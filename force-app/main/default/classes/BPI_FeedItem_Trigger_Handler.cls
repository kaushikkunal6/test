/******************************************************************************************
*  Date          : 2-SEP-2019
*  Author        : Simon Alexander
*  Description   : Validation to prevent an MRL User from creating, updating or deleting any FeedItems and tracking modifications/deletions in merge1
*  Modifications : 2-SEP-2019  - Initial
*  Modifications : 10-SEP-2019 - Palash Awasthi 
*  Modifications : 15-Nov-2019 - Simon Alexander - Added Merge1 execution   
* ***************************************************************************************/

public with sharing class BPI_FeedItem_Trigger_Handler extends BPG_Trigger_Handler_Utilities { 
    
    public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
        // Before Update Event
        preventMRL((List<FeedItem>) n);
    }
    
    
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        // Before Insert Event
        preventMRL((List<FeedItem>) n);
    }
    
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
        // After Update Event
        if (Test.isRunningTest() && UserInfo.getUserName() != 'userMerge1@testclass_bp86Fhe45Hf4t42eL.com'){
            return;
        }
        new BPI_MG1_FeedItemTriggerHandler().run();
    }
    
    
    public override void beforeDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        // Before Delete Event
        if (Test.isRunningTest() && UserInfo.getUserName() != 'userMerge1@testclass_bp86Fhe45Hf4t42eL.com'){
            return;
        }
        new BPI_MG1_FeedItemTriggerHandler().run();
    }
    
    
    public static void preventMRL(List<FeedItem> feeditems)
    {
        //Get the Set of disallowed Feed Item type from Custom Metadata
        
        Set<String> blockedFeedItemTypeSet = new Set<String>();
        
        for (BPI_Feed_Item_Type__mdt blockedFeedItem: [SELECT Item_Type__c FROM BPI_Feed_Item_Type__mdt LIMIT 100]) {
            blockedFeedItemTypeSet.add(blockedFeedItem.Item_Type__c);
        }
        
        // Get the current user info to see if they are MRL
        List <BPI_MRL_User__c> mrlUsers = [SELECT Id FROM BPI_MRL_User__c WHERE BPI_Email__c = :UserInfo.getUserEmail() AND BPI_MRL_Status__c IN ('Active', 'Pending') LIMIT 1];
        
        if (mrlUsers.size() == 0) return;
        
        else{
            
            for (FeedItem item: feedItems) {
                
                if (blockedFeedItemTypeSet.contains(item.Type)) {
                    
                    item.addError(System.Label.Prevent_MRL_Users_from_Chatter_Post);
                }
            }
        }
        
    }  
}