/**************************************************************************
 * @author           srnandan
 * @date             08/September/2018
 * @group            AirBP
 * @description      Test class for AITM_TenderInvitationEmailGenPolishCntlr
 * history
 * 08/September/2018 srnandan      Created
*******************************************************************/
@isTest
private inherited sharing class AITM_TenderInvitationEmailGenPolishTests {
    /**
     * @description tests to verify GeneratedValidEmailDTO for specific tender id
     * @param null
     * @return null
     */
    @isTest  
    private static void checkIfValidTenderIdIsPassedToGeneratorValidEmailDTOIsGenerated() {
        TenderInvitationEmailGenPolishCntlrTestSetup setup = new TenderInvitationEmailGenPolishCntlrTestSetup().generateData();
        
        Test.startTest();
            AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = AITM_TenderInvitationEmailGenPolishCntlr.generate(setup.tender.Id, AITM_TenderDao.POLISH);
        Test.stopTest();

        System.assertEquals(1, generatedEmailDTO.emailAddresses.size(), 'The email addresses size is 1');
    }
    
    /**
     * @description tests to verify ChatterMessage posted for a tender
     * @param null
     * @return null
     */
    @isTest  
    private static void checkIfValidTenderIdIsPassedToGeneratorValidChatterMessageGenerated() {
        TenderInvitationEmailGenPolishCntlrTestSetup setup = new TenderInvitationEmailGenPolishCntlrTestSetup().generateData();
        
        Test.startTest();
            List<String> chatterMessages = AITM_TenderInvitationEmailGenPolishCntlr.postToChatter(setup.tender.Id, AITM_TenderDao.POLISH);
        Test.stopTest();

        System.assertEquals(0, chatterMessages.size(), 'The chatter message size is 0');
    }
    
    /**
     * @description test data TenderInvitationEmailGenPolishCntlrTestSetup controller inner class
     */
    private inherited sharing class TenderInvitationEmailGenPolishCntlrTestSetup extends AITM_TestSetup {
        public final Integer ITEMS_SIZE = 10;
        public List<Account> accounts;
        public List<AITM_Tender_Account__c> tenderAccounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        
        /**
         * @description generates the test data for account, Location, Tender, Pricingbasis, 
         * LocationManager users for the test class
         * @param  null
         * @return TenderInvitationEmailGenCntlrTestSetup
         */
        public TenderInvitationEmailGenPolishCntlrTestSetup generateData() {
            accounts = createAccounts(ITEMS_SIZE);
            insert accounts;

            locations = createLocations(ITEMS_SIZE);
            for(AITM_Location__c location : locations){
                location.AITM_Country__c = 'Spain';
            }
            insert locations;
			locations[0].AITM_Country__c = 'Poland';
            update locations;
            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            tender.AITM_Stage__c = 'Awaiting Price';
            tender.AITM_Unit_Of_Measure__c = 'LT'; 
            insert tender;

            tenderAccounts = createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
            insert tenderAccounts;

            AITM_Pricing_Basis__c pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test');
            insert pricingBasis;

            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
            for (AITM_Tender_Location_Line_Item__c lineItems : tenderLocations) {
                lineItems.AITM_Pricing_Basis__c = pricingBasis.Id;
                lineItems.AITM_Currency__c = 'USD';
                lineItems.AITM_Unit_Of_Measure__c = 'LT'; 
                lineItems.AITM_Offered_Differential__c = 1.0;
            }
            insert tenderLocations;

            return this;
        }

        private Contact createContact(Id accountId, Id locationId, String lastName, String emailValue) {
            return new Contact(
                AccountId = accountId,
                AITM_Location__c = locationId,
                LastName = lastName,
                Email = emailValue
            );
        }
    }
}