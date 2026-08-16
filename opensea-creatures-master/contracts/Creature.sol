aURI;
        _contractMetadataURI = newContractURI;
        emit ContractURIUpdated(oldContractURI, n
     * @notice Mints a new Creature NFT to a given address.
     * @param to Address to receive the minted token.
     */
    functions to) public onlyOwner {
        mintToCaller(to);
    }
}

