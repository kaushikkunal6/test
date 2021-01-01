/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_InvitationEmailGenerator
 
 * history
 * 01/December/2017  George       Created
 * 09/Aug/2018       Ravi         Modified - added method level comments as per coding standards
 *******************************************************************/
 @isTest 
 private class AITM_InvitationEmailGeneratorTests {
    
    /**
     * @description tests to check if valid Tender is passed to Generator valid email ID
     * @param  null
     * @return null
     */  
    //To read the  report details given the seeAllData = true
    @isTest (seeAllData = true)  
    private static void checkIfValidTenderIdIsPassedToGeneratorValidEmailDTOIsGenerated() {
      
      Test.startTest();
          InvitationEmailGeneratorTestSetup setup = new InvitationEmailGeneratorTestSetup().generateData();
          AITM_InvitationEmailGenerator.Generator generator = new AITM_InvitationEmailGenerator.Generator(setup.tender.Id, AITM_TenderDao.NONPOLISH);
      Test.stopTest();
            
      AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = generator.generate();

      System.assertEquals(2, generatedEmailDTO.emailAddresses.size(),'Email address size should be 2');
    }
    
    /**
     * @description tests to check if valid Tender is passed to Generator valid email ID
     * @param  null
     * @return null
     */  
    @isTest  
    private static void checkIfValidTenderIdIsPassedToGeneratorPolishEmailDTOIsGenerated() {
      
      Test.startTest();
          InvitationEmailGeneratorTestSetup setup = new InvitationEmailGeneratorTestSetup().generateData();
          AITM_InvitationEmailGenerator.Generator generator1 = new AITM_InvitationEmailGenerator.Generator(setup.tender.Id);
          AITM_InvitationEmailGenerator.Generator generator = new AITM_InvitationEmailGenerator.Generator(setup.tender.Id, AITM_TenderDao.POLISH);
      Test.stopTest();
            
      AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = generator.generate();

      System.assertEquals(1, generatedEmailDTO.emailAddresses.size(),'Email address size should be 1');
    } 
    
    /**
     * @description tests to check if plain text body populated
     * @param  null
     * @return null
     */  
    @isTest  
    private static void checkIfPlainTextBody() {
      
      Test.startTest();
          InvitationEmailGeneratorTestSetup setup = new InvitationEmailGeneratorTestSetup().generateData();
          AITM_InvitationEmailGenerator.Generator generator1 = new AITM_InvitationEmailGenerator.Generator(setup.tender.Id);
          AITM_InvitationEmailGenerator.Generator generator = new AITM_InvitationEmailGenerator.Generator(setup.tender.Id, AITM_TenderDao.POLISH);
      Test.stopTest();
            
      String textContent = generator.getEditablePlainTextBody();

      System.assert(textContent.contains('Dear Location Manager, I am pleased'),'Plain text body matches');
    } 
    
    /**
     * @description tests to check if plain text body populated
     * @param  null
     * @return null
     */  
    //To read the  report details given the seeAllData = true
    @isTest (seeAllData = true)  
    private static void checkIfBulkInvitationEmailsGenerated() {
      
      Test.startTest();
          InvitationEmailGeneratorTestSetup setup = new InvitationEmailGeneratorTestSetup().generateData();
          AITM_InvitationEmailGenerator.Generator generator1 = new AITM_InvitationEmailGenerator.Generator(setup.tender.Id);
          AITM_InvitationEmailGenerator.Generator generator = new AITM_InvitationEmailGenerator.Generator(setup.tender.Id, AITM_TenderDao.NONPOLISH);
          AITM_InvitationEmailGenerator.TenderEmailDataHolder tenderEmailDataHolder = new AITM_InvitationEmailGenerator.TenderEmailDataHolder(setup.tender, AITM_TenderDao.NONPOLISH);
          AITM_InvitationEmailGenerator.TenderEmailBuilder emailBuilder = new AITM_InvitationEmailGenerator.TenderEmailBuilder(tenderEmailDataHolder);
          emailBuilder.build(AITM_TenderDao.NONPOLISH);
          tenderEmailDataHolder.getTenderLocationIdToLineItems();
      Test.stopTest();
      List<Id> tenderIds = new List<Id>();
      tenderIds.add(setup.tender.Id);
      List<Messaging.SingleEmailMessage> messages = generator.generateTenderInvitationEmailsBulk(tenderIds);

      System.assertEquals(0, messages.size(),'Bulk mesages sent for multiple tenders');
    }
    
    /**
     * @description tests to check if post to chatter
     * @param  null
     * @return null
     */  
    @isTest  
    private static void checkIfPostToChatter() {
      
      Test.startTest();
          InvitationEmailGeneratorTestSetup setup = new InvitationEmailGeneratorTestSetup().generateData();
          AITM_InvitationEmailGenerator.Generator generator1 = new AITM_InvitationEmailGenerator.Generator(setup.tender.Id);
          AITM_InvitationEmailGenerator.Generator generator = new AITM_InvitationEmailGenerator.Generator(setup.tender.Id, AITM_TenderDao.NONPOLISH);
      Test.stopTest();
      List<String> messages = generator.postToChatter();

      System.assertEquals(0, messages.size(),'chatter mesages sent for location managers');
    }
     
    /**
     * @description test data holder InvitationEmailGenerator controller inner class
     */
    private class InvitationEmailGeneratorTestSetup extends AITM_TestSetup {
      public final Integer ITEMS_SIZE = 1;
      public List<Account> accounts;
      public List<AITM_Tender_Account__c> tenderAccounts;
      public List<AITM_Location__c> locations;
      public AITM_Tender__c tender;
      public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
      public List<AITM_Tender_Location__c> tenderLocationMaster;
      public List<AITM_Delivery_Point__c> deliveryPoints;
      private List<User> delegates;
        
     /**
      * @description generate test data i.e. accounts, location, tenders
      * @param  null
      * @return InvitationEmailGeneratorTestSetup
      */
      public InvitationEmailGeneratorTestSetup generateData() {
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
        tender.AITM_Unit_Of_Measure__c = 'USG';
        insert tender;
        
        tenderAccounts = createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        insert tenderAccounts;

        AITM_Pricing_Basis__c pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test');
        insert pricingBasis;
        deliveryPoints = createDeliveryPoints(ITEMS_SIZE);
        insert deliveryPoints;
		tenderLocationMaster = createTenderLocations(new List<AITM_Tender__c>{tender},locations);
        for(AITM_Tender_Location__c tenderLoc : tenderLocationMaster) {
           tenderLoc.AITM_Status__c = 'Awaiting price';
        }
        insert tenderLocationMaster;
        delegates = createUsers(2, 'Air_TMLocation Manager');
        insert delegates;  
        tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
        for (AITM_Tender_Location_Line_Item__c lineItems : tenderLocations) {
              lineItems.AITM_Pricing_Basis__c = pricingBasis.Id;
              lineItems.AITM_Delivery_Point__c = '1';
              lineItems.AITM_Currency__c = 'USD';
              lineItems.AITM_Unit_Of_Measure__c = 'LT'; 
              lineItems.AITM_Offered_Differential__c = 1.0;
              lineItems.AITM_Offered_Volume__c = 1.0;
              lineItems.AITM_Volume__c = 1.0;
              lineItems.AITM_Tender_Location__c = tenderLocationMaster[0].Id;
              lineItems.AITM_Status__c = 'Awaiting price';
              lineItems.AITM_Location_Delivery_Point__c = deliveryPoints[0].Id;
        }
        insert tenderLocations;
          
        return this;
      }
      
      /**
       * @description createContact test data 
       * @param accountId
       * @param locationId
       * @param lastName
       * @param emailValue 
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
       
      public List<AITM_Delivery_Point__c> createDeliveryPoints(Integer size) {
	        List<AITM_Delivery_Point__c> result = new List<AITM_Delivery_Point__c>();
	        for (Integer index = 0; index < size; index++) {
	            AITM_Delivery_Point__c iterationDeliveryPoint = createDeliveryPoint(locations[0], false, index);
	            result.add(iterationDeliveryPoint);
	        }
	        return result;
	    }  
   }
}