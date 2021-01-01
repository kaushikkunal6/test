@isTest 
private class AITM_TenderLocationStagingHandlerTests {
    @isTest 
    static void testOnASingleRecordCreationOnlyOneTenderLocationLineItemWillBeCreatedAndTheStagingRecordWillBeDeleted() {
        TenderLocationStagingHandlerTestSetup testSetup = new TenderLocationStagingHandlerTestSetup().generateData();

        Test.startTest();
            insert testSetup.stagingLocations[0];
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Account__c IN :testSetup.accounts AND AITM_Tender__c = :testSetup.tender.Id]);
        System.assertEquals(1, [SELECT Count() FROM AITM_Tender_Location_Staging__c WHERE AITM_Tender__c = :testSetup.tender.Id]);  
    }

    @isTest 
    static void testOnABulkRecordCreationMultipleenderLocationLineItemWillBeCreatedAndTheStagingRecordsWillBeDeleted() {
        TenderLocationStagingHandlerTestSetup testSetup = new TenderLocationStagingHandlerTestSetup().generateData();

        Test.startTest();
            insert testSetup.stagingLocations;
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Account__c IN :testSetup.accounts AND AITM_Tender__c = :testSetup.tender.Id]);
        System.assertEquals(testSetup.stagingLocations.size(), [SELECT Count() FROM AITM_Tender_Location_Staging__c WHERE AITM_Tender__c = :testSetup.tender.Id]); 
    }

    private class TenderLocationStagingHandlerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Staging__c> stagingLocations;

        public TenderLocationStagingHandlerTestSetup generateData() {

            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            insert tender;

            createTenderLocationStagings();

            return this;
        }

        public void createTenderLocationStagings() {
            stagingLocations = createTenderLocationStagings(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }
    }

}