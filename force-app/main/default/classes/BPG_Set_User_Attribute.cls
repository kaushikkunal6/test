/******************************************************************************************
 *  Date          : 26-DEC-2019
 *  Author        : Sunny Yap
 *  Description   : Assign attributes to user based on public group assignment.
 *  Modifications : 26-DEC-2019 SYAP - Initial
 *****************************************************************************************/
 
public with sharing class BPG_Set_User_Attribute implements Database.Batchable<sObject> {
    private string query = 'SELECT Id FROM User where LastModifiedDate = LAST_N_DAYS:1 and Profile.UserType = \'Standard\'';
    private string queryTest = 'SELECT Id FROM User where LastModifiedDate = LAST_N_DAYS:1 and Profile.UserType = \'Standard\' limit 150';
 
 /******************************************************************************************
  * Standard Method In Batchable Class
  *****************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        if (Test.isRunningTest()){
            return Database.getQueryLocator(queryTest);
		}
        else {
        	return Database.getQueryLocator(query);
        }
    }

 /******************************************************************************************
  * Calls Helper Class - Pass In User List
  *****************************************************************************************/    
    public void execute (Database.BatchableContext bc, List<User> users) {
      doAssignment(users);
    }

 /******************************************************************************************
  * Helper Class Isolated - Ease Invocation From Test Classes
  *****************************************************************************************/
    public void doAssignment(List<User> users) {
      // Create User Id > Group List Map
      Map<Id, List<String>> userGroupMap = new Map<Id, List<String>>();
      try {
        // Get User List
        List<Id> userIdList = new List<Id>();
        for (User thisUser : users) {
          userIdList.add(thisUser.Id);
        }
      
        // Get Distinct Group DeveloperName
        Map<String, GroupMember> groupMap = new Map<String, GroupMember>();
        List<GroupMember> members = [select Group.DeveloperName, UserOrGroupId from GroupMember where UserOrGroupId in :userIdList and Group.Type = 'Regular'];
        for (GroupMember thisMember : members) {
          List<String> groupList = null;
          if (!userGroupMap.containsKey(thisMember.UserOrGroupId)) {
            groupList = new List<String>();
            userGroupMap.put(thisMember.UserOrGroupId, groupList);
          }
          else {
            groupList = userGroupMap.get(thisMember.UserOrGroupId);
          }
          groupList.add(thisMember.Group.DeveloperName);
          groupMap.put(thisMember.Group.DeveloperName, null);
        }
      
        // Retrieve Custom Metadata (Flat)
        List<BPG_User_Attribute__mdt> metadataList = [
          select
            BPG_Object_Name__c,
            BPG_Field_Name__c,
            BPG_Field_Value_Type__c,
            BPG_Field_Value__c
          from
            BPG_User_Attribute__mdt
          where
            BPG_Object_Type__c = 'Public Group' and
            BPG_Object_Name__c in :groupMap.keySet()
          order by
            BPG_Sequence__c desc
        ];

        // Store Custom Metadata (Hierarchy)
        // Object Name (Level 1) > Actual Field Mapping
        Map<String, Map<String, Boolean>> mainBooleanMap = new Map<String, Map<String, Boolean>>();
        Map<String, Map<String, String>> mainTextMap = new Map<String, Map<String, String>>();
        for (BPG_User_Attribute__mdt thisMetadata : metadataList) {
          // Construct Boolean Map
          Map<String, Boolean> booleanMap = null;
          if (!mainBooleanMap.containsKey(thisMetadata.BPG_Object_Name__c)) {
            booleanMap = new Map<String, Boolean>();
            mainBooleanMap.put(thisMetadata.BPG_Object_Name__c, booleanMap);
          }
          else {
            booleanMap = mainBooleanMap.get(thisMetadata.BPG_Object_Name__c);
          }

          // Construct Text Map
          Map<String, String> textMap = null;
          if (!mainTextMap.containsKey(thisMetadata.BPG_Object_Name__c)) {
            textMap = new Map<String, String>();
            mainTextMap.put(thisMetadata.BPG_Object_Name__c, textMap);
          }
          else {
            textMap = mainTextMap.get(thisMetadata.BPG_Object_Name__c);
          }
        
          // Create User Field > User Field Value Pair
          if (thisMetadata.BPG_Field_Value_Type__c == 'Text') {
            textMap.put(thisMetadata.BPG_Field_Name__c, thisMetadata.BPG_Field_Value__c);
          }
          else
          if (thisMetadata.BPG_Field_Value_Type__c == 'Boolean') {
            boolean booleanValue = thisMetadata.BPG_Field_Value__c == 'true' ? true : false;
            booleanMap.put(thisMetadata.BPG_Field_Name__c, booleanValue);
          }
        }
           
        // Assign User Attributes
        for (User thisUser : users) {
          if (userGroupMap.containsKey(thisUser.Id)) {
            List<String> groupList = userGroupMap.get(thisUser.Id);
            for (String groupName : groupList) {
              if (mainBooleanMap.containsKey(groupName)) {
                Map<String, Boolean> booleanMap = mainBooleanMap.get(groupName);
                for (String fieldName : booleanMap.keySet()) {
                  thisUser.put(fieldName, booleanMap.get(fieldName));
                }
              }
              if (mainTextMap.containsKey(groupName)) {
                Map<String, String> textMap = mainTextMap.get(groupName);
                for (String fieldName : textMap.keySet()) {
                  thisUser.put(fieldName, textMap.get(fieldName));
                }
              }
            }
          }
        }
        update users;
      } catch (Exception exceptionObject) {
        BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'BPG_Set_User_Attribute', 'doAssignment', userGroupMap.keySet(), 'GCM_Application_Administrator');
      }
    }
    
 /******************************************************************************************
  * Standard Method In Batchable Class
  *****************************************************************************************/
    public void finish(Database.BatchableContext bc) {}
}