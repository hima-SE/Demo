@isTest
private class CreateTransactionServiceTest {
     @testSetup Static void createTestData(){
        Id accRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        account cust =  new account (RecordTypeId = accRecType,
                                     Salutation = 'Ms.',
                                     FirstName = 'Test Cust',
                                     LastName  = 'Does Not Exist'
                                    );
        insert cust;
        
        Id fsAccRecType = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();
 		FinServ__FinancialAccount__c fsAcc = new FinServ__FinancialAccount__c ( FinServ__PrimaryOwner__c = cust.Id ,
                                                                               	RecordTypeId = fsAccRecType,
                                                                                Name = 'Test Savings Account',
                                                                                FinServ__Status__c = 'Active',
                                                                                FinServ__FinancialAccountType__c = 'Savings',
                                                                                FinServ__FinancialAccountNumber__c = '12345',
                                                                                FinServ__Balance__c = 200.00
                                                                              	); 
        insert fsAcc;

    }
    static testmethod void positiveDebit(){
        FinServ__FinancialAccount__c fsAcc = [Select FinServ__FinancialAccountNumber__c from FinServ__FinancialAccount__c ] ;
        fsAcc.FinServ__FinancialAccountNumber__c = '12345';
        Update fsAcc;
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '12345';
        tranReq.Amount = 10.00;
        tranReq.SourceSystemId = 'Test';
        tranReq.TransactionDate = system.now();
        tranReq.TransactionId = 'Ref123';
        tranReq.TransactionType = 'Debit';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('SUCCESS',resp.status, 'Error Status for Postive Debit Test Case');
        	system.assertEquals(0,resp.responseCode , 'Error responseCode for Postive Debit Test Case');
        	system.assertEquals(' ',resp.errorReason , 'Error errorReason for Postive Debit Test Case');
        	List<FinServ__FinancialAccountTransaction__c> checkTran = new list<FinServ__FinancialAccountTransaction__c>();
            checkTran = [select Id from FinServ__FinancialAccountTransaction__c where FinServ__TransactionId__c = : tranReq.TransactionId ];
        	system.assertEquals(1, checkTran.Size(), 'Error expecting 1 transaction to be created with this ref Id');
            
    }
    static testmethod void negativeDebit(){
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '12345';
        tranReq.Amount = 1000.00;
        tranReq.SourceSystemId = 'Test';
        tranReq.TransactionDate = system.now();
        tranReq.TransactionId = 'Ref123';
        tranReq.TransactionType = 'Debit';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('ERROR' ,resp.status , 'Error Status for Negative Debit Test Case');
        	system.assertEquals(1,resp.responseCode ,'Error responseCode for Negative Debit Test Case');
        	system.assertEquals('Insufficient Funds',resp.errorReason, 'Error errorReason for Negative Debit Test Case');
            
    }
    static testmethod void positiveCredit(){
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '12345';
        tranReq.Amount = 10.00;
        tranReq.SourceSystemId = 'Test';
        tranReq.TransactionDate = system.now();
        tranReq.TransactionId = 'Ref123';
        tranReq.TransactionType = 'Credit';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('SUCCESS', resp.status, 'Error Status for Postive Credit Test Case');
        	system.assertEquals(0,resp.responseCode , 'Error responseCode for Postive Credit Test Case');
        	system.assertEquals(' ',resp.errorReason, 'Error errorReason for Postive Credit Test Case');
    }
    static testmethod void duplicateTrans(){
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '12345';
        tranReq.Amount = 10.00;
        tranReq.SourceSystemId = 'Test';
        tranReq.TransactionDate = system.now();
        tranReq.TransactionId = 'Ref123';
        tranReq.TransactionType = 'Debit';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
        	//try posting a 2nd time.
        	CreateTransactionService.CreateTranRespClass resp2= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('ERROR',resp2.status, 'Error Status for duplicate Transaction Test Case');
        	system.assertEquals(6,resp2.responseCode , 'Error responseCode for duplicate Transaction Test Case');
        	system.assertEquals('Duplicate Transaction',resp2.errorReason , 'Error errorReason for duplicate Transaction Test Case');
            
    }
    static testmethod void negativeValidationAccount1(){
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '';
        tranReq.Amount = 10.00;
        tranReq.SourceSystemId = 'Test';
        tranReq.TransactionDate = system.now();
        tranReq.TransactionId = 'Ref123';
        tranReq.TransactionType = 'Credit';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('ERROR' ,resp.status ,'Error Status for Negative Acct1 Test Case');
        	system.assertEquals(1,resp.responseCode ,'Error responseCode for Negative Acct1 Test Case');
        	system.assertEquals('Please Provide Valid Account Number',resp.errorReason, 'Error errorReason for Negative Acct1 Test Case');
    }
	static testmethod void negativeValidationAccount2(){
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '5678';
        tranReq.Amount = 10.00;
        tranReq.SourceSystemId = 'Test';
        tranReq.TransactionDate = system.now();
        tranReq.TransactionId = 'Ref123';
        tranReq.TransactionType = 'Credit';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('ERROR' ,resp.status ,'Error Status for Negative Acct2 Test Case');
        	system.assertEquals(1,resp.responseCode , 'Error responseCode for Negative Acct2 Test Case');
        	system.assertEquals('Account Not Found',resp.errorReason, 'Error errorReason for Negative Acct2 Test Case');
    }
    static testmethod void negativeValidationTranType(){
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '12345';
        tranReq.Amount = 10.00;
        tranReq.SourceSystemId = 'Test';
        tranReq.TransactionDate = system.now();
        tranReq.TransactionId = 'Ref123';
        tranReq.TransactionType = '';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('ERROR' ,resp.status ,'Error Status for Tran type Test Case');
        	system.assertEquals(2,resp.responseCode , 'Error responseCode for tran type Test Case');
        	system.assertEquals('Invalid Transaction Type',resp.errorReason, 'Error errorReason for tran type Test Case');
    }

