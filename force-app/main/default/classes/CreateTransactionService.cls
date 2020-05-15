/*@author : Hima
 * @date : 14/05/2020
 * @description : This is a rest service that can be consumed to create transactions on the financial accounts.
 * for the ease of build, it is assumed that transactions are of completed status always. additional checks can be applied on status.
 * Sample Request :  {
						"FinancialAccount":"29452",
						"SourceSystemId":"Test111",
						"TransactionDate":"2020-05-14T03:38:12.000+0000",
						"TransactionType":"Debit",
						"TransactionSubtype":"EFT",
						"TransactionId":"Ref12345",
						"Amount":100.00
					  }
 */
@RestResource(urlMapping = '/CreateTransactionService')
global with sharing class CreateTransactionService {
    global with sharing class CreateTranReqClass {
        public string   FinancialAccount;
        public string   SourceSystemId;
        public datetime TransactionDate;
        public string   TransactionType;
        public string   TransactionSubtype;
        public string   TransactionId;
        public decimal Amount;
    }
    global with sharing class CreateTranRespClass {
        public string  status;
        public integer responseCode;
        public string  errorReason;
    }
    
	@HttpPost
    global static CreateTranRespClass postTransaction(){
        CreateTranRespClass response = new CreateTranRespClass();
        Try{
        	RestRequest request = RestContext.request;
        	string reqBody = request.requestBody.toString();
        	CreateTranReqClass formatedReq = (CreateTranReqClass)JSON.deserialize(reqBody,CreateTranReqClass.class);
        	CreateTranRespClass validateDataResp = validateData(formatedReq);
        	if (validateDataResp.status =='SUCCESS'){
            	response = createTransaction(formatedReq);
        	}ELSE{
            	response = validateDataResp;
        	}
        }Catch (exception e){
            response.status       = 'ERROR';
            response.responseCode = 7;
            response.errorReason  = 'A Technical Error Has Occured.Please try again';
            System.debug('errormessage:' + e.getMessage());
            System.debug('stackTrace:' + e.getStackTraceString());
        }
        
		//string responseString =  JSON.serialize(response,true); 
        //return responseString;
        return response;
    }
    
    // first level of Checks - request data validitity.
    public static CreateTranRespClass validateData(CreateTranReqClass formatedReq ){
			CreateTranRespClass validateDataResp = new CreateTranRespClass(); 
        	// Check ensure AccountNumber is provided. We can additional checks to include the account number length , if there is a minimum.
        	IF(String.isBlank(formatedReq.FinancialAccount) || !formatedReq.FinancialAccount.isNumeric()){
            	validateDataResp.status       = 'ERROR';
                validateDataResp.responseCode = 1;
                validateDataResp.errorReason  = 'Please Provide Valid Account Number';
            }Else If(formatedReq.TransactionType != 'Credit'&& formatedReq.TransactionType != 'Debit'){
                validateDataResp.status       = 'ERROR';
                validateDataResp.responseCode = 2;
                validateDataResp.errorReason  = 'Invalid Transaction Type';
            }Else If(formatedReq.Amount<=0.00){
                validateDataResp.status       = 'ERROR';
                validateDataResp.responseCode = 3;
                validateDataResp.errorReason  = 'Invalid Amount';
            }Else If(string.Isblank(formatedReq.SourceSystemId)){ // can add additional checks to avoid malcious transactions
                validateDataResp.status       = 'ERROR';
                validateDataResp.responseCode = 4;
                validateDataResp.errorReason  = 'Failed To Identify Source';
            }Else If(String.isBlank(String.valueof(formatedReq.TransactionDate))){
                 validateDataResp.status       = 'ERROR';
                 validateDataResp.responseCode = 5;
                 validateDataResp.errorReason  = 'Transaction Date Is Required';
                
            }Else If(String.isBlank(formatedReq.TransactionId)){
                 validateDataResp.status       = 'ERROR';
                 validateDataResp.responseCode = 6;
                 validateDataResp.errorReason  = 'Transaction Id Is Required';
            }ELSE{
                 validateDataResp.status       = 'SUCCESS';
                 validateDataResp.responseCode = 0;
                 validateDataResp.errorReason  = ' ';	
            }       		
        	return validateDataResp;
    }
    // Find the account , Check the status and balance , if all okay post the transaction.
    public static CreateTranRespClass createTransaction(CreateTranReqClass formatedReq ){
			CreateTranRespClass createTranResp = new CreateTranRespClass();        
        	list<FinServ__FinancialAccount__c> accList = [Select Id, FinServ__FinancialAccountNumber__c, FinServ__Status__c, FinServ__Balance__c From FinServ__FinancialAccount__c where FinServ__FinancialAccountNumber__c = :formatedReq.FinancialAccount ];
                If(accList.size() >0){
                    If (accList[0].FinServ__Status__c != 'Active' && accList[0].FinServ__Status__c != 'Open'){
                        // Can apply checks on transaction sub type to see which transactions are valid for each account status instead.
                        createTranResp.status       = 'ERROR';
                 		createTranResp.responseCode = 1;
                 		createTranResp.errorReason  = 'Cannot Process Transaction on this account';
                    }ELSE{
                        IF(formatedReq.TransactionType == 'Debit' && formatedReq.Amount > accList[0].FinServ__Balance__c ){
                              createTranResp.status 	  = 'ERROR';
                 			  createTranResp.responseCode = 1;
                 			  createTranResp.errorReason  = 'Insufficient Funds';
                           }Else{
                               
                               if(formatedReq.TransactionType == 'Debit'){
                                   accList[0].FinServ__Balance__c -= formatedReq.Amount; 
                               }else{
                                   accList[0].FinServ__Balance__c += formatedReq.Amount; 
                               }
                              
                              // check to ensure the transaction was not already posted. 
                              list<FinServ__FinancialAccountTransaction__c> checktransList  = new list<FinServ__FinancialAccountTransaction__c>();
                              checktransList = [Select Id from FinServ__FinancialAccountTransaction__c where FinServ__TransactionId__c = :formatedReq.TransactionId ];
                               
                               If(checktransList.size() == 0)  {
                              				FinServ__FinancialAccountTransaction__c trans = new FinServ__FinancialAccountTransaction__c(
                              													FinServ__FinancialAccount__c = accList[0].Id,
                              													FinServ__PostDate__c  = system.now(),
                              													FinServ__SourceSystemId__c = formatedReq.SourceSystemId,
                              													FinServ__TransactionDate__c	 = formatedReq.TransactionDate,													
                              													FinServ__TransactionStatus__c = 'Posted',
                                  												FinServ__TransactionType__c = formatedReq.TransactionType,
                                                                                FinServ__TransactionSubtype__c = formatedReq.TransactionSubtype,
                                                                                FinServ__TransactionId__c = formatedReq.TransactionId,
                                  												FinServ__Amount__c = formatedReq.Amount); 
                              
                             				insert trans;
                             				update accList;
                              
                             				createTranResp.status 	  = 'SUCCESS';
                 		     				createTranResp.responseCode = 0;
                 		     				createTranResp.errorReason  = ' ';	
                               }else{
                                   		createTranResp.status 	  = 'ERROR';
                 		     			createTranResp.responseCode = 6;
                 		     			createTranResp.errorReason  = 'Duplicate Transaction';	
                               }
                    	   }
                    }  
                }ELSE{
                    	createTranResp.status 		= 'ERROR';
                 		createTranResp.responseCode = 1;
                 		createTranResp.errorReason  = 'Account Not Found';
                }
        	return createTranResp;
    }
}