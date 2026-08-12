```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Migrations
 * @dev
 * This contract is used by Truffle to keep track of deployment migrations.
 *
 * It records the last migration that has been completed and allows the
 * migration state to be transferred to a new Migrations contract when
 * upgrading the deployment system.
 */
contract Migrations {
    // =============================================================
    //                           STATE
    // =============================================================

    /// @notice Address that is allowed to manage migration state.
    address public owner;

    /// @notice Number of the last completed migration.
    uint256 public last_completed_migration;

    // =============================================================
    //                           EVENTS
    // =============================================================

    /// @notice Emitted when the owner is initialized.
    event OwnershipInitialized(address indexed owner);

    /// @notice Emitted when a migration is marked as completed.
    event MigrationCompleted(uint256 indexed migrationNumber);

    /// @notice Emitted when migration state is transferred.
    event MigrationUpgraded(
        address indexed newContract,
        uint256 indexed migrationNumber
    );

    // =============================================================
    //                         CONSTRUCTOR
    // =============================================================

    /**
     * @dev Sets the deployer as the owner.
     */
    constructor() {
        owner = msg.sender;

        emit OwnershipInitialized(msg.sender);
    }

    // =============================================================
    //                           MODIFIERS
    // =============================================================

    /**
     * @dev Restricts a function to the contract owner.
     */
    modifier restricted() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // =============================================================
    //                       MIGRATION CONTROL
    // =============================================================

    /**
     * @notice Records a migration as completed.
     *
     * @param completed The migration number to record.
     */
    function setCompleted(uint256 completed) public restricted {
        last_completed_migration = completed;

        emit MigrationCompleted(completed);
    }

    /**
     * @notice Transfers the current migration state to another
     *         Migrations contract.
     *
     * @param new_address Address of the new Migrations contract.
     */
    function upgrade(address new_address) public restricted {
        require(new_address != address(0), "Invalid address");
        require(new_address != address(this), "Same contract");

        Migrations upgraded = Migrations(new_address);

        upgraded.setCompleted(last_completed_migration);

        emit MigrationUpgraded(
            new_address,
            last_completed_migration
        );
    }

    // =============================================================
    //                           HELPERS
    // =============================================================

    /**
     * @notice Returns the current owner.
     */
    function getOwner() external view returns (address) {
        return owner;
    }

    /**
     * @notice Returns the last completed migration.
     */
    function getLastCompletedMigration()
        external
        view
        returns (uint256)
    {
        return last_completed_migration;
    }
}
```

