// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IWhitelistUtils is IERC165 {
    function isPresaleOn() external view returns(bool);
    function presaleCheck(uint256 numberOfTokens, bytes32[] memory proof, address _sender, bool _freeMint) external;
}