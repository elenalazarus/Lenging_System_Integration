@isTest
public class LoanIntegrationTriggerTest {
    @testSetup
    static void setup() {
        // Create necessary test data
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;

        List<Loan__c> loans = new List<Loan__c>();
        for (Account acc : accounts) {
            loans.add(new Loan__c(
                Amount__c = 1000,
                Account__c = acc.Id
            ));
        }
        insert loans;
    }

    @isTest
    static void testInsertTrigger() {
        // Mock HTTP callouts
        Test.setMock(HttpCalloutMock.class, new LendingSystemMock());

        List<Loan__c> newLoans = new List<Loan__c>();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        for (Integer i = 0; i < 5; i++) {
            newLoans.add(new Loan__c(
                Amount__c = 1000 * (i + 1),
                Account__c = testAccount.Id
            ));
        }

        Test.startTest();
        insert newLoans;
        Test.stopTest();

        // Verify that the LoanId__c field is updated correctly
        List<Loan__c> updatedLoans = [SELECT Id, LoanId__c FROM Loan__c WHERE Id IN :newLoans];
        for (Loan__c loan : updatedLoans) {
            System.assertNotEquals(null, loan.LoanId__c, 'LoanId__c should be updated');
        }
    }

    @isTest
    static void testUpdateTrigger() {
        // Mock HTTP callouts
        Test.setMock(HttpCalloutMock.class, new LendingSystemMock());

        List<Loan__c> loans = [SELECT Id, Amount__c, Account_Number__c, LoanId__c FROM Loan__c LIMIT 5];
        for (Loan__c loan : loans) {
            loan.Amount__c += 1000;
        }

        Test.startTest();
        update loans;
        Test.stopTest();

        // Verify that the Stack_Trace__c field is null (no errors during processing)
        List<Loan__c> updatedLoans = [SELECT Id, Stack_Trace__c FROM Loan__c WHERE Id IN :loans];
        for (Loan__c loan : updatedLoans) {
            System.assertEquals(null, loan.Stack_Trace__c, 'There should be no errors in Stack_Trace__c');
        }
    }

    @isTest
    static void testDeleteTrigger() {
        // Mock HTTP callouts
        Test.setMock(HttpCalloutMock.class, new LendingSystemMock());

        List<Loan__c> loans = [SELECT Id FROM Loan__c LIMIT 5];

        Test.startTest();
        delete loans;
        Test.stopTest();

        // Verify that the loans are deleted successfully (check the database for deletion)
        Integer remainingLoans = [SELECT COUNT() FROM Loan__c WHERE Id IN :loans];
        System.assertEquals(0, remainingLoans, 'Loans should be deleted');
    }
}
