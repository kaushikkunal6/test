public  with sharing class AITM_customLookupController {

    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        String sQuery;
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 
        if(ObjectName == 'AITM_Pricing_Basis__c')  
        {
        sQuery =  'select id, Name,AITM_Description__c from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC LIMIT 100';
        }
        else{
           sQuery  =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC LIMIT 100';
        }
            List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        system.debug('list of records-->' + returnList);
        return returnList;
    }
}