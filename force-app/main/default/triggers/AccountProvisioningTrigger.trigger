trigger AccountProvisioningTrigger on Account_Provisioning__e (after insert) {
     for (Account_Provisioning__e accEvent : Trigger.New){
       AccountProvisioningTriggerHandler.SendAccForProv(accEvent.Financial_Acct_ID__c);
       EventBus.TriggerContext.currentContext().setResumeCheckpoint(accEvent .replayId);             
    }
}