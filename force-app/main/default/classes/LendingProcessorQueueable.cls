public with sharing class LendingProcessorQueueable implements Queueable, Database.AllowsCallouts {
    private static final String LENDING_SYSTEM_ENDPOINT = 'callout:LendingSystem';
    
    public List<Loan__c> loans;
    public String calloutMethod;
    
    public LendingProcessorQueueable(List<Loan__c> loanList, String calloutMethod){
        this.loans = loanList;
        this.calloutMethod = calloutMethod;
    }

    public void execute(QueueableContext context) {
        List<Loan__c> loansToUpdate = new List<Loan__c>();
        while(loans.size() > 0 && loansToupdate.size() < 100) { // Max 100 callouts allowed here
            Loan__c nextLoan = loans.remove(0);
            loansToUpdate.add(processPayload(this.calloutMethod, generateBody(nextLoan), nextLoan.Id));
        }
        update loansToupdate;
        if(loans.size() > 0) {
            /** Important to consider: max number of enqueued jobs - 50 
              max number of processed records per queue due to callout limit - 100
              Total possible amount of records to process - 5000 records per transaction
            */
            System.enqueueJob(this);
        }
    }

    /** To avoid a query of parent account records for the sake of just 1 field I would create a formula Account_Number__c
        field on Loan object to get a value right away
    */
    private String generateBody(Loan__c loan) {
        String reqBody;
        if (this.calloutMethod == 'POST') {
            reqBody = '{operation: "I", accountNumber:"' + loan.Account_Number__c + '", amount: '  + loan.Amount__c + '}';
        } else if (this.calloutMethod == 'PUT') {
            reqBody = '{operation: "U", loanId: "' + loan.LoanId__c + '", accountNumber:"' + loan.Account_Number__c + '", amount: '  + loan.Amount__c + '}';
        } else if (this.calloutMethod == 'DELETE') {
            reqBody = '{operation: "D", loanId: "' + loan.LoanId__c + '"}';
        }
        return reqBody;
    }

    public static Loan__c processPayload(
        String reqMethod,
        String reqBody,
        String logID
    ) {
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod(reqMethod); 
        httpRequest.setEndpoint(LENDING_SYSTEM_ENDPOINT); 
        httpRequest.setBody(reqBody);        
        Loan__c logToUpdate = new Loan__c();
        logToUpdate.Id = logID;           
        try {                
            Http http = new Http();   
            HttpResponse response = http.send(httpRequest);       

            if (response.getStatusCode() == 200) {
                if (reqMethod == 'POST') {
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    logToUpdate.LoanId__c = (String) jsonResponse.get('loanId');
                }
            } else {
                logToUpdate.Stack_Trace__c = 'EXTERNAL SERVER ERROR: ' + response.getStatusCode()+ ': ' +response.getBody();
                System.debug('EXTERNAL SERVER ERROR: '+ response.getStatusCode()+ ' ' +response.getBody());
            }              
        } catch(System.Exception e) {
            logToUpdate.Stack_Trace__c = 'DATA SYNC ERROR: ' + String.valueOf(e);                    
            System.debug('DATA SYNC ERROR: ' + e);
        }
        return logToUpdate;
    }
}