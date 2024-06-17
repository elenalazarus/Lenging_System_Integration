public class LendingSystemMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        // Determine the request method and set the appropriate response
        String reqMethod = req.getMethod();
        if (reqMethod == 'POST') {
            // Mock response for POST request
            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
            String loanId = 'loan-' + requestBody.get('accountNumber');
            res.setBody('{"loanId": "' + loanId + '"}');
        }

        return res;
    }
}
