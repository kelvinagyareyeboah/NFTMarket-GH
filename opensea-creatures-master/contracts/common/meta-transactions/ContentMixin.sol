
     * Handles meta-transactio
    function _msgSen
            // Ensure calld

            assembly {
                // L
                sender := shr(96, calldataload(sub(calldatasize(
        } else {
            sender = msg
    /**
     * @dev Returns full calldata
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
