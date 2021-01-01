/************************************************************************************************
 * @author           Saravan
 * @date             10/May/2019
 * @group            AirBP
 * @description      Batch class used to delete the tender location line items once tender is deleted
 *                   
 * history
 * 10/May/2019   	 Saravan       Created
 **************************************************************************************************************/
public without sharing class AITM_DeleteTLLineItemsShareBatch implements Database.Batchable<SObject>, Database.Stateful {
   public BatchState state; 

   /**
     * @description overloaded constructor
     * @param  state of type BatchState
     */
    public AITM_DeleteTLLineItemsShareBatch(BatchState state) {
        this.state = state;
    } 


    /**
     * @description start
     * @param  context of type Database.BatchableContext
     * @return Iterable
     */
    public Iterable<SObject> start(Database.BatchableContext context) {
        return state.tenderLocationLineItemsShare;
    } 

    /**
     * @description execute
     * @param  context of type Database.BatchableContext
     * @param  scope of type List<AITM_Tender_Location_Line_Item__Share>
     * @return null
     */
    public void execute(Database.BatchableContext context,List<AITM_Tender_Location_Line_Item__Share> scope) {
        if (scope.size() > 0) {
            List<Database.DeleteResult> results = Database.delete(scope, false);           
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
    public without sharing class BatchFactory {

        private final Integer BATCH_SIZE = 100;
        private final String BATCH_JOB_NAME = 'AITM_DeleteTLLineItemsShareBatch';
        private final String RUNNING_STATE = 'INPROGRESS';
        private final String DONE_STATE = 'DONE';
        private final Set<String> RUNNING_JOB_STATUSES = new Set<String>{'Queued', 'Preparing', 'Processing'};

      /**
       * @description executeBatch
       * @param  state of type BatchState
       * @return null
       */
        public void executeBatch(BatchState state) {
            Database.executeBatch(new AITM_DeleteTLLineItemsShareBatch(state), BATCH_SIZE);
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
     * @description batchstate holds the details
     */    
    public without sharing class BatchState {
        public List<AITM_Tender_Location_Line_Item__Share> tenderLocationLineItemsShare;
      
        /**
         * @description batch state
         */
        public BatchState(List<AITM_Tender_Location_Line_Item__Share> tenderLocationLineItemsShare) {
            this.tenderLocationLineItemsShare = tenderLocationLineItemsShare;
        }
    }    
}