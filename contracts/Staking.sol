// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Staking {

    address public admin;
    uint256 public rewardRate; // reward per second per ETH, scaled

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        uint256 rewardDebt; // optional for advanced reward tracking
    }

    mapping(address => StakeInfo) public stakes;

    constructor(uint256 _rewardRate) {
        admin = msg.sender;
        rewardRate = _rewardRate;
    }

    // Users call this to stake ETH
    function stake() external payable {
        require(msg.value > 0, "Must send ETH to stake");

        StakeInfo storage user = stakes[msg.sender];

        // If user already has staked amount, first calculate pending reward
        if (user.amount > 0) {
            uint256 pending = (user.amount * rewardRate * (block.timestamp - user.startTime)) / 1e18;
            user.rewardDebt += pending;
        }

        // Update stake amount
        user.amount += msg.value;
        user.startTime = block.timestamp;
    }
}