pragma solidity ^0.4.2;

import "ConvertLib.sol";

/*
Eventually
 * ability to remove products.
 * co-purchase by different people.
 * add merchants akin to what Amazon has become.
 * add the ability to pay with a third-party token.
*/

contract ContractShopFront {
  struct Product {
    uint id;
    uint price;
    uint stock;
  }

  // as a regular user you can buy 1 of the products.
  struct UserPrivilege {
    bool owner;   // Make payments or withdraw from contract
    bool admin;   // Add products
  }

  mapping (address => Product) _Inventory;
  mapping (address => UserPrivileges) _PersonDB;

  //// Constructor
  function ContractShopFront(address owner)
    validateAddress(owner)
  {
    _PersonDB[owner] = UserPrivilege(true, true);
  }

  //// Public

  //  TODO: Consider making where owners can't accidently lock themselves out
  public userMakeOwner (address user, bool changeTo)
    validateAddress(user)
  {
    UserPrivilege userPriv = _PersonDB[user];
    userPriv.owner = changeTo;
    _PersonDB[user] = userPriv;
  }

  public userMakeAdmin (address user, bool changeTo)
    validateAddress(user)
  {
    UserPrivilege userPriv = _PersonDB[user];
    userPriv.admin = changeTo;
    _PersonDB[user] = userPriv;
  }

  // add privelidge features. user buy.

  function sendCoin(address receiver, uint amount) returns(bool sufficient) {
    if (balances[msg.sender] < amount) return false;
    balances[msg.sender] -= amount;
    balances[receiver] += amount;
    Transfer(msg.sender, receiver, amount);
    return true;
  }
  
  function getBalanceInEth(address addr) returns(uint){
    return ConvertLib.convert(getBalance(addr),2);
  }
  
  function getBalance(address addr) returns(uint) {
    return balances[addr];
  }

  modifier validateAddress (address addr) {
    if (addr == 0) throw;
    _;
  }

	
}
