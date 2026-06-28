// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* =========================================================
   IMPORTS
========================================================= */

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/* =========================================================
   CONTRACT
========================================================= */

contract AdvancedERC721Tradable is
    ERC721,
    ERC721Burnable,
    ERC2981,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using Strings for uint256;

    /* =========================================================
       ERRORS
    ========================================================= */

    error MaxSupplyReached();
    error InvalidMintAmount();
    error TokenDoesNotExist();
    error WithdrawFailed();

    /* =========================================================
       STATE VARIABLES
    ========================================================= */

    uint256 private _nextTokenId = 1;

    uint256 public immutable maxSupply;

    string private _baseTokenURI;
    string public contractMetadataURI;

    /* =========================================================
       EVENTS
    ========================================================= */

    event BaseURIUpdated(string newURI);
    event ContractURIUpdated(string newURI);
    event BatchMint(address indexed to, uint256 amount);
    event Withdraw(address indexed owner, uint256 amount);

    /* =========================================================
       CONSTRUCTOR
    ========================================================= */

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        string memory contractURI_,
        uint256 maxSupply_,
        address royaltyReceiver_,
        uint96 royaltyFeeNumerator_
    ) ERC721(name_, symbol_) Ownable(msg.sender) {
        _baseTokenURI = baseURI_;
        contractMetadataURI = contractURI_;
        maxSupply = maxSupply_;

        _setDefaultRoyalty(
            royaltyReceiver_,
            royaltyFeeNumerator_
        );
    }

    /* =========================================================
       MINTING
    ========================================================= */

    function mint(address to)
        external
        onlyOwner
        whenNotPaused
    {
        if (_nextTokenId > maxSupply) {
            revert MaxSupplyReached();
        }

        _safeMint(to, _nextTokenId);

        unchecked {
            _nextTokenId++;
        }
    }

    function batchMint(address to, uint256 amount)
        external
        onlyOwner
        whenNotPaused
    {
        if (amount == 0) revert InvalidMintAmount();

        if ((_nextTokenId + amount - 1) > maxSupply) {
            revert MaxSupplyReached();
        }

        for (uint256 i; i < amount; ) {
            _safeMint(to, _nextTokenId);

            unchecked {
                ++_nextTokenId;
                ++i;
            }
        }

        emit BatchMint(to, amount);
    }

    /* =========================================================
       VIEW FUNCTIONS
    ========================================================= */

    function totalSupply() public view returns (uint256) {
        return _nextTokenId - 1;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (!_ownerOf(tokenId)) {
            revert TokenDoesNotExist();
        }

        return string(
            abi.encodePacked(
                _baseTokenURI,
                tokenId.toString(),
                ".json"
            )
        );
    }

    function contractURI()
        external
        view
        returns (string memory)
    {
        return contractMetadataURI;
    }

    /* =========================================================
       ADMIN FUNCTIONS
    ========================================================= */

    function setBaseURI(string calldata newBaseURI)
        external
        onlyOwner
    {
        _baseTokenURI = newBaseURI;

        emit BaseURIUpdated(newBaseURI);
    }

    function setContractURI(string calldata newContractURI)
        external
        onlyOwner
    {
        contractMetadataURI = newContractURI;

        emit ContractURIUpdated(newContractURI);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /* =========================================================
       ROYALTIES
    ========================================================= */

    function setDefaultRoyalty(
        address receiver,
        uint96 feeNumerator
    ) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function removeRoyalty()
        external
        onlyOwner
    {
        _deleteDefaultRoyalty();
    }

    /* =========================================================
       WITHDRAW
    ========================================================= */

    function withdraw()
        external
        onlyOwner
        nonReentrant
    {
        uint256 balance = address(this).balance;

        (bool success, ) = payable(owner()).call{
            value: balance
        }("");

        if (!success) revert WithdrawFailed();

        emit Withdraw(owner(), balance);
    }

    /* =========================================================
       REQUIRED OVERRIDES
    ========================================================= */

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /* =========================================================
       RECEIVE / FALLBACK
    ========================================================= */

    receive() external payable {}

    fallback() external payable {}
}
