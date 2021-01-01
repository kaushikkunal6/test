/**************************************************************************
 * @author           srnandan
 * @date             11/October/2018
 * @group            AirBP
 * @description      Test class for AITM_RelatedTenderFileListController
 * history
 * 11/October/2018   srnandan      Created
*******************************************************************/
@isTest
private class AITM_RelatedTenderFileListCtrlTests {
	/**
     * @description tests to verify GeneratedValidEmailDTO for specific tender id
     * @param null
     * @return null
     */
    @isTest  
    private static void checkIfValidTenderIdIsPassedToGetContentDocs() {
        AITM_RelatedTenderFileListControllerTestSetup setup = new AITM_RelatedTenderFileListControllerTestSetup().generateData();
        
        Test.startTest();
            List<ContentDocument> contentDocumentList = AITM_RelatedTenderFileListController.getContentDocs(setup.tender.Id);
        Test.stopTest();

        System.assertEquals(1, contentDocumentList.size(), 'The document list size is 1');
    }
    
    /**
     * @description test data TenderInvitationEmailGenPolishCntlrTestSetup controller inner class
     */
    private class AITM_RelatedTenderFileListControllerTestSetup extends AITM_TestSetup {
        public final Integer ITEMS_SIZE = 10;
        public List<Account> accounts;
        public List<AITM_Tender_Account__c> tenderAccounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        public List<ContentVersion> contentVersionList;
        public List<ContentDocumentLink> contentDocumentLinkTest;
        /**
         * @description generates the test data for account, Location, Tender, Pricingbasis, 
         * LocationManager users for the test class
         * @param  null
         * @return TenderInvitationEmailGenCntlrTestSetup
         */
        public AITM_RelatedTenderFileListControllerTestSetup generateData() {
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
            
			ContentVersion cv = new ContentVersion(
				Title = 'LABP DEBRIEF',
				PathOnClient = 'LABP DEBRIEF.html',
				VersionData = Blob.valueOf('test video content'),
				IsMajorVersion = true
			);
            contentVersionList = new List<ContentVersion>();
			contentVersionList.add(cv);
			insert contentVersionList;
            
            ContentDocument doc = [
                SELECT Id, Title, LatestPublishedVersionId 
                FROM ContentDocument
                LIMIT 1
            ];
    
            ContentDocumentLink cdl = New ContentDocumentLink(
                LinkedEntityId = tender.id,
                ContentDocumentId = doc.Id,
                shareType = 'V'
            );
			contentDocumentLinkTest = new List<ContentDocumentLink>();
            contentDocumentLinkTest.add(cdl);
            insert contentDocumentLinkTest;
            
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