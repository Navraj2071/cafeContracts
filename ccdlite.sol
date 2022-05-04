// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./bean.sol";

contract CafeCounter {

    // Bean Contract
    Bean bean;
    uint256 public totalBeansBurnt = 0;

    //store data
    address public owner;

    //user data
    mapping(uint256 => uint256) public userIdTobeans;

    // coupon data
    uint256 public couponCount;
    mapping (uint256 => uint256) public couponIdToBeans;
    mapping (uint256 => uint256) public couponIdToUserId;
    mapping (uint256 => uint256) public couponIdToExpiryDate; //expiryDate in epoch.

    // events
    event ownerSet (address _newOwner);    
    event couponCreated (uint256 _couponId, uint256 _userId, uint256 _beans, uint256 _expiryDate);    
    event userBeanCount (uint256 _userId, uint256 _beans);
    event beansRewarded (uint256 _userId, uint256 _beans);
    event beansBurnt (uint256 _beans);

    constructor (address _beanContract) {
        owner = msg.sender;       
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
 
    //Allocate beans to a user.
    function allocateBeans(uint256 _userId,uint256 _beans, uint256 _expiryDate) public isOwner {        
        couponCount = couponCount + 1;
        couponIdToBeans[couponCount] = _beans;
        couponIdToUserId[couponCount] = _userId;
        couponIdToExpiryDate[couponCount] = _expiryDate;       
        emit couponCreated(couponCount, _userId, _beans, _expiryDate);
        emit beansRewarded(_userId, _beans);
    }

    // Burn beans token.
    function burnBeans (uint256 _amount) public isOwner {
        totalBeansBurnt = totalBeansBurnt + _amount;
        bean.burn(_amount);
        emit beansBurnt(_amount);
    }   

    //burn expired beans
    function expireBeans () public isOwner {
        for (uint256 couponId = 1; couponId <= couponCount; couponId ++) {
            if (couponIdToExpiryDate[couponId] < block.timestamp) {
                burnBeans(couponIdToBeans[couponId]);
                couponIdToBeans[couponId] = 0;
            }
        }
    }

    //update the beans data for userId
    function updatebeansData(uint256 _userId) public isOwner {
        uint256 _beans = 0;        
        for (uint256 couponId = 1; couponId <= couponCount; couponId ++) {
            if (couponIdToUserId[couponId] == _userId) {
                _beans = _beans + couponIdToBeans[couponId];
            }
        }
        userIdTobeans[_userId] = _beans;
    } 

    // redeem beans for a user
    function redeemBeans(uint256 _userId, uint256 _beans) public isOwner {
        require (userIdTobeans[_userId] > _beans, "User doesn't have these many beans.");
        uint256 usedBeans = 0;
        uint256 couponId = 1;
        while (usedBeans < _beans) {
            if (couponIdToUserId[couponId] == _userId){
                if (couponIdToBeans[couponId] > (_beans - usedBeans)) {
                    couponIdToBeans[couponId] = couponIdToBeans[couponId] - (_beans - usedBeans);
                    usedBeans = usedBeans + (_beans - usedBeans);
                }
                else {
                    usedBeans = usedBeans + couponIdToBeans[couponId];  
                    couponIdToBeans[couponId] = 0;
                }
            }
            couponId = couponId + 1;
        }
        burnBeans(usedBeans);        
    }   
}