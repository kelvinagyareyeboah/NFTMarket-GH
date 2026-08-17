
    // ---------------------------------------------------------

    /// @notice Total supply per token ID
    mapping(uint256 => uint256) public totalSupply;

    /// @notice Optional max supply per token ID (0 = uncapped)
    mapping(uint256 => uint256) public maxSupply;

    /// @notice Royalty receiver
    address private royaltyReceiver;

    /// @notice Royalty fee in basis points (e.g. 500 = 5%)
    uint96 private royaltyFee;

    uint96 private constant MAX_ROYALTY_FEE_BPS = 1000; // 10%

    // ---------------------------------------------------------
    // Errors
    // ---------------------------------------------------------

    error ZeroAddress();
    error ArrayLengthMismatch();
    error EmptyArray();
    error InsufficientBalance(uint256 tokenId, uint256 have, uint256 want);
    error NotAuthorized();
    error RoyaltyFeeTooHigh(uint96 fee, uint96 max);
    error MaxSupplyExceeded(uint256 tokenId, uint256 attempted, uint256 cap);
    error InvalidMaxSupply(uint256 tokenId, uint256 cap, uint256 currentSupply);

    // ---------------------------------------------------------
    // Events
    // ---------------------------------------------------------

    event Minted(address indexed to, uint256 indexed tokenId, uint256 amount);
    event Burned(address indexed from, uint256 indexed tokenId, uint256 amount);
    event BaseURIUpdated(string newURI);
    event RoyaltyUpdated(address receiver, uint96 fee);
    event MaxSupplyUpdated(uint256 indexed tokenId, uint256 cap);

    // ---------------------------------------------------------
    // Constructor
    // ---------------------------------------------------------

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
    ) external onlyOwner whenNotPaused nonReentrant {
        if (to == address(0)) revert ZeroAddress();

        uint256 cap = maxSupply[tokenId];
        uint256 newSupply = totalSupply[tokenId] + amount;
        if (cap != 0 && newSupply > cap) {
            revert MaxSupplyExceeded(tokenId, newSupply, cap);
        }

        // Effects before interactions
        totalSupply[tokenId] = newSupply;

        // Interaction (may call back into an untrusted receiver contract)
        _mint(to, tokenId, amount, data);

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
    ) external onlyOwner whenNotPaused nonReentrant {
        if (to == address(0)) revert ZeroAddress();
        if (tokenIds.length == 0) revert EmptyArray();
        if (tokenIds.length != amounts.length) revert ArrayLengthMismatch();

        // Effects before interactions
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 cap = maxSupply[tokenIds[i]];
            uint256 newSupply = totalSupply[tokenIds[i]] + amounts[i];
            if (cap != 0 && newSupply > cap) {
                revert MaxSupplyExceeded(tokenIds[i], newSupply, cap);
            }
            totalSupply[tokenIds[i]] = newSupply;
        }

        // Interaction
        _mintBatch(to, tokenIds, amounts, data);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            emit Minted(to, tokenIds[i], amounts[i]);
        }
    }

    // ---------------------------------------------------------
    // Burning
    // ---------------------------------------------------------

    /**
     * @notice Burn tokens you own (or are approved to burn)
     */
    function burn(
        address from,
        uint256 tokenId,
        uint256 amount
    ) external whenNotPaused nonReentrant {
        if (from != msg.sender && !isApprovedForAll(from, msg.sender)) {
            revert NotAuthorized();
        }

        uint256 balance = balanceOf(from, tokenId);
        if (balance < amount) {
            revert InsufficientBalance(tokenId, balance, amount);
        }

        // Effects before interactions
        totalSupply[tokenId] -= amount;

        // Interaction
        _burn(from, tokenId, amount);

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

    function setBaseURI(string calldata newURI) external onlyOwner whenNotPaused {
        _setURI(newURI);
        emit BaseURIUpdated(newURI);
    }

    /**
     * @notice Set (or update) a hard cap on total supply for a token ID.
     * @dev Cap of 0 means uncapped. Cannot set a cap below current supply.
     */
    function setMaxSupply(uint256 tokenId, uint256 cap) external onlyOwner {
        uint256 current = totalSupply[tokenId];
        if (cap != 0 && cap < current) {
            revert InvalidMaxSupply(tokenId, cap, current);
        }
        maxSupply[tokenId] = cap;
        emit MaxSupplyUpdated(tokenId, cap);
    }

    function setRoyalty(address receiver, uint96 fee) external onlyOwner whenNotPaused {
        if (receiver == address(0)) revert ZeroAddress();
        if (fee > MAX_ROYALTY_FEE_BPS) {
            revert RoyaltyFeeTooHigh(fee, MAX_ROYALTY_FEE_BPS);
        }
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
