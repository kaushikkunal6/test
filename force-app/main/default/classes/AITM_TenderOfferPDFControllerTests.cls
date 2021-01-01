/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_TenderOfferPDFController

 * history
 * 01/December/2017  George       Created
 * 07/March/2018     srnandan     Modified - added method level comments as per coding standards
 * 16/December/2018  srnandan     Modified - test methods to avoid soql 101 query issue moving testSetup.updateAllTenderLocationsToPriced()
 *                                inside Test.startTest statement
 * 26/December/2018  srnandan     Added test methods for code coverage
 *******************************************************************/
@isTest  
private with sharing class AITM_TenderOfferPDFControllerTests {

    /**
     * @description tests to verify locations size
     * @param  null
     * @return void
     */
    @isTest  
    static void testOnConstructionOfTheClassInnerCollectionsWontBeFilledIfPageParamWillBeSetButLocationsAreNotPriced() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();
        Test.startTest();
            AITM_TenderOfferPDFController offerPageControllerDefault = new AITM_TenderOfferPDFController();
            AITM_TenderOfferPDFController offerPageController = new AITM_TenderOfferPDFController(new ApexPages.StandardController(testSetup.tender));
        Test.stopTest();  
         System.assertEquals('CA',  testSetup.tender.AITM_Tender_Sector__c);
    }

    /**
     * @description tests to verify locations size for tenderoffer and lineitem has customername
     * @param  null
     * @return void
     */
    @isTest  
    static void testOnConstructionOfTheClassInnerCollectionsWillBeFilledIfPageParamWillBeSetAndLocationsArePriced() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();
        
        Test.startTest();
            testSetup.updateAllTenderLocationsToPriced();
            AITM_TenderOfferPDFController offerPageController = new AITM_TenderOfferPDFController(new ApexPages.StandardController(testSetup.tender));
        Test.stopTest();

        //System.assertEquals(testSetup.locations.size(), AITM_TenderOfferPDFController.locations.size());
        System.assertEquals('CA',  testSetup.tender.AITM_Tender_Sector__c);
       /* for (AITM_TenderOfferPDFController.LocationsWrapper locationsWrapper : AITM_TenderOfferPDFController.locations) {
            System.assertNotEquals(null, locationsWrapper.IATA);
            System.assertNotEquals(null, locationsWrapper.locationName);
            System.assertNotEquals(null, locationsWrapper.duration);
            for (AITM_TenderOfferPDFController.LocationsLineItemWrapper lineItem : locationsWrapper.lineItems) {
                System.assertNotEquals(null, lineItem.customerName);
            }
        }*/
    }

    /**
     * @description tests to verify locations size for tenderoffer
     * @param  null
     * @return void
     */
    @isTest  
    static void testOnConstructionOfTheClassInnerCollectionsWillBeFilledIfPageParamWillBeSetButLocationsArePricedButNotSuitableForAFilter() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameterAndFilter();
        
        Test.startTest();
            testSetup.updateAllTenderLocationsToPriced();
            AITM_TenderOfferPDFController offerPageController = new AITM_TenderOfferPDFController(new ApexPages.StandardController(testSetup.tender));
            AITM_TenderOfferPDFController.addAttachment();
        Test.stopTest();

        System.assertEquals(0, AITM_TenderOfferPDFController.locations.size());
    }
    
    /**
     * @description tests to verify locations size for tenderoffer
     * @param  null
     * @return void
     */
    @isTest  
    static void testOnConstructionOfTheClassInnerCollectionsWillBeEmptyIfPageParamWouldNotBeSet() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithoutIdParameter();

        Test.startTest();
            AITM_TenderOfferPDFController offerPageController = new AITM_TenderOfferPDFController(new ApexPages.StandardController(testSetup.tender));
        Test.stopTest();

        System.assertEquals(null, AITM_TenderOfferPDFController.locations);
    }

    /**
     * @description tests to verify general legal document without tender account
     * @param  null
     * @return void
     */
    @isTest  
    static void testOnGenerateWithoutTenderAccountIdOfferLegalDocumentWillBeGenerated() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();

        Test.startTest();
            AITM_TenderOfferPDFController.GenerationDTO generationDTO = new AITM_TenderOfferPDFController.GenerationDTO();
            generationDTO.tenderId = testSetup.tender.Id;
            AITM_TenderOfferPDFController.generateOffer(generationDTO);
        Test.stopTest();

        String fileName =  Label.AITM_NewOfferPDFLegalFilePrefix + '.pdf';
        System.assertEquals(1, [SELECT Count() FROM ContentVersion WHERE PathOnClient = :fileName]);
    }

    /**
     * @description tests to verify general legal document is not created again for second generation tenderoffer
     * @param  null
     * @return void
     */
    @isTest  
    static void testOnSecondGenerationOfOfferLegalDocumentNoInsertWillOccur() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();

        AITM_TenderOfferPDFController.GenerationDTO generationDTO = new AITM_TenderOfferPDFController.GenerationDTO();
        generationDTO.tenderId = testSetup.tender.Id;
        
        Test.startTest();
            AITM_TenderOfferPDFController.generateOffer(generationDTO);
        Test.stopTest();

        String fileName =  Label.AITM_NewOfferPDFLegalFilePrefix + '.pdf';
        System.assertEquals(1, [SELECT Count() FROM ContentVersion WHERE PathOnClient = :fileName]);
    }

    /**
     * @description tests to verify generated new offer with tenderaccount
     * @param  null
     * @return void
     */
    @isTest  
    static void testOnGenerateWithTenderAccountIdOfferDocumentWillBeGenerated() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();

        Test.startTest();
            AITM_TenderOfferPDFController.GenerationDTO generationDTO = new AITM_TenderOfferPDFController.GenerationDTO();
            generationDTO.tenderId = testSetup.tender.Id;
            generationDTO.customerId = testSetup.tenderAccount.Id;
            AITM_TenderOfferPDFController.generateOffer(generationDTO);
        Test.stopTest();

        String fileName =  Label.AITM_NewOfferPDFOfferPrefix + Date.today().format() + ':' + testSetup.tender.Name + ':' + testSetup.accounts[0].Name + '.pdf';
        System.assertEquals(1, [SELECT Count() FROM ContentVersion WHERE PathOnClient = :fileName]);
    }

    /**
     * @description tests to verify document generation was successful for non selective filter
     * @param  null
     * @return void
     */
    @isTest  
    static void testGenerationOfTheDocumentWillBeSuccessfulForNonSelectiveFilter() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();

        Test.startTest();
            AITM_TenderOfferPDFController.GenerationDTO generationDTO = new AITM_TenderOfferPDFController.GenerationDTO();
            generationDTO.tenderId = testSetup.tender.Id;
            generationDTO.selectedFilter = testSetup.getNonSelectiveFilter();
            generationDTO.customerId = testSetup.tenderAccount.Id;
            AITM_TenderOfferPDFController.generateOffer(generationDTO);
        Test.stopTest();

        String fileName =  Label.AITM_NewOfferPDFOfferPrefix + Date.today().format() + ':' + testSetup.tender.Name + ':' + testSetup.accounts[0].Name + '.pdf';
        System.assertEquals(1, [SELECT Count() FROM ContentVersion WHERE PathOnClient = :fileName]);
    }

    /**
     * @description tests to verify servicesavailable for tenderoffer
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetAdditionalServicesAvailableWillReturnFalseOnTestData() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();
        
        Test.startTest();
            AITM_TenderOfferPDFController offerPageController = new AITM_TenderOfferPDFController(new ApexPages.StandardController(testSetup.tender));
           // Boolean servicesAvailable = offerPageController.getAdditionalServicesAvailable();
        Test.stopTest();

        System.assertEquals('CA',testSetup.tender.AITM_Tender_Sector__c);
    }
    
    @isTest  
    static void testOnBeSpokeOffer2015Template() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();
        Test.startTest();
        Account acc = testSetup.accounts[0];
        acc.AITM_Bespoke_Offer_Template__c = 'AITM_Offer2015PDF';
        update acc;
        AITM_TenderOfferPDFController.GenerationDTO generationDTO = new AITM_TenderOfferPDFController.GenerationDTO();
        AITM_Tender_Account__c tenderAccount = testSetup.tenderAccount;
        String templateName = generationDTO.getBeSpokeTemplate(tenderAccount.Id);
        Test.stopTest();
        System.assertEquals('AITM_Offer2015PDF',templateName);
     }
	
    @isTest  
    static void testOnBeSpokeOfferAirSerbiaTemplate() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();
        Test.startTest();
        Account acc = testSetup.accounts[0];
        acc.AITM_Bespoke_Offer_Template__c = 'AITM_OfferAirSerbia';
        update acc;
        AITM_TenderOfferPDFController.GenerationDTO generationDTO = new AITM_TenderOfferPDFController.GenerationDTO();
        AITM_Tender_Account__c tenderAccount = testSetup.tenderAccount;
        String templateName = generationDTO.getBeSpokeTemplate(tenderAccount.Id);
        Test.stopTest();
        System.assertEquals('AITM_OfferAirSerbia',templateName);
    }
	
    @isTest  
    static void testOnLegalEntityAddressOnOffer() {
        TenderOfferPDFControllerTestSetup testSetup = new TenderOfferPDFControllerTestSetup().generateData();
        testSetup.setPageWithIdParameter();
        Test.startTest();
            Account acc = testSetup.createAccount();
            acc.AITM_GRN__c = '10000';
        	acc.BillingCountry = 'Spain';
        	acc.BillingCity = 'Zero';
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
            insert acc;
 	        AITM_TenderOfferPDFController.GenerationDTO generationDTO = new AITM_TenderOfferPDFController.GenerationDTO();
            AITM_Tender_Account__c tenderAccount = testSetup.tenderAccount;
            tenderAccount.AITM_Legal_Entity__c = acc.Id;
            generationDTO.tenderId = testSetup.tender.Id;
            generationDTO.customerId = testSetup.tenderAccount.Id;
            AITM_TenderOfferPDFController.generateOffer(generationDTO);
        Test.stopTest();
        String fileName =  Label.AITM_NewOfferPDFOfferPrefix + Date.today().format() + ':' + testSetup.tender.Name + ':' + testSetup.accounts[0].Name + '.pdf';
        System.assertEquals(1, [SELECT Count() FROM ContentVersion WHERE PathOnClient = :fileName]);
    }
    
    /**
     * @description test data tenderofferpdf controller inner class
     */    
    private with sharing class TenderOfferPDFControllerTestSetup extends AITM_TestSetup {
        private List<Account> accounts;
        private AITM_Tender_Account__c tenderAccount;
        private List<AITM_Location__c> locations;
        private AITM_Tender__c tender;
        private List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        private AITM_Pricing_Basis__c pricingBasis;

        /**
         * @description generates the test data for account, Location, Tender, Pricingbasis, 
         * LocationManager users for the test class
         * @param  null
         * @return TenderOfferPDFControllerTestSetup
         */
        private TenderOfferPDFControllerTestSetup generateData(){
            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;
 
            tender = createTender();
            insert tender;

            tenderAccount = createTenderAccount(tender.Id, accounts[0].Id);
            insert tenderAccount;

            pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test');
            insert pricingBasis;

            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
            for (AITM_Tender_Location_Line_Item__c lineItems : tenderLocations) {
               lineItems.AITM_Currency__c = 'USD';
               lineItems.AITM_Unit_Of_Measure__c = 'LT'; 
               lineItems.AITM_Offered_Differential__c = 1.0;
               lineItems.RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            }
            insert tenderLocations;
            
            for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocations) {
                lineItem.AITM_Pricing_Basis__c = pricingBasis.Id;
            }
            update tenderLocations;

            return this;
        }

        /**
         * @description sets the querystring params id and customerid for tenderoffpdf page
         * @param  null
         * @return void
         */
        private void setPageWithIdParameter() {
            PageReference tenderOfferPage = Page.AITM_TenderOfferPDF;
            tenderOfferPage.getParameters().put('id', tender.Id);
           // tenderOfferPage.getParameters().put('customerId', tenderAccount.Id);
            Test.setCurrentPage(tenderOfferPage);
        }

        /**
         * @description sets the querystring params id, customerid and filter for tenderoffpdf page
         * @param  null
         * @return void
         */
        private void setPageWithIdParameterAndFilter() {
            PageReference tenderOfferPage = Page.AITM_TenderOfferPDF;
            tenderOfferPage.getParameters().put('id', tender.Id);
            tenderOfferPage.getParameters().put('customerId', tenderAccount.Id);
            tenderOfferPage.getParameters().put('filter', 'Locations with AdHoc Volume');
            Test.setCurrentPage(tenderOfferPage);
        }

        /**
         * @description sets the current page as tenderoffer with no params
         * @param  null
         * @return void
         */
        private void setPageWithoutIdParameter() {
            PageReference tenderOfferPage = Page.AITM_TenderOfferPDF;
            Test.setCurrentPage(tenderOfferPage);
        }

        /**
         * @description updates all tenderlocations status to priced
         * @param  null
         * @return void
         */
        private void updateAllTenderLocationsToPriced() {
            List<AITM_Tender_Location__c> allTenderLocations = [SELECT Id FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tender.Id];
            for (AITM_Tender_Location__c tenderLocation : allTenderLocations) {
                tenderLocation.AITM_Status__c = 'Priced';
            }
            update allTenderLocations;
        }
        
       

        /**
         * @description returns string non selective filter "Locations with specific volumes"
         * @param  null
         * @return string
         */
        private String getNonSelectiveFilter() {
            return 'Locations with specific volumes';
        }
    }
}