/**
 * Created by Adelchi on 27/04/2018.
 */

public with sharing class InventoryManagement2Ctrl {
        public static Inventory__c newInventory;
        public static List<String> inventoryNames;
        public static List<String> consumablesNames;

        @AuraEnabled
        public static void addItems(String medId, Decimal Quantity, String batchNumber, String expireDate){
            Date expiringDate = date.valueOf(expireDate);
            String userId = userInfo.getUserId();
            String contactId = [SELECT ContactId FROM User WHERE Id =: userId LIMIT 1].ContactId;
            String siteId = [SELECT Site__c FROM Contact WHERE Id =: contactId LIMIT 1].Site__c;
            Inventory_Required__c invReq = [SELECT Name, Doses_per_Item__c, Group__c FROM Inventory_Required__c WHERE Id =: medId LIMIT 1];
            Inventory__c newInventory  = new Inventory__c();
            newInventory.Total_Doses__c = invReq.Doses_per_Item__c * Quantity;
            newInventory.Name = invReq.Name;
            newInventory.Batch_Number__c = batchNumber;
            newInventory.Expiration_Date__c = expiringDate;
            newInventory.SiteName__c = siteId;
            newInventory.Available__c = True;
            insert newInventory;
        }

        @AuraEnabled
        public static List<String> getMedicationList(){
            Medication_Prescribed__c mp = new Medication_Prescribed__c();
            inventoryNames = fetchPickList.getselectOptions(mp, 'Medication_Name__c');
            return inventoryNames;
        }


        @AuraEnabled
        public static List<String> getConsumablesList(){
            Medication_Prescribed__c mp = new Medication_Prescribed__c();
            consumablesNames = fetchPickList.getselectOptions(mp, 'Consumables__c');
            return consumablesNames;
        }

        @AuraEnabled
        public static void removeMedItems(String medId, Decimal Quantity, String batchNumber, String expireDate, String removalReason){
            String userId = userInfo.getUserId();
            String contactId = [SELECT ContactId FROM User WHERE Id =: userId LIMIT 1].ContactId;
            String siteId = [SELECT Site__c FROM Contact WHERE Id =: contactId LIMIT 1].Site__c;
            List<Inventory__c> inventoryItems = [SELECT Id, Available__c, Manual_Removal_Reason__c, Removal_Reason__c, Batch_Number__c, Expiration_Date__c FROM Inventory__c WHERE Name =: Name AND SiteName__c =: siteId AND Expiration_Date__c =: expiringDate];
            if(!(inventoryItems.size()<Quantity)){
                for(Integer i=0; i<Quantity; i++){
                    inventoryItems[i].Available__c = False;
                    inventoryItems[i].Removal_Reason__c = 'Manually Removed';
                    inventoryItems[i].Manual_Removal_Reason__c = removalReason;
                }
                Update inventoryItems;
            }else{system.debug('Inventory List Size < Quantity of Items Intended to be Removed');}
        }

        @AuraEnabled
        public static void editItems(){}

    }