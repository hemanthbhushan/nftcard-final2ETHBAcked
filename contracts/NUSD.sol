// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
//0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
//0xD68C10D62A3b823cfa4193063fCd6d7e4E178057
contract NUSD {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public oracle;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address _oracleAddress) {
        name = "nUSD";
        symbol = "nUSD";
        decimals = 8;
        totalSupply = 0;
        oracle = _oracleAddress;
    }

    function deposit() external payable {
        // Get the latest ETH price from the Chainlink Oracle
        uint256 ethToUsdPrice;
        ethToUsdPrice = getEthToUsdPrice();

        // Calculate the amount of nUSD to mint
        uint256 nUSDAmount = (msg.value * (ethToUsdPrice)) / 2;

        // Mint nUSD to the depositor
        balanceOf[msg.sender] += nUSDAmount;
        totalSupply += nUSDAmount;

        emit Transfer(address(0), msg.sender, nUSDAmount);
    }

    function redeem(uint256 _nUSDAmount) external {
        require(balanceOf[msg.sender] >= _nUSDAmount, "Insufficient balance");
        uint256 ethToUsdPrice;
        ethToUsdPrice = getEthToUsdPrice();
        // Calculate the amount of ETH to send back based on the current ETH price
        uint256 ETHAmount = ((_nUSDAmount) / (ethToUsdPrice)) * 2;

        // Burn nUSD from the sender's balance
        balanceOf[msg.sender] -= _nUSDAmount;
        totalSupply -= _nUSDAmount;

        // Transfer the equivalent amount of ETH back to the sender
        payable(msg.sender).transfer(ETHAmount);

        emit Transfer(msg.sender, address(0), _nUSDAmount);
    }

    function getEthToUsdPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(oracle);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }
}
