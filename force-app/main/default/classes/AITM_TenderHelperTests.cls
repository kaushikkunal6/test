/***************************************************************
 * @author          Sushant
 * @date            01/December/2017
 * @group           AirBP
 * @description     Test class for AITM_Tender_Helper
 **********************************************************/
@IsTest 
private class AITM_TenderHelperTests {

    private static final String STAGE_AWAITING_PRICE = 'Awaiting Price';
    private static final String STAGE_FEEDBACK = 'Feedback and Negotiation';
    private static final String successResponse = '"successMsg": "All Tenders are processed Successfully"';
    private static final String errorResponse = '"errorMsg": "All Tenders are not processed"';
    private static final String message = '"message": "All Tenders are processed Successfully"';

    /**
     * @description tests to verify tender status change after tenderlocation status updated
     * @param  null
     * @return void
     */
    @isTest  
    static void testIsTenderChangedStatusAfterTenderLocationStatusUpdateToAwaitingPrice() {

        TenderHelperTestSetup testSetup = new TenderHelperTestSetup().generateData();
    
        AITM_Tender__c tender = testSetup.tender;
        AITM_TenderHelper helperInstance = new AITM_TenderHelper();
        helperInstance.addToNotificationList(tender);
        helperInstance.startNewRound(tender);
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

        TenderHelperTestSetup testSetup = new TenderHelperTestSetup().generateData();

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

        TenderHelperTestSetup testSetup = new TenderHelperTestSetup().generateData();

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

        TenderHelperTestSetup testSetup = new TenderHelperTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;
        AITM_TenderHelper helperclass = new AITM_TenderHelper();
        helperclass.beforeInsertCheckTenderOldOrNew(new List<AITM_Tender__c>{tender});
        Map<Id, AITM_Tender__c> mapOfIdVsTender = new Map<Id, AITM_Tender__c>();
        mapOfIdVsTender.put(tender.Id, tender);
        Schema.SObjectType sObjectType;
        String params;        
        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;
        List<AITM_Tender_Location__c> tenderLocationsToUpdate = new List<AITM_Tender_Location__c>();

        List<AITM_Location__c> locations = testSetup.locations;
        for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
            tenderLocation.AITM_Comments__c = 'Tender Location Round 1';
            tenderLocationsToUpdate.add(tenderLocation);
        }
        update tenderLocationsToUpdate;
        
        Test.startTest();
            tender.AITM_No_Feedback_Progress_To_De_Brief__c = false;
            tender.AITM_Send_Feedback_Notification__c = true;
            tender.AITM_Send_LABP_Feedback_Notification__c = true;
            tender.AITM_Stage__c = 'Awaiting Price';
            tender.AITM_Send_Invitation_Notification__c = true;
            update tender;
        Test.stopTest();
        helperclass.validateCallResponse(successResponse ,tender);
        helperclass.validateCallResponse(errorResponse ,tender);
        helperclass.validateCallResponse(message ,tender);       
        helperclass.beforeDeleteTenderDeleteRelatedLineItems(new List<AITM_Tender__c>{tender});
        List<AITM_Tender_Location__c> currentRoundtenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations( tender.Id );
        System.assertEquals('"successMsg": "All Tenders are processed Successfully"', successResponse);
        System.assertEquals(1, currentRoundtenderLocations[0].AITM_Current_Round__c);  
    }
    
    /**
     * @description tests to verify creation of new round with no line items
     * @param  null
     * @return void
     */
    @isTest  
    static void testCreationOfTenderDebriefcallout() {
        AITM_TenderHelper helperclass = new AITM_TenderHelper();
        TenderHelperTestSetup testSetup = new TenderHelperTestSetup().generateData();
        
        AITM_Tender__c tender = testSetup.tender;         
        Map<Id, Sobject> mapOfIdVsTender = new Map<Id, Sobject>();
        mapOfIdVsTender.put(tender.Id, tender);
        Schema.SObjectType sObjectType;
        String params;        
        
        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;
        List<AITM_Tender_Location__c> tenderLocationsToUpdate = new List<AITM_Tender_Location__c>();

        List<AITM_Location__c> locations = testSetup.locations;
        for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
            tenderLocation.AITM_Comments__c = 'Tender Location Round 1';
            tenderLocationsToUpdate.add(tenderLocation);
        }
        update tenderLocationsToUpdate;

        Test.startTest();
            tender.AITM_No_Feedback_Progress_To_De_Brief__c = false;
            tender.AITM_Send_Feedback_Notification__c = true;
            tender.AITM_Send_LABP_Feedback_Notification__c = true;
            tender.AITM_Capture_Debrief_Email_Sent_Date__c = system.now() +1;
            update tender;
        Test.stopTest();
        AITM_TenderHelper.exposeDebriefTenderToMuleProsSystem(json.serialize(tender));
        helperclass.calloutToSendRequest(tender);
        List<AITM_Tender_Location__c> currentRoundtenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations( tender.Id );
        System.assertEquals(1, currentRoundtenderLocations[0].AITM_Current_Round__c);  
    }
     
    /**
     * @description class holds test data preparation
     */
    private class TenderHelperTestSetup extends AITM_TestSetup {
        private AITM_TenderHelper classUnderTest;
        private List<Account> accounts;
        private List<AITM_Location__c> locations;
        private AITM_Tender__c tender;
        private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        private List<AITM_Tender_Location__c> tenderLocations;
        private List<User> locationManagers;
        private AITM_EnableTenderDebrief__c customData;
        private AITM_Contracting_Entity__c contractingObj;
        private AITM_Callout_Param__c setting;

        /**
         * @description generates test data
         * @param  null
         * @return TenderHelperTestSetup
         */
        private TenderHelperTestSetup generateData(){            
            classUnderTest = new AITM_TenderHelper();
            
            customData = new AITM_EnableTenderDebrief__c();
            customData.Name = 'EnableTenderDebriefMethod';
            customData.AITM_Enable_DebriefMethod__c = true;
            insert customData;
            
            setting = new AITM_Callout_Param__c();
            setting.Name = 'MuleTenderRequest';
            setting.AITM_Client_Id__c = 'clientId';
            setting.AITM_Client_Secret__c = 'sectetId';
            insert setting;
            
            contractingObj = new AITM_Contracting_Entity__c();
            contractingObj.Name = 'test';
            insert contractingObj;
            
            accounts = createAccounts(1);
            accounts[0].AITM_Customer_Segment__c = 'Base';
            accounts[0].Alternate_Customer_Name__c = 'test'; 
            accounts[0].AITM_Customer_Segment__c = 'IATA';
            accounts[0].AITM_Contracting_Entity__c = contractingObj.Id;
            accounts[0].AITM_Exchange_Rate__c = 'IATA';
            accounts[0].Credit_Days__c = '2';
            accounts[0].AITM_Credit_Days1__c = '2';
            accounts[0].AITM_Credit_Days__c =  0.2;
            accounts[0].AITM_Invoice_Frequency__c = 'Daily';
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            tender.AITM_Stage__c = 'Debrief';
            tender.AITM_Capture_Debrief_Email_Sent_Date__c = system.now();
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