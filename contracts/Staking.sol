// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Staking {

    address public admin;
    uint256 public rewardRate; // reward per second per ETH, scaled by 1e18

    struct StakeInfo {
        uint256 amount;      // amount of ETH staked
        uint256 startTime;   // timestamp when staking started
        uint256 rewardDebt;  // accumulated rewards from previous stakes
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

        // If user already has staked ETH, accumulate pending rewards
        if (user.amount > 0) {
            uint256 pending = (user.amount * rewardRate * (block.timestamp - user.startTime)) / 1e18;
            user.rewardDebt += pending;
        }

        // Update staked amount and reset startTime
        user.amount += msg.value;
        user.startTime = block.timestamp;
    }

    // Users call this to withdraw staked ETH + rewards
    function withdraw() external {
        StakeInfo storage user = stakes[msg.sender];
        require(user.amount > 0, "No stake found");

        // Calculate pending rewards since last stake
        uint256 reward = (user.amount * rewardRate * (block.timestamp - user.startTime)) / 1e18;

        // Total ETH to return = staked ETH + rewardDebt + pendingReward
        uint256 total = user.amount + user.rewardDebt + reward;

        // Reset user stake info
        user.amount = 0;
        user.startTime = 0;
        user.rewardDebt = 0;

        // Transfer total ETH back to user
        payable(msg.sender).transfer(total);
    }

    // Helper function to check pending rewards without withdrawing
    function pendingReward(address userAddress) external view returns (uint256) {
        StakeInfo storage user = stakes[userAddress];
        if (user.amount == 0) return 0;

        uint256 reward = (user.amount * rewardRate * (block.timestamp - user.startTime)) / 1e18;
        return user.rewardDebt + reward;
    }
}