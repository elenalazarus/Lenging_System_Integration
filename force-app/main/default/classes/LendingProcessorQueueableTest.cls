@isTest
public class LendingProcessorQueueableTest {
    @testSetup
    static void setup() {
        Account acc = new Account(Name = 'testAcc', AccountNumber = '123456');
        insert acc;
        // Create test data for Loan__c objects
        List<Loan__c> loans = new List<Loan__c>();
        for (Integer i = 0; i < 150; i++) { // Creating 150 loans to test re-enqueueing
            loans.add(new Loan__c(
                Amount__c = 1000 * (i + 1),
                Account__c = acc.id
            ));
        }
        insert loans;
    }

    @isTest
    static void testLendingProcessorQueueable() {
        // Mock HTTP callouts
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LendingSystemMock());

        // Query the loans
        List<Loan__c> loanList = [SELECT Id, Amount__c, Account_Number__c, LoanId__c FROM Loan__c];

        // Enqueue the LendingProcessorQueueable job
        System.enqueueJob(new LendingProcessorQueueable(loanList, 'POST'));

        // Finish the test context to execute the enqueued job
        Test.stopTest();

        // Verify that the LoanId__c field is updated correctly
        List<Loan__c> updatedLoans = [SELECT LoanId__c FROM Loan__c];
        for (Loan__c loan : updatedLoans) {
            Assert.areNotEqual(null, loan.LoanId__c, 'LoanId__c should be updated');
        }

        // Verify that the re-enqueued jobs have been processed
        Integer countProcessedLoans = [SELECT COUNT() FROM Loan__c WHERE LoanId__c != null];
        Assert.areEqual(150, countProcessedLoans, 'All 150 loans should be processed');
    }
}


