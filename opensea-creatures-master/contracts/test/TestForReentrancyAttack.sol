
        bytes memory /*data*/
    ) public override returns (bytes4) {
        // Update cached balances for ids (best-effort)
        for (uint256 i = 0; i < _ids.length; i++) {
            // Use the token contract that invoked this callback
            // `msg.sender` is the token contract (ERC-1155)
            cachedBalance[_ids[i]] = IERC1155(msg.sender).balanceOf(address(this), _ids[i]);
        }
        // For batch receipts we *do not* attempt to re-mint in this implementation.
        return ERC1155_BATCH_RECEIVED_SIG;
    }

    /// @notice Withdraw ERC-1155 tokens from this contract to owner
    function withdrawERC1155(address tokenContract, uint256 tokenId, uint256 amount) external onlyOwner {
        IERC1155(tokenContract).safeTransferFrom(address(this), owner(), tokenId, amount, "");
        emit Withdrawal(owner(), tokenId, amount);
    }

    /// @notice Query helper: get cached balance for token id
    function getCachedBalance(uint256 tokenId) external view returns (uint256) {
        return cachedBalance[tokenId];
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceID) external pure override returns (bool) {
        return interfaceID == INTERFACE_ERC165 || interfaceID == INTERFACE_ERC1155_RECEIVER_FULL;
    }
}

