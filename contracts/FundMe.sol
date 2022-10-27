//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./PriceConverter.sol";

error FundMe__NotOwner();

/** @title A contract for crowd funding.
 * @author Patrick Collins, written here by E. Joy
 * @notice This contract is to demo a sample funding contract.
 */

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUSD = 50 * 1e18;
    address private owner;
    address[] private funders;
    mapping(address => uint256) private addressToAmountFunded;
    AggregatorV3Interface private priceFeed;

    modifier ownerOnly() {
        if (msg.sender != owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeedAddress) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(priceFeed) >= minimumUSD,
            "You need to send more ETH!"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public ownerOnly {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getFunders(uint256 index) public view returns (address) {
        return funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return priceFeed;
    }
}
