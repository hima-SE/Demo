@isTest
private class AccountProvisioningTriggerTest {
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
    static testmethod void testProvisioningTrigger(){
        FinServ__FinancialAccount__c fsAcc  = [Select Id , FinServ__Status__c,FinServ__FinancialAccountNumber__c  from FinServ__FinancialAccount__c Limit 1];
        Account_Provisioning__e ap = new Account_Provisioning__e(Financial_Acct_ID__c = fsAcc.Id);
        test.startTest();
        	EventBus.publish(ap);
        test.stopTest();
    }
}