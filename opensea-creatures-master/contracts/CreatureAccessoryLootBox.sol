
     * @dev Internal mint function overrides base mint.
     * @param _to Recipient address.
     * @param _id Token ID.
     * @param _quantity Number of tokens.
     * @pa

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
