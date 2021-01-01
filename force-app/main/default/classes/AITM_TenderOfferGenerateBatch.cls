/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      To generate Tender Offer Batch

 * history
 * 01/December/2017  George       Created 
 * 05/August/2018    srnandan     Modified added comments to each method and header of class
 * 23/August/2018    Ravi         Modified - added without sharing to the class
 *************************************************************************************/
public without sharing class AITM_TenderOfferGenerateBatch implements Database.Batchable<SObject>, Database.Stateful {
    public BatchState state;

    /**
     * @description overloaded constructor
     * @param  state of type BatchState
     */

    public AITM_TenderOfferGenerateBatch(BatchState state) {
        this.state = state;
    }
    
    /**
     * @description start
     * @param  context of type Database.BatchableContext
     * @return Database.QueryLocator
     */
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(this.state.getBatchQuery());
    }

    /**
     * @description execute
     * @param  context of type Database.BatchableContext
     * @param  scope of type List<AITM_Tender_Account__c>
     * @return null
     */
    public void execute(Database.BatchableContext context, List<AITM_Tender_Account__c> scope) {
        if (scope.size() > 0) {
            AITM_TenderOfferPDFController.generateOffer(state.toGenerationDTO());
        }

        for (AITM_Tender_Account__c customer : scope) {
            AITM_TenderOfferPDFController.GenerationDTO generationDTO = state.toGenerationDTO();
            generationDTO.customerId = customer.Id;
            AITM_TenderOfferPDFController.generateOffer(generationDTO);
        }
    }
    
    /**
     * @description finish
     * @param  context of type Database.BatchableContext
     * @return null
     */
    
    public void finish(Database.BatchableContext context) {}

    /**
     * @description Batch Factory class
     */
    public class BatchFactory {
        private final Integer BATCH_SIZE = 1;
        private final String BATCH_JOB_NAME = 'AITM_TenderOfferGenerateBatch';
        private final String RUNNING_STATE = 'INPROGRESS';
        private final String DONE_STATE = 'DONE';
        private final Set<String> RUNNING_JOB_STATUSES = new Set<String>{'Queued', 'Preparing', 'Processing'};
        
        /**
         * @description executeBatch
         * @param  state of type BatchState
         * @return null
         */        
        public void executeBatch(BatchState state) {
            Database.executeBatch(new AITM_TenderOfferGenerateBatch(state), BATCH_SIZE);
        }

        /**
         * @description check
         * @param  null
         * @return string
         */
        public String check() {
            List<AsyncApexJob> futures = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = :BATCH_JOB_NAME AND Status IN :RUNNING_JOB_STATUSES];

            if (futures.size() > 0) {
                return RUNNING_STATE;
            } else {
                return DONE_STATE;
            }
        }
    }

    /**
     * @description Batch State class
     */

    public class BatchState {
        public Id tenderId;
        public String selectedFilter;

        /**
         * @description batch state
         * @param  tenderId of type Id
         * @param  selectedFilter of type string
         */
        public BatchState(Id tenderId, String selectedFilter) {
            this.tenderId = tenderId;
            this.selectedFilter = selectedFilter;
        }

        /**
         * @description get batch query
         * @param  null
         * @return string
         */
        public String getBatchQuery() {
            return new BatchQueryBuilder().getCustomersQuery(this.tenderId);
        }

        /**
         * @description generation dto
         * @param  null
         * @return AITM_TenderOfferPDFController.GenerationDTO
         */

        public AITM_TenderOfferPDFController.GenerationDTO toGenerationDTO() {
            AITM_TenderOfferPDFController.GenerationDTO result = new AITM_TenderOfferPDFController.GenerationDTO();
            result.tenderId = this.tenderId;
            result.selectedFilter = this.selectedFilter;
            return result;
        }
    }

    /**
     * @description batch query builder
     */
    public class BatchQueryBuilder extends AITM_QueryBuilder {
        
        /**
         * @description gets customer query
         * @param  tenderId of type Id
         * @return string
         */
        public String getCustomersQuery(Id tenderId) {
            this.selectx(new Set<String>{'Id'});
            this.fromx('AITM_Tender_Account__c');
            this.wherex('AITM_Tender__c = \'' + tenderId + '\'');
            return this.getQuery();
        }
    }
}