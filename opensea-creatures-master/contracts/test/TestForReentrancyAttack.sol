
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

/// @notice Minimal interface for the accessory factory.
interface ICreatureAccessoryFactory {
    function mint(
        uint256 optionId,
        address to,
        uint256 amount,
        bytes calldata data
    ) external;
}

/// @title TestForReentrancyAttack
/// @notice ERC-1155 receiver used to test reentrancy behavior in a factory.
///
/// This contract:
/// - Starts a factory mint operation.
/// - Receives ERC-1155 tokens.
/// - Optionally attempts another factory mint from the ERC-1155 callback.
/// - Stops according to configurable balance and recursion limits.
/// - Allows the owner to withdraw received ERC-1155 tokens.
contract TestForReentrancyAttack is IERC1155Receiver, Ownable {
    // =============================================================
    //                         CONSTANTS
    // =============================================================

    bytes4 private constant ERC1155_RECEIVED_SIG = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED_SIG = 0xbc197c81;

    bytes4 private constant ERC1155_RECEIVER_INTERFACE_ID = 0x4e2312e0;
    bytes4 private constant ERC165_INTERFACE_ID = 0x01ffc9a7;

    // =============================================================
    //                         STATE
    // =============================================================

    /// @notice Factory used for the test.
    ICreatureAccessoryFactory public factory;

    /// @notice Target balance before callback-based mint attempts stop.
    uint256 public totalToMint = 3;

    /// @notice Cached ERC-1155 balances.
    mapping(uint256 => uint256) public cachedBalance;

    /// @notice Maximum nested callback depth.
    uint256 public maxRecursion = 10;

    /// @notice Current callback recursion depth.
    uint256 private recursionDepth;

    /// @notice Enables or disables callback-based behavior.
    bool public attackEnabled = true;

    // =============================================================
    //                           EVENTS
    // =============================================================

    event FactoryAddressSet(address indexed factory);
    event AttackEnabledSet(bool enabled);
    event TotalToMintSet(uint256 total);
    event MaxRecursionSet(uint256 maxDepth);
    event AttackStarted(uint256 indexed optionId);
    event Withdrawal(
        address indexed to,
        uint256 indexed tokenId,
        uint256 amount
    );

    // =============================================================
    //                        CONSTRUCTOR
    // =============================================================

    constructor(address _factory) {
        if (_factory != address(0)) {
            factory = ICreatureAccessoryFactory(_factory);
            emit FactoryAddressSet(_factory);
        }
    }

    // =============================================================
    //                       OWNER CONTROLS
    // =============================================================

    /// @notice Set the factory contract.
    function setFactoryAddress(address _factory) external onlyOwner {
        require(_factory != address(0), "zero address");

        factory = ICreatureAccessoryFactory(_factory);

        emit FactoryAddressSet(_factory);
    }

    /// @notice Set the target token balance.
    function setTotalToMint(uint256 _totalToMint) external onlyOwner {
        require(_totalToMint > 0, "totalToMint > 0");

        totalToMint = _totalToMint;

        emit TotalToMintSet(_totalToMint);
    }

    /// @notice Enable or disable callback behavior.
    function setAttackEnabled(bool _enabled) external onlyOwner {
        attackEnabled = _enabled;

        emit AttackEnabledSet(_enabled);
    }

    /// @notice Configure the maximum callback recursion depth.
    function setMaxRecursion(uint256 _max) external onlyOwner {
        require(_max > 0, "max > 0");

        maxRecursion = _max;

        emit MaxRecursionSet(_max);
    }

    // =============================================================
    //                         TEST START
    // =============================================================

    /// @notice Starts the initial factory mint.
    ///
    /// @param optionId Factory option to mint.
    /// @param amount Number of tokens requested.
    function startAttack(
        uint256 optionId,
        uint256 amount
    ) external onlyOwner {
        require(address(factory) != address(0), "factory not set");

        // Start each test with a fresh recursion counter.
        recursionDepth = 0;

        emit AttackStarted(optionId);

        factory.mint(
            optionId,
            address(this),
            amount,
            ""
        );
    }

    // =============================================================
    //                    ERC-1155 RECEIVER
    // =============================================================

    /// @notice Handles a single ERC-1155 token transfer.
    ///
    /// When enabled, the callback checks the received token balance
    /// and may request another factory mint until the configured
    /// target or recursion limit is reached.
    function onERC1155Received(
        address,
        address,
        uint256 tokenId,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {

        // Always accept the token when callback behavior is disabled.
        if (!attackEnabled) {
            return ERC1155_RECEIVED_SIG;
        }

        // The ERC-1155 token contract is the callback sender.
        IERC1155 tokenContract = IERC1155(msg.sender);

        uint256 balance = tokenContract.balanceOf(
            address(this),
            tokenId
        );

        cachedBalance[tokenId] = balance;

        // Stop when the maximum recursion depth is reached.
        if (recursionDepth >= maxRecursion) {
            return ERC1155_RECEIVED_SIG;
        }

        // Stop once the target balance has been reached.
        if (balance >= totalToMint) {
            return ERC1155_RECEIVED_SIG;
        }

        // Do not continue if the factory has not been configured.
        if (address(factory) == address(0)) {
            return ERC1155_RECEIVED_SIG;
        }

        recursionDepth++;

        // A failed nested mint should not prevent the ERC-1155
        // transfer callback from completing successfully.
        try factory.mint(
            1,
            address(this),
            1,
            ""
        ) {
            // Nested mint succeeded.
        } catch {
            // Nested mint failed; continue accepting the token.
        }

        recursionDepth--;

        return ERC1155_RECEIVED_SIG;
    }

    /// @notice Handles ERC-1155 batch transfers.
    ///
    /// Batch transfers only update the cached balances. They do not
    /// initiate additional factory calls.
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory tokenIds,
        uint256[] memory,
        bytes memory
    ) public override returns (bytes4) {

        IERC1155 tokenContract = IERC1155(msg.sender);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            cachedBalance[tokenIds[i]] = tokenContract.balanceOf(
                address(this),
                tokenIds[i]
            );
        }

        return ERC1155_BATCH_RECEIVED_SIG;
    }

    // =============================================================
    //                         WITHDRAWAL
    // =============================================================

    /// @notice Withdraw ERC-1155 tokens held by this contract.
    function withdrawERC1155(
        address tokenContract,
        uint256 tokenId,
        uint256 amount
    ) external onlyOwner {

        IERC1155(tokenContract).safeTransferFrom(
            address(this),
            owner(),
            tokenId,
            amount,
            ""
        );

        emit Withdrawal(
            owner(),
            tokenId,
            amount
        );
    }

    // =============================================================
    //                           HELPERS
    // =============================================================

    /// @notice Returns the cached balance for a token ID.
    function getCachedBalance(
        uint256 tokenId
    ) external view returns (uint256) {
        return cachedBalance[tokenId];
    }

    /// @notice Returns the current recursion depth.
    function getRecursionDepth()
        external
        view
        returns (uint256)
    {
        return recursionDepth;
    }

    /// @notice Returns the configured factory address.
    function getFactoryAddress()
        external
        view
        returns (address)
    {
        return address(factory);
    }

    // =============================================================
    //                      ERC-165 SUPPORT
    // =============================================================

    /// @inheritdoc IERC165
    function supportsInterface(
        bytes4 interfaceId
    ) external pure override returns (bool) {
        return
            interfaceId == ERC165_INTERFACE_ID ||
            interfaceId == ERC1155_RECEIVER_INTERFACE_ID;
    }
}


