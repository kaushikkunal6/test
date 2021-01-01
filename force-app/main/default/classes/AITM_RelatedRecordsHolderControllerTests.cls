@IsTest 
private class AITM_RelatedRecordsHolderControllerTests {

    @isTest 
    static void testFilterOptionCanBeCreatedWithAllParamsSetByDefault() {
        Test.startTest();
            AITM_RelatedRecordsHolderController.FilterOption filterOption = new AITM_RelatedRecordsHolderController.FilterOption('FilterName', false);
        Test.stopTest();

        System.assertEquals(false, filterOption.disabled);
        System.assertEquals('FilterName', filterOption.name);
        System.assertEquals(0, filterOption.getCriteria().size());
        System.assertEquals(false, filterOption.isSelectiveFilter());
        System.assertEquals(true, filterOption.isPassedFilter(null));
    }

    @isTest 
    static void testGetFilterOptionsWillProceedAllInputsWithTheValidResults() {
        Test.startTest();
            List<AITM_RelatedRecordsHolderController.FilterOption> locationResults = AITM_RelatedRecordsHolderController.getFilterOptions('RelatedTenderLocationsHolder', null);
            List<AITM_RelatedRecordsHolderController.FilterOption> deBriefResults = AITM_RelatedRecordsHolderController.getFilterOptions('DeBriefHolder', null);
            List<AITM_RelatedRecordsHolderController.FilterOption> unknownResults = AITM_RelatedRecordsHolderController.getFilterOptions('Test', null);
        Test.stopTest();

        System.assert(locationResults.size() > 0);
        System.assert(deBriefResults.size() > 0);
        System.assertEquals(null, unknownResults);
    }

    @isTest 
    static void testGetFilterWillProceedAllInputsWithTheValidResults() {
        Test.startTest();
            AITM_RelatedRecordsHolderController.FilterOption deBriefResult = AITM_RelatedRecordsHolderController.getFilter('DeBriefHolder', 'All Locations', null);
            AITM_RelatedRecordsHolderController.FilterOption locationResult = AITM_RelatedRecordsHolderController.getFilter('RelatedTenderLocationsHolder', 'All Locations', null);
            AITM_RelatedRecordsHolderController.FilterOption unknownResult = AITM_RelatedRecordsHolderController.getFilter('Test', 'All Locations', null);
        Test.stopTest();

        System.assertEquals('All Locations', deBriefResult.name);
        System.assertEquals(false, deBriefResult.disabled);
        System.assertEquals('All Locations', locationResult.name);
        System.assertEquals(false, locationResult.disabled);
        System.assertEquals(null, unknownResult);
    }
}