/*************************************************************************
 * @author         srnandan
 * @date           01/January/2019
 * @group          AirBP
 * @description    controller class used for lightning sharing component and sharing records

 * history
 * 01/January/2019  srnandan       Created
 * 28/February/2019 srnandan      Modified - AR-XXXX added methods for delegates grant and revoke permissions
 * 								  to run the delete tender location line item share and insert tender location line item share 
 * 								  in batch when the the number of records exceeds governor limit
 *************************************************************************/
global without sharing class AITM_LightningSharing {

    global without sharing class SharingPermsException extends Exception{}

    @AuraEnabled
    public static String sayMyName(Id recordId){
        String nameField;

        Schema.SObjectType token = recordId.getSObjectType();
        for (Schema.SObjectField dfr:token.getDescribe().fields.getMap().values()){
            if (dfr.getDescribe().isNameField()){
                nameField = dfr.getDescribe().getName();
            }
        }
        String query = 'select ' + nameField + ' from ' + recordId.getSObjectType() + ' where id = \'' + recordId + '\'';
        
        recordStuff rs = new recordStuff();
        rs.recordName = String.valueOf(Database.query(query)[0].get(nameField));
        rs.objectType = String.valueOf(recordId.getSObjectType().getDescribe().getLabel());

        return JSON.serialize(rs);

    }

    without sharing class recordStuff {
        String recordName {get;set;}
        String objectType {get;set;}
    }

    @AuraEnabled
    global static boolean canIEditPerms(Id recordId){
        try {
            String query = 'SELECT RecordId, HasDeleteAccess, HasAllAccess FROM UserRecordAccess WHERE RecordId = \'' + String.escapeSingleQuotes(String.valueOf(recordId)) + '\' AND UserId = \'' + UserInfo.getUserId() + '\'';
            sObject o = Database.query(query);
            if ((Boolean)o.get('HasDeleteAccess') || (Boolean)o.get('HasAllAccess')){
                
                return true;
            }
        } catch (System.queryException e){
            //it's possible you can't even see that record and the queries are null!
            return false;
        }
        return false;
    }

    @AuraEnabled
    global static void deletePerm(Id UserOrGroupID, Id recordId){
        //access check
        Schema.DescribeSObjectResult describe = getSharingDescribe(recordId);

        //can I delete the sharing objects?
        if (!describe.isDeletable() || !describe.isAccessible()){
            throw new AuraHandledException(Label.AITM_LackingPermissions);
        }

        String query = buildQuery(recordId);
        query = query + ' and UserOrGroupID =\''+String.escapeSingleQuotes(UserOrGroupID)+'\'';
        

        list<sObject> existing = database.query(query);
        
        delete existing;

    }

    @AuraEnabled
    global static String upsertPerm (Id UserOrGroupID, Id recordId, String level){

        Schema.DescribeSObjectResult describe = getSharingDescribe(recordId);
        level = String.escapeSingleQuotes(level);

        
        if (!canIEditPerms(recordId)){
            throw new AuraHandledException(Label.AITM_OwnerAdminModify);
        }


        // special handling for role => groups
        if (UserOrGroupID.getSobjectType()==Schema.UserRole.SObjectType){
            //it's a role...find the matching group?
            list<group> matchingGroups = [select id, name, type from group where RelatedId =: UserOrGroupID and type = 'Role'];
            if (matchingGroups.size()>1){
                throw new AuraHandledException(Label.AITM_MultipleGroupsForRole);
            }
            UserOrGroupID = matchingGroups[0].Id;
        }


        String query = buildQuery(recordId);
        query = query + ' and UserOrGroupID =\''+String.escapeSingleQuotes(String.valueOf(UserOrGroupID))+'\'';

        list<sObject> existing = database.query(query);
        String sobj = objectTypeFromId(recordId);

        if (existing.size() > 0){
            //can I update this thing?

            if (!describe.isUpdateable() ||
                !describe.fields.getMap().get(getAccessLevelField(sobj)).getDescribe().isUpdateable()
                ){
                throw new AuraHandledException(Label.AITM_OwnerAdminModify);
            }

            existing[0].put(getAccessLevelField(sobj), level);
            update existing;
            return JSON.serialize(existing);
            } else {
                //are we even allowed to insert this?  for these specific fields that we'll set?
                if (!describe.isCreateable() ||
                        !describe.fields.getMap().get(getAccessLevelField(sobj)).getDescribe().isCreateable() ||
                        !describe.fields.getMap().get(getLookupField(sobj)).getDescribe().isCreateable() ||
                        !describe.fields.getMap().get('UserOrGroupId').getDescribe().isCreateable()
                     ){
                    throw new AuraHandledException(Label.AITM_OwnerAdminModify);
                }
                //create a new SObject dynamically and insert
                Schema.SObjectType newObj = Schema.getGlobalDescribe().get(getSharingTableName(sobj));
                sobject share = newObj.newSObject();

                share.put(getAccessLevelField(sobj), level);
                share.put(getLookupField(sobj), recordId);
                share.put('UserOrGroupId', String.escapeSingleQuotes(String.valueOf(UserOrGroupID)));

                if (objectTypeFromId(recordId)=='Account'){
                    //share.put('ContactAccessLevel', level);
                    share.put('CaseAccessLevel', level);
                    share.put('OpportunityAccessLevel', level);
                }

                insert share;
                return JSON.serialize(share);
            }
        //return null;
    }
    
    global static void grantPermissionForDelegates(List<User> userList, Id recordId, String level){
		if(userList.size()>0){
        Schema.DescribeSObjectResult describe = getSharingDescribe(recordId);
        level = String.escapeSingleQuotes(level);

        /*if (!canIEditPerms(recordId)){
            throw new AuraHandledException(Label.AITM_OwnerAdminModify);
        }*/
        String sobj = objectTypeFromId(recordId);
        //are we even allowed to insert this?  for these specific fields that we'll set?
        if (!describe.isCreateable() ||
                !describe.fields.getMap().get(getAccessLevelField(sobj)).getDescribe().isCreateable() ||
                !describe.fields.getMap().get(getLookupField(sobj)).getDescribe().isCreateable() ||
                !describe.fields.getMap().get('UserOrGroupId').getDescribe().isCreateable()
                ){
            throw new AuraHandledException(Label.AITM_OwnerAdminModify);
        }
        //create a new SObject dynamically and insert
        List<sobject> sobjectList = new List<sobject>();
        Schema.SObjectType newObj = Schema.getGlobalDescribe().get(getSharingTableName(sobj));
        for(User user : userList) {            
            sobject share = newObj.newSObject();
            share.put(getAccessLevelField(sobj), level);
            share.put(getLookupField(sobj), recordId);
            share.put('UserOrGroupId', String.escapeSingleQuotes(String.valueOf(user.Id)));
            share.put('RowCause','Sharing_To_Pricing_Delegates__c');

            /*if(sobj =='Account'){
                //share.put('ContactAccessLevel', level);
                share.put('CaseAccessLevel', level);
                share.put('OpportunityAccessLevel', level);
            }*/
            sobjectList.add(share);
        }
        
        INSERT sobjectList;
    }
	}

        global static void revokePermissionForDelegates(Id recordId, String rowCause){
            String query = buildQueryDelegates(recordId);
            query = query + ' and RowCause =\''+String.escapeSingleQuotes(rowCause)+'\'';
            list<sObject> existing = database.query(query);
            Database.DeleteResult[] results = Database.delete(existing,false);
        }


    global static void revokePermissionForDelegates(List<Id> tenderLocationLineItem, String rowCause){
        if(!tenderLocationLineItem.isEmpty()) {
            String query = buildQueryDelegates(tenderLocationLineItem[0]);
            query = query + ' and RowCause =\''+String.escapeSingleQuotes(rowCause)+'\'';
            List<sObject> existing = database.query(query);
            if (existing.size() > Limits.getLimitDMLRows()){               
                //call apex batch job to delete records
                AITM_DeleteTLLineItemsShareBatch.BatchState batchState = new AITM_DeleteTLLineItemsShareBatch.BatchState(existing);
                new AITM_DeleteTLLineItemsShareBatch.BatchFactory().executeBatch(batchState);
            } else {
                Database.DeleteResult[] results = Database.delete(existing,false); 
            }        
        }
    }

    global static void grantPermissionForDelegates(Map<Id, Set<String>> lineItemsMap, String level){
        if(lineItemsMap.size() > 0) {
            List<Id> recordIds = new List<Id>();
            recordIds.addAll(lineItemsMap.keyset());
            
            Schema.DescribeSObjectResult describe = getSharingDescribe(recordIds[0]);
            level = String.escapeSingleQuotes(level);
    
            /*if (!canIEditPerms(recordId)){
                throw new AuraHandledException(Label.AITM_OwnerAdminModify);
            }*/
                   
            String sobj = objectTypeFromId(recordIds[0]);
            //are we even allowed to insert this?  for these specific fields that we'll set?
            if (!describe.isCreateable() ||
                    !describe.fields.getMap().get(getAccessLevelField(sobj)).getDescribe().isCreateable() ||
                    !describe.fields.getMap().get(getLookupField(sobj)).getDescribe().isCreateable() ||
                    !describe.fields.getMap().get('UserOrGroupId').getDescribe().isCreateable()
                    ){
                //throw new AuraHandledException(Label.AITM_OwnerAdminModify);
            }
            //create a new SObject dynamically and insert
            List<sobject> sobjectList = new List<sobject>();
            Schema.SObjectType newObj = Schema.getGlobalDescribe().get(getSharingTableName(sobj));
            for(Id recordId : lineItemsMap.keyset()) { 
            for(String user :lineItemsMap.get(recordId)) {                
                sobject share = newObj.newSObject();
                share.put(getAccessLevelField(sobj), level);
                share.put(getLookupField(sobj), recordId);
                share.put('UserOrGroupId', String.escapeSingleQuotes(user));
                share.put('RowCause','Sharing_To_Pricing_Delegates__c');
                sobjectList.add(share);
    
                /*if (sobj=='Account'){
                    //share.put('ContactAccessLevel', level);
                    share.put('CaseAccessLevel', level);
                    share.put('OpportunityAccessLevel', level);
                }*/
                
            }
          }
            
            INSERT sobjectList;
        }
    }

    global static void grantPermissionForDelegatesWithID(Map<String,String> lineItemsMap, String level){
        if(lineItemsMap.size() > 0) {
             List<String> recordIds = new List<String>();
             recordIds.addAll(lineItemsMap.keyset());  
                       
        Schema.DescribeSObjectResult describe = getSharingDescribe(recordIds[0].substringBefore('/'));
        level = String.escapeSingleQuotes(level);      
                
        String sobj = objectTypeFromId(recordIds[0].substringBefore('/'));            
        List<sobject> sobjectList = new List<sobject>();
        Schema.SObjectType newObj = Schema.getGlobalDescribe().get(getSharingTableName(sobj));
            for(String recordId :lineItemsMap.keyset()) {                
               String lineItemId = recordId.substringBefore('/');
               String userId = recordId.substringAfter('/'); 
                 if(userId!=null){
                    sobject share = newObj.newSObject(); 
                    share.put(getAccessLevelField(sobj), level);
                    share.put(getLookupField(sobj), lineItemId); 
                    share.put('UserOrGroupId', String.escapeSingleQuotes(userId)); 
                    share.put('RowCause','Sharing_To_Pricing_Delegates__c');       
            
            sobjectList.add(share);
           }
        }
        if (sobjectList.size() > Limits.getLimitDMLRows()){               
                //call apex batch job to insert records                
                AITM_InsertTLLineItemsShareBatch.BatchState batchState = new AITM_InsertTLLineItemsShareBatch.BatchState(sobjectList);
                new AITM_InsertTLLineItemsShareBatch.BatchFactory().executeBatch(batchState);
            } else {                
                INSERT sobjectList;
            }    
     }

   }



    @AuraEnabled(cacheable=true)
    global static String doSOSL(String searchString, String objectType){
        
        searchString = String.escapeSingleQuotes(searchString);
        objectType = String.escapeSingleQuotes(objectType);

        //check CRUD/FLS
        //what object is this?
        Schema.DescribeSObjectResult describe = Schema.getGlobalDescribe().get(objectType).getDescribe();
        //can I query?
        if (!describe.isQueryable() || !describe.isAccessible()){
            throw new AuraHandledException(Label.AITM_LackingPermissions);
        }

        Map<String, Schema.SObjectField> fieldMap = describe.fields.getMap();
        for (Schema.SObjectField field:fieldMap.values()){
            if (field.getDescribe().isNameField()){
                if (!field.getDescribe().isAccessible()){
                    throw new AuraHandledException(Label.AITM_LackingPermissions);
                }
            }
        }

        // limit rows returned for performance reasons
        String sosl = 'FIND \'*' + searchString + '*\' IN NAME FIELDS RETURNING ' + getReturning(objectType) + ' limit 200';
        list<list<sobject>> results = search.query(sosl);

        list<sObject> output = new list<sobject>();
        for (list<sObject> result:results){
            output.addAll(result);
        }

        return JSON.serialize(output);
    }

    @TestVisible
    private static String getReturning (String objectType){
        //assert that we can use these fields as the current user
        if (!User.Id.getDescribe().isAccessible() ||
              !User.Name.getDescribe().isAccessible() ||
              !User.UserType.getDescribe().isAccessible() ||
              !Group.Id.getDescribe().isAccessible() ||
              !Group.Name.getDescribe().isAccessible()
            ){
            throw new AuraHandledException(Label.AITM_LackingPermissions);
        }


        //filter out user types that don't have sharing!
        if (objectType == 'User'){
            return 'User(Id, Name, UserType WHERE UserType in (\'Standard\', \'PowerCustomerSuccess\', \'PowerPartner\'))';
        }
        if (objectType == 'Group'){
            return objectType + '(Id, Name, Type)';
        } else {
            return objectType + '(Id, Name)';
        }
    }



    @AuraEnabled
    global static String objectTypeFromId(Id recordId){
        Schema.SObjectType token = recordId.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        return dr.getName();
    }
    
    @AuraEnabled
    global static String getSharings(Id recordId){
    
        if (!sharingExists(objectTypeFromId(recordId))){
            throw new AuraHandledException(Label.AITM_OWDReadWrite);
        }
    
        list<sObject> results = database.query(buildQuery(recordId));
        list<sharingHolder> output = new list<sharingHolder>();
    
        set<id> groupAndUserIDs = new set<id>();
        set<id> RoleIds = new set<id>();
    
        for (sobject so:results){
            sharingHolder sh = new sharingHolder();
            sh.RowCause = String.valueOf(so.get('RowCause'));
            sh.AccessLevel = String.valueOf(so.get(getAccessLevelField(objectTypeFromId(recordId))));
            sh.UserOrGroupID = String.valueOf(so.get('UserOrGroupID'));
            groupAndUserIDs.add(sh.UserOrGroupID);
            output.add(sh);
        }
    
        if (!User.Id.getDescribe().isAccessible() ||
                  !User.Name.getDescribe().isAccessible() ||
                  !User.UserType.getDescribe().isAccessible() ||
                  !Group.Id.getDescribe().isAccessible() ||
                  !Group.Name.getDescribe().isAccessible() ||
                  !Group.Type.getDescribe().isAccessible()
                ){
                throw new AuraHandledException(Label.AITM_LackingPermissions);
            }
        map<Id, User> UserMap = new map<Id, User>([Select Name, UserType from User where Id in: groupAndUserIDs]);
        map<Id, Group> GroupMap = new map<Id, Group>([Select Name, Type, RelatedId from Group where Id in: groupAndUserIDs]);
        for (group g:GroupMap.values()){
            if (g.RelatedId != null){
                RoleIds.add(g.RelatedId);
            }
        }
        map<Id, UserRole> RoleMap = new map<Id, UserRole>([Select Name from UserRole where Id in: RoleIDs]);
    
        for (sharingHolder sh:output){
            if (UserMap.get(sh.UserOrGroupID)!=null){
                //it's a user
                sh.UserOrGroupType = 'User';
                sh.UserOrGroupName = UserMap.get(sh.UserOrGroupID).Name;
                sh.SubType = huh(UserMap.get(sh.UserOrGroupID).UserType);
                } else if (GroupMap.get(sh.UserOrGroupID)!=null){
                    sh.UserOrGroupType = 'Group';
                    sh.SubType = GroupMap.get(sh.UserOrGroupID).Type;
                    sh.UserOrGroupName = GroupMap.get(sh.UserOrGroupID).Name;
                    //special handling for roles
                    if (sh.SubType.contains('Role')){
                        sh.UserOrGroupName = RoleMap.get(GroupMap.get(sh.UserOrGroupID).RelatedId).Name;
                    }
                }
            }
    
            return JSON.serialize(output);
    }
    
    @TestVisible private static String buildQuery(Id recordId){
        String sobj = objectTypeFromId(recordId);
        schema.DescribeSObjectResult describe = getSharingDescribe (recordId);
		
        if (!describe.isAccessible() ||
              !describe.fields.getMap().get('Id').getDescribe().isAccessible() ||
              !describe.fields.getMap().get('RowCause').getDescribe().isAccessible() ||
              !describe.fields.getMap().get('UserOrGroupId').getDescribe().isAccessible() ||
              !describe.fields.getMap().get(getAccessLevelField(sobj)).getDescribe().isAccessible() ||
              !describe.fields.getMap().get(getLookupField(sobj)).getDescribe().isAccessible()
              ){
            //throw new AuraHandledException(Label.AITM_LackingPermissions);
        }

        String query = 'select Id, RowCause, UserOrGroupId, ' +getAccessLevelField(sobj)+ ' from ' +getSharingTableName(sobj)+ ' where ' + getLookupField(sobj)+ ' = \'' + String.escapeSingleQuotes(String.valueOf(recordId)) + '\'';
        
        return query;
    }

    @TestVisible private static String buildQueryDelegates(Id recordId){
        String sobj = objectTypeFromId(recordId);       
        String query = 'select Id, RowCause, UserOrGroupId, ' +getAccessLevelField(sobj)+ ' from ' +getSharingTableName(sobj)+ ' where ' + getLookupField(sobj)+ ' = \'' + String.escapeSingleQuotes(String.valueOf(recordId)) + '\'';
        return query;
    }

    @TestVisible private static String huh(String userType){
        if (userType == 'PowerCustomerSuccess') {return 'Customer Plus (with Sharing)';}
        else if (userType == 'PowerPartner') {return 'Partner';}
        else if (userType == 'CustomerSuccess') {return 'Customer';}
        else if (userType == 'CsnOnly') {return 'Chatter';}
        else if (userType == 'CSPLitePortal') {return 'High Volume Customer';}
        else {return userType;}
    }

    global without sharing class sharingHolder {
        global String UserOrGroupName {get;set;}
        global String SubType {get;set;}
        global String UserOrGroupType {get;set;}
        global String UserOrGroupID {get;set;}
        global String AccessLevel {get;set;}
        global String RowCause {get;set;}
    }

    private static boolean isStandard (String sobj){
        if (sobj=='Account' || sobj=='Asset' || sobj=='Campaign' || sobj =='Case' || sobj=='Contact' || sobj=='Lead' || sobj=='Opportunity' || sobj=='User' ){
            return true;
        }
        return false;
    }

    @TestVisible
    private static String getLookupField (String sobj){
        if (isStandard(sobj)){
            return sobj + 'Id';
        } else {
            return 'ParentId';
        }
    }

    @TestVisible
    private static String getAccessLevelField (String sobj){
        
        if (isStandard(sobj)){
            
            return sobj + 'AccessLevel';
        } else {
            
            return 'AccessLevel';
        }
    }

    @TestVisible
    private static String getSharingTableName (String sobj){
        if (sobj.contains('__c')){
            return sobj.replace('__c','__Share');
        } else {
            return sobj+'Share';
        }
    }

    @TestVisible
    private static schema.DescribeSObjectResult getSharingDescribe (Id recordId){
        try{
            String sharingName = getSharingTableName(objectTypeFromId(recordId));
            return Schema.getGlobalDescribe().get(sharingName).getDescribe();
        } catch (exception e){
            //probably means they don't have sharing turned on for this object
            throw new AuraHandledException(Label.AITM_OWDReadWrite);
        }
    }

    @TestVisible
    private static boolean sharingExists(String sobj){
        //custom objects
        if (sobj.contains('__c')){
            Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
            if (  tokens.containsKey( getSharingTableName(sobj) ) || tokens.containsKey('ltngsharing__' + getSharingTableName(sobj)) ) {
                return true;
            }
        } else {
            String tableName = getSharingTableName(sobj);
            String query = 'select count() from ' + tableName;
            try {
                integer count = database.countQuery(query);
                if (count > 0) {
                    return true;
                } else {
                    return false;
                }
            } catch (exception e){
                return false;
            }
            
        }

        return false;
    }

}