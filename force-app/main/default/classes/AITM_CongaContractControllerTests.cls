/**************************************************************************
 * @author           srnandan
 * @date             05/June/2019
 * @group            AirBP
 * @description      Test class for AITM_TenderCongaContractContainerController

 * history
 * 05/June/2019      	 srnandan       Created
 *******************************************************************/
@isTest  
private inherited sharing class AITM_CongaContractControllerTests {

    /**
     * @description tests to filter options for customers
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterCustomerOptionsTest() {
        TenderCongaContractContainerControllerTestSetup testSetup = new TenderCongaContractContainerControllerTestSetup().generateData();

        Test.startTest();
            List<AITM_CongaContractContainerController.AccountOption> accountOptions = AITM_CongaContractContainerController.getFilterOptions(testSetup.tender.id);
        Test.stopTest();

        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1], 'Tender id passed is valid');
        System.assertNotEquals(null, accountOptions, 'Account Options is not null');
    }
    
    /**
     * @description tests to attachOfferDocuments
     * @param  null
     * @return void
     */
    @isTest  
    static void attachOfferDocumentsForTaxFeeTest() {
        TenderCongaContractContainerControllerTestSetup testSetup = new TenderCongaContractContainerControllerTestSetup().generateData();

        Test.startTest();
            String url = AITM_CongaContractContainerController.attachOfferDocuments(testSetup.tender.id, '', 
                          'test', 'Air India', 'Air India', '', false, 'testContract', true, '8080808',false);
        Test.stopTest();

        System.assertNotEquals(null, url, 'String Url should not be null');
    }
    
    /**
     * @description tests to attachOfferDocuments
     * @param  null
     * @return void
     */
    @isTest  
    static void attachOfferDocumentsForNewTaxFeeTest() {
        TenderCongaContractContainerControllerTestSetup testSetup = new TenderCongaContractContainerControllerTestSetup().generateData();

        Test.startTest();
            String url = AITM_CongaContractContainerController.attachOfferDocuments(testSetup.tender.id, '', 
                          'test', 'Air India', 'Air India', '', false, 'testContract', false, '8080808',false);
        Test.stopTest();

        System.assertNotEquals(null, url, 'String Url should not be null');
    }
    
	/**
     * @description tests to filter options for customers
     * @param  null
     * @return void
     */
    @isTest  
    static void getFilterCustomerBSpokeOptionsTest() {
        TenderCongaContractContainerControllerTestSetup testSetup = new TenderCongaContractContainerControllerTestSetup().generateData();

        Test.startTest();
        	Account acc = testSetup.account;
        	acc.AITM_Bespoke_Template__c = 'AITM_Contract2015PDF';
            update acc;
            List<AITM_CongaContractContainerController.AccountOption> accountOptions = AITM_CongaContractContainerController.getFilterOptions(testSetup.tender.id);
        Test.stopTest();

        System.assertNotEquals(null, [SELECT Id FROM AITM_Tender__c LIMIT 1], 'Tender id passed is valid');
        System.assertNotEquals(null, accountOptions, 'Account Options is not null');
    }    
    /**
     * @description test data TenderOfferContainerController inner class
     */    
    private inherited sharing class TenderCongaContractContainerControllerTestSetup extends AITM_TestSetup {
        //declaration of variable tender sobject
        AITM_Tender__c tender = createTender();
        Account account = createAccount();
        AITM_Tender_Account__c tenderAccount;
		/**
         * @description generates the test data for a tender
         * @param  null
         * @return TenderCongaOfferContainerControllerTestSetup
         */
        public TenderCongaContractContainerControllerTestSetup generateData() {
            insert tender;
			insert account;
            tenderAccount = createTenderAccount(tender.Id, account.Id);
            insert tenderAccount;
            return this;
        }

        /**
         * @description generates the test data for Location Manager, users for the test class
         * @param  null
         * @return User
         */
        public User createLocationManager() {
            User locationManager = createUsers(1, 'Air_TMLocation Manager')[0];
            locationManager.FirstName = 'Location';
            locationManager.LastName = 'Manager';
            insert locationManager;
            locationManager = [SELECT Id, Name FROM User WHERE Id = :locationManager.Id LIMIT 1][0];
            return locationManager;
        }
    }
}