// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.16;

import "./Utils/MintingUtils.sol";
import "./RMRK/RMRKEquippable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@rmrk-team/evm-contracts/contracts/RMRK/utils/RMRKEquipRenderUtils.sol";
/* import "hardhat/console.sol"; */

interface IWhitelistUtils {
    function isPresaleOn() external view returns(bool);
    function presaleCheck(uint256 numberOfTokens, bytes32[] memory proof, address _sender, bool _freeMint) external;
}

contract NFT is Ownable, MintingUtils, RMRKEquippable, ReentrancyGuard {
    using Counters for Counters.Counter;

    uint256 public maxMintAmountPerTx = 20;
    uint256 private RESERVED_NFT = 33;

    bool public reservedNFTMinted;

    address public whitelistUtils;

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 mintPrice,
        string memory _fallbackURI,
        address _whitelistUtilsContract
    ) RMRKEquippable(name, symbol) MintingUtils(maxSupply, mintPrice) {
        _setFallbackURI(_fallbackURI);
        setWhitelistUtils(_whitelistUtilsContract);
    }
    // --------------- MINT -------------------------- //

    modifier mintReq (uint256 numberOfTokens) {
        require(!IWhitelistUtils(whitelistUtils).isPresaleOn(), "Presale is going on");
        if(!reservedNFTMinted){
            require((totalSupply() + numberOfTokens) <= (maxSupply() - RESERVED_NFT), "Not enough tokens left.");
        }
        else{
            require((totalSupply() + numberOfTokens) <= maxSupply(), "Not enough tokens left.");
        }
        require(numberOfTokens <= maxMintAmountPerTx && numberOfTokens > 0, "Max mint amount per transaction is 20.");   
        require(msg.value >= (mintPrice() * numberOfTokens), "Not enough ether sent.");
        _;
    }

    function reserveNFT() external onlyOwner {
      if (reservedNFTMinted) revert ("Reserved NFTs already minted");
      for(uint i = 0; i< RESERVED_NFT;) {
          _tokenIdTracker.increment();
          uint256 currentToken = _tokenIdTracker.current();
          _safeMint(owner(), currentToken);
          unchecked {++i;}
      }
      reservedNFTMinted = true;
    }

    function mint(uint256 numberOfTokens) external payable saleIsOpen mintReq(numberOfTokens) nonReentrant {
        for(uint i = 0; i< numberOfTokens;) {
            if(totalSupply() < maxSupply()){
                _tokenIdTracker.increment();
                uint256 currentToken = _tokenIdTracker.current();
                _safeMint(_msgSender(), currentToken);
                unchecked {++i;}
            }
        }
    }

    function mintNesting(
        address to,
        uint256 numberOfTokens,
        uint256 destinationId
    ) external payable mintReq(numberOfTokens) saleIsOpen {
        for(uint i = 0; i< numberOfTokens;) {
            if(totalSupply() < maxSupply()){
                _tokenIdTracker.increment();
                uint256 currentToken = _tokenIdTracker.current();
                _nestMint(to, currentToken, destinationId);
                unchecked {++i;}
            }
        }
    }

    function presaleMint(uint256 numberOfTokens, bytes32[] memory proof, bool _freeMint) public payable nonReentrant saleIsOpen {
        if(!_freeMint){
            require(msg.value >= mintPrice(), "Not enough ether sent.");
        }
        IWhitelistUtils(whitelistUtils).presaleCheck(numberOfTokens, proof, _msgSender(), _freeMint);
        
        _tokenIdTracker.increment();
        uint256 currentToken = _tokenIdTracker.current();
        _safeMint(_msgSender(), currentToken);
    }

    // ------------------------------------------------ //

    //update for reentrancy
    function burn(uint256 tokenId) public onlyApprovedOrDirectOwner(tokenId) {
        _burn(tokenId);
    }

    // ---------------- RESOURCES ------------------------- //

    function addResourceToToken(
        uint256 tokenId,
        uint64 resourceId,
        uint64 overwrites
    ) external onlyOwner {
        // This reverts if token does not exist:
        ownerOf(tokenId);
        _addResourceToToken(tokenId, resourceId, overwrites);
    }

    function addResourceEntry(
        ExtendedResource calldata resource,
        uint64[] calldata fixedPartIds,
        uint64[] calldata slotPartIds
    ) external onlyOwner {
        _addResourceEntry(resource, fixedPartIds, slotPartIds);
    }

    function setValidParentRefId(
        uint64 refId,
        address parentAddress,
        uint64 partId
    ) external onlyOwner {
        _setValidParentRefId(refId, parentAddress, partId);
    }

    // ------------------------------------------------ //

    // ---------------- WALLET OF OWNER ------------------------- //

    function walletOfOwner(address _owner)
    external
    view
    returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;

        while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply()) {
            address currentTokenOwner = ownerOf(currentTokenId);

            if (currentTokenOwner == _owner) {
                ownedTokenIds[ownedTokenIndex] = currentTokenId;

                unchecked {++ownedTokenIndex;}
            }

            unchecked {++currentTokenId;}
        }

        return ownedTokenIds;
    }

    // ------------------------------------------------ //

    // ---------------- WHITELIST UTILS ------------------------- //
    function setWhitelistUtils(address _address) public onlyOwner{
        whitelistUtils = _address;
    }
    // ---------------------------------------------------------- //
}
