/***************************************************************
 * @author           Kunal
 * @date             12/Dev/2019
 * @group            AirBP
 * @description      Batch to delete existing and create refreshed t&f records: AITM_DeleteTaxFeeRecordsBatch

 * history
 * 12/Dec/2019  	 Kunal       Created 
 **********************************************************/
public without sharing class AITM_DeleteTaxFeeRecordsBatch implements Database.Batchable<SObject>, Database.Stateful{
    public BatchState state;
    
    /**
     * @description overloaded constructor
     * @param  state of type BatchState
     */
    public AITM_DeleteTaxFeeRecordsBatch(BatchState state) {
        this.state = state;
    }
    
    /**
     * @description start
     * @param  context of type Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Iterable<SObject> start(Database.BatchableContext context) {
        List<AITM_Tender_Location_Line_Item__c> lineItems = AITM_LocationsDao.getLineItemsByTenderAndRecordTypeId(state.tenderId, state.lineItemsRecordTypeId);
        return lineItems;         
    }
    
    /**
     * @description execute
     * @param  context of type Database.BatchableContext
     * @param  scope of type List<AITM_Tender_Location_Line_Item__c>
     * @return null
     */
    public void execute(Database.BatchableContext context, List<AITM_Tender_Location_Line_Item__c> scope) {
        if (scope != null && scope.size() > 0) {
            Map<Id, Boolean> mapOfLineItemWithBooleanProductDefault = new Map<Id, Boolean>();
            Map<String, Boolean> mapOfUpdatedFeeWithSelectToApplyBoolean = new Map<String, Boolean>();
            List<AITM_Tender_Location_Taxes_and_Fees__c> listOfExistingTaxesFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
            
            for(AITM_Tender_Location_Line_Item__c lineitem : scope) {
                mapOfLineItemWithBooleanProductDefault.put(lineItem.Id, false);
            }
            for(AITM_Tender_Location_Taxes_and_Fees__c fee : new AITM_LocationsDao().getTaxesAndFeesBySetOfItemIds(mapOfLineItemWithBooleanProductDefault.keySet())){
                if(!mapOfUpdatedFeeWithSelectToApplyBoolean.containsKey(fee.Name +'-' + fee.AITM_Fuel_type__c + '-' + fee.Tender_Location_Line_Item_Id__c)) {
                    mapOfUpdatedFeeWithSelectToApplyBoolean.put(fee.Name +'-'+ fee.AITM_Fuel_type__c + '-' + fee.Tender_Location_Line_Item_Id__c, fee.AITM_Select_to_Apply_in_Contract__c);    
                }
                listOfExistingTaxesFees.add(fee);
            }
            if(!listOfExistingTaxesFees.isEmpty()){
                AITM_TenderApplyNewTaxesAndfees.deleteExistingTaxesAndFees(listOfExistingTaxesFees);
            }
            AITM_TenderApplyNewTaxesAndfees.attachTaxAndFeeRecordsOnLineItem(scope, null);
        }
    }
    
    /**
     * @description finish
     * @param  context of type Database.BatchableContext
     * @return null
     */    
    public void finish(Database.BatchableContext context) {
        if(String.isNotEmpty(state.selectedFilter)){
            AITM_TenderOfferGenerateBatch.BatchState batchState = new AITM_TenderOfferGenerateBatch.BatchState(state.tenderId, state.selectedFilter);
            new AITM_TenderOfferGenerateBatch.BatchFactory().executeBatch(batchState);    
        }
    }
    
    /**
     * @description Batch Factory class
     */
    public class BatchFactory {

        private final Integer BATCH_SIZE = 100;
        private final Set<String> BATCH_JOB_NAME = new Set<String>{'AITM_DeleteTaxFeeRecordsBatch','AITM_TenderOfferGenerateBatch'};
        private final String RUNNING_STATE = 'INPROGRESS';
        private final String DONE_STATE = 'DONE';
        private final Set<String> RUNNING_JOB_STATUSES = new Set<String>{'Queued', 'Preparing', 'Processing'};

       /**
       * @description executeBatch
       * @param  state of type BatchState
       * @return null
       */
        public void executeBatch(BatchState state) {
            Database.executeBatch(new AITM_DeleteTaxFeeRecordsBatch(state), BATCH_SIZE);
        }

       /**
        * @description check
        * @param  null
        * @return string
        */
        public String check() {
            List<AsyncApexJob> futures = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name IN :BATCH_JOB_NAME AND Status IN :RUNNING_JOB_STATUSES];
            if (futures.size() > 0) {
                return RUNNING_STATE;
            } else {
                return DONE_STATE;
            }
        }
    }

    /**
     * @description batchstate holds the details
     */    
    public class BatchState {
        public Id tenderId;
        public Id lineItemsRecordTypeId;
        public String selectedFilter;
      
        /**
         * @description batch state
        */
        public BatchState(Id tenderId, Id recordTypeId, String selectedFilter) {
            this.tenderId = tenderId;
            this.lineItemsRecordTypeId = recordTypeId;
            this.selectedFilter = selectedFilter;
        }
    }
}