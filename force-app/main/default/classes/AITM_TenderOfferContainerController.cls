/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      class for Generating Offer

 * history
 * 01/December/2017      George       Created
 * 18/December/2019      Kunal       Modified - added method refreshTaxesAndFees
 *******************************************************************/
public class AITM_TenderOfferContainerController {
    
    /**
     * @description getting filter option for offer
     * @param  tenderId of type Id
     * @return filterOption
     */
    public static @AuraEnabled List<AITM_RelatedRecordsHolderController.FilterOption> getFilterOptions(Id tenderId) {
        return AITM_RelatedTenderLocationsHolderCntrl.getFilterOptions(tenderId);
    }
    
    /**
     * @description call the batch process to generate offer
     * @param  tenderId of type String
     * @param  selectedFilter of type String
     * @return void
     */
    public static @AuraEnabled void attachOfferDocuments(String tenderId, String selectedFilter) {
        AITM_TenderOfferGenerateBatch.BatchState batchState = new AITM_TenderOfferGenerateBatch.BatchState(Id.valueOf(tenderId), selectedFilter);
        new AITM_TenderOfferGenerateBatch.BatchFactory().executeBatch(batchState);
    }
    
    /**
     * @description process to check the batch status
     * @param  null
     * @return String
     */
    public static @AuraEnabled String check() {
        AITM_TenderOfferGenerateBatch.BatchFactory factory = new AITM_TenderOfferGenerateBatch.BatchFactory();
        return factory.check();
    }
    
    /**
     * @description refresh fees records before offer generation
     * @param  tenderId of type String
     * @param  selectedFilter of type String
     * @return void
     */
    public static @AuraEnabled void refreshAndGenerateOffer(String tenderId, String selectedFilter) {
        refreshTaxesAndFees(tenderId, selectedFilter);
    }
    
    /**
     * @description refresh fees records before offer report generation
     * @param  tenderId of type String
     * @return void
     */
    public static @AuraEnabled void refreshAndGenerateRefreshedOfferReport(String tenderId) {
        refreshTaxesAndFees(tenderId, null);
    }
	
    /**
     * @description process to check the batch status
     * @param  null
     * @return String
     */
	public static @AuraEnabled String checkForTFRecords(){
        AITM_DeleteTaxFeeRecordsBatch.BatchFactory feeBatchfactory = new AITM_DeleteTaxFeeRecordsBatch.BatchFactory();
        AITM_TenderOfferGenerateBatch.BatchFactory offerBatchfactory = new AITM_TenderOfferGenerateBatch.BatchFactory();
        if(offerBatchfactory.check() == 'DONE' && feeBatchfactory.check() == 'DONE'){
            return 'DONE';
        } return 'INPROGRESS';
    }
    
    /**
     * @description call the batch process to delete and create new Fees records
     * @param  tenderId of type String
     * @param  selectedFilter of type String
     * @return void
     */
    public static void refreshTaxesAndFees(String tenderId, String selectedFilter){
        AITM_DeleteTaxFeeRecordsBatch.BatchState batchState = new AITM_DeleteTaxFeeRecordsBatch.BatchState(tenderId, AITM_LocationsDao.DEFAULT_RECORD_TYPE_ID, selectedFilter);
        new AITM_DeleteTaxFeeRecordsBatch.BatchFactory().executeBatch(batchState);
    }
    
    /**
     * @description process to check the batch status
     * @param  null
     * @return String
     */
    public static @AuraEnabled String checkForTFRecordsForReport() {
        AITM_DeleteTaxFeeRecordsBatch.BatchFactory feeBatchfactory = new AITM_DeleteTaxFeeRecordsBatch.BatchFactory();
        return feeBatchfactory.check();
    }
}