
    /**
     * @d
     * Handles meta-transactio
    function _msgSender
        if (msg.sender ==
            // Ensure calldata is long enough (at least 20 bytes for address)
            req

            assembly {
                // Load last 20
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
