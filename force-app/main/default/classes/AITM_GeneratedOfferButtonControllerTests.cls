/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_GeneratedOfferButtonController

 * history
 * 01/December/2017  George       Created
 * 07/March/2018     srnandan     Modified - added test methods "testGetTenderAvailableForSendingTenderIsNotInPricedStageOfferSentError"
 *                                and "testGetTenderAvailableForSendingTenderIsNotInDebriefStageError"
 *                                added method level comments as per coding standards
 * 24/August/2018    Ravi        Modifed - AR-3711 - updated assertEquals statement in method testGetTenderAvailableForSendingTenderIsNotInPricedStageOfferSentError
 *******************************************************************/
@isTest  
private class AITM_GeneratedOfferButtonControllerTests {

    private static final String STAGE_PRICED = 'Priced';
    
    /**
     * @description tests to verify errormessage when tender stage is not priced
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetTenderAvailableForSendingOfferIsNotGeneratedError() {
        AITM_GeneratedOfferButtonControllerTestSetup testSetup = new AITM_GeneratedOfferButtonControllerTestSetup().generateData();
        
        AITM_Tender__c tender = testSetup.tender;
        update tender;

        Test.startTest();
        String errorMessage = AITM_GeneratedOfferButtonController.getTenderAvailableForEmailSending(tender.Id);
        Test.stopTest();

        System.assertEquals(Label.AITM_GeneratedOfferButtonNotPricedStage, errorMessage);
    }

    /**
     * @description tests to verify taxes and fees
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetTaxesAndFees() {
        AITM_GeneratedOfferButtonControllerTestSetup testSetup = new AITM_GeneratedOfferButtonControllerTestSetup().generateData();
        
        AITM_Tender__c tender = testSetup.tender;
        tender.AITM_Stage__c = STAGE_PRICED;
        tender.AITM_Produce_Customer_Email__c = true;
        update tender;

        Test.startTest();
            AITM_Tender_Location__c tenderLocation = AITM_TenderLocationTaxesFeesController.getTenderLocation(testSetup.tenderLocations[0].Id);
        Test.stopTest();

        System.assertNotEquals(null, tenderLocation);
    }

    /**
     * @description tests to verify taxes and fees
     * @param  null
     * @return void
     */
    @isTest  
    static void testUpdateTenderLocation() {
        AITM_GeneratedOfferButtonControllerTestSetup testSetup = new AITM_GeneratedOfferButtonControllerTestSetup().generateData();
        
        AITM_Tender__c tender = testSetup.tender;
        tender.AITM_Stage__c = STAGE_PRICED;
        tender.AITM_Produce_Customer_Email__c = true;
        update tender;

        Test.startTest();
            AITM_TenderLocationTaxesFeesController.updateTenderLocation(testSetup.tenderLocations[0]);
        Test.stopTest();

        System.assertEquals(testSetup.tender.Id, tender.Id);
    }

