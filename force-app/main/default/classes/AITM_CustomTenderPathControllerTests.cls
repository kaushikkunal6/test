/***************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_CustomTenderPathController

 * history
 * 01/December/2017  George       Created
 * 04/April/2018     srnandan     Modified - AR-2371 added test method "testDisableMarkCompleteButtonForLocationManager" and header and method comments
 **********************************************************/
private @isTest class AITM_CustomTenderPathControllerTests {
    
    /**
     * @description tests to verify disabling of mark complete button
     * @param  null
     * @return void
     */
    static @isTest void testDisableMarkCompleteButtonForLocationManager() {
        CustomTenderPathControllerTestSetup testSetup = new CustomTenderPathControllerTestSetup().generateData();
        Boolean disableButton = false;
        Test.startTest();
                system.runAs(testSetup.userLM) {
                disableButton = AITM_CustomTenderPathController.toggleMarkStageButton();
            }
        Test.stopTest();

        System.assertEquals(true, disableButton,'The button is disabled');
    }

    /**
     * @description tests to verify custom tender path get stages with valid list of stages
     * @param  null
     * @return void
     */
    static @isTest void testCustomTenderPathGetStagesWillReturnAValidListsForStages() {
        CustomTenderPathControllerTestSetup testSetup = new CustomTenderPathControllerTestSetup().generateData();

        Test.startTest();
            AITM_CustomTenderPathController.TenderStages tenderStages = AITM_CustomTenderPathController.getStagesForTender(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(0, tenderStages.completedTenderStages.size(),'Tender Stage is Completed');
        System.assertEquals(6, tenderStages.uncompletedTenderStages.size(),'Tender Stage is uncompleted');
        System.assertEquals('Tender Created', tenderStages.currentTenderStage,'Tender is created');
    }

    /**
     * @description tests to verify custom tender path stage set as awaiting price from tender created
     * @param  null
     * @return void
     */
    static @isTest void testCustomTenderPathSetStageAsCompletedWillUpdateTheTenderStageToAwaitingPriceFromTenderCreated() {
        CustomTenderPathControllerTestSetup testSetup = new CustomTenderPathControllerTestSetup().generateData();
        testSetup.updateTenderToPriced();

        Test.startTest();
            String result = AITM_CustomTenderPathController.setStageAsCompleted(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals('OK', result, 'The result is Ok');
        System.assertEquals(1, [SELECT Count() FROM AITM_Tender__c WHERE Id = :testSetup.tender.Id AND AITM_Stage__c = 'Offer Submitted'],'The count is equal to 1');
    }

    /**
     * @description tests to verify custom tender path stage set as priced
     * @param  null
     * @return void
     */
    static @isTest void testCustomTenderPathSetTenderStageWillUpdateTheTender() {
        CustomTenderPathControllerTestSetup testSetup = new CustomTenderPathControllerTestSetup().generateData();
        testSetup.updateTenderToPriced();

        Test.startTest();
            String result = AITM_CustomTenderPathController.setStageForTender(testSetup.tender.Id, 'Offer Submitted');
        Test.stopTest();

        System.assertEquals('OK', result,'The result is Ok');
        System.assertEquals(1, [SELECT COUNT() FROM AITM_Tender__c WHERE Id = :testSetup.tender.Id AND AITM_Stage__c = 'Offer Submitted'], 'The count is equal to 1');
    }

    /**
     * @description class to hold custom tender path controller details
     */
    private class CustomTenderPathControllerTestSetup extends AITM_TestSetup {
        private AITM_Tender__c tender;
        private User userLM;
        private final Set<String> PROFILES_NOTALLOWED_TO_UPDATE = new Set<String>{
            'Air_TMLocation Manager'        
        };

        /**
         * @description generates test data
         * @param  null
         * @return CustomTenderPathControllerTestSetup
         */
        private CustomTenderPathControllerTestSetup generateData() {
            tender = createTender();
            INSERT tender;
            Profile p = [SELECT Id FROM Profile WHERE Name = :PROFILES_NOTALLOWED_TO_UPDATE Limit 1];
            userLM = new User(Alias = 'standt2',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemolm@camfed.org');
            INSERT userLM;
            return this;
        }

        /**
         * @description update tender to priced stage
         * @param  null
         * @return void
         */
        private void updateTenderToPriced() {
            tender.AITM_Stage__c = 'Priced';
            UPDATE tender;
        }
    }
}