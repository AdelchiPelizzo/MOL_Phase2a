/**
 * Created by Adelchi on 10/05/2018.
 */

/**
* @ClassName      : InventoryReportCtrl
* @parameter      : NA
* @Description    : This class is used to contain the sobject records and their type to show on the Inventory Report page
*/

public with sharing class InventoryReport2Ctrl {

    public static String userId;
    public static String contactId;
    public static String siteId;
    public static List<Inventory__c> inLst;
    public static Integer lim;

    @AuraEnabled
    public static void setUserData(){
        lim = 0;
        userId = userInfo.getUserId();
        contactId = [SELECT ContactId FROM User WHERE Id =: userId LIMIT 1].ContactId;
        siteId = [SELECT Site__c FROM Contact WHERE Id =: contactId LIMIT 1].Site__c;
        inLst = [SELECT Name, Total_Doses__c, Inventory_required__c, Batch_Number__c, Expiration_Date__c FROM Inventory__c WHERE SiteName__c =: siteId AND Available__c = True];
    }

    @AuraEnabled
    public static List<reportRecord> getList (){
        system.debug('getList Method started ...');
        setUserData();
        system.debug('set user data ...userId.. '+ userId+ ' ..siteId>> '+siteId);
        system.debug('inventory list for the site - size ...'+inLst.size());
        List<reportRecord> repRList = new List<reportRecord>();
        Integer j = 1;
        Integer i = 0;
        for(i=0; i<inLst.size(); i++){
            lim =+ Limits.getQueries();
            system.debug('Inside FOR loop ... i= '+i+'. j= >'+j+'.....'+Limits.getQueries()+'.........'+lim);
            for(j=1; j>i; ){
                system.debug('Inside first if ...'+i+' ....'+inLst[j].Batch_Number__c +'----'+ inLst[i].Batch_Number__c);
                Boolean b = (inLst[j].Batch_Number__c != inLst[i].Batch_Number__c);
                system.debug(b+'.....'+Limits.getQueries());
                if(inLst[j].Batch_Number__c != inLst[i].Batch_Number__c){
                    system.debug('inside for if ...'+inLst[j].Batch_Number__c+'...'+inLst[i].Batch_Number__c);
                    repRList.add(new reportRecord(inLst[i].Name, inLst[i].Batch_Number__c));
                    system.debug('report Record created');
                    system.debug(repRList.size()+'..i counter ..'+i);
                }
            }j++;
        }
        system.debug('repRList'+repRList);
        return repRList;
    }

    public class reportRecord {
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String BatchNumber {get;set;}
        @AuraEnabled public Integer totalBoxByName {get;set;}
        @AuraEnabled public Integer totalDoseByName {get;set;}
        @AuraEnabled public Integer invReqQty {get;set;}
        @AuraEnabled public Integer invReqDoses {get;set;}

        public reportRecord(String Name, String BatchNr){
            this.Name = Name;
            this.BatchNumber = BatchNr;
            JSONParser parser = JSON.createParser(getRecordWrapper(Name, BatchNr));
            parser.nextToken();
            parser.nextValue();
            this.totalBoxByName = parser.getIntegerValue();
            parser.nextToken();
            parser.nextValue();
            this.totalDoseByName = parser.getIntegerValue();
            parser.nextToken();
            parser.nextValue();
            this.invReqQty = parser.getIntegerValue();
            parser.nextToken();
            parser.nextValue();
            this.invReqDoses = parser.getIntegerValue();
        }
    }

    @AuraEnabled
    public static String getRecordWrapper(String Name, String BatchNr){
        Integer totalBoxByName = 0;
        Integer totalDoseByName = 0;
        Integer invReqQty = 0;
        Integer invReqDoses = 0;
        String irId = '';
        List<Inventory__c> inventoryList = [SELECT Name, Total_Doses__c, Inventory_required__c FROM Inventory__c WHERE SiteName__c =: siteId AND Available__c = True AND Name = : Name AND Batch_Number__c =: BatchNr];
        system.debug(inventoryList);
        if(inventoryList.size()>0){
            for(Integer i=0; i<inventoryList.size(); i++){
                lim =+ Limits.getQueries();
                totalBoxByName = totalBoxByName+1;
                if(inventoryList[i].Total_Doses__c!=Null){
                    totalDoseByName = + (Integer)inventoryList[i].Total_Doses__c;
                }
            }
            system.debug(inventoryList.size()+'...'+totalBoxByName);
            if(inventoryList[0].Inventory_required__c!=null){
                irId = inventoryList[0].Inventory_required__c;
            }else{system.debug('irId is empty :::'+ irId);}
            Inventory_Required__c inventoryReq = [SELECT Name, Quantity_Required__c, Total_Doses_Required__c FROM Inventory_Required__c  WHERE Id =: irId ];
            if(inventoryReq!=null){
                invReqQty = (Integer)inventoryReq.Quantity_Required__c;
                invReqDoses = (Integer)inventoryReq.Total_Doses_Required__c;
            }
        }
        system.debug(JSON.serialize(new RecordWrapper(totalBoxByName, totalDoseByName, BatchNr, invReqQty, invReqDoses)));
        return JSON.serialize(new RecordWrapper(totalBoxByName, totalDoseByName, BatchNr, invReqQty, invReqDoses));
    }


    public class RecordWrapper
    {
        @AuraEnabled public Integer totBoxByNam {set;get;}
        @AuraEnabled public Integer totalDoseName {set;get;}
        @AuraEnabled public String batchNumber {set;get;}
        @AuraEnabled public Integer InvRequiredQty {set;get;}
        @AuraEnabled public Integer inventoryReqDose {set;get;}
        public RecordWrapper(Integer totBoxByNam, Integer totalDoseName, String batchNumber, Integer InvRequiredQty, Integer inventoryReqDose)
        {
            this.totBoxByNam = totBoxByNam;
            this.totalDoseName = totalDoseName;
            this.batchNumber = batchNumber;
            this.InvRequiredQty = InvRequiredQty;
            this.inventoryReqDose = inventoryReqDose;
        }
    }
}