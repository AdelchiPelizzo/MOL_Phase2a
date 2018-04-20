/**
 * Created by Adelchi on 15/04/2018.
 */

trigger UpdateInventory on Medication_Prescribed__c (after insert) {
    List<Inventory__c> InventoryList = new List<Inventory__c>();
    for (Medication_Prescribed__c mp : Trigger.new) {
        Inventory__c inventory = [SELECT Available__c, Removal_Reason__c, SiteName__c FROM Inventory__c WHERE  Name =: mp.Medication_Name__c AND Available__c = TRUE AND SiteName__c =: mp.Consultation__c LIMIT 1];
        if(inventory!= null){
            inventory.Available__c = False;
            inventory.Removal_Reason__c = 'Used';
            InventoryList.add(inventory);
        }
    }
    try {update InventoryList;}catch(TypeException e){
        String err = e.getMessage();
        Trigger.New[0].adderror(err);
    }
}