// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "./utils/MintingUtils.sol";
import "./utils/IWhitelistUtils.sol";
import "./extension/Royalties.sol";
import "@rmrk-team/evm-contracts/contracts/RMRK/equippable/RMRKEquippable.sol";
import "@rmrk-team/evm-contracts/contracts/RMRK/utils/RMRKTokenURI.sol";
import "@rmrk-team/evm-contracts/contracts/implementations/IRMRKInitData.sol";
import "@rmrk-team/evm-contracts/contracts/RMRK/utils/RMRKEquipRenderUtils.sol";
/* import "hardhat/console.sol"; */

contract NFT is 
    Ownable, 
    IRMRKInitData,
    MintingUtils,
    Royalties,
    RMRKTokenURI,
    RMRKEquippable {
    using Counters for Counters.Counter;

    uint256 private _totalAssets;

    uint256 public maxMintAmountPerTx = 21; //maxMintperTx = 20
    uint256 private RESERVED_NFT = 33;

    IWhitelistUtils public whitelistUtils;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory tokenURI_,
        InitData memory data
    ) 
    RMRKEquippable(name_, symbol_) 
    MintingUtils(data.maxSupply, data.pricePerMint)
    Royalties(data.royaltyRecipient, data.royaltyPercentageBps) //1bps = 0.01%
    RMRKTokenURI(tokenURI_, data.tokenUriIsEnumerable)
    {}
    // --------------- MINT -------------------------- //

    modifier mintReq (uint256 numberOfTokens) {
        require((totalSupply() + numberOfTokens) < maxSupply() + 1, "Not enough tokens left.");
        require(numberOfTokens < maxMintAmountPerTx && numberOfTokens > 0, "Max mint amount per transaction is 20.");   
        require(!(msg.value < mintPrice() * numberOfTokens) , "Not enough ether sent.");
        _;
    }

    function reserveNFT() external onlyOwner {
        require((totalSupply() + RESERVED_NFT) < maxSupply() + 1, "Not enough tokens left.");
        for(uint i = 0; i< RESERVED_NFT;) {
            _tokenIdTracker.increment();
            uint256 currentToken = _tokenIdTracker.current();
            _safeMint(owner(), currentToken, "");
            unchecked {++i;}
        }
    }

    function mint(address to, uint256 numberOfTokens) external payable saleIsOpen mintReq(numberOfTokens) nonReentrant {
        for(uint i = 0; i< numberOfTokens;) {
            if(totalSupply() < maxSupply()){
                _tokenIdTracker.increment();
                uint256 currentToken = _tokenIdTracker.current();
                _safeMint(to, currentToken, "");
                unchecked {++i;}
            }
        }
    }
    function presaleMint(bytes32[] memory proof, bool _freeMint) public payable saleIsOpen nonReentrant {
        if(whitelistUtils != IWhitelistUtils(address(0))) {require(IWhitelistUtils(whitelistUtils).isPresaleOn(), "Presale is over");}
        if(!_freeMint){
            require(!(msg.value < mintPrice()) , "Not enough ether sent.");
        }
        IWhitelistUtils(whitelistUtils).presaleCheck(1, proof, _msgSender(), _freeMint);
        
        _tokenIdTracker.increment();
        uint256 currentToken = _tokenIdTracker.current();
        _safeMint(_msgSender(), currentToken, "");
    }

    function nestMint(
        address to,
        uint256 numberOfTokens,
        uint256 destinationId
    ) external payable mintReq(numberOfTokens) saleIsOpen {
        for(uint i = 0; i< numberOfTokens;) {
            if(totalSupply() < maxSupply()){
                _tokenIdTracker.increment();
                uint256 currentToken = _tokenIdTracker.current();
                _nestMint(to, currentToken, destinationId, "");
                unchecked {++i;}
            }
        }
    }

    // ------------------------------------------------ //
    
    // ---------------- UTILS ------------------------- //
    // function transfer(address to, uint256 tokenId) public virtual {
    //     transferFrom(_msgSender(), to, tokenId);
    // }

    // function nestTransfer(
    //     address to,
    //     uint256 tokenId,
    //     uint256 destinationId
    // ) public virtual {
    //     nestTransferFrom(_msgSender(), to, tokenId, destinationId, "");
    // }

    function setTokenURI(
        string memory tokenURI_,
        bool isEnumerable
    ) internal virtual {
        _setTokenURI(tokenURI_, isEnumerable);
    }
    
    // ---------------- RESOURCES ------------------------- //

    function addAssetToToken(
        uint256 tokenId,
        uint64 assetId,
        uint64 replacesAssetWithId
    ) public virtual onlyOwner {
        _addAssetToToken(tokenId, assetId, replacesAssetWithId);
        if (_msgSender() == ownerOf(tokenId)) {
            _acceptAsset(tokenId, _pendingAssets[tokenId].length - 1, assetId);
        }
    }

    function addEquippableAssetEntry(
        uint64 equippableGroupId,
        address baseAddress,
        string memory metadataURI,
        uint64[] calldata partIds
    ) public virtual onlyOwner returns (uint256) {
        unchecked {
            _totalAssets += 1;
        }
        _addAssetEntry(
            uint64(_totalAssets),
            equippableGroupId,
            baseAddress,
            metadataURI,
            partIds
        );
        return _totalAssets;
    }

    function addAssetEntry(
        string memory metadataURI
    ) public virtual onlyOwner returns (uint256) {
        unchecked {
            _totalAssets += 1;
        }
        _addAssetEntry(uint64(_totalAssets), metadataURI);
        return _totalAssets;
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

    function totalAssets() public view virtual returns (uint256) {
        return _totalAssets;
    }
    

    // ------------------ ROYALTY ----------------------- //

    function setRoyaltyPercentage(uint256 newRoyaltyPercentageBps) public onlyOwner {
        _setRoyaltyPercentage(newRoyaltyPercentageBps);
    }

    function updateRoyaltyRecipient(address newRoyaltyRecipient) public virtual override onlyOwner {
        _setRoyaltyRecipient(newRoyaltyRecipient);
    }

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

    function priorityAssetTokenURI(uint256 _tokenId)
        public
        view
        virtual
        returns (string memory)
    {
        return getAssetMetadata(_tokenId, getActiveAssetPriorities(_tokenId)[0]);
    }

    // ---------------- WHITELIST UTILS ------------------------- //
    function setWhitelistUtils(IWhitelistUtils _address) public onlyOwner{
        whitelistUtils = _address;
    }
    // ---------------------------------------------------------- //

    receive() external payable {}
}
