/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_TenderOfferPDFController

 * history
 * 01/December/2017      George       Created
 * 04/September/2018     Anusha       Modified - added method level comments as per coding standards
 *******************************************************************/
@isTest  
private class AITM_TenderOfferContainerControllerTests {

    /**
     * @description tests to filter the users
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetFilterOptionsWillReturnValidListOfFilterOptionsWithUserIfLocationManager() {
        TenderOfferContainerControllerTestSetup testSetup = new TenderOfferContainerControllerTestSetup().generateData();
        User locationManager = testSetup.createLocationManager();

        Test.startTest();
            List<AITM_RelatedRecordsHolderController.FilterOption> filterOptions = AITM_TenderOfferContainerController.getFilterOptions(testSetup.tender.Id);
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
        
        Test.startTest();
            String result = AITM_TenderOfferContainerController.check();
        Test.stopTest();

        System.assertEquals(expectedCheckValue, result);
    }
    /**
     * @description tests to attach offer documnent
     * @param  null
     * @return void
     */
    @isTest  
    static void attachOfferDocumentsTest() {
        TenderOfferContainerControllerTestSetup testSetup = new TenderOfferContainerControllerTestSetup().generateData();

        Test.startTest();
            AITM_TenderOfferContainerController.attachOfferDocuments(testSetup.tender.id, '');
        Test.stopTest();

        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1]);
    }

    /**
     * @description test data TenderOfferContainerController inner class
     */    
    private class TenderOfferContainerControllerTestSetup extends AITM_TestSetup {
        AITM_Tender__c tender = createTender();

        public TenderOfferContainerControllerTestSetup generateData() {
            insert tender;

            return this;
        }

        /**
         * @description generates the test data for Location Manager, users for the test class
         * @param  null
         * @return TenderLocationMappingHandlerTestSetup
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