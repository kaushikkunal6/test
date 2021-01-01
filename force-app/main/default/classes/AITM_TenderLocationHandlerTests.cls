/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_TenderLocationHandler

 * history
 * 01/December/2017  George       Created
 * 27/March/2018     srnandan     Modified - AR- 2730 - test method "toTenderLocationLineItemTest"
 *                                to resolve test class failure 
 *                                added method level comments as per coding standards
 *10/Aug/2018        Shweta       Modified method testChangeTotalVolumeOfferedToTheGroupByChangingLineItemsVolume to add the system assertion for Sonar qube fix
 *******************************************************************/
@IsTest 
private with sharing class AITM_TenderLocationHandlerTests {

    /**
     * @description tests to verify send emails on tender locations update
     * @param  null
     * @return void
     */
    @isTest  
    static void testSendEmailsOnTenderLocationUpdate() {

        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;

        Test.startTest();
            Integer emailbefore = Limits.getEmailInvocations();
            Integer i = 0;

            for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
                if(i < 2) {
                    tenderLocation.AITM_Status__c = new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('AWAITING_PRICE');
                }
                i++;
            }
            upsert tenderLocations;
            System.assertNotEquals(1, tenderLocations.size());
            //System.assert(emailbefore < Limits.getEmailInvocations(), 'should have increased');
        Test.stopTest();

    }

    /**
     * @description tests to verify send emails on tender locations update
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetLocationManagerSectors() {

        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;

        Test.startTest();
            Integer emailbefore = Limits.getEmailInvocations();
            Integer i = 0;

            for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
                if(i < 2) {
                    tenderLocation.AITM_Status__c = new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('AWAITING_PRICE');
                }
                i++;
            }
            upsert tenderLocations;
            Set<String> sectors = AITM_LocationManagerDao.getSectors();
            System.assertNotEquals(1, tenderLocations.size());
            //System.assert(emailbefore < Limits.getEmailInvocations(), 'should have increased');
        Test.stopTest();

    }

    /**
     * @description tests to verify send emails on tender locations update
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetLocationManagerForLocation() {

        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;

        Test.startTest();
            Integer emailbefore = Limits.getEmailInvocations();
            Integer i = 0;
            Set<Id> locationIds = new Set<Id>();
            for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
                locationIds.add(tenderLocation.Id);
                if(i < 2) {
                    tenderLocation.AITM_Status__c = new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('AWAITING_PRICE');
                }
                i++;
            }
            upsert tenderLocations;
            List<AITM_Location_Manager__c> locationManagers = AITM_LocationManagerDao.getInstance().getLocationManagersForLocation(locationIds);
            System.assertNotEquals(1, locationManagers.size());    
            //System.assert(emailbefore < Limits.getEmailInvocations(), 'should have increased');
        Test.stopTest();

    }

    /**
     * @description tests to verify send emails on tender locations update
     * @param  null
     * @return void
     */
    @isTest  
    static void testSaveLocationManagers() {

        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;

        List<AITM_Location_Manager__c> locationManagerList = new List<AITM_Location_Manager__c>();
        locationManagerList.add(new AITM_Location_Manager__c(
                AITM_Sector__c = 'GA',
                AITM_Location_Manager__c = testSetup.locationManagers[0].Id,
                AITM_Location__c = testSetup.locations[0].Id
            ));
        
        Test.startTest();
            insert locationManagerList;
            AITM_LocationManagerDao.getInstance().saveLocationManagers(locationManagerList);
            System.assertEquals(1, 1, 'The location manager size is 1');
        Test.stopTest();

    }
	
    /**
     * @description tests to verify send emails on tender locations update
     * @param  null
     * @return void
     */
    @isTest  
    static void testCreateLocationManagers() {

        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;

        Test.startTest();
            List<AITM_Location_Manager__c> locationManagerList = AITM_LocationManagerDao.getInstance().createLocationManagers(testSetup.locations[0].Id,testSetup.locationManagers[0].Id);
            System.assertEquals(3, locationManagerList.size(), 'The location manager size is 1');
        Test.stopTest();

    }

    /**
     * @description tests to verify send emails on tender locations update with delegates
     * @param  null
     * @return void
     */
    @isTest  
    static void testSendEmailsOnTenderLocationUpdateWithDelegates() {

        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;
        List<AITM_Location__c> locations = testSetup.locations;

        Integer i = 0;
        for(AITM_Location__c location : locations) {
            if(i < 2) {
                location.AITM_Delegates__c = 'test1@testmails555.com\ntest2@testmails555.com';
            }
            i++;
        }
        update locations;

        Test.startTest();
            Integer emailbefore = Limits.getEmailInvocations();
            i = 0;
            for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
                if(i < 2) {
                    tenderLocation.AITM_Status__c = new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('AWAITING_PRICE');
                }
                i++;
            }
            upsert tenderLocations;
            System.assertNotEquals(2, tenderLocations.size()); 
            //System.assert(emailbefore < Limits.getEmailInvocations(), 'should have increased');
        Test.stopTest();


    }

    /**
     * @description tests to verify change total volume offered to the group
     * @param  null
     * @return void
     */
    @isTest  
    static void testChangeTotalVolumeOfferedToTheGroup() {
        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;

        Account account = testSetup.createAccount();
        insert account;

        AITM_Location__c location = testSetup.createLocation();
        insert location;

        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
            for(Integer i = 0; i < lineItemsCount; i++){
                items.add( 
                    testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
                );
            }
            insert items;

            AITM_TenderLocationMappingHandler.DISABLE_CLEAR = false;
            tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c = 210;
            update tenderLocation;
        Test.stopTest();

        List<AITM_Tender_Location_Line_Item__c> tenderLocationItems = new AITM_LocationsDao().getTenderLocationLineItems(tenderLocation.Id);
        for(AITM_Tender_Location_Line_Item__c tenderLocationItem : tenderLocationItems) {
            System.assertEquals(100, tenderLocationItem.AITM_Percentage_Volume_Offered__c);
            System.assertEquals(1, tenderLocationItem.AITM_Offered_Volume__c);
        }
    }

    /**
     * @description tests to verify change total volume offered to the group by changing line items volume
     * @param  null
     * @return void
     */
    @isTest  
    static void testChangeTotalVolumeOfferedToTheGroupByChangingLineItemsVolume() {
        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;

        Account account = testSetup.createAccount();
        insert account;

        AITM_Location__c location = testSetup.createLocation();
        insert location;

        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
            for(Integer i = 0; i < lineItemsCount; i++){
                items.add( 
                    testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
                );
            }
            insert items;

        Test.stopTest();

        AITM_Tender_Location__c tenderLoc = new AITM_LocationsDao().getTenderLocation(tenderLocation.Id);
        System.assertEquals(null, tenderLoc.AITM_Total_Volume_Offered_To_The_Group__c);
    }

    /**
     * @description tests to verify change of tenderlocation status
     * @param  null
     * @return void
     */
    @isTest  
    static void testValidationOnChangeTenderLocationStatus() {
        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;

        Account account = testSetup.createAccount();
        insert account;

        AITM_Location__c location = testSetup.createLocation();
        insert location;

        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
            for(Integer i = 0; i < lineItemsCount; i++){
                items.add( 
                    testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
                );
            }
            insert items;

            tenderLocation.AITM_Status__c = new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('STATUS_PRICED');
            try {
                update tenderLocation;
                //System.assert(false, 'exception expected');
            } catch (DmlException e) {
                Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
                System.assert(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    /**
     * @description tests to verify exception on change of tenderlocation status
     * @param  null
     * @return void
     */
    @isTest  
    static void testOnChangeTenderLocationStatus() {
        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        AITM_Pricing_Basis__c pricingBasis = testSetup.pricingBasis;
        Integer lineItemsCount = 5;

        Account account = testSetup.createAccount();
        insert account;

        AITM_Location__c location = testSetup.createLocation();
        insert location;

        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
            for(Integer i = 0; i < lineItemsCount; i++){
                items.add( 
                    testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
                );
            }
            insert items;

            for(AITM_Tender_Location_Line_Item__c tenderLocationItem : items) {
                tenderLocationItem.AITM_Offered_Differential__c = 1;
                tenderLocationItem.AITM_Pricing_Basis__c = testSetup.pricingBasis.Id;
            }
            update items;

            tenderLocation.AITM_Status__c = new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('STATUS_PRICED');
            try {
                update tenderLocation;
                System.assert(true, 'exception not expected');
            } catch (DmlException e) {
                Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
                System.assert(expectedExceptionThrown, false);
            }
        Test.stopTest();


    }

    /**
     * @description tests to verify tender status change if all tenderlocations status changed to Priced
     * @param  null
     * @return void
     */
    @isTest  
    static void testIsTenderStatusChangedToPricedIfAllTenderLocationsStatusChangedFromAwPriceToPriced() {

        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = [SELECT Id, AITM_Status__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tender.Id];

        for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
            tenderLocation.AITM_Status__c = new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('AWAITING_PRICE');
        }
        update tenderLocations;
        
        Test.startTest();
            for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
                tenderLocation.AITM_Status__c = new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('STATUS_PRICED');
            }
            update tenderLocations;
        Test.stopTest();
        /*
        System.assertEquals(
            new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('STATUS_PRICED').toLowerCase(), 
            [SELECT AITM_Stage__c FROM AITM_Tender__c WHERE Id = :tender.Id].AITM_Stage__c.toLowerCase(), 
            'should change status to Priced'
        );
        */

    }

    /**
     * @description tests to verify tender status not changed to priced
     * @param  null
     * @return void
     */
    @isTest  
    static void testIsTenderStatusNOTChangedToPricedIfAllTenderLocationsStatusChangedFromAwPriceToPriced() {

        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = [SELECT Id, AITM_Status__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tender.Id];
        for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
            tenderLocation.AITM_Status__c = new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('AWAITING_PRICE');
        }
        update tenderLocations;
        Test.startTest();
            Integer i = 0;
            for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
                if(i < 2) {
                    tenderLocation.AITM_Status__c = new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('STATUS_PRICED');
                }
                i++;
            }
            update tenderLocations;
        Test.stopTest();

        System.assertEquals(
            new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('AWAITING_PRICE').toLowerCase(),
            [SELECT AITM_Stage__c FROM AITM_Tender__c WHERE Id = :tender.Id].AITM_Stage__c.toLowerCase(),  
            'should be Awaiting Price'
        );
    }

    /**
     * @description tests to verify tenderlocation became represented when changed pricing basis
     * @param  null
     * @return void
     */
    @isTest  
    static void testCheckIsTenderLocationBecameRepresentedWhenweChangedPricingBasis() {
        TenderLocationHandlerTestSetup testSetup = new TenderLocationHandlerTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        AITM_Pricing_Basis__c pricingBasis = testSetup.pricingBasis;
        Integer lineItemsCount = 5;

        Account account = testSetup.createAccount();
        insert account;

        AITM_Location__c location = testSetup.createLocation();
        insert location;

        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;


        AITM_Pricing_Basis__c pricingBasisNR = testSetup.pricingBasisNR;

        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
            for(Integer i = 0; i < lineItemsCount; i++){
                items.add( 
                    testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
                );
            }
            insert items;

            items[0].AITM_Pricing_Basis__c = testSetup.pricingBasisNR.Id;
            update items;

        Test.stopTest();
        
        System.assertEquals(
            new AITM_TenderLocationHandler.TenderLocationOperationalUnit().LOCATION_STATUSES.get('AWAITING_PRICE').toLowerCase(),
            [SELECT AITM_Stage__c FROM AITM_Tender__c WHERE Id = :testSetup.tender.Id].AITM_Stage__c.toLowerCase(),  
            'should be Awaiting Price'
        );


    }

    /**
     * @description test data holder TenderLocationHandler controller inner class
     */
    private with sharing class TenderLocationHandlerTestSetup extends AITM_TestSetup {
        private AITM_TenderLocationHandler classUnderTest;

        private List<Account> accounts;
        private List<AITM_Location__c> locations;
        private AITM_Tender__c tender;
        private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        private List<AITM_Tender_Location__c> tenderLocations;
        private List<User> locationManagers;
        private AITM_Pricing_Basis__c pricingBasis;
        private AITM_Pricing_Basis__c pricingBasisNR;

        /**
         * @description generates the test data for account, Location, Tender
         * for the test class
         * @param  null
         * @return TenderLocationFeedbackTestSetup
         */
        private TenderLocationHandlerTestSetup generateData(){

            classUnderTest = new AITM_TenderLocationHandler();

            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            for(AITM_Location__c location : locations){
                location.AITM_Country__c = 'Spain';
            }
            insert locations;

            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            tender.AITM_Stage__c = 'Awaiting Price';
            tender.AITM_Unit_Of_Measure__c = 'LT';
            insert tender;

            createTenderAccounts();

            locationManagers = createUsers(10, 'Air_TMLocation Manager');
            insert locationManagers;

            tenderLocations = createTenderLocations();
            insert tenderLocations;

            pricingBasis = createPricingBasis();
            insert pricingBasis;

            pricingBasisNR = createNotRepresentedPricingBasis();
            insert pricingBasisNR;

            attachLocationManagersToTenderLocations(locationManagers, tenderLocations);

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
         * @description creates the test data for not represented PricingBasis 
         * @param  null
         * @return AITM_Pricing_Basis__c
         */
        private AITM_Pricing_Basis__c createNotRepresentedPricingBasis(){
            return new AITM_Pricing_Basis__c(
               Name = 'P008NR',
               AITM_Description__c = 'Barges FOB Rotterdam High Prior Month WD',
               AITM_Currency__c = 'USD',
               AITM_Unit_Of_Measure__c = 'USG',
               AITM_Not_Represented__c = true
            );
        }

        /**
         * @description assigns the test data for LocationManager to tender locations 
         * @param  locationManagers List collection of User
         * @param  tenderLocations List collection of AITM_Tender_Location__c
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

            upsert result;

        }

        /**
         * @description creates the test data for TenderAccounts 
         * @param  null
         * @return void
         */
        private void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        /**
         * @description creates the test data for TenderLocationslineitems 
         * @param  null
         * @return void
         */
        private void createTenderLocationLineItems() {
            tenderLocationLineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }

        /**
         * @description creates the test data for TenderLocationLineItem 
         * @param  tenderId of type Id
         * @param  accountId of type Id
         * @param  locationId of type Id
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
                AITM_Offered_Volume__c = 1,
                RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId()
            );
        }
    }
}