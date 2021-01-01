@isTest 
private class AITM_TenderContractContainerContrlTests {

     static @isTest void testGetFilterOptionWillReturnTenderAccountsForATender() {
        AITM_TenderContractContainerContrlTestSetup testSetup = new AITM_TenderContractContainerContrlTestSetup().generateData();

        Test.startTest();
            List<AITM_TenderContractContainerController.AccountOption> filterOptions = AITM_TenderContractContainerController.getFilterOptions(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(1, filterOptions.size());
        System.assertEquals(testSetup.tenderAccount.Id, filterOptions[0].accountId);
    }

    @isTest 
    static void testAttachOfferDocumentsWillCreateOfferIfValidAccountOptionWillBeTrasphered() {
        AITM_TenderContractContainerContrlTestSetup testSetup = new AITM_TenderContractContainerContrlTestSetup().generateData();

        Test.startTest();
            AITM_TenderContractContainerController.AccountOption filterOption = AITM_TenderContractContainerController.getFilterOptions(testSetup.tender.Id)[0];
            AITM_TenderContractContainerController.attachOfferDocuments(testSetup.tender.Id, filterOption.accountId);
        Test.stopTest();

        String fileName =  Label.AITM_NewContractPDFContractPrefix + Date.today().format() + ':' + testSetup.tender.Name + ':' + testSetup.accounts[0].Name + '.pdf';
        System.assertEquals(1, [SELECT Count() FROM ContentVersion WHERE PathOnClient = :fileName]);
    }

    private class AITM_TenderContractContainerContrlTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public AITM_Tender_Account__c tenderAccount;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;

        public AITM_TenderContractContainerContrlTestSetup generateData() {
            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            insert tender;

            tenderAccount = createTenderAccount(tender.Id, accounts[0].Id);
            insert tenderAccount;

            AITM_Pricing_Basis__c pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test');
            insert pricingBasis;

            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
            for (AITM_Tender_Location_Line_Item__c lineItems : tenderLocations) {
               lineItems.AITM_Pricing_Basis__c = pricingBasis.Id;
               lineItems.AITM_Delivery_Point__c = '1';
               lineItems.AITM_Currency__c = 'USD';
               lineItems.AITM_Unit_Of_Measure__c = 'LT'; 
               lineItems.AITM_Offered_Differential__c = 1.0;
            }
            insert tenderLocations;

            return this;
        }
    }
}