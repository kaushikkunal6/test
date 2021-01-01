@isTest 
private class AITM_ChangeCustomerControllerTests {
    @isTest 
    static void testCustomersSearchWillReturnValidResultOnValidSearchKey() {
        ChangeCustomerControllerTestSetup testSetup = new ChangeCustomerControllerTestSetup();
        List<Id> fixedSearchResults = new List<Id>(new Map<Id, SObject>(testSetup.accounts).keySet());

        Test.startTest();
            Test.setFixedSearchResults(fixedSearchResults);
            List<Account> results = AITM_ChangeCustomerController.searchCustomers('Test', testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(testSetup.accounts.size(), results.size(), 'The accounts size is equal to results size');
    }
    
    @isTest 
    static void testCustomersSearchWillReturnValidResultOnInvalidSearchKey() {
        ChangeCustomerControllerTestSetup testSetup = new ChangeCustomerControllerTestSetup();

        Test.startTest();
            Test.setFixedSearchResults(new List<Id>());
            List<Account> results = AITM_ChangeCustomerController.searchCustomers('invalid account name', testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'The result size is equal to zero');
    }
    
    @isTest 
    static void testSaveWillWorkFineWithoutTenderLocations() {
        ChangeCustomerControllerTestSetup testSetup = new ChangeCustomerControllerTestSetup();

        Test.startTest();
            String voidList = JSON.serialize(new List<AITM_ChangeCustomerController.TenderLocationItemWrapper>());
            AITM_ChangeCustomerController.saveTenderAccountWithRelatedData(voidList, testSetup.accounts[0].Id, testSetup.accounts[1].Id, testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tender.Id], 'The result size is equal to 1');
    }
    
    @isTest 
    static void testWhenTenderLocationsAreCreatedTenderLocationsWrapperAreReturned() {
        ChangeCustomerControllerTestSetup testSetup = new ChangeCustomerControllerTestSetup();
        testSetup.createTenderLocations();

        Test.startTest();
            List<AITM_ChangeCustomerController.TenderLocationItemWrapper> result = AITM_ChangeCustomerController.getTenderLocationLineItems(testSetup.tender.Id);   
        Test.stopTest();

        System.assertEquals(10, result.size(), 'The result size is equal to 10');
        for (AITM_ChangeCustomerController.TenderLocationItemWrapper wrapper : result) {
            System.assertEquals(testSetup.tender.Id, wrapper.tenderId, 'The tenderId is equal to ' + testSetup.tender.Id);
        }
    }
	
    @isTest 
    static void testTenderAccountCustomers() {
        ChangeCustomerControllerTestSetup testSetup = new ChangeCustomerControllerTestSetup();
        testSetup.createTenderLocations();

        Test.startTest();
            List<AITM_ChangeCustomerController.TenderAccountCustomerWrapper> result = AITM_ChangeCustomerController.getTenderAccountCustomers(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'The result is equal to 1');
        for (AITM_ChangeCustomerController.TenderAccountCustomerWrapper wrapper : result) {
            System.assertEquals(testSetup.tender.Id, wrapper.tenderId, 'The tenderId is equal to ' + testSetup.tender.Id);
        }
    }

    @isTest 
    static void testNewTenderLocationLineItemsWillBeCreatedIfTheyArePassed() {
        ChangeCustomerControllerTestSetup testSetup = new ChangeCustomerControllerTestSetup();
        testSetup.createTenderLocations();

        Test.startTest();
            List<AITM_ChangeCustomerController.TenderLocationItemWrapper> listToSave = AITM_ChangeCustomerController.getTenderLocationLineItems(testSetup.tender.Id);
            for (AITM_ChangeCustomerController.TenderLocationItemWrapper wrapper : listToSave) {
                wrapper.accountId = testSetup.accounts[1].Id;
            }
            AITM_ChangeCustomerController.saveTenderAccountWithRelatedData(JSON.serialize(listToSave), testSetup.accounts[1].Id, testSetup.accounts[0].Id, testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tender.Id],'The tender size is equal to 1');
        System.assertEquals(10, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Account__c = :testSetup.accounts[1].Id], 'The tender location line item is equal to 10');
    }

    private class ChangeCustomerControllerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;

        public ChangeCustomerControllerTestSetup(){
            accounts = createAccounts(10);
            insert accounts;
            locations = createLocations(10);
            insert locations;
            tender = createTender();
            insert tender;
        }

        public void createTenderLocations() {
            insert createTenderAccount(tender.Id, accounts[0].Id);
            insert createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, new List<Account>{accounts[0]}, locations);  
        }
    }

}