/***********************************************************************************************
 * @author           Sushant
 * @date             16/June/2020
 * @group            AirBP
 * @description      Test class for AITM_TenderLocationProsPricingService
 *************************************************************************************/
 
@isTest  
private With Sharing class AITM_TenderLocationProsPricingTests {
    
     /**
     * @description tests pricing information for success call
     * @param null
     * @return void
     */  
    @isTest  
  private static void testTargetPriceWillFillTargetPriceAndResultFieldsOnTenderLocationLineItem() {
    AITM_TenderLocationPricingServiceTestSetup setup = new AITM_TenderLocationPricingServiceTestSetup();
    setup.setPricingService('SUCCESS');

    Test.startTest();
      AITM_TenderLocationProsPricingService.getInstance().retrievePricingInformation(setup.lineItemsIds, 'Target Price');
      List<AITM_Tender_Location_Line_Item__c> lineItems = [SELECT AITM_Pricing_Service_Call_Status__c, AITM_Target_Price__c FROM AITM_Tender_Location_Line_Item__c WHERE ID IN :setup.lineItemsIds];
    Test.stopTest();
    System.assertNotEquals('OK', lineItems[0].AITM_Pricing_Service_Call_Status__c);
  }

    /**
     * @description tests pricing information for failure call
     * @param null
     * @return void
     */
    @isTest  
  private static void testTargetPriceWontFillTargetPriceInCaseOfAnError() {
    AITM_TenderLocationPricingServiceTestSetup setup = new AITM_TenderLocationPricingServiceTestSetup();
      setup.setPricingService('ERROR');
      AITM_SwitchProsCalloutApi__c checkPROSTypeToCall = setup.customSettingsInsert();
      checkPROSTypeToCall.AITM_NewProsCallout__c = false;
      checkPROSTypeToCall.AITM_OldProsCallout__c = true;
      insert checkPROSTypeToCall;
      
     Test.startTest();
       AITM_TenderLocationProsPricingService.getInstance().retrievePricingInformation(setup.lineItemsIds, 'Target Price');
       List<AITM_Tender_Location_Line_Item__c> lineItems = [SELECT AITM_Pricing_Service_Call_Status__c, AITM_Target_Price__c, AITM_Last_Call_To_Pricing_System__c FROM AITM_Tender_Location_Line_Item__c WHERE ID IN :setup.lineItemsIds];
     Test.stopTest();
     System.assertNotEquals('OK', setup.lineItems[0].AITM_Pricing_Service_Call_Status__c); 
  }

    /**
     * @description tests pricing information for targetprice and call status
     * @param null
     * @return void
     */
    @isTest  
    private static void testPricingInformationWillFillSomeFieldsAndResultFieldsOnTenderLocationLineItem() {
    AITM_TenderLocationPricingServiceTestSetup setup = new AITM_TenderLocationPricingServiceTestSetup();
     
     setup.setPricingService('ERROR');
     AITM_SwitchProsCalloutApi__c checkPROSTypeToCall = setup.customSettingsInsert();
     checkPROSTypeToCall.AITM_NewProsCallout__c = false;      
     checkPROSTypeToCall.AITM_OldProsCallout__c = true;
     insert checkPROSTypeToCall;
        
     Set<Id> firstTwoLineItems = new Set<Id>{setup.lineItems[0].Id, setup.lineItems[1].Id};    
     Test.startTest();
          System.enqueueJob(new AITM_TenderLocationProsPricingService(firstTwoLineItems, 'Pricing Information'));
     Test.stopTest();
     System.assertNotEquals('error', setup.lineItems[0].AITM_Pricing_Service_Call_Status__c); 
  }
   
   /**
     * @description tests pricing information onafterinserttenderlocationlineitem
     * @param null
     * @return void
     */ 
   @isTest  
   private static void afterInsertTenderLocationProsPricingService() {      
      AITM_TenderLocationPricingServiceTestSetup setup = new AITM_TenderLocationPricingServiceTestSetup();
      setup.setPricingService('SUCCESS');
      AITM_SwitchProsCalloutApi__c checkPROSTypeToCall = setup.customSettingsInsert();
      checkPROSTypeToCall.AITM_NewProsCallout__c = false;      
      checkPROSTypeToCall.AITM_OldProsCallout__c = true;
      insert checkPROSTypeToCall;  
      Test.startTest();
          AITM_TenderLocationProsPricingService pricingInstance = new AITM_TenderLocationProsPricingService();             
          pricingInstance.afterInsert(setup.lineItems[0]);     
          pricingInstance.getRequiredFieldsError(setup.lineItems[0]);
      Test.stopTest();
      System.assertNotEquals('null', setup.lineItems[0].AITM_Pricing_Service_Call_Status__c); 
   }
   
   /**
     * @description tests pricing information onafterupdatetenderlocationlineitem
     * @param null
     * @return void
     */ 
   @isTest  
   private static void afterUpdateTenderLocationProsPricingService() {
      AITM_TenderLocationPricingServiceTestSetup setup = new AITM_TenderLocationPricingServiceTestSetup();
      setup.setPricingService('SUCCESS');
       
      AITM_SwitchProsCalloutApi__c checkPROSTypeToCall = setup.customSettingsInsert();
      checkPROSTypeToCall.AITM_NewProsCallout__c = true;      
      checkPROSTypeToCall.AITM_OldProsCallout__c = false;
       Test.startTest();
      insert checkPROSTypeToCall;   
       
      AITM_Tender_Location_Line_Item__c newLineitemObject = setup.newlineItem;
      newLineitemObject.AITM_Data_Pricing_Calculation_Provided__c = true; 
      update newLineitemObject;
       
      
          AITM_TenderLocationProsPricingService pricingInstance = new AITM_TenderLocationProsPricingService();             
          pricingInstance.afterUpdate(setup.lineItems[0], newLineitemObject);   
      Test.stopTest(); 
      system.assertNotEquals('OK', setup.lineItems[0].AITM_Pricing_Service_Call_Status__c);       
   } 
   
    /**
     * @description wrapper class for pricing service setup test data
     */
  private With Sharing class AITM_TenderLocationPricingServiceTestSetup extends AITM_TestSetup {
        public final Integer ITEMS_SIZE = 10;
        public List<Account> accounts;
        public List<AITM_Tender_Account__c> tenderAccounts;
		public List<AITM_Location__c> locations;
		public List<AITM_Tender_Location__c> tenderLocations;
		public AITM_Tender__c tender;
		public List<AITM_Tender_Location_Line_Item__c> lineItems;
        public AITM_SwitchProsCalloutApi__c checkPROSTypeToCall;
        public Set<Id> lineItemsIds;
        public AITM_Tender_Location_Line_Item__c newlineItem;
        
        /**
         * @description default constructor
         * @param null
         */
        public AITM_TenderLocationPricingServiceTestSetup() {
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
        
        newlineItem = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
        newlineItem.AITM_Ad_hoc_Volume__c = true;   
        newlineItem.Recordtypeid = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();  
        newlineItem.AITM_Percentage_Volume_Offered__c = 2;
        newlineItem.AITM_Requested_Volume_USG__c = 3;
        newlineItem.AITM_Data_Pricing_Calculation_Provided__c = false;
        newlineItem.AITM_Volume__c = 50;
        insert newlineItem;       
            
		lineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
		for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
		   lineItem.AITM_Pricing_Basis__c = pricingBasis.Id;
		   lineItem.AITM_Delivery_Point__c = '1';
		   lineItem.AITM_Currency__c = 'USD';
		   lineItem.AITM_Unit_Of_Measure__c = 'LT'; 
		   lineItem.AITM_Offered_Differential__c = 1.0;
           lineItem.AITM_Data_Pricing_Calculation_Provided__c = false;
		}
		insert lineItems;

		lineItemsIds = new Map<Id, SObject>(lineItems).keySet();
		insert this.createPricingServiceSettings();
        }

       public AITM_SwitchProsCalloutApi__c customSettingsInsert(){
           checkPROSTypeToCall = new AITM_SwitchProsCalloutApi__c();
           checkPROSTypeToCall.Name = 'MuleProsCalloutClass';
           checkPROSTypeToCall.AITM_NewProsCallout__c = false;      
           checkPROSTypeToCall.AITM_OldProsCallout__c = true;
           return checkPROSTypeToCall;
       } 
      /**
         * @description sets pricing service 
         * @param serviceName of type String
         * @return void
         */
        public void setPricingService(String serviceName) {
            if (serviceName == 'SUCCESS') {
                Test.setMock(HttpCalloutMock.class, new PricingServiceSuccessResponseMock());
            } else if (serviceName == 'ERROR') {
                Test.setMock(HttpCalloutMock.class, new PricingServiceErrorResponseMock());
            }
        }
  }

  /**
     * @description class implementing HttpCalloutMock to mock success service response
  */
  private With Sharing class PricingServiceSuccessResponseMock implements HttpCalloutMock {
        /**
         * @description mock response for httprequest success
         * @param request of type HTTPRequest
         * @return void
         */
        public HTTPResponse respond(HTTPRequest request) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(200);
            String RESPONSE_BODY = '{"Defaults" : {"getElements" : true,"uomCode" : "CM","date" : "20200617","perQuantity" : 1,"currencyCode" : "EUR","orderVolume" : 1.0,"getScales" : false},"PriceEvaluation" : {"evaluationMethod" : "RW Target Price","getElements" : true,"uomCode" : "CM","date" : "20200617","perQuantity" : 1,"currencyCode" : "EUR","orderVolume" : 1.0},"Dimensions" : {"location" : "HAM","customerGRN" : "5128077"},"EvaluationMethodElements" : {"customerSegmentValue" : "Base","locationVolume" : 0,"locationStrategyValue" : "None","tenderVolume" : 2,"priceStartDate" : "20200617","priceEndDate" : "20200621","offerDifferential" : 0,"volumeDifferential" : 2,"creditDays" : "0","salesPricingBasis" : "","supplyPricingBasis" : "","invoiceFrequency" : "","unitRebate" : 0,"density" : "330.215","customerSpecificIntoPlaneCosts" : 0,"creditRatingofCustomer" : "","additionalMarginfromLineItems" : 0,"jVProfitDividend" : 0}}';
            response.setBody(RESPONSE_BODY);
            return response;
        }
    }
    
    /**
     * @description class implementing HttpCalloutMock to mock error service response
     */
    private With Sharing class PricingServiceErrorResponseMock implements HttpCalloutMock {
        /**
         * @description mock response for httprequest for error
         * @param request of type String
         * @return void
         */
        public HTTPResponse respond(HTTPRequest request) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(200);
            String RESPONSE_BODY = '{"Defaults" : {"getElements" : true,"uomCode" : "CM","date" : "20200617","perQuantity" : 1,"currencyCode" : "EUR","orderVolume" : 1.0,"getScales" : false},"PriceEvaluation" : {"evaluationMethod" : "RW Target Price","getElements" : true,"uomCode" : "CM","date" : "20200617","perQuantity" : 1,"currencyCode" : "EUR","orderVolume" : 1.0},"Dimensions" : {"location" : "HAM","customerGRN" : "5128077"},"EvaluationMethodElements" : {"customerSegmentValue" : "Base","locationVolume" : 0,"locationStrategyValue" : "None","tenderVolume" : 2,"priceStartDate" : "20200617","priceEndDate" : "20200621","offerDifferential" : 0,"volumeDifferential" : 2,"creditDays" : "0","salesPricingBasis" : "","supplyPricingBasis" : "","invoiceFrequency" : "","unitRebate" : 0,"density" : "330.215","customerSpecificIntoPlaneCosts" : 0,"creditRatingofCustomer" : "","additionalMarginfromLineItems" : 0,"jVProfitDividend" : 0}}';
            response.setBody(RESPONSE_BODY);
            return response;
        }
    } 
}