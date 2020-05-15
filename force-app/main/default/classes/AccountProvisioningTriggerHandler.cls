public class AccountProvisioningTriggerHandler {
    // Data class for request.
     private class SendAccForProvReq{
        private string CustName;
        private string CustAccountNumber;
        Private string FinancialAccountNumber;
        Private string FinancialAccountType;
    }
    
    // Data class for response.
    private class AccProvResp{
        private string AccNumber;
    }
    // retrive the data from the financial account that needs to provisioned. 
    // build the request and pass it DoCallOut Method to perform the callout.
    // update the finacial account with the accountnumber returned after provisioning.
    // FutureScope : Error Handling (create error log records).
    @future(callout=true)
    public static void SendAccForProv(string NewAccId){
        
        Try {
       	 	list<FinServ__FinancialAccount__c> newAccList = [Select Id, Name, FinServ__RecordTypeName__c, FinServ__PrimaryOwner__r.AccountNumber, FinServ__PrimaryOwner__r.Name,FinServ__FinancialAccountNumber__c  From FinServ__FinancialAccount__c where Id = :NewAccId ];
        
        	//Fill the request template with all the required data for provisioning
        	SendAccForProvReq reqbodyTemp      = new SendAccForProvReq();
        	reqbodyTemp.CustName               = newAccList[0].FinServ__PrimaryOwner__r.Name;
        	reqbodyTemp.CustAccountNumber      = newAccList[0].FinServ__PrimaryOwner__r.AccountNumber;
        	reqbodyTemp.FinancialAccountNumber = newAccList[0].Id;
        	reqbodyTemp.FinancialAccountType   = newAccList[0].FinServ__FinancialAccountNumber__c;
            
        
			//Generate the reqBody in Json format.
        	string reqbody 			= JSON.serialize(reqbodyTemp,true);
        
        	//Send This off to Provisioning system
        	//In realtime for testclasses to work with callout
        	//				we will also have set Mockresponse using Test.setMock(HttpCalloutMock.class, new MockResponseProviderClass())
        	//				where MockResponseProviderClass will hold the logic for setting mock response.
        	httpResponse response 	    = DoCallOut(reqbody);
        
        	// Considering that the 3rd party system will not have any errors in the resp if callout was success(ex:data issues causing provisioning to fail).
        	//  In real time we need to check on an any additional response scenariors and error if required.
        	
            AccProvResp respBody = (AccProvResp) JSON.deserialize(response.getBody(), AccProvResp.class);
				
            // update the financialAccount with the account number returned after provisioning.        
        		newAccList[0].FinServ__FinancialAccountNumber__c = respBody.AccNumber;
            	newAccList[0].FinServ__Status__c = 'Open';
        		update newAccList;
        	
        } catch (exception e ){
            // error handling would be done here - DMLExceptions / integration exception / any other data related exception from 3rd party. 
            // Ex: Create a error handling rec that would provides details of error and facilitate further action.
            throw e;
        }
        
    }
    
	// This method uses the request body and builds the http request with headers. 
	// performs the callout.
	// Checks the callout response was okay and returns the response.
	// In Real time when SF would connect to multiple systems , It is Ideal to follow integration framework 
	//                                      and put this in a seperate class for reusability 
    public static httpResponse DoCallOut(string reqBody){
        //Generate Http request
        HttpRequest request     = new HttpRequest();
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setBody(reqbody);
        request.setHeader('Content-Type','text/json');
        request.setHeader('Content-Length',string.valueOf(reqbody.length()));
        string endpoint		    = 'callout:AccProvisioningSystem'; // This is dummy. Named credetial storing end point details.
        
        // do callout
        http h 					= new http();
        //httpResponse response   = h.send(request);
        //This response is mocked and can be replaced with callout.
        httpResponse response   = mockResponse();
        
        if(response.getStatusCode() != 200){ 
            IntegrationException e 		  = new IntegrationException();
            					 e.code   = string.valueof(response.getStatusCode());
            					 e.reason = response.getBody();    
            throw e;
        } 
        //return the response.
        return response;
    }
    public static httpResponse mockResponse(){
        httpResponse response   = new httpResponse();
        AccProvResp res = new AccProvResp();
        res.AccNumber = String.valueOf(Integer.valueof((Math.random() * 100000)));
        string resBody = JSON.serialize(res,true);
        response.setBody(resBody);
        response.setStatus('Success');
        response.setStatusCode(200);
        response.setHeader('Content-Type','text/json');
        response.setHeader('Content-Length',string.valueOf(resBody.length()));
        return response;
    }
    public class IntegrationException extends Exception {
        public string code;
        public string reason;
    }
    
}