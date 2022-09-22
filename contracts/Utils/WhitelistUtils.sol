//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract WhitelistUtils is Ownable, ReentrancyGuard {
    address public nftContract;

    bool public preSale;
    bool public preSaleT;

    bytes32 private root;
    bytes32 private rootT;
    bytes32 private rootFreeMint;

    mapping (address => bool) preSaleClaimed;
    mapping (address => bool) preSaleTClaimed;
    mapping (address => bool) freeMintClaimed;

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

    function isValidT(bytes32[] memory proof, bytes32 leaf) public view returns(bool) {
        return MerkleProof.verify(proof, rootT, leaf);
    }

    function isValidFreeMint(bytes32[] memory proof, bytes32 leaf) public view returns(bool) {
        return MerkleProof.verify(proof, rootFreeMint, leaf);
    }

    function setRoot(bytes32 _root) external onlyOwner{
        root = _root;
    }

    function setRootT(bytes32 _root) external onlyOwner{
        rootT = _root;
    }

    function setRootFreeMint(bytes32 _root) external onlyOwner{
        rootFreeMint = _root;
    }

    // -------------------------------------------------- //

    // --------------------------------------------------- //

    //getters
    function isPresaleClaimed(address _address) public view returns(bool){
        return preSaleClaimed[_address];
    }

    function isPresaleTClaimed(address _address) public view returns(bool){
        return preSaleTClaimed[_address];
    }

    function isFreeMintClaimed(address _address) public view returns(bool){
        return freeMintClaimed[_address];
    }

    function isPresaleOn() external view returns(bool){
        if(preSale || preSaleT){
            return true;
        }
        else{
            return false;
        }
    }

    // setters

    function setPresaleClaimed(address _address) private {
        preSaleClaimed[_address] = true;
    }

    function setPresaleTClaimed(address _address) private {
        preSaleTClaimed[_address] = true;
    }

    function setFreeMintClaimed(address _address) private {
        freeMintClaimed[_address] = true;
    }

    function setPresaleOn(bool _preSale) external onlyOwner{
        if(_preSale){
            preSale = true;
            if(preSaleT) {
                preSaleT = false;
            }
        }
        else {
            if(preSale) {
                preSale = false;
            }
            preSaleT = true;
        }
    }

    function setPresaleOff() external onlyOwner {
        preSale = false;
        preSaleT = false;
    }
    
    // --------------------------------------------------- //

    // ------------------- MINT -------------------------- //
    function presaleCheck(bytes32[] memory proof, address _sender, bool _freeMint) external{
        if(_freeMint){
            freeMintCheck(proof, _sender);
        }
        else{
            whitelistMintCheck(proof, _sender);
        }
    }


    function freeMintCheck(bytes32[] memory proof, address _sender) private {
        require(msg.sender == owner() || msg.sender == nftContract, "Not Authorised.");
        require(isValidFreeMint(proof, keccak256(abi.encodePacked(_sender))), "YOU ARE NOT A CHOSEN ONE");
        require(!isFreeMintClaimed(_sender), "You have already claimed.");
        setFreeMintClaimed(_sender);
    }

    function whitelistMintCheck(bytes32[] memory proof, address _sender) private{
        require(msg.sender == owner() || msg.sender == nftContract, "Not Authorised.");
        require(preSaleT || preSale, "THE GATES ARE CLOSED");

        if(preSaleT){
            require(isValidT(proof, keccak256(abi.encodePacked(_sender))), "THE GATES ONLY OPEN FOR THE CHOSEN ONES");
            require(!isPresaleTClaimed(_sender), "You have already claimed");
            setPresaleTClaimed(_sender);
        }
        else if (preSale){
            require(isValid(proof, keccak256(abi.encodePacked(_sender))), "THE GATES ONLY OPEN FOR THE CHOSEN ONES");
            require(!isPresaleClaimed(_sender), "You have already claimed");
            setPresaleClaimed(_sender);
        }
    }
}