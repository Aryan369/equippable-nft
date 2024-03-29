// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MintingUtils is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter internal _tokenIdTracker;

    uint256 internal _maxSupply;
    uint256 internal _mintPrice;
    bool internal _paused;

    constructor(uint256 maxSupply_, uint256 mintPrice_) {
        _maxSupply = maxSupply_;
        _mintPrice = mintPrice_;
    }

    modifier saleIsOpen() {
        require(!_paused, "The contract is paused.");
        require(totalSupply() < _maxSupply, "Max tokens have already minted");
        _;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdTracker.current();
    }

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    function mintPrice() public view returns (uint256) {
        return _mintPrice;
    }

    function setMintPrice(uint256 mintPrice_) public onlyOwner {
        _mintPrice = mintPrice_;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function setPaused(bool _state) public onlyOwner{
        _paused = _state;
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        _withdraw(to, amount);
    }

    function withdrawAll(address to) external onlyOwner {
        _withdraw(to, address(this).balance);
    }

    function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }
}
