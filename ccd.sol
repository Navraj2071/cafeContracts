// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./bean.sol";

contract CafeCounter {

    // Bean Contract
    Bean bean;

    //store data
    address public owner;
    uint256 public productCount;
    mapping (uint256 => string) public productIdToName;
    mapping (uint256 => string) public productIdToDescription;
    mapping (uint256 => uint256) public productIdToPrice; // price in INR * 100
    mapping (uint256 => uint256) public productIdToBeans; // beans in %age.

    //order data
    uint256 public orderCount;
    mapping(uint256 => uint256) public orderIdToUserId;
    mapping(uint256 => uint256) public orderIdToProductId;

    // coupon data
    uint256 public couponCount;
    mapping (uint256 => uint256) public couponIdToBeans;
    mapping (uint256 => uint256) public couponIdToUserId;
    mapping (uint256 => uint256) public couponIdToExpiryDate; //expiryDate in epoch.

    // user data
    uint256 public userCount;
    mapping (uint256 => string) public userIdToName;
    mapping (uint256 => uint256) public userIdToPhone;
    mapping (uint256 => uint256) public phoneToUserId;
    mapping (uint256 => string) public userIdToLocation;
    mapping (uint256 => uint256) public userIdToBeans;

    // events
    event ownerSet (address _newOwner);
    event productAdded(uint256 _productId, string _name, string _description, uint256 _price);
    event productUpdated(uint256 _productId, string _name, string _description, uint256 _price);
    event userCreated (uint256 _phone, uint256 _userId);
    event userDataUpdated (uint256 _userId, string _name, string _location);
    event orderPlaced (uint256 _orderId, uint256 _productId, uint256 _userId);
    event couponCreated (uint256 _couponId, uint256 _userId, uint256 _beans, uint256 _expiryDate);
    event userBeanCount (uint256 _userId, uint256 _beans);

    constructor (address _beanContract) {
        owner = msg.sender;
        productCount = 0;
        userCount = 0;
        orderCount = 0;
        couponCount = 0;
        bean = Bean(_beanContract);
    }

    modifier isOwner () {
        require (msg.sender == owner, "Only owner can call this function.");
        _;
    }

    //store functions
    function setOwner(address _newOwner) public isOwner{
        owner = _newOwner;
        emit ownerSet(owner);
    }

    function addProduct(string memory _name, string memory _description, uint256 _price) public isOwner {
        require (_price > 0, "Price cannot be empty.");
        productCount = productCount + 1;
        productIdToName[productCount] = _name;
        productIdToDescription[productCount] = _description;
        productIdToPrice[productCount] = _price;
        emit productAdded(productCount, _name, _description, _price);
    }

    function updateProduct(uint256 productId, string memory _name, string memory _description, uint256 _price) public isOwner {
         require (_price > 0, "Price cannot be empty.");        
        productIdToName[productId] = _name;
        productIdToDescription[productId] = _description;
        productIdToPrice[productId] = _price;
        emit productUpdated(productId, _name, _description, _price);
    }

    function allocateBeans(uint256 _userId,uint256 _beans, uint256 _expiryDate) public isOwner {
        require (userIdToPhone[_userId] > 0, "User does not exist.");
        couponCount = couponCount + 1;
        couponIdToBeans[couponCount] = _beans;
        couponIdToUserId[couponCount] = _userId;
        couponIdToExpiryDate[couponCount] = _expiryDate;
        emit couponCreated(couponCount, _userId, _beans, _expiryDate);
    }

    function getUserBeans(uint256 _userId) public isOwner  {
        uint256 _beans = 0;
        for (uint256 couponId = 1; couponId <= couponCount; couponId++) {
            if (couponIdToUserId[couponId] == _userId) {
                if (couponIdToExpiryDate[couponId] > block.timestamp) {couponIdToBeans[couponId] = 0;}
                else {_beans = _beans + couponIdToBeans[couponId];}
            }
        }
        emit userBeanCount (_userId, _beans);        
    }

    function burnBeans (uint256 _beans) internal {
        bean.burn(_beans);
    }

    //user functions
    function signUp(uint256 _phone) public isOwner {
        require(phoneToUserId[_phone] == 0, "Phone number already in use.");
        userCount = userCount + 1;
        userIdToPhone[userCount] = _phone;
        phoneToUserId[_phone] = userCount;
        emit userCreated(_phone, userCount);
    }

    function userDetails (uint256 _userId, string memory _name, string memory _location) public isOwner {
        require(userIdToPhone[_userId] > 0, "User does not exist.");
        userIdToName[_userId] = _name;
        userIdToLocation[_userId] = _location;
        emit userDataUpdated(_userId, _name, _location);
    }

    function placeOrder (uint256 _productId, uint256 _userId) public isOwner {
        require (productIdToPrice[_productId] > 0, "Product does not exist.");
        require (userIdToPhone[_userId] > 0, "User does not exist.");
        orderCount = orderCount + 1;
        orderIdToUserId[orderCount] = _userId;
        orderIdToProductId[orderCount] = _productId;
        emit orderPlaced(orderCount, _productId, _userId);
    }
}