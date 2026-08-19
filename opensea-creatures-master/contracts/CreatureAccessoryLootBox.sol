rOpen, _classProbabilities, _gu
    ////////////////////////////////////
    // MAIN U
     * @notice Oded NFTs to the recipis Address that will rece
     * @param _amount Number of lo
     * Anyone ho
     */
    function unpack(
        uint256 _optionId,
        address _toAddress,
        uint256 _amount
    ) external {
        // Burns the lootbox tokens from sender (will revert if not enough balance)
        _burn(_msgSender(), _optionId, _amount);
        // Mints NFTs randomly chosen from lootbox contents to the recipient
        LootBoxRandomness._mint(state, _optionId, _toAddress, _amount, "", address(this));
    }

    /**
     * @notice Mints lootbox tokens to an address.
     * @param _to Recipient address.
     * @param _optionId Lootbox type ID (also used as token ID).
     * @param _amount Number of lootboxes to mint.
     * @param _data Optional data.
     * Only callable by the owner or their proxy (for integration with marketplaces).
     */
    function mint(
        address _to,
        uint256 _optionId,
        uint256 _amount,
        bytes memory _data
    ) override public nonReentrant {
        require(_isOwnerOrProxy(_msgSender()), "Lootbox: owner or proxy only");
        require(_optionId < state.numOptions, "Lootbox: Invalid Option");
        // Calls internal mint (which also updates supply tracking)
        _mint(_to, _optionId, _amount, _data);
    }

    /**
     * @dev Internal mint function overrides base mint.
     * Also tracks total number of tokens minted for each ID.
     * @param _to Recipient address.
     * @param _id Token ID.
     * @param _quantity Number of tokens.
     * @param _data Optional data.
     */
    function _mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) override internal {
        // Update total supply for this token ID
        tokenSupply[_id] = tokenSupply[_id].add(_quantity);
        // Call the parent contract mint logic
        super._mint(_to, _id, _quantity, _data);
    }

    /**
     * @dev Checks if the caller is the owner or their proxy contract.
     * Used to allow marketplaces like OpenSea to mint on behalf of the owner.
     * @param _address Caller address.
     * @return True if caller is owner or approved proxy.
     */
    function _isOwnerOrProxy(address _address) internal view returns (bool) {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        return owner() == _address || address(proxyRegistry.proxies(owner())) == _address;
    }
}
