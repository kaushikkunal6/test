/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_DeBriefEmailGenerator

 * history
 * 01/December/2017  George      Created 
 * 23/April/2018     srnandan    added comments at method and class level as per coding standards                               
 ************************************************************************************************/
@isTest  
private with sharing class AITM_DeBriefEmailGeneratorCntrlTests  {
    
    /**
     * @description checks if the tenderId id being passed is valid or not
     * @param  null
     * @return null
     */
    @isTest  
    private static void checkIfValidTenderIdIsPassedToGeneratorValidEmailDTOIsGenerated() {
        AITM_DeBriefEmailGeneratorCntrlTestSetup setup = new AITM_DeBriefEmailGeneratorCntrlTestSetup().generateData();
        
        Test.startTest();
            setup.progressToDeBrief();
            AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = AITM_DeBriefEmailGeneratorController.generate(setup.tender.Id, AITM_TenderDao.NONPOLISH);
        Test.stopTest();

        System.assertEquals(2, generatedEmailDTO.emailAddresses.size(), 'The generated email size is 2');
        //System.assertEquals(true, generatedEmailDTO.emailAddresses[0].isTo, 'The generated email to address is True');
        //System.assertEquals(UserInfo.getUserEmail(), generatedEmailDTO.emailAddresses[0].targetEmail, 'targetEmail address gets from user info');
        System.assert(String.isNotBlank(generatedEmailDTO.subject), 'The subject is blank');
        System.assert(generatedEmailDTO.emailBodies.size() > 1, 'Should be complex structure');
        //System.assertEquals(1, generatedEmailDTO.emailAttachments.size(), 'Pricing Sheet Should Be Attached');
        
        System.assert(generatedEmailDTO.emailBodies[0].htmlBody.contains(setup.tender.Name), 'The tender name is equal to htmlbody');
        //System.assert(generatedEmailDTO.emailBodies[1].htmlBody.contains('Tender Context'), 'The tender is equal to tender context');
    }
    
    /**
     * @description checks if valid emailId passed will trigger the creation of the attachment for the tender
     * @param  null
     * @return null
     */
    @isTest  
    private static void checkIfValidEmailDTOWillTriggerAttachmentCreationForATender() {
        AITM_DeBriefEmailGeneratorCntrlTestSetup setup = new AITM_DeBriefEmailGeneratorCntrlTestSetup().generateData();
        
        Test.startTest();
            setup.progressToDeBrief();
            AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = new AITM_DeBriefEmailGenerator.Generator(setup.tender.Id, AITM_TenderDao.NONPOLISH).generate();
            AITM_DeBriefEmailGeneratorController.attachEmail(setup.generateEmailDTOObjectWithIdInJSON(generatedEmailDTO), AITM_TenderDao.NONPOLISH);
        Test.stopTest();

        String fileName = generatedEmailDTO.subject + '.html';
        ContentVersion insertedContentVersion = [SELECT Id, Title, FileType, PathOnClient FROM ContentVersion WHERE Title = :fileName LIMIT 1][0];
        System.assertEquals('HTML', insertedContentVersion.FileType, 'file type version is HTML');
    }

    /**
     * @description checks if airport email generated
     * @param  null
     * @return null
     */
    @isTest 
    private static void checkIfAirportsEmailWillBeGeneratedWhenGenerateForAiport() {
        AITM_DeBriefEmailGeneratorCntrlTestSetup setup = new AITM_DeBriefEmailGeneratorCntrlTestSetup().generateData();
        //setup.getDistributionList();

        Test.startTest();
            setup.progressToDeBrief();
            Integer emailBefore = Limits.getEmailInvocations();
            AITM_DeBriefEmailGeneratorController.notifyAirports(setup.tender.Id, AITM_TenderDao.NONPOLISH);
            System.assertNotEquals(2,emailBefore);
        Test.stopTest();
    }
    
    /**
     * @description Test class AITM_DeBriefEmailGeneratorTestSetup extending the class AITM_TestSetup
     */
    private with sharing class AITM_DeBriefEmailGeneratorCntrlTestSetup extends AITM_TestSetup {
        public final Integer ITEMS_SIZE = 1;
        public List<Account> accounts;
        public List<AITM_Tender_Account__c> tenderAccounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        private final ID TLLI_ID_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
        
        /**
         * @description generates test data
         * @param  null
         * @return null
         */
        public AITM_DeBriefEmailGeneratorCntrlTestSetup generateData() {
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
                lineItems.AITM_Offered_Volume__c = 1.0;
                lineItems.AITM_Volume__c = 1.0;
                lineItems.AITM_Requested_Volume_USG__c = 1.0;
                lineItems.AITM_Awarded_Volume__c = 1.0;
            }
            insert tenderLocations;
            return this;
        }
       
       /**
        * @description to generate the To List of the email with Id in JSON
        * @param  generatedEmailDTO of type AITM_EmailGeneratorController.EmailDTO
        * @return String
        */
        public String generateEmailDTOObjectWithIdInJSON(AITM_EmailGeneratorController.EmailDTO generatedEmailDTO) {
            AITM_DeBriefEmailGeneratorController.EmailDTOTenderId testObj = new AITM_DeBriefEmailGeneratorController.EmailDTOTenderId();
            testObj.tenderId = tender.Id;
            testObj.emailDTO = generatedEmailDTO;
            return JSON.serialize(testObj);
        }

        /*private List<Contact> getDistributionList() {
            List<Contact> distributionList = new List<Contact>();
            for (Integer i = 0; i < locations.size(); i++) {
                distributionList.add(this.createContact(accounts[0].Id, locations[i].Id, 'Tester tester' + String.valueOf(i), 'supertestingemail@casdeasfdfadhdksacx.cscsdc' + String.valueOf(i)));
            }
            insert distributionList;
            return distributionList;
        }*/
       
        /**
        * @description to create the test contact
        * @param  accountId of type Id
        * @param locationId of type Id
        * @param lastname of type String
        * @param emalivalue of type String
        * @return Contact 
        */
        private Contact createContact(Id accountId, Id locationId, String lastName, String emailValue) {
            return new Contact(
                AccountId = accountId,
                AITM_Location__c = locationId,
                LastName = lastName,
                Email = emailValue
            );
        }
        
        /**
         * @description to progress to debrief tab
         * @param  null
         * @return null
         */
        private void progressToDeBrief() {
            for (AITM_Tender_Location_Line_Item__c lineItem  : tenderLocations) {
                lineItem.RecordTypeId = TLLI_ID_RECORD_TYPE_DEBRIEF;   
            }
            update tenderLocations;
        }
    }
}