ss.
     * @param _id Token ID.
     * @param _quantity Number of tok  
        uint256 _quantity,
        bytes
    ) override in        tokenSupply[_id] = tokenSupply[_id].add(_quantity);
        // Call the parent contract mint logic
        super._mint(_to, _id, _quant

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
