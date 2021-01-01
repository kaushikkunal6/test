@IsTest 
private class AITM_TenderLocationFeedbackTests {
    private static final String STAGE_AWAITING_PRICE = 'Awaiting Price';
    private static final String STAGE_FEEDBACK = 'Feedback and Negotiation';

    @isTest 
    static void testIsGetTenderLocationReturnsTenderLocationAndUpdateMethodUpdates() {

        TenderLocationFeedbackTestSetup testSetup = new TenderLocationFeedbackTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;

        Test.startTest();
            tenderLocations[0].AITM_Offered_Differential_Currency__c = 'EUR';
        	AITM_TenderLocationFeedback.updateTenderLocation(tenderLocations[0]);
        	AITM_Tender_Location__c tenderLocation = AITM_TenderLocationFeedback.getTenderLocation(tenderLocations[0].Id);

        Test.stopTest();

        System.assertNotEquals(null, tenderLocation.Id);
        System.assertEquals('EUR', tenderLocation.AITM_Offered_Differential_Currency__c);

    }

    @isTest 
    static void testGetFieldAccess() {
        Test.startTest();
            Map<String, Map<String, Boolean>> fieldsAccess = AITM_TenderLocationFeedback.getFieldsAccess('AITM_Tender_Location__c');
        Test.stopTest();
        System.assertNotEquals(null, fieldsAccess.size());
    }

    @isTest 
    static void testGetPickValues() {
    	Map<String, String> auraIdToFieldName = new Map<String, String>();
    	String auraId = 'last-look-to-incumbent';
    	auraIdToFieldName.put(auraId, 'AITM_Last_Look_To_Incumbent__c');
        Test.startTest();
            Map<String, List<String>> selectOptions = AITM_TenderLocationFeedback.getPickValues('AITM_Tender_Location__c', auraIdToFieldName);
        Test.stopTest();
        System.assertEquals(3, selectOptions.get(auraId).size());
    }

    @isTest 
    static void testGetRoundsOptions() {
        TenderLocationFeedbackTestSetup testSetup = new TenderLocationFeedbackTestSetup().generateData();
        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;
        List<AITM_Tender_Location__c> tenderLocationsToUpdate = new List<AITM_Tender_Location__c>();

        List<AITM_Location__c> locations = testSetup.locations;
        for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
            tenderLocation.AITM_Comments__c = 'Tender Location Round 1';
            tenderLocationsToUpdate.add(tenderLocation);
        }
        update tenderLocationsToUpdate;

        tender.AITM_Stage__c = STAGE_FEEDBACK;
        tender.AITM_No_Feedback_Progress_To_De_Brief__c = false;
        update tender;

        Test.startTest();
            tender.AITM_Stage__c = STAGE_AWAITING_PRICE;
            update tender;
        Test.stopTest();
        System.assertEquals(1, AITM_TenderLocationFeedback.getRoundsOptions(tenderLocations[0].Id).size());
    }

    @isTest 
    static void testGetTenderLocationNewRound() {
        TenderLocationFeedbackTestSetup testSetup = new TenderLocationFeedbackTestSetup().generateData();
        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;
        List<AITM_Tender_Location__c> tenderLocationsToUpdate = new List<AITM_Tender_Location__c>();

        List<AITM_Location__c> locations = testSetup.locations;
        for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
            tenderLocation.AITM_Comments__c = 'Tender Location Round 1';
            tenderLocationsToUpdate.add(tenderLocation);
        }
        update tenderLocationsToUpdate;

        tender.AITM_Stage__c = STAGE_FEEDBACK;
        tender.AITM_No_Feedback_Progress_To_De_Brief__c = false;
        update tender;

        Test.startTest();
            tender.AITM_Stage__c = STAGE_AWAITING_PRICE;
            update tender;
            AITM_Tender_Location__c tendeLocationRound2 = AITM_TenderLocationFeedback.getTenderLocationForRound(tenderLocations[0].Id, 1);
        Test.stopTest();
        
        System.assertEquals(1, tendeLocationRound2.AITM_Current_Round__c);
    }

    private class TenderLocationFeedbackTestSetup extends AITM_TestSetup {
        public AITM_TenderLocationFeedback classUnderTest;

        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        public List<AITM_Tender_Location__c> tenderLocations;
        public List<User> locationManagers;
        public AITM_Pricing_Basis__c pricingBasis;

        public TenderLocationFeedbackTestSetup generateData(){

	        classUnderTest = new AITM_TenderLocationFeedback();

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
	        insert tender;

	        createTenderAccounts();

	        locationManagers = createUsers(10, 'Air_TMLocation Manager');
	        insert locationManagers;

	        tenderLocations = createTenderLocations();
	        insert tenderLocations;

	        pricingBasis = createPricingBasis();
	        insert pricingBasis;

	        attachLocationManagersToTenderLocations(locationManagers, tenderLocations);
            
            return this;
        }

        public List<AITM_Tender_Location__c> createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
            for(AITM_Location__c location : locations){
                tenderLocations.add(
                    createTenderLocation(tender.Id, location.Id)
                );
            }
            return tenderLocations;
        }

        public AITM_Pricing_Basis__c createPricingBasis(){
            return new AITM_Pricing_Basis__c(
               Name = 'P008',
               AITM_Description__c = 'Barges FOB Rotterdam High Prior Month WD',
               AITM_Currency__c = 'USD',
               AITM_Unit_Of_Measure__c = 'USG'
            );
        }

        public void attachLocationManagersToTenderLocations(List<User> locationManagers, List<AITM_Tender_Location__c> tenderLocations) {

            List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
            Integer index = 0;

            for(AITM_Tender_Location__c tenderLocation : tenderLocations){
                tenderLocation.AITM_Location_Manager__c = locationManagers[index].Id;
                result.add(tenderLocation);
                index++;
            }

            upsert result;

        }

        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        public void createTenderLocationLineItems() {
            tenderLocationLineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }

        public AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
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