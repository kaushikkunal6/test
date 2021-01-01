@IsTest 
private class AITM_DeBriefHolderControllerTests {
    @isTest 
    static void testGetFilterOptionsWillReturnNonVoidList() {
        DeBriefHolderControllerTestSetup testSetup = new DeBriefHolderControllerTestSetup();
        testSetup.generateData();

        Test.startTest();
            List<AITM_RelatedRecordsHolderController.FilterOption> result = AITM_DeBriefHolderController.getFilterOptions(testSetup.tender.Id);
        Test.stopTest();
        System.assert(result.size() > new AITM_LocationsDao().getTenderLocations(testSetup.tender.Id).size());
    }

    @isTest 
    static void testGetFilterWillReturnValidResultOnValidInput() {
        DeBriefHolderControllerTestSetup testSetup = new DeBriefHolderControllerTestSetup();
        testSetup.generateData();

        Test.startTest();
            AITM_RelatedRecordsHolderController.FilterOption result = AITM_DeBriefHolderController.getFilter('All Locations', testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals('All Locations', result.name);
        System.assertEquals(false, result.disabled);
    }
    
    @isTest 
    static void testGetFilterWillReturn() {
        DeBriefHolderControllerTestSetup testSetup = new DeBriefHolderControllerTestSetup();
        testSetup.generateData();
        
        Test.startTest();
            AITM_RelatedRecordsHolderController.FilterOption result = AITM_DeBriefHolderController.getFilter('', testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(null, result);
    }


    private class DeBriefHolderControllerTestSetup extends AITM_TestSetup {
        public AITM_Tender__c tender;

        public DeBriefHolderControllerTestSetup(){
            tender = createTender();
        }

        public void generateData() {
            insert tender;
        }

    }
}