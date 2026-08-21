s

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

