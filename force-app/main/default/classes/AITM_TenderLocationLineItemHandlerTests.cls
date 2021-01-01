/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_TenderLocationLineItemHandler

 * history
 * 01/December/2017  George      Created 
 * 23/April/2018     srnandan    added comments at method and class level as per coding standards
 * 3/Jan/2020        Saravan     added new method testTenderCustomerJVTermsUpdate
 * 3/Jan/2020        Kunal       added new method testUpdateTenderLocationLineItemRequestedVolumeToLT                  
 ************************************************************************************************/

@isTest 
private inherited sharing class AITM_TenderLocationLineItemHandlerTests {

	/**
     * @description test to insert tender location line item
     * @param  null
     * @return null	 
     */  
	 
    @isTest 
    static void testInsertionOfTenderLocationsWillCreateRecordsIfThereAreNoRecordsForTenderAccountCombination() {
        TenderLocationLineItemHandlerTestSetup testSetup = new TenderLocationLineItemHandlerTestSetup().generateData();
        testSetup.createTenderLocationLineItems();

        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        Test.startTest();
            insert testSetup.tenderLocations;
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size(), [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(tenderLocationVolume*testSetup.tenderLocations.size(), totalVolume);
    }
	
	/**
     * @description test to update tender location line item
     * @param  null
     * @return null
     */ 

    @isTest 
    static void testInsertionTenderLocationsWillNotUpdateRecordsIfTheyAreAlreadyCreated() {
        TenderLocationLineItemHandlerTestSetup testSetup = new TenderLocationLineItemHandlerTestSetup().generateData();
        
        testSetup.createTenderLocationLineItems();
        insert testSetup.tenderLocations;

        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
            tenderLocation.Id = null;
            tenderLocation.AITM_Volume__c = 5;
        }

        Test.startTest();
            insert testSetup.tenderLocations;
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size()*2, [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals((1+5)*testSetup.tenderLocations.size(), totalVolume);
    }
	
	/**
     * @description to test adhoc location line item
     * @param  null
     * @return null
     */  

    @isTest 
    static void testInsertLocationsWillNotUpdateRecordsToBeZeroIfTheyAreAdHoc() {
        TenderLocationLineItemHandlerTestSetup testSetup = new TenderLocationLineItemHandlerTestSetup().generateData();
        
        testSetup.createTenderLocationLineItems();
        insert testSetup.tenderLocations;

        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
            tenderLocation.Id = null;
            tenderLocation.AITM_Volume__c = null;
            tenderLocation.AITM_Ad_hoc_Volume__c = true;
        }

        Test.startTest();
            insert testSetup.tenderLocations;
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size()*2, [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c == null? 0 : tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals((1+0)*testSetup.tenderLocations.size(), totalVolume);
    }
	
	/**
     * @description test to update Requested Volume from USG to LT
     * @param  null
     * @return null
     */ 
	
	@isTest 
    static void testUpdateTenderLocationLineItemRequestedVolumeToLT() {
        TenderLocationLineItemHandlerTestSetup testSetup = new TenderLocationLineItemHandlerTestSetup().generateData();
        
        testSetup.createTenderLocationLineItems();
        AITM_Pricing_Basis__c pricingBasis = testSetup.pricingBasis;
        pricingBasis.AITM_Not_Represented__c = false;
        insert pricingBasis;
        
        AITM_Tender_Location_Line_Item__c tenderLocation = testSetup.tenderLocations[0];
        tenderLocation.AITM_Requested_Volume_UoM__c = 'USG';
        tenderLocation.AITM_Pricing_Basis__c = pricingBasis.id;
        tenderLocation.AITM_Pricing_Basis__r = pricingBasis;
        tenderLocation.AITM_Volume__c = 55.0;
        insert tenderLocation;
        
        AITM_Tender_Location_Line_Item__c tenderLocation1 = [SELECT Id, AITM_Requested_Volume_UoM__c, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Volume__c = 55.0];
        tenderLocation1.AITM_Requested_Volume_UoM__c = 'LT';

        Test.startTest();
            update tenderLocation1;
        Test.stopTest();

        System.assertEquals('LT', tenderLocation1.AITM_Requested_Volume_UoM__c);
    }
	
	 /**
     * @description checks if the JVTermsUpdated in Tender Accout Or Not
     * @param  null
     * @return null
     */
	
	@isTest 
    static void testTenderCustomerJVTermsUpdate() {
        TenderLocationLineItemHandlerTestSetup testSetup = new TenderLocationLineItemHandlerTestSetup().generateData();
        testSetup.createPolishTenderLocationLineItems();
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
       
        Test.startTest();
        	insert singleTenderAccount;
            insert testSetup.tenderLocations;
        Test.stopTest();
        
        AITM_Tender_Account__c actSingleTenderAccount = [SELECT id, JV_terms__c FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tender.Id];
        System.assertNotEquals(Null, actSingleTenderAccount.JV_terms__c);
        
    }

    private inherited sharing class TenderLocationLineItemHandlerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
		public List<AITM_Location__c> polishLocations;
        public AITM_Tender__c tender;
		private AITM_Pricing_Basis__c pricingBasis;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;

        public TenderLocationLineItemHandlerTestSetup generateData(){
            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;
			
			polishLocations = createLocations(10);
            for (AITM_Location__c loc :polishLocations)
            {
                loc.AITM_Locations_Filter__c = 'Polish';                
            }
            insert polishLocations;

            tender = createTender();
            insert tender;
			
			pricingBasis = createPricingBasis();

            return this;
        }
		
		/**
         * @description creates the test data for Non Polish Tender Location Line Item 
         * @param  null
         * @return AITM_Tender_Location_Line_Item__c
         */

        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }
		
		/**
         * @description creates the test data for Tender Accout 
         * @param  null
         * @return AITM_Tender_Account__c
         */

		public AITM_Tender_Account__c createSingleTenderAccounts() {
            return new AITM_Tender_Account__c(AITM_Account__c = accounts[0].Id, AITM_Tender__c = tender.Id);
        }
		
		/**
         * @description creates the test data for Polish Tender Location Line Item 
         * @param  null
         * @return AITM_Tender_Location_Line_Item__c
         */

        public void createPolishTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{polishLocations[0]});
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
    }

}