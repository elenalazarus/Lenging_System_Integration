trigger LoanIntegrationTrigger on Loan__c (after insert, after update, after delete) {
    if(!TriggerExecution__c.getInstance().IsActive__c){
        return;
    }

    if (Trigger.isInsert){
        LendingSystemIntegration.insertLoan(Trigger.newMap);
    }

    if (Trigger.isUpdate){
        LendingSystemIntegration.updateLoan(Trigger.newMap);
    }

    if (Trigger.isDelete){
        LendingSystemIntegration.deletLoan(Trigger.newMap);
    }
}