/***************************************************************
 * @author           srnandan
 * @date             02/April/2018
 * @group            AirBP
 * @description      Test class for AITM_RelatedTenderLocationsSummaryCtrl

 * history
 * 02/April/2018     srnandan     created
 **********************************************************/
@isTest
private class AITM_RelatedTenderLocSummaryCtrlTests {

    /**
     * @description tests to get location summary by country all locations with same status
     * @param  null
     * @return void
     */
    @isTest  
	static void testGetLocationSummaryDetails() {
        AITM_RelatedTenderLocationsSummaryCtrTestSetup testSetup = new AITM_RelatedTenderLocationsSummaryCtrTestSetup().generateData();    
        testSetup.createTenderLocationLineItems();
        INSERT testSetup.tenderLocationLineItems;
        Decimal tenderLocationVolume = testSetup.tenderLocationLineItems[0].AITM_Volume__c;
        Test.startTest();
        	List<AITM_RelatedTenderLocationsSummaryCtrl.TenderLocationSummaryAdapter> result = AITM_RelatedTenderLocationsSummaryCtrl.getLocationSummaryDetails(testSetup.tender.Id, null, 1);
        Test.stopTest();
        System.assertEquals(testSetup.tenderLocationLineItems.size(), [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id],'The location line items size is equal to test data');
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assert(tenderLocationVolume*testSetup.tenderLocationLineItems.size() == totalVolume, 'The totalvolume is equal to tenderlocationitems size');
    }

    /**
     * @description tests to get location summary by country all locations with same status
     * @param  null
     * @return void
     */
    @isTest  
	static void testGetRelatedLocationDetails() {
        AITM_RelatedTenderLocationsSummaryCtrTestSetup testSetup = new AITM_RelatedTenderLocationsSummaryCtrTestSetup().generateData();    
        testSetup.createTenderLocationLineItems();
        INSERT testSetup.tenderLocationLineItems;
        
        Test.startTest();
        	List<AITM_RelatedTenderLocationsController.TenderLocationAdapter> result = AITM_RelatedTenderLocationsController.getLocationDetails(testSetup.tender.Id, null);
        Test.stopTest();
        System.assertEquals(testSetup.tenderLocationLineItems.size(), [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id],'The location line items size is equal to test data');
    }
    
    /**
     * @description tests to get location summary by country with different location status 
     * @param  null
     * @return void
     */
    @isTest  
    static void testLocationSummaryWithDiffLineItemStatus() {
        AITM_RelatedTenderLocationsSummaryCtrTestSetup testSetup = new AITM_RelatedTenderLocationsSummaryCtrTestSetup().generateData();    
		
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;

        Account account = testSetup.createAccount();
        INSERT account;
        List<AITM_Location__c> locations = new List<AITM_Location__c>();
        AITM_Location__c location = testSetup.createLocation();
        location.AITM_Country__c = 'USA';
        locations.add(location);
        location = new AITM_Location__c(
            Name = 'Test Location1',
            AITM_ICAO__c = 'BY',
            AITM_IATA__c = 'YU',
            AITM_Currency__c = 'USD',
            AITM_Unit_Of_Measure__c = 'LT',
            AITM_Delivery_Point__c = '1',
            AITM_Country__c = 'USA'
        );
        locations.add(location);
        INSERT locations;
        List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
        Id locationId = locations[0].Id;
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = locationId,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = testSetup.STATUS_PRICED,
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        tenderLocations.add(tenderLocation);
        Id locationOneId = locations[1].Id;
        tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = locationOneId,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = testSetup.STATUS_AWAITING_PRICE,
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        tenderLocations.add(tenderLocation);
        INSERT tenderLocations;

        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();

        for(Integer i = 0; i < lineItemsCount; i++){
            if(i == 1 || i == 2) {
                items.add( 
                    testSetup.createTenderLocationLineItem(tenderId, account.Id, locationId, tenderLocations[0].Id)
                );
            }else {
                items.add( 
                    testSetup.createTenderLocationLineItem(tenderId, account.Id, locationOneId, tenderLocations[1].Id)
                );
            }
        }
        INSERT items;

        Test.startTest();
        	List<AITM_RelatedTenderLocationsSummaryCtrl.TenderLocationSummaryAdapter> result = AITM_RelatedTenderLocationsSummaryCtrl.getLocationSummaryDetails(testSetup.tender.Id, null, 1);
        Test.stopTest();

        System.assert(items.size() == [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id], 'The line item is equal to items size');
        System.assert(result[0].status.equals(testSetup.STATUS_AWAITING_PRICE), 'The status is equal to Awaiting price');
        System.assert(items.size() == 5,'The items size is equal to 5');
        System.assert(result.size() == 1, 'The items size is equal to 1');
    }

    /**
     * @description tests to get location summary by country with different location status same status priced 
     * @param  null
     * @return void
     */
    @isTest  
    static void testLocationSummaryWithDiffLocationsWithPricedStatus() {
        AITM_RelatedTenderLocationsSummaryCtrTestSetup testSetup = new AITM_RelatedTenderLocationsSummaryCtrTestSetup().generateData();    
        
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;

        Account account = testSetup.createAccount();
        INSERT account;
        List<AITM_Location__c> locations = new List<AITM_Location__c>();
        AITM_Location__c location = testSetup.createLocation();
        location.AITM_Country__c = 'USA';
        locations.add(location);
        location = new AITM_Location__c(
            Name = 'Test Location1',
            AITM_ICAO__c = 'BY',
            AITM_IATA__c = 'YU',
            AITM_Currency__c = 'USD',
            AITM_Unit_Of_Measure__c = 'LT',
            AITM_Delivery_Point__c = '1',
            AITM_Country__c = 'USA'
        );
        locations.add(location);
        INSERT locations;
        List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
        Id locationId = locations[0].Id;
        
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = locationId,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = testSetup.STATUS_PRICED,
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        tenderLocations.add(tenderLocation);
        Id locationOneId = locations[1].Id;
        tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = locationOneId,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = testSetup.STATUS_PRICED,
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        tenderLocations.add(tenderLocation);
        INSERT tenderLocations;

        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();

        for(Integer i = 0; i < lineItemsCount; i++){
            if(i == 1 || i == 2) {
                items.add( 
                    testSetup.createTenderLocationLineItem(tenderId, account.Id, locationId, tenderLocations[0].Id)
                );
            }else {
                items.add( 
                    testSetup.createTenderLocationLineItem(tenderId, account.Id, locationOneId, tenderLocations[1].Id)
                );
            }
        }
        INSERT items;

        Test.startTest();
            List<AITM_RelatedTenderLocationsSummaryCtrl.TenderLocationSummaryAdapter> result = AITM_RelatedTenderLocationsSummaryCtrl.getLocationSummaryDetails(testSetup.tender.Id, null, 1);
        Test.stopTest();

        System.assert(items.size() == [SELECT COUNT() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id],'The items size is equal to countr of tender');
        System.assert(result[0].status.equals(testSetup.STATUS_PRICED), 'The status is equal to Priced');
        System.assert(items.size() == 5, 'The items size is equal to 5');
        System.assert(result.size() == 1, 'The result size is equal to 1');
    }

    /**
     * @description test data holder RelatedTenderLocationSummary controller inner class
     */
	private class AITM_RelatedTenderLocationsSummaryCtrTestSetup extends AITM_TestSetup{
		private List<Account> accounts;
        private List<AITM_Location__c> locations;
        private AITM_Tender__c tender;
        private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        private List<AITM_Tender_Location__c> tenderLocations;
        private final String STATUS_AWAITING_PRICE = 'Awaiting price';
        private final String STATUS_PRICED = 'Priced';

        /**
         * @description generates the test data for account, Location, Tender, TenderLocation, 
         * TenderLocationLineItem for the test class
         * @param  null
         * @return AITM_RelatedTenderLocationsSummaryCtrTestSetup
         */
        private AITM_RelatedTenderLocationsSummaryCtrTestSetup generateData() {
        	accounts = createAccounts(10);
            INSERT accounts;

            locations = createLocations(10);
            for(Integer i = 0; i < locations.size(); i++) {
            	locations[i].AITM_Country__c = 'USA';
            }

            INSERT locations;

            tender = createTender();
            INSERT tender;
            
            return this;
        }

        /**
         * @description returns account test data
         * @param  null
         * @return Account sobject
         */
        private Account getAccount() {
            return createAccount();
        }

        /**
         * @description creates test data for TenderAccounts 
         * @param  null
         * @return void
         */
        private void createTenderAccounts() {
            INSERT createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        /**
         * @description creates test data list of TenderLocationLineItems 
         * @param  null
         * @return void
         */
        private void createTenderLocationLineItems() {
            tenderLocationLineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }

        /**
         * @description creates test data for Tender locations 
         * @param  null
         * @return void
         */
        private void createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
                for(AITM_Location__c location : locations){
                tenderLocations.add(
                    createTenderLocation(tender.Id, location.Id)
                );
            }
            INSERT tenderLocations;
        }

        /**
         * @description creates test data for TenderLocationLineItem 
         * @param tenderId of type Id
         * @param accountId of type Id
         * @param locationId of type Id
         * @param tenderLocationId of type Id
         * @return AITM_Tender_Location_Line_Item__c
         */
        private AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0,
                AITM_Status__c = STATUS_PRICED
            );
        }
    }
}