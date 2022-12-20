// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/interfaces/IERC2981.sol";

abstract contract Royalties is IERC2981 {
    address private _royaltyRecipient;
    uint256 private _royaltyPercentageBps;

    /**
     * @notice Used to initiate the smart contract.
     * @dev `royaltyPercentageBps` is expressed in basis points, so 1 basis point equals 0.01% and 500 basis points
     *  equal 5%.
     * @param royaltyRecipient Address to which royalties should be sent
     * @param royaltyPercentageBps The royalty percentage expressed in basis points
     */
    constructor(
        address royaltyRecipient,
        uint256 royaltyPercentageBps //in basis points
    ) {
        _setRoyaltyRecipient(royaltyRecipient);
        _setRoyaltyPercentage(royaltyPercentageBps);
    }

    function updateRoyaltyRecipient(
        address newRoyaltyRecipient
    ) external virtual;

    function _setRoyaltyRecipient(address newRoyaltyRecipient) internal {
        _royaltyRecipient = newRoyaltyRecipient;
    }

    function getRoyaltyRecipient() external view virtual returns (address) {
        return _royaltyRecipient;
    }

    function _setRoyaltyPercentage(uint256 royaltyPercentageBps) internal {
        _royaltyPercentageBps = royaltyPercentageBps;
    }

    function getRoyaltyPercentage() external view virtual returns (uint256) {
        return _royaltyPercentageBps;
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    )
        external
        view
        virtual
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = _royaltyRecipient;
        royaltyAmount = (salePrice * _royaltyPercentageBps) / 10000;
    }
}
