/******************************************************************************************
*  Date          : 15-NOV-2019
*  Author        : Simon Alexander
*  Description   : Merge 1 logic to track modifications/deletions to ContentVersions
*  Modifications  : 15-Nov-2019 - Simon Alexander - Added Merge1 execution
*            
* ***************************************************************************************/

public with sharing class BPI_ContentVersion_Trigger_Handler extends BPG_Trigger_Handler_Utilities { 
    
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
        // Before Update Event
        new BPI_MG1_ContentVersionTriggerHandler().run();
    }
    
    
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        // Before Insert Event
        new BPI_MG1_ContentVersionTriggerHandler().run();
    }
      
}