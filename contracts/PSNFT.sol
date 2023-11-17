// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./PieSlicer.sol";

contract PSNFT is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    EIP712Upgradeable
{
    uint256 private _nextTokenId;

    PieSlicer pieSlicer;
    address public creator;
    uint price;
    address distributor;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        PieSlicer _pieSlicer
    ) public initializer {
        __ERC721_init("PSNFT", "PS");
        __ERC721Enumerable_init();
        __EIP712_init("PSNFT", "1");

        pieSlicer = _pieSlicer;
    }

    function mint(uint tokenId) public payable {
        require(msg.value >= price, "msg.value not enough");
        // isLocked[tokenId] = true;
        uint distributorShare = msg.value / 2;
        uint creatorShare = msg.value - distributorShare;

        pieSlicer.increaseHolderBalance(msg.sender, 1);

        payable(distributor).transfer(distributorShare);
        payable(creator).transfer(creatorShare);
        _safeMint(msg.sender, tokenId);
    }

    // The following functions are overrides required by Solidity.
    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
