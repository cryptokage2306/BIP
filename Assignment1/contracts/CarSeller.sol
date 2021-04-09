// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract CarSeller {
    address seller;
    uint256 public total;
    event SellCar(address carIdentity, uint256 amount);
    struct Record {
        address carIdentity;
        uint256 amount;
    }

    mapping (address=>uint256) inventory;
    Record[] public CarSalesRecords;

    constructor() {
        seller = msg.sender;
    }

    function addCar(address _carIdentity, uint256 _amount) public {
        require(msg.sender == seller, "Not Authorize to add cars");
        inventory[_carIdentity] = _amount;
    }

    function sellCard(address _carIdentity, uint256 _amount) public {
        require(inventory[_carIdentity] != 0 && inventory[_carIdentity] < _amount, 'Car is not present');
        require(_carIdentity != address(0));
        delete inventory[_carIdentity];
        CarSalesRecords.push(Record({
            carIdentity: _carIdentity,
            amount: _amount
        }));
        total += 1;
        emit SellCar( _carIdentity,_amount);
    }
}
