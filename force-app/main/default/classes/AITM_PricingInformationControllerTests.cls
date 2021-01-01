@isTest 
public class AITM_PricingInformationControllerTests {

	public static final String STAGE_DEBRIEF = 'debrief';
	public static final String STAGE_FEEDBACK = 'feedback and negotiation';
	public static final String PAGE_URL = '/apex/AITM_PricingInformation?id=';

	@isTest 
    static void testXLSContentWithDeBriefRecords() {
		PricingInformationControllerTestSetup testSetup = new PricingInformationControllerTestSetup().generateData();
		testSetup.createTenderLocationLineItems();

		Test.StartTest();
			testSetup.progressToDeBrief();
	        PageReference pageRef = Page.AITM_PricingInformation;
	        Test.setCurrentPage(pageRef);
	      	ApexPages.currentPage().getParameters().put('id', testSetup.tender.Id);
	        AITM_PricingInformationController.XLSContent xlsContent = new AITM_PricingInformationController.XLSContent(testSetup.tender.Id, AITM_TenderDao.NONPOLISH);
		Test.StopTest();

        if (testSetup.debriefLocationAvailable()) {
		    System.assertEquals('<?xml version="1.0"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40"><Styles><Style ss:ID="date_dd_mm_yyyy"><NumberFormat ss:Format="dd.mm.yyyy;@"/></Style></Styles><Worksheet ss:Name="Sheet1"><Table>',xlsContent.header);
		    //System.assertNotEquals(null, xlsContent.headerRow);
		    System.assertNotEquals(null, xlsContent.data);
		    System.assertEquals('</Table></Worksheet></Workbook>',xlsContent.footer);
        }

    }

	@isTest 
    static void testXLSContentNoDeBriefRecords() {

		PricingInformationControllerTestSetup testSetup = new PricingInformationControllerTestSetup().generateData();

		Test.StartTest(); 
	        PageReference pageRef = Page.AITM_PricingInformation;
	        Test.setCurrentPage(pageRef);
	      	ApexPages.currentPage().getParameters().put('id', testSetup.tender.Id);
	        AITM_PricingInformationController.XLSContent xlsContent = new AITM_PricingInformationController.XLSContent(testSetup.tender.Id, AITM_TenderDao.NONPOLISH);
		Test.StopTest();

		System.assertEquals('<?xml version="1.0"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40"><Styles><Style ss:ID="date_dd_mm_yyyy"><NumberFormat ss:Format="dd.mm.yyyy;@"/></Style></Styles><Worksheet ss:Name="Sheet1"><Table>',xlsContent.header);
		System.assertEquals(null, xlsContent.headerRow);
		System.assertEquals('', xlsContent.data);
		System.assertEquals('</Table></Worksheet></Workbook>',xlsContent.footer);

    }

	private class PricingInformationControllerTestSetup extends AITM_TestSetup {

		public AITM_PricingInformationControllerTests classUnderTest;
		public List<Account> accounts;
		public List<AITM_Location__c> locations;
		public AITM_Tender__c tender;
		public List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
		public List<AITM_Tender_Location__c> tenderLocations;
		public List<User> locationManagers;
		public AITM_Pricing_Basis__c pricingBasis;
		public final Integer ITEMS_COUNT = 10;
        private final ID TLLI_ID_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();

		public PricingInformationControllerTestSetup generateData(){

			classUnderTest = new AITM_PricingInformationControllerTests();

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
			insert tenderLocationLineItems;
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
				AITM_Requested_Volume_USG__c = 1,
				AITM_Tender_Result__c = 'BG'
				);
		}

		private void progressToDeBrief() {
            for (AITM_Tender_Location_Line_Item__c lineItem  : tenderLocationLineItems) {
                lineItem.RecordTypeId = TLLI_ID_RECORD_TYPE_DEBRIEF;   
            }
            update tenderLocationLineItems;
        }

        public Boolean debriefLocationAvailable() {
            return [SELECT COUNT() From AITM_Tender_Location_Line_Item__c WHERE RecordType.DeveloperName = :AITM_LocationsDao.TLLI_RECORD_TYPE_DEBRIEF] > 0;
        }
	}
}