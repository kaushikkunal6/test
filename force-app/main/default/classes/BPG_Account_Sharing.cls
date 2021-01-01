/******************************************************************************************
 *  Date          : 10-JUL-2019
 *  Author        : Sunny Yap
 *  Description   : Account custom sharing.
 *  Modifications : 10-JUL-2019 SYAP - Initial
 *                  27-JUL-2019 SYAP - Fixed null pointer exception for public groups.
 *                  31-OCT-2019 SYAP - Performance improvements.
 *                  06-DEC-2019 SYAP - Added capability to trigger bulk reassign.
 *                  14-DEC-2019 SYAP - Added without sharing clause
 *****************************************************************************************/

public without sharing class BPG_Account_Sharing {

/******************************************************************************************
   Assign Public Group To Accounts
   Based On Matching Sales Organisation, Division Code, Distribution Code
 *****************************************************************************************/
  public static void assignPublicGroup(List<Account> accounts, Map<Id, Account> oldMap, Map<Id, Account> newMap, Boolean isInsert, String exceptionQueue) {
    try {
      // Get Valid Record Type
      Set<Id> accountRecordTypes = new Set<Id>();
      accountRecordTypes.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
      accountRecordTypes.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId());

      // Get Valid Person Account Id
      String personAccountSOQL = 'select Id from RecordType where SObjectType = \'Account\' and IsPersonType = true and DeveloperName = \'GCM_Person_Account\'';
      RecordType personAccountRT = (RecordType) BPG_Error_Logger.queryFirstRecord(personAccountSOQL);
      if (personAccountRT != null) accountRecordTypes.add(personAccountRT.Id);
      
      // Find In Scope Accounts
      Map<Id, Account> accountMap = new Map<Id, Account>();
      Map<String, String> salesOrganisationMap = new Map<String, String>();
      for (Account thisAccount : accounts) {
        if (accountRecordTypes.contains(thisAccount.RecordTypeId)) {
          Boolean isInScope = false;
          if (!isInsert) {
            // In Scope If Sales Organisation OR Business Unit Changed
            if (thisAccount.Sales_Organisation__c != null && thisAccount.Sales_Division_Code__c != null && thisAccount.Sales_Distribution_Channel__c != null) {
              if (oldMap.get(thisAccount.Id).Sales_Organisation__c != thisAccount.Sales_Organisation__c || 
                oldMap.get(thisAccount.Id).Sales_Division_Code__c != thisAccount.Sales_Division_Code__c ||
                oldMap.get(thisAccount.Id).Sales_Distribution_Channel__c != thisAccount.Sales_Distribution_Channel__c ||
                oldMap.get(thisAccount.Id).GCM_Reassign_Date__c != thisAccount.GCM_Reassign_Date__c) {
                isInScope = true;
              }
            }     

            // In Scope If Owner Changed
            if (oldMap.get(thisAccount.Id).OwnerId != thisAccount.OwnerId) {
                isInScope = true;
            }
          }
          else {
            isInScope = true;       
          }
          
          // Build In Scope Record Map + Sales Organisation List
          if (isInScope) {
            accountMap.put(thisAccount.Id, thisAccount);
            if (thisAccount.Sales_Organisation__c != null) {
              salesOrganisationMap.put(thisAccount.Sales_Organisation__c, null);
            }
          }
        }
      }
    
      // Sales Organisation OR Business Unit Changes Triggers Other Automation (Outside GCM)
      // The Following Line Prevents Infinite Recursion
      if (accountMap.size() == 0) return;

      Map<String, Id> publicGroupMap = new Map<String, Id>(); // Public Group Name > Public Group Id
      Map<String, List<String>> ruleMap = new Map<String, List<String>>(); // Criteria > Public Group Name List

      // Save Rules In Memory
      List<BPG_Account_Sharing_Rule__mdt> rules = [
        select
          BPG_Sales_Organisation__c,
          BPG_Division_Code__c,
          BPG_Distribution_Code__c,
          BPG_Public_Group__c
        from
          BPG_Account_Sharing_Rule__mdt
        where
          BPG_Sales_Organisation__c in :salesOrganisationMap.keySet() and
          BPG_Active__c = true
      ];
      for (BPG_Account_Sharing_Rule__mdt rule : rules) {
        publicGroupMap.put(rule.BPG_Public_Group__c, null);
        String key = rule.BPG_Sales_Organisation__c + rule.BPG_Division_Code__c + rule.BPG_Distribution_Code__c;
      
        List<String> publicGroupList;
        if (!ruleMap.containsKey(key)) {
          publicGroupList = new List<String>();
          ruleMap.put(key, publicGroupList);
        }
        else {
          publicGroupList = ruleMap.get(key);
        }
        publicGroupList.add(rule.BPG_Public_Group__c);
      }
    
      // Save Public Group DeveloperName > Id Map In Memory
      List<Group> publicGroups = [select Id, DeveloperName from Group where DeveloperName in :publicGroupMap.keySet() and Type = 'Regular'];
      for (Group publicGroup : publicGroups) {
        publicGroupMap.put(publicGroup.DeveloperName, publicGroup.Id);
      }
          
      // Delete Old Account Sharing Records
      List<AccountShare> accountShareToDelete = [
        select
          Id
        from
          AccountShare
        where
          AccountId in :accountMap.keySet() and 
          RowCause = 'Manual' and
          UserOrGroupId in (select Id from Group where Type = 'Regular' and DeveloperName like 'GCM%')];
      if (accountShareToDelete.size() > 0) delete accountShareToDelete;

      // Exit If Public Groups Not Found
      if (publicGroupMap.size() == 0) return;

      // Add New Account Sharing Records
      List<AccountShare> accountShareRules = new List<AccountShare>();
      for (Id accountId : accountMap.keySet()) {
        String key = newMap.get(accountId).Sales_Organisation__c + newMap.get(accountId).Sales_Division_Code__c + newMap.get(accountId).Sales_Distribution_Channel__c;
        if (ruleMap.containsKey(key)) {
          List<String> publicGroupList = ruleMap.get(key);
          for (String publicGroupName : publicGroupList) {
            if (publicGroupMap.containsKey(publicGroupName)) {
              AccountShare share = new AccountShare();
              share.AccountAccessLevel = 'Edit';
              share.AccountId = accountId;
              share.CaseAccessLevel = 'Edit';
              share.OpportunityAccessLevel = 'Edit';
              share.RowCause = 'Manual';
              share.UserOrGroupId = publicGroupMap.get(publicGroupName);
              accountShareRules.add(share);
            }
          }
        }
      }
      if (accountShareRules.size() > 0) insert accountShareRules;
    } catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'BPG_Account_Sharing', 'assignPublicGroup', newMap.keySet(), exceptionQueue);
    }
  }
}