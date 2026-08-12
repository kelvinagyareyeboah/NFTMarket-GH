

    /**
     * @dev Sets the last completed migration number
     * @param completed The migration number to record as
    function setCompleted(uint completed) public restricted {
        last_complet
    }

    /**
     * @dev Allows upgrading to a new Migrations contract
     *      and sets the last completed migration in the new contract
     * @param new_address The address of the new Migrations contract
     */
    function upgrade(address new_address) public restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}

