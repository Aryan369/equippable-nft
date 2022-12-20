//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract WhitelistUtils is Ownable, ReentrancyGuard {
    address public nftContract;

    bool public preSale;

    bytes32 private root;
    bytes32 private rootFreeMint;

    uint256 public whitelistMintLimit = 1;
    uint256 public freeMintLimit = 1;

    uint256 whitelistKey = 0;
    uint256 freeKey = 0;

    mapping (uint256 => mapping(address=>uint256)) whitelistClaimed;
    mapping (uint256 => mapping(address=>uint256)) freeMintClaimed;

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

    function isValidFreeMint(bytes32[] memory proof, bytes32 leaf) public view returns(bool) {
        return MerkleProof.verify(proof, rootFreeMint, leaf);
    }

    function setRoot(bytes32 _root) external onlyOwner{
        root = _root;
    }

    function setRootFreeMint(bytes32 _root) external onlyOwner{
        rootFreeMint = _root;
    }

    // -------------------------------------------------- //

    function resetClaimedList(uint8 _opt) public onlyOwner {
        if(_opt == 0){
            whitelistKey++;
        }
        else if (_opt == 1) {
            freeKey++;
        }
        else{
            whitelistKey++;
            freeKey++;
        }
    }

    // --------------------------------------------------- //

    //getters
    function isPresaleOn() external view returns(bool){
        return preSale;
    }

    // setters

    function setWhitelistMintLimit(uint256 _limit) external onlyOwner{
        whitelistMintLimit = _limit;
    }

    function setFreeMintClaimed(uint256 _limit) external onlyOwner {
        freeMintLimit = _limit;
    }

    function setPresale(bool _state) external onlyOwner{
        preSale = _state;
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
        require(preSale, "THE GATES ARE CLOSED");
        require(isValid(proof, keccak256(abi.encodePacked(_sender))), "THE GATES ONLY OPEN FOR THE CHOSEN ONES");
        require(whitelistClaimed[whitelistKey][_sender] + numberOfTokens <= whitelistMintLimit, "You have reached whitelist mint limit");
        whitelistClaimed[freeKey][_sender] += numberOfTokens;
    }

    function _freeMintCheck(uint256 numberOfTokens, bytes32[] memory proof, address _sender) private {
        require(isValidFreeMint(proof, keccak256(abi.encodePacked(_sender))), "YOU ARE NOT A CHOSEN ONE");
        require(freeMintClaimed[whitelistKey][_sender] + numberOfTokens <= freeMintLimit, "You have already claimed");
        freeMintClaimed[freeKey][_sender] += numberOfTokens;
    }
}