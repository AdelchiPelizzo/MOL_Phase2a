/**
 * Created by Adelchi on 14/04/2018.
 */

public with sharing class MedicationPrescriptionCtrl {

    public static Consultation__c consultation;
    public static Inventory__c iRecord;
    public static Medication_Prescribed__c medPrescribed;
    public static Site__c site;
    public static Supply__c medicalSupply;

   @AuraEnabled
    public static void getInventoryItem(String medPId, String consultId, String InventoryName, String batchN, Decimal qty){
       system.debug(InventoryName+'xxxxx'+consultId+'quantity>> '+qty);
       consultation = [SELECT Site__c FROM Consultation__c WHERE Id =: consultId LIMIT 1];
       for(Integer i=0; i<qty; i++){
           iRecord = [SELECT Id, Available__c, Removal_Reason__c, Batch_Number__c FROM Inventory__c WHERE SiteName__c =: consultation.Site__c AND Batch_Number__c =: batchN AND Name =: InventoryName AND Available__c = true LIMIT 1];
           system.debug(iRecord.Id);
           setInventoryItem(consultId, medPId);
       }
    }

    @AuraEnabled
    public static List<Inventory_Required__c> getRequired(String siteId){
        List<Inventory_Required__c> lstIR = new List<Inventory_Required__c>();
        lstIR = [SELECT Name, Quantity_Required__c, IsStandard__c, Group__c FROM Inventory_Required__c WHERE Site__c =: siteId];
        return lstIR;
    }

    @AuraEnabled
    public static void setInventoryItem(String conId, String medPrescribedId){
        system.debug('inside set Inventory name method xxxxx   '+conId);
        iRecord.Available__c = false;
        iRecord.Removal_Reason__c = 'Used';
        iRecord.Consultation__c = conId;
        iRecord.Medication_Prescribed__c = medPrescribedId;
        system.debug('inside set Inventory name method xxxxx   '+iRecord.Available__c);
        update iRecord;
    }

    @AuraEnabled
    public static void setMedicalSupply(String inventoryId, String medPrescribedId, Decimal units){
        List<Supply__c> supList = new List<Supply__c>();
        supList = [SELECT Id FROM Supply__c WHERE Medication_Prescribed__r.Id =: medPrescribed AND Inventory__c =: inventoryId];
    }

/*    @AuraEnabled
    public static List < String > getMedicationList(){
        system.debug('get medication list method started ');
        Medication_Prescribed__c mp = new Medication_Prescribed__c();
        List < String > medicationList = fetchPickList.getselectOptions(mp, 'Medication_Name__c');
        return medicationList;
    }*/

    @AuraEnabled
    public static List<String> getBatchNumList(String medId){
        system.debug('get medication list method started ');
        String userId = userInfo.getUserId();
        system.debug(userId);
        String contactId = [SELECT ContactId FROM User WHERE Id =: userId LIMIT 1].ContactId;
        system.debug(contactId);
        String siteId = [SELECT Site__c FROM Contact WHERE Id =: contactId LIMIT 1].Site__c;
        system.debug(siteId);
        String medName = [SELECT Name FROM Inventory_Required__c WHERE Id =: medId LIMIT 1].Name;
        system.debug(medName);
        List<String> batchNLst = new List<String>();
        List<Inventory__c> invLst = [SELECT Batch_Number__c FROM Inventory__c WHERE Name =: medName AND SiteName__c =: siteId AND Available__c = TRUE];
        system.debug(invLst.size());
        for(Integer i=0; i<invLst.size(); i++){
            batchNLst.add(invLst[i].Batch_Number__c);
        }
        system.debug(batchNLst.size());
        return batchNLst;
    }

}