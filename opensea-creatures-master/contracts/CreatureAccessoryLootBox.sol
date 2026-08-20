upply[_id] = tokenSupply[_id].add(_quantity);
        // Call the parent contract mint logic
     * @dev Checks if the caller is the owner or their proxy contract.
     * Used to allow marketplaces like OpenSea to mint on behalf of the owner.
     * @param _address Caller address.
     * @return True if caller
    function _isOwnerOrProxy(addresinretur
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        return owner() == _adddress(proxyRegistry.proxies(owner())) == _
}
