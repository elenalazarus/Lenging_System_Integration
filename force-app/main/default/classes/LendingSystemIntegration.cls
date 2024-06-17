public with sharing class LendingSystemIntegration {
    private static final String LENDING_SYSTEM_ENDPOINT = 'callout:LendingSystem';

    public static void insertLoan(Map<Id, Loan__c> insertedLoans) {
        System.enqueueJob(new LendingProcessorQueueable(Trigger.new, 'POST'));
    }

    public static void updateLoan(Map<Id, Loan__c> updatedLoans) {
        System.enqueueJob(new LendingProcessorQueueable(Trigger.new, 'PUT'));
    }

    public static void deleteLoan(Map<Id, Loan__c> deletedLoans) {
        System.enqueueJob(new LendingProcessorQueueable(Trigger.new, 'DELETE'));
    }
}