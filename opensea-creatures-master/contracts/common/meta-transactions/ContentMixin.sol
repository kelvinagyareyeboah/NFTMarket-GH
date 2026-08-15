// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ContextMixin
 * @dev Provides context-aware sender and calldata helpers for contracts
 *      that support native meta-transactions.
 *
 * In a normal transaction:
 *
 *      msg.sender
 *
 * is the actual caller.
 *
 * During a meta-transaction, NativeMetaTransaction performs an internal
 * call through address(this). In that situation:
 *
 *      msg.sender == address(this)
 *
 * The original user's address is appended to the end of calldata.
 * This contract extracts those final 20 bytes and exposes them through
 * _msgSender().
 *
 * Contracts inheriting this mixin should use _msgSender() instead of
 * msg.sender whenever the function needs to identify the actual user.
 */
abstract contract ContextMixin {
    // =============================================================
    //                         CONSTANTS
    // =============================================================

    /**
     * @dev Number of bytes occupied by an Ethereum address.
     */
    uint256 private constant ADDRESS_LENGTH = 20;

    // =============================================================
    //                         CONTEXT
    // =============================================================

    /**
     * @notice Returns the actual sender of the current call.
     *
     * For normal calls, this returns msg.sender.
     *
     * For meta-transactions, the internal call originates from this
     * contract itself. In that case, the original sender is encoded
     * in the final 20 bytes of calldata.
     *
     * @return sender The actual user that initiated the operation.
     */
    function _msgSender()
        internal
        view
        virtual
        returns (address sender)
    {
        /*
         * Normal transaction:
         *
         * The caller is external, so msg.sender already represents
         * the correct address.
         */
        if (msg.sender != address(this)) {
            return msg.sender;
        }

        /*
         * Meta-transaction:
         *
         * The original sender is appended to calldata by the
         * meta-transaction executor.
         */
        require(
            msg.data.length >= ADDRESS_LENGTH,
            "ContextMixin: invalid calldata"
        );

        assembly {
            /*
             * calldatasize() returns the total calldata length.
             *
             * Subtracting 20 gives the location of the final
             * 20-byte address.
             *
             * shr(96, ...) removes the leading 12 bytes from
             * the 32-byte word, leaving the 20-byte address.
             */
            sender := shr(
                96,
                calldataload(
                    sub(
                        calldatasize(),
                        ADDRESS_LENGTH
                    )
                )
            )
        }
    }

    /**
     * @notice Returns the complete calldata for the current call.
     *
     * @dev This preserves the standard context-helper pattern and
     *      allows inheriting contracts to access calldata through
     *      _msgData().
     *
     * @return The complete calldata supplied to the current call.
     */
    function _msgData()
        internal
        view
        virtual
        returns (bytes calldata)
    {
        return msg.data;
    }

    // =============================================================
    //                       META-TX HELPERS
    // =============================================================

    /**
     * @notice Determines whether the current call is an internal
     *         meta-transaction execution.
     *
     * @return True when the contract is calling itself.
     */
    function _isMetaTransaction()
        internal
        view
        returns (bool)
    {
        return msg.sender == address(this);
    }

    /**
     * @notice Returns the calldata length.
     *
     * @return The number of bytes in the current calldata.
     */
    function _msgDataLength()
        internal
        view
        returns (uint256)
    {
        return msg.data.length;
    }
}
