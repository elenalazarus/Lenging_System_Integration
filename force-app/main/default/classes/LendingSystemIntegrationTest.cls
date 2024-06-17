@isTest
public class LendingSystemIntegrationTest {
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
    static void testInsertLoan() {
        // Mock HTTP callouts
        Test.setMock(HttpCalloutMock.class, new LendingSystemMock());

        // Query the loans
        List<Loan__c> loanList = [SELECT Id, Amount__c, Account_Number__c, LoanId__c FROM Loan__c LIMIT 100];

        Test.startTest();
        // Trigger insertLoan method
        LendingSystemIntegration.insertLoan(new Map<Id, Loan__c>(loanList));
        Test.stopTest();

        // Verify that the LoanId__c field is updated correctly
        List<Loan__c> updatedLoans = [SELECT Id, LoanId__c, Stack_Trace__c FROM Loan__c WHERE Id IN :loanList];
        for (Loan__c loan : updatedLoans) {
            Assert.areNotEqual(null, loan.LoanId__c, 'LoanId__c should be updated');
        }
    }

    @isTest
    static void testUpdateLoan() {
        // Mock HTTP callouts
        Test.setMock(HttpCalloutMock.class, new LendingSystemMock());

        // Query the loans
        List<Loan__c> loanList = [SELECT Id, Amount__c, Account_Number__c, LoanId__c FROM Loan__c LIMIT 100];

        Test.startTest();
        // Trigger updateLoan method
        LendingSystemIntegration.updateLoan(new Map<Id, Loan__c>(loanList));
        Test.stopTest();

        // Verify that the loans are processed without errors
        List<Loan__c> processedLoans = [SELECT Id, Stack_Trace__c FROM Loan__c WHERE Id IN :loanList];
        for (Loan__c loan : processedLoans) {
            Assert.areEqual(null, loan.Stack_Trace__c, 'There should be no errors in Stack_Trace__c');
        }
    }

    @isTest
    static void testDeleteLoan() {
        // Mock HTTP callouts
        Test.setMock(HttpCalloutMock.class, new LendingSystemMock());

        // Query the loans
        List<Loan__c> loanList = [SELECT Id, Amount__c, Account_Number__c, LoanId__c FROM Loan__c LIMIT 100];

        Test.startTest();
        // Trigger deleteLoan method
        LendingSystemIntegration.deleteLoan(new Map<Id, Loan__c>(loanList));
        Test.stopTest();

        // Verify that the loans are processed without errors
        List<Loan__c> processedLoans = [SELECT Id, Stack_Trace__c FROM Loan__c WHERE Id IN :loanList];
        for (Loan__c loan : processedLoans) {
            Assert.areEqual(null, loan.Stack_Trace__c, 'There should be no errors in Stack_Trace__c');
        }
    }
}
