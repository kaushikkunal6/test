/***************************************************************
 * @author           Kunal
 * @date             28/May/2019
 * @group            AirBP
 * @description      Test class for AITM_TenderLocationTaxFeeBatch

 * history
 * 28/May/2019  	 Kunal       Created 
 **********************************************************/
@isTest 
public inherited sharing class AITM_TenderLocationTaxFeeBatchTests {
    
    /**
     * @description tests to run the batch
     * @param  null
     * @return void
     */
    @isTest  
    static void testInsertTenderLocationTaxFee() {
        InsertTenderLocationTaxFeeBatch testSetup = new InsertTenderLocationTaxFeeBatch().generateData();      
        AITM_Tender_Location_Line_Item__c defaultLineItem = testSetup.defaultLineItem;
        AITM_Tender_Location_Line_Item__c debriefLineItem = testSetup.debriefLineItem;

        AITM_TenderLocationTaxFeeBatch batchFactory = new AITM_TenderLocationTaxFeeBatch(testSetup.tender.Id, 'insert');
        
        Test.startTest();
            Database.executeBatch(batchFactory);
        Test.stopTest();
		
        System.assertEquals(1, new List<AITM_Tender_Location_Line_Item__c>{debriefLineItem}.size(), 'Batch processing is success');
    }
    
    /**
     * @description class holds test data preparation
     */
    private inherited sharing class InsertTenderLocationTaxFeeBatch extends AITM_TestSetup {
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
        private InsertTenderLocationTaxFeeBatch generateData(){

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