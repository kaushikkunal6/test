/**************************************************************************
 * @author           George
 * @date             03/April/2018
 * @group            AirBP
 * @description      Test class for AITM_AddLocationsController

 * history
 * 03/April/2018     srnandan      Created AR-2726
 * 23/December/2018  srnandan      Modified AR-4842 assert statements corrected
 *******************************************************************/
@isTest 
private class AITM_AddLocationsControllerTests {

    @isTest 
    static void testLocationsSearchWillReturnValidResultOnValidSearchKey() {
        AddLocationsControllerTestSetup testSetup = new AddLocationsControllerTestSetup().generateData();
        List<Id> fixedSearchResults = new List<Id>(new Map<Id, SObject>(testSetup.locations).keySet());

        Test.startTest();
            Test.setFixedSearchResults(fixedSearchResults);
            List<AITM_Location__c> results = AITM_AddLocationsController.searchLocations(testSetup.tender.Id, 'Test');
        Test.stopTest();

        System.assertEquals(testSetup.locations.size(), results.size());
    }

    @isTest 
    static void testLocationsSearchWillReturnVoidListOnVoidSearch() {
        AddLocationsControllerTestSetup testSetup = new AddLocationsControllerTestSetup().generateData();
        List<Id> fixedSearchResults = new List<Id>();

        Test.startTest();
            Test.setFixedSearchResults(fixedSearchResults);
            List<AITM_Location__c> results = AITM_AddLocationsController.searchLocations(testSetup.tender.Id, 'Test');
        Test.stopTest();

        System.assertEquals(10, results.size());
    }

    @isTest 
    static void testWithoutTenderAccountsWillbeNotTenderLocationsAvailable() {
        AddLocationsControllerTestSetup testSetup = new AddLocationsControllerTestSetup().generateData();
        
        Test.startTest();
            List<AITM_AddLocationsController.TenderLocationWrapper> results = AITM_AddLocationsController.getTenderLocations(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    @isTest 
    static void testGetTenderLocationsWillReturnAListOfAllTenderLocationsWillZeroVolume() {
        AddLocationsControllerTestSetup testSetup = new AddLocationsControllerTestSetup().generateData();
        testSetup.createTenderAccounts();

        Test.startTest();
            List<AITM_AddLocationsController.TenderLocationWrapper> results = AITM_AddLocationsController.getTenderLocations(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(testSetup.accounts.size(), results.size());

        for (AITM_AddLocationsController.TenderLocationWrapper wrappedTender : results) {
            System.assertEquals(0, wrappedTender.volume);
            System.assertEquals(false, wrappedTender.isFilled());
            System.assertEquals(false, wrappedTender.isSelected);
            System.assertEquals(false, wrappedTender.adHocVolume);
        }
    }

    @isTest 
    static void testSaveTenderLocationsWrapperWillNotPeformSaveWhenNothingIsFilledUp() {
        AddLocationsControllerTestSetup testSetup = new AddLocationsControllerTestSetup().generateData();
        testSetup.createTenderAccounts();

        Test.startTest();
            List<AITM_AddLocationsController.TenderLocationWrapper> tenderLocations = AITM_AddLocationsController.getTenderLocations(testSetup.tender.Id);
            AITM_AddLocationsController.saveTenderLocations(JSON.serialize(tenderLocations),testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
    }

    @isTest 
    static void testSaveTenderLocationsWrapperWillPeformInsertWhenLocationAndVolumeAreFilled() {
        AddLocationsControllerTestSetup testSetup = new AddLocationsControllerTestSetup().generateData();
        testSetup.createTenderAccounts();

        Test.startTest();
            List<AITM_AddLocationsController.TenderLocationWrapper> tenderLocations = AITM_AddLocationsController.getTenderLocations(testSetup.tender.Id);
            for (AITM_AddLocationsController.TenderLocationWrapper tenderLocation : tenderLocations) {
                tenderLocation.locationId = testSetup.locations[0].Id;
                tenderLocation.volume = 1;
                tenderLocation.isSelected = true;
            }
            AITM_AddLocationsController.saveTenderLocations(JSON.serialize(tenderLocations),testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(10, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(10, totalVolume);
    }

    @isTest 
    static void testSaveTenderLocationsWrapperWillPeformUpdateWhenLocationAndVolumeAreFilledButRecordsExsisting() {
        AddLocationsControllerTestSetup testSetup = new AddLocationsControllerTestSetup().generateData();
        testSetup.createTenderAccounts();
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            List<AITM_AddLocationsController.TenderLocationWrapper> tenderLocations = AITM_AddLocationsController.getTenderLocations(testSetup.tender.Id);
            for (AITM_AddLocationsController.TenderLocationWrapper tenderLocation : tenderLocations) {
                tenderLocation.locationId = testSetup.locations[0].Id;
                tenderLocation.volume = 10;
                tenderLocation.isSelected = true;
            }
            
            AITM_AddLocationsController.saveTenderLocations(JSON.serialize(tenderLocations),testSetup.tender.Id);
        Test.stopTest();
        
        System.assertEquals(20, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(110, totalVolume);
    }

    @isTest 
    static void testSaveTenderLocationsWrapperWillPeformUpsertWhenLocationAndVolumeAreFilledButSomeRecordsExsisting() {
        AddLocationsControllerTestSetup testSetup = new AddLocationsControllerTestSetup().generateData();
        testSetup.createTenderAccounts();
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            List<AITM_AddLocationsController.TenderLocationWrapper> tenderLocations = AITM_AddLocationsController.getTenderLocations(testSetup.tender.Id);
            for (AITM_AddLocationsController.TenderLocationWrapper tenderLocation : tenderLocations) {
                tenderLocation.locationId = testSetup.locations[0].Id;
                tenderLocation.volume = 10;
                tenderLocation.isSelected = true;
            }
            AITM_AddLocationsController.saveTenderLocations(JSON.serialize(tenderLocations),testSetup.tender.Id);
        Test.stopTest();
        System.assertEquals(20, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(110, totalVolume);
    }

    private class AddLocationsControllerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;

        public AddLocationsControllerTestSetup generateData() {
            AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
			settings.AITM_IsActive__c = true;
			upsert settings AITM_DeactivateTriggerSetting__c.Id;
            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            insert tender;
            return this;
        }

        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        public void createTenderLocationLineItems() {
            insert createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }

        public void deleteTenderLocationLineItems(Integer rows) {
            delete [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tender.Id LIMIT :rows];
        }
    }
}