// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {PSNFT} from "./PSNFT.sol";
import {SqrTreasury} from "./SqrTreasury.sol";

/**
 * @title PieSlicer Smart Contract
 * @dev Manages the Pie Slicer ecosystem, facilitating NFT deployment, holder balances, and total tokens.
 */
contract PieSlicer is AccessControl {
    address[] holders;
    mapping(address => uint) public holderBalance;

    address[] nftContracts;
    uint public totalTokens;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address public distributionTreasury;

    modifier onlyPSNContract() {
        bool isFound = false;
        for (uint256 index = 0; index < nftContracts.length; index++) {
            if (nftContracts[index] == msg.sender) {
                isFound = true;
                _;
            }
        }
        require(isFound, "not a psn contract");
    }

    /**
     * @dev Constructor function, initializing admin role and deploying DistributionTreasury.
     */
    constructor() {
        _grantRole(ADMIN_ROLE, _msgSender());
        distributionTreasury = address(new SqrTreasury());
    }

    /**
     * @dev Event emitted when a new PSNFT contract is deployed.
     */
    event PSNFTDeployed(address nft);

    /**
     * @dev Deploys a new PSNFT contract with specified parameters.
     * @param tokenName Name of the token.
     * @param tokenSymbol Symbol of the token.
     * @param creator Address of the creator.
     * @param price Initial price of the NFT.
     */
    function deployPSNFT(
        string calldata tokenName,
        string calldata tokenSymbol,
        address creator,
        uint price
    ) external onlyRole(ADMIN_ROLE) {
        PSNFT newNFT = new PSNFT(
            tokenName,
            tokenSymbol,
            creator,
            price,
            distributionTreasury
        );

        nftContracts.push(address(newNFT));
        emit PSNFTDeployed(address(newNFT));
    }

    /**
     * @dev Retrieves the list of holders in the Pie Slicer network.
     */
    function getHolders() public view returns (address[] memory) {
        return holders;
    }

    /**
     * @dev Retrieves the list of deployed PSNFT contracts.
     */
    function getNFTContracts() public view returns (address[] memory) {
        return nftContracts;
    }

    /**
     * @dev Event emitted when a holder's balance changes.
     */
    event HolderBalanceChange(
        address holder,
        uint newBalance,
        uint oldBalance,
        uint difference
    );

    /**
     * @dev Increases a holder's balance and updates the holders list. Called by PSNFT on mint or transfer.
     * @param holder Address of the holder.
     * @param amount Amount to increase the balance.
     */
    function increaseHolderBalance(
        address holder,
        uint amount
    ) public onlyPSNContract {
        if (holderBalance[holder] == 0) holders.push(holder);
        holderBalance[holder] += amount;
        emit HolderBalanceChange(
            holder,
            holderBalance[holder],
            holderBalance[holder] - amount,
            amount
        );
    }

    /**
     * @dev Decreases a holder's balance.  Called by PSNFT on transfer.
     * @param holder Address of the holder.
     * @param amount Amount to decrease the balance.
     */
    function decreaseHolderBalance(
        address holder,
        uint amount
    ) public onlyPSNContract {
        holderBalance[holder] -= amount;
        emit HolderBalanceChange(
            holder,
            holderBalance[holder],
            holderBalance[holder] + amount,
            amount
        );
    }

    /**
     * @dev Event emitted when total tokens are increased.
     */
    event TotalTokensIncreased(uint amount);

    /**
     * @dev Increases the total tokens count. Called by PSN Contract
     * @param amount Amount to increase total tokens.
     */
    function increaseTotalTokens(uint amount) public onlyPSNContract {
        totalTokens += amount;
        emit TotalTokensIncreased(amount);
    }
}
