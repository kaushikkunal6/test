/***************************************************************
 * @author           Kunal
 * @date             06/Nov/2019
 * @group            AirBP
 * @description      Batch to create t&f debrief records: AITM_TenderLocationTaxFeeBatch

 * history
 * 28/May/2019  	 Kunal       Created 
 **********************************************************/
public without sharing class AITM_TenderLocationTaxFeeBatch implements Database.Batchable<SObject>{
    private final Id tenderRecordId;
    private final String operationType;
    public Set<Id> setOfDefaultLineItemIdsToProcess;
    public List<AITM_Tender_Location_Line_Item__c> processDebriefLineItems;
   
    /**
     * @description overloaded constructor
     * @param  state of type BatchState
     */
    public AITM_TenderLocationTaxFeeBatch(Id tenderId, String opType) {
        tenderRecordId = tenderId;
        operationType = opType;
        processDebriefLineItems = new List<AITM_Tender_Location_Line_Item__c>();
        setOfDefaultLineItemIdsToProcess = new Set<Id>();
    }
    
    /**
     * @description start
     * @param  context of type Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Iterable<SObject> start(Database.BatchableContext context) {
        List<AITM_Tender_Location_Line_Item__c> lineItems = AITM_LocationsDao.getTenderLocationLineItemsWithTaxFees(tenderRecordId);
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
            Map<Id, List<AITM_Tender_Location_Taxes_and_Fees__c>> mapOfLineItemWithTaxFeeRecords = new Map<Id, List<AITM_Tender_Location_Taxes_and_Fees__c>>();
            List<AITM_Tender_Location_Taxes_and_Fees__c> createDebriefLineItemsTaxFeeRecords = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
            List<AITM_Tender_Location_Taxes_and_Fees__c> deleteExistingDebriefTaxFeeRecords = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
            
            for(AITM_Tender_Location_Line_Item__c item : scope){
                if(String.isBlank(item.AITM_Record_Type_Name__c) || item.AITM_Record_Type_Name__c == 'Default'){
                    setOfDefaultLineItemIdsToProcess.add(item.Id);
                } else if(item.AITM_Record_Type_Name__c == 'De-brief'){
				    setOfDefaultLineItemIdsToProcess.add(item.AITM_Previous_TLLI_Id__c);
                    processDebriefLineItems.add(item);
                }
            }
            mapOfLineItemWithTaxFeeRecords = getLineItemWithTaxFeeRecords(setOfDefaultLineItemIdsToProcess);
            if(operationType == 'insert' || operationType == 'All') {
            	insertDebriefLineItemTaxFeeRecords(createDebriefLineItemsTaxFeeRecords, processDebriefLineItems, mapOfLineItemWithTaxFeeRecords);  
                deleteExistingDefaultTaxFeeRecords(processDebriefLineItems);
            } 
        }     
    }
    
    /**
     * @description get tax fee records from existing line items with LineItem id
     * @param setOfDefaultLineItemIdsToProcess of type Set collection Tender_Location_Line_Item__c
     * @return taxFees of type Map collection AITM_Tender_Location_Taxes_and_Fees__c
     */
    private Map<Id, List<AITM_Tender_Location_Taxes_and_Fees__c>> getLineItemWithTaxFeeRecords(Set<Id> setOfDefaultLineItemIdsToProcess){
        Map<Id, List<AITM_Tender_Location_Taxes_and_Fees__c>> mapOfItemIdWithTaxFeeRecords = new Map<Id, List<AITM_Tender_Location_Taxes_and_Fees__c>>();
        
        for(AITM_Tender_Location_Taxes_and_Fees__c fee : getTaxFeeRecords(setOfDefaultLineItemIdsToProcess)) {
            if(!mapOfItemIdWithTaxFeeRecords.containsKey(fee.Tender_Location_Line_Item_Id__c)) {
                mapOfItemIdWithTaxFeeRecords.put(fee.Tender_Location_Line_Item_Id__c, new List<AITM_Tender_Location_Taxes_and_Fees__c>{fee});    
            } else{
                mapOfItemIdWithTaxFeeRecords.get(fee.Tender_Location_Line_Item_Id__c).add(fee);
            }
        }
        return mapOfItemIdWithTaxFeeRecords;
    }
    
    /**
     * @description get tax fee records from existing line items
     * @param setOfDefaultLineItemIdsToProcess of type Set collection Tender_Location_Line_Item__c
     * @return taxFees of type list collection AITM_Tender_Location_Taxes_and_Fees__c
     */
    public List<AITM_Tender_Location_Taxes_and_Fees__c> getTaxFeeRecords(Set<Id> setOfDefaultLineItemIdsToProcess){
        return new List<AITM_Tender_Location_Taxes_and_Fees__c> ([SELECT Id, Name, AITM_Level__c, AITM_FEE_TAX_GROUP__c, AITM_FEE_TAX_NAME__c, AITM_Charge_Type__c, AITM_Value__c, Tender_Location_Line_Item_Id__c, AITM_Display_Currency__c, AITM_Compulsory_Conditional__c, AITM_Unit_of_measure__c, AITM_Record_Type_Name__c,AITM_Select_to_Apply_in_Contract__c, AITM_Tender_Sector__c, AITM_Fuel_Type__c 
                                                                  FROM AITM_Tender_Location_Taxes_and_Fees__c 
                                                                  WHERE Tender_Location_Line_Item_Id__c IN :setOfDefaultLineItemIdsToProcess]);
    }
    
    /**
     * @description insert debrief Line item tax fee records from existing line items with debrief record type
     * @param createDebriefLineItemsTaxFeeRecords of type list collection AITM_Tender_Location_Taxes_and_Fees__c
     * @param lineItems of type list collection AITM_Tender_Location_Line_Item__c
     * @param mapOfItemIdWithTaxFeeRecords of type list collection AITM_Tender_Location_Line_Item__c
     * @return void
     */
     private void insertDebriefLineItemTaxFeeRecords(List<AITM_Tender_Location_Taxes_and_Fees__c> createDebriefLineItemsTaxFeeRecords, List<AITM_Tender_Location_Line_Item__c> lineItems, Map<Id, List<AITM_Tender_Location_Taxes_and_Fees__c>> mapOfItemIdWithTaxFeeRecords) {
         List<AITM_Tender_Location_Taxes_and_Fees__c> listOfTaxFeeRecords = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
         
         for(Integer i = 0; i < lineItems.size() ; i++) {
             if(mapOfItemIdWithTaxFeeRecords.containsKey(lineItems[i].AITM_Previous_TLLI_Id__c)){
             
				 for(AITM_Tender_Location_Taxes_and_Fees__c defaultFee : mapOfItemIdWithTaxFeeRecords.get(lineItems[i].AITM_Previous_TLLI_Id__c)){
					 AITM_Tender_Location_Taxes_and_Fees__c debriefItemFeeRecord = new AITM_Tender_Location_Taxes_and_Fees__c();
					 
					 debriefItemFeeRecord.AITM_Level__c = defaultFee.AITM_Level__c;
					 debriefItemFeeRecord.AITM_FEE_TAX_GROUP__c = defaultFee.AITM_FEE_TAX_GROUP__c;
					 debriefItemFeeRecord.AITM_FEE_TAX_NAME__c = defaultFee.AITM_FEE_TAX_NAME__c;
					 debriefItemFeeRecord.AITM_Charge_Type__c = defaultFee.AITM_Charge_Type__c;
					 debriefItemFeeRecord.AITM_Value__c = defaultFee.AITM_Value__c;
					 debriefItemFeeRecord.AITM_Display_Currency__c = defaultFee.AITM_Display_Currency__c;
					 debriefItemFeeRecord.AITM_Compulsory_Conditional__c = defaultFee.AITM_Compulsory_Conditional__c;
					 debriefItemFeeRecord.AITM_Unit_of_measure__c = defaultFee.AITM_Unit_of_measure__c;
					 debriefItemFeeRecord.AITM_Record_Type_Name__c = 'De-brief';
					 debriefItemFeeRecord.AITM_Tender_Sector__c = defaultFee.AITM_Tender_Sector__c;
					 debriefItemFeeRecord.AITM_Fuel_Type__c = defaultFee.AITM_Fuel_type__c;
					 debriefItemFeeRecord.AITM_Select_to_Apply_in_Contract__c = defaultFee.AITM_Select_to_Apply_in_Contract__c;
					 debriefItemFeeRecord.Tender_Location_Line_Item_Id__c = lineItems[i].Id;
					 debriefItemFeeRecord.Name = defaultFee.Name;
					 createDebriefLineItemsTaxFeeRecords.add(debriefItemFeeRecord);
				}	
			}
        } 
       
        Database.insert(createDebriefLineItemsTaxFeeRecords, false);
    }
    
    /**
     * @description delete Existing debrief tax fee records from existing line items with debrief record type
     * @param lineItems of type list collection AITM_Tender_Location_Line_Item__c
     * @return void
     */
     private void deleteExistingDefaultTaxFeeRecords(List<AITM_Tender_Location_Line_Item__c> lineItems) {
         List<AITM_Tender_Location_Taxes_and_Fees__c> listOfDefaultTaxFeeRecords = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
         Set<Id> lineItemIds = new Set<Id>();
         
         for(Integer i = 0; i < lineItems.size();i++) {
             lineItemIds.add(lineItems[i].Id);
         }
         listOfDefaultTaxFeeRecords = [SELECT Id FROM AITM_Tender_Location_Taxes_and_Fees__c WHERE AITM_Record_Type_Name__c = 'Default' AND Tender_Location_Line_Item_Id__c IN :lineItemIds];
         
         if(!listOfDefaultTaxFeeRecords.isEmpty()) {
             Database.delete(listOfDefaultTaxFeeRecords, false);
         }
    }
    
    /**
     * @description finish
     * @param  context of type Database.BatchableContext
     * @return null
     */    
    public void finish(Database.BatchableContext context) {}
}