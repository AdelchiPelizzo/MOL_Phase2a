/**
 * Created by Adelchi on 14/04/2018.
 */

public with sharing class MedicationPrescriptionCtrl {

    public static Consultation__c consultation;
    public static Inventory__c iRecord;
    public static Medication_Prescribed__c medPrescribed;
    public static Site__c site;

   @AuraEnabled
    public static void getInventoryItem(String consultId, String InventoryName, String batchN, Integer qty){
       system.debug(InventoryName+'xxxxx'+consultId+'quantity>> '+qty);
       Boolean checkBatchNumber = ([SELECT count() FROM Inventory__c WHERE Batch_Number__c =: batchN]>0);
       if(!checkBatchNumber){
           throw new AuraHandledException('No Items are Available with this Batch Number!');
       }else{
           consultation = [SELECT Site__c FROM Consultation__c WHERE Id =: consultId LIMIT 1];
           for(Integer i=0; i<qty; i++){
               iRecord = [SELECT Id, Available__c, Removal_Reason__c, Batch_Number__c FROM Inventory__c WHERE SiteName__c =: consultation.Site__c AND Batch_Number__c =: batchN AND Name =: InventoryName AND Available__c = true LIMIT 1];
               system.debug(iRecord.Id);
               setInventoryItem(consultId);
           }
       }
    }

    @AuraEnabled
    public static void setInventoryItem(String conId){
        system.debug('inside set Inventory name method xxxxx   '+conId);
        iRecord.Available__c = false;
        iRecord.Removal_Reason__c = 'Used';
        iRecord.Consultation__c = conId;
        system.debug('inside set Inventory name method xxxxx   '+iRecord.Available__c);
        update iRecord;
    }

    @AuraEnabled
    public static List < String > getMedicationList(){
        system.debug('get medication list method started ');
        Medication_Prescribed__c mp = new Medication_Prescribed__c();
        List < String > medicationList = fetchPickList.getselectOptions(mp, 'Medication_Name__c');
        return medicationList;
    }

}