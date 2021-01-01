/***************************************************************
 * @author           Kunal
 * @date             11/Aug/2020  
 * @group            AirBP
 * @description      Batch to delete existing and create refreshed t&f records: AITM_RefreshTaxFeeRecordsBatch

 * history
 * 11/Aug/2020  	 Kunal       Created 
 **********************************************************/
public without sharing class AITM_RefreshTaxFeeRecordsBatch implements Database.Batchable<SObject>, Database.Stateful{
    public BatchState state;
	private @testVisible static String ALL_Locations = 'All Locations';
    private @testVisible static String LOCATION = 'Location(s)';
    private @testVisible static String LOCATION_MANAGERS = 'Location Manager(s)';
    private @testVisible static String COUNTRIES = 'Countries';
    private @testVisible static String TAXES = 'Taxes';
    private @testVisible static String NOTES = 'Notes';
    private @testVisible static String TAXESWITHNOTES = 'TaxesWithNotes';
    private @testVisible static Set<String> RECORD_TYPES = new Set<String>{'','Default'};
    
    /**
     * @description overloaded constructor
     * @param  null
     */
     public AITM_RefreshTaxFeeRecordsBatch() {}
    
    /**
     * @description overloaded constructor
     * @param  state of type BatchState
     */
    public AITM_RefreshTaxFeeRecordsBatch(BatchState state) {
        this.state = state;
    }
    
    /**
     * @description start
     * @param  context of type Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        if(state.selectedOption == ALL_Locations){
            return Database.getQueryLocator([SELECT Id, AITM_Tender_Location__r.AITM_Round__c, AITM_Is_Additional_Notes_Updated__c, AITM_Delivery_Method__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Additional_Notes_Taxes_Fees__c, AITM_Product_Default__c, AITM_Tender_Id__c, AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_Record_Type_Name__c 
                                             FROM AITM_Tender_Location_Line_Item__c 
                                             WHERE AITM_Is_Current_Round__c = true 
                                               AND AITM_Old_Taxes_Fees_Flag__c = false AND AITM_Tender__c = :state.tenderId 
                                               AND AITM_Record_Type_Name__c = :RECORD_TYPES]);
        }else if(state.selectedOption == LOCATION){
            return Database.getQueryLocator([SELECT Id, AITM_Tender_Location__r.AITM_Round__c, AITM_Is_Additional_Notes_Updated__c, AITM_Delivery_Method__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Additional_Notes_Taxes_Fees__c, AITM_Product_Default__c, AITM_Tender_Id__c, AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_Record_Type_Name__c 
                                             FROM AITM_Tender_Location_Line_Item__c 
                                             WHERE AITM_Is_Current_Round__c = true 
                                               AND AITM_Old_Taxes_Fees_Flag__c = false AND AITM_Tender__c = :state.tenderId 
                                               AND AITM_Record_Type_Name__c = :RECORD_TYPES AND AITM_Location__r.Name = :state.selectedValues]);
        }else if(state.selectedOption == LOCATION_MANAGERS){
            return Database.getQueryLocator([SELECT Id, AITM_Tender_Location__r.AITM_Round__c, AITM_Is_Additional_Notes_Updated__c, AITM_Delivery_Method__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Additional_Notes_Taxes_Fees__c, AITM_Product_Default__c, AITM_Tender_Id__c, AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_Record_Type_Name__c 
                                             FROM AITM_Tender_Location_Line_Item__c 
                                             WHERE AITM_Is_Current_Round__c = true 
                                               AND AITM_Old_Taxes_Fees_Flag__c = false AND AITM_Tender__c = :state.tenderId 
                                               AND AITM_Record_Type_Name__c = :RECORD_TYPES AND AITM_Tender_Location__r.AITM_Location_Manager__r.Name = :state.selectedValues]);
        }else if(state.selectedOption == COUNTRIES){
            return Database.getQueryLocator([SELECT Id, AITM_Tender_Location__r.AITM_Round__c, AITM_Is_Additional_Notes_Updated__c, AITM_Delivery_Method__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Additional_Notes_Taxes_Fees__c, AITM_Product_Default__c, AITM_Tender_Id__c, AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_Record_Type_Name__c 
                                             FROM AITM_Tender_Location_Line_Item__c 
                                             WHERE AITM_Is_Current_Round__c = true 
                                               AND AITM_Old_Taxes_Fees_Flag__c = false AND AITM_Tender__c = :state.tenderId 
                                               AND AITM_Record_Type_Name__c = :RECORD_TYPES AND AITM_Location__r.AITM_Country__c = :state.selectedValues]);
        }else{
            return null;
        }        
    }
    
    /**
     * @description execute
     * @param  context of type Database.BatchableContext
     * @param  scope of type List<AITM_Tender_Location_Line_Item__c>
     * @return null
     */
    public void execute(Database.BatchableContext context, List<AITM_Tender_Location_Line_Item__c> scope) {
        if (scope != null && scope.size() > 0) {
            if(state.OperationSelection == TAXES || state.OperationSelection == TAXESWITHNOTES){
                refreshTaxesOnLineItems(scope);
            }
            
            if(state.OperationSelection == NOTES || state.OperationSelection == TAXESWITHNOTES){
                refreshAdditionalNotesOnLineItems(scope);
            }
        }
    }
    
    /**
     * @description finish
     * @param  context of type Database.BatchableContext
     * @return null
     */    
    public void finish(Database.BatchableContext context) {
        List<AITM_Taxes_Fees__c> masterTaxes = [SELECT CreatedDate FROM AITM_Taxes_Fees__c ORDER BY CreatedDate DESC limit 1];
        String loadDetails = 'Latest load of Taxes & Fees was on ' + masterTaxes[0].CreatedDate;
        
        AsyncApexJob job = [Select Id, Status, CreatedDate, CompletedDate, CreatedBy.Name from AsyncApexJob where Id = :context.getJobId()];
        String refreshDetails;
        if(state.OperationSelection == TAXES){
            refreshDetails = '  | Last T&F Refresh on this tender was on ' +  job.CompletedDate + ' by ' + job.CreatedBy.Name;
        }else if(state.OperationSelection == NOTES){
            refreshDetails = '  | Last Additonal notes Refresh on this tender was on ' +  job.CompletedDate + ' by ' + job.CreatedBy.Name;
        }else if(state.OperationSelection == TAXESWITHNOTES){
            refreshDetails = '  | Last T&F and Additional notes Refresh on this tender was on ' +  job.CompletedDate + ' by ' + job.CreatedBy.Name;
        }
        
        AITM_Tender__c tender = [SELECT Id, AITM_Taxes_Fees_Load_Details_On_Info_Bar__c, AITM_Refresh_Batch_Running__c FROM AITM_Tender__c WHERE Id = :state.tenderId];
        
        tender.AITM_Taxes_Fees_Load_Details_On_Info_Bar__c = loadDetails + refreshDetails;
        tender.AITM_Refresh_Batch_Running__c = false;
        Database.update(new List<AITM_Tender__c>{tender}, false);
    }
    
    /**
     * @description refreshAdditionalNotesOnLineItems
     * @param scope of type List<AITM_Tender_Location_Line_Item__c>
     * @return null
     */
    public void refreshAdditionalNotesOnLineItems(List<AITM_Tender_Location_Line_Item__c> scope){
        List<AITM_Tender_Location_Line_Item__c> listofLineItemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
        
        for(AITM_Tender_Location_Line_Item__c lineitem : scope) {
            if(!state.ignoreManualAdjusted && lineitem.AITM_Location_Delivery_Point__c != null){
                lineitem.AITM_Additional_Notes_Taxes_and_Fees__c = lineitem.AITM_Location_Delivery_Point__r.AITM_Additional_Notes_Taxes_Fees__c;
                
                listofLineItemsToUpdate.add(lineitem);
            }else if(state.ignoreManualAdjusted && lineitem.AITM_Location_Delivery_Point__c != null && !lineitem.AITM_Is_Additional_Notes_Updated__c){// && lineitem.thatmanuallupdatedNotesFILED){
                lineitem.AITM_Additional_Notes_Taxes_and_Fees__c = lineitem.AITM_Location_Delivery_Point__r.AITM_Additional_Notes_Taxes_Fees__c;
                
                listofLineItemsToUpdate.add(lineitem);
            }
        }
                
        if(listofLineItemsToUpdate != null && listofLineItemsToUpdate.size() > 0){
            Database.update(listofLineItemsToUpdate, false);
        }
    }
    
    
    /**
     * @description refreshTaxesOnLineItems
     * @param scope of type List<AITM_Tender_Location_Line_Item__c >
     * @return null
     */
    public void refreshTaxesOnLineItems(List<AITM_Tender_Location_Line_Item__c> scope){
        Map<Id, Boolean> mapOfLineItemWithBooleanProductDefault = new Map<Id, Boolean>();
        Map<String, Boolean> mapOfUpdatedFeeWithSelectToApplyBoolean = new Map<String, Boolean>();
        Map<String, Boolean> mapOfUniqueTaxKeyWithValue = new Map<String, Boolean>();
        List<AITM_Tender_Location_Taxes_and_Fees__c> listOfExistingTaxesFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
        
        for(AITM_Tender_Location_Line_Item__c lineitem : scope) {
            mapOfLineItemWithBooleanProductDefault.put(lineItem.Id, false);
        }
        for(AITM_Tender_Location_Taxes_and_Fees__c fee : new AITM_LocationsDao().getTaxesAndFeesBySetOfItemIds(mapOfLineItemWithBooleanProductDefault.keySet())){
            String key;
            if(fee.AITM_Display_Currency__c != null){
                key = fee.Name + '-' + fee.AITM_Compulsory_Conditional__c + '-' + fee.AITM_Fuel_Type__c + '-' + fee.AITM_Display_Currency__c + '-' + fee.AITM_Unit_of_measure__c + '-' + fee.Tender_Location_Line_Item_Id__c;
            }else{
                key = fee.Name + '-' + fee.AITM_Compulsory_Conditional__c + '-' + fee.AITM_Fuel_Type__c + '-' + '-' + fee.AITM_Unit_of_measure__c + '-' + fee.Tender_Location_Line_Item_Id__c;
            }
            if(!mapOfUpdatedFeeWithSelectToApplyBoolean.containsKey(key)) {
                mapOfUpdatedFeeWithSelectToApplyBoolean.put(key, fee.AITM_Select_to_Apply_in_Contract__c); 
            }
            if(!state.ignoreManualAdjusted){
                listOfExistingTaxesFees.add(fee);
            }else if(state.ignoreManualAdjusted){
                if(!fee.AITM_Manually_Saved_Tax__c){
                    mapOfUniqueTaxKeyWithValue.put(key, fee.AITM_Manually_Saved_Tax__c);
                    listOfExistingTaxesFees.add(fee);
                }else{
                    mapOfUniqueTaxKeyWithValue.put(key, fee.AITM_Manually_Saved_Tax__c);
                }
            }
        }
        if(!listOfExistingTaxesFees.isEmpty()){
            AITM_TenderApplyNewTaxesAndFees.deleteExistingTaxesAndFees(listOfExistingTaxesFees);
        }
        AITM_TenderApplyNewTaxesAndFees.attachTaxAndFeeRecordsOnLineItem(scope, mapOfUniqueTaxKeyWithValue);// mapOfUpdatedFeeWithSelectToApplyBoolean);
    }
    
    /**
     * @description Batch Factory class
     */
    public class BatchFactory {
        
       /**
       * @description executeBatch
       * @param  state of type BatchState
       * @return null
       */
        public void executeBatch(BatchState state) {
            Database.executeBatch(new AITM_RefreshTaxFeeRecordsBatch(state));
        }
    }
    
    /**
     * @description batchstate holds the details
     */    
    public class BatchState {
        public Id tenderId;
        public String OperationSelection;
		public String selectedOption;
		public List<String> selectedValues;
		public String DEFAULT_RECORD_TYPE;
        public Boolean ignoreManualAdjusted;
		
      
        /**
         * @description batch state
        */
        public BatchState(Id tenderId, String OperationSelection, String selectedOption, List<String> selectedValues, String DEFAULT_RECORD_TYPE, Boolean ignoreManualAdjusted) {
            this.tenderId = tenderId;
            this.OperationSelection = OperationSelection;
			this.selectedOption = selectedOption;
			this.selectedValues = selectedValues;
			this.DEFAULT_RECORD_TYPE = DEFAULT_RECORD_TYPE;
            this.ignoreManualAdjusted = ignoreManualAdjusted;
        }
    }
}