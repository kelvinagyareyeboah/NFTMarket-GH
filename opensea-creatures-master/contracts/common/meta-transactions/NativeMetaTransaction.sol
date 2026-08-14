
    function _hashMetaTx(MetaTransaction memory
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                META_TX_TYPEHASH,
                metaTx.from,
                keccak256(metaTx.functionSignature),
                metaTx.deadline
            )
        );
    }

    // ============================================================
    // SIGNATURE RECOVERY
    // ============================================================

    function _recoverSigner(bytes32 digest, bytes calldata sig)
        internal
        pure
        returns (address)
    {
        require(sig.length == 65, "MetaTx: bad signature");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := calldataload(sig.offset)
            s := calldataload(add(sig.offset, 32))
            v := byte(0, calldataload(add(sig.offset, 64)))
        }

        if (v < 27) v += 27;

        // Prevent malleability
        require(uint256(s) <= HALF_ORDER, "MetaTx: invalid s");

        return ecrecover(digest, v, r, s);
    }

    // ============================================================
    // VIEW FUNCTIONS
    // ============================================================

    function getNonce(address user) external view returns (uint256) {
        return _nonces[user];
    }

    // ============================================================
    // MSG.SENDER OVERRIDE (CRITICAL)
    // ============================================================

    function _msgSender() internal view returns (address sender) {
        if (msg.sender == address(this)) {
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            sender = msg.sender;
        }
    }
}
        
