/**************************************************************************
 * @author           George
 * @date             03/April/2018
 * @group            AirBP
 * @description      Test class for AITM_CountryByTenderLocationItemCtrl

 * history
 * 03/April/2018  srnandan      Created AR-2726
 *******************************************************************/
@isTest
private with sharing class AITM_CountryByTenderLocItemCtrlTests {
    private final static String STATUS_PRICED = 'Priced';

    /**
     * @description tests to verify initialization of record results on init event
     * @param  null
     * @return void
     */
    @isTest 
    static void testInitializeCountryDetailsResultsInitializationAdapterWithData() {
        AITM_CountryByTenderLocationTestSetup setup = new AITM_CountryByTenderLocationTestSetup().generateData();
        Test.startTest();
            AITM_CountryByTenderLocationItemCtrl.CountryDetailResultsInitializationAdapter result = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(setup.tender.Id, setup.locations[0].AITM_Country__c, 1);
        Test.stopTest();
        System.assert(result.results.size() == 25 ,'The expected result size is' + result.results.size());
    }

    /**
     * @description tests to verify initialization of record results on init event
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetPricingResponsibilityWithData() {
        AITM_CountryByTenderLocationTestSetup setup = new AITM_CountryByTenderLocationTestSetup().generateData();
        Test.startTest();
            AITM_CountryByTenderLocationItemCtrl.CountryDetailResultsInitializationAdapter result = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(setup.tender.Id, setup.locations[0].AITM_Country__c, 1);
        Test.stopTest();
        System.assert(result.results.size() == 25,'The expected result size is 0');
    }

    /**
     * @description tests to update of status on line item and location
     * @param  null
     * @return void
     */
    @isTest  
	static void testUpdateRecordWithStatus() {
        AITM_CountryByTenderLocationTestSetup testSetup = new AITM_CountryByTenderLocationTestSetup().generateData();
        AITM_Tender_Location_Line_Item__c lineItem = testSetup.tenderLocationLineItems[0];
        lineItem.AITM_Status__c = STATUS_PRICED;
        lineItem.AITM_Pricing_Basis__c = testSetup.pricingBasis.Id;
        AITM_CountryByTenderLocationItemCtrl.CountryDetailResultsInitializationAdapter initializationResult = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(testSetup.tender.Id, 'Spain', 1);
        for (AITM_CountryByTenderLocationItemCtrl.TenderLocationItemAdapter adapter : initializationResult.results) {
            adapter.lineStatus = lineItem.AITM_Status__c;
            adapter.status = adapter.lineStatus;
        }
        Test.startTest();                        
            String result = AITM_CountryByTenderLocationItemCtrl.save(JSON.serialize(initializationResult.results));
            initializationResult = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(testSetup.tender.Id, 'USX', 1);
        Test.stopTest();
        
        System.assert(String.isBlank(result), 'The result is blank');
        //System.assert(initializationResult.results[0].lineStatus.equals(lineItem.AITM_Status__c), 'The line status is equal to adapter status');        
    }

    /**
     * @description tests to update of revised offer on line item
     * @param  null
     * @return void
     */
    @isTest  
    static void testUpdateRecordWithRevisedOffer() {
        AITM_CountryByTenderLocationTestSetup testSetup = new AITM_CountryByTenderLocationTestSetup().generateData();
        AITM_Tender_Location_Line_Item__c lineItem = testSetup.tenderLocationLineItems[0];
        lineItem.AITM_Status__c = STATUS_PRICED;
        lineItem.AITM_Pricing_Basis__c = testSetup.pricingBasis.Id;
        AITM_CountryByTenderLocationItemCtrl.CountryDetailResultsInitializationAdapter initializationResult = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(testSetup.tender.Id, 'Spain', 1);
        for (AITM_CountryByTenderLocationItemCtrl.TenderLocationItemAdapter adapter : initializationResult.results) {
            adapter.lineStatus = lineItem.AITM_Status__c;
            adapter.status = adapter.lineStatus;
        }
        Test.startTest();                        
            String result = AITM_CountryByTenderLocationItemCtrl.save(JSON.serialize(initializationResult.results));
            initializationResult = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(testSetup.tender.Id, 'Spain', 1);
        Test.stopTest();
        
        System.assert(String.isBlank(result), 'The result is blank');
        //System.assert(initializationResult.results[0].lineStatus.equals(lineItem.AITM_Status__c), 'The line status is equal to adapter status');        
    }

    /**
     * @description tests to update of new offered differential on line item
     * @param  null
     * @return void
     */
    @isTest  
    static void testUpdateRecordWithOfferDifferential() {
        AITM_CountryByTenderLocationTestSetup testSetup = new AITM_CountryByTenderLocationTestSetup().generateData();
        AITM_Tender_Location_Line_Item__c lineItem = testSetup.tenderLocationLineItems[0];
        lineItem.AITM_Status__c = STATUS_PRICED;
        lineItem.AITM_Pricing_Basis__c = testSetup.pricingBasis.Id;
        lineItem.AITM_Offered_Differential__c = 12;
        AITM_CountryByTenderLocationItemCtrl.CountryDetailResultsInitializationAdapter initializationResult = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(testSetup.tender.Id, 'Spain', 1);
        for (AITM_CountryByTenderLocationItemCtrl.TenderLocationItemAdapter adapter : initializationResult.results) {
            adapter.lineStatus = lineItem.AITM_Status__c;
            adapter.status = adapter.lineStatus;
            adapter.newDiff = lineItem.AITM_Offered_Differential__c;
        }
        Test.startTest();                        
            String result = AITM_CountryByTenderLocationItemCtrl.save(JSON.serialize(initializationResult.results));
            initializationResult = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(testSetup.tender.Id, 'Spain', 1);
        Test.stopTest();
        
        System.assert(String.isBlank(result), 'The result is blank');
        //System.assert(initializationResult.results[0].lineStatus.equals(lineItem.AITM_Status__c), 'the status of adapter is equal to lineitem status');        
        //System.assert(initializationResult.results[0].newDiff == lineItem.AITM_Offered_Differential__c, 'The new diff of adapter is equal to line item offered differential');        
    }

    /**
     * @description tests to update of uom on line item
     * @param  null
     * @return void
     */
    @isTest  
    static void testUpdateRecordWithUOM() {
        AITM_CountryByTenderLocationTestSetup testSetup = new AITM_CountryByTenderLocationTestSetup().generateData();
        AITM_Tender_Location_Line_Item__c lineItem = testSetup.tenderLocationLineItems[0];
        lineItem.AITM_Status__c = testSetup.STATUS_AWAITING_PRICE;
        lineItem.AITM_Pricing_Basis__c = testSetup.pricingBasis.Id;
        lineItem.AITM_Unit_Of_Measure__c = 'KG';
        AITM_CountryByTenderLocationItemCtrl.CountryDetailResultsInitializationAdapter initializationResult = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(testSetup.tender.Id, 'Spain', 1);
        for (AITM_CountryByTenderLocationItemCtrl.TenderLocationItemAdapter adapter : initializationResult.results) {
            adapter.lineStatus = lineItem.AITM_Status__c;
            adapter.status = adapter.lineStatus;
            adapter.uom = lineItem.AITM_Unit_Of_Measure__c;
        }
        Test.startTest();                        
            String result = AITM_CountryByTenderLocationItemCtrl.save(JSON.serialize(initializationResult.results));
            initializationResult = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(testSetup.tender.Id, 'Spain', 1);
        Test.stopTest();
        
        System.assert(String.isBlank(result), 'The result is blank');
        //System.assert(initializationResult.results[0].lineStatus.equals(lineItem.AITM_Status__c),'The line status is equal to adapter status');        
        //System.assert(initializationResult.results[0].uom.equals(lineItem.AITM_Unit_Of_Measure__c),'The line uom is equal to adapter uom');        
    }

    /**
     * @description tests to update of currency on line item
     * @param  null
     * @return void
     */
    @isTest  
    static void testUpdateRecordWithCurrency() {
        AITM_CountryByTenderLocationTestSetup testSetup = new AITM_CountryByTenderLocationTestSetup().generateData();
        AITM_Tender_Location_Line_Item__c lineItem = testSetup.tenderLocationLineItems[0];
        lineItem.AITM_Status__c = testSetup.STATUS_AWAITING_PRICE;
        lineItem.AITM_Pricing_Basis__c = testSetup.pricingBasis.Id;
        lineItem.AITM_Currency__c = 'USD';
        
        AITM_CountryByTenderLocationItemCtrl.CountryDetailResultsInitializationAdapter initializationResult = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(testSetup.tender.Id, 'Spain', 1);
        for (AITM_CountryByTenderLocationItemCtrl.TenderLocationItemAdapter adapter : initializationResult.results) {
            adapter.lineStatus = lineItem.AITM_Status__c;
            adapter.status = adapter.lineStatus;
            adapter.curr = lineItem.AITM_Currency__c;
        }
        Test.startTest();                        
            String result = AITM_CountryByTenderLocationItemCtrl.save(JSON.serialize(initializationResult.results));
            initializationResult = AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults(testSetup.tender.Id, 'Spain', 1);
        Test.stopTest();
        
        System.assert(String.isBlank(result), 'The result is blank');
        //System.assert(initializationResult.results[0].lineStatus.equals(lineItem.AITM_Status__c),'The result status is equal to line item status');        
        //System.assert(initializationResult.results[0].curr.equals(lineItem.AITM_Currency__c), 'The result currency is equal to USD');        
    }

    /**
     * @description tests to get pick list values for currency
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetPickValuesCurrency() {
        Test.startTest();
            List<String> selectOptions = AITM_CountryByTenderLocationItemCtrl.getPickValues('AITM_Tender_Location_Line_Item__c', 'AITM_Currency__c');
        Test.stopTest();
        System.assert(selectOptions.size() > 0,'The select options are greater than zero');
    }

    /**
     * @description tests to get pick list values for UOM
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetPickValuesUOM() {
        Test.startTest();
            List<String> selectOptions = AITM_CountryByTenderLocationItemCtrl.getPickValues('AITM_Tender_Location_Line_Item__c', 'AITM_Unit_Of_Measure__c');
        Test.stopTest();
        System.assert(selectOptions.size() > 0, 'The select options are greater than zero');
    }

    /**
     * @description tests to get pick list values for status
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetPickValuesStatus() {
        Test.startTest();
            List<String> selectOptions = AITM_CountryByTenderLocationItemCtrl.getPickValues('AITM_Tender_Location_Line_Item__c', 'AITM_Status__c');
        Test.stopTest();
        System.assert(selectOptions.size() > 0, 'The select options are greater than zero');
    }

    /**
     * @description tests to verify location line item tender result and awarded volume
     * @param  null
     * @return void
     */
    @isTest  
    static void testToTenderLocationLineItem() {
        AITM_CountryByTenderLocationTestSetup testSetup = new AITM_CountryByTenderLocationTestSetup().generateData();
        AITM_Tender_Location_Line_Item__c testItem = testSetup.tenderLocationLineItems[0];
        testItem.AITM_Unit_Of_Measure__c = 'USG';
        testItem.AITM_Currency__c = 'USX';
        testItem.AITM_Offered_Differential__c = 12;
        testItem.AITM_Status__c = testSetup.STATUS_AWAITING_PRICE;
        Test.startTest();
        	UPDATE testItem;
            AITM_CountryByTenderLocationItemCtrl.TenderLocationItemAdapter adaper = new AITM_CountryByTenderLocationItemCtrl.TenderLocationItemAdapter(testItem);
            AITM_Tender_Location_Line_Item__c result = adaper.toTenderLocationLineItem();  
        Test.stopTest();

        System.assert(result.AITM_Unit_Of_Measure__c.equals('USG'), 'The result value is equal to USG');
        System.assert(result.AITM_Offered_Differential__c == 12, 'The offered differential is equal to 12');
        //System.assert(result.AITM_Currency__c.equals('USX'), 'The currency value is equal to USX');
        //System.assert(testSetup.STATUS_AWAITING_PRICE.equals(result.AITM_Status__c), 'The status value is awaiting price');
    }

    /**
     * @description test data holder CountryByRelatedTenderLocationLineItems controller inner class
     */
    private with sharing class AITM_CountryByTenderLocationTestSetup extends AITM_TestSetup {
        private List<Account> accounts;
        private List<AITM_Location__c> locations;
        private AITM_Tender__c tender;
        private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        private List<AITM_Tender_Location__c> tenderLocations;
        private List<User> locationManagers;
        private AITM_Pricing_Basis__c pricingBasis;
        private final String STATUS_AWAITING_PRICE = 'Awaiting price';
        private final Integer ITEMS_COUNT = 5;
        private List<AITM_Delivery_Point__c> deliveryPoints;

        /**
         * @description generates the test data for account, Location, Tender, TenderLocation, 
         * TenderLocationLineItem for the test class
         * @param  null
         * @return CountryByTenderLocationTestSetup
         */
        private AITM_CountryByTenderLocationTestSetup generateData(){
            /*AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
			settings.AITM_IsActive__c = true;
			upsert settings AITM_DeactivateTriggerSetting__c.Id;       */
            accounts = createAccounts(ITEMS_COUNT);
            INSERT accounts;

            locations = createLocations(ITEMS_COUNT);
            for(AITM_Location__c location : locations){
                location.AITM_Country__c = 'Spain';
            }
            INSERT locations;
            deliveryPoints = new List<AITM_Delivery_Point__c>();
            Integer count = 0;
            for(AITM_Location__c location : locations) {
                deliveryPoints.add(createDeliveryPoint(location,false, count++));
            }
            INSERT deliveryPoints;
            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            INSERT tender;

            createTenderAccounts();

            locationManagers = createUsers(ITEMS_COUNT, 'Air_TMLocation Manager');
            INSERT locationManagers;
            for(AITM_Delivery_Point__c deliveryPoint : deliveryPoints) {
                deliveryPoint.AITM_CA_Pricing_Responsibility1__c = locationManagers[0].Id;
                deliveryPoint.AITM_GA_Pricing_Responsibility1__c = locationManagers[0].Id;
                deliveryPoint.AITM_Location_Manager1__c = locationManagers[0].Id;
            }
            update deliveryPoints;

            tenderLocations = createTenderLocations();
            INSERT tenderLocations;

            pricingBasis = createPricingBasis();
            INSERT pricingBasis;
            
            attachLocationManagersToTenderLocations(locationManagers, tenderLocations);

            tenderLocationLineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
            for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocationLineItems) {
               lineItem.AITM_Pricing_Basis__c = pricingBasis.Id;
               lineItem.AITM_Currency__c = 'USD';
               lineItem.AITM_Unit_Of_Measure__c = 'USG'; 
               lineItem.AITM_Offered_Differential__c = 1.0;
               lineitem.AITM_Location_Delivery_Point__c = deliveryPoints[0].Id;
            }
            INSERT tenderLocationLineItems;
            UserRole role = [Select Name from UserRole WHERE Name = 'AirBP'];
            Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator'];
            String uName = 'airbp_test_admusr';
            User user = new User(
                    Alias = 'unadm_',
                    Email = uName + '@testorg.com',
                    EmailEncodingKey ='UTF-8',
                    LastName ='Testing',
                    LanguageLocaleKey ='en_US',
                    LocaleSidKey ='en_US',
                    ProfileId = p.Id,
                    TimeZoneSidKey ='America/Los_Angeles',
                    UserName = uName + '@testorg.com'
            );
            system.runAs(user) {
                for(User u : locationManagers) {
                    u.UserRoleId = role.Id;
                }
                update locationManagers;
            }
            return this;
        }

        /**
         * @description creates the test data for TenderLocations 
         * @param  null
         * @return List collection of AITM_Tender_Location__c
         */
        private List<AITM_Tender_Location__c> createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
            for(AITM_Location__c location : locations){
                tenderLocations.add(
                    createTenderLocation(tender.Id, location.Id)
                    );
            }
            return tenderLocations;
        }

        /**
         * @description creates the test data for PricingBasis
         * @param  null
         * @return AITM_Pricing_Basis__c
         */
        private AITM_Pricing_Basis__c createPricingBasis(){
            return new AITM_Pricing_Basis__c(
                Name = 'P008',
                AITM_Description__c = 'Barges FOB Rotterdam High Prior Month WD',
                AITM_Currency__c = 'USD',
                AITM_Unit_Of_Measure__c = 'USG'
                );
        }

        /**
         * @description assigns LocationManagers to TenderLocations
         * @param  null
         * @return void
         */
        private void attachLocationManagersToTenderLocations(List<User> locationManagers, List<AITM_Tender_Location__c> tenderLocations) {

            List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
            Integer index = 0;

            for(AITM_Tender_Location__c tenderLocation : tenderLocations){
                tenderLocation.AITM_Location_Manager__c = locationManagers[index].Id;
                result.add(tenderLocation);
                index++;
            }

            UPSERT result;

        }

        /**
         * @description creates test data for TenderAccounts 
         * @param  null
         * @return void
         */
        private void createTenderAccounts() {
            INSERT createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        /**
         * @description creates test data list of TenderLocationLineItems 
         * @param  null
         * @return void
         */
        private void createTenderLocationLineItems() {
            tenderLocationLineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }

        /**
         * @description creates test data for TenderLocationLineItem 
         * @param tenderId of type Id
         * @param accountId of type Id
         * @param locationId of type Id
         * @param tenderLocationId of type Id
         * @return AITM_Tender_Location_Line_Item__c
         */
        private AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0,
                AITM_Requested_Volume_USG__c = 1,
                AITM_Unit_Of_Measure__c = 'USG',
                AITM_Status__c = STATUS_AWAITING_PRICE
              );
        }
    }
}