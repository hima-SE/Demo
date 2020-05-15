@isTest
private class AccountProvisioningTriggerHandlerTest {
    @testSetup Static void createTestData(){
        Id accRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        account cust =  new account (RecordTypeId = accRecType,
                                     Salutation = 'Ms.',
                                     FirstName = 'Test Cust',
                                     LastName  = 'Does Not Exist'
                                    );
        insert cust;
        
        Id fsAccRecType = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Savings Account').getRecordTypeId();
 		FinServ__FinancialAccount__c fsAcc = new FinServ__FinancialAccount__c ( FinServ__PrimaryOwner__c = cust.Id ,
                                                                               	RecordTypeId = fsAccRecType,
                                                                                Name = 'Test Savings Account',
                                                                                FinServ__Status__c = 'Pending',
                                                                                FinServ__FinancialAccountType__c = 'Savings'
                                                                              	); 
        insert fsAcc;

    }
    static testmethod void testACCProvPostive(){
       FinServ__FinancialAccount__c fsAcc  = [Select Id , FinServ__Status__c,FinServ__FinancialAccountNumber__c  from FinServ__FinancialAccount__c Limit 1];
        Account_Provisioning__e prov       = new Account_Provisioning__e( Financial_Acct_ID__c = fsAcc.Id);
        Test.startTest();
        	AccountProvisioningTriggerHandler.SendAccForProv(fsAcc.Id);
        Test.stopTest();
		FinServ__FinancialAccount__c fsAccAfter = [select Id ,FinServ__FinancialAccountNumber__c, FinServ__Status__c 
                                                   							from FinServ__FinancialAccount__c where Id = :fsAcc.Id];
        system.assertEquals('Open', fsAccAfter.FinServ__Status__c, 'Status Update incorrect');
        system.assert(!String.isBlank(fsAccAfter.FinServ__FinancialAccountNumber__c), 'Account not provisioned');
        
    }
}