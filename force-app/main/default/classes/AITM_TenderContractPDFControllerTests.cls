@isTest 
private class AITM_TenderContractPDFControllerTests {
    @isTest 
    static void testOnConstructionOfTheClassInnerCollectionsWontBeFilledIfPageParamWillBeSetButLocationsAreNotPriced() {
        AITM_TenderContractPDFControllerTestSetup testSetup = new AITM_TenderContractPDFControllerTestSetup().generateData();

        Test.startTest();
            AITM_TenderContractPDFController contractPageController = new AITM_TenderContractPDFController(new ApexPages.StandardController(testSetup.tender));
        Test.stopTest();

        System.assertEquals(null, AITM_TenderContractPDFController.locations);
    }

    @isTest 
    static void testOnConstructionOfTheClassInnerCollectionsWillBeFilledIfPageParamWillBeSetAndLocationsArePriced() {
        AITM_TenderContractPDFControllerTestSetup testSetup = new AITM_TenderContractPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();

        Test.startTest();
            AITM_TenderContractPDFController contractPageController = new AITM_TenderContractPDFController(new ApexPages.StandardController(testSetup.tender));
        Test.stopTest();

        //System.assertEquals(testSetup.locations.size(), AITM_TenderContractPDFController.locations.size());
        for (AITM_TenderContractPDFController.LocationsWrapper locationsWrapper : AITM_TenderContractPDFController.locations) {
            System.assertNotEquals(null, locationsWrapper.IATA);
            System.assertNotEquals(null, locationsWrapper.locationName);
            for (AITM_TenderContractPDFController.LocationsLineItemWrapper lineItem : locationsWrapper.lineItems) {
                System.assertNotEquals(null, lineItem.customerName);
            }
        }
    }
    
    @isTest 
    static void testOnConstructionOfTheClassInnerCollectionsWillBeEmptyIfPageParamWouldNotBeSet() {
        AITM_TenderContractPDFControllerTestSetup testSetup = new AITM_TenderContractPDFControllerTestSetup().generateData();
        testSetup.setPageWithoutIdParameter();

        Test.startTest();
            AITM_TenderContractPDFController contractPageController = new AITM_TenderContractPDFController(new ApexPages.StandardController(testSetup.tender));
        Test.stopTest();

        System.assertEquals(null, AITM_TenderContractPDFController.locations);
    }

    @isTest 
    static void testOnGenerateWithoutTenderAccountIdNoContractWillBeGenerated() {
        AITM_TenderContractPDFControllerTestSetup testSetup = new AITM_TenderContractPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();

        Test.startTest();
            AITM_TenderContractPDFController.GenerationDTO generationDTO = new AITM_TenderContractPDFController.GenerationDTO();
            generationDTO.tenderId = testSetup.tender.Id;
            AITM_TenderContractPDFController.generateContract(generationDTO);
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM ContentVersion LIMIT 1]);
    }

    @isTest 
    static void testOnGenerateWithTenderAccountIdContractDocumentWillBeGenerated() {
        AITM_TenderContractPDFControllerTestSetup testSetup = new AITM_TenderContractPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();

        Test.startTest();
            AITM_TenderContractPDFController.GenerationDTO generationDTO = new AITM_TenderContractPDFController.GenerationDTO();
            generationDTO.tenderId = testSetup.tender.Id;
            generationDTO.customerId = testSetup.tenderAccount.Id;
            AITM_TenderContractPDFController.generateContract(generationDTO);
        Test.stopTest();

        String fileName =  Label.AITM_NewContractPDFContractPrefix + Date.today().format() + ':' + testSetup.tender.Name + ':' + testSetup.accounts[0].Name + '.pdf';
        System.assertEquals(1, [SELECT Count() FROM ContentVersion WHERE PathOnClient = :fileName]);
    }

    @isTest 
    static void testGetAdditionalServicesAvailableWillReturnFalseOnTestData() {
        AITM_TenderContractPDFControllerTestSetup testSetup = new AITM_TenderContractPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();

        Test.startTest();
            AITM_TenderContractPDFController contractPageController = new AITM_TenderContractPDFController(new ApexPages.StandardController(testSetup.tender));
            Boolean servicesAvailable = contractPageController.getAdditionalServicesAvailable();
        Test.stopTest();

        System.assertEquals(false, servicesAvailable);
    }

    private class AITM_TenderContractPDFControllerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public AITM_Tender_Account__c tenderAccount;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        private final Id DEBRIEF_RECORD_TYPE = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();

        public AITM_TenderContractPDFControllerTestSetup generateData(){
            AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
			settings.AITM_IsActive__c = true;
			upsert settings AITM_DeactivateTriggerSetting__c.Id;

            accounts = createAccounts(1);
            insert accounts;

            locations = createLocations(1);
            insert locations;

            tender = createTender();
            insert tender;

            tenderAccount = createTenderAccount(tender.Id, accounts[0].Id);
            insert tenderAccount;

            AITM_Pricing_Basis__c pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test');
            insert pricingBasis;

            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
            insert tenderLocations;
            for (AITM_Tender_Location_Line_Item__c lineItems : tenderLocations) {
               lineItems.AITM_Pricing_Basis__c = pricingBasis.Id;
               //lineItems.AITM_Delivery_Point__c = '1';
               lineItems.AITM_Currency__c = 'USD';
               lineItems.AITM_Unit_Of_Measure__c = 'LT'; 
               lineItems.AITM_Offered_Differential__c = 1.0;
               lineItems.RecordTypeId = DEBRIEF_RECORD_TYPE;
               lineItems.AITM_Tender_Result__c = 'BG';
            }
            update tenderLocations;
            return this;
        }

        public void setPageWithIdParameter() {
            PageReference tenderOfferPage = Page.AITM_TenderOfferPDF;
            tenderOfferPage.getParameters().put('id', tender.Id);
            tenderOfferPage.getParameters().put('customerId', tenderAccount.Id);
            Test.setCurrentPage(tenderOfferPage);
        }

        public void setPageWithoutIdParameter() {
            PageReference tenderOfferPage = Page.AITM_TenderOfferPDF;
            Test.setCurrentPage(tenderOfferPage);
        }
    }
}