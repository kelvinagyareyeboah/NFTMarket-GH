

    /**
     * @notice Allows the contract owner to update the contract metadata URI.
     * @param newContractURI New contract metada
    function setContractURI(string memory newContractURI) external onlyOwner {
        string memory oldContractURI = _contractMetadataURI;
        _contractMetadataURI = newContractURI;
        emit ContractURIUpdated(oldContractURI, n
     * @notice Mints a new Creature NFT to a given address.
     * @param to Address to receive the minted token.
     */
    function mintTo(address to) public onlyOwner {
        mintToCaller(to);
    }
}

