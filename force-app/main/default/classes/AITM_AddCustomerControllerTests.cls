@isTest 
private with sharing class AITM_AddCustomerControllerTests {
    @isTest 
    static void testCustomersSearchWillReturnValidResultOnValidSearchKey() {
        AddCustomerControllerTestSetup testSetup = new AddCustomerControllerTestSetup();
        List<Id> fixedSearchResults = new List<Id>(new Map<Id, SObject>(testSetup.accounts).keySet());

        Test.startTest();
            Test.setFixedSearchResults(fixedSearchResults);
            List<Account> results = AITM_AddCustomerController.searchCustomers('Test', testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(testSetup.accounts.size(), results.size());
    }

    @isTest 
    static void testCustomersSearchWillReturnValidResultOnInvalidSearchKey() {
        AddCustomerControllerTestSetup testSetup = new AddCustomerControllerTestSetup();

        Test.startTest();
            Test.setFixedSearchResults(new List<Id>());
            List<Account> results = AITM_AddCustomerController.searchCustomers('invalid account name', testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    @isTest 
    static void testSaveWillWorkFineWithoutTenderLocations() {
        AddCustomerControllerTestSetup testSetup = new AddCustomerControllerTestSetup();

        Test.startTest();
            String voidList = JSON.serialize(new List<AITM_AddCustomerController.TenderLocationWrapper>());
            AITM_AddCustomerController.saveTenderAccountWithRelatedData(voidList, testSetup.accounts[0].Id, testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
    }

    @isTest 
    static void testWhenTenderLocationsAreCreatedTenderLocationsWrapperAreReturned() {
        AddCustomerControllerTestSetup testSetup = new AddCustomerControllerTestSetup();
        testSetup.createTenderLocations();

        Test.startTest();
            List<AITM_AddCustomerController.TenderLocationWrapper> result = AITM_AddCustomerController.getTenderLocations(testSetup.tender.Id);
        Test.stopTest();

      System.assertEquals(10, result.size());
      for (AITM_AddCustomerController.TenderLocationWrapper wrapper : result) {
            System.assertEquals(null, wrapper.accountId);
            System.assertEquals(testSetup.tender.Id, wrapper.tenderId);
        }
    }

    @isTest 
    static void testNewTenderLocationLineItemsWillBeCreatedIfTheyArePassed() {
        AddCustomerControllerTestSetup testSetup = new AddCustomerControllerTestSetup();
        testSetup.createTenderLocations();
        
        Test.startTest();
            List<AITM_AddCustomerController.TenderLocationWrapper> listToSave = AITM_AddCustomerController.getTenderLocations(testSetup.tender.Id);
         for (AITM_AddCustomerController.TenderLocationWrapper wrapper : listToSave) {
                wrapper.accountId = testSetup.accounts[1].Id;
                wrapper.isSelected = true;
            }
              AITM_AddCustomerController.validateTenderAccountWithRelatedData(testSetup.accounts[1].Id);
              AITM_AddCustomerController.saveTenderAccountWithRelatedData(JSON.serialize(listToSave), testSetup.accounts[1].Id, testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(1+1, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        System.assertEquals(10, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Account__c = :testSetup.accounts[1].Id]);
  
}
    
    @isTest 
    static void testUpdateLocationIfStraddled() {
        AddCustomerControllerTestSetup testSetup = new AddCustomerControllerTestSetup();
        AITM_AddCustomerController controller = new AITM_AddCustomerController();
        
        Test.startTest();
            controller.updateLocationIfStraddled(testSetup.accounts[0].Id, testSetup.tender.Id);
         Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM AITM_Tender_Location__c WHERE AITM_Is_Straddled__c = false]);
    }

    private with sharing class AddCustomerControllerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public AITM_Tender_Location__c straddledLocation; 
        public AITM_Tender_Location_Line_Item__c straddledLineItem; 
        public AITM_Pricing_Basis__c pricingBasis;

        public AddCustomerControllerTestSetup(){
            accounts = createAccounts(10);
            insert accounts;
            locations = createLocations(10);
            insert locations;
            pricingBasis = new AITM_Pricing_Basis__c(Name = 'None - Air BP not Represented');
            insert pricingBasis;
            tender = createTender();
            insert tender;
            straddledLocation = createStraddledTenderLocation(tender.Id, locations[0].Id);
            insert straddledLocation;
            straddledLineItem = createStraddledTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id, straddledLocation.Id);
            insert straddledLineItem;
            AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
			settings.AITM_IsActive__c = true;
			upsert settings AITM_DeactivateTriggerSetting__c.Id;
            
        }

        public void createTenderLocations() {
            insert createTenderAccount(tender.Id, accounts[0].Id);
            insert createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, new List<Account>{accounts[0]}, locations);  
        }
    }

}