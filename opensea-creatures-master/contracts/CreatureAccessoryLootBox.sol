Tradable (so lootboxes themselves are ERC1155 tokens that can
mness to
 *s owner-o
cont
    usin
     * @notice Initializes the loomne
     * @p
        
        uint256 _
        uint256 _seed
    )
        LootBoxRandomness.initState(state, _factoryAddress, _numOptions, _numClasses, _seed);
    }

    /**
     * @notice Defines which token IDs belong to a specific class.
     * @param _classId ID of the item class.
     * @param _tokenIds List of token IDs in that class.
     * Callable only by the contract owner.
     */
    function setTokenIdsForClass(
        uint256 _classId,
        uint256[] memory _tokenIds
    ) public onlyOwner {
        LootBoxRandomness.setTokenIdsForClass(state, _classId, _tokenIds);
    }

    /**
     * @notice Configures lootbox opening behavior for a given option.
     * @param _option ID of the lootbox option (e.g., bronze, silver, gold).
     * @param _maxQuantityPerOpen Maximum number of NFTs to mint per opening.
     * @param _classProbabilities Array defining probabilities to select each item class.
     * @param _guarantees Array defining guaranteed item classes per open.
     * Callable only by the contract owner.
     */
    function setOptionSettings(
        uint256 _option,
        uint256 _maxQuantityPerOpen,
        uint16[] memory _classProbabilities,
        uint16[] memory _guarantees
    ) public onlyOwner {
        LootBoxRandomness.setOptionSettings(state, _option, _maxQuantityPerOpen, _classProbabilities, _guarantees);
    }

    ////////////////////////////////////
    // MAIN USER INTERACTION FUNCTIONS
    ////////////////////////////////////

    /**
     * @notice Opens a lootbox, burns it, and mints contained NFTs to the recipient.
     * @param _optionId ID of the lootbox option to open.
     * @param _toAddress Address that will receive the opened NFTs.
     * @param _amount Number of lootboxes to open.
     * Anyone holding lootboxes can call this.
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
