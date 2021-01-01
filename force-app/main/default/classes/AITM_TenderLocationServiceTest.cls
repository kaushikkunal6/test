/**************************************************************************
 * @author           Aru
 * @date             19/Nov/2020
 * @description      Test class for AITM_TenderLocationService
 *******************************************************************/
 
@isTest 
private with sharing class AITM_TenderLocationServiceTest{
    @isTest 
    static void testGetWrapperTLLIFields() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id,i)
            );
        }
        insert items;
    
        Test.startTest();
            AITM_TenderLocationService.getWrapperTLLIFields(tenderLocation.Id, 'AITM_Tender_Location_Taxes_and_Fees__c');
        Test.stopTest();
    
        System.assertEquals(lineItemsCount, items.size());
        System.assertEquals(tenderLocation.Id, items[0].AITM_Tender_Location__c);    
    }
    
    @isTest 
    static void testGetWrapperTLLIFieldsHighestVolume() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
        
        String exchange = 'ECB';
        String measure = 'Gross';
        String deliveryMethod = 'Bulk';
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            if(i == 0){
                exchange = 'IATA';
                measure ='Net';
                deliveryMethod ='Into-Wing with Into-Plane';
            }
            
            items.add( 
                testSetup.createTLIWithColorCodes(tenderId, account.Id, location.Id, tenderLocation.Id,i, exchange, measure, deliveryMethod)
            );
        }
        insert items;
           
        Test.startTest();
            AITM_TenderLocationService.getWrapperTLLIFields(tenderLocation.Id, 'AITM_Tender_Location_Taxes_and_Fees__c');
        Test.stopTest();   
    }
    
    @isTest 
    static void testGetWrapperTLLIFieldsAffiliates() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
        
        AITM_Tender_Account__c tendorCustomer = new AITM_Tender_Account__c(
                                                                            AITM_Tender__c = tenderId,
                                                                            AITM_Account__c = account.Id,
                                                                            AITM_Affiliates_Account__c = account.Id
                                                                          );
        insert tendorCustomer;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id,i)
            );
        }
        insert items;
    
        Test.startTest();
            AITM_TenderLocationService.getWrapperTLLIFields(tenderLocation.Id, 'AITM_Tender_Location_Taxes_and_Fees__c');
        Test.stopTest();    
    }
    
    @isTest 
    static void testGetWrapperTLLIFieldsForOneItem() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
        
        AITM_Location__c forOneLocation = testSetup.createLocation();
        insert forOneLocation;
        
        AITM_Tender_Location__c forOneTenderLocation = testSetup.createTenderLocation(tenderId, forOneLocation.Id);
        insert forOneTenderLocation;

        List<AITM_Tender_Location_Line_Item__c> forOneItem = new List<AITM_Tender_Location_Line_Item__c>();
        
        for(Integer i = 0; i < 1; i++){
            forOneItem.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, forOneLocation.Id, forOneTenderLocation.Id,i)
            );
        }
        insert forOneItem;
    
        Test.startTest();
            AITM_TenderLocationService.getWrapperTLLIFields(forOneTenderLocation.Id, 'AITM_Tender_Location_Taxes_and_Fees__c');
        Test.stopTest();
    }
    
    @isTest 
    static void testUpdateAllLinesWithMasterLOI() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id,i)
            );
        }
        insert items;
    
        Test.startTest();
            AITM_TenderLocationService.updateAllLinesWithMasterLOI(tenderLocation.Id, 'High');
        Test.stopTest();
    }
    
    @isTest 
    static void testLineItems() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id,i)
            );
        }
        insert items;
    
        Test.startTest();
            AITM_TenderLocationService.getLineItems(tenderLocation.Id, 'AITM_Tender_Location_Line_Item__c');
        Test.stopTest();   
    }
    
    @isTest 
    static void testGetTaxesAndFees() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id,i)
            );
        }
        insert items;
    
        Test.startTest();
            AITM_TenderLocationService.getTaxesAndFees(items[0].Id, 'AITM_Tender_Location_Taxes_and_Fees__c');
        Test.stopTest();
    }
    
    @isTest 
    static void testSaveTaxesAndFees() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id,i)
            );
        }
        insert items;
        
        List<AITM_Tender_Location_Taxes_and_Fees__c> fees = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            fees.add( 
                testSetup.createTenderLocationTF(tenderId, account.Id, location.Id, items[0].Id,i)
            );
        }
        insert fees;
        
        List<AITM_Tender_Location_Taxes_and_Fees__c> newFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            newFees.add( 
                testSetup.newTF(tenderId, account.Id, location.Id, items[0].Id,i)
            );
        }
    
        Test.startTest();
            AITM_TenderLocationService.saveTaxesAndFees(fees, newFees ,items[0].Id, '', '', false, true);
        Test.stopTest();
    }
    
    private with sharing class TenderLocationNewOfferTestSetup extends AITM_TestSetup {
        public AITM_TenderLocationNewOffer classUnderTest;
    
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public AITM_Pricing_Basis__c pricingBasis;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        public AITM_Tender_Location__c straddledLocation; 
        public AITM_Tender_Location_Line_Item__c straddledLineItem; 
    
        public TenderLocationNewOfferTestSetup generateData(){
            classUnderTest = new AITM_TenderLocationNewOffer();
    
            accounts = createAccounts(10);
            insert accounts;
    
            locations = createLocations(10);
            insert locations;
    
            tender = createTender();
            insert tender;
    
            createTenderLocations();
        
            pricingBasis = createPricingBasis();
            INSERT pricingBasis;
            
            straddledLocation = createStraddledTenderLocation(tender.Id, locations[0].Id);
            insert straddledLocation;
            
            straddledLineItem = createStraddledTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id, straddledLocation.Id);
            insert straddledLineItem;
            
            return this;
        }
        
        /**
         * @description calls the test data for Tender Accounts
         * @param null
         * @return Tender Accounts
         */
        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }
      
        /**
         * @description creates the test data for PricingBasis
         * @param null
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
         * @description creates the test data for Tender Location Line Items
         * @param null
         * @return Tender Location Line Items
         */
        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }
        
        /**
         * @description creates the test data for Tender Accounts
         * @param null
         * @return Tender Accounts
         */
        public void createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
                for(AITM_Location__c location : locations){
                tenderLocations.add(
                    createTenderLocation(tender.Id, location.Id)
                );
            }
            insert tenderLocations;
        }
         
         /**
         * @description creates the test data for Line Items
         * @param tenderId of type Id
         * @param accountId of type Id
         * @param locationId of type Id
         * @param tenderLocationId of type Id
         * @param Volume USG of type Integer
         * @param Exchange of type String
         * @param Measure of type String
         * @param Delivery Method of type String
         * @return AITM_Tender_Location_Line_Item__c
         */
         public AITM_Tender_Location_Line_Item__c createTLIWithColorCodes(Id tenderId, Id accountId, Id locationId, Id tenderLocationId, Integer volUsg, String exchange, String measure, String deliveryMethod) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Pricing_Basis__c = pricingBasis.Id,
                AITM_Requested_Volume_USG__c = Integer.valueOf(volUsg),
                AITM_Exchange__c = String.valueOf(exchange),
                AITM_Measure__c = String.valueOf(measure),
                AITM_Delivery_Method__c = String.valueOf(deliveryMethod),
                RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId()
            );
        }
        
         /**
         * @description creates the test data for Line Items
         * @param tenderId of type Id
         * @param accountId of type Id
         * @param locationId of type Id
         * @param tenderLocationId of type Id
         * @param Volume USG of type Integer
         * @param Exchange of type String
         * @param Measure of type String
         * @param Delivery Method of type String
         * @return AITM_Tender_Location_Line_Item__c
         */
        public AITM_Tender_Location_Line_Item__c createTenderLocationLineItemWithColorCodes(Id tenderId, Id accountId, Id locationId, Id tenderLocationId, Integer volUsg, String exchange, String measure, String deliveryMethod) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0,
                AITM_Pricing_Basis__c = pricingBasis.Id,
                AITM_Requested_Volume_USG__c = Integer.valueOf(volUsg),
                AITM_Exchange__c = String.valueOf(exchange),
                AITM_Measure__c = String.valueOf(measure),
                AITM_Delivery_Method__c = String.valueOf(deliveryMethod),
                RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId()
            );
        }
        
         /**
         * @description creates the test data for Line Items
         * @param tenderId of type Id
         * @param accountId of type Id
         * @param locationId of type Id
         * @param tenderLocationId of type Id
         * @param Volume USG of type Integer
         * @return AITM_Tender_Location_Line_Item__c
         */
        public AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId, Integer volUsg) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0,
                AITM_Pricing_Basis__c = pricingBasis.Id,
                AITM_Requested_Volume_USG__c = Integer.valueOf(volUsg),
                RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId()
            );
        }
        
        /**
         * @description creates the test data for T&F
         * @param tenderId of type Id
         * @param accountId of type Id
         * @param locationId of type Id
         * @param tenderLocationId of type Id
         * @param Volume USG of type Integer
         * @return T&F
         */
        public AITM_Tender_Location_Taxes_and_Fees__c createTenderLocationTF(Id tenderId, Id accountId, Id locationId, Id tenderLocationId, Integer volUsg) {
            return new AITM_Tender_Location_Taxes_and_Fees__c(
                Tender_Location_Line_Item_Id__c = tenderLocationId,
                Name = 'Test',
                AITM_Compulsory_Conditional__c = 'Conditional'
            );
        }
        
        /**
         * @description creates the test data for T&F
         * @param tenderId of type Id
         * @param accountId of type Id
         * @param locationId of type Id
         * @param tenderLocationId of type Id
         * @param Volume USG of type Integer
         * @return T&F
         */
        public AITM_Tender_Location_Taxes_and_Fees__c newTF(Id tenderId, Id accountId, Id locationId, Id tenderLocationId, Integer volUsg) {
            return new AITM_Tender_Location_Taxes_and_Fees__c(
                Tender_Location_Line_Item_Id__c = tenderLocationId,
                Name = 'Test',
                AITM_Compulsory_Conditional__c = 'Conditional'
            );
        }       
    }
}