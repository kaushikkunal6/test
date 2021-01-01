/************************************************************************************************
 * @author           Shweta
 * @date             31/July/2019
 * @group            AirBP
 * @description      Batch class used to clone the Tender Location Line Items when round is get changed for the tender
 *                   
 * history
 * 31/July/2019   	 Shweta      Created
 * 8/Sep/2019        Saravan`   Modified - 693709 -Updated the method insertCloneLineItemRecords to include Previous Round Differential 
 **************************************************************************************************************/
public with sharing class AITM_CloneTLLIBatch implements Database.Batchable<SObject>,Database.Stateful{
     private List<AITM_Tender_Location__c> tenderLocations;
	 private Id tenderId;  
     private decimal round;
     private Map<Id, AITM_Tender_Location__c> newTenderLocationsByOldIds = new Map<Id, AITM_Tender_Location__c>();
     private final String DEFAULT_RECORD_TYPE_ID = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
     private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItemToCloned = new List<AITM_Tender_Location_Line_Item__c>();   
     private map<string,id> mapOfNewTlli = new map<string,id>();

    /**
      * @description overloaded constructor
      * @param newTenderLocationsByOldIds of type Map<Id,AITM_Tender_Location__c>
      */
        public AITM_CloneTLLIBatch(Map<Id,AITM_Tender_Location__c> newTenderLocationsByOldIds,List<AITM_Tender_Location__c> tenderLocations) {
        this.tenderLocations = tenderLocations;
        this.newTenderLocationsByOldIds = newTenderLocationsByOldIds;       
    }

    /**
      * @description start
      * @param  context of type Database.BatchableContext
      * @return Iterable
      */ 
        public Iterable<SObject> start(Database.BatchableContext context) {
             List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItemToClone = new AITM_LocationsDao().getTenderLocationLineItemsToClone(tenderLocations);
             return tenderLocationLineItemToClone;         
       
    } 

    /**
      * @description execute
      * @param  context of type Database.BatchableContext
      * @param  scope of type List<AITM_Tender_Location_Line_Item__c>
      * @return null
      */

      public void execute(Database.BatchableContext context, List<AITM_Tender_Location_Line_Item__c> scope) {
        if (scope.size() > 0) {
            List<AITM_Tender_Location_Line_Item__c> cloneCreateLineItems = new List<AITM_Tender_Location_Line_Item__c>();
            insertCloneLineItemRecords(cloneCreateLineItems, scope);
                    
        }     
    }

    /**
      * @description to clone and insert the tender location line items for the next round
      * @param cloneCreateLineItems of type List<AITM_Tender_Location_Line_Item__c>
      * @param lineItems of type List<AITM_Tender_Location_Line_Item__c>
      * @return null
      */

     private void insertCloneLineItemRecords(List<AITM_Tender_Location_Line_Item__c> cloneCreateLineItems, List<AITM_Tender_Location_Line_Item__c> lineItems) {
        for(AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
              AITM_Tender_Location__c tenderLocationClone = newTenderLocationsByOldIds.get(lineItem.AITM_Tender_Location__c);
                AITM_Tender_Location_Line_Item__c cloneItem = lineItem.clone(false, true, false, true);
                cloneItem.AITM_Round__c = tenderLocationClone.AITM_Current_Round__c;
                cloneItem.AITM_Status__c = tenderLocationClone.AITM_Status__c;
                cloneItem.AITM_Tender_Result__c = null;
                cloneItem.AITM_Last_Tender_Result__c = lineItem.AITM_Tender_Result__c;
                cloneItem.AITM_Tender_Location__c = tenderLocationClone.Id;
                cloneItem.AITM_Parent_TLLI_Id__c = lineItem.AITM_Parent_TLLI_Id__c;
                cloneItem.RecordTypeId = DEFAULT_RECORD_TYPE_ID;
                cloneItem.AITM_Is_Clone__c = true;
				cloneItem.AITM_Previous_Round_Differential__c = lineItem.AITM_Offered_Differential__c;
				cloneItem.AITM_ManualClonedBy__c = lineItem.Id;
                cloneCreateLineItems.add(cloneItem);
        }

        Database.insert(cloneCreateLineItems);
		for(AITM_Tender_Location_Line_Item__c tlli: cloneCreateLineItems){     
             mapOfNewTlli.put(tlli.AITM_ManualClonedBy__c, tlli.id);
            } 
           
        tenderId =cloneCreateLineItems[0].AITM_Tender__c;   
        round = cloneCreateLineItems[0].AITM_Current_Round__c;
    }
	
	
	
    /**
      * @description finish
      * @param  context of type Database.BatchableContext
      * @return null
      */    
     public void finish(Database.BatchableContext context) {
	     Database.executeBatch(new AITM_TenderLocationTaxFeeCloneBatch(tenderId,(round-1),mapOfNewTlli),100);   
	 }
}