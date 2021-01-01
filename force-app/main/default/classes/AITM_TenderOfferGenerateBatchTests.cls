@isTest 
private class AITM_TenderOfferGenerateBatchTests {

    @isTest 
    static void testBatchGenerationWillBeSuccessfulAndDocumentsWillBeAttached() {
        TenderOfferGenerateBatchTestSetup testSetup = new TenderOfferGenerateBatchTestSetup().generateData();
        AITM_TenderOfferGenerateBatch.BatchFactory batchFactory = new AITM_TenderOfferGenerateBatch.BatchFactory();

        Test.startTest();
            batchFactory.executeBatch(new AITM_TenderOfferGenerateBatch.BatchState(testSetup.tender.Id, 'All Locations'));
        Test.stopTest();

        String legalFileName =  Label.AITM_NewOfferPDFLegalFilePrefix + '.pdf';
        String fileName =  Label.AITM_NewOfferPDFOfferPrefix + Date.today().format() + ':' + testSetup.tender.Name + ':' + testSetup.accounts[0].Name + '.pdf';
        System.assertEquals(2, [SELECT Count() FROM ContentVersion WHERE PathOnClient = :legalFileName OR PathOnClient = :fileName]);
    }

    @isTest 
    static void testBatchGenerationWontBeSuccessfulForInvalidTenderId() {
        TenderOfferGenerateBatchTestSetup testSetup = new TenderOfferGenerateBatchTestSetup().generateData();
        AITM_TenderOfferGenerateBatch.BatchFactory batchFactory = new AITM_TenderOfferGenerateBatch.BatchFactory();

        Test.startTest();
            batchFactory.executeBatch(new AITM_TenderOfferGenerateBatch.BatchState(testSetup.getRandomTenderId(), 'All Locations'));
        Test.stopTest();

        String legalFileName =  Label.AITM_NewOfferPDFLegalFilePrefix + '.pdf';
        String fileName =  Label.AITM_NewOfferPDFOfferPrefix + Date.today().format() + ':' + testSetup.tender.Name + ':' + testSetup.accounts[0].Name + '.pdf';
        System.assertEquals(0, [SELECT Count() FROM ContentVersion WHERE PathOnClient = :legalFileName OR PathOnClient = :fileName]);
    }

    private class TenderOfferGenerateBatchTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public AITM_Tender_Account__c tenderAccount;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;

        public TenderOfferGenerateBatchTestSetup generateData(){
            accounts = createAccounts(10);
            insert accounts;

            tender = createTender();
            insert tender;

            tenderAccount = createTenderAccount(tender.Id, accounts[0].Id);
            insert tenderAccount;

            return this;
        }

        public Id getRandomTenderId() {
            AITM_Tender__c result = createTender();
            insert result;
            return result.Id;
        }
    }
}