# Lending System Integration

This is an implementation of a simple flow to synchronize updated data within Salesforce with external Loan System.

## Design details
Trigger events fire on after insert, update and delete of Loan records and enqueue asynchronous job that allows sending 1 callout per 1 record as per requirements.

Queueable was chosen for the convenience of the recursive approach to ensure as many records can be processed as possible, considering the external web server's limitations of accepting just 1 record per callout.

Error logging and exception handling were implemented, storing error messages in field values of records.

Additional fields were added on the Loan record to avoid extra queries of parent Account records (Account_Number__c formula field referencing Account.AccountNumber) and manage error handling (Stack_Trace__c)

Custom settings TriggerExecution__c allows deactivation of the trigger in case of a bulk load of old loan records to Salesforce

## Assumptions made

1. The system will not process more than 5000 records per transaction as max number of enqueued jobs - 50 and max number of processed records per queue due to callout limit - 100

## Key Files
* LoanIntegrationTrigger - trigger class that fires when records are created, updated or deleted
* LendingSystemIntegration - trigger handler that calls Queueable (considering it's not a class that calls the external server, better to rename it to LoanIntegrationTriggerHandler for clarity)
* LendingProcessorQueueable - asynchronous job for processing Loan records
