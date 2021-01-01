/***************************************************************
 * @author          George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_TenderHandler

 * history
 * 01/December/2017  George       Created
 * 21/March/2018     srnandan     Modified - AR-2729 - modified test method 
 *                                "testIsChatterMessageBeenCreatedForAllTenderLocations" assertion 
 *                                to pass test and added header and method comments
 **********************************************************/
@IsTest 
private class AITM_TenderHandlerTests {

    private static final String STAGE_AWAITING_PRICE = 'Awaiting Price';
    private static final String STAGE_FEEDBACK = 'Feedback and Negotiation';

    /**
     * @description tests to verify tender status change after tenderlocation status updated
     * @param  null
     * @return void
     */
    @isTest  
    static void testIsTenderChangedStatusAfterTenderLocationStatusUpdateToAwaitingPrice() {

        TenderHandlerTestSetup testSetup = new TenderHandlerTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;

        Test.startTest();
            Integer i = 0;

            for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
                if(i < 2) {
                    tenderLocation.AITM_Status__c = STAGE_AWAITING_PRICE;
                }
                i++;
            }
            upsert tenderLocations;
        Test.stopTest();

        System.assertNotEquals(STAGE_AWAITING_PRICE, [SELECT AITM_Stage__c FROM AITM_Tender__c WHERE Id = :tender.Id].AITM_Stage__c);
    }

    /**
     * @description tests to verify chatter messages been created per tender
     * @param  null
     * @return void
     */
    @isTest  
    static void testIsChatterMessageBeenCreatedForAllTenderLocations() {

        TenderHandlerTestSetup testSetup = new TenderHandlerTestSetup().generateData();

        Test.startTest();
            AITM_TenderHandler.TenderLocationChatterNotificationHandler notificationHandler = new AITM_TenderHandler.TenderLocationChatterNotificationHandler();
            notificationHandler.tenderIdsLocationsOfWhichShouldBeNotified.add(testSetup.tender.Id);
            List<ConnectApi.BatchInput> chatterMessages = notificationHandler.notifyRelatedTenderLocations();
        Test.stopTest();

        System.assertEquals(1, chatterMessages.size());
    }

    /**
     * @description tests to verify tender location negotiation instructed updated
     * @param  null
     * @return void
     */
    @isTest  
    static void testIsTenderLocationNegotiationInstructionsBeenUpdated() {

        TenderHandlerTestSetup testSetup = new TenderHandlerTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;
        List<AITM_Tender_Location__c> tenderLocationsToUpdate = new List<AITM_Tender_Location__c>();

        List<AITM_Location__c> locations = testSetup.locations;
        for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
            tenderLocation.AITM_Quality_Of_Feedback__c = 'Low';
            tenderLocation.AITM_Last_Look_To_Incumbent__c = 'No';
            tenderLocation.AITM_Number_Of_Rounds__c = 4;
            tenderLocationsToUpdate.add(tenderLocation);
        }
        update tenderLocationsToUpdate;

        Test.startTest();
            tender.AITM_Quality_Of_Feedback__c = 'Low';
            tender.AITM_Number_Of_Rounds__c = 4;
            tender.AITM_Last_Look_To_Incumbent__c = 'No';
            update tender;
        Test.stopTest();

        for(AITM_Tender_Location__c tenderLocation : [SELECT AITM_Quality_Of_Feedback__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tender.Id ]) {
            System.assertEquals(tender.AITM_Quality_Of_Feedback__c, tenderLocation.AITM_Quality_Of_Feedback__c);
            System.assertEquals(tender.AITM_Number_Of_Rounds__c, tenderLocation.AITM_Number_Of_Rounds__c);
            System.assertEquals(tender.AITM_Last_Look_To_Incumbent__c, tenderLocation.AITM_Last_Look_To_Incumbent__c);
        }

    }

    /**
     * @description tests to verify creation of new round with no line items
     * @param  null
     * @return void
     */
    @isTest  
    static void testCreationOfNewRoundNoLineItems() {

        TenderHandlerTestSetup testSetup = new TenderHandlerTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;
        List<AITM_Tender_Location__c> tenderLocationsToUpdate = new List<AITM_Tender_Location__c>();

        List<AITM_Location__c> locations = testSetup.locations;
        for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
            tenderLocation.AITM_Comments__c = 'Tender Location Round 1';
            tenderLocationsToUpdate.add(tenderLocation);
        }
        update tenderLocationsToUpdate;

        tender.AITM_Stage__c = AITM_TenderHandlerTests.STAGE_FEEDBACK;
        tender.AITM_No_Feedback_Progress_To_De_Brief__c = false;
        tender.AITM_Send_Feedback_Notification__c = true;
        tender.AITM_Send_LABP_Feedback_Notification__c = true;
        update tender;

        Test.startTest();
            tender.AITM_Stage__c = AITM_TenderHandlerTests.STAGE_AWAITING_PRICE;
            update tender;
        Test.stopTest();

        List<AITM_Tender_Location__c> currentRoundtenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations( tender.Id );
        System.assertEquals(STAGE_AWAITING_PRICE, tender.AITM_Stage__c);
    }

    /**
     * @description class holds test data preparation
     */
    private class TenderHandlerTestSetup extends AITM_TestSetup {
        private AITM_TenderHandler classUnderTest;

        private List<Account> accounts;
        private List<AITM_Location__c> locations;
        private AITM_Tender__c tender;
        private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        private List<AITM_Tender_Location__c> tenderLocations;
        private List<User> locationManagers;

        /**
         * @description generates test data
         * @param  null
         * @return TenderHandlerTestSetup
         */
        private TenderHandlerTestSetup generateData(){

            classUnderTest = new AITM_TenderHandler();

            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            insert tender;

            createTenderAccounts();

            locationManagers = createUsers(10, 'Air_TMLocation Manager');
            insert locationManagers;

            tenderLocations = createTenderLocations();
            insert tenderLocations;

            attachLocationManagersToTenderLocations(locationManagers, tenderLocations);

            return this;
        }

        /**
         * @description creates tender locations
         * @param  null
         * @return List collection of type AITM_Tender_Location__c
         */
        private List<AITM_Tender_Location__c> createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
            for(AITM_Location__c location : locations){
                AITM_Tender_Location__c tenderLocation = createTenderLocation(tender.Id, location.Id);
                tenderLocation.AITM_Status__c = 'Awaiting Price';
                tenderLocations.add(tenderLocation);
            }
            return tenderLocations;
        }

        /**
         * @description attach location managers to tender locations
         * @param  locationManagers list collection of users
         * @param  tenderLocations list collection of AITM_Tender_Location__c
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
         * @description creates tender accounts
         * @param  null
         * @return void
         */
        private void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        /**
         * @description creates tenderlocationitems
         * @param  null
         * @return void
         */
        private void createTenderLocationLineItems() {
            tenderLocationLineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }

        /**
         * @description creates tenderlocationlineitem
         * @param  tenderId of type Id
         * @param  accountId of type Id
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