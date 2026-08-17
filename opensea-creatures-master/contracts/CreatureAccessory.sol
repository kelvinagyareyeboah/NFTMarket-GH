// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// =========================================================
// Imports
// =========================================================

import "./ERC1155Tradable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title CreatureAccessory
 * @author Kelvin
 *
 * @notice
 * ERC-1155 based digital accessory contract with:
 *
 * - Per-token supply tracking
 * - Optional maximum supply caps
 * - Single and batch minting
 * - Single and batch burning
 * - Owner-controlled administration
 * - Emergency pause functionality
 * - EIP-2981 royalty support
 * - Configurable royalty receiver and fee
 * - Configurable base URI
 * - Per-token metadata URI support
 * - Metadata freezing
 * - Reentrancy protection
 * - Explicit authorization checks
 * - Extensive validation and custom errors
 *
 * @dev
 * This contract extends ERC1155Tradable and adds additional
 * application-level functionality on top of the ERC-1155 standard.
 *
 * IMPORTANT:
 * This contract assumes ERC1155Tradable exposes the standard
 * ERC1155 functionality such as:
 *
 * - _mint()
 * - _mintBatch()
 * - _burn()
 * - _burnBatch()
 * - balanceOf()
 * - balanceOfBatch()
 * - isApprovedForAll()
 * - _setURI()
 * - supportsInterface()
 *
 * OpenZeppelin 4.x import paths are assumed.
 */
