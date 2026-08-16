he base URI for all tokens.
     */
    function baseTokenURI() public view override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @notice Returns the contract metadata URI used by OpenSea.
     */
    function contractURI() public view returns (string memory) {
        return _contractMetadataURI;
    }

    /**
     * @notice Allows the contract owner to update the base token URI.
     * @param newBaseURI New base URI string.
     */
    function setBaseTokenURI(string memory newBaseURI) external onlyOwner {
        string memory oldBaseURI = _baseTokenURI;
        _baseTokenURI = newBaseURI;
        emit BaseURIUpdated(oldBaseURI, newBaseURI);
    }

    /**
     * @notice Allows the contract owner to update the contract metadata URI.
     * @param newContractURI New contract metadata URI string.
     */
    function setContractURI(string memory newContractURI) external onlyOwner {
        string memory oldContractURI = _contractMetadataURI;
        _contractMetadataURI = newContractURI;
        emit ContractURIUpdated(oldContractURI, newContractURI);
    }

    /**
     * @notice Mints a new Creature NFT to a given address.
     * @param to Address to receive the minted token.
     */
    function mintTo(address to) public onlyOwner {
        mintToCaller(to);
    }
}

