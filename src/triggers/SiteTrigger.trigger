// 
// (c) 2016 Appirio, Inc.
//
// SiteTrigger  :   Trigger
// Usage        :   1) Prevent deactivation of Site if there are any Future Booking
//
//  21/04/2016     Khushal Dave      Original
//
trigger SiteTrigger on Site__c (before update, before delete) {

	if(CommonUtility.validateTrigger(Constants.SITE_TRIGGER_NAME)){    
    
       if(Trigger.isUpdate && Trigger.isBefore){
           SiteTriggerHandler.beforeUpdate();
       }
    
       if(Trigger.isBefore && Trigger.isDelete){
           SiteTriggerHandler.beforeDelete();
       }
   }

}