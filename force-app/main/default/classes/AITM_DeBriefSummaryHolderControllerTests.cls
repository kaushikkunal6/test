@isTest 
private class AITM_DeBriefSummaryHolderControllerTests {
	@isTest 
	static void testSaveAndGetTender() {
		DeBriefKeyPerMetricsControllerTestSetup testSetup = new DeBriefKeyPerMetricsControllerTestSetup().generateData();
		String volumeNotes = 'test volume notes';
		testSetup.tender.AITM_Volume_Notes__c = volumeNotes;

		Test.startTest();
		AITM_DeBriefSummaryHolderController.saveTender(testSetup.tender);
		AITM_Tender__c tender = AITM_DeBriefSummaryHolderController.getTender(testSetup.tender.Id);
		
		Test.stopTest();

		System.assertEquals(volumeNotes, tender.AITM_Volume_Notes__c);
	}

	private class DeBriefKeyPerMetricsControllerTestSetup extends AITM_TestSetup {

		public AITM_DeBriefKeyPerMetricsController classUnderTest;
		public AITM_Tender__c tender;

		public DeBriefKeyPerMetricsControllerTestSetup generateData(){
			classUnderTest = new AITM_DeBriefKeyPerMetricsController();
			tender = createTender();
			insert tender;

			return this;
		}

	}
}