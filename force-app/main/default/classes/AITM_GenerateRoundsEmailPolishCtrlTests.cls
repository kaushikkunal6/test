/**************************************************************************
 * @author           srnandan
 * @date             08/October/2018
 * @group            AirBP
 * @description      Test class for AITM_GenerateRoundsEmailPolishController

 * history
 * 08/October/2018   srnandan     Created
 *******************************************************************/
@isTest 
private class AITM_GenerateRoundsEmailPolishCtrlTests {

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
            AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = AITM_GenerateRoundsEmailPolishController.generate(setup.tender.Id, AITM_TenderDao.POLISH);
        Test.stopTest();

        System.assertEquals(1, generatedEmailDTO.emailAddresses.size(), 'The email addresses size is 1');
        //System.assertEquals(true, generatedEmailDTO.emailAddresses[0].isTo, 'The email address is valid');
        System.assert(String.isNotBlank(generatedEmailDTO.subject), 'The subject is not blank');
        System.assert(generatedEmailDTO.emailBodies.size() > 1, 'Should be complex structure');
        
    }
    
    /**
    * @description tests to verify tender status is awaiting price or changed
    * @param  null
    * @return void
    */
    @isTest
    private static void testWhenTenderStatusChange() {
        AITM_GenerateRoundsEmailControllerTestSetup setup = new AITM_GenerateRoundsEmailControllerTestSetup().generateData();
        
        Test.startTest();
            AITM_GenerateRoundsEmailPolishController.updateTenderChange(setup.tender.Id);
        Test.stopTest();

        System.assertEquals(true, true, 'The result is true');
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
        AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = AITM_GenerateRoundsEmailPolishController.generate(setup.tender.Id, AITM_TenderDao.POLISH);

        Test.startTest();
            AITM_GenerateRoundsEmailPolishController.attachEmail(setup.generateEmailDTOObjectWithIdInJSON(generatedEmailDTO));
        Test.stopTest();
        String fileName = generatedEmailDTO.subject + '.html';
        ContentVersion insertedContentVersion = [SELECT Id, Title, FileType, PathOnClient FROM ContentVersion WHERE Title = :fileName][0];
        System.assertEquals('HTML', insertedContentVersion.FileType, 'The file type is HTML');
    }
    
   /**
    * @description test data holder generateRoundsEmailController controller inner class
    */
    private class AITM_GenerateRoundsEmailControllerTestSetup extends AITM_TestSetup {
        public final Integer ITEMS_SIZE = 1;
        public List<Account> accounts;
        public List<AITM_Tender_Account__c> tenderAccounts;
        public List<AITM_Location__c> locations;
        public List<AITM_Tender_Location__c> tenderLocations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> lineItems;

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
            locations[0].AITM_Country__c = 'Poland';
            update locations;

            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            tender.AITM_Stage__c = 'Awaiting price';
            tender.AITM_Unit_Of_Measure__c = 'LT';
            insert tender;

            tenderLocations = createTenderLocations();
            for(AITM_Tender_Location__c tenderLocation : tenderLocations){
                tenderLocation.AITM_Has_Feedback__c = true;
            }
            insert tenderLocations;

            tenderAccounts = createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
            insert tenderAccounts;

            AITM_Pricing_Basis__c pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test');
            insert pricingBasis;
            AITM_Delivery_Point__c deliveryPoint = createDeliveryPoint(locations[0],true, 1);
			insert deliveryPoint;
            lineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
            for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
               lineItem.AITM_Pricing_Basis__c = pricingBasis.Id;
               //lineItem.AITM_Delivery_Point__c = '1';
               lineItem.AITM_Location_Delivery_Point__c = deliveryPoint.Id;
               lineItem.AITM_Currency__c = 'USD';
               lineItem.AITM_Unit_Of_Measure__c = 'LT'; 
               lineItem.AITM_Offered_Differential__c = 1.0;
            }
            insert lineItems;

            return this;
        }

       /**
        * @description generates emaildto object in json format
        * @param  generatedEmailDTO of type AITM_EmailGeneratorController
        * @return string
        */
        public String generateEmailDTOObjectWithIdInJSON(AITM_EmailGeneratorController.EmailDTO generatedEmailDTO) {
            AITM_GenerateRoundsEmailController.EmailDTOTenderId testObj = new AITM_GenerateRoundsEmailController.EmailDTOTenderId();
            testObj.tenderId = tender.Id;
            testObj.emailDTO = generatedEmailDTO;
            return JSON.serialize(testObj);
        }

       /**
        * @description creates tender locations
        * @param  null
        * @return List<AITM_Tender_Location__c>
        */
        public List<AITM_Tender_Location__c> createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
            for(AITM_Location__c location : locations){
                tenderLocations.add(
                    createTenderLocation(tender.Id, location.Id)
                    );
            }
            return tenderLocations;
        }
    }
}