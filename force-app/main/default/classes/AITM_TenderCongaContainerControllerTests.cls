/**************************************************************************
 * @author           srnandan
 * @date             05/June/2019
 * @group            AirBP
 * @description      Test class for AITM_TenderCongaOfferContainerController

 * history
 * 05/June/2019      	 srnandan       Created
 *******************************************************************/
@isTest  
private inherited sharing class AITM_TenderCongaContainerControllerTests {

    /**
     * @description tests to filter the users
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetFilterOptionsWillReturnValidListOfFilterOptionsWithUserIfLocationManager() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();
        User locationManager = testSetup.createLocationManager();

        Test.startTest();
            List<AITM_RelatedRecordsHolderController.FilterOption> filterOptions = AITM_TenderCongaOfferContainerController.getFilterOptions(testSetup.tender.Id);
        Test.stopTest();

        System.assert(filterOptions.size() > new AITM_LocationsDao().getTenderLocations(testSetup.tender.Id).size());
    }

    /**
     * @description tests to check the expectedcheck
     * @param  null
     * @return void
     */
    @isTest  
    static void checkFactoryTestShouldReturnDone() {
        String expectedCheckValue = 'DONE';
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();
        Test.startTest();
            String result = AITM_TenderCongaOfferContainerController.check(testSetup.tender.Id,'bac');
        Test.stopTest();

        System.assertNotEquals(expectedCheckValue, result, 'The job is in progress');
    }
    
    /**
     * @description tests to attach offer documnent
     * @param  null
     * @return void
     */
    @isTest  
    static void attachOfferDocumentsTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
            AITM_TenderCongaOfferContainerController.createOfferLegalDocument(testSetup.tender.id,false);
        Test.stopTest();

        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1], 'Tender id passed is valid');
    }
    
    /**
     * @description tests to attach offer documnent
     * @param  null
     * @return void
     */
    @isTest  
    static void attachOfferDocumentsForWordTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
            AITM_TenderCongaOfferContainerController.createOfferLegalDocument(testSetup.tender.id,true);
        Test.stopTest();

        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1], 'Tender id passed is valid');
    }
	
    /**
     * @description tests to filter options for customers
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterCustomerOptionsTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
            List<AITM_TenderCongaOfferContainerController.AccountOption> accountOptions = AITM_TenderCongaOfferContainerController.getFilterCustomerOptions(testSetup.tender.id);
        Test.stopTest();

        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1], 'Tender id passed is valid');
        System.assertNotEquals(null, accountOptions, 'Account Options is not null');
    }
    
    /**
     * @description tests to filter options for customers
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterCustomerOptionsBSpokeTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
        	testSetup.account.AITM_Bespoke_Offer_Template__c = 'AITM_AirSerbia';
        	update testSetup.account;
            List<AITM_TenderCongaOfferContainerController.AccountOption> accountOptions = AITM_TenderCongaOfferContainerController.getFilterCustomerOptions(testSetup.tender.id);
        Test.stopTest();

        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1], 'Tender id passed is valid');
        System.assertNotEquals(null, accountOptions, 'Account Options is not null');
    }
    
    /**
     * @description tests to get query details for filter location manager
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterQueryDetailsLocationManagerTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
            String queryCriteria = AITM_TenderCongaOfferContainerController.getFilterQueryDetails('',testSetup.tender.id, '',testSetup.tender.Name,'','','',false, false,'1', '8080808',false);
        Test.stopTest();
		System.assertNotEquals(null, queryCriteria,'The value is null');
        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1]);
    }
    
    /**
     * @description tests to get query details for filter location with out quotes
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterQueryDetailsLocationWOQuotesTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
            String queryCriteria = AITM_TenderCongaOfferContainerController.getFilterQueryDetails('Locations without Quotes',testSetup.tender.id, testSetup.account.Id,testSetup.tender.Name,testSetup.account.Name,'','',false, false,'1', '8080808',false);
        Test.stopTest();
		System.assertNotEquals(null, queryCriteria,'The value is null');
        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1]);
    }
    
    /**
     * @description tests to get query details for filter location with adhoc volume
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterQueryDetailsLocationWithAdhocVolumeTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
        	testSetup.account.AITM_Bespoke_Offer_Template__c = 'AITM_AirSerbia';
            update testSetup.account;
        	update testSetup.tenderAccount;
            String queryCriteria = AITM_TenderCongaOfferContainerController.getFilterQueryDetails('Locations with AdHoc Volume',testSetup.tender.id, testSetup.account.Id,testSetup.tender.Name,testSetup.account.Name,'','AITM_AirSerbia',true, true,'2', '8080808',false);
        Test.stopTest();
		System.assertNotEquals(null, queryCriteria,'The value is null');
        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1]);
    }
    
    /**
     * @description tests to get query details for filter location with volume
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterQueryDetailsLocationWithVolumeTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
        	testSetup.account.AITM_Bespoke_Offer_Template__c = 'AITM_AirSerbia';
            update testSetup.account;
            String queryCriteria = AITM_TenderCongaOfferContainerController.getFilterQueryDetails('Locations with AdHoc Volume',testSetup.tender.id, testSetup.account.Id,testSetup.tender.Name,testSetup.account.Name,testSetup.account.Id,'AITM_AirSerbia',false, false,'3', '8080808',false);
        Test.stopTest();
		System.assertNotEquals(null, queryCriteria,'The value is null');
        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1]);
    }
    
    /**
     * @description tests to get query details for filter all locations
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterQueryDetailsAllLocationsTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
            String queryCriteria = AITM_TenderCongaOfferContainerController.getFilterQueryDetails('All Locations',testSetup.tender.id, '',testSetup.tender.Name,'','','',false, false,'1', '8080808',false);
        Test.stopTest();
		System.assertNotEquals(null, queryCriteria,'The value is not null');
        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1]);
    }
    
    /**
     * @description tests to attach offer documnent
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterQueryDetailsLocationsPricedTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
            String queryCriteria = AITM_TenderCongaOfferContainerController.getFilterQueryDetails('Locations with Priced',testSetup.tender.id, '',testSetup.tender.Name,'','','',false, false,'1', '8080808',false);
        Test.stopTest();
		System.assertNotEquals(null, queryCriteria,'The value is not null');
        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1]);
    }
    
    /**
     * @description tests to get query details for filter not-represented
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterQueryDetailsLocationsNotRepresentedTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
            String queryCriteria = AITM_TenderCongaOfferContainerController.getFilterQueryDetails('Non-represented Locations',testSetup.tender.id, '',testSetup.tender.Name,'','','',false, false,'1', '8080808',false);
        Test.stopTest();
		System.assertNotEquals(null, queryCriteria,'The value is not null');
        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1]);
    }
    
    /**
     * @description tests to get querydetails for filter Volume Mismatch
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterQueryDetailsLocationsWithVolumeMismatchTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
            String queryCriteria = AITM_TenderCongaOfferContainerController.getFilterQueryDetails('Locations With Volume Mismatch',testSetup.tender.id, '',testSetup.tender.Name,'','','',false, false,'1', '8080808',false);
        Test.stopTest();
		System.assertNotEquals(null, queryCriteria,'The value is not null');
        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1]);
    }
	
	/**
     * @description tests to attach offer documnent
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterQueryDetailsLocationswithQuotesTest() {
        TenderCongaOfferContainerControllerTestSetup testSetup = new TenderCongaOfferContainerControllerTestSetup().generateData();

        Test.startTest();
            String queryCriteria = AITM_TenderCongaOfferContainerController.getFilterQueryDetails('Locations with Quotes',testSetup.tender.id, '',testSetup.tender.Name,'','','',false, false,'1', '8080808',false);
        Test.stopTest();
		System.assertNotEquals(null, queryCriteria,'The value is not null');
        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1]);
    }
    
    /**
     * @description test data TenderOfferContainerController inner class
     */    
    private inherited sharing class TenderCongaOfferContainerControllerTestSetup extends AITM_TestSetup {
        //declaration of variable tender sobject
        AITM_Tender__c tender = createTender();
        Account account = createAccount();
        AITM_Tender_Account__c tenderAccount;
		/**
         * @description generates the test data for a tender
         * @param  null
         * @return TenderCongaOfferContainerControllerTestSetup
         */
        public TenderCongaOfferContainerControllerTestSetup generateData() {
            insert tender;
			insert account;
            tenderAccount = createTenderAccount(tender.Id, account.Id);
            insert tenderAccount;
            return this;
        }

        /**
         * @description generates the test data for Location Manager, users for the test class
         * @param  null
         * @return User
         */
        public User createLocationManager() {
            User locationManager = createUsers(1, 'Air_TMLocation Manager')[0];
            locationManager.FirstName = 'Location';
            locationManager.LastName = 'Manager';
            insert locationManager;
            locationManager = [SELECT Id, Name FROM User WHERE Id = :locationManager.Id LIMIT 1][0];
            return locationManager;
        }
    }
}