// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LemonadeStand {
    address owner;
    uint256 skuCount;

    enum State {
        ForSale,
        Sold
    }

    struct Item {
        string name;
        uint256 sku;
        uint256 price;
        State state;
        address seller;
        address buyer;
    }

    mapping(uint256 => Item) items;

    event ForSale(uint256 sku);
    event Sold(uint256 sku);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier verifyCaller(address _address) {
        require(msg.sender == _address);
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(msg.value == _price);
        _;
    }

    modifier forSale(uint256 _sku) {
        require(items[_sku].state == State.ForSale);
        _;
    }

    modifier sold(uint256 _sku) {
        require(items[_sku].state == State.Sold);
        _;
    }

    constructor() {
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string memory _name, uint256 _price) public onlyOwner {
        skuCount += 1;
        emit ForSale(skuCount);
        items[skuCount] = Item({
            name: _name,
            price: _price,
            sku: skuCount,
            state: State.ForSale,
            seller: msg.sender,
            buyer: address(0)
        });
    }

    function buyItem(uint256 sku)
        public
        payable
        forSale(sku)
        paidEnough(items[sku].price)
    {
        address buyer = msg.sender;
        uint256 price = items[sku].price;
        items[sku].buyer = buyer;
        payable(items[sku].seller).transfer(price);
        items[sku].state = State.Sold;
        emit Sold(sku);
    }

    function fetchItem(uint256 _sku) public view returns (Item memory) {
        return items[_sku];
    }
}
