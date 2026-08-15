-Identifier: MIT
pragma 
abstract co
    /**
     * @d
     * Handles meta-transactions wherontra
     */
    function _msgSender() internal view virtual returns (ad
        if (msg.sender == address(this)) {
            // Ensure calldata is long enough (at least 20 bytes for address)
            require(msg.data.length >= 20, "ContextMixin: a");

            assembly {
                // Load last 20 bytes of calldata
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            sender = msg.sender;
        }
    }

    /**
     * @dev Returns full calldata
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
