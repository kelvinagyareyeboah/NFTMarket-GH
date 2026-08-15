
     * Handles meta-transactio
    function _msgSen
            // Ensure calldata is l

            assembly {
                // Load last 20
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            sender = msg
    /**
     * @dev Returns full calldata
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
