--------------------------------------------
    // Constr-----------------------------------------

    constructor(address _proxyRegistryAddress)
        ERC1155Tradable(
            "OpenSea Creature Accessory",
            "OSCA",
            "https://creatures-api.opensea.io/api/accessory/{id}",
            _proxyRegistryAddress
        )
    {
        royaltyReceiver = msg.sender;
        royaltyFee = 500; // 5%
    }

    // ---------------------------------------------------------
    // Minting
    // ---------------------------------------------------------

    /**
     * @notice Mint a specific amount of a token ID
     */
    function mint(
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external onlyOwner whenNotPaused {
        _mint(to, tokenId, amount, data);
        totalSupply[tokenId] += amount;

        emit Minted(to, tokenId, amount);
    }

    /**
     * @notice Batch mint multiple token IDs
     */
    function mintBatch(
        address to,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) external onlyOwner whenNotPaused {
        _mintBatch(to, tokenIds, amounts, data);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            totalSupply[tokenIds[i]] += amounts[i];
            emit Minted(to, tokenIds[i], amounts[i]);
        }
    }

    // ---------------------------------------------------------
    // Burning
    // ---------------------------------------------------------

    /**
     * @notice Burn tokens you own
     */
    function burn(
        address from,
        uint256 tokenId,
        uint256 amount
    ) external {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "Not authorized"
        );

        _burn(from, tokenId, amount);
        totalSupply[tokenId] -= amount;

        emit Burned(from, tokenId, amount);
    }

    // ---------------------------------------------------------
    // Admin Controls
    // ---------------------------------------------------------

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        _setURI(newURI);
        emit BaseURIUpdated(newURI);
    }

    function setRoyalty(address receiver, uint96 fee) external onlyOwner {
        require(fee <= 1000, "Max 10%");
        royaltyReceiver = receiver;
        royaltyFee = fee;

        emit RoyaltyUpdated(receiver, fee);
    }

    // ---------------------------------------------------------
    // Royalties (EIP-2981)
    // ---------------------------------------------------------

    function royaltyInfo(
        uint256,
        uint256 salePrice
    ) external view override returns (address, uint256) {
        uint256 royaltyAmount = (salePrice * royaltyFee) / 10_000;
        return (royaltyReceiver, royaltyAmount);
    }

    // ---------------------------------------------------------
    // OpenSea Contract Metadata
    // ---------------------------------------------------------

    function contractURI() public pure returns (string memory) {
        return "https://creatures-api.opensea.io/contract/opensea-erc1155";
    }

    // ---------------------------------------------------------
    // Interface Support
    // ---------------------------------------------------------

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Tradable, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
