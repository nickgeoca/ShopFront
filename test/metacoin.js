contract('ContractShopFront', function(accounts) {
  // User/Public API
  it("should get the correct product price", function() {
    var cSF = ContractShopFront.deployed();
    var testId = 20;
    var testPrice = 30;
    var testQuantity = 40;
      
    cSF.addProduct(testId, testPrice, testQuantity);

    return cSF.getProductPrice.call().then(function(price) {
      assert.equal(price.valueOf(), testPrice, "testPrice does not equal retreived price");
    });
  });
});
