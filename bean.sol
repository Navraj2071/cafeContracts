//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";


contract Bean is ERC20Capped {  
    uint256 public maxSupply = 100000000000; 
    address public owner;  

    //events
    event beansCreated (uint256 _beans);
    event beansBurnt (uint256 _beans);


    constructor(uint256 initialsupply) ERC20("bean", "bne") ERC20Capped(maxSupply) {
        ERC20._mint(msg.sender, initialsupply);
        owner = msg.sender;        
    }  

    function mintBean(uint256 _beans) public {
        require(msg.sender == owner, "Only owner can mint new tokens.");
        _mint(msg.sender, _beans);
        emit beansCreated(_beans);
    }     

   function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
        emit beansBurnt(amount);
    }

}