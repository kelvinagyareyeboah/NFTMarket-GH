
    /**
     * @d
     * Handles meta-transactio
    function _msgSender
        if (
            // Ensure calldata is long yte
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
