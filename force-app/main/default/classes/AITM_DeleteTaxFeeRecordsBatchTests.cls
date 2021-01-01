/***************************************************************
 * @author           Kunal
 * @date             17/Dec/2019
 * @group            AirBP
 * @description      Test class for AITM_DeleteTaxFeeRecordsBatch

 * history
 * 17/Dec/2019  	 Kunal       Created 
 **********************************************************/
@isTest
private inherited sharing class AITM_DeleteTaxFeeRecordsBatchTests {
    
    /**
     * @description test should create tax and fee records
     * @param null
     * @return void
     */
    @isTest 
    static void testBatchShouldCreateTaxFeeRecords() {
        AITM_DeleteTaxFeeRecordsBatch testSetup = new AITM_DeleteTaxFeeRecordsBatch().generateData();
        AITM_Tender_Location_Line_Item__c defaultLineItem = testSetup.defaultLineItem;
        AITM_DeleteTaxFeeRecordsBatch.BatchFactory batchFactory = new AITM_DeleteTaxFeeRecordsBatch.BatchFactory();
        
        Test.startTest();
            batchFactory.executeBatch(new AITM_DeleteTaxFeeRecordsBatch.BatchState(testSetup.getRandomTenderId(), AITM_LocationsDao.DEFAULT_RECORD_TYPE_ID, null));
        Test.stopTest();

        System.assertEquals(1, new List<AITM_Tender_Location_Line_Item__c>{defaultLineItem}.size());
    }

    
    /**
     * @description class holds test data preparation
     */
    private inherited sharing class AITM_DeleteTaxFeeRecordsBatch extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;          
        public AITM_Tender_Location_Taxes_and_Fees__c locationTaxAndFee;
        public AITM_Taxes_Fees__c masterTFRecord;
        public AITM_Tender_Location_Line_Item__c debriefLineItem;
        public AITM_Tender_Location_Line_Item__c defaultLineItem;
        public AITM_Tender_Location__c straddledLocation;

        /**
         * @description generates test data
         * @param  null
         * @return InsertTenderLocationLineItemsBatch
         */
        private AITM_DeleteTaxFeeRecordsBatch generateData(){

            accounts = createAccounts(1);
            insert accounts;

            tender = createTender();
            tender.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false;
            insert tender;
            
            locations = createLocations(1);
            insert locations;
            
            straddledLocation = createStraddledTenderLocation(tender.Id, locations[0].Id);
            straddledLocation.AITM_Current_Round__c = 1;
            insert straddledLocation;
            defaultLineItem = createStraddledTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id, straddledLocation.Id);
            defaultLineItem.AITM_Record_Type_Name__c = 'Default';
            defaultLineItem.AITM_Round__c = 1;
            insert defaultLineItem;
            masterTFRecord = createMasterDataTaxesAndFees();
            insert masterTFRecord; 
            locationTaxAndFee = createTenderLocationTaxesAndFee(defaultLineItem.Id);
            insert locationTaxAndFee;

            return this;
        }
        
        public Id getRandomTenderId() {
            AITM_Tender__c result = createTender();
            insert result;
            return result.Id;
        }
    }
}