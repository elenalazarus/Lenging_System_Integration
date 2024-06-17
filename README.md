# Lending System Integration

This is an implementation of a simple flow to synchronize updated data within Salesforce with external Loan System.

## Design details
Trigger events fire on after insert, update and delete of Loan records and enqueue asynchronous job that allows to send 1 callout per 1 record as per requirements.
Queueable was chosen for convenience of recursive approach to make sure as many records can be processed as possible considering external web server limitations of accepting just 1 record per callout.

## A few assumptions were made

1. The system will not process more than 5000 records per transaction as max number of enqueued jobs - 50 and max number of processed records per queue due to callout limit - 100


