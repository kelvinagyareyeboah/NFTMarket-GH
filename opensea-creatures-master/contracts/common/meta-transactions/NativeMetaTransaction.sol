// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EIP712Base} from "./EIP712Base.sol";

/**
 * @title NativeMetaTransaction
 * @dev Provides EIP-712 signed gasless meta-transactions.
 *
 * The user signs a structured MetaTransaction off-chain.
 * A relayer can then submit the transaction and pay the gas.
 *
 * The original user address is appended to the internal call data so
 * contracts inheriting this contract can recover the actual user through
 * _msgSender().
 */
contract NativeMetaTransaction is EIP712Base {
    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /**
     * @dev EIP-712 type hash for MetaTransaction.
     */
    bytes32 private constant META_TX_TYPEHASH =
        keccak256(
            "MetaTransaction(uint256 nonce,address from,bytes functionSignature,uint256 deadline)"
        );

    /**
     * @dev Maximum allowed value for the ECDSA `s` parameter.
     *
     * This prevents signature malleability by requiring `s` to be in
     * the lower half of the secp256k1 curve order.
     */
    uint256 private constant HALF_ORDER =
        0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // =============================================================
    //                            STORAGE
    // =============================================================

    /**
     * @dev Tracks the next valid nonce for each user.
     */
    mapping(address => uint256) private _nonces;

    // =============================================================
    //                             EVENTS
    // =============================================================

    /**
     * @dev Emitted after a valid meta-transaction is accepted.
     */
    event MetaTransactionExecuted(
        address indexed user,
        address indexed relayer,
        bytes functionSignature
    );

    // =============================================================
    //                            STRUCTS
    // =============================================================

    /**
     * @dev Represents a signed meta-transaction.
     */
    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
        uint256 deadline;
    }

    // =============================================================
    //                         META TRANSACTIONS
    // =============================================================

    /**
     * @notice Executes a signed meta-transaction.
     *
     * @param user The address that signed the transaction.
     * @param functionSignature Encoded function call to execute.
     * @param deadline Timestamp after which the signature expires.
     * @param signature User's EIP-712 signature.
     *
     * @return returndata Data returned by the executed function.
     */
    function executeMetaTransaction(
        address user,
        bytes calldata functionSignature,
        uint256 deadline,
        bytes calldata signature
    ) external payable returns (bytes memory returndata) {
        require(
            block.timestamp <= deadline,
            "MetaTx: expired"
        );

        require(
            user != address(0),
            "MetaTx: invalid user"
        );

        MetaTransaction memory metaTx = MetaTransaction({
            nonce: _nonces[user],
            from: user,
            functionSignature: functionSignature,
            deadline: deadline
        });

        // Construct the EIP-712 digest.
        bytes32 digest = toTypedMessageHash(
            _hashMetaTx(metaTx)
        );

        // Recover the signer from the supplied signature.
        address recovered = _recoverSigner(
            digest,
            signature
        );

        require(
            recovered == user,
            "MetaTx: invalid signature"
        );

        /*
         * Increment the nonce before making the external call.
         *
         * This prevents the same signed meta-transaction from being
         * replayed during a reentrant execution.
         */
        _nonces[user]++;

        emit MetaTransactionExecuted(
            user,
            msg.sender,
            functionSignature
        );

        /*
         * Append the original user's address to calldata.
         *
         * _msgSender() reads these final 20 bytes when the internal
         * call is executed through this contract.
         */
        (bool success, bytes memory result) = address(this).call(
            abi.encodePacked(
                functionSignature,
                user
            )
        );

        require(
            success,
            "MetaTx: call failed"
        );

        return result;
    }

    // =============================================================
    //                           HASHING
    // =============================================================

    /**
     * @notice Generates the struct hash used by EIP-712.
     *
     * @param metaTx Meta-transaction to hash.
     */
    function _hashMetaTx(
        MetaTransaction memory metaTx
    ) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                META_TX_TYPEHASH,
                metaTx.nonce,
                metaTx.from,
                keccak256(metaTx.functionSignature),
                metaTx.deadline
            )
        );
    }

    // =============================================================
    //                      SIGNATURE RECOVERY
    // =============================================================

    /**
     * @notice Recovers the signer from a 65-byte ECDSA signature.
     *
     * @param digest EIP-712 message digest.
     * @param sig Signature containing r, s and v.
     */
    function _recoverSigner(
        bytes32 digest,
        bytes calldata sig
    ) internal pure returns (address) {
        require(
            sig.length == 65,
            "MetaTx: bad signature"
        );

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := calldataload(sig.offset)
            s := calldataload(add(sig.offset, 32))
            v := byte(
                0,
                calldataload(add(sig.offset, 64))
            )
        }

        /*
         * Support signatures using either:
         *   v = 27 / 28
         * or
         *   v = 0 / 1
         */
        if (v < 27) {
            v += 27;
        }

        require(
            v == 27 || v == 28,
            "MetaTx: invalid v"
        );

        /*
         * Reject high-s signatures to prevent ECDSA
         * signature malleability.
         */
        require(
            uint256(s) <= HALF_ORDER,
            "MetaTx: invalid s"
        );

        return ecrecover(
            digest,
            v,
            r,
            s
        );
    }

    // =============================================================
    //                         VIEW FUNCTIONS
    // =============================================================

    /**
     * @notice Returns the current nonce for a user.
     *
     * @param user Address whose nonce should be queried.
     */
    function getNonce(
        address user
    ) external view returns (uint256) {
        return _nonces[user];
    }

    // =============================================================
    //                      MESSAGE SENDER
    // =============================================================

    /**
     * @notice Returns the actual user behind a meta-transaction.
     *
     * When a normal transaction calls the contract, msg.sender is
     * returned directly.
     *
     * When executeMetaTransaction() performs the internal call,
     * the original user's address is stored in the final 20 bytes
     * of calldata and is returned instead.
     *
     * @dev Child contracts should use _msgSender() instead of
     *      msg.sender for functions that support meta-transactions.
     */
    function _msgSender()
        internal
        view
        returns (address sender)
    {
        if (msg.sender == address(this)) {
            assembly {
                sender := shr(
                    96,
                    calldataload(
                        sub(calldatasize(), 20)
                    )
                )
            }
        } else {
            sender = msg.sender;
        }
    }
}
