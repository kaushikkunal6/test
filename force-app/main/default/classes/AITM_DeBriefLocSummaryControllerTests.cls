/***********************************************************************************************
 * @author           Simon Alexander
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_DeBriefLocSummaryController                          
 ************************************************************************************************/
@IsTest 
private with sharing class AITM_DeBriefLocSummaryControllerTests {

	public static final String STAGE_DEBRIEF = 'Debrief';
	@isTest 
	static void testLocationSummaryVolumeCalculations() {
        DeBriefLocSummaryControllerTestSetup testSetup = new DeBriefLocSummaryControllerTestSetup().generateData();
		Test.startTest();
        	AITM_Tender__c tender = testSetup.tender;
        	Account account = testSetup.createAccount();
        	insert account;

        	AITM_Location__c location = testSetup.createLocation();
			insert location;

        	List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;
        	delete tenderLocations;

        	AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tender.Id, location.Id);
        	tenderLocation.AITM_Comments__c = 'Tender Location Round 1';
        	tenderLocation.AITM_Has_Feedback__c = true;
        	insert tenderLocation;
			List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
			for(Integer i = 0; i <= testSetup.ITEMS_COUNT; i++){
				AITM_Tender_Location_Line_Item__c lineItem = testSetup.createTenderLocationLineItem(tender.Id, account.Id, location.Id, tenderLocation.Id);
                lineItem.RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
				lineItem.AITM_Tender_Result__c = testSetup.getTenderResult(i);
				items.add(lineItem);
			}			
			insert items;
			tender.AITM_Stage__c = STAGE_DEBRIEF;
			update tender;
		    Map<String, String> locSummaryValues = AITM_DeBriefLocSummaryController.getTenderSummaryValues(new AITM_TenderDao().getTender(testSetup.tender.Id));
        	Boolean flagDebrief = testSetup.debriefLocationAvailable();
		Test.stopTest();

        if (flagDebrief) {
		    System.assertEquals(3, Integer.valueOf(locSummaryValues.get('gainedVolume')));
		    System.assertEquals(3, Integer.valueOf(locSummaryValues.get('retainedVolume')));
		    System.assertEquals(3, Integer.valueOf(locSummaryValues.get('lostVolume')));
		    System.assertEquals(7, Integer.valueOf(locSummaryValues.get('marketInformationVolume')));
        }
	}


	private with sharing class DeBriefLocSummaryControllerTestSetup extends AITM_TestSetup {

		public AITM_DeBriefLocSummaryController classUnderTest;
		public List<Account> accounts;
		public List<AITM_Location__c> locations;
		public AITM_Tender__c tender;
		public List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
		public List<AITM_Tender_Location__c> tenderLocations;
		public List<User> locationManagers;
		public AITM_Pricing_Basis__c pricingBasis;
		public final Integer ITEMS_COUNT = 15;

		public DeBriefLocSummaryControllerTestSetup generateData(){
			classUnderTest = new AITM_DeBriefLocSummaryController();
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
			tender.AITM_Stage__c = 'Awaiting Price';
			insert tender;

			createTenderAccounts();

			locationManagers = createUsers(ITEMS_COUNT, 'Air_TMLocation Manager');
			insert locationManagers;

			tenderLocations = createTenderLocations();
			insert tenderLocations;

			pricingBasis = createPricingBasis();
			insert pricingBasis;

			attachLocationManagersToTenderLocations(locationManagers, tenderLocations);
			return this;
		}

		public List<AITM_Tender_Location__c> createTenderLocations() {
			List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
			for(AITM_Location__c location : locations){
				tenderLocations.add(
					createTenderLocation(tender.Id, location.Id)
				);
			}
			return tenderLocations;
		}

		public AITM_Pricing_Basis__c createPricingBasis(){
			return new AITM_Pricing_Basis__c(
				Name = 'P008',
				AITM_Description__c = 'Barges FOB Rotterdam High Prior Month WD',
				AITM_Currency__c = 'USD',
				AITM_Unit_Of_Measure__c = 'USG'
				);
		}

		public void attachLocationManagersToTenderLocations(List<User> locationManagers, List<AITM_Tender_Location__c> tenderLocations) {

			List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
			Integer index = 0;

			for(AITM_Tender_Location__c tenderLocation : tenderLocations){
				tenderLocation.AITM_Location_Manager__c = locationManagers[index].Id;
				result.add(tenderLocation);
				index++;
			}

			upsert result;

		}

		public void createTenderAccounts() {
			insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
		}

		public void createTenderLocationLineItems() {
			tenderLocationLineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
		}

		public AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
			return new AITM_Tender_Location_Line_Item__c(
				AITM_Tender__c = tenderId,
				AITM_Account__c = accountId,
				AITM_Location__c = locationId,
				AITM_Start_Date__c = Date.today(),
				AITM_Tender_Location__c = tenderLocationId,
				AITM_End_Date__c = Date.today().addYears(1),
				AITM_Volume__c = 1.0,
				AITM_Requested_Volume_USG__c = 1
				);
		}


		private String getTenderResult(Integer resultNum){
			String result;
			if(resultNum <= 2){result = 'BG';}
			else if (resultNum > 2 && resultNum <=5) {result = 'BR';}
			else if (resultNum > 5 && resultNum <=8) {result = 'LB';}
			else if (resultNum > 8 && resultNum <=11) {result = 'MI';}
			else if (resultNum > 11 && resultNum <=15) {result = 'MIX';}

			return result;
		}

        public Boolean debriefLocationAvailable() {
            return [SELECT COUNT() From AITM_Tender_Location_Line_Item__c WHERE RecordType.DeveloperName = :AITM_LocationsDao.TLLI_RECORD_TYPE_DEBRIEF] > 0;
        }
	}
}