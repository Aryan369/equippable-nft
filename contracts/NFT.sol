// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.16;

import "./Utils/MintingUtils.sol";
import "./Utils/IWhitelistUtils.sol";
import "./RMRK/equippable/RMRKEquippable.sol";
// @dev 
import "./RMRK/utils/RMRKEquipRenderUtils.sol";
/* import "hardhat/console.sol"; */

contract NFT is Ownable, MintingUtils, RMRKEquippable {
    using Counters for Counters.Counter;

    uint256 private _totalResources;

    uint256 public maxMintAmountPerTx = 20;
    uint256 private RESERVED_NFT = 33;

    IWhitelistUtils public whitelistUtils;

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 mintPrice,
        string memory _fallbackURI
    ) RMRKEquippable(name, symbol) MintingUtils(maxSupply, mintPrice) {
        setFallbackURI(_fallbackURI);
    }
    // --------------- MINT -------------------------- //

    modifier mintReq (uint256 numberOfTokens) {
        if(whitelistUtils != IWhitelistUtils(address(0))) {require(!IWhitelistUtils(whitelistUtils).isPresaleOn(), "Presale is going on");}
        require((totalSupply() + numberOfTokens) <= maxSupply(), "Not enough tokens left.");
        require(numberOfTokens <= maxMintAmountPerTx && numberOfTokens > 0, "Max mint amount per transaction is 20.");   
        require(msg.value >= (mintPrice() * numberOfTokens), "Not enough ether sent.");
        _;
    }

    function reserveNFT() external onlyOwner {
        require((totalSupply() + RESERVED_NFT) <= maxSupply(), "Not enough tokens left.");
        for(uint i = 0; i< RESERVED_NFT;) {
            _tokenIdTracker.increment();
            uint256 currentToken = _tokenIdTracker.current();
            _safeMint(owner(), currentToken);
            unchecked {++i;}
        }
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
    
    // ---------------- TRANSFER UTILS ------------------------- //
    function transfer(address to, uint256 tokenId) public virtual {
        transferFrom(_msgSender(), to, tokenId);
    }

    function nestTransfer(
        address to,
        uint256 tokenId,
        uint256 destinationId
    ) public virtual {
        nestTransferFrom(_msgSender(), to, tokenId, destinationId);
    }
    
    // ---------------- RESOURCES ------------------------- //

    function addResourceToToken(
        uint256 tokenId,
        uint64 resourceId,
        uint64 overwrites
    ) public virtual onlyOwner {
        _addResourceToToken(tokenId, resourceId, overwrites);
    }

    function addResourceEntry(
        uint64 equippableGroupId,
        address baseAddress,
        string memory metadataURI,
        uint64[] memory fixedPartIds,
        uint64[] memory slotPartIds
    ) public virtual onlyOwner returns (uint256) {
        unchecked {
            _totalResources += 1;
        }
        _addResourceEntry(
            uint64(_totalResources),
            equippableGroupId,
            baseAddress,
            metadataURI,
            fixedPartIds,
            slotPartIds
        );
        return _totalResources;
    }

    function setValidParentForEquippableGroup(
        uint64 equippableGroupId,
        address parentAddress,
        uint64 partId
    ) public virtual onlyOwner {
        _setValidParentForEquippableGroup(
            equippableGroupId,
            parentAddress,
            partId
        );
    }

    function totalResources() public view virtual returns (uint256) {
        return _totalResources;
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

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        returns (string memory)
    {
        return getResourceMetadata(_tokenId, getActiveResourcePriorities(_tokenId)[0]);
    }

    // ---------------- WHITELIST UTILS ------------------------- //
    function setWhitelistUtils(IWhitelistUtils _address) public onlyOwner{
        whitelistUtils = _address;
    }
    // ---------------------------------------------------------- //

    receive() external payable {}
}
