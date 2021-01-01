@IsTest 
private class AITM_TenderDaoTests {

    @isTest 
    static void testGetTender() {

        TenderDaoTestSetup testSetup = new TenderDaoTestSetup().generateData();

        Id tenderId = testSetup.tender.Id;

        Test.startTest();
            AITM_Tender__c result = testSetup.classUnderTest.getTender(tenderId);
        Test.stopTest();

        System.assertEquals(testSetup.tender.Owner.Name, result.Owner.Name);

    }

    @isTest 
    static void testGetContentVersionBodyByContentVersionId() {
        TenderDaoTestSetup testSetup = new TenderDaoTestSetup().generateData();
        
        Test.startTest();
            Blob result = testSetup.classUnderTest.getContentVersionBodyByContentVersionId(testSetup.contentVers.Id);
        Test.stopTest();

        System.assertEquals(testSetup.BLOB_DATA, result.toString());
    }

    private class TenderDaoTestSetup extends AITM_TestSetup {
        public final String BLOB_DATA = 'testData';
        public AITM_TenderDao classUnderTest;

        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        public ContentVersion contentVers;


        public TenderDaoTestSetup generateData(){

            classUnderTest = new AITM_TenderDao();

            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            insert tender;

            createTenderLocations();

            contentVers = new Contentversion();
            contentVers.title = 'ABC';
            contentVers.PathOnClient = 'test';
            Blob b = Blob.valueOf('Unit Test Attachment Body');
            contentVers.versiondata = Blob.valueOf(BLOB_DATA);
            insert contentVers;
            
            return this;
        }

        public void createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
            for(AITM_Location__c location : locations){
                tenderLocations.add(
                    createTenderLocation(tender.Id, location.Id)
                );
            }
            insert tenderLocations;
        }

        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }
    }

}