    /**
     * @description tests to verify taxes and fees
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetFieldAccess() {
        AITM_GeneratedOfferButtonControllerTestSetup testSetup = new AITM_GeneratedOfferButtonControllerTestSetup().generateData();
        
        AITM_Tender__c tender = testSetup.tender;
        tender.AITM_Stage__c = STAGE_PRICED;
        tender.AITM_Produce_Customer_Email__c = true;
        update tender;

        Test.startTest();
            Map<String, Map<String, Boolean>> mapItems = AITM_TenderLocationTaxesFeesController.getFieldsAccess('AITM_Tender_Location__c');
        Test.stopTest();

        System.assertNotEquals(null, mapItems);
    }

    /**
     * @description tests to verify when stage is not DebriefStage
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetTenderAvailableForSendingTenderIsNotInDebriefStageError() {
        AITM_GeneratedOfferButtonControllerTestSetup testSetup = new AITM_GeneratedOfferButtonControllerTestSetup().generateData();
        
        AITM_Tender__c tender = testSetup.tender;
        tender.AITM_Stage__c = STAGE_PRICED;
        tender.AITM_Produce_Customer_Email__c = true;
        update tender;

        Test.startTest();
        String errorMessage = AITM_GeneratedOfferButtonController.getTenderAvailableForEmailSending(tender.Id);
        Test.stopTest();

        System.assertEquals(null, errorMessage);
    }

    /**
     * @description tests to verify errormessage when stage is Priced and Offer Sent To Customer is true 
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetTenderAvailableForSendingTenderIsNotInPricedStageOfferSentError() {
        AITM_GeneratedOfferButtonControllerTestSetup testSetup = new AITM_GeneratedOfferButtonControllerTestSetup().generateData();
        
        AITM_Tender__c tender = testSetup.tender;
        tender.AITM_Stage__c = STAGE_PRICED;
        tender.AITM_Offer_Sent_To_A_Customer__c = true;
        update tender;

        Test.startTest();
        String errorMessage = AITM_GeneratedOfferButtonController.getTenderAvailableForEmailSending(tender.Id);
        Test.stopTest();
		System.assertEquals(null, errorMessage);
    }

    /**
     * @description tests to verify the field AITM_Offer_Sent_To_A_Customer__c is true when tender is updated after email sent
     * @param  null
     * @return void
     */
    @isTest  
    static void testIsUpdateTenderAfterEmailSentUpdatesTender() {
        AITM_GeneratedOfferButtonControllerTestSetup testSetup = new AITM_GeneratedOfferButtonControllerTestSetup().generateData();
        
        AITM_Tender__c tender = testSetup.tender;
        tender.AITM_Produce_Customer_Email__c = true;
        tender.AITM_Offer_Sent_To_A_Customer__c = false;
        update tender;

        Test.startTest();
            AITM_GeneratedOfferButtonController.updateTenderAfterEmailSent(tender.Id);
            AITM_Tender__c updatedTender = new AITM_TenderDao().getTender(tender.Id);
        Test.stopTest();

        System.assertEquals(true, updatedTender.AITM_Offer_Sent_To_A_Customer__c);

    }

    /**
     * @description tests to verify email subject the tender offer email
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetEmail() {
        AITM_GeneratedOfferButtonControllerTestSetup testSetup = new AITM_GeneratedOfferButtonControllerTestSetup().generateData();
        AITM_Tender__c tender = testSetup.tender;
        Date startDate = tender.AITM_Start_Date__c;
        Date endDate = tender.AITM_End_Date__c;
        String emailSubject  = 'Air BP offer dated '+ Date.today().format() + ' ' + tender.Name;

        Test.startTest();
            AITM_EmailGeneratorController.EmailDTO emailDTO = AITM_GeneratedOfferButtonController.getEmail(tender.Id);
        Test.stopTest();

        System.assertEquals(emailSubject, emailDTO.subject);
    }

    /**
     * @description test data holder generateofferbutton controller inner class
     */ 
    private class AITM_GeneratedOfferButtonControllerTestSetup extends AITM_TestSetup {

        private AITM_GeneratedOfferButtonController classUnderTest;
        private List<Account> accounts;
        private List<AITM_Location__c> locations;
        private AITM_Tender__c tender;
        private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        private List<AITM_Tender_Location__c> tenderLocations;
        private List<User> locationManagers;
        private AITM_Pricing_Basis__c pricingBasis;
        private final Integer ITEMS_COUNT = 10;
        private final String DEBRIEF_STAGE = 'Debrief';

        /**
         * @description generates the test data for account, Location, Tender, Pricingbasis, 
         * LocationManager users for the test class
         * @param  null
         * @return AITM_GeneratedOfferButtonControllerTestSetup
         */
        private AITM_GeneratedOfferButtonControllerTestSetup generateData(){

            classUnderTest = new AITM_GeneratedOfferButtonController();
                
            accounts = createAccounts(ITEMS_COUNT);
            insert accounts;

            locations = createLocations(ITEMS_COUNT);
            for(AITM_Location__c location : locations){
                location.AITM_Country__c = 'Spain';
            }
            insert locations;
            if(ITEMS_Count > 1) {
                locations[0].AITM_Country__c = 'POLAND';
            }
            update locations;
            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            tender.AITM_Stage__c = DEBRIEF_STAGE;
            
            insert tender;

            createTenderAccounts();

            locationManagers = createUsers(ITEMS_COUNT, 'Air_TMLocation Manager');
            insert locationManagers;

            tenderLocations = createTenderLocations();
            insert tenderLocations;

            pricingBasis = createPricingBasis();
            insert pricingBasis;

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

            upsert result;

        }

        /**
         * @description creates test data for TenderAccounts 
         * @param  null
         * @return void
         */
        private void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
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
                AITM_Tender_Result__c = 'BG'
                );
        }
    }
}