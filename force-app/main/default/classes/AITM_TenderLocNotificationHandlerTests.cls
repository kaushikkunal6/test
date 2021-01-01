@isTest 
private class AITM_TenderLocNotificationHandlerTests {
	
	private static final String STATUS_AWAITING_PRICE = 'awaiting price';

    @isTest 
    static void testIsTenderChangedStatusAfterTenderLocationStatusUpdateToAwaitingPrice() {

        TenderLocNotificationHandlerTestSetup testSetup = new TenderLocNotificationHandlerTestSetup();
        testSetup.generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;

        Test.startTest();
            Integer i = 0;

            for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
                if(i < 2) {
                    tenderLocation.AITM_Status__c = STATUS_AWAITING_PRICE;
                }
                i++;
            }
            upsert tenderLocations;
        Test.stopTest();

        System.assertNotEquals(STATUS_AWAITING_PRICE, [SELECT Id, AITM_Stage__c FROM AITM_Tender__c WHERE Id = :tender.Id].AITM_Stage__c.toLowerCase());
    }

    private class TenderLocNotificationHandlerTestSetup extends AITM_TestSetup {
        public AITM_TenderHandler classUnderTest;

        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        public List<AITM_Tender_Location__c> tenderLocations;
        public List<User> locationManagers;

        public TenderLocNotificationHandlerTestSetup(){
        	classUnderTest = new AITM_TenderHandler();
        }

        public void generateData() {
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
                AITM_Offered_Volume__c = 1
            );
        }

    }
}