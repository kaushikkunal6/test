/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_DeBriefResultsController

 * history
 * 01/December/2017  George       Created
 * 27/March/2018     srnandan     Modified - AR- 2730 - test method "toTenderLocationLineItemTest"
 *                                to resolve test class failure 
 *                                added method level comments as per coding standards
 * 29/May/2018       srnandan     Modified - AR-3169 - Credit Days conversion Numeric to picklist 
 * 10/Aug/2018       Shweta       Modified - Method testSaveWillUpdateTheRecordsWithTenderResult() to fix the sonar qube error
 * 04/December/2018  srnandan     Modified - AR-4630 added new test methods and modified existing save operation
 *******************************************************************/
@IsTest 
private with sharing class AITM_DeBriefResultsControllerTests {

    public static final ID ID_TLLI_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();

    /**
     * @description tests to verify DeBrief record results initialization
     * @param  null
     * @return void
     */
    @isTest  
    static void testInitializeDeBriefResultsWillReturnDeBriefResultsInitializationAdapterWillFieldsAreFilled() {
        DeBriefResultsControllerTestSetup setup = new DeBriefResultsControllerTestSetup().generateData();

        Test.startTest();
            AITM_DeBriefResultsController.DeBriefResultsInitializationAdapter result = AITM_DeBriefResultsController.initializeDeBriefResults(setup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, result.results.size());
        System.assertEquals(false, result.editable);
        System.assertEquals(6, result.options.size());
    }

    /**
     * @description tests to verify DeBrief record result is editable or not
     * @param  null
     * @return void
     */
    @isTest  
    static void testInitializeDeBriefResultsWillReturnDeBriefResultsInitializationAdapterWillReturnEditableForDeBriefTender() {
        DeBriefResultsControllerTestSetup setup = new DeBriefResultsControllerTestSetup().generateData();
        setup.updateTenderToDeBrief();

        Test.startTest();
            AITM_DeBriefResultsController.DeBriefResultsInitializationAdapter result = AITM_DeBriefResultsController.initializeDeBriefResults(setup.tender.Id);
        Test.stopTest();

        System.assertEquals(true, result.editable);
    }

    /**
     * @description tests to verify the update records results
     * @param  null
     * @return void
     */
    @isTest  
    static void testSaveWillUpdateTheRecordsWithTenderResult() {
        DeBriefResultsControllerTestSetup setup = new DeBriefResultsControllerTestSetup().generateData();
        setup.createTenderAccounts();
        setup.updateTenderToDeBrief();
        setup.createTenderLocationLineItems();

        AITM_DeBriefResultsController.DeBriefResultsInitializationAdapter initializationResult = AITM_DeBriefResultsController.initializeDeBriefResults(setup.tender.Id);
        for (AITM_DeBriefResultsController.DeBriefResultsAdapter adapter : initializationResult.results) {
            adapter.result = initializationResult.options.get(1);
        }

        Test.startTest();
            String result = AITM_DeBriefResultsController.save(JSON.serialize(initializationResult.results));
        Test.stopTest();

        System.assert(String.isBlank(result), result);
        System.assertEquals(setup.accounts.size()*setup.locations.size(), [SELECT Count() FROM AITM_Tender_Location_Line_Item__c LIMIT 100 ]);
    }

    /**
     * @description tests to verify location mismatch filter option selected returns valid list
     * @param  null
     * @return void
     */
    @isTest  
    static void testWithLocationMismatchFilterOptionSelectedValidListWillBeReturned() {
        DeBriefResultsControllerTestSetup testSetup = new DeBriefResultsControllerTestSetup().generateData();
        AITM_Tender_Location__c tenderLocation = testSetup.getTenderLocationWithLocationsWithVolumeMismatch();

        Test.startTest();
            List<AITM_DeBriefResultsController.DeBriefResultsAdapter> adapters = AITM_DeBriefResultsController.loadDeBriefDetails(testSetup.tender.Id, testSetup.getLocationMismatchJSON());
        Test.stopTest();

        System.assertEquals(0, adapters.size());
    }

    /**
     * @description tests to verify location adhoc selected selected returns valid list
     * @param  null
     * @return void
     */
    @isTest  
    static void testWithLocationAdHocSelectedValidListWillBeReturned() {
        DeBriefResultsControllerTestSetup testSetup = new DeBriefResultsControllerTestSetup().generateData();
        AITM_Tender_Location__c tenderLocation = testSetup.getTenderLocationWithAdHoc();

        Test.startTest();
            List<AITM_DeBriefResultsController.DeBriefResultsAdapter> adapters = AITM_DeBriefResultsController.loadDeBriefDetails(testSetup.tender.Id, testSetup.getAdHocJSON());
        Test.stopTest();
    
        System.assertEquals(0, adapters.size());
    }

    /**
     * @description tests to verify location with quotes selected returns valid list
     * @param  null
     * @return void
     */
    @isTest  
    static void testWithLocationsWithQuotesSelectedValidListWillBeReturned() {
        DeBriefResultsControllerTestSetup testSetup = new DeBriefResultsControllerTestSetup().generateData();
        AITM_Tender_Location__c tenderLocation = testSetup.getTenderLocationWithQuotes();

        Test.startTest();
            List<AITM_DeBriefResultsController.DeBriefResultsAdapter> adapters = AITM_DeBriefResultsController.loadDeBriefDetails(testSetup.tender.Id, testSetup.getLocationsWithQuotes());
        Test.stopTest();
    
        System.assertEquals(0, adapters.size());
    }
	
    /**
     * @description tests to verify locations without quotes selected returns valid list
     * @param  null
     * @return void
     */
    @isTest  
    static void testWithLocationsWithoutQuotesSelectedValidListWillBeReturned() {
        DeBriefResultsControllerTestSetup testSetup = new DeBriefResultsControllerTestSetup().generateData();
        AITM_Tender_Location__c tenderLocation = testSetup.getTenderLocationWithoutQuotes();

        Test.startTest();
            List<AITM_DeBriefResultsController.DeBriefResultsAdapter> adapters = AITM_DeBriefResultsController.loadDeBriefDetails(testSetup.tender.Id, testSetup.getLocationsWithoutQuotes());
        Test.stopTest();
    
        System.assertEquals(0, adapters.size());
    }
	
    /**
     * @description tests to verify business gained locations returns valid list
     * @param  null
     * @return void
     */
    @isTest  
    static void testWithBusinessGainedLocationsSelectedValidListWillBeReturned() {
        DeBriefResultsControllerTestSetup testSetup = new DeBriefResultsControllerTestSetup().generateData();
        AITM_Tender_Location__c tenderLocation = testSetup.getTenderLocationWithTenderResult('BG');

        Test.startTest();
            List<AITM_DeBriefResultsController.DeBriefResultsAdapter> adapters = AITM_DeBriefResultsController.loadDeBriefDetails(testSetup.tender.Id, testSetup.getBusinessGainedLocations());
        Test.stopTest();
    
        System.assertEquals(0, adapters.size());
    }

    /**
     * @description tests to verify location mismatch filter option selected returns valid list
     * @param  null
     * @return void
     */
    @isTest  
    static void testWithBusinessRetainedLocationsSelectedValidListWillBeReturned() {
        DeBriefResultsControllerTestSetup testSetup = new DeBriefResultsControllerTestSetup().generateData();
        AITM_Tender_Location__c tenderLocation = testSetup.getTenderLocationWithTenderResult('BR');

        Test.startTest();
            List<AITM_DeBriefResultsController.DeBriefResultsAdapter> adapters = AITM_DeBriefResultsController.loadDeBriefDetails(testSetup.tender.Id, testSetup.getBusinessRetainedLocations());
        Test.stopTest();
    
        System.assertEquals(0, adapters.size());
    }

    /**
     * @description tests to verify business lost location selected returns valid list
     * @param  null
     * @return void
     */
    @isTest  
    static void testWithBusinessLostLocationsSelectedValidListWillBeReturned() {
        DeBriefResultsControllerTestSetup testSetup = new DeBriefResultsControllerTestSetup().generateData();
        AITM_Tender_Location__c tenderLocation = testSetup.getTenderLocationWithTenderResult('LB');

        Test.startTest();
            List<AITM_DeBriefResultsController.DeBriefResultsAdapter> adapters = AITM_DeBriefResultsController.loadDeBriefDetails(testSetup.tender.Id, testSetup.getBusinessLostLocations());
        Test.stopTest();
    
        System.assertEquals(0, adapters.size());
    }

    /**
     * @description tests to verify market info location selected valid list
     * @param  null
     * @return void
     */
    @isTest  
    static void testWithMarketInfoLocationsLocationsSelectedValidListWillBeReturned() {
        DeBriefResultsControllerTestSetup testSetup = new DeBriefResultsControllerTestSetup().generateData();
        AITM_Tender_Location__c tenderLocation = testSetup.getTenderLocationWithTenderResult('MI');

        Test.startTest();
            List<AITM_DeBriefResultsController.DeBriefResultsAdapter> adapters = AITM_DeBriefResultsController.loadDeBriefDetails(testSetup.tender.Id, testSetup.getMarketInfoLocations());
        Test.stopTest();
    
        System.assertEquals(0, adapters.size());
    }

    /**
     * @description tests to verify filtered tendered locations selectivity flag
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilteredTenderLocationsWithselectivityFlagTest() {
        DeBriefResultsControllerTestSetup testSetup = new DeBriefResultsControllerTestSetup().generateData();
        AITM_RelatedRecordsHolderController.FilterOption options = new AITM_RelatedRecordsHolderController.FilterOption('Business Gained', false);
        AITM_Tender_Location__c tenderLocation = testSetup.getTenderLocationWithTenderResult('BG');

        Test.startTest();
            List<AITM_DeBriefResultsController.DeBriefResultsAdapter> deBriefResults = AITM_DeBriefResultsController.getFilteredTenderLocations(testSetup.tender.id, options, true);
        Test.stopTest();
        
        System.assertEquals(0, deBriefResults.size());
       
    }
	
    /**
     * @description tests to verify filtered DeBrief tender locations results size
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilteredTenderLocationsTest() {
        DeBriefResultsControllerTestSetup testSetup = new DeBriefResultsControllerTestSetup().generateData();
        AITM_RelatedRecordsHolderController.FilterOption options = new AITM_RelatedRecordsHolderController.FilterOption('Business Gained', false);
        
        AITM_Tender_Location__c tenderLocation = testSetup.getTenderLocationWithTenderResult('BG');

        Test.startTest();
            List<AITM_DeBriefResultsController.DeBriefResultsAdapter> deBriefResults = AITM_DeBriefResultsController.getFilteredTenderLocations(testSetup.tender.id, options);
        Test.stopTest();
        if(deBriefResults.size() > 0){
            AITM_DeBriefResultsController.DeBriefResultsAdapter result = deBriefResults.get(0);           
        }
        System.assertEquals(0, deBriefResults.size());
    }
	
    /**
     * @description tests to verify location line item tender result and awarded volume
     * @param  null
     * @return void
     */
    @isTest  
    static void toTenderLocationLineItemTest() {
        DeBriefResultsControllerTestSetup testSetup = new DeBriefResultsControllerTestSetup().generateData();
        testSetup.createTenderAccounts();
        testSetup.createTenderLocationLineItems();
        AITM_Tender_Location_Line_Item__c testItem = testSetup.lineItems[0];
        testItem.AITM_Requested_Volume_USG__c = 140;
        testItem.AITM_Offered_Volume__c = 140;
        testItem.AITM_Tender_Result__c = 'BG';
        update testItem;

        Test.startTest();
            AITM_DeBriefResultsController.DeBriefResultsAdapter adaper = new AITM_DeBriefResultsController.DeBriefResultsAdapter(testItem);
            AITM_Tender_Location_Line_Item__c result = adaper.toTenderLocationLineItem();  
        Test.stopTest();

        System.assertEquals('BG', result.AITM_Tender_Result__c);
        System.assertEquals(140, result.AITM_Awarded_Volume__c);
    }

    /**
     * @description test data holder DeBriefResults controller inner class
     */
    private with sharing class DeBriefResultsControllerTestSetup extends AITM_TestSetup {        
        private List<Account> accounts;
        private List<AITM_Location__c> locations;
        private AITM_Tender__c tender;
        private List<AITM_Tender_Location_Line_Item__c> lineItems;
        private final Id debriefRecordType = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();

        /**
         * @description generates the test data for account, Location, Tender
         * for the test class
         * @param  null
         * @return DeBriefResultsControllerTestSetup
         */
        private DeBriefResultsControllerTestSetup generateData(){
            AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
			settings.AITM_IsActive__c = true;
			upsert settings AITM_DeactivateTriggerSetting__c.Id;           
            accounts = createAccounts(1);
            insert accounts;

            locations = createLocations(1);
            insert locations;

            tender = createTender();
            insert tender;
            return this;
        }

        /**
         * @description updates tender to DeBrief stage
         * @param  null
         * @return void
         */
        private void updateTenderToDeBrief() {
            tender.AITM_Stage__c = 'Debrief';
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            update tender;
        }

        /**
         * @description creates the test data for TenderAccounts 
         * @param  null
         * @return void
         */
        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }
        
        /**
         * @description creates the test data for TenderLocationslineitems 
         * @param  null
         * @return void
         */
        private void createTenderLocationLineItems() {
            lineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
            for(AITM_Tender_Location_Line_Item__c lineItem : lineItems){
                lineItem.RecordTypeId = AITM_DeBriefResultsControllerTests.ID_TLLI_RECORD_TYPE_DEBRIEF;
            }
            insert lineItems;
        }

        /**
         * @description gets the TenderLocation with Volume mismatch record 
         * @param  null
         * @return AITM_Tender_Location__c
         */
        private AITM_Tender_Location__c getTenderLocationWithLocationsWithVolumeMismatch() {
            AITM_Tender_Location__c result = createTenderLocation(tender.Id, locations[0].Id);
            insert result;

            AITM_Tender_Location_Line_Item__c lineItem1 = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            lineItem1.AITM_Tender_Location__c = result.Id;
            lineItem1.AITM_Offered_Volume__c = 100;
            lineItem1.AITM_Volume__c = 100;
            lineItem1.AITM_Unit_Of_Measure__c = 'USG';
            lineItem1.RecordTypeId = AITM_DeBriefResultsControllerTests.ID_TLLI_RECORD_TYPE_DEBRIEF;
            insert lineItem1;

            AITM_Tender_Location_Line_Item__c lineItem2 = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            lineItem2.AITM_Tender_Location__c = result.Id;
            lineItem2.AITM_Offered_Volume__c = 100;
            lineItem2.AITM_Volume__c = 200;
            lineItem2.AITM_Unit_Of_Measure__c = 'USG';
            lineItem2.RecordTypeId = AITM_DeBriefResultsControllerTests.ID_TLLI_RECORD_TYPE_DEBRIEF;
            insert lineItem2;

            result = new AITM_LocationsDao().getTenderLocationsWithLineItems(tender.Id, null)[0];
            return result;
        }

        /**
         * @description gets the TenderLocation with Adhoc
         * @param  null
         * @return AITM_Tender_Location__c
         */
        private AITM_Tender_Location__c getTenderLocationWithAdHoc() {
            AITM_Tender_Location__c result = createTenderLocation(tender.Id, locations[0].Id);
            insert result;

            AITM_Tender_Location_Line_Item__c lineItem1 = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            lineItem1.AITM_Tender_Location__c = result.Id;
            lineItem1.AITM_Ad_hoc_Volume__c = true;
            lineItem1.AITM_Volume__c = null;
            lineItem1.RecordTypeId = AITM_DeBriefResultsControllerTests.ID_TLLI_RECORD_TYPE_DEBRIEF;
            insert lineItem1;

            AITM_Tender_Location_Line_Item__c lineItem2 = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            lineItem2.AITM_Tender_Location__c = result.Id;
            lineItem2.AITM_Ad_hoc_Volume__c = false;
            lineItem2.AITM_Volume__c = 1;
            lineItem2.RecordTypeId = AITM_DeBriefResultsControllerTests.ID_TLLI_RECORD_TYPE_DEBRIEF;
            insert lineItem2;

            result = new AITM_LocationsDao().getTenderLocationsWithLineItems(tender.Id, null)[0];
            return result;
        }

        /**
         * @description gets the TenderLocation with Quotes
         * @param  null
         * @return AITM_Tender_Location__c
         */
        private AITM_Tender_Location__c getTenderLocationWithQuotes() {
            AITM_Tender_Location__c result = createTenderLocation(tender.Id, locations[0].Id);
            insert result;

            AITM_Tender_Location_Line_Item__c lineItem1 = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            lineItem1.AITM_Tender_Location__c = result.Id;
            lineItem1.AITM_Offered_Volume__c = 100;
            lineItem1.AITM_Volume__c = 100;
            lineItem1.AITM_Unit_Of_Measure__c = 'USG';
            lineItem1.AITM_Offered_Differential__c = 10;
            lineItem1.RecordTypeId = AITM_DeBriefResultsControllerTests.ID_TLLI_RECORD_TYPE_DEBRIEF;
            insert lineItem1;

            AITM_Tender_Location_Line_Item__c lineItem2 = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            lineItem2.AITM_Tender_Location__c = result.Id;
            lineItem2.AITM_Offered_Volume__c = 100;
            lineItem2.AITM_Volume__c = 100;
            lineItem2.AITM_Offered_Differential__c = 10;
            lineItem2.AITM_Unit_Of_Measure__c = 'USG';
            lineItem2.RecordTypeId = AITM_DeBriefResultsControllerTests.ID_TLLI_RECORD_TYPE_DEBRIEF;
            insert lineItem2;

            result = new AITM_LocationsDao().getTenderLocationsWithLineItems(tender.Id, null)[0];
            return result;
        }

        /**
         * @description gets the TenderLocation without Quotes 
         * @param  null
         * @return AITM_Tender_Location__c
         */
        private AITM_Tender_Location__c getTenderLocationWithoutQuotes() {
            AITM_Tender_Location__c result = createTenderLocation(tender.Id, locations[0].Id);
            insert result;

            AITM_Tender_Location_Line_Item__c lineItem1 = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            lineItem1.AITM_Tender_Location__c = result.Id;
            lineItem1.AITM_Offered_Volume__c = 100;
            lineItem1.AITM_Volume__c = 100;
            lineItem1.AITM_Unit_Of_Measure__c = 'USG';
            lineItem1.AITM_Offered_Differential__c = null;
            lineItem1.RecordTypeId = AITM_DeBriefResultsControllerTests.ID_TLLI_RECORD_TYPE_DEBRIEF;
            insert lineItem1;

            AITM_Tender_Location_Line_Item__c lineItem2 = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            lineItem2.AITM_Tender_Location__c = result.Id;
            lineItem2.AITM_Offered_Volume__c = 100;
            lineItem2.AITM_Volume__c = 100;
            lineItem2.AITM_Offered_Differential__c = null;
            lineItem2.AITM_Unit_Of_Measure__c = 'USG';
            lineItem2.RecordTypeId = AITM_DeBriefResultsControllerTests.ID_TLLI_RECORD_TYPE_DEBRIEF;
            insert lineItem2;

            result = new AITM_LocationsDao().getTenderLocationsWithLineItems(tender.Id, null)[0];
            return result;
        }

        /**
         * @description gets the TenderLocation with Tender result
         * @param  tenderResult of type string
         * @return AITM_Tender_Location__c
         */
        private AITM_Tender_Location__c getTenderLocationWithTenderResult(String tenderResult) {
            AITM_Tender_Location__c result = createTenderLocation(tender.Id, locations[0].Id);
            insert result;

            AITM_Tender_Location_Line_Item__c lineItem1 = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            lineItem1.AITM_Tender_Location__c = result.Id;
            lineItem1.AITM_Offered_Volume__c = 100;
            lineItem1.AITM_Volume__c = 100;
            lineItem1.AITM_Unit_Of_Measure__c = 'USG';
            lineItem1.AITM_Offered_Differential__c = null;
            lineItem1.AITM_Tender_Result__c = tenderResult;
            lineItem1.RecordTypeId = AITM_DeBriefResultsControllerTests.ID_TLLI_RECORD_TYPE_DEBRIEF;
            insert lineItem1;

            AITM_Tender_Location_Line_Item__c lineItem2 = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            lineItem2.AITM_Tender_Location__c = result.Id;
            lineItem2.AITM_Offered_Volume__c = 100;
            lineItem2.AITM_Volume__c = 100;
            lineItem2.AITM_Offered_Differential__c = null;
            lineItem2.AITM_Unit_Of_Measure__c = 'USG';
            lineItem1.AITM_Tender_Result__c = tenderResult;
            lineItem2.RecordTypeId = AITM_DeBriefResultsControllerTests.ID_TLLI_RECORD_TYPE_DEBRIEF;
            insert lineItem2;

            result = new AITM_LocationsDao().getTenderLocationsWithLineItems(tender.Id, null)[0];
            return result;
        }

        /**
         * @description gets the TenderLocation with Volume mismatch record 
         * @param  filterName of type string
         * @param  tenderId of type Id
         * @return AITM_RelatedRecordsHolderController.FilterOption
         */
        private AITM_RelatedRecordsHolderController.FilterOption getFilterOption(String filterName, Id tenderId) {
            return AITM_RelatedTenderLocationsHolderCntrl.getFilter(filterName, tenderId);
        }

        /**
         * @description gets the location mismatch jsdon
         * @param  null
         * @return string
         */
        private String getLocationMismatchJSON() {
            return '{"disabled":false,"name":"Locations With Volume Mismatch"}';
        }

        /**
         * @description gets the adhoc json
         * @param  null
         * @return string
         */
        private String getAdHocJSON() {
            return '{"disabled":false,"name":"Locations with AdHoc Volume"}';
        }

        /**
         * @description gets the locations with quotes
         * @param  null
         * @return string
         */
        private String getLocationsWithQuotes() {
            return '{"disabled":false,"name":"Locations with Quotes"}';
        }

        /**
         * @description gets the locations without quotes
         * @param  null
         * @return string
         */
        private String getLocationsWithoutQuotes() {
            return '{"disabled":false,"name":"Locations without Quotes"}';
        }

        /**
         * @description gets the Business Gained locations
         * @param  null
         * @return string
         */
        private String getBusinessGainedLocations() {
            return '{"disabled":false,"name":"Business Gained"}';
        }

        /**
         * @description gets the Business retained locations
         * @param  null
         * @return string
         */
        private String getBusinessRetainedLocations() {
            return '{"disabled":false,"name":"Business Retained"}';
        }

        /**
         * @description gets the Business lost locations
         * @param  null
         * @return string
         */
        private String getBusinessLostLocations() {
            return '{"disabled":false,"name":"Business Lost"}';
        }

        /**
         * @description gets the MarketInfo locations
         * @param  null
         * @return string
         */
        private String getMarketInfoLocations() {
            return '{"disabled":false,"name":"Market Info"}';
        }

    }
}