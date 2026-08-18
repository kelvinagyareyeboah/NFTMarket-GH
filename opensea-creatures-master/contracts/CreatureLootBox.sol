 {
    uintRES_PER_BOX
    constructor(address _proxyRegistryAddress, address _factoryAddress)
        ERC721Tradable("CreatureLootBox", "LOOT
        factoryAddress =        for (uint256 i = 0; i < NUM_CREATURES_PER_BOX; i++) {
            // M            factory.mint(OPTION_ID, _msgSender());
        }

        // Burn the presale item.
        _burn(_tokenId);
    }

    function baseTokenURI() override public pure returns (string memory) {
        return "https://creatures-api.opensea.io/api/box/";
    }

    function itemsPerLootbox() public view returns (uint256) {
        return NUM_CREATURES_PER_BOX;
    }
}
