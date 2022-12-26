//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CodenameUtils is Ownable {

    mapping(uint256 => string) codenames;
    mapping(string => bool) codenameExists;

    // --------------------- CODENAME --------------------------- //
    function _setCodename(string memory _codename, uint256 _tokenId) internal {
        require(codenameExists[_codename] == false, "Codename already assigned.");

        bytes memory bs = bytes(_codename);
        require(bs.length <= 10, "Max charactes allowed are 10");

        codenameExists[codenames[_tokenId]] = false;
        codenames[_tokenId] = _codename;
        codenameExists[codenames[_tokenId]] = true;
    }

    function getCodename(uint256 _tokenId) public view returns(string memory) {
        return codenames[_tokenId];
    }
    // ---------------------------------------------------------- //
}