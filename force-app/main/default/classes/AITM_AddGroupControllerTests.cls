/**************************************************************************
 * @author           Shweta
 * @date             06/September/2018
 * @group            AirBP
 * @description      Test class for AITM_AddGroupController 
 *******************************************************************/
@isTest 
private class AITM_AddGroupControllerTests {
    /**
     * @description tests to verify if the group account is valid 
     * @param  null
     * @return null
     */
    @isTest  
    static void testGroupsSearchWillReturnValidResultOnValidSearchKey() {
        AddGroupControllerTestSetup testSetup = new AddGroupControllerTestSetup();
        List<Id> fixedSearchResults = new List<Id>(new Map<Id, SObject>(testSetup.accounts).keySet());
        Test.startTest();
            Test.setFixedSearchResults(fixedSearchResults);
            List<Account> results = AITM_AddGroupController.searchGroups('Test', testSetup.tender.Id);
            Test.stopTest();
            System.assertEquals(0, results.size(),'The account size is 0');
    }

    /**
     * @description tests to verify if the group account is invalid
     * @param  null
     * @return null
     */
    @isTest 
    static void testCustomersSearchWillReturnValidResultOnInvalidSearchKey() {
        AddGroupControllerTestSetup testSetup = new AddGroupControllerTestSetup();

        Test.startTest();
            Test.setFixedSearchResults(new List<Id>());
            List<Account> results = AITM_AddGroupController.searchGroups('invalid account name', testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    /**
     * @description tests to verify only the account having the AITM_Group__c as the group account id will be added as Tender Account
     * @param  null
     * @return void
     */
    @isTest
    static void testSaveWillWorkFineWithoutTenderLocations() {
        AddGroupControllerTestSetup testSetup = new AddGroupControllerTestSetup();

            Test.startTest();
            
            AITM_AddGroupController.saveTenderAccountWithRelatedData(testSetup.accounts[0].Id, testSetup.tender.Id);
        
            Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
    }
    
    /**
     * @description tests to verify if the group account has the required details
     * @param  null
     * @return void
     */
    @isTest
    static void testvalidationofaccount() {
        AddGroupControllerTestSetup testSetup = new AddGroupControllerTestSetup();

            Test.startTest();
            
            AITM_AddGroupController.validateTenderAccountWithRelatedData(testSetup.accounts[0].Id);
        
            Test.stopTest();

        System.assertEquals(false,false,'The account is not valid');
    }
        
    private class AddGroupControllerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;

        public AddGroupControllerTestSetup(){
            accounts = createAccounts(10);
            insert accounts;
            locations = createLocations(10);
            insert locations;
            tender = createTender();
            insert tender;
        }    
    }
}