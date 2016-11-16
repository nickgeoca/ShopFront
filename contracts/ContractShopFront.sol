pragma solidity ^0.4.2;

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
    string name;  // TODO: Make this more efficinet. string32 didn't work
  }

  /// SPEC: Privileges
  /// user: Can buy 1 of the products
  /// owner: Make payments or withdraw from contract
  /// admin: Can add products
  /// @dev Waste of memory to store 2 bools when 99% of users are both false.
  /// @dev Privileges. By default, a user can buy 1 of the products.
  /// @param owner Make payments or withdraw from contract
  /// @param admin Can add products
  struct UserPrivileges {
    bool owner;
    bool admin;
  }

  mapping (uint => Product) _InventoryDB;
  mapping (address => UserPrivileges) _PersonDB;

  //// Constructor
  function ContractShopFront(address owner)
    isValidAddress(owner)
  {
    _PersonDB[owner] = UserPrivileges(true, true);
  }

  ///////////////
  // User API

  function getProductPrice (uint id) returns (uint)
  { return _InventoryDB[id].price; }
  
  function getProductStock (uint id) returns (uint)
  { return _InventoryDB[id].stock; }
  
  function buyProduct (uint productId, uint productPrice, uint productQuantity) 
    isValidAddress(msg.sender)
    isThereEnoughProductInStock(productId, productQuantity)
    arePricesTheSame(productId, productPrice)
    doesUserHaveEnoughFunds(productPrice, productQuantity)
    returns (bool)
  {
    refundUser(productPrice * productQuantity);
    _InventoryDB[productId].stock = _InventoryDB[productId].stock - productQuantity;
    // TODO: Debit to user stock
  }

  ///////////////
  // Admin/Owner API

  function makePersonOwner (address user, bool changeTo)
    isValidAddress(user)
    isCallerAnOwner()
    // TODO: Consider making where owners can't accidently lock themselves out
  {
    _PersonDB[user].owner = changeTo;
  }

  function makePersonAdmin (address user, bool changeTo)
    isValidAddress(user)
    isCallerAnOwner()
  {
    _PersonDB[user].admin = changeTo;
  }

  function addProduct (uint id, uint price, uint stock, string name)
    isValidAddress(msg.sender)
    isCallerAnAdmin()
  {
    _InventoryDB[id] = Product(id, price, stock, name);
  }

  function setProductStock (uint id, uint stock)
    isValidAddress(msg.sender)
    isCallerAnAdmin()
    isExistingProduct(id)
  {
    _InventoryDB[id].stock = stock;
  }


  ///////////////
  // Private
  function isOwner(address a) private returns (bool)
  { return _PersonDB[a].owner; }

  function isAdmin(address a) private returns (bool)
  { return _PersonDB[a].admin; }

  function refundUser(uint totalCost) private {
    if (!msg.sender.send(msg.value - totalCost)) throw;
  }

  ///////////////
  // Modifiers
  modifier isValidAddress (address addr) {
    if (addr == 0) throw;
    _;
  }

  modifier isCallerAnOwner () {
    if (!isOwner(msg.sender)) throw;
    _;
  }

  modifier isCallerAnAdmin () {
    if (!isAdmin(msg.sender)) throw;
    _;
  }

  modifier isExistingProduct (uint id) {
    if (bytes(_InventoryDB[id].name).length == 0)
      if (bytes(_InventoryDB[id].name)[0] == 0)
	throw;
    _;
  }

  modifier arePricesTheSame (uint id, uint price) {
    if (_InventoryDB[id].price != price) throw;
    _;
  }

  modifier doesUserHaveEnoughFunds(uint price, uint quantity) {
    if (msg.value < (price * quantity)) throw;
    _;
  }

  modifier isThereEnoughProductInStock(uint id, uint quantity) {
    if (quantity > _InventoryDB[id].stock) throw;
    _;
  }


}
