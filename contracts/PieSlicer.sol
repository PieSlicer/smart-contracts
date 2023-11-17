// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PSNFT} from "./PSNFT.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract PieSlicer is Initializable, AccessControlUpgradeable {
    address[] holders;
    mapping(address => uint) public holderBalance;

    address[] nftContracts;
    uint public totalTokens;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

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

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) public initializer {
        __AccessControl_init();

        _grantRole(ADMIN_ROLE, defaultAdmin);
    }

    function deployPSNFT(
        string calldata tokenName,
        string calldata tokenSymbol,
        address creator,
        uint price,
        address distributor
    ) external onlyRole(ADMIN_ROLE) {
        PSNFT newNFT = new PSNFT(
            tokenName,
            tokenSymbol,
            creator,
            price,
            distributor
        );

        nftContracts.push(address(newNFT));
    }

    function getHolders() public view returns (address[] memory) {
        return holders;
    }

    function getNFTContracts() public view returns (address[] memory) {
        return nftContracts;
    }

    function increaseHolderBalance(
        address holder,
        uint amount
    ) public onlyPSNContract {
        holderBalance[holder] += amount;
    }

    function decreaseHolderBalance(
        address holder,
        uint amount
    ) public onlyPSNContract {
        holderBalance[holder] -= amount;
    }

    function increaseTotalTokens(uint amount) public onlyPSNContract {
        totalTokens += amount;
    }
}
