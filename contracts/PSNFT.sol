// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./PieSlicer.sol";

/**
 * @title PSNFT Smart Contract
 * @dev ERC721 token with URI storage, representing NFTs in the Pie Slicer ecosystem.
 */
contract PSNFT is ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    PieSlicer pieSlicer;
    address public creator;
    uint public price;
    address public ditrbutionTreasury;
    string public baseUri;

    /**
     * @dev Constructor function to initialize PSNFT with specified parameters.
     * @param _tokenName Name of the token.
     * @param _tokenSymbol Symbol of the token.
     * @param _creator Address of the creator.
     * @param _price Initial price of the NFT.
     * @param _distributor Address of the distribution treasury.
     */
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        address _creator,
        uint _price,
        address _distributor
    ) ERC721(_tokenName, _tokenSymbol) Ownable(_creator) {
        creator = _creator;
        price = _price;
        ditrbutionTreasury = _distributor;
        pieSlicer = PieSlicer(msg.sender);
        baseUri = "ipfs://bafybeieslvbdtrq7rxwvrxfbmqu7thqlup2xdfhwt7ac7w4heqvk4vm52y";
    }

    /**
     * @dev Mint function to create a new NFT and distribute funds.
     * @param tokenId ID of the token.
     */
    function mint(uint tokenId) public payable {
        require(msg.value >= price, "msg.value not enough");
        uint distributorShare = msg.value / 2;
        uint creatorShare = msg.value - distributorShare;

        pieSlicer.increaseHolderBalance(msg.sender, 1);
        pieSlicer.increaseTotalTokens(1);

        payable(ditrbutionTreasury).transfer(distributorShare);
        payable(creator).transfer(creatorShare);
        _safeMint(msg.sender, tokenId);
    }

    /**
     * @dev Overrides the tokenURI function to include token-specific information.
     * @param tokenId ID of the token.
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return string.concat(_baseURI(), Strings.toString(tokenId), ".PNG");
    }

    /**
     * @dev Overrides the _safeTransfer function to update holder balances during transfers.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal override {
        super._safeTransfer(from, to, tokenId, data);
        pieSlicer.increaseHolderBalance(to, 1);
        pieSlicer.decreaseHolderBalance(from, 1);
    }

    /**
     * @dev Overrides the _update function to support external calls.
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        return super._update(to, tokenId, auth);
    }

    /**
     * @dev Overrides the _increaseBalance function for internal functionality.
     */
    function _increaseBalance(
        address account,
        uint128 value
    ) internal override {
        super._increaseBalance(account, value);
    }

    /**
     * @dev Overrides the supportsInterface function.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
