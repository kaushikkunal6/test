@isTest 
private class AITM_TenderPathShowMoreControllerTests {
    @isTest 
    static void testPullDefaultsForTenderForShowMoreWillReturnValidResult() {
        TenderPathShowMoreControllerTestSetup testSetup = new TenderPathShowMoreControllerTestSetup().generateData();

        Test.startTest();
            AITM_TenderPathShowMoreController.DefaultValuesToCheckboxes defaultValues = AITM_TenderPathShowMoreController.pullDefaultValuesForCheckboxes(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(false, defaultValues.feedbackToDebrief);
        System.assertEquals(true, defaultValues.showButtons);
    }

    @isTest 
    static void testChangeFeedbackToDeBriefWillUpdateTheTenderRecordWithoutErrors() {
        TenderPathShowMoreControllerTestSetup testSetup = new TenderPathShowMoreControllerTestSetup().generateData();

        Test.startTest();
            String operationStatus = AITM_TenderPathShowMoreController.changeFeedbackToDeBrief(testSetup.tender.Id, true);
        Test.stopTest();

        System.assertEquals('OK', operationStatus);
        System.assertEquals(1, [SELECT Count() FROM AITM_Tender__c WHERE Id = :testSetup.tender.Id AND AITM_No_Feedback_Progress_To_De_Brief__c = true]);
    }

    private class TenderPathShowMoreControllerTestSetup extends AITM_TestSetup {
        public AITM_Tender__c tender;

        public TenderPathShowMoreControllerTestSetup generateData() {
            tender = createTender();
            insert tender;

            return this;
        }
    }
}