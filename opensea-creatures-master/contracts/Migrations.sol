

    /**
     * @dev Sets the last completed migration number
     * @param comigration number to record as
    function setCompleted(uint completed) 
     * @dev Allows upgrad contract
     *      and sets the last completed migration in the new contract
     * @param new_address The address of the new Mig
    function s new_address) public restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_m
    }
}

