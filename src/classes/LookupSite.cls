/**
 * Created by Adelchi on 25/04/2018.
 */
public class LookupSite {

    /**
     * Returns JSON of list of ResultWrapper to Lex Components
     * @objectName - Name of SObject
     * @fld_API_Text - API name of field to display to user while searching
     * @fld_API_Val - API name of field to be returned by Lookup COmponent
     * @lim   - Total number of record to be returned
     * @fld_API_Search - API name of field to be searched
     * @searchText - text to be searched
     * */
    @AuraEnabled
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val,
            Integer lim,String fld_API_Search,String searchText ){

        String contactUserId = [SELECT ContactId FROM User WHERE Id =: userInfo.getUserId() LIMIT 1].ContactId;
        Contact c = [SELECT Id, Site__c, Contract_Employer__c FROM Contact WHERE Id =: contactUserId];
        String AccountId = c.Contract_Employer__c;

        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';


        String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val+
                ' FROM '+objectName+
                ' WHERE '+fld_API_Search+' LIKE '+searchText+' AND Account__c = '+AccountId+
                ' LIMIT '+lim;

        List<sObject> sobjList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();

        for(SObject s : sobjList){
            ResultWrapper obj = new ResultWrapper();
            obj.objName = objectName;
            obj.text = String.valueOf(s.get(fld_API_Text)) ;
            obj.val = String.valueOf(s.get(fld_API_Val))  ;
            lstRet.add(obj);
        }
        system.debug(JSON.serialize(lstRet));
        return JSON.serialize(lstRet) ;
    }

    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String val{get;set;}
    }
}