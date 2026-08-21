 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title FactoryERC721
 * @dev Interface for an ERC-721 minting factory.
 *
 * This interface defines the standard functions required by a factory
 * capable of supporting multiple NFT minting options.
 *
 * Each option is identified by an `_optionId` and may represent a
 * different collection, rarity, supply configuration, bundle, or
 * minting rule.
 *
 * Implementing contracts are responsible for providing:
 * - Collection metadata
 * - Minting option information
 * - Mint availability checks
 * - Option metadata
 * - Mint execution
 * - Factory interface identification
 *
 * This interface contains no storage or implementation logic.
 */
interface FactoryERC721 {
    // =============================================================
    //                         METADATA
    // =============================================================

    /**
     * @notice Returns the name of the factory.
     *
     * @return The human-readable factory name.
     */
    function name()
        external
        view
        returns (string memory);

    /**
     * @notice Returns the factory symbol.
     *
     * @return The abbreviated factory symbol.
     */
    function symbol()
        external
        view
        returns (string memory);

    // =============================================================
    //                      MINTING OPTIONS
    // =============================================================

    /**
     * @notice Returns the total number of minting options.
     *
     * Each option is identified by an ID between:
     *
     *      0
     *      numOptions() - 1
     *
     * @return Number of available minting options.
     */
    function numOptions()
        external
        view
        returns (uint256);

    /**
     * @notice Checks whether a minting option is currently available.
     *
     * The implementing contract may use supply limits, sale state,
     * access restrictions, or other business rules to determine
     * whether the option can be minted.
     *
     * @param _optionId Identifier of the minting option.
     *
     * @return True when the option can currently be minted.
     */
    function canMint(
        uint256 _optionId
    )
        external
        view
        returns (bool);

    // =============================================================
    //                       OPTION METADATA
    // =============================================================

    /**
     * @notice Returns metadata for a specific minting option.
     *
     * The returned value should normally be a URI pointing to JSON
     * metadata describing the option.
     *
     * Example:
     *
     *      Option 0 -> Common Creature
     *      Option 1 -> Rare Creature
     *      Option 2 -> Legendary Creature
     *
     * @param _optionId Identifier of the minting option.
     *
     * @return URI containing metadata for the selected option.
     */
    function tokenURI(
        uint256 _optionId
    )
        external
        view
        returns (string memory);

    // =============================================================
    //                    INTERFACE IDENTIFICATION
    // =============================================================

    /**
     * @notice Indicates whether the contract implements the factory
     *         interface.
     *
     * @dev This provides a simple factory-specific interface check.
     *      Implementing contracts may additionally expose ERC-165
     *      through `supportsInterface(bytes4)`.
     *
     * @return True when the contract supports this factory interface.
     */
    function supportsFactoryInterface()
        external
        view
        returns (bool);

    // =============================================================
    //                          MINTING
    // =============================================================

    /**
     * @notice Executes a mint using the selected option.
     *
     * The implementing contract determines the exact minting behavior,
     * including:
     *
     * - Number of NFTs created
     * - NFT collection used
     * - Supply restrictions
     * - Access requirements
     * - Rarity or tier selection
     * - Transfer of the resulting NFT(s)
     *
     * Implementations should normally validate the option ID and
     * ensure that the selected option is available before minting.
     *
     * @param _optionId Identifier of the minting option.
     * @param _toAddress Address that receives the minted NFT(s).
     */
    function mint(
        uint256 _optionId,
        address _toAddress
    )
        external;

    // =============================================================
    //                       IMPLEMENTATION NOTES
    // =============================================================

    /*
     * Implementing contracts may enforce additional requirements such as:
     *
     * - onlyOwner
     * - authorized minters
     * - proxy authorization
     * - option-specific supply limits
     * - paused minting
     * - payment requirements
     * - whitelist restrictions
     *
     * These rules are intentionally not defined here because this file
     * only specifies the external factory interface.
     */
}
