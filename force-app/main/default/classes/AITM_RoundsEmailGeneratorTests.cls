/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_RoundsEmailGenerator

 * history
 * 01/December/2017  George       Created
 * 13/June/2018      srnandan     Modified - added method level comments as per coding standards
 *******************************************************************/
@isTest 
private with sharing class AITM_RoundsEmailGeneratorTests {
    /**
     * @description tests to verify tender passed along with tender locations
     * @param  null
     * @return void
     */
    //To read the  report details given the seeAllData = true
    @isTest (seeAllData = true)
    private static void testWhenTenderPassedWithTheValidStructureAlongWithTenderLocationRightEmailDTOIsPopulated() {
        AITM_GenerateRoundsEmailControllerTestSetup setup = new AITM_GenerateRoundsEmailControllerTestSetup().generateData();
        
        Test.startTest();
            AITM_RoundsEmailGenerator.Generator generator = new AITM_RoundsEmailGenerator.Generator(setup.tender.Id, AITM_TenderDao.NONPOLISH);
            AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = generator.generate();
        Test.stopTest();

        System.assertEquals(2, generatedEmailDTO.emailAddresses.size(), 'Email addresses size is 2');
        //System.assertEquals(true, generatedEmailDTO.emailAddresses[0].isTo, 'Has to email address');
        //System.assertEquals(UserInfo.getUserEmail(), generatedEmailDTO.emailAddresses[0].targetEmail, 'Target email matching with logged in user email');
        System.assert(String.isNotBlank(generatedEmailDTO.subject), 'Subject is not blank');
        System.assert(generatedEmailDTO.emailBodies.size() > 1, 'Should be complex structure');
        
    }
    
    /**
     * @description tests to verify attach email received with content
     * @param  null
     * @return void
     */
    //To read the  report details given the seeAllData = true
    @isTest (seeAllData = true)
    private static void testWhenAttachEmailReceiveAValidEmailDTOWrapperAttachmentWillBeCreated() {
        AITM_GenerateRoundsEmailControllerTestSetup setup = new AITM_GenerateRoundsEmailControllerTestSetup().generateData();

        Test.startTest();
            AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = AITM_GenerateRoundsEmailController.generate(setup.tender.Id, AITM_TenderDao.NONPOLISH);
            AITM_RoundsEmailGenerator.AttachmentGenerator generator = new AITM_RoundsEmailGenerator.AttachmentGenerator(setup.tender.Id, generatedEmaiLDTO, AITM_TenderDao.NONPOLISH);
            generator.attach();
        Test.stopTest();
        String fileName = generatedEmailDTO.subject + '.html';
        ContentVersion insertedContentVersion = [SELECT Id, Title, FileType, PathOnClient FROM ContentVersion WHERE Title = :fileName][0];
        System.assertEquals('HTML', insertedContentVersion.FileType, 'File type is HTML');
    }
    
    /**
     * @description test data holder generateRoundsEmailController controller inner class
     */
    private with sharing class AITM_GenerateRoundsEmailControllerTestSetup extends AITM_TestSetup {
        public final Integer ITEMS_SIZE = 1;
        public List<Account> accounts;
        public List<AITM_Tender_Account__c> tenderAccounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        
        /**
         * @description generate test data i.e. accounts, location, tenders
         * @param  null
         * @return AITM_GenerateRoundsEmailControllerTestSetup
         */
        public AITM_GenerateRoundsEmailControllerTestSetup generateData() {
            AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
			settings.AITM_IsActive__c = true;
			upsert settings AITM_DeactivateTriggerSetting__c.Id;
            accounts = createAccounts(ITEMS_SIZE);
            insert accounts;

            locations = createLocations(ITEMS_SIZE);
            for(AITM_Location__c location : locations){
                location.AITM_Country__c = 'Spain';
            }
            insert locations;

            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            tender.AITM_Stage__c = 'Awaiting Price';
            tender.AITM_Unit_Of_Measure__c = 'LT'; 
            insert tender;

            tenderAccounts = createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
            insert tenderAccounts;

            AITM_Pricing_Basis__c pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test');
            insert pricingBasis;
            AITM_Delivery_Point__c deliveryPoint = createDeliveryPoint(locations[0],true, 1);
			insert deliveryPoint;

            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
            for (AITM_Tender_Location_Line_Item__c lineItems : tenderLocations) {
               lineItems.AITM_Pricing_Basis__c = pricingBasis.Id;
               //lineItems.AITM_Delivery_Point__c = '1';
               lineItems.AITM_Location_Delivery_Point__c = deliveryPoint.Id;
               lineItems.AITM_Currency__c = 'USD';
               lineItems.AITM_Unit_Of_Measure__c = 'LT'; 
               lineItems.AITM_Offered_Differential__c = 1.0;
            }
            insert tenderLocations;

            return this;
        }
    }
}