// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.15;

import "./RMRK/base/RMRKBaseStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTBase is Ownable, RMRKBaseStorage {
    
    constructor(string memory metadataURI, string memory type__)
        RMRKBaseStorage(metadataURI, type__)
    {}

    function addPart(IntakeStruct calldata intakeStruct)
        external
        onlyOwner
    {
        _addPart(intakeStruct);
    }

    function addPartList(IntakeStruct[] calldata intakeStructs)
        external
        onlyOwner
    {
        _addPartList(intakeStructs);
    }

    function addEquippableAddresses(
        uint64 partId,
        address[] memory equippableAddresses
    ) external onlyOwner {
        _addEquippableAddresses(partId, equippableAddresses);
    }

    function addEquippableAddressesToParts(
        uint64[] calldata partIds,
        address[] memory equippableAddresses
    ) external onlyOwner {
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
        address[] memory equippableAddresses
    ) external onlyOwner {
        _setEquippableAddresses(partId, equippableAddresses);
    }

    function setEquippableAddressesToParts(
        uint64[] calldata partIds,
        address[] memory equippableAddresses
    ) external onlyOwner {
        uint256 numParts = partIds.length;

        for (uint256 i; i < numParts; ) {
            uint64 partId = partIds[i];
            _setEquippableAddresses(partId, equippableAddresses);
            unchecked {++i;}
        }
    }

    function setEquippableToAll(uint64 partId) external onlyOwner {
        _setEquippableToAll(partId);
    }

    function setEquippableToAllToParts(uint64[] calldata partIds) external onlyOwner {
        uint256 numParts = partIds.length;

        for (uint256 i; i < numParts;){
            uint64 partId = partIds[i];
            _setEquippableToAll(partId);
            unchecked{++i;}
        }
    }

    function resetEquippableAddresses(uint64 partId) external onlyOwner {
        _resetEquippableAddresses(partId);
    }

    function resetEquippableAddressesOfParts(uint64[] calldata partIds) external onlyOwner {
        uint256 numParts = partIds.length;

        for (uint256 i; i < numParts;){
            uint64 partId = partIds[i];
            _resetEquippableAddresses(partId);
            unchecked{++i;}
        }
    }

    function setZIndex(uint64[] memory partIds, uint8[] memory zIndexes) external onlyOwner {
        _setZIndex(partIds, zIndexes);
    }
}
