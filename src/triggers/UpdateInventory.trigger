/**
 * Created by Adelchi on 15/04/2018.
 */

trigger UpdateInventory on Medication_Prescribed__c (before insert) {
    system.debug('Trigger Started');
    //Get User Information
    String userId = userInfo.getUserId();
    String contactId = [SELECT ContactId FROM User WHERE Id =: userId LIMIT 1].ContactId;
    String siteId = [SELECT Site__c FROM Contact WHERE Id =: contactId LIMIT 1].Site__c;
    system.debug(siteId);
    //Initiate a list of full boxes
    //and a list of partial boxes
    List<Inventory__c> InventList = new List<Inventory__c>();
    List<Inventory__c> InventListPartial = new List<Inventory__c>();
    //Start iteration through new Medication Prescribed Records
    for (Medication_Prescribed__c mp : Trigger.new) {
        // Get quantity and type of prescripition
        Integer qty = (Integer)mp.Quantity_Prescribed__c;
        String mode = mp.prescriptionMode__c;
        system.debug('prescription Mode >> '+mode);
        system.debug('Batch Number >> '+mp.Batch_Number__c);
        //Get list of available full boxes or partial
        List<Inventory__c> InventoryList = [SELECT Id, Available__c, isPartial__c, Total_Doses__c, Batch_Number__c, Removal_Reason__c, Number_of_Items__c, SiteName__c FROM Inventory__c WHERE  Name =: mp.Medication_Name__c AND Available__c = TRUE AND SiteName__c =: siteId AND isPartial__c = FALSE AND Batch_Number__c =: mp.Batch_Number__c];
        system.debug('InventoryList >> '+InventoryList);
        List<Inventory__c> InventoryListPartial = [SELECT Id, Available__c, isPartial__c, Total_Doses__c, Batch_Number__c, Removal_Reason__c, Number_of_Items__c, SiteName__c FROM Inventory__c WHERE  Name =: mp.Medication_Name__c AND Available__c = TRUE AND SiteName__c =: siteId AND isPartial__c = TRUE AND Batch_Number__c =: mp.Batch_Number__c];
        system.debug('InventoryListPartial >> '+InventoryListPartial);
        Integer numberOfExistingFullBoxes = InventoryList.size();
        Integer numberOfExistingPartBoxes = InventoryListPartial.size();

        //Make a Map of InventoryId to partialQuantity
        Map<String, Decimal> inventoryMap = new Map<String, Decimal>();

        Integer numberOfDosesPrescribed = 0;
        Integer numberOfBoxesPrescribed = 0;

        if(mode=='box'){
            numberOfBoxesPrescribed = qty;
        }else{
            numberOfDosesPrescribed = qty;
        }
        system.debug('numberOfBoxesPrescribed >> '+numberOfBoxesPrescribed+'  >> numberOfDosesPrescribed >> '+numberOfDosesPrescribed);

        if(numberOfBoxesPrescribed > 0 && numberOfExistingFullBoxes > 0){
            for(Integer i=0; i<numberOfBoxesPrescribed; i++){
                InventoryList[i].Available__c = False;
                InventoryList[i].Removal_Reason__c = 'Used';
                mp.Inventory__c = InventoryList[i].Id;
            }
            update InventoryList;
        }else if(numberOfDosesPrescribed >0 && numberOfExistingPartBoxes > 0){
            system.debug('inside else if >> numberOfDosesPrescribed>> '+numberOfDosesPrescribed+'  << numberOfExistingPartBoxes >> '+numberOfExistingPartBoxes);
            for(Inventory__c inventory : InventoryListPartial) {
                inventoryMap.put(inventory.Id, inventory.Total_Doses__c);
            }
            for (String id : inventoryMap.keySet())
            {
                Inventory__c i = [SELECT Available__c, isPartial__c, Total_Doses__c, Medication_Prescribed__r.Id, Batch_Number__c, Removal_Reason__c, Number_of_Items__c, SiteName__c FROM Inventory__c WHERE  id =: id LIMIT 1];
                system.debug(i);
                if(inventoryMap.get(id)==numberOfDosesPrescribed){
                    system.debug('first run ... !');
                    i.Available__c = False;
                    i.Total_Doses__c = 0;
                    i.Removal_Reason__c = 'Used';
                    InventListPartial.add(i);
                    numberOfDosesPrescribed = 0;
                    mp.Inventory__c = Id;
                    update i;
                }else if(inventoryMap.get(id)>numberOfDosesPrescribed){
                    system.debug('second run ... !');
                    i.Total_Doses__c = i.Total_Doses__c - numberOfDosesPrescribed;
                    i.isPartial__c = True;
                    system.debug(mp.Id);
                    mp.Inventory__c = i.Id;
                    update i;
                    numberOfDosesPrescribed = 0;
                }else if(inventoryMap.get(id)<numberOfDosesPrescribed){
                    system.debug('third run ... !');
                    i.Available__c = False;
                    numberOfDosesPrescribed = numberOfDosesPrescribed - (Integer)inventoryMap.get(id);
                    i.Total_Doses__c = 0;
                    i.isPartial__c = False;
                    i.Removal_Reason__c = 'Used';
                    mp.Inventory__c = Id;
                    InventListPartial.add(i);
                }
            }
            update InventListPartial;
            if(numberOfDosesPrescribed > 0){
                InventoryList[0].isPartial__c = True;
                InventoryList[0].Total_Doses__c = InventoryList[0].Total_Doses__c - numberOfDosesPrescribed;
                mp.Inventory__c = InventoryList[0].Id;
            }
            update InventoryList;

            /*
            System.debug(id);
            System.debug(inventoryMap.get(id));
            */
        }else if(numberOfDosesPrescribed >0 && numberOfExistingPartBoxes == 0){
            InventoryList[0].isPartial__c = True;
            InventoryList[0].Total_Doses__c = InventoryList[0].Total_Doses__c - numberOfDosesPrescribed;
            mp.Inventory__c = InventoryList[0].Id;
            update InventoryList;
        }
    }
}