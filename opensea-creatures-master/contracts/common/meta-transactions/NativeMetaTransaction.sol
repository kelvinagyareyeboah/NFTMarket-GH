

            r := calldataload(sig.offset)
            s := ca
            v := by(add(sig.off

        if (v < 27) v += 27;

        // Prevent malleability
        require(uint2: invalid s");

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
        
