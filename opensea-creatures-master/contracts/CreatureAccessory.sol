alldata newURI) external onlyOwner {
        _setURI(newURI);
        emit BaseURIUpdated(newURI);
    }

    function setRoyalty(address receiver, uint96 fee) external onlyOwner {
        require(fee <= 1000, "Max 10%");
        royaltyReceiver = receiver;
        royaltyFee = fee;

        emit RoyaltyUpdated(receiver, fee);
    }

    // ---------------------------------------------------------
    // Royalties (EIP-2981)
    // ---------------------------------------------------------

    function royaltyInfo(
        uint256,
        uint256 salePrice
    ) external view override returns (address, uint256) {
        uint256 royaltyAmount = (salePrice * royaltyFee) / 10_000;
        return (royaltyReceiver, royaltyAmount);
    }

    // ---------------------------------------------------------
    // OpenSea Contract Metadata
    // ---------------------------------------------------------

    function contractURI() public pure returns (string memory) {
        return "https://creatures-api.opensea.io/contract/opensea-erc1155";
    }

    // ---------------------------------------------------------
    // Interface Support
    // ---------------------------------------------------------

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Tradable, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
