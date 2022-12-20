// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./RMRK/Base/RMRKBaseStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTBase is Ownable, RMRKBaseStorage {
    
    constructor(
        string memory metadataURI, 
        string memory type__
    ) RMRKBaseStorage(metadataURI, type__) {}

    function addPart(IntakeStruct calldata intakeStruct) public virtual onlyOwner {
        _addPart(intakeStruct);
    }

    function addPartList(IntakeStruct[] calldata intakeStructs)public virtual onlyOwner {
        _addPartList(intakeStructs);
    }

    function addEquippableAddresses(
        uint64 partId,
        address[] calldata equippableAddresses
    ) public virtual onlyOwner {
        _addEquippableAddresses(partId, equippableAddresses);
    }

    function addEquippableAddressesToParts(
        uint64[] calldata partIds,
        address[] calldata equippableAddresses
    ) public virtual onlyOwner {
        uint256 numParts = partIds.length;

        for (uint256 i; i < numParts; ) {
            uint64 partId = partIds[i];
            _addEquippableAddresses(partId, equippableAddresses);
            unchecked {
                ++i;
            }
        }
    }

    function setEquippableAddresses(
        uint64 partId,
        address[] calldata equippableAddresses
    ) public virtual onlyOwner {
        _setEquippableAddresses(partId, equippableAddresses);
    }

    function setEquippableAddressesToParts(
        uint64[] calldata partIds,
        address[] calldata equippableAddresses
    ) public virtual onlyOwner {
        uint256 numParts = partIds.length;

        for (uint256 i; i < numParts; ) {
            uint64 partId = partIds[i];
            _setEquippableAddresses(partId, equippableAddresses);
            unchecked {++i;}
        }
    }

    function setEquippableToAll(uint64 partId) public virtual onlyOwner {
        _setEquippableToAll(partId);
    }

    function setEquippableToAllToParts(uint64[] calldata partIds) public virtual onlyOwner {
        uint256 numParts = partIds.length;

        for (uint256 i; i < numParts;){
            uint64 partId = partIds[i];
            _setEquippableToAll(partId);
            unchecked{++i;}
        }
    }

    function resetEquippableAddresses(uint64 partId) public virtual onlyOwner {
        _resetEquippableAddresses(partId);
    }

    function resetEquippableAddressesOfParts(uint64[] calldata partIds) public virtual onlyOwner {
        uint256 numParts = partIds.length;

        for (uint256 i; i < numParts;){
            uint64 partId = partIds[i];
            _resetEquippableAddresses(partId);
            unchecked{++i;}
        }
    }

    function setZIndex(uint64[] memory partIds, uint8[] memory zIndexes) public virtual onlyOwner {
        _setZIndex(partIds, zIndexes);
    }
}
