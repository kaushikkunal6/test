/*******************************************************************
 * @author           Kunal
 * @date             01/October/2020
 * @group            AirBP
 * @description      Test class for AITM_RefreshTaxFeeRecordsBatch
 *******************************************************************/
@isTest 
private with sharing class AITM_RefreshTaxFeeRecordsBatchTests {
    
    /**
     * @description tests to run the batch
     * @param  null
     * @return void
     */
    @isTest  
    static void testProcessLineItemBasedOnCountries() {    
        AITM_RefreshTaxFeeRecordsBatchSetup testSetup = new AITM_RefreshTaxFeeRecordsBatchSetup().generateData();
        AITM_Tender_Location_Line_Item__c defaultLineItem = testSetup.defaultLineItem;
        AITM_RefreshTaxFeeRecordsBatch.BatchFactory batchFactory = new AITM_RefreshTaxFeeRecordsBatch.BatchFactory();
        
        
        Test.startTest();
            batchFactory.executeBatch(new AITM_RefreshTaxFeeRecordsBatch.BatchState(testSetup.tender.Id, 'Notes', 'Countries', new List<String>{'London heathrow'}, 'Default', true));
        Test.stopTest();
		
        System.assertEquals(1, new List<AITM_Tender_Location_Line_Item__c>{defaultLineItem}.size(), 'Batch processing is success');
    }
    
    /**
     * @description tests to run the batch
     * @param  null
     * @return void
     */
    @isTest  
    static void testProcessLineItemBasedOnALLLocations() {    
        AITM_RefreshTaxFeeRecordsBatchSetup testSetup = new AITM_RefreshTaxFeeRecordsBatchSetup().generateData();
        AITM_Tender_Location_Line_Item__c defaultLineItem = testSetup.defaultLineItem;
        AITM_RefreshTaxFeeRecordsBatch.BatchFactory batchFactory = new AITM_RefreshTaxFeeRecordsBatch.BatchFactory();
        
        
        Test.startTest();
            batchFactory.executeBatch(new AITM_RefreshTaxFeeRecordsBatch.BatchState(testSetup.tender.Id, 'Notes', 'All Locations', new List<String>{'London heathrow'}, 'Default', true));
        Test.stopTest();
		
        System.assertEquals(1, new List<AITM_Tender_Location_Line_Item__c>{defaultLineItem}.size(), 'Batch processing is success');
    }
    
    /**
     * @description tests to run the batch
     * @param  null
     * @return void
     */
    @isTest  
    static void testProcessLineItemBasedOnManagers() {    
        AITM_RefreshTaxFeeRecordsBatchSetup testSetup = new AITM_RefreshTaxFeeRecordsBatchSetup().generateData();
        AITM_Tender_Location_Line_Item__c defaultLineItem = testSetup.defaultLineItem;
        AITM_RefreshTaxFeeRecordsBatch.BatchFactory batchFactory = new AITM_RefreshTaxFeeRecordsBatch.BatchFactory();
        
        
        Test.startTest();
            batchFactory.executeBatch(new AITM_RefreshTaxFeeRecordsBatch.BatchState(testSetup.tender.Id, 'Taxes', 'All Locations', new List<String>{'London heathrow'}, 'Default', true));
        Test.stopTest();
		
        System.assertEquals(1, new List<AITM_Tender_Location_Line_Item__c>{defaultLineItem}.size(), 'Batch processing is success');
    }
    
    /**
     * @description tests to run the batch
     * @param  null
     * @return void
     */
    @isTest  
    static void testProcessLineItemBasedOnLocation() {    
        AITM_RefreshTaxFeeRecordsBatchSetup testSetup = new AITM_RefreshTaxFeeRecordsBatchSetup().generateData();
        AITM_Tender_Location_Line_Item__c defaultLineItem = testSetup.defaultLineItem;
        AITM_RefreshTaxFeeRecordsBatch.BatchFactory batchFactory = new AITM_RefreshTaxFeeRecordsBatch.BatchFactory();
        
        
        Test.startTest();
            batchFactory.executeBatch(new AITM_RefreshTaxFeeRecordsBatch.BatchState(testSetup.tender.Id, 'TaxesWithNotes', 'Location(s)', new List<String>{'London heathrow'}, 'Default', true));
        Test.stopTest();
		
        System.assertEquals(1, new List<AITM_Tender_Location_Line_Item__c>{defaultLineItem}.size(), 'Batch processing is success');
    }
    
    /**
     * @description class holds test data preparation
     */
    private inherited sharing class AITM_RefreshTaxFeeRecordsBatchSetup extends AITM_TestSetup {
        private List<Account> accounts;
        private List<AITM_Location__c> locations;
        private AITM_Tender__c tender;          
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
        private AITM_RefreshTaxFeeRecordsBatchSetup generateData(){

            accounts = createAccounts(1);
            insert accounts;

            tender = createTender();
            insert tender;
            
            locations = createLocations(1);
            insert locations;
            
            straddledLocation = createStraddledTenderLocation(tender.Id, locations[0].Id);
            insert straddledLocation;
            defaultLineItem = createStraddledTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id, straddledLocation.Id);
            defaultLineItem.AITM_Record_Type_Name__c = 'Default';
            insert defaultLineItem;
            debriefLineItem = createStraddledTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id, straddledLocation.Id);
            debriefLineItem.AITM_Record_Type_Name__c = 'De-brief';
            debriefLineItem.AITM_Previous_TLLI_Id__c = defaultLineItem.Id;
            insert debriefLineItem;
            masterTFRecord = createMasterDataTaxesAndFees();
            insert masterTFRecord; 
            locationTaxAndFee = createTenderLocationTaxesAndFee(defaultLineItem.Id);
            insert locationTaxAndFee;

            return this;
        }
    }
}