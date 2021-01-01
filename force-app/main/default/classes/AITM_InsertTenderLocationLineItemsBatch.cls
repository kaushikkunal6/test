/************************************************************************************************
 * @author           Ravi
 * @date             23/May/2019
 * @group            AirBP
 * @description      Batch class used to insert the tender location line items once tender is created
 *                   
 * history
 * 23/May/2019   Ravi          Created
 * 23/July/2019  srnandan      Modified the code to avoid heap size and limit exception
 * 27/Aug/2019   srnandan      workitem (677274) - declared constant STATUS_MI for setting default status as 'MI' if no value set
 * 27/Aug/2019   Shweta        Modified - Use the 'Without Sharing' as its a batch class performing the operations like insert/Delete  on Tender Location Line Items. 
 * 23/Sep/2019   srnandan      workitem (703002) added assignment AITM_Include_Notes_in_Contract__c for debrief records from default lineitems
 * 22/Apr/2020   Saravan       Modified - 108793 added assignment of Parent Id for debrief record from default lineitems
 * 09/Oct/2020   Shweta        Modified - Updated to without sharing as the delete access is not given to the LABP profile for moving from debrief to awaiting Stage and then back to the debrief stage
 **************************************************************************************************************/
public without sharing class AITM_InsertTenderLocationLineItemsBatch implements Database.Batchable<SObject> {
   private final Id tenderRecordId;
   private final String DEBRIEF_RECORD_TYPE_ID = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId(); 
   private final String operationType;
   private static final String STATUS_MI = 'MI';	
   /**
     * @description overloaded constructor
     * @param  state of type BatchState
     */
    public AITM_InsertTenderLocationLineItemsBatch(Id tenderId, String opType) {
        tenderRecordId = tenderId;
        operationType = opType;
    } 

    /**
     * @description start
     * @param  context of type Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Iterable<SObject> start(Database.BatchableContext context) {
        List<AITM_Tender_Location_Line_Item__c> lineItems = new AITM_LocationsDao.TenderLocationLineItemsDao().getTenderLocationLineItemsForTender(tenderRecordId);
        return lineItems;         
    } 

    /**
     * @description execute
     * @param  context of type Database.BatchableContext
     * @param  scope of type List<AITM_Tender_Location_Line_Item__c>
     * @return null
     */
    public void execute(Database.BatchableContext context, List<AITM_Tender_Location_Line_Item__c> scope) {
        if (scope.size() > 0) {
            List<AITM_Tender_Location_Line_Item__c> debriefCreateLineItems = new List<AITM_Tender_Location_Line_Item__c>();
            if(operationType == 'insert') {
            	insertDebriefLineItemRecords(debriefCreateLineItems,scope);               
            } else {
                debriefLineItemRecords(debriefCreateLineItems,scope);
            }
            
        }     
    }

    /**
     * @description insert debrief records from existing line items with default record type
     * @param debriefCreateLineItems of type list collection AITM_Tender_Location_Line_Item__c
     * @param lineItems of type list collection AITM_Tender_Location_Line_Item__c
     * @return void
     */
     private void insertDebriefLineItemRecords(List<AITM_Tender_Location_Line_Item__c> debriefCreateLineItems, List<AITM_Tender_Location_Line_Item__c> lineItems) {
         
         for(Integer i = 0; i < lineItems.size() ; i++) {
            AITM_Tender_Location_Line_Item__c debriefItem = new AITM_Tender_Location_Line_Item__c();
                debriefItem.RecordTypeId = DEBRIEF_RECORD_TYPE_ID;
                debriefItem.OwnerId = lineItems[i].OwnerId;
                debriefItem.AITM_Account__c = lineItems[i].AITM_Account__c;
                debriefItem.AITM_Bid_Expiry_Date__c = lineItems[i].AITM_Bid_Expiry_Date__c;
                debriefItem.AITM_Tender__c = lineItems[i].AITM_Tender__c;
                debriefItem.AITM_Tender_Location__c = lineItems[i].AITM_Tender_Location__c;
                debriefItem.AITM_Ad_hoc_Volume__c = lineItems[i].AITM_Ad_hoc_Volume__c;
                debriefItem.AITM_Currency__c = lineItems[i].AITM_Currency__c;
                debriefItem.AITM_Current_Value__c = lineItems[i].AITM_Current_Value__c;
                debriefItem.AITM_Tender_Result__c = (String.isBlank(lineItems[i].AITM_Tender_Result__c) 
                    ? STATUS_MI : lineItems[i].AITM_Tender_Result__c);
                debriefItem.AITM_Credit_Days__c = lineItems[i].AITM_Credit_Days__c;
                debriefItem.AITM_Location_Delivery_Point__c = lineItems[i].AITM_Location_Delivery_Point__c; 
                debriefItem.AITM_Details_Context__c = lineItems[i].AITM_Details_Context__c;                                        
                debriefItem.AITM_Duration__c = lineItems[i].AITM_Duration__c;
                debriefItem.AITM_Invoice_Frequency__c = lineItems[i].AITM_Invoice_Frequency__c; 
                debriefItem.AITM_End_Date__c = lineItems[i].AITM_End_Date__c;
                debriefItem.AITM_Exchange__c = lineItems[i].AITM_Exchange__c;
                debriefItem.AITM_Location_Manager__c = lineItems[i].AITM_Location_Manager__c;
                debriefItem.AITM_Last_Tender_Result__c = lineItems[i].AITM_Last_Tender_Result__c;
                debriefItem.AITM_Level_Of_Interest__c = lineItems[i].AITM_Level_Of_Interest__c;
                debriefItem.AITM_Location__c = lineItems[i].AITM_Location__c; 
                debriefItem.AITM_Offered_Differential__c = lineItems[i].AITM_Offered_Differential__c;
                debriefItem.AITM_Offered_Volume__c = lineItems[i].AITM_Offered_Volume__c;
                debriefItem.AITM_Pricing_Basis__c = lineItems[i].AITM_Pricing_Basis__c;
                debriefItem.AITM_Quantity__c = lineItems[i].AITM_Quantity__c;
                debriefItem.AITM_Requested_Volume_USG__c = lineItems[i].AITM_Requested_Volume_USG__c;
                debriefItem.AITM_Requested_Volume_UoM__c = lineItems[i].AITM_Requested_Volume_UoM__c;
                debriefItem.AITM_Round__c = lineItems[i].AITM_Round__c;
                debriefItem.AITM_Specification__c = lineItems[i].AITM_Specification__c;
                debriefItem.AITM_Start_Date__c = lineItems[i].AITM_Start_Date__c;                
                debriefItem.AITM_Unit_Of_Measure__c = lineItems[i].AITM_Unit_Of_Measure__c;
                debriefItem.AITM_Percentage_Volume_Offered__c = lineItems[i].AITM_Percentage_Volume_Offered__c;
                debriefItem.AITM_History_Line_Item__c = lineItems[i].AITM_History_Line_Item__c;                                             
                debriefItem.AITM_Volume__c = lineItems[i].AITM_Volume__c;
                debriefItem.AITM_Rebate__c = lineItems[i].AITM_Rebate__c;
                debriefItem.AITM_Tender_Owner_Profile__c = lineItems[i].AITM_Tender_Owner_Profile__c;
                debriefItem.AITM_Taxes_Fees__c = lineItems[i].AITM_Taxes_Fees__c;
                debriefItem.AITM_Additional_Notes_Taxes_and_Fees__c = lineItems[i].AITM_Additional_Notes_Taxes_and_Fees__c;
                debriefItem.AITM_Measure__c = lineItems[i].AITM_Measure__c;
                debriefItem.AITM_Product_Density_for_Pricing__c = lineItems[i].AITM_Product_Density_for_Pricing__c;
                debriefItem.AITM_Density__c = lineItems[i].AITM_Density__c;
                debriefItem.AITM_Product_Default__c = lineItems[i].AITM_Product_Default__c;
                debriefItem.AITM_Product_Specification__c = lineItems[i].AITM_Product_Specification__c;
                debriefItem.AITM_Include_Taxes_and_Fees_in_Contract__c = lineItems[i].AITM_Include_Taxes_and_Fees_in_Contract__c;
                debriefItem.AITM_Include_Notes_in_Contract__c = lineItems[i].AITM_Include_Notes_in_Contract__c;
                debriefItem.AITM_Delivery_Method__c = lineItems[i].AITM_Delivery_Method__c;
                debriefItem.AITM_Previous_TLLI_Id__c = lineItems[i].Id;
             	debriefItem.AITM_Parent_TLLI_Id__c = lineItems[i].AITM_Parent_TLLI_Id__c;
                debriefItem.AITM_Product_Pricing_Report__c = lineItems[i].AITM_Product_Pricing_Report__c;
            	debriefItem.AITM_Record_Type_Name__c = 'De-brief';
                debriefItem.AITM_Straddled_Taxes_Fees__c = lineItems[i].AITM_Straddled_Taxes_Fees__c;
                debriefItem.AITM_Straddled_Additional_Taxes_Fees__c = lineItems[i].AITM_Straddled_Additional_Taxes_Fees__c;
                debriefItem.AITM_Is_Straddled__c = lineItems[i].AITM_Is_Straddled__c;
                debriefCreateLineItems.add(debriefItem); 
                //lineItems.remove(i);
         } 
       
        Database.insert(debriefCreateLineItems, false);
        //debriefCreateLineItems.clear(); 
    }
 	
    /**
     * @description insert debrief records from existing line items with default record type
     * @param debriefCreateLineItems of type list collection AITM_Tender_Location_Line_Item__c
     * @param lineItems of type list collection AITM_Tender_Location_Line_Item__c
     * @return void
     */
     private void debriefLineItemRecords(List<AITM_Tender_Location_Line_Item__c> debriefCreateLineItems, List<AITM_Tender_Location_Line_Item__c> lineItems) {
         Set<Id> lineItemIds = new Set<Id>();
         for(Integer i = 0; i < lineItems.size();i++) {
             lineItemIds.add(lineItems[i].Id);
         }
         List<Id> debriefDeleteLineItems = new List<Id>();
         Map<Id, String> debriefResultsMap = new AITM_LocationsDao.TenderLocationLineItemsDao().getTenderLocationDebriefResultsForIds(lineItemIds);
         for(Integer i = 0; i < lineItems.size() ; i++) {
             if(debriefResultsMap.containsKey(lineItems[i].Id)) {
                String[] strArr = debriefResultsMap.get(lineItems[i].Id).split(':');
                String lineId;
                String debriefResult;
                if(strArr.size() > 1) {
                    lineId = strArr[0];
                    debriefResult = strArr[1];
                }else if(strArr.size() == 1) {
                    lineId = strArr[0];
                }
                if(lineId != null) {
                    debriefDeleteLineItems.add(lineId); 
                }
                
                AITM_Tender_Location_Line_Item__c debriefItem = new AITM_Tender_Location_Line_Item__c();
                debriefItem.RecordTypeId = DEBRIEF_RECORD_TYPE_ID;
                debriefItem.OwnerId = lineItems[i].OwnerId;
                debriefItem.AITM_Account__c = lineItems[i].AITM_Account__c;
                debriefItem.AITM_Bid_Expiry_Date__c = lineItems[i].AITM_Bid_Expiry_Date__c;
                debriefItem.AITM_Tender__c = lineItems[i].AITM_Tender__c;
                debriefItem.AITM_Tender_Location__c = lineItems[i].AITM_Tender_Location__c;
                debriefItem.AITM_Ad_hoc_Volume__c = lineItems[i].AITM_Ad_hoc_Volume__c;
                debriefItem.AITM_Currency__c = lineItems[i].AITM_Currency__c;
                debriefItem.AITM_Current_Value__c = lineItems[i].AITM_Current_Value__c;
                debriefItem.AITM_Tender_Result__c = debriefResult;
                debriefItem.AITM_Credit_Days__c = lineItems[i].AITM_Credit_Days__c;
                debriefItem.AITM_Location_Delivery_Point__c = lineItems[i].AITM_Location_Delivery_Point__c; 
                debriefItem.AITM_Details_Context__c = lineItems[i].AITM_Details_Context__c;                                        
                debriefItem.AITM_Duration__c = lineItems[i].AITM_Duration__c;
                debriefItem.AITM_Invoice_Frequency__c = lineItems[i].AITM_Invoice_Frequency__c; 
                debriefItem.AITM_End_Date__c = lineItems[i].AITM_End_Date__c;
                debriefItem.AITM_Exchange__c = lineItems[i].AITM_Exchange__c;
                debriefItem.AITM_Location_Manager__c = lineItems[i].AITM_Location_Manager__c;
                debriefItem.AITM_Last_Tender_Result__c = lineItems[i].AITM_Last_Tender_Result__c;
                debriefItem.AITM_Level_Of_Interest__c = lineItems[i].AITM_Level_Of_Interest__c;
                debriefItem.AITM_Location__c = lineItems[i].AITM_Location__c; 
                debriefItem.AITM_Offered_Differential__c = lineItems[i].AITM_Offered_Differential__c;
                debriefItem.AITM_Offered_Volume__c = lineItems[i].AITM_Offered_Volume__c;
                if((debriefResult == 'BG' || debriefResult == 'BR') && lineItems[i].AITM_Offered_Volume__c != null){
                    debriefItem.AITM_Awarded_Volume__c = lineItems[i].AITM_Offered_Volume__c;
                }
                debriefItem.AITM_Pricing_Basis__c = lineItems[i].AITM_Pricing_Basis__c;
                debriefItem.AITM_Quantity__c = lineItems[i].AITM_Quantity__c;
                debriefItem.AITM_Requested_Volume_USG__c = lineItems[i].AITM_Requested_Volume_USG__c;
                debriefItem.AITM_Requested_Volume_UoM__c = lineItems[i].AITM_Requested_Volume_UoM__c;
                debriefItem.AITM_Round__c = lineItems[i].AITM_Round__c;
                debriefItem.AITM_Specification__c = lineItems[i].AITM_Specification__c;
                debriefItem.AITM_Start_Date__c = lineItems[i].AITM_Start_Date__c;                
                debriefItem.AITM_Unit_Of_Measure__c = lineItems[i].AITM_Unit_Of_Measure__c;
                debriefItem.AITM_Percentage_Volume_Offered__c = lineItems[i].AITM_Percentage_Volume_Offered__c;
                debriefItem.AITM_History_Line_Item__c = lineItems[i].AITM_History_Line_Item__c;                                             
                debriefItem.AITM_Volume__c = lineItems[i].AITM_Volume__c;
                debriefItem.AITM_Rebate__c = lineItems[i].AITM_Rebate__c;
                debriefItem.AITM_Tender_Owner_Profile__c = lineItems[i].AITM_Tender_Owner_Profile__c;
                debriefItem.AITM_Taxes_Fees__c = lineItems[i].AITM_Taxes_Fees__c;
                debriefItem.AITM_Additional_Notes_Taxes_and_Fees__c = lineItems[i].AITM_Additional_Notes_Taxes_and_Fees__c;
                debriefItem.AITM_Measure__c = lineItems[i].AITM_Measure__c;
                debriefItem.AITM_Product_Density_for_Pricing__c = lineItems[i].AITM_Product_Density_for_Pricing__c;
                debriefItem.AITM_Density__c = lineItems[i].AITM_Density__c;
                debriefItem.AITM_Product_Default__c = lineItems[i].AITM_Product_Default__c;
                debriefItem.AITM_Product_Specification__c = lineItems[i].AITM_Product_Specification__c;
                debriefItem.AITM_Include_Taxes_and_Fees_in_Contract__c = lineItems[i].AITM_Include_Taxes_and_Fees_in_Contract__c;
                debriefItem.AITM_Include_Notes_in_Contract__c = lineItems[i].AITM_Include_Notes_in_Contract__c;
                debriefItem.AITM_Delivery_Method__c = lineItems[i].AITM_Delivery_Method__c;
                debriefItem.AITM_Previous_TLLI_Id__c = lineItems[i].Id;
                debriefItem.AITM_Parent_TLLI_Id__c = lineItems[i].AITM_Parent_TLLI_Id__c;
                debriefItem.AITM_Product_Pricing_Report__c = lineItems[i].AITM_Product_Pricing_Report__c;
            	debriefItem.AITM_Record_Type_Name__c = 'De-brief';
                debriefItem.AITM_Straddled_Taxes_Fees__c = lineItems[i].AITM_Straddled_Taxes_Fees__c;
                debriefItem.AITM_Straddled_Additional_Taxes_Fees__c = lineItems[i].AITM_Straddled_Additional_Taxes_Fees__c;
                debriefItem.AITM_Is_Straddled__c = lineItems[i].AITM_Is_Straddled__c;
                debriefCreateLineItems.add(debriefItem); 
             } else {
            	AITM_Tender_Location_Line_Item__c debriefItem = new AITM_Tender_Location_Line_Item__c();
                debriefItem.RecordTypeId = DEBRIEF_RECORD_TYPE_ID;
                debriefItem.OwnerId = lineItems[i].OwnerId;
                debriefItem.AITM_Account__c = lineItems[i].AITM_Account__c;
                debriefItem.AITM_Bid_Expiry_Date__c = lineItems[i].AITM_Bid_Expiry_Date__c;
                debriefItem.AITM_Tender__c = lineItems[i].AITM_Tender__c;
                debriefItem.AITM_Tender_Location__c = lineItems[i].AITM_Tender_Location__c;
                debriefItem.AITM_Ad_hoc_Volume__c = lineItems[i].AITM_Ad_hoc_Volume__c;
                debriefItem.AITM_Currency__c = lineItems[i].AITM_Currency__c;
                debriefItem.AITM_Current_Value__c = lineItems[i].AITM_Current_Value__c;
                if(String.isBlank(lineItems[i].AITM_Tender_Result__c)){
                    debriefItem.AITM_Tender_Result__c = STATUS_MI;
                } else {
                    debriefItem.AITM_Tender_Result__c = lineItems[i].AITM_Tender_Result__c;
                }
                debriefItem.AITM_Credit_Days__c = lineItems[i].AITM_Credit_Days__c;
                debriefItem.AITM_Location_Delivery_Point__c = lineItems[i].AITM_Location_Delivery_Point__c; 
                debriefItem.AITM_Details_Context__c = lineItems[i].AITM_Details_Context__c;                                        
                debriefItem.AITM_Duration__c = lineItems[i].AITM_Duration__c;
                debriefItem.AITM_Invoice_Frequency__c = lineItems[i].AITM_Invoice_Frequency__c; 
                debriefItem.AITM_End_Date__c = lineItems[i].AITM_End_Date__c;
                debriefItem.AITM_Exchange__c = lineItems[i].AITM_Exchange__c;
                debriefItem.AITM_Location_Manager__c = lineItems[i].AITM_Location_Manager__c;
                debriefItem.AITM_Last_Tender_Result__c = lineItems[i].AITM_Last_Tender_Result__c;
                debriefItem.AITM_Level_Of_Interest__c = lineItems[i].AITM_Level_Of_Interest__c;
                debriefItem.AITM_Location__c = lineItems[i].AITM_Location__c; 
                debriefItem.AITM_Offered_Differential__c = lineItems[i].AITM_Offered_Differential__c;
                debriefItem.AITM_Offered_Volume__c = lineItems[i].AITM_Offered_Volume__c;
                debriefItem.AITM_Pricing_Basis__c = lineItems[i].AITM_Pricing_Basis__c;
                debriefItem.AITM_Quantity__c = lineItems[i].AITM_Quantity__c;
                debriefItem.AITM_Requested_Volume_USG__c = lineItems[i].AITM_Requested_Volume_USG__c;
                debriefItem.AITM_Requested_Volume_UoM__c = lineItems[i].AITM_Requested_Volume_UoM__c;
                debriefItem.AITM_Round__c = lineItems[i].AITM_Round__c;
                debriefItem.AITM_Specification__c = lineItems[i].AITM_Specification__c;
                debriefItem.AITM_Start_Date__c = lineItems[i].AITM_Start_Date__c;                
                debriefItem.AITM_Unit_Of_Measure__c = lineItems[i].AITM_Unit_Of_Measure__c;
                debriefItem.AITM_Percentage_Volume_Offered__c = lineItems[i].AITM_Percentage_Volume_Offered__c;
                debriefItem.AITM_History_Line_Item__c = lineItems[i].AITM_History_Line_Item__c;                                             
                debriefItem.AITM_Volume__c = lineItems[i].AITM_Volume__c;
                debriefItem.AITM_Rebate__c = lineItems[i].AITM_Rebate__c;
                debriefItem.AITM_Tender_Owner_Profile__c = lineItems[i].AITM_Tender_Owner_Profile__c;
                debriefItem.AITM_Taxes_Fees__c = lineItems[i].AITM_Taxes_Fees__c;
                debriefItem.AITM_Additional_Notes_Taxes_and_Fees__c = lineItems[i].AITM_Additional_Notes_Taxes_and_Fees__c;
                debriefItem.AITM_Measure__c = lineItems[i].AITM_Measure__c;
                debriefItem.AITM_Product_Density_for_Pricing__c = lineItems[i].AITM_Product_Density_for_Pricing__c;
                debriefItem.AITM_Density__c = lineItems[i].AITM_Density__c;
                debriefItem.AITM_Product_Default__c = lineItems[i].AITM_Product_Default__c;
                debriefItem.AITM_Product_Specification__c = lineItems[i].AITM_Product_Specification__c;
                debriefItem.AITM_Include_Taxes_and_Fees_in_Contract__c = lineItems[i].AITM_Include_Taxes_and_Fees_in_Contract__c;
                debriefItem.AITM_Include_Notes_in_Contract__c = lineItems[i].AITM_Include_Notes_in_Contract__c;
                debriefItem.AITM_Delivery_Method__c = lineItems[i].AITM_Delivery_Method__c;
                debriefItem.AITM_Previous_TLLI_Id__c = lineItems[i].Id;
                debriefItem.AITM_Parent_TLLI_Id__c = lineItems[i].AITM_Parent_TLLI_Id__c;
                debriefItem.AITM_Product_Pricing_Report__c = lineItems[i].AITM_Product_Pricing_Report__c;
            	debriefItem.AITM_Record_Type_Name__c = 'De-brief';
                debriefItem.AITM_Straddled_Taxes_Fees__c = lineItems[i].AITM_Straddled_Taxes_Fees__c;
                debriefItem.AITM_Straddled_Additional_Taxes_Fees__c = lineItems[i].AITM_Straddled_Additional_Taxes_Fees__c;
                debriefItem.AITM_Is_Straddled__c = lineItems[i].AITM_Is_Straddled__c;
                debriefCreateLineItems.add(debriefItem); 
                //lineItems.remove(i);
             }
         } 
        Database.delete(debriefDeleteLineItems, false);  
        Database.insert(debriefCreateLineItems, false);
        //debriefCreateLineItems.clear(); 
    }
    
    /**
     * @description finish
     * @param  context of type Database.BatchableContext
     * @return null
     */    
    public void finish(Database.BatchableContext context) {
		Database.executeBatch(new AITM_TenderLocationTaxFeeBatch(tenderRecordId, operationType));
	}
}