// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./PieSlicer.sol";

contract PSNFT is ERC721, Ownable {
    uint256 private _nextTokenId;

    PieSlicer pieSlicer;
    address public creator;
    uint price;
    address distributor;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        address _creator,
        uint _price,
        address _distributor
    ) ERC721(_tokenName, _tokenSymbol) Ownable(creator) {
        creator = _creator;
        price = _price;
        distributor = _distributor;
    }

    function mint(uint tokenId) public payable {
        require(msg.value >= price, "msg.value not enough");
        uint distributorShare = msg.value / 2;
        uint creatorShare = msg.value - distributorShare;

        pieSlicer.increaseHolderBalance(msg.sender, 1);
        pieSlicer.increaseTotalTokens(1);

        payable(distributor).transfer(distributorShare);
        payable(creator).transfer(creatorShare);
        _safeMint(msg.sender, tokenId);
    }

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

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