    static testmethod void negativeValidationAmt(){
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '12345';
        tranReq.Amount = -10.00;
        tranReq.SourceSystemId = 'Test';
        tranReq.TransactionDate = system.now();
        tranReq.TransactionId = 'Ref123';
        tranReq.TransactionType = 'Credit';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('ERROR' ,resp.status ,'Error Status for Amt Test Case');
        	system.assertEquals(3,resp.responseCode , 'Error responseCode for Amt Test Case');
        	system.assertEquals('Invalid Amount',resp.errorReason, 'Error errorReason for Amt Test Case');
    }

     static testmethod void negativeValidationSrc(){
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '12345';
        tranReq.Amount = 10.00;
        tranReq.SourceSystemId = '';
        tranReq.TransactionDate = system.now();
        tranReq.TransactionId = 'Ref123';
        tranReq.TransactionType = 'Credit';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('ERROR' ,resp.status ,'Error Status for src Test Case');
        	system.assertEquals(4,resp.responseCode , 'Error responseCode for src Test Case');
        	system.assertEquals('Failed To Identify Source',resp.errorReason, 'Error errorReason for Src Test Case');
    }
    static testmethod void negativeValidationTranDate(){
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '12345';
        tranReq.Amount = 10.00;
        tranReq.SourceSystemId = 'Src123';
        tranReq.TransactionDate = null;
        tranReq.TransactionId = 'Ref123';
        tranReq.TransactionType = 'Credit';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('ERROR' ,resp.status ,'Error Status for Tran Date Case');
        	system.assertEquals(5,resp.responseCode , 'Error responseCode for Tran date Case');
        	system.assertEquals('Transaction Date Is Required',resp.errorReason, 'Error errorReason for Tran date Case');
    }
    static testmethod void negativeValidationTranId(){
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '12345';
        tranReq.Amount = 10.00;
        tranReq.SourceSystemId = 'Src123';
        tranReq.TransactionDate = system.now();
        tranReq.TransactionId = '';
        tranReq.TransactionType = 'Credit';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('ERROR' ,resp.status ,'Error Status for Tran ID Test Case');
        	system.assertEquals(6,resp.responseCode ,'Error responseCode for Tran Id Test Case');
        	system.assertEquals('Transaction Id Is Required',resp.errorReason, 'Error errorReason for Tran Id Test Case');
    }
    static testmethod void negativeValidationAccStatus(){
        FinServ__FinancialAccount__c fsAcc  = [Select Id , FinServ__Status__c from FinServ__FinancialAccount__c Limit 1];
        fsAcc.FinServ__Status__c = 'Pending';
        update fsAcc;
        
        CreateTransactionService.CreateTranReqClass tranReq = new CreateTransactionService.CreateTranReqClass();
        
        tranReq.FinancialAccount = '12345';
        tranReq.Amount = 10.00;
        tranReq.SourceSystemId = 'Src123';
        tranReq.TransactionDate = system.now();
        tranReq.TransactionId = 'Ref123';
        tranReq.TransactionType = 'Credit';
        
        String JsonMsg=JSON.serialize(tranReq);   
              
            Test.startTest(); 
             // Set up a test request
            RestResponse response = new RestResponse();
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueof(JsonMsg);   
            request.requestUri ='/services/apexrest/CreateTransactionService';
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response; 
            CreateTransactionService.CreateTranRespClass resp= CreateTransactionService.postTransaction();
           // Verify results
            Test.stopTest();
        	system.assertEquals('ERROR' ,resp.status ,'Error Status for Acc status Test Case');
        	system.assertEquals(1,resp.responseCode ,'Error responseCode for Acc status Test Case');
        	system.assertEquals('Cannot Process Transaction on this account',resp.errorReason, 'Error errorReason for Acc status Test Case');
        
    }
}