@isTest 
private inherited sharing class AITM_TenderInvitationEmailGenCntlrTests {
    @isTest 
    private static void checkIfValidTenderIdIsPassedToGeneratorValidEmailDTOIsGenerated() {
        TenderInvitationEmailGenCntlrTestSetup setup = new TenderInvitationEmailGenCntlrTestSetup().generateData();
		AITM_Tender__c tender = new AITM_Tender__c();
		tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
		tender.AITM_Density__c = '331';
		tender.AITM_Stage__c = 'Awaiting Price';
        tender.AITM_Unit_Of_Measure__c = 'LT';
        tender.AITM_Start_Date__c = Date.today();
        tender.AITM_End_Date__c = Date.today().addYears(1);
        tender.AITM_Tender_Sector__c = 'GA';
		insert tender;
        Test.startTest();
		    AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = AITM_TenderInvitationEmailGenCntlr.generate(tender.Id, AITM_TenderDao.NONPOLISH);
		Test.stopTest();

		System.assertEquals(1, generatedEmailDTO.emailAddresses.size(),'The email address size is 1');
        System.assert(String.isNotBlank(generatedEmailDTO.subject),'the subject is not blank');
    }
    @isTest 
    private static void checkIfValidTenderIdIsPassedToGeneratorValidChatterMessageGenerated() {
        TenderInvitationEmailGenCntlrTestSetup setup = new TenderInvitationEmailGenCntlrTestSetup().generateData();
        
        Test.startTest();
            List<String> chatterMessages = AITM_TenderInvitationEmailGenCntlr.postToChatter(setup.tender.Id, AITM_TenderDao.NONPOLISH);
        Test.stopTest();

        System.assertEquals(0, chatterMessages.size(),'The chatter size is 0');
    }

    private inherited sharing class TenderInvitationEmailGenCntlrTestSetup extends AITM_TestSetup {
        public final Integer ITEMS_SIZE = 10;
        public List<Account> accounts;
        public List<AITM_Tender_Account__c> tenderAccounts;
		public List<AITM_Location__c> locations;
		public AITM_Tender__c tender;
		public List<AITM_Tender_Location_Line_Item__c> tenderLocations;

        public TenderInvitationEmailGenCntlrTestSetup generateData() {
            accounts = createAccounts(ITEMS_SIZE);
			insert accounts;

			locations = createLocations(ITEMS_SIZE);
			for(AITM_Location__c location : locations){
				location.AITM_Country__c = 'Spain';
			}
			insert locations;

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
                //lineItems.AITM_Delivery_Point__c = '1';
                lineItems.AITM_Currency__c = 'USD';
                lineItems.AITM_Unit_Of_Measure__c = 'LT'; 
                lineItems.AITM_Offered_Differential__c = 1.0;
                lineItems.AITM_Offered_Volume__c = 1.0;
                lineItems.AITM_Volume__c = 1.0;
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