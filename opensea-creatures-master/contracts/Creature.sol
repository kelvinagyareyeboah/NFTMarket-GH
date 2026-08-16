 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";

/**
 * @title Creature
 * @dev Tradable ERC-721 NFT contract for unique Creature NFTs.
 *
 * Inherits from ERC721Tradable to provide:
 * - ERC-721 functionality
 * - Marketplace compatibility
 * - Proxy registry support
 * - Owner-controlled minting
 * - Configurable token metadata
 */
contract Creature is ERC721Tradable {
    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /**
     * @dev Default metadata endpoint used when the contract is deployed.
     */
    string private constant DEFAULT_BASE_URI =
        "https://creatures-api.opensea.io/api/creature/";

    /**
     * @dev Default contract-level metadata endpoint.
     */
    string private constant DEFAULT_CONTRACT_URI =
        "https://creatures-api.opensea.io/contract-metadata.json";

    // =============================================================
    //                           STORAGE
    // =============================================================

    /**
     * @dev Base URI used to construct individual token metadata URLs.
     */
    string private _baseTokenURI;

    /**
     * @dev URI containing metadata about the entire NFT collection.
     */
    string private _contractMetadataURI;

    // =============================================================
    //                            EVENTS
    // =============================================================

    /**
     * @dev Emitted when the base token URI is changed.
     */
    event BaseURIUpdated(
        string oldBaseURI,
        string newBaseURI
    );

    /**
     * @dev Emitted when the contract metadata URI is changed.
     */
    event ContractURIUpdated(
        string oldContractURI,
        string newContractURI
    );

    /**
     * @dev Emitted when a new Creature NFT is minted.
     */
    event CreatureMinted(
        address indexed to
    );

    // =============================================================
    //                         CONSTRUCTOR
    // =============================================================

    /**
     * @notice Initializes the Creature NFT collection.
     *
     * @param proxyRegistryAddress Address of the marketplace proxy
     *        registry used by ERC721Tradable.
     */
    constructor(address proxyRegistryAddress)
        ERC721Tradable(
            "Creature",
            "OSC",
            proxyRegistryAddress
        )
    {
        _baseTokenURI = DEFAULT_BASE_URI;
        _contractMetadataURI = DEFAULT_CONTRACT_URI;
    }

    // =============================================================
    //                         METADATA
    // =============================================================

    /**
     * @notice Returns the base URI for token metadata.
     *
     * @return The collection's current base metadata URI.
     */
    function baseTokenURI()
        public
        view
        override
        returns (string memory)
    {
        return _baseTokenURI;
    }

    /**
     * @notice Returns the collection-level metadata URI.
     *
     * @dev This URI can be used by marketplaces such as OpenSea
     *      to retrieve collection metadata.
     *
     * @return The current contract metadata URI.
     */
    function contractURI()
        public
        view
        returns (string memory)
    {
        return _contractMetadataURI;
    }

    /**
     * @notice Updates the base URI used for token metadata.
     *
     * @dev Only the contract owner can change this value.
     *
     * @param newBaseURI New base metadata URI.
     */
    function setBaseTokenURI(
        string memory newBaseURI
    ) external onlyOwner {
        string memory oldBaseURI = _baseTokenURI;

        _baseTokenURI = newBaseURI;

        emit BaseURIUpdated(
            oldBaseURI,
            newBaseURI
        );
    }

    /**
     * @notice Updates the collection-level metadata URI.
     *
     * @dev Only the contract owner can change this value.
     *
     * @param newContractURI New collection metadata URI.
     */
    function setContractURI(
        string memory newContractURI
    ) external onlyOwner {
        string memory oldContractURI = _contractMetadataURI;

        _contractMetadataURI = newContractURI;

        emit ContractURIUpdated(
            oldContractURI,
            newContractURI
        );
    }

    // =============================================================
    //                            MINTING
    // =============================================================

    /**
     * @notice Mints a new Creature NFT to an address.
     *
     * @dev Restricted to the contract owner. The actual minting
     *      implementation is provided by ERC721Tradable.
     *
     * @param to Address that will receive the new NFT.
     */
    function mintTo(
        address to
    ) public onlyOwner {
        require(
            to != address(0),
            "Creature: invalid recipient"
        );

        mintToCaller(to);

        emit CreatureMinted(to);
    }

    // =============================================================
    //                         VIEW HELPERS
    // =============================================================

    /**
     * @notice Returns the current base token URI.
     *
     * @return Current base URI.
     */
    function getBaseTokenURI()
        external
        view
        returns (string memory)
    {
        return _baseTokenURI;
    }

    /**
     * @notice Returns the current contract metadata URI.
     *
     * @return Current contract metadata URI.
     */
    function getContractMetadataURI()
        external
        view
        returns (string memory)
    {
        return _contractMetadataURI;
    }
}
