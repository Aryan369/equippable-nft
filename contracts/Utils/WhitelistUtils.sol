//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract WhitelistUtils is Ownable, ReentrancyGuard {
    address public nftContract;

    bool public preSale;
    bool public preSaleSecondary;

    bytes32 private root;
    bytes32 private rootSecondary;
    bytes32 private rootFreeMint;

    uint256 public whitelistMintLimit = 1;
    uint256 public whitelistSecondaryMintLimit = 1;
    uint256 public freeMintLimit = 1;

    mapping (address=>uint256) whitelistClaimed;
    mapping (address=>uint256) whitelistSecondaryClaimed;
    mapping (address=>uint256) freeMintClaimed;

    constructor(address _nftContract){
        setNFTContract(_nftContract);
    }

    function setNFTContract(address nftContract_) public onlyOwner{
        nftContract = nftContract_;
    }

    // ---------------- MERKLE PROOF ------------------------ //
    
    function isValid(bytes32[] memory proof, bytes32 leaf) public view returns(bool) {
        return MerkleProof.verify(proof, root, leaf);
    }

    function isValidSecondary(bytes32[] memory proof, bytes32 leaf) public view returns(bool) {
        return MerkleProof.verify(proof, rootSecondary, leaf);
    }

    function isValidFreeMint(bytes32[] memory proof, bytes32 leaf) public view returns(bool) {
        return MerkleProof.verify(proof, rootFreeMint, leaf);
    }

    function setRoot(bytes32 _root) external onlyOwner{
        root = _root;
    }

    function setRootSecondary(bytes32 _root) external onlyOwner{
        rootSecondary = _root;
    }

    function setRootFreeMint(bytes32 _root) external onlyOwner{
        rootFreeMint = _root;
    }

    // -------------------------------------------------- //

    // --------------------------------------------------- //

    //getters
    function isPresaleOn() external view returns(bool){
        if(preSale || preSaleSecondary){
            return true;
        }
        else{
            return false;
        }
    }

    // setters

    function setWhitelistMintLimit(uint256 _limit) external onlyOwner{
        whitelistMintLimit = _limit;
    }

    function setWhitelistSecondaryMintLimit(uint256 _limit) external onlyOwner{
        whitelistSecondaryMintLimit = _limit;
    }

    function setFreeMintClaimed(uint256 _limit) external onlyOwner {
        freeMintLimit = _limit;
    }

    function setPresaleOn(bool _preSalePrimary) external onlyOwner{
        if(_preSalePrimary){
            preSale = true;
            preSaleSecondary = false;
        }
        else {
            preSale = false;
            preSaleSecondary = true;
        }
    }

    function setPresaleOff() external onlyOwner {
        preSale = false;
        preSaleSecondary = false;
    }
    
    // --------------------------------------------------- //

    // ------------------- MINT -------------------------- //
    function presaleCheck(uint256 numberOfTokens, bytes32[] memory proof, address _sender, bool _freeMint) external{
        require(msg.sender == owner() || msg.sender == nftContract, "Not Authorised.");
        if(_freeMint){
            _freeMintCheck(numberOfTokens, proof, _sender);
        }
        else{
            _whitelistMintCheck(numberOfTokens, proof, _sender);
        }
    }


    function _whitelistMintCheck(uint256 numberOfTokens, bytes32[] memory proof, address _sender) private{
        require(preSaleSecondary || preSale, "THE GATES ARE CLOSED");

        if(preSaleSecondary){
            require(isValidSecondary(proof, keccak256(abi.encodePacked(_sender))), "THE GATES ONLY OPEN FOR THE CHOSEN ONES");
            require(whitelistSecondaryClaimed[_sender] + numberOfTokens <= whitelistSecondaryMintLimit, "You have reached whitelist mint limit");
            whitelistSecondaryClaimed[_sender] += numberOfTokens;
        }
        else if (preSale){
            require(isValid(proof, keccak256(abi.encodePacked(_sender))), "THE GATES ONLY OPEN FOR THE CHOSEN ONES");
            require(whitelistClaimed[_sender] + numberOfTokens <= whitelistMintLimit, "You have reached whitelist mint limit");
            whitelistClaimed[_sender] += numberOfTokens;
        }
    }

    function _freeMintCheck(uint256 numberOfTokens, bytes32[] memory proof, address _sender) private {
        require(isValidFreeMint(proof, keccak256(abi.encodePacked(_sender))), "YOU ARE NOT A CHOSEN ONE");
        require(freeMintClaimed[_sender] + numberOfTokens <= freeMintLimit, "You have already claimed");
        freeMintClaimed[_sender] += numberOfTokens;
    }
}