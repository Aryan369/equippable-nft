// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PaymentSplitter is Ownable{

    struct Payee {
        address _address;
        uint256 _share;
    }

    mapping (uint256 => Payee) public payees;
    uint256 public numberOfPayees;

    function setPayees(Payee[] memory _payees) public onlyOwner {
        for(uint i = 1; i <= _payees.length;){
            payees[i] = _payees[i];
            unchecked {++i;}
        }
        numberOfPayees = _payees.length;
    }

    function withdraw() external {
        uint256 _balance = address(this).balance;
        for(uint i = 1; i <= numberOfPayees;){
            _withdraw(payees[i]._address, _balance * payees[i]._share / 100);
        }
    }

    function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }

    receive() external payable{}
}