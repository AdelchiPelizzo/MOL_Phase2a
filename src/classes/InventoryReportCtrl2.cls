/**
 * Created by Adelchi on 08/05/2018.
 */

public with sharing class InventoryReportCtrl2 {
    /* Start - Variables */
    public List<String> lstHeaders                  	{set;get;}//list to hold names of the headers
    public List<String> lstFieldAPINames            	{set;get;}//list to hold the api names of the fields that needs to be displayed on page
    public List<RecordWrapper> lstRecordWrapper     	{set;get;}//list to hold wrapper class objects to show on the page.
    public String strObjectId                       	{get;set;}//Id of the element that needs to be deleted
    public Boolean isRender								{get;set;}//flag variable to hold the status of rendering
    public Boolean isEditable							{get;set;}//flag variable to hold the status of checkboxes
    public String ContactId								{get;set;}//variable to hold contact id
    /* End - Variables */

    /*Start - Class Variables */
    private static final String ACTIVE_STATUS	= 'Active';//this variable is used to show the active status for fund of interest object record
    private String strContactName;
    /*End - Class Variables */

    /* Start - Constructor */
    public InventoryReportCtrl2()
    {
        //Do  Nothing
    }
    /* End - Constructor */

    /**
           * @ClassName      : RecordWrapper
           * @parameter      : NA
           * @Description    : This class is used to contain the sobject records and their type to show on the Inventory report page
       */


    public static List<reportRecord> getList (){
        List<Inventory__c> i = [SELECT Name, Batch_Number__c FROM Inventory__c];
        List<reportRecord> repRList = new List<reportRecord>();
        for(Inventory__c inv : i){
            repRList.add(new reportRecord(i.Name, i.Batch_Number__c));
        }
        return i;

    }

    public class reportRecord {
        public String Name {get;set;}
        public String BatchNr {get;set;}
        public Integer totalBoxByName {get;set;}
        public Integer totalDoseByName {get;set;}
        public String BatchNr {get;set;}
        public Integer invReqQty {get;set;}
        public Integer invReqDoses {get;set;}

        public reportRecord(String Name, String BatchNr){
            this.Name = Name;
            this.BatchNr = BatchNr;
            RecordWrapper rw = getRecordWrapper(Name, BatchNr);
            this.totalBoxByName = rw.totBoxByNam;
            this.totalDoseByName = rw.totalDoseName;
            this.invReqQty = rw.InvRequiredQty;
            this.invReqQty = rw.inventoryReqDose;
        }
    }

    @AuraEnabled
    public static RecordWrapper getRecordWrapper(String Name, String BatchNr){
        String userId = userInfo.getUserId();
        String contactId = [SELECT ContactId FROM User WHERE Id =: userId LIMIT 1].ContactId;
        String siteId = [SELECT Site__c FROM Contact WHERE Id =: contactId LIMIT 1].Site__c;
        List<RecordWrapper> lstRecords = new List<RecordWrapper>();
        Integer totalBoxByName = 0;
        Integer totalDoseByName = 0;
        String irId = '';
        List<Inventory__c> inventoryList = [SELECT Name, Total_Doses__c, Inventory_required__c FROM Inventory__c WHERE SiteName__c =: siteId AND Available__c = True AND Name = : Name AND Batch_Number__c =: BatchNr];
        for(Integer i=0; i<inventoryList.size(); i++){
            totalBoxByName = + (Integer)inventoryList[i].Total_Doses__c;
            totalDoseByName = + 1;
        }
        irId = inventoryList[0].Inventory_required__c;
        Inventory_Required__c inventoryReq = [SELECT Name, Quantity_Required__c, Total_Doses_Required__c FROM Inventory_Required__c  WHERE Id =: irId ];
        Integer invReqQty = (Integer)inventoryReq.Quantity_Required__c;
        Integer invReqDoses = (Integer)inventoryReq.Total_Doses_Required__c;
        return new RecordWrapper(totalBoxByName, totalDoseByName, BatchNr, invReqQty, invReqDoses);
    }

    public class RecordWrapper
    {
        public Integer totBoxByNam {set;get;}
        public Integer totalDoseName {set;get;}
        public String batchNumber {set;get;}
        public Integer InvRequiredQty {set;get;}
        public Integer inventoryReqDose {set;get;}
        public RecordWrapper(Integer totBoxByNam, Integer totalDoseName, String batchNumber, Integer InvRequiredQty, Integer inventoryReqDose)
        {
            this.totBoxByNam = totBoxByNam;
            this.totalDoseName = totalDoseName;
            this.batchNumber = batchNumber;
            this.InvRequiredQty = InvRequiredQty;
            this.inventoryReqDose = inventoryReqDose;
        }
    }

    /**
           * @Name         : getRecords
           * @parameter    : Field set name, sobject name
           * @Description  : This method is used to frame soql and retrieve the records from corresponding sobject and fill the wrapper class objects accordingly.
       */
    private List<RecordWrapper> getRecords(String strFieldSetName, String strSobjectName, String strType)
    {
        List<RecordWrapper> lstRecords = new List<RecordWrapper>();
        Schema.FieldSet objFieldSet = Schema.getGlobalDescribe().get(strSobjectName).getDescribe().FieldSets.getMap().get(strFieldSetName);
        String strQuery = 'SELECT Id,';
        try
        {
            //Iterating over field set member object to fill the header list and field api list
            for(Schema.FieldSetMember objFieldSetMember : objFieldSet.getFields())
            {
                if(strType == 'Investor Contact' && objFieldSetMember.getFieldPath()!='Investment__c')
                {
                    lstHeaders.add(objFieldSetMember.getLabel());
                    lstFieldAPINames.add(objFieldSetMember.getFieldPath());
                }
                strQuery+=objFieldSetMember.getFieldPath() +',';
            }
            strQuery = strQuery.substring(0,strQuery.length()-1);
            strQuery+=' FROM '+strSobjectName;
            strQuery+= strSobjectName == 'Investor_Contact__c' ? ' WHERE Contact__c =: ContactId' : ' WHERE Contact__c =: ContactId AND Status__c=:ACTIVE_STATUS';

            //Iterating over records to fill the wrapper class list to bind with the page
            for(Sobject objSobject : Database.query(strQuery))
            {
                lstRecords.add(new RecordWrapper(objSobject, strType, strSobjectName));
            }
        }
        catch(Exception ex)
        {
            System.debug('================'+ex.getMessage()+'======================'+ex.getLineNumber());
        }
        return lstRecords;
    }

    /**
            * @Name         : saveRecords
            * @parameter    : -
            * @Description  : This method is used to save the records updated on the page side
        */
    public void saveRecords()
    {
        List<Sobject> lstSobject = new List<Sobject>();//list to hold the objects that needs to be updated
        try
        {
            //Iterating over record wrapper list to collect the objects into a list to update them.
            for(RecordWrapper objRecordWrapper : lstRecordWrapper)
            {
                lstSobject.add(objRecordWrapper.objSobject);
            }
            update lstSobject;
            isEditable = false;
        }
        catch(Exception ex)
        {
            System.debug('================='+ex.getMessage());
        }
    }

    /**
            * @Name         : editRecords
            * @parameter    : -
            * @Description  : This method is used to enable the checkboxes on click of edit button
        */
    public void editRecords()
    {
        isEditable = true;
    }

    /**
           * @Name         : redirectFundOfInterest
           * @parameter    : -
           * @Description  : This method is used to redirect the standard New Fund of Interest page.
       */
    public Pagereference redirectFundOfInterest()
    {
        return new Pagereference('/a0u/e?CF00NL0000003IwZg='+strContactName+'&CF00NL0000003IwZg_lkid='+ContactId+'&saveURL='+ContactId+'&retURL='+ContactId);
    }

    /**
            * @Name         : redirectInvestorContact
            * @parameter    : -
            * @Description  : This method is used to redirect the standard New Investor Contact page.
        */
    public Pagereference redirectInvestorContact()
    {
        return new Pagereference('/a03/e?CF00Ni000000DjVDG='+strContactName+'&CF00Ni000000DjVDG_lkid='+ContactId+'&saveURL='+ContactId+'&retURL='+ContactId);
    }

    /**
           * @Name         : deleteRecords
           * @parameter    : -
           * @Description  : This method is used to delete a particular record based on its Id.
       */
    public void deleteRecords()
    {
        //creating new object record
        sobject objSobject = Schema.getGlobalDescribe().get(String.valueOf(Id.valueOf(strObjectId).getSobjectType())).newSObject();
        objSobject.put('Id', strObjectId);
        delete objSobject;//deleting the sobject
        initializeElements();//initializing the elements
    }

    /**
           * @Name         : initializeElements
           * @parameter    : -
           * @Description  : This method is used to initialize the elements.
       */
    public void initializeElements()
    {
        isRender = true;
        lstHeaders = new List<String>{'Name'};
        lstFieldAPINames = new List<String>();
        lstRecordWrapper = new List<RecordWrapper>();
        lstRecordWrapper = getRecords('SL_InvestorContactFieldSet', 'Investor_Contact__c', 'Investor Contact');//calling function for investor contact object
        lstRecordWrapper.addAll(getRecords('SL_FundOfInterestFieldSet', 'Fund_of_Interest__c', 'Fund Of Interest'));//calling function for fund of interest object
        strContactName = [SELECT Name FROM Contact WHERE Id=:ContactId].Name;
        if(lstRecordWrapper.isEmpty())
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,'No Records to display.'));
    }
}