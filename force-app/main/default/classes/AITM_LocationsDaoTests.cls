/**********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_LocationsDao

 * history
 * 01/December/2017  George      Created 
 * 11/June/2019      Ravi        Updated getTenderLocationsWithDeBriefLineItemsForFeedback and getTenderLocationsWithLineItemsForFeedbackcomments methods to TLLI                               
 ************************************************************************************************/
@isTest 
private inherited sharing class AITM_LocationsDaoTests {

    //
    public static final ID TLLI_ID_RECORD_TYPE_DEFAULT = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
    /**
     * @description tests to check search location results
     * @param  null
     * @return void
     */
    @isTest 
    static void testSearchLocationWillReturnValidResultOnValidInput() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        List<Id> fixedSearchResults = new List<Id>(new Map<Id, SObject>(testSetup.locations).keySet());

        Test.startTest();
            Test.setFixedSearchResults(fixedSearchResults);
            List<AITM_Location__c> results = testSetup.classUnderTest.searchLocations('Test');
        Test.stopTest();

        System.assertEquals(testSetup.locations.size(), results.size());
    }

    /**
     * @description tests to check delivery point by tender section location results
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetDeliveryPointByTenderSectorandLocationId() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        AITM_Location__c location = testSetup.locations[0];
        Set<String> sector = new Set<String>();
        sector.add('CA');
        sector.add('GA');

        Test.startTest();
            List<AITM_Delivery_Point__c> results = testSetup.classUnderTest.getDeliveryPoints(location.Id,sector);
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    /**
     * @description tests to check search location results
     * @param  null
     * @return void
     */
    @isTest 
    static void testLocationsSearchWillReturnVoidListOnVoidSearch() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        List<Id> fixedSearchResults = new List<Id>();

        Test.startTest();
            Test.setFixedSearchResults(fixedSearchResults);
            List<AITM_Location__c> results = testSetup.classUnderTest.searchLocations('Test');
        Test.stopTest();

        System.assertEquals(10, results.size());
    }

    /**
     * @description tests to check tender account by tender with valid id location results
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetTenderAccountsByTenderIdWillReturnTenderWillReturnAValidListForAValidTenderId() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderAccounts();

        Test.startTest();
            List<AITM_Tender_Account__c> results = testSetup.classUnderTest.getTenderAccountsByTenderId(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals([SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tender.Id], results.size());
    }

    /**
     * @description tests to check get location by id results
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetLocationById() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        
        Test.startTest();
            AITM_Location__c result = testSetup.classUnderTest.getLocationById(testSetup.locations[0].Id);
        Test.stopTest();

        System.assertEquals(result.Id, testSetup.locations[0].Id);
    }

    /**
     * @description tests to check tender location by tender account results
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetTenderLocationLineItemsByTenderAndAccountId() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        
        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> results = testSetup.classUnderTest.getTenderLocationLineItemsByTenderAndAccountId(testSetup.tender.Id,testSetup.accounts[0].Id);
        Test.stopTest();

        System.assertEquals(results.size(), [SELECT COUNT() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c =: testSetup.tender.Id AND AITM_Account__c =: testSetup.accounts[0].Id]);
    }

    /**
     * @description tests to check debrief location results
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetDebriefTenderLocationLineItems() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        
        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> results = testSetup.classUnderTest.getDebriefTenderLocationLineItems();
        Test.stopTest();

        System.assertEquals(results.size(), [SELECT COUNT() FROM AITM_Tender_Location_Line_Item__c WHERE RecordTypeId = :AITM_LocationsDao.TLLI_ID_RECORD_TYPE_DEBRIEF AND CreatedDate = LAST_N_DAYS:7]);
    }

    /**
     * @description tests to check locations with contacts results
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetLocationsWithContacts() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        Set<Id> locationIds = new Set<Id>();
        for(AITM_Location__c location : testSetup.locations) {
            locationIds.add(location.Id);
        }

        Test.startTest();
            List<AITM_Location__c> results = testSetup.classUnderTest.getLocationsWithContacts(locationIds);
        Test.stopTest();

        System.assertEquals(locationIds.size(), results.size());
    }

    /**
     * @description tests to check tender location market line items results
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetTenderLocationMarketLineItems() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        List<String> tenderResults = new List<String>();
        tenderResults.add('BG');
        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> results = testSetup.classUnderTest.getTenderLocationMarketLineItems(testSetup.tender.Id,tenderResults, AITM_LocationsDao.TLLI_ID_RECORD_TYPE_DEBRIEF);
        Test.stopTest();

        System.assertEquals(tenderResults.size(), 1);
    }

    /**
     * @description tests to check tender location staging items results
     * @param  null
     * @return void
     */
    @isTest 
    static void testTenderLocationStagingItems() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();

        Test.startTest();
        	    AITM_Tender_Location_Staging__c staging = new AITM_Tender_Location_Staging__c(
                AITM_Tender__c = testSetup.tender.Id,
                AITM_Account__c = testSetup.accounts[0].Id,
                AITM_Location__c = testSetup.locations[0].Id,
                AITM_Start_Date__c = Date.today(),
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0
            );
            insert staging;
        Test.stopTest();

        System.assertEquals(testSetup.tender.Id, staging.AITM_Tender__c);
    }

    /**
     * @description tests to check tender accounts by tenderid
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetTenderAccountsByTenderIdWillReturnAVoidListIfThereAreNoTenderAccounts() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();

        Test.startTest();
            List<AITM_Tender_Account__c> results = testSetup.classUnderTest.getTenderAccountsByTenderId(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    /**
     * @description tests to check tender accounts by tenderid
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetTenderAccountsByTenderIdWillReturnAVoidListIfTenderIdIsMalformed() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();

        Test.startTest();
            List<AITM_Tender_Account__c> results = testSetup.classUnderTest.getTenderAccountsByTenderId('sampletext');
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    /**
     * @description tests to check tender locations records creation
     * @param  null
     * @return void
     */
    @isTest 
    static void testSaveTenderLocationsWillCreateRecordsIfThereAreNoRecordsForTenderAccountCombination() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocationLineItems();

        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        Test.startTest();
            testSetup.classUnderTest.saveTenderLocations(testSetup.tenderLocations);
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size(), [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(tenderLocationVolume*testSetup.tenderLocations.size(), totalVolume);
    }

    /**
     * @description tests to check update tender locations for existing records
     * @param  null
     * @return void
     */
    @isTest 
    static void testSaveTenderLocationsWillUpdateRecordsIfTheyAreAlreadyCreated() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        
        testSetup.createTenderLocationLineItems();
        insert testSetup.tenderLocations;
        

        Test.startTest();
            for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
                tenderLocation.AITM_Volume__c = 5;
            }
            testSetup.classUnderTest.saveTenderLocations(testSetup.tenderLocations);
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size(), [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE Id IN :testSetup.tenderLocations]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(testSetup.tenderLocations.size(), totalVolume);
    }

    /**
     * @description tests to check save tender locations update records if adhoc
     * @param  null
     * @return void
     */
    @isTest 
    static void testSaveTenderLocationsWillUpdateRecordsIfTheyAreAdHocSoAllVolumesWillBeNull() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        
        testSetup.createTenderLocationLineItems();
        insert testSetup.tenderLocations;

        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
            tenderLocation.Id = null;
            tenderLocation.AITM_Volume__c = null;
            tenderLocation.AITM_Ad_hoc_Volume__c = true;
        }

        Test.startTest();
            testSetup.classUnderTest.saveTenderLocations(testSetup.tenderLocations);
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size()*2, [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c == null ? 0 : tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(tenderLocationVolume*testSetup.tenderLocations.size(), totalVolume);
    }

    /**
     * @description tests to check tender locations by tenderid
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetLocationsForTender() {

        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;

        testSetup.createTenderLocations();

        Test.startTest();
            List<AITM_Tender_Location__c> results = new AITM_LocationsDao().getTenderLocations(tenderId);
        Test.stopTest();

        System.assertEquals(testSetup.locations.size(), results.size());
    }

    /**
     * @description tests to check save tender locations through staging 
     * @param  null
     * @return void
     */
    @isTest 
    static void testSaveTenderLocationsThroughTheStagingWontCreateStagingObjectsAndWillActuallyCreateRecords() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            testSetup.classUnderTest.saveTenderLocations(testSetup.tenderLocations);
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size(), [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        System.assertEquals(0, [Select Count() FROM AITM_Tender_Location_Staging__c WHERE AITM_Tender__c = :testSetup.tender.Id]);   
    }

    /**
     * @description tests to check tender location staging
     * @param  null
     * @return void
     */
    @isTest 
    static void testConversionToTenderLocationStagingWillFullyCoverMatchingLineItem() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            AITM_Tender_Location_Staging__c result = testSetup.classUnderTest.parseLocationStaging(testSetup.tenderLocations[0]);
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations[0].AITM_Tender__c, result.AITM_Tender__c);
        System.assertEquals(testSetup.tenderLocations[0].AITM_Account__c, result.AITM_Account__c);
        System.assertEquals(testSetup.tenderLocations[0].AITM_Location__c, result.AITM_Location__c);
        System.assertEquals(testSetup.tenderLocations[0].AITM_Volume__c, result.AITM_Volume__c);
        System.assertEquals(testSetup.tenderLocations[0].AITM_Start_Date__c, result.AITM_Start_Date__c);
        System.assertEquals(testSetup.tenderLocations[0].AITM_End_Date__c, result.AITM_End_Date__c);
        System.assertEquals(testSetup.tenderLocations[0].AITM_Unit_Of_Measure__c, result.AITM_Unit_Of_Measure__c);
    }

    /**
     * @description tests to check tender location by tenderid
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetTenderLocationMethod() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;

        testSetup.createTenderLocations();

        List<AITM_Tender_Location__c> tenderLocations = new AITM_LocationsDao().getTenderLocations(tenderId);

        Test.startTest();
            AITM_Tender_Location__c tenderLocation = new AITM_LocationsDao().getTenderLocation(tenderLocations[0].Id);
        Test.stopTest();

        System.assertEquals(tenderLocations[0].AITM_Location__c, tenderLocation.AITM_Location__c);

    }

    /**
     * @description tests to check tender location line items upsert
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetTenderLocationLineItems() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;

        Account account = testSetup.createAccount();
        insert account;

        AITM_Location__c location = testSetup.createLocation();
        insert location;

        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;

        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();

        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;

        for(AITM_Tender_Location_Line_Item__c lineItem : items) {
            lineItem.RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        }
        update items;

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationItems = new AITM_LocationsDao().getTenderLocationLineItems(tenderLocation.Id);
            AITM_Tender_Location_Line_Item__c tenderLocationItem = new AITM_LocationsDao().getTenderLocationLineItem(tenderLocationItems[0].Id);
        Test.stopTest();

        System.assertEquals(lineItemsCount, tenderLocationItems.size());
        System.assertEquals(tenderLocationItem.Id, tenderLocationItems[0].Id);

    }

    /**
     * @description tests to check location group codes
     * @param  null
     * @return void
     */
    @isTest 
    static void getLocationGroupsByCodesTest() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        Set<String> codes = new Set<String>();
        codes.add('CY0');
        codes.add('Y0');

        Test.startTest();
        Map<String, Id> result = testSetup.classUnderTest.getLocationsGroupedByCodes(codes);
        Test.stopTest();

        System.assertEquals(2, result.size());
    }

    /**
     * @description tests to check tender locations round by tenderid
     * @param  null
     * @return void
     */
    @isTest 
    static void getTenderLocationsWithRoundTest() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();

        Test.startTest();
            List<AITM_Tender_Location__c> tenderLocationsResult = testSetup.classUnderTest.getTenderLocations(testSetup.tender.Id, 1);
        Test.stopTest();

        System.assertEquals(10, tenderLocationsResult.size());
    }

    /**
     * @description tests to check current round tender locations
     * @param  null
     * @return void
     */
    @isTest 
    static void getCurrentRoundTenderLocations() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();

        Test.startTest();
            List<AITM_Tender_Location__c> tenderLocationsResult = testSetup.classUnderTest.getCurrentRoundTenderLocations(testSetup.tender.id);
        Test.stopTest();

        System.assertEquals(10, tenderLocationsResult.size());
    }

    /**
     * @description tests to check tender accounts by ids
     * @param  null
     * @return void
     */
    @isTest 
    static void getTenderLocationsByIdsTest() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();

        AITM_Location__c location = testSetup.locations[0];
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(testSetup.tender.Id, location.Id);
        insert tenderLocation;

        Test.startTest();
            List<Id> tenderLocationIds = new List<Id>();
            tenderLocationIds.add(tenderLocation.Id);
            List<AITM_Tender_Location__c> tenderLocationsResult = testSetup.classUnderTest.getTenderLocationsByIds(tenderLocationIds);
        Test.stopTest();

        System.assertEquals(1, tenderLocationsResult.size());
    }

    /**
     * @description tests to check tender location line items by tenderid
     * @param  null
     * @return void
     */
    @isTest 
    static void getTenderLocationsWithLineItems() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();
        testSetup.createTenderLocationLineItems();
        
        Test.startTest();
            List<AITM_Tender_Location__c> tenderLocationsResult = testSetup.classUnderTest.getTenderLocationsWithLineItems(testSetup.tender.Id, new List<String>());
        Test.stopTest();

        System.assertEquals(10, tenderLocationsResult.size());
    }

    /**
     * @description tests to check tender location line itesm for feedback
     * @param  null
     * @return void
     */
    @isTest 
    static void getTenderLocationsWithLineItemsForFeedback() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationsResult = testSetup.classUnderTest.getTenderLocationsWithLineItemsForFeedback(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, tenderLocationsResult.size(), 'Tenderlocations with line items for Feedback result');
    }

    /**
     * @description tests to check tender location debrief items for feedback
     * @param  null
     * @return void
     */
    @isTest 
    static void getTenderLocationsWithDeBriefLineItemsForFeedback() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationsResult = testSetup.classUnderTest.getTenderLocationsWithDeBriefLineItemsForFeedback(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, tenderLocationsResult.size(), 'Tender Locations with Debrief line itmes feedback');
    }

    /**
     * @description tests to check tender location line items by tenderid
     * @param  null
     * @return void
     */
    @isTest 
    static void getTenderLocationLineItemsByTender() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationsResult = testSetup.classUnderTest.getTenderLocationLineItemsByTender(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, tenderLocationsResult.size(), 'Tenderlocations with line items result');
    }

    /**
     * @description tests to check tender location line items by tenderid
     * @param  null
     * @return void
     */
    @isTest 
    static void getTenderLocationLineItemsByTenderForXLS() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationsResult = testSetup.classUnderTest.getTenderLocationLineItemsByTenderForXLS(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, tenderLocationsResult.size(), 'Tenderlocations with line items result');
    }

    /**
     * @description tests to check tender location items debrief xls
     * @param  null
     * @return void
     */
    @isTest 
    static void getTenderLocationLineItemsByTenderForDebriefXLS() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationsResult = testSetup.classUnderTest.getTenderLocationLineItemsByTenderForDebriefXLS(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, tenderLocationsResult.size(), 'Tenderlocations with line items result');
    }

    /**
     * @description tests to check tender location items feedback xls
     * @param  null
     * @return void
     */
    @isTest 
    static void getTenderLocationLineItemsByTenderForFeedbackXLS() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationsResult = testSetup.classUnderTest.getTenderLocationLineItemsByTenderForFeedbackXLS(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, tenderLocationsResult.size(), 'Tenderlocations with line items result');
    }

    /**
     * @description tests to check tender location line items invitation xls
     * @param  null
     * @return void
     */
    @isTest 
    static void getTenderLocationLineItemsByTenderForInvitationXLS() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationsResult = testSetup.classUnderTest.getTenderLocationLineItemsByTenderForInvitationXLS(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, tenderLocationsResult.size(), 'Tenderlocations with line items result');
    }

    /**
     * @description tests to check tender locations by tenderid
     * @param  null
     * @return void
     */
    @isTest 
    static void getTenderLocationsTest() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        testSetup.createTenderLocations();

        Test.startTest();
            Set<Id> tenderLocationsIds = new Set<Id>();
            tenderLocationsIds.add(testSetup.tender.Id);
            List<AITM_Tender_Location__c> tenderLocationsResult = testSetup.classUnderTest.getTenderLocations(tenderLocationsIds);
        Test.stopTest();

        System.assertEquals(10, tenderLocationsResult.size());
    }

    /**
     * @description tests to check parsing location line items
     * @param  null
     * @return void
     */
    @isTest 
    static void parseLocationLineItemTest() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        Account acc = testSetup.getAccount();
        insert acc;
        AITM_Tender_Location_Staging__c stagingTestObj = testSetup.createTenderLocationStaging(testSetup.tender.Id, acc.Id, testSetup.locations[0].Id);

        Test.startTest();
            AITM_Tender_Location_Line_Item__c result = new AITM_LocationsDao().parseLocationLineItem(stagingTestObj);
        Test.stopTest();   

        System.assertEquals(stagingTestObj.AITM_Start_Date__c, result.AITM_Start_Date__c);
        System.assertEquals(stagingTestObj.AITM_End_Date__c, result.AITM_End_Date__c);
    }

    /**
     * @description tests to check cloned tender location items
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetTenderLocationLineItemsToClone() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;

        Account account = testSetup.createAccount();
        insert account;

        AITM_Location__c location = testSetup.createLocation();
        insert location;

        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;

        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();

        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;

        for(AITM_Tender_Location_Line_Item__c lineItem : items) {
            lineItem.RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        }
        update items;

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationItems = new AITM_LocationsDao().getTenderLocationLineItemsToClone(new List<AITM_Tender_Location__c>{tenderLocation});
        Test.stopTest();

        System.assertEquals(lineItemsCount, tenderLocationItems.size());
    }

    /**
     * @description tests to filtered tender location line items
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetFilteredTenderLocationLineItems() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;

        Account account = testSetup.createAccount();
        insert account;

        AITM_Location__c location = testSetup.createLocation();
        insert location;

        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;

        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();

        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
        for(AITM_Tender_Location_Line_Item__c lineItem : items) {
            lineItem.RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        }
        update items;

        List<String> criterias = new List<String>();
        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationItems = new AITM_LocationsDao().getFilteredTenderLocationLineItems(
                criterias, tenderId, TLLI_ID_RECORD_TYPE_DEFAULT
            );
        Test.stopTest();

        System.assertEquals(lineItemsCount, tenderLocationItems.size());
    }

    /**
     * @description tests to filtered tender location line items query builder
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetTenderLocationLineItemsTenderLocationLineItemsQueryBuilder() {
        LocationsDaoTestSetup testSetup = new LocationsDaoTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;

        Account account = testSetup.createAccount();
        insert account;

        AITM_Location__c location = testSetup.createLocation();
        insert location;

        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;

        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();

        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
        for(AITM_Tender_Location_Line_Item__c lineItem : items) {
            lineItem.RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        }
        update items;
        List<String> criterias = new List<String>();
        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationItems = new AITM_LocationsDao().getTenderLocationsLineItems(
                new List<AITM_Tender_Location__c>{tenderLocation}, new Set<String>{'AITM_Current_Round__c'}
            );
        Test.stopTest();

        System.assertEquals(lineItemsCount, tenderLocationItems.size());

    }

    /**
     * @description class for test data preparation
     * @param  null
     * @return void
     */
    private inherited sharing class LocationsDaoTestSetup extends AITM_TestSetup {
        public AITM_LocationsDao classUnderTest;

        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;

        public LocationsDaoTestSetup generateData(){
            classUnderTest = new AITM_LocationsDao();

            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            insert tender;
            
            return this;
        }

        public Account getAccount() {
            return createAccount();
        }

        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }

        public void createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
                for(AITM_Location__c location : locations){
                tenderLocations.add(
                    createTenderLocation(tender.Id, location.Id)
                );
            }
            insert tenderLocations;
        }

        public AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0
            );
        }
    }
}