// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Staking {

    address public admin;
    uint256 public rewardRate; // reward per second per ETH

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        uint256 rewardDebt;
    }

    mapping(address => StakeInfo) public stakes;

    constructor(uint256 _rewardRate) {
        admin = msg.sender;
        rewardRate = _rewardRate;
    }

}
