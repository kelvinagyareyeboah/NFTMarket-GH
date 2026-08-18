 {
    uintRES_PER_BOX = 3;
    uint2
    constructor(address _proxyRegistryAddress, address _factoryAddress)
        ERC721Tradable("CreatureLootBox", "LOOTBOX", _proxyReg
        factoryAddress = _factoryAddress;
    }

    function u
  

        // Insert custom logic for configuring the item here.
        for (uint256 i = 0; i < NUM_CREATURES_PER_BOX; i++) {
            // Mint the ERC721 item(s).
            FactoryERC721 factory = FactoryERC721(factoryAddress);
            factory.mint(OPTION_ID, _msgSender());
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
