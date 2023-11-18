// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PSNFT} from "./PSNFT.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {DistributionTreasury} from "./DistributionTreasury.sol";
import {QuadraticTreasuryDistribution} from "./QDistributionTreasury.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

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

    constructor() {
        _grantRole(ADMIN_ROLE, _msgSender());

        distributionTreasury = address(
            new QuadraticTreasuryDistribution()
        );
    }

    event PSNFTDeployed(address nft);

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

    function getHolders() public view returns (address[] memory) {
        return holders;
    }

    function getNFTContracts() public view returns (address[] memory) {
        return nftContracts;
    }

    event HolderBalanceChange(
        address holder,
        uint newBalance,
        uint oldBalance,
        uint difference
    );

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

    event TotalTokensIncreased(uint amount);

    function increaseTotalTokens(uint amount) public onlyPSNContract {
        totalTokens += amount;
        emit TotalTokensIncreased(amount);
    }
}
