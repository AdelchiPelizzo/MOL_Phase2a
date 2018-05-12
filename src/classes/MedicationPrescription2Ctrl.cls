/**
 * Created by Adelchi on 27/04/2018.
 */

public with sharing class MedicationPrescription2Ctrl {

    public static Consultation__c consultation;
    public static Inventory__c iRecord;
    public static Medication_Prescribed__c medPrescribed;
    public static Site__c site;

    @AuraEnabled
    public static void getInventoryItem(String medPId, String consultId, String InventoryName, String batchN, Decimal qty, String prescriptionMode){
        system.debug(InventoryName+'xxxxx'+consultId+'quantity>> '+qty);
        consultation = [SELECT Site__c FROM Consultation__c WHERE Id =: consultId LIMIT 1];
        for(Integer i=0; i<qty; i++){
            iRecord = [SELECT Id, Available__c, Removal_Reason__c, Batch_Number__c FROM Inventory__c WHERE SiteName__c =: consultation.Site__c AND Batch_Number__c =: batchN AND Name =: InventoryName AND Available__c = true LIMIT 1];
            system.debug(iRecord.Id);
            setInventoryItem(consultId, medPId);
        }
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
    public static List<Inventory_Required__c> getRequired(String siteId){
        List<Inventory_Required__c> lstIR = new List<Inventory_Required__c>();
        lstIR = [SELECT Name, Quantity_Required__c, IsStandard__c, Group__c FROM Inventory_Required__c WHERE Site__c =: siteId];
        return lstIR;
    }

    @AuraEnabled
    public static List<String> getBatchNumList(String medId, String prescriptionMode, Integer qty){
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
        List<Inventory__c> invLst = new List<Inventory__c>();
        if(prescriptionMode == 'box'){
            invLst = [SELECT Batch_Number__c FROM Inventory__c WHERE Name =: medName AND SiteName__c =: siteId AND Available__c = TRUE AND isPartial__c = False];
        }else{
            invLst = [SELECT Batch_Number__c, Total_Doses__c FROM Inventory__c WHERE Name =: medName AND SiteName__c =: siteId AND Available__c = TRUE ORDER BY  Total_Doses__c ASC];
        }
        system.debug(invLst.size());
        for(Integer i=0; i<invLst.size(); i++){
            batchNLst.add(invLst[i].Batch_Number__c);
        }
        system.debug(batchNLst.size());
        return batchNLst;
    }

    @AuraEnabled
    public static void setExistingQuantity(String prescribedMedId){
        String userId = userInfo.getUserId();
        String contactId = [SELECT ContactId FROM User WHERE Id =: userId LIMIT 1].ContactId;
        String siteId = [SELECT Site__c FROM Contact WHERE Id =: contactId LIMIT 1].Site__c;

        Medication_Prescribed__c mPr = [SELECT Name, Inventory__c, Consultation__c, prescriptionMode__c, Quantity_Prescribed__c FROM Medication_Prescribed__c WHERE Id =: prescribedMedId LIMIT 1];

        Inventory_Required__c invReq = [SELECT Id,  Existing_Boxes__c, Existing_Doses__c FROM Inventory_Required__c WHERE Site__c =: siteId AND Name =: mPr.Name LIMIT 1];

        if(mPr.prescriptionMode__c == 'box'){
            invReq.Existing_Boxes__c =- mPr.Quantity_Prescribed__c;
        }else{
            invReq.Existing_Doses__c =- mPr.Quantity_Prescribed__c;
        }
        /*List<Inventory__c> invListBox = [SELECT Id, Total_Doses__c, Available__c FROM Inventory__c WHERE Inventory_Required__c =: InventReq AND Available__c = True AND isPartial__c = False];
        List<Inventory__c> invListDose = [SELECT Id, Total_Doses__c, Available__c FROM Inventory__c WHERE Name =: Name AND Batch_Number__c =: BatchNr AND Available__c = True AND isPartial__c = True];

        Inventory_Required__c> invReqToUpdate = new List<Inventory_Required__c>();*/
        update invReq;

    }


}