/*
 * NextStepFuture Class Description:
 * 
 * Question 1: Create a future method that updates all account and opportunities next step to 'Meeting in the future'
 * Question 2: Create a method that inserts a big deal opportunity and updates the user role name to 'CRO'
 * 
 * Benefits of using future methods:
 * 
 * 1. Asynchronous Processing: Allows long-running operations to be handled in the background, freeing up resources.
 * 2. Governor Limit Management: Asynchronous methods have a separate set of limits, providing more flexibility.
 * 3. User Experience Enhancement: Improves responsiveness in user interfaces by offloading processes to the background.
 * 4. Mixed DML Operations Handling: Helps overcome Mixed DML errors by allowing updates on setup and non-setup objects.
 * 5. Enhanced Integration Capabilities: Useful for making callouts to external systems without blocking the user interaction.
 * 
 * For more detailed information, refer to the official Salesforce documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_invoking_future_methods.htm
 * 
 * Note: The class below contains placeholders for implementing a future method to update accounts and opportunities.
 *       The accompanying test class 'AsynchronousTest' should also be updated to test this method.
 */
public with sharing class NextStepFuture {

    /* 
     * Question 1
     * Update/Uncomment the template code to create a method
     * Create a future method that updates all account and opportunities next step to 'Meeting in the future'
     * Account Next Step field is a custom field
     * Opportunity Next Step field is a standard field
     * Update the corresponding test class AsynchronousTest and test method nextStepFuture_testUpdateAllNextStep to cover test this method
     *
     * 
     * 
     */

    @future
    public static void updateAllAccsAndOppsNextStep (List<Id> listAccountIds) {
        // convert list to set to prevent accountId duplicates
        Set<Id> setAccountIds = new Set<Id>(listAccountIds);
        String NEXTSTEP = 'Meeting in the future';

        // Query for accounts and opportunities in separate lists.
        // Loop through each list and update nextStep field
        // Update lists if not empty
        List<Account> accUpdate = new List<Account>([SELECT Id, Next_Step__c FROM Account WHERE Id IN: setAccountIds]);
        List<Opportunity> oppUpdate = new List<Opportunity>([SELECT Id, NextStep FROM Opportunity WHERE AccountId IN :setAccountIds]);

        for (Account acc : accUpdate) {
            if (acc.Next_Step__c != NEXTSTEP) {
            acc.Next_Step__c = NEXTSTEP;
            }
        }

        for (Opportunity opp : oppUpdate) {
            if (opp.NextStep != NEXTSTEP) {
            opp.NextStep = NEXTSTEP;
            }
        }

        if (!accUpdate.isEmpty()) {
            update accUpdate;
        }
        if (!oppUpdate.isEmpty()) {
            update oppUpdate; 
        }
}

    /*
    * Question 2
    * Update/Uncomment the template code to create a method
    * Create a method that inserts a big deal opportunity and updates the user role name to 'CRO'
    * Update the corresponding test class AsynchronousTest and test method nextStepFuture_testCreateDealAndUpdateRole to cover test this method
    *
    *TR - Because we have two DMLS for a setup object and non-setup object, we can't call both helpers in one transaction, so we have to call them in their own separate transaction. A future method
    * - starts its own transaction. Both helper methods were turned to future methods so that the parent can call on them both separately, avoiding the mixed DML error.
    *
    * Mix DML Error happens when you try to perform DML operations on setup and non-setup objects in a single transaction.
    */
    public static void createDealAndUpdateRole() {

        // call Opportunity future Method
        insertBigDeal();

        // setup data and call UserRole future method
        UserRole role = [
            SELECT Id, Name 
            FROM UserRole 
            WHERE Id = :UserInfo.getUserRoleId() 
            OR Name = 'CRO' 
            LIMIT 1];    
        
        if (role != null) {
        updateUserRoleName(role.Id);
        }
    }

    // Future Helper method to insert big deal
    @future
    private static void insertBigDeal() {
        Opportunity opp = new Opportunity();
        opp.Amount = 1000000;
        opp.Name = 'Big Deal';
        opp.StageName = 'Closed Won'; 
        opp.CloseDate = Date.today();
        insert opp;
    }

    // Future Helper method to update role name
    @future
    private static void updateUserRoleName(Id roleId){
        UserRole role;
        if (roleId == null) {
            role = new UserRole(
                Name = 'CRO', 
                PortalType = 'None', 
                CaseAccessForAccountOwner = 'Edit');
        } else {
            role = new UserRole(
            Id = roleId,
            Name = 'CRO');
        }
        upsert role;
    }
}
