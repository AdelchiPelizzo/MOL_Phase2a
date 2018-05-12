/**
 * Created by Adelchi on 09/05/2018.
 */

public with sharing class UpdateInventoryRequired {

    @AuraEnabled
    public static void setExistingDoses(String InventReq, String BatchNr, Integer qty, String mode){
        List<Inventory_Required__c> invReqToUpdate = new List<Inventory_Required__c>();
        List<Inventory__c> invListBox = [SELECT Id, Total_Doses__c, Available__c FROM Inventory__c WHERE InvenTory_Required__c =: InventReq AND Available__c = True AND isPartial__c = False];
        List<Inventory__c> invListDose = [SELECT Id, Total_Doses__c, Available__c FROM Inventory__c WHERE Name =: Name AND Batch_Number__c =: BatchNr AND Available__c = True AND isPartial__c = True];

    }

}