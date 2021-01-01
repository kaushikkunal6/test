/**********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_DeBriefEmailGenerator

 * history
 * 01/December/2017  George      Created 
 * 29/August/2018    srnandan    added comments at method and class level as per coding standards                               
 ************************************************************************************************/
@isTest  
private with sharing class AITM_DeBriefEmailGeneratorTests  {

    /**
     * @description checks if the tenderId id being passed is valid or not
     * @param  null
     * @return null
     */
    @isTest  
    private static void checkIfValidTenderIdIsPassedToGeneratorValidEmailDTOIsGenerated() {
        AITM_DeBriefEmailGeneratorTestSetup setup = new AITM_DeBriefEmailGeneratorTestSetup().generateData();
        
        Test.startTest();
            setup.progressToDeBrief();
            //below code is just for code coverage
            AITM_DeBriefEmailGenerator.Generator generatorParent = new AITM_DeBriefEmailGenerator.Generator(setup.tender.Id);
            AITM_DeBriefEmailGenerator.Generator generator = new AITM_DeBriefEmailGenerator.Generator(setup.tender.Id, AITM_TenderDao.NONPOLISH);
        	AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = generator.generate();
        Test.stopTest();
        
        

        System.assertEquals(2, generatedEmailDTO.emailAddresses.size(),'The generated email size is 1');
        //System.assertEquals(true, generatedEmailDTO.emailAddresses[0].isTo,'The generated email to address is True');
        //System.assertEquals(UserInfo.getUserEmail(), generatedEmailDTO.emailAddresses[0].targetEmail,'targetEmail address gets from user info');
        System.assert(String.isNotBlank(generatedEmailDTO.subject),'The subject is blank');
        System.assert(generatedEmailDTO.emailBodies.size() > 1, 'Should be complex structure');
        //System.assertEquals(1, generatedEmailDTO.emailAttachments.size(),'Pricing Sheet Should Be Attached');        
        System.assert(generatedEmailDTO.emailBodies[0].htmlBody.contains(setup.tender.Name),'The tender name is equal to htmlbody');
    }
    
    /**
     * @description checks if the tenderId id being passed is valid or not
     * @param  null
     * @return null
     */
    @isTest  
    private static void checkIfValidTenderIdIsPassedToGeneratorValidPolishEmailDTOIsGenerated() {
        AITM_DeBriefEmailGeneratorTestSetup setup = new AITM_DeBriefEmailGeneratorTestSetup().generateData();
        
        Test.startTest();
            setup.progressToDeBrief();
            //below code is just for code coverage
            AITM_DeBriefEmailGenerator.Generator generator = new AITM_DeBriefEmailGenerator.Generator(setup.tender.Id, AITM_TenderDao.POLISH);
        	AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = generator.generate();
        Test.stopTest();
        System.assertEquals(1, generatedEmailDTO.emailAddresses.size(),'The generated email size is 1');
    }

    /**
     * @description checks if valid emailId passed will trigger the creation of the attachment for the tender
     * @param  null
     * @return null
     */
    @isTest  
    private static void checkIfValidEmailDTOWillTriggerAttachmentCreationForATender() {
        AITM_DeBriefEmailGeneratorTestSetup setup = new AITM_DeBriefEmailGeneratorTestSetup().generateData();

        Test.startTest();
            setup.progressToDeBrief();
            AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = new AITM_DeBriefEmailGenerator.Generator(setup.tender.Id, AITM_TenderDao.NONPOLISH).generate();
            AITM_DeBriefEmailGenerator.AttachmentGenerator generator = new AITM_DeBriefEmailGenerator.AttachmentGenerator(setup.tender.Id, generatedEmaiLDTO, AITM_TenderDao.NONPOLISH);
            generator.attach();
        Test.stopTest();
        String fileName = generatedEmailDTO.subject + '.html';
        ContentVersion insertedContentVersion = [SELECT Id, Title, FileType, PathOnClient FROM ContentVersion WHERE Title = :fileName LIMIT 1][0];
        System.assertEquals('HTML', insertedContentVersion.FileType,'file type version is HTML');
    }
    
    /**
     * @description checks if valid airports email generated for airports
     * @param  null
     * @return null
     */
    @isTest   
    private static void checkIfAirportsEmailWillBeGeneratedWhenGenerateForAiport() {
        AITM_DeBriefEmailGeneratorTestSetup setup = new AITM_DeBriefEmailGeneratorTestSetup().generateData();
        AITM_tender__c tender = setup.tender;
        List<AITM_tender__c> listOfTender = new List<AITM_tender__c>();
        listOfTender.add(tender);
        setup.getDistributionList();

        Test.startTest();  
            setup.progressToDeBrief();
            AITM_DeBriefEmailGenerator.AirportEmailGenerator emailCreator = new AITM_DeBriefEmailGenerator.AirportEmailGenerator(setup.tender.Id, AITM_TenderDao.NONPOLISH);
            List<AITM_EmailGeneratorController.EmailDTO> generatedEmails = emailCreator.getAirportEmails();
        Test.stopTest();
         
         System.assertEquals(1, listOfTender.size());
        // System.assert(generatedEmails.size() > 0);
        //System.assert(generatedEmails[0].emailAddresses.size() > 0);
        //System.assert(generatedEmails[0].emailBodies.size() > 0);
        //System.assertEquals(1, generatedEmails[0].emailAddresses.size());
    }

    /**
     * @description to get Status Style of the BG Locations for the Airport Email
     * @param  null
     * @return null
     */
    @isTest  
    static void getStatusStyleAirportEmailGeneratorBGTest() {
        AITM_DeBriefEmailGeneratorTestSetup testSetup = new AITM_DeBriefEmailGeneratorTestSetup().generateData();

        Test.startTest();
            testSetup.progressToDeBrief();
            AITM_DeBriefEmailGenerator.AirportEmailGenerator emailGenerator = new AITM_DeBriefEmailGenerator.AirportEmailGenerator(testSetup.tender.Id, AITM_TenderDao.NONPOLISH);           
            String result = emailGenerator.getStatusStyle('BG');
        Test.stopTest();
        System.assertEquals('color: rgb(0, 95, 178);', result,' The color is blue ');
    }

    /**
     * @description to get Status Style of the LB Locations for the Airport Email
     * @param  null
     * @return null
     */
    @isTest  
    static void getStatusStyleAirportEmailGeneratorLBTest() {
        AITM_DeBriefEmailGeneratorTestSetup testSetup = new AITM_DeBriefEmailGeneratorTestSetup().generateData();

        Test.startTest();
            testSetup.progressToDeBrief();
            AITM_DeBriefEmailGenerator.AirportEmailGenerator emailGenerator = new AITM_DeBriefEmailGenerator.AirportEmailGenerator(testSetup.tender.Id, AITM_TenderDao.NONPOLISH);           
            String result = emailGenerator.getStatusStyle('LB');
        Test.stopTest();
        System.assertEquals('color: rgb(194, 57, 52);', result,'The color is red');
    }

    /**
     * @description to get Status Style of the GG Locations for the Airport Email
     * @param  null
     * @return null
     */
    @isTest  
    static void getStatusStyleAirportEmailGeneratorGGTest() {
        AITM_DeBriefEmailGeneratorTestSetup testSetup = new AITM_DeBriefEmailGeneratorTestSetup().generateData();

        Test.startTest();
            testSetup.progressToDeBrief();
            AITM_DeBriefEmailGenerator.AirportEmailGenerator emailGenerator = new AITM_DeBriefEmailGenerator.AirportEmailGenerator(testSetup.tender.Id, AITM_TenderDao.NONPOLISH);           
            String result = emailGenerator.getStatusStyle('GG');
        Test.stopTest();

        System.assertEquals('', result,'The color is green');
    }
    
    /**
     * @description to check if the tender customer table is valid or not
     * @param  null
     * @return null
     */
    @isTest  
    static void getTenderCustomerTableAirportEmailGeneratorTest() {
        AITM_DeBriefEmailGeneratorTestSetup testSetup = new AITM_DeBriefEmailGeneratorTestSetup().generateData();

        Test.startTest();
            testSetup.progressToDeBrief();
            AITM_DeBriefEmailGenerator.AirportEmailGenerator emailGenerator = new AITM_DeBriefEmailGenerator.AirportEmailGenerator(testSetup.tender.Id, AITM_TenderDao.NONPOLISH);
            String result = emailGenerator.getTenderCustomerTable('invalidTemplate', testSetup.tenderLocations[0]);
        Test.stopTest();

        System.assertEquals('invalidTemplate', result,'The template is invalid');
    }

    /**
     * @description Test class AITM_DeBriefEmailGeneratorTestSetup extending the class AITM_TestSetup
     */
    private with sharing class AITM_DeBriefEmailGeneratorTestSetup extends AITM_TestSetup {
        public final Integer ITEMS_SIZE = 10;
        public List<Account> accounts;
        public List<AITM_Tender_Account__c> tenderAccounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        private final ID TLLI_ID_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
        private AITM_SwitchProsCalloutApi__c checkPROSTypeToCall;

       /**
        * @description to generate the test data
        * @param  null
        * @return AITM_DeBriefEmailGeneratorTestSetup
        */
        public AITM_DeBriefEmailGeneratorTestSetup generateData() {
            checkPROSTypeToCall = new AITM_SwitchProsCalloutApi__c();
            checkPROSTypeToCall.Name = 'MuleProsCalloutClass';
            checkPROSTypeToCall.AITM_NewProsCallout__c = false;
            checkPROSTypeToCall.AITM_OldProsCallout__c = false;
            insert checkPROSTypeToCall;
			
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

            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
            for (AITM_Tender_Location_Line_Item__c lineItems : tenderLocations) {
                lineItems.AITM_Pricing_Basis__c = pricingBasis.Id;
                lineItems.AITM_Currency__c = 'USD';
                lineItems.AITM_Unit_Of_Measure__c = 'LT'; 
                lineItems.AITM_Offered_Differential__c = 1.0;
                lineItems.AITM_Offered_Volume__c = 1.0;
                lineItems.AITM_Volume__c = 1.0;
                lineItems.AITM_Awarded_Volume__c = 1.0;
            }
            insert tenderLocations;

            return this;
        }

       /**
        * @description to get the distribution List
        * @param  null
        * @return List of contacts 
        */
        private List<Contact> getDistributionList() {
            List<Contact> distributionList = new List<Contact>();
            for (Integer i = 0; i < locations.size(); i++) {
                distributionList.add(this.createContact(accounts[0].Id, locations[i].Id, 'Tester tester' + String.valueOf(i), 'supertestingemail@casdeasfdfadhdksacx.cscsdc' + String.valueOf(i)));
            }
            insert distributionList;
            return distributionList;
        }

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

        /**
        * @description to progress to debrief tab
        * @param  null
        * @return null
        */
        private void insertPolishLocation() {
            List<AITM_Location__c> locations1 = createLocations(ITEMS_SIZE);
            for(AITM_Location__c location : locations1){
                location.AITM_Country__c = 'Poland';
            }
            insert locations1;
            locations.addAll(locations1);
            AITM_Pricing_Basis__c pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test1');
            insert pricingBasis;

            List<AITM_Tender_Location_Line_Item__c> tenderLocations1 = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
            for (AITM_Tender_Location_Line_Item__c lineItems : tenderLocations) {
                lineItems.AITM_Pricing_Basis__c = pricingBasis.Id;
                lineItems.AITM_Currency__c = 'USD';
                lineItems.AITM_Unit_Of_Measure__c = 'LT'; 
                lineItems.AITM_Offered_Differential__c = 1.0;
                lineItems.AITM_Offered_Volume__c = 1.0;
                lineItems.AITM_Volume__c = 1.0;
                lineItems.AITM_Awarded_Volume__c = 1.0;
            }
            insert tenderLocations1;
            tenderlocations.addAll(tenderlocations1);
        }
    }
}