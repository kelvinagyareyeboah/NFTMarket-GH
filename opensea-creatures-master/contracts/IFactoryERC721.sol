
    function canMint(uint256 _optionId) external view returns (bool);

    // ------------------------------------------------------------------------
    // Metadata Reference
    // ------------------------------------------------------------------------

    /**
     * @notice Returns metadata describing the minting option.
     * @dev This metadata can follow the ERC721 metadata standard.
     *      It provides descriptive details about what each minting option does,
     *      often used by NFT marketplaces like OpenSea to display visual information.
     *
     * Example:
     * - Option 0 → "Mint a Common Creature"
     * - Option 1 → "Mint a Legendary Creature"
     *
     * @param _optionId The identifier for the minting option.
     * @return A string representing a JSON metadata URI.
     */
    function tokenURI(uint256 _optionId) external view returns (string memory);

    // ------------------------------------------------------------------------
    // Interface Identification
    // ------------------------------------------------------------------------

    /**
     * @notice Identifies this contract as a factory contract.
     * @dev Used to help other contracts or services recognize that this interface
     *      represents a minting factory rather than a standard ERC721 token.
     *      Ideally, this should follow the ERC165 `supportsInterface()` pattern.
     * @return Always returns true if implemented properly.
     */
    function supportsFactoryInterface() external view returns (bool);

    // ------------------------------------------------------------------------
    // Minting Execution
    // ------------------------------------------------------------------------

    /**
     * @notice Executes the minting operation based on a given option.
     * @dev The logic inside the implementing contract determines how many tokens
     *      are minted, what kind they are, and to whom they are sent.
     * 
     * Requirements:
     * - Can only be called by the contract owner or an authorized proxy.
     * - The `_optionId` must be valid (less than `numOptions()`).
     * - The `canMint()` function should return true for this `_optionId`.
     *
     * Example workflow:
     * ```
     *  1. User interacts with marketplace and selects "Mint Rare NFT".
     *  2. Marketplace calls `mint(1, userAddress)` on this factory.
     *  3. Factory creates and transfers the new NFT(s) to `userAddress`.
     * ```
     *
     * @param _optionId The numeric identifier for the chosen minting option.
     * @param _toAddress The recipient address that will own the minted NFT(s).
     */
    function mint(uint256 _optionId, address _toAddress) external;
}

