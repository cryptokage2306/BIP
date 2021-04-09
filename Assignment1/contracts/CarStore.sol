// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

contract CarStore {
    // declare storeOwner address
    address storeOwner;
    
    // declare BuyCar event
    event BuyCar(address _carId, address _buyerAddress);
    
    // declare a Car structure
    struct Car {
        uint256 price;
        bool sold;
        address buyerAddress;
    }
    // declare a mapping of Inventory with key of address that is carIdentity and value is Car structure
    mapping (address=>Car) inventory;

    // declare a carList array which track car
    address[] carList;

    // Here we are initializing storeOwner to address which deploy the contract
    constructor() public {
        storeOwner = msg.sender;
    }
    
    // This function add car to inventory and carList array
    function addCar(address _carId, uint256 _price) public {
        require(msg.sender != address(0));
        require(msg.sender == storeOwner, "Not Authorize to add cars");
        inventory[_carId].price = _price;
        inventory[_carId].sold = false;
        inventory[_carId].buyerAddress = address(0);
        carList.push(_carId);
    }

    // This function let sender buy car based on carId
    function buyCar(address _carId) public {
        require(inventory[_carId].sold == false, 'Car already sold');
        inventory[_carId].sold = true;
        inventory[_carId].buyerAddress = msg.sender;
        emit BuyCar( _carId, msg.sender);
    }
    
    // return list of cars registered for selling in store
    function getCarList()public view returns( address  [] memory){
        return carList;
    }

    // return car info based on carId
    function getCar(address _carId)public view returns( Car memory){
        return inventory[_carId];
    }
}