contract CreatureAccessory is
    ERC1155Tradable,
    Ownable,
    Pausable,
    ReentrancyGuard,
    IERC2981
{
    // =========================================================
    // Constants
    // =========================================================

    /**
     * @notice Maximum royalty that can be configured.
     * @dev 1000 basis points = 10%.
     */
    uint96 public constant MAX_ROYALTY_FEE_BPS = 1000;

    /**
     * @notice Basis point denominator.
     * @dev 10,000 basis points = 100%.
     */
    uint256 public constant BPS_DENOMINATOR = 10_000;

    // =========================================================
    // Storage
    // =========================================================

    /**
     * @notice Total number of units minted for each token ID,
     *         minus units subsequently burned.
     */
    mapping(uint256 => uint256) public totalSupply;

    /**
     * @notice Maximum supply allowed for each token ID.
     *
     * @dev
     * A value of zero means the token is uncapped.
     */
    mapping(uint256 => uint256) public maxSupply;

    /**
     * @notice Tracks whether a token ID has ever been minted.
     */
    mapping(uint256 => bool) public tokenExists;

    /**
     * @notice Tracks whether metadata for a token has been frozen.
     */
    mapping(uint256 => bool) public metadataFrozen;

    /**
     * @notice Custom URI for individual token IDs.
     *
     * @dev
     * If this value is empty, the contract's base URI is used.
     */
    mapping(uint256 => string) private tokenURIs;

    /**
     * @notice Address receiving secondary-sale royalties.
     */
    address private royaltyReceiver;

    /**
     * @notice Royalty fee expressed in basis points.
     *
     * @dev
     * Example:
     * 500 = 5%
     * 750 = 7.5%
     * 1000 = 10%
     */
    uint96 private royaltyFee;

    /**
     * @notice Whether the entire collection's metadata has been frozen.
     *
     * @dev
     * Once frozen, base URI and token-specific URIs cannot be changed.
     */
    bool public metadataPermanentlyFrozen;

    // =========================================================
    // Custom Errors
    // =========================================================

    /**
     * @notice Thrown when address(0) is supplied where a valid
     *         address is required.
     */
    error ZeroAddress();

    /**
     * @notice Thrown when an array expected to contain values is empty.
     */
    error EmptyArray();

    /**
     * @notice Thrown when two arrays have different lengths.
     */
    error ArrayLengthMismatch();

    /**
     * @notice Thrown when an account attempts an unauthorized operation.
     */
    error NotAuthorized();

    /**
     * @notice Thrown when an account attempts to burn more tokens
     *         than it owns.
     */
    error InsufficientBalance(
        uint256 tokenId,
        uint256 available,
        uint256 requested
    );

    /**
     * @notice Thrown when a mint would exceed a token's maximum supply.
     */
    error MaxSupplyExceeded(
        uint256 tokenId,
        uint256 attemptedSupply,
        uint256 maximumSupply
    );

    /**
     * @notice Thrown when attempting to configure a maximum supply
     *         below the current circulating supply.
     */
    error InvalidMaxSupply(
        uint256 tokenId,
        uint256 maximumSupply,
        uint256 currentSupply
    );

    /**
     * @notice Thrown when royalty exceeds the configured maximum.
     */
    error RoyaltyFeeTooHigh(
        uint96 fee,
        uint96 maximumFee
    );

    /**
     * @notice Thrown when attempting to modify frozen metadata.
     */
    error MetadataFrozen();

    /**
     * @notice Thrown when attempting to modify metadata for a token
     *         that has individually been frozen.
     */
    error TokenMetadataFrozen(uint256 tokenId);

    /**
     * @notice Thrown when an operation requires an existing token.
     */
    error TokenDoesNotExist(uint256 tokenId);

    /**
     * @notice Thrown when a token already exists and an operation
     *         requires a new token.
     */
    error TokenAlreadyExists(uint256 tokenId);

    // =========================================================
    // Events
    // =========================================================

    /**
     * @notice Emitted whenever tokens are minted.
     */
    event Minted(
        address indexed operator,
        address indexed to,
        uint256 indexed tokenId,
        uint256 amount
    );

    /**
     * @notice Emitted whenever multiple tokens are minted.
     */
    event BatchMinted(
        address indexed operator,
        address indexed to,
        uint256[] tokenIds,
        uint256[] amounts
    );

    /**
     * @notice Emitted whenever tokens are burned.
     */
    event Burned(
        address indexed operator,
        address indexed from,
        uint256 indexed tokenId,
        uint256 amount
    );

    /**
     * @notice Emitted whenever multiple tokens are burned.
     */
    event BatchBurned(
        address indexed operator,
        address indexed from,
        uint256[] tokenIds,
        uint256[] amounts
    );

    /**
     * @notice Emitted when the base URI changes.
     */
    event BaseURIUpdated(string newURI);

    /**
     * @notice Emitted when a token-specific URI changes.
     */
    event TokenURIUpdated(
        uint256 indexed tokenId,
        string newURI
    );

    /**
     * @notice Emitted when token metadata is frozen.
     */
    event TokenMetadataFrozen(uint256 indexed tokenId);

    /**
     * @notice Emitted when all collection metadata is permanently frozen.
     */
    event MetadataPermanentlyFrozen();

    /**
     * @notice Emitted when maximum supply is changed.
     */
    event MaxSupplyUpdated(
        uint256 indexed tokenId,
        uint256 maximumSupply
    );

    /**
     * @notice Emitted when royalties are changed.
     */
    event RoyaltyUpdated(
        address indexed receiver,
        uint96 fee
    );

    // =========================================================
    // Constructor
    // =========================================================

    /**
     * @notice Creates the CreatureAccessory collection.
     *
     * @param _proxyRegistryAddress Address of the marketplace proxy
     *        registry used by ERC1155Tradable.
     */
    constructor(address _proxyRegistryAddress)
        ERC1155Tradable(
            "OpenSea Creature Accessory",
            "OSCA",
            "https://creatures-api.opensea.io/api/accessory/{id}",
            _proxyRegistryAddress
        )
    {
        if (_proxyRegistryAddress == address(0)) {
            revert ZeroAddress();
        }

        royaltyReceiver = msg.sender;

        // Default royalty = 5%.
        royaltyFee = 500;
    }

    // =========================================================
    // Minting
    // =========================================================

    /**
     * @notice Mint tokens to an address.
     *
     * @dev
     * Only the contract owner can mint.
     *
     * Supply is updated before `_mint()` performs its external
     * ERC-1155 receiver callback.
     *
     * @param to Recipient of the tokens.
     * @param tokenId Token ID to mint.
     * @param amount Number of units to mint.
     * @param data Additional ERC-1155 callback data.
     */
    function mint(
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    )
        external
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        if (to == address(0)) {
            revert ZeroAddress();
        }

        _validateMint(tokenId, amount);

        // -----------------------------------------------------
        // Effects
        // -----------------------------------------------------

        totalSupply[tokenId] += amount;

        tokenExists[tokenId] = true;

        // -----------------------------------------------------
        // Interaction
        // -----------------------------------------------------

        _mint(to, tokenId, amount, data);

        emit Minted(
            msg.sender,
            to,
            tokenId,
            amount
        );
    }

    /**
     * @notice Batch mint multiple token IDs to one address.
     *
     * @param to Recipient.
     * @param tokenIds Token IDs.
     * @param amounts Amount corresponding to each token ID.
     * @param data ERC-1155 callback data.
     */
    function mintBatch(
        address to,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    )
        external
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        if (to == address(0)) {
            revert ZeroAddress();
        }

        if (tokenIds.length == 0) {
            revert EmptyArray();
        }

        if (tokenIds.length != amounts.length) {
            revert ArrayLengthMismatch();
        }

        // -----------------------------------------------------
        // Checks
        // -----------------------------------------------------

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _validateMint(
                tokenIds[i],
                amounts[i]
            );
        }

        // -----------------------------------------------------
        // Effects
        // -----------------------------------------------------

        for (uint256 i = 0; i < tokenIds.length; i++) {
            totalSupply[tokenIds[i]] += amounts[i];

            tokenExists[tokenIds[i]] = true;
        }

        // -----------------------------------------------------
        // Interaction
        // -----------------------------------------------------

        _mintBatch(
            to,
            tokenIds,
            amounts,
            data
        );

        emit BatchMinted(
            msg.sender,
            to,
            tokenIds,
            amounts
        );
    }

    /**
     * @notice Internal mint validation.
     */
    function _validateMint(
        uint256 tokenId,
        uint256 amount
    ) internal view {
        uint256 cap = maxSupply[tokenId];

        uint256 newSupply =
            totalSupply[tokenId] + amount;

        if (cap != 0 && newSupply > cap) {
            revert MaxSupplyExceeded(
                tokenId,
                newSupply,
                cap
            );
        }
    }

    // =========================================================
    // Burning
    // =========================================================

    /**
     * @notice Burns tokens from an account.
     *
     * @dev
     * The caller must either:
     *
     * 1. Be the token owner, or
     * 2. Have operator approval.
     *
     * @param from Address whose tokens are burned.
     * @param tokenId Token ID.
     * @param amount Number of tokens to burn.
     */
    function burn(
        address from,
        uint256 tokenId,
        uint256 amount
    )
        external
        whenNotPaused
        nonReentrant
    {
        if (from == address(0)) {
            revert ZeroAddress();
        }

        _checkBurnAuthorization(from);

        uint256 balance =
            balanceOf(from, tokenId);

        if (balance < amount) {
            revert InsufficientBalance(
                tokenId,
                balance,
                amount
            );
        }

        // -----------------------------------------------------
        // Effects
        // -----------------------------------------------------

        totalSupply[tokenId] -= amount;

        // -----------------------------------------------------
        // Interaction
        // -----------------------------------------------------

        _burn(
            from,
            tokenId,
            amount
        );

        emit Burned(
            msg.sender,
            from,
            tokenId,
            amount
        );
    }

    /**
     * @notice Batch burn tokens.
     *
     * @param from Address whose tokens are burned.
     * @param tokenIds Token IDs.
     * @param amounts Amounts to burn.
     */
    function burnBatch(
        address from,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    )
        external
        whenNotPaused
        nonReentrant
    {
        if (from == address(0)) {
            revert ZeroAddress();
        }

        if (tokenIds.length == 0) {
            revert EmptyArray();
        }

        if (tokenIds.length != amounts.length) {
            revert ArrayLengthMismatch();
        }

        _checkBurnAuthorization(from);

        // -----------------------------------------------------
        // Checks
        // -----------------------------------------------------

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 balance =
                balanceOf(
                    from,
                    tokenIds[i]
                );

            if (balance < amounts[i]) {
                revert InsufficientBalance(
                    tokenIds[i],
                    balance,
                    amounts[i]
                );
            }
        }

        // -----------------------------------------------------
        // Effects
        // -----------------------------------------------------

        for (uint256 i = 0; i < tokenIds.length; i++) {
            totalSupply[tokenIds[i]] -= amounts[i];
        }

        // -----------------------------------------------------
        // Interaction
        // -----------------------------------------------------

        _burnBatch(
            from,
            tokenIds,
            amounts
        );

        emit BatchBurned(
            msg.sender,
            from,
            tokenIds,
            amounts
        );
    }

    /**
     * @notice Allows the owner to burn tokens from any address.
     *
     * @dev
     * This is useful for administrative recovery, moderation,
     * or emergency collection management.
     *
     * Use with caution because this gives the owner significant
     * control over holders' assets.
     */
    function adminBurn(
        address from,
        uint256 tokenId,
        uint256 amount
    )
        external
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        if (from == address(0)) {
            revert ZeroAddress();
        }

        uint256 balance =
            balanceOf(from, tokenId);

        if (balance < amount) {
            revert InsufficientBalance(
                tokenId,
                balance,
                amount
            );
        }

        totalSupply[tokenId] -= amount;

        _burn(
            from,
            tokenId,
            amount
        );

        emit Burned(
            msg.sender,
            from,
            tokenId,
            amount
        );
    }

    /**
     * @notice Checks whether the caller is allowed to burn
     *         tokens belonging to `from`.
     */
    function _checkBurnAuthorization(
        address from
    ) internal view {
        if (
            from != msg.sender &&
            !isApprovedForAll(
                from,
                msg.sender
            )
        ) {
            revert NotAuthorized();
        }
    }

    // =========================================================
    // Supply Management
    // =========================================================

    /**
     * @notice Configure a maximum supply for a token.
     *
     * @dev
     * A maximum supply of zero means unlimited supply.
     *
     * The cap cannot be set below the currently circulating supply.
     *
     * @param tokenId Token ID.
     * @param cap Maximum supply.
     */
    function setMaxSupply(
        uint256 tokenId,
        uint256 cap
    )
        external
        onlyOwner
        whenNotPaused
    {
        uint256 current =
            totalSupply[tokenId];

        if (
            cap != 0 &&
            cap < current
        ) {
            revert InvalidMaxSupply(
                tokenId,
                cap,
                current
            );
        }

        maxSupply[tokenId] = cap;

        emit MaxSupplyUpdated(
            tokenId,
            cap
        );
    }

    /**
     * @notice Returns the remaining mintable supply.
     *
     * @dev
     * For uncapped tokens, the maximum uint256 value is returned.
     */
    function remainingSupply(
        uint256 tokenId
    )
        external
        view
        returns (uint256)
    {
        uint256 cap =
            maxSupply[tokenId];

        if (cap == 0) {
            return type(uint256).max;
        }

        return cap - totalSupply[tokenId];
    }

    /**
     * @notice Returns whether a token has been created.
     */
    function exists(
        uint256 tokenId
    )
        external
        view
        returns (bool)
    {
        return tokenExists[tokenId];
    }

    // =========================================================
    // Metadata Management
    // =========================================================

    /**
     * @notice Updates the collection base URI.
     *
     * @dev
     * Cannot be called after metadata has been permanently frozen.
     */
    function setBaseURI(
        string calldata newURI
    )
        external
        onlyOwner
        whenNotPaused
    {
        if (metadataPermanentlyFrozen) {
            revert MetadataFrozen();
        }

        _setURI(newURI);

        emit BaseURIUpdated(
            newURI
        );
    }

    /**
     * @notice Sets a custom metadata URI for a token.
     *
     * @dev
     * A token-specific URI overrides the base URI behavior
     * implemented by the inherited contract where applicable.
     */
    function setTokenURI(
        uint256 tokenId,
        string calldata newURI
    )
        external
        onlyOwner
        whenNotPaused
    {
        if (metadataPermanentlyFrozen) {
            revert MetadataFrozen();
        }

        if (metadataFrozen[tokenId]) {
            revert TokenMetadataFrozen(
                tokenId
            );
        }

        tokenURIs[tokenId] = newURI;

        emit TokenURIUpdated(
            tokenId,
            newURI
        );
    }

    /**
     * @notice Returns the custom URI assigned to a token.
     *
     * @return URI string.
     */
    function tokenURI(
        uint256 tokenId
    )
        external
        view
        returns (string memory)
    {
        return tokenURIs[tokenId];
    }

    /**
     * @notice Permanently freezes metadata for a specific token.
     */
    function freezeTokenMetadata(
        uint256 tokenId
    )
        external
        onlyOwner
        whenNotPaused
    {
        if (metadataFrozen[tokenId]) {
            revert TokenMetadataFrozen(
                tokenId
            );
        }

        metadataFrozen[tokenId] = true;

        emit TokenMetadataFrozen(
            tokenId
        );
    }

    /**
     * @notice Permanently freezes all collection metadata.
     *
     * @dev
     * Once executed, neither base URI nor token-specific URIs
     * can be changed.
     *
     * This action is irreversible.
     */
    function permanentlyFreezeMetadata()
        external
        onlyOwner
        whenNotPaused
    {
        if (metadataPermanentlyFrozen) {
            revert MetadataFrozen();
        }

        metadataPermanentlyFrozen = true;

        emit MetadataPermanentlyFrozen();
    }

    // =========================================================
    // Royalty Management
    // =========================================================

    /**
     * @notice Updates royalty configuration.
     *
     * @param receiver Address receiving royalties.
     * @param fee Royalty percentage in basis points.
     */
    function setRoyalty(
        address receiver,
        uint96 fee
    )
        external
        onlyOwner
        whenNotPaused
    {
        if (receiver == address(0)) {
            revert ZeroAddress();
        }

        if (
            fee > MAX_ROYALTY_FEE_BPS
        ) {
            revert RoyaltyFeeTooHigh(
                fee,
                MAX_ROYALTY_FEE_BPS
            );
        }

        royaltyReceiver = receiver;
        royaltyFee = fee;

        emit RoyaltyUpdated(
            receiver,
            fee
        );
    }

    /**
     * @notice Returns the configured royalty receiver.
     */
    function getRoyaltyReceiver()
        external
        view
        returns (address)
    {
        return royaltyReceiver;
    }

    /**
     * @notice Returns the configured royalty fee.
     *
     * @return Fee in basis points.
     */
    function getRoyaltyFee()
        external
        view
        returns (uint96)
    {
        return royaltyFee;
    }

    /**
     * @notice EIP-2981 royalty calculation.
     *
     * @param tokenId Token ID.
     * @param salePrice Sale price.
     *
     * @return receiver Royalty receiver.
     * @return royaltyAmount Royalty amount.
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    )
        external
        view
        override
        returns (
            address receiver,
            uint256 royaltyAmount
        )
    {
        // Silence unused-variable warning while making it explicit
        // that this implementation uses one royalty configuration
        // for the entire collection.
        tokenId;

        royaltyAmount =
            (salePrice * royaltyFee) /
            BPS_DENOMINATOR;

        return (
            royaltyReceiver,
            royaltyAmount
        );
    }

    // =========================================================
    // Pause / Emergency Controls
    // =========================================================

    /**
     * @notice Pauses minting, burning and selected administrative
     *         operations.
     *
     * @dev
     * Only the owner can pause the contract.
     */
    function pause()
        external
        onlyOwner
    {
        _pause();
    }

    /**
     * @notice Resumes normal contract operation.
     */
    function unpause()
        external
        onlyOwner
    {
        _unpause();
    }

    /**
     * @notice Returns whether the contract is currently paused.
     */
    function isPaused()
        external
        view
        returns (bool)
    {
        return paused();
    }

    // =========================================================
    // OpenSea Metadata
    // =========================================================

    /**
     * @notice Returns collection-level marketplace metadata.
     */
    function contractURI()
        public
        pure
        returns (string memory)
    {
        return
            "https://creatures-api.opensea.io/contract/opensea-erc1155";
    }

    // =========================================================
    // Interface Detection
    // =========================================================

    /**
     * @notice Checks whether the contract supports an interface.
     *
     * @param interfaceId Interface identifier.
     *
     * @return True when supported.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(
            ERC1155Tradable,
            IERC165
        )
        returns (bool)
    {
        if (
            interfaceId ==
            type(IERC2981).interfaceId
        ) {
            return true;
        }

        return
            super.supportsInterface(
                interfaceId
            );
    }
}
