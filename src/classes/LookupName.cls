/**
 * Created by Adelchi on 24/04/2018.
 */

/**
 * Created by Adelchi on 27/12/2017.
 */

public class LookupName {

    /**
     * Returns JSON of list of ResultWrapper to Lex Components
     * @objectName - Name of SObject
     * @fld_API_Val - API name of field to be returned by Lookup COmponent
     * @lim   - Total number of record to be returned
     * @fld_API_Search - API name of field to be searched
     * @searchText - text to be searched
     * */
    @AuraEnabled
    public static String searchDB(String objectName, String fld_API_Text, Integer lim, String fld_API_Search, String searchText ){
        String contactUserId = [SELECT ContactId FROM User WHERE Id =: userInfo.getUserId() LIMIT 1].ContactId;
        Contact c = [SELECT Id, Site__c, Contract_Employer__c FROM Contact WHERE Id =: contactUserId];
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
        system.debug('fld_API_Text>> '+fld_API_Text);
        system.debug('objectName >>> '+objectName);
        system.debug('fld_API_Search  >> '+fld_API_Search);
        system.debug('searchText >> '+searchText);
        system.debug('c.Site__c >> '+c.Site__c);
        system.debug('limit >> '+lim);

        String query = 'SELECT '+ fld_API_Text+
                ' FROM '+objectName+
                ' WHERE '+fld_API_Search+
                ' LIKE '+searchText+' AND Site__c = '+c.Site__c+' LIMIT '+lim;



        List<sObject> sobjList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();

        for(SObject s : sobjList){
            ResultWrapper obj = new ResultWrapper();
            obj.objName = objectName;
            obj.text = String.valueOf(s.get(fld_API_Text)) ;
            lstRet.add(obj);
        }
        system.debug(JSON.serialize(lstRet));
        return JSON.serialize(lstRet) ;
    }

    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
    }
}