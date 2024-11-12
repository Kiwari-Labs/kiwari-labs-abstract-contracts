// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

/// @title Campaign contract
/// @author Kiwari Labs

import "./interfaces/IERC20Mintable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Campaign is Ownable {
    uint256 public startBlock;
    uint256 public validFor;
    bool public isCampaignActive; // 1 bytes
    IERC20Mintable public rewardToken; // ERC20 token for minting rewards 20 bytes
    uint256 public rewardAmount; // Amount of tokens to mint as reward
    uint256 public rewardLimit; // Maximum number of rewards that can be claimed
    uint256 public totalRewardsClaimed; // Counter for total rewards claimed

    mapping(address => bool) public hasClaimed; // Track if user has claimed reward
    mapping(address => bool) private whitelistedAddresses;

    event RewardClaimed(address indexed user, uint256 rewardAmount);

    modifier onlyOwnerOrWhitelisted() {
        require(
            whitelistedAddresses[msg.sender] || owner() == msg.sender,
            "Permission deny"
        );
        _;
    }

    constructor(
        address owner_,
        uint256 startTime_,
        uint256 validFor_,
        address rewardTokenAddress_,
        uint256 rewardAmount_,
        uint256 rewardLimit_
    ) Ownable(owner_) {
        require(
            startTime_ > block.timestamp,
            "Start time must be in the future"
        );
        require(validFor_ > 0, "End time must be after start time");

        startBlock = startTime_;
        validFor = validFor_;
        rewardToken = IERC20Mintable(rewardTokenAddress_);
        rewardAmount = rewardAmount_;
        rewardLimit = rewardLimit_; // Set the reward limit
        isCampaignActive = false;
        totalRewardsClaimed = 0; // Initialize the reward counter
    }

    // Function to check if the campaign is ongoing
    function isCampaignOngoing() public view returns (bool) {
        return (block.number >= startBlock &&
            block.number <= startBlock + validFor &&
            isCampaignActive);
    }

    // Owner can manually stop the campaign if desired
    function stopCampaign() public onlyOwner {
        require(isCampaignActive, "Campaign is already inactive");
        isCampaignActive = false;
    }

    // Automatically deactivate the campaign when validFor is reached
    function checkAndDeactivateCampaign() internal {
        if (block.number > startBlock + validFor) {
            isCampaignActive = false;
        }
    }

    // User can claim reward, automatically activating the campaign if necessary
    // The campaign will also automatically deactivate when the end time is reached
    function claimReward(address to_) public {
        // Deactivate the campaign if the current time is past the end time
        checkAndDeactivateCampaign();
        require(block.number <= validFor, "Campaign has already ended");

        // Activate the campaign if it hasn't been activated yet and within the time period
        if (
            !isCampaignActive &&
            block.number >= startBlock &&
            block.number <= startBlock + validFor &&
            totalRewardsClaimed + rewardAmount < rewardLimit
        ) {
            isCampaignActive = true;
        }

        require(isCampaignActive, "Campaign is not active");
        require(!hasClaimed[to_], "Reward already claimed");

        // Mint reward tokens to the user
        rewardToken.mint(to_, rewardAmount);

        // Mark that the user has claimed their reward
        hasClaimed[to_] = true;
        totalRewardsClaimed = totalRewardsClaimed + rewardAmount;

        // Emit the event for reward claim
        emit RewardClaimed(msg.sender, rewardAmount);

        // Check again after minting to deactivate if the campaign has ended
        checkAndDeactivateCampaign();
    }

    function claimReward() public {
        claimReward(msg.sender);
    }

    // Owner can extend the campaign time
    function extendCampaign(uint56 validFor_) public onlyOwner {
        require(
            validFor_ > validFor,
            "New end time must be after current end time"
        );
        validFor = validFor_;
    }

    // Function to return campaign times
    function getCampaignTimes() public view returns (uint256, uint256) {
        return (startBlock, validFor);
    }

    // Function to update the reward limit
    function setRewardLimit(uint256 newLimit) public onlyOwnerOrWhitelisted {
        require(
            newLimit >= totalRewardsClaimed,
            "New reward limit must be >= total rewards claimed"
        );
        rewardLimit = newLimit;
    }

    // Function to add an address to the whitelist, restricted to onlyOwner
    function addAddressToWhitelist(address _address) external onlyOwner {
        whitelistedAddresses[_address] = true;
    }

    // Function to remove an address from the whitelist, restricted to onlyOwner
    function removeAddressFromWhitelist(address _address) external onlyOwner {
        whitelistedAddresses[_address] = false;
    }

    // Function to check if an address is whitelisted
    function isWhitelisted(address _address) external view returns (bool) {
        return whitelistedAddresses[_address];
    }
}
