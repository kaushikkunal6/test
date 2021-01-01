@isTest 
public class AITM_TenderLocNextBackButtonsCntlrTests {
    @isTest 
    static void testGetTenderLocations() {

        TenderLocNextBackButtonsCntlrTestSetup testSetup = new TenderLocNextBackButtonsCntlrTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;

        Test.startTest();
            List<AITM_Tender_Location__c> results = AITM_TenderLocNextBackButtonsCntlr.getTenderLocations(testSetup.tenderLocations[0].Id, null);
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size(), results.size());
    }
    
    @isTest 
    static void testGetTenderIdByTenderLocationId() {

        TenderLocNextBackButtonsCntlrTestSetup testSetup = new TenderLocNextBackButtonsCntlrTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;

        Test.startTest();
            Id tenderId1 = AITM_TenderLocNextBackButtonsCntlr.getTenderIdByTenderLocationId(testSetup.tenderLocations[0].Id);
        Test.stopTest();

        System.assertEquals(tenderId1, tenderId);
    }

    private class TenderLocNextBackButtonsCntlrTestSetup extends AITM_TestSetup {
        public AITM_TenderLocNextBackButtonsCntlr classUnderTest;
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> lineItems;
        public List<AITM_Tender_Location__c> tenderLocations;

        public TenderLocNextBackButtonsCntlrTestSetup generateData(){
            classUnderTest = new AITM_TenderLocNextBackButtonsCntlr();
			
            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            insert tender;

            tenderLocations = createTenderLocations();
            insert tenderLocations;

            return this;
        }

        public Account getAccount() {
            return createAccount();
        }

        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        public void createTenderLocationLineItems() {
            lineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
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

        public AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0
            );
        }

    }
}