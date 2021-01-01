/**************************************************************************
 * @author           Kunal
 * @date             01/October/2020
 * @group            AirBP
 * @description      Test class for AITM_RefreshTaxes
 *******************************************************************/
@isTest 
private with sharing class AITM_RefreshTaxesTests {
    
    /**
     * @description tests to filter the users
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetFilterOptions() {
        Test.startTest();
            List<String> listOfFilters = AITM_RefreshTaxes.getFilterOptions();
        Test.stopTest();

        System.assertNotEquals(null, listOfFilters);
    }
    
    /**
     * @description tests to GetMultiSelectData
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetMultiSelectData() {
        AITM_RefreshTaxesTestSetup testSetup = new AITM_RefreshTaxesTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 1;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
    
        Test.startTest();
            Map<String,  List<String>> tableData = AITM_RefreshTaxes.getMultiSelectData(tenderId);
        Test.stopTest();
    
        System.assertNotEquals(0, tableData.get('locationNames').size());    
    }
    
    /**
     * @description tests to Process the Refresh
     * @param  null
     * @return void
     */
    @isTest  
    static void testProcessingRefresh() {
        AITM_RefreshTaxesTestSetup testSetup = new AITM_RefreshTaxesTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        
        Test.startTest();
        Id jobId = AITM_RefreshTaxes.processingRefresh(tenderId, 'Notes', 'Countries', new List<String>{'London Heathrow'}, true);
        Test.stopTest();

        System.assertEquals(null, jobId);
    }    
    
    
    /**
     * @description test data AITM_RefreshTaxesTestSetup inner class
     */
    private with sharing class AITM_RefreshTaxesTestSetup extends AITM_TestSetup {
        public AITM_RefreshTaxes classUnderTest;
    
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public AITM_Pricing_Basis__c pricingBasis;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        public AITM_Tender_Location__c straddledLocation; 
        public AITM_Tender_Location_Line_Item__c straddledLineItem; 
    
        public AITM_RefreshTaxesTestSetup generateData(){
            classUnderTest = new AITM_RefreshTaxes();
    
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
    
        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
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
         * @description run createTenderLocationLineItems
         * @param null
         * @return void
         */
        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }
        
        /**
         * @description run createTenderLocations
         * @param null
         * @return void
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
         * @description Processing the createTenderLocationLineItem
         * @param tenderId of type Id
         * @param accountId of type Id
         * @param locationId of type Id
         * @param tenderLocationId of type Id
         * @return AITM_Tender_Location_Line_Item__c
         */
      	public AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0,
                AITM_Pricing_Basis__c = pricingBasis.Id,
                RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId()
            );
        }
    
    }
}