upply[_id] = tokenSupply[_id].add(_quantity);
        // Call the parent contract mint logic
     * @dev Checks if the caller is the owner oxy co
     * Used to allow marketplaces like OpenSea to mint on behalf of the owner.
     *
    function _isOwnerOrProxy(ad
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        return owner() == _adddress(proxyRegistry.pr
