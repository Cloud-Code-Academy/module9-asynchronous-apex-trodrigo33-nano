/*
 * NextStepQueueable Class Description:
 * 
 * Implement the Queueable interface to process records asynchronously.
 * This example processes up to 10 accounts at a time.
 * It removes the Next Step from the accounts and related opportunities.
 *  
 * Benefits of using Queueable methods:
 * 
 * 1. Chaining Jobs: Allows for the chaining of jobs, meaning you can add another job to the queue from a running job.
 * 2. Stateful Execution: Supports stateful execution, which allows member variables to retain their values between job invocations.
 * 3. High Concurrency: Processes large sets of data without hitting governor limits.
 * 4. Flexibility: Useful for operations that need more flexibility in execution, especially when there's a possibility of chaining or performing related async operations.
 * 5. Enhanced Integration Capabilities: Useful for making asynchronous callouts to external systems, allowing for more extended processing times.
 * 
 * For more detailed information, refer to the official Salesforce documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm
 * 
 * Note: The class below contains placeholders for implementing a queueable job to update accounts and opportunities.
 */
public with sharing class NextStepQueueable implements Queueable{

    ////TR - Created maxdepth control 
    // TR - added check to see if maximumqueuestackdepth is maxed at 5 (sandbox)
    // Member variable to store the accounts
    // Constructor to accept the accounts
        // Store the accounts in a member variable

    private static final Integer MAX_JOBS = 5;
    private Map<Id,Account> accounts;
    public NextStepQueueable(Map<Id,Account> accounts) {
        this.accounts = accounts;
    }

    // Method to queue the job
        // Get 10 accounts with Next Step populated
        // If there are any accounts, queue the job using System.enqueueJob
        // TR - This method makes the decision to either chain a new job or stop the chain. 
        // TR - It is only called AFTER the execute() method is complete (i.e the current queued job has finished processing and either ends or starts a new job)

    public static void enqueueJob() {
        Map<Id,Account> accounts = new Map<Id, Account>([SELECT Id, Next_Step__c FROM Account WHERE Next_Step__c != NULL LIMIT 10]);
        if (!accounts.isEmpty()) {
            System.enqueueJob(new NextStepQueueable(accounts));
        }
    }

    /*
     * Update/Uncomment the template code to create a method
     * Method to execute the queueable job
     */

    // Get the accounts from the member variable
        // Remove the Next Step using the helper method
        // Update the accounts

    // Get the opportunities related to the accounts
        // Remove the Next Step using the helper method
        // Update the opportunities
    
    // Call the enqueueJob method to queue another job to process more records.

    public void execute (QueueableContext context) {

        Boolean reachedDepthMax = AsyncInfo.getMaximumQueueableStackDepth() == MAX_JOBS;
        if (reachedDepthMax) {
            return;
        }

        List<Account> accUpdate = [SELECT Id, Next_Step__c FROM Account WHERE Id IN :accounts.keySet()];
        for (Account acc : accUpdate) {
            removeNextStep(acc);
        }

        List<Opportunity> oppUpdate = new List<Opportunity>([SELECT Id, NextStep, AccountId FROM Opportunity WHERE AccountId IN :accounts.keySet() AND NextStep != NULL]);
        for (Opportunity opp : oppUpdate) {
            removeNextStep(opp);
        }
        update accUpdate;
        update oppUpdate;

        // TR - Current job has ended, calls on method enqueueJob() to determine if we want to continue a new job OR end the overall process.
        NextStepQueueable.enqueueJob();
    }

    // Helper method to remove the Next Step
    // Overloaded method to accept an opportunity

    // Helper method to remove the Next Step
    // Overloaded method to accept an account

    private static void removeNextStep(Opportunity opp) {
        opp.NextStep = null;

    }

    private static void removeNextStep(Account acc) {
        acc.Next_Step__c = null;
    }
}