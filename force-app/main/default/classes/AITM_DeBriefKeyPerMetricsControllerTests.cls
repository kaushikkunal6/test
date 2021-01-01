/***************************************************************
 * @author          George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_DeBriefKeyPerMetricsControllerTests

 * history
 * 01/December/2017  George       Created
 * 09/March/2018     srnandan     Modified - added header and method comments
 **********************************************************/
@isTest 
private class AITM_DeBriefKeyPerMetricsControllerTests {

	private static final String STAGE_DEBRIEF = 'Debrief';
	private static final String STAGE_FEEDBACK = 'feedback and negotiation';

	/**
     * @description tests to verify tender debrief tendervolume new contract
     * @param  null
     * @return void
     */
	@isTest  
	static void testTenderVolumeNewContractCalculation() {
		DeBriefKeyPerMetricsControllerTestSetup testSetup = new DeBriefKeyPerMetricsControllerTestSetup().generateData();

		Test.startTest();
        testSetup.progressToDeBrief();
		AITM_Tender__c tender = new AITM_TenderDao().getTender(testSetup.tender.Id);
		AITM_Tender__c tenderDebrief = AITM_DeBriefKeyPerMetricsController.getTender(tender);
		Test.stopTest();

        if (testSetup.debriefLocationAvailable()) {
		    System.assertEquals(0, tenderDebrief.AITM_Volume_New_Contract__c);
        }
	}

	/**
     * @description class to hold test data set up extending AITM_TestSetup class
     */
	private class DeBriefKeyPerMetricsControllerTestSetup extends AITM_TestSetup {
		private AITM_DeBriefKeyPerMetricsController classUnderTest;
		private List<Account> accounts;
		private List<AITM_Location__c> locations;
		private AITM_Tender__c tender;
		private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
		private List<AITM_Tender_Location__c> tenderLocations;
		private List<User> locationManagers;
		private final Integer ITEMS_COUNT = 10;
        private Decimal volumeNewContract ;
        private Decimal grossProfitNewContract ;
        private Decimal workingCaptialNewContract;
        private Decimal ppiAndVolumeMultiplicationSumNewContract;
		private	Decimal volumePrevContract;
		private	Decimal grossProfitPrevContract;
		private	Decimal workingCaptialPrevContract;
		private	Decimal ppiAndVolumeMultiplicationSumPrevContract;
        private final ID TLLI_ID_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();

		/**
     	 * @description generates test data i.e. accounts, tenderlocations, tender, tenderaccounts,location managers
     	 * @param  null
     	 * @return DeBriefKeyPerMetricsControllerTestSetup class
    	 */
		private DeBriefKeyPerMetricsControllerTestSetup generateData(){
			classUnderTest = new AITM_DeBriefKeyPerMetricsController();
			accounts = createAccounts(ITEMS_COUNT);
			insert accounts;
			locations = createLocations(ITEMS_COUNT);
			for(AITM_Location__c location : locations){
				location.AITM_Country__c = 'Spain';
			}
			insert locations;
			tender = createTender();
			tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
			tender.AITM_Density__c = '331';
			tender.AITM_Stage__c = 'Debrief';
            tender.AITM_Volume_New_Contract__c = 0;
            tender.AITM_Gross_Profit_New_Contract__c = 0;
            tender.AITM_ROWC_New_Contract__c = 0;
            tender.AITM_Price_Perf_Index_New_Contract__c = 0;
            tender.AITM_Gross_Profit_Previous_Contract__c = 1;                    
			insert tender;
			createTenderAccounts();
			locationManagers = createUsers(ITEMS_COUNT, 'Air_TMLocation Manager');
			insert locationManagers;
			tenderLocations = createTenderLocations();
			insert tenderLocations;
			tenderLocationLineItems = new List<AITM_Tender_Location_Line_Item__c>();
			for(Integer i = 0; i < this.ITEMS_COUNT; i++){
				AITM_Tender_Location_Line_Item__c lineItem = this.createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id, tenderLocations[0].Id);
				tenderLocationLineItems.add(lineItem);
			}
			insert tenderLocationLineItems;
			attachLocationManagersToTenderLocations(locationManagers, tenderLocations);
			return this;
		}

		/**
     	 * @description returns list collection of AITM_Tender_Location__c
     	 * @param  null
     	 * @return List collection of AITM_Tender_Location__c
    	 */
		private List<AITM_Tender_Location__c> createTenderLocations() {
			List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
			for(AITM_Location__c location : locations){
				tenderLocations.add(
					createTenderLocation(tender.Id, location.Id)
					);
			}
			return tenderLocations;
		}

		/**
     	 * @description assigns location manager to each tenderlocation
     	 * @param  locationManagers collection of type user
     	 * @param  tenderLocations collection of type AITM_Tender_Location__c
     	 * @return void
    	 */
		private void attachLocationManagersToTenderLocations(List<User> locationManagers, List<AITM_Tender_Location__c> tenderLocations) {
			List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
			Integer index = 0;

			for(AITM_Tender_Location__c tenderLocation : tenderLocations){
				User locationManager = locationManagers[index];
				tenderLocation.AITM_Location_Manager__c = locationManager.Id;
				result.add(tenderLocation);
				index++;
			}
			upsert result;
		}

		/**
     	 * @description creates tender accounts
     	 * @param  null
     	 * @return void
    	 */
		private void createTenderAccounts() {
			insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
		}

		/**
     	 * @description creates tenderlocationlineitems
     	 * @param  null
     	 * @return void
    	 */
		private void createTenderLocationLineItems() {
			tenderLocationLineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
		}

		/**
     	 * @description create tenderlocationline item 
     	 * @param  tenderId of type Id
     	 * @param  accountId of type Id
     	 * @param  locationId of type Id
     	 * @param  tenderLocationId of type Id
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
				AITM_Requested_Volume_USG__c = 1,
                AITM_Offered_Volume__c = 1,
                AITM_Working_Capital__c =1,
                AITM_Gross_Profit__c = 1,
                AITM_PPI__c = 1,
				AITM_Tender_Result__c = 'BG'
				);
		}

		/**
     	 * @description returns true if debrief record type is available for tenderlocationlineitem
     	 * @param  null
     	 * @return boolean
    	 */
        private Boolean debriefLocationAvailable() {
            return [SELECT COUNT() From AITM_Tender_Location_Line_Item__c WHERE RecordType.DeveloperName = :AITM_LocationsDao.TLLI_RECORD_TYPE_DEBRIEF] > 0;
        }
        
        /**
         * @description to progress to debrief tab
         * @param  null
         * @return null
         */
        private void progressToDeBrief() {
            for (AITM_Tender_Location_Line_Item__c lineItem  : tenderLocationLineItems) {
                lineItem.RecordTypeId = TLLI_ID_RECORD_TYPE_DEBRIEF;   
            }
            update tenderLocationLineItems;
        }
	}
}