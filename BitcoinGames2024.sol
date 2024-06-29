// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract rentOneCar {
    // Create Struct named Car with the following members:
    // string make; uint year; uint doors; uint mileage; uint256 rentalAmt
    struct Car {
        string make;
        uint year;
        uint doors;
        uint mileage;
        uint256 rentalAmt;
    }

    Car car;

    address owner;
    address approvedRenter;
    bool isRented;

    // Constants for approval and return confirmation codes
    bytes32 constant approvalCode = 0x1234567890123456789012345678901234567890123456789012345678901234;
    bytes32 constant returnConfirmation = 0x0987654321098765432109876543210987654321098765432109876543210987;

    constructor(string memory _make, uint year, uint doors, uint mileage, uint256 rentalAmt) {
        owner = msg.sender;
        car = Car(_make, year, doors, mileage, rentalAmt);
        isRented = false;
    }

    function carDetails() public view returns (Car memory) {
        return car;
    }

    function rentCar() public payable returns (bytes32) {
        require(car.rentalAmt == msg.value, "Funds don't equal rental amount");
        require(isRented == false, "Car is already rented");

        approvedRenter = msg.sender;
        isRented = true;
        return approvalCode;
    }

    function returnCar() public returns (bytes32) {
        require(msg.sender == approvedRenter, "Only the approved renter can return the car");
        isRented = false;
        approvedRenter = address(0);
        return returnConfirmation;
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract sellOneCar {
    // Create Struct named Car with the following members:
    // string make; uint year; uint doors; uint mileage; uint256 saleAmt
    struct Car {
        string make;
        uint year;
        uint doors;
        uint mileage;
        uint256 saleAmt;
    }

    Car public car;
    address public owner;
    address public approvedBuyer;
    bool public isSold;

    // Constants for approval and confirmation codes
    bytes32 constant approvalCode = 0x1234567890123456789012345678901234567890123456789012345678901234;
    bytes32 constant saleConfirmation = 0x0987654321098765432109876543210987654321098765432109876543210987;

    constructor(string memory _make, uint year, uint doors, uint mileage, uint256 saleAmt) {
        owner = msg.sender;
        car = Car(_make, year, doors, mileage, saleAmt);
        isSold = false;
    }

    // Function to get car details
    function carDetails() public view returns (Car memory) {
        return car;
    }

    // Function to approve the buyer
    function approveBuyer(address _buyer) public {
        require(msg.sender == owner, "Only owner can approve a buyer");
        require(!isSold, "Car is already sold");
        approvedBuyer = _buyer;
    }

    // Function to buy the car
    function buyCar() public payable returns (bytes32) {
        require(msg.sender == approvedBuyer, "You are not the approved buyer");
        require(car.saleAmt == msg.value, "Incorrect sale amount");
        require(!isSold, "Car is already sold");

        isSold = true;
        owner = approvedBuyer;
        approvedBuyer = address(0);

        // Transfer the sale amount to the previous owner
        payable(owner).transfer(msg.value);

        return saleConfirmation;
    }

    // Function to withdraw funds
    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}

contract ExchangeCar {
    // Create Struct named Car with the following members:
    // string make; uint year; uint doors; uint milage; uint256 value
    struct Car {
        string make;
        uint year;
        uint doors;
        uint mileage;
        uint256 value;
    }

    // Car details for each owner
    Car public owner1Car;
    Car public owner2Car;

    // Addresses of the owners
    address public owner1;
    address public owner2;

    // Approval status
    bool public owner1Approved;
    bool public owner2Approved;

    // Event to log car exchange
    event CarExchanged(address owner1, Car owner1Car, address owner2, Car owner2Car);

    constructor(
        string memory _make1,
        uint _year1,
        uint _doors1,
        uint _mileage1,
        uint256 _value1,
        string memory _make2,
        uint _year2,
        uint _doors2,
        uint _mileage2,
        uint256 _value2
    ) {
        owner1 = msg.sender;
        owner1Car = Car(_make1, _year1, _doors1, _mileage1, _value1);
        owner2Car = Car(_make2, _year2, _doors2, _mileage2, _value2);
    }

    // Function for owner1 to approve the exchange
    function approveExchange() public {
        require(msg.sender == owner1, "Only owner1 can approve the exchange");
        owner1Approved = true;
    }

    // Function for owner2 to approve the exchange
    function approveExchangeByOwner2(address _owner2) public {
        require(owner2 == address(0) || msg.sender == owner2, "Only owner2 can approve the exchange");
        if (owner2 == address(0)) {
            owner2 = _owner2;
        }
        owner2Approved = true;
    }

    // Function to exchange the cars
    function exchangeCars() public {
        require(owner1Approved, "Owner1 has not approved the exchange");
        require(owner2Approved, "Owner2 has not approved the exchange");

        // Swap the cars between the owners
        Car memory tempCar = owner1Car;
        owner1Car = owner2Car;
        owner2Car = tempCar;

        // Reset approval status
        owner1Approved = false;
        owner2Approved = false;

        emit CarExchanged(owner1, owner1Car, owner2, owner2Car);
    }

    // Function to get details of the cars
    function getCarDetails() public view returns (Car memory, Car memory) {
        return (owner1Car, owner2Car);
    }
}