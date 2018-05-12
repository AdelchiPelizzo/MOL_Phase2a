/**
 * Created by Adelchi on 07/05/2018.
 */
/**
* @ClassName      : InventoryReportCtrl
* @parameter      : NA
* @Description    : This class is used to contain the sobject records and their type to show on the Inventory Report page
*/
public with sharing class InventoryReportCtrl {

    public static String userId;
    public static String contactId;
    public static String siteId;
    public static List<Inventory__c> inLst;
    public static Inventory_required__c requirement;

    @AuraEnabled
    public static void setUserData(){
        userId = userInfo.getUserId();
        contactId = [SELECT ContactId FROM User WHERE Id =: userId LIMIT 1].ContactId;
        siteId = [SELECT Site__c FROM Contact WHERE Id =: contactId LIMIT 1].Site__c;
        inLst = [SELECT Name, Total_Doses__c, Inventory_required__c, Batch_Number__c, Expiration_Date__c FROM Inventory__c WHERE SiteName__c =: siteId AND Available__c = True];
    }

    @AuraEnabled
    public static List<RecordWrapper> getList (String searchTerm){
        setUserData();
        List<RecordWrapper> rWList = new List<RecordWrapper>();
        List<Inventory__c> inventoryList = new List<Inventory__c>();
        inventoryList  = [SELECT Name, Total_Doses__c, Expiration_Date__c, Inventory_required__c, Batch_Number__c, isPartial__c FROM Inventory__c WHERE SiteName__c =: siteId AND Available__c = True AND Name = : searchTerm ORDER BY Batch_Number__c ASC];
        system.debug(inventoryList[0].Inventory_required__c);
        requirement = [SELECT Id, Quantity_Required__c, Total_Doses_Required__c FROM Inventory_required__c WHERE Name  =: searchTerm LIMIT 1];
        system.debug(requirement.Id);
        Integer j = 0;
        Integer i = 0;
        Integer totalDose = 0;
        Integer totalBox = 0;
        String BatchNr = inventoryList[0].Batch_Number__c;
        Date expDate = inventoryList[0].Expiration_Date__c;
        Decimal boxesReq = requirement.Quantity_Required__c;
        Decimal dosesReq = requirement.Quantity_Required__c;
        for(i=0; i<inventoryList.size(); i++){
            system.debug('start for loop'+inventoryList.size());
            if(inventoryList[i].Batch_Number__c == batchNr){
                system.debug('inside if'+i);
                totalDose = totalDose + (Integer)inventoryList[i].Total_Doses__c;
                expDate = inventoryList[i].Expiration_Date__c;
                totalBox = totalBox + 1;
            }else{
                system.debug('inside else'+i);
                rWList.add(new RecordWrapper(totalBox, totalDose, BatchNr, dosesReq, boxesReq, expDate));
                batchNr = inventoryList[i].Batch_Number__c;
                i--;
                totalDose = 0;
                totalBox = 0;
            }
            system.debug('end for loop'+rWList.size());
        }
        if(inventoryList.size()>0){rWList.add(new RecordWrapper(totalBox, totalDose, BatchNr, dosesReq, boxesReq, expDate));}
        system.debug(rWList);
        return rWList;
    }


    public class RecordWrapper
    {
        @AuraEnabled public Integer totBoxByNam {set;get;}
        @AuraEnabled public Integer totalDoseName {set;get;}
        @AuraEnabled public String batchNumber {set;get;}
        @AuraEnabled public Integer InvRequiredQty {set;get;}
        @AuraEnabled public Integer inventoryReqDose {set;get;}
        @AuraEnabled public Date expDate {set;get;}

        public RecordWrapper(Integer totBoxByNam, Integer totalDoseByName, String batchNumber, Decimal InvRequiredQty, Decimal inventoryReqDose, Date ExpirationDate)
        {
            this.totBoxByNam = totBoxByNam;
            this.totalDoseName = totalDoseByName;
            this.batchNumber = batchNumber;
            this.InvRequiredQty = (Integer)InvRequiredQty;
            this.inventoryReqDose = (Integer)inventoryReqDose;
            this.expDate = ExpirationDate;
        }
    }
}