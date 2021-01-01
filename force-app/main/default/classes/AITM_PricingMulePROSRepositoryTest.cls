/***********************************************************************************************
 * @author           Sushant
 * @date             16/June/2020
 * @group            AirBP
 * @description      Test class for AITM_PricingMulePROSRepository
 *************************************************************************************/
@isTest  
private with sharing class AITM_PricingMulePROSRepositoryTest{    
    
    private static Integer ITEMS_SIZE = 2;
    public static List<Account> accounts;
    public static List<AITM_Tender_Account__c> tenderAccounts;
    public static List<AITM_Location__c> locations;
    public static List<AITM_Tender_Location__c> tenderLocations;
    public static AITM_Tender__c tender;
    public static AITM_Tender_Location_Line_Item__c lineItem;
    public static AITM_Log__c Insertlog;
    public static Integer RESPONSE_CODE = 200;
    public static String RESPONSE_HEADER_KEY = 'Content-Type';
    public static String RESPONSE_HEADER_VALUE = 'application/json';
    public static AITM_Http_Request__c setting; 
    
    /**
     * @description tests to validate the retrievepricinginformation method.
     * @param  null
     * @return void
     */
    @isTest
    private static void testvalidatetenderlocationlineitemretrievePricingInformation() {  
       AITM_PricingMuleProsRepositoryTestSetup testSetup = new AITM_PricingMuleProsRepositoryTestSetup().generateData();    
       Test.startTest();
           Test.setMock(HttpCalloutMock.class, new PricingServiceSuccessResponseMock());
           AITM_PricingServiceMulePROSRepository pricingService = new AITM_PricingServiceMulePROSRepository();
           pricingService.getPricingServiceMappings('PROS', false);    
           AITM_Tender_Location_Line_Item__c result = (AITM_Tender_Location_Line_Item__c) pricingService.retrievePricingInformation(lineItem);        
       Test.stopTest();
       system.assertNotEquals(null, result);
    }
    
     /**
     * @description tests to verify the pricing values in case of null response
     * @param  null
     * @return void
     */
    @isTest
    private static void testValidateMulesoftResponseHavingEmptyRespone() {  
       AITM_PricingMuleProsRepositoryTestSetup testSetup = new AITM_PricingMuleProsRepositoryTestSetup().generateData();     
       Test.startTest();
           AITM_PricingServiceMulePROSRepository pricingService = new AITM_PricingServiceMulePROSRepository();
           AITM_Tender_Location_Line_Item__c item = pricingService.validateMulesoftResponse('', lineItem.Id,Insertlog.Id);    
       Test.stopTest();
       system.assertNotEquals(null, item); 
    }
    
     /**
     * @description tests to verify the pricing values in case of service failure
     * @param  null
     * @return void
     */
    @isTest
    private static void testValidateMulesoftResponseHavingErrMsgRespone() {  
       AITM_PricingMuleProsRepositoryTestSetup testSetup = new AITM_PricingMuleProsRepositoryTestSetup().generateData();      
       Test.startTest();
           AITM_PricingServiceMulePROSRepository pricingService = new AITM_PricingServiceMulePROSRepository();
           AITM_Tender_Location_Line_Item__c item = pricingService.validateMulesoftResponse('errMsg', lineItem.Id,Insertlog.Id);    
       Test.stopTest();
       system.assertNotEquals('errMsg', item.AITM_Pricing_Service_Call_Status__c); 
    }
    
     /**
     * @description tests to verify the pricing values in case of service failure
     * @param  null
     * @return void
     */
    @isTest
    private static void testValidateMulesoftResponseHavingMessageRespone() {  
       AITM_PricingMuleProsRepositoryTestSetup testSetup = new AITM_PricingMuleProsRepositoryTestSetup().generateData();     
       Test.startTest();
           AITM_PricingServiceMulePROSRepository pricingService = new AITM_PricingServiceMulePROSRepository();
           AITM_Tender_Location_Line_Item__c item = pricingService.validateMulesoftResponse('message', lineItem.Id,Insertlog.Id);    
       Test.stopTest();
       system.assertNotEquals('OK', item.AITM_Pricing_Service_Call_Status__c); 
    }
    
     /**
     * @description tests to verify the pricing values in case of service failure
     * @param  null
     * @return void
     */
    @isTest
    private static void testValidateMulesoftResponseHavingErrorRespone() {  
       AITM_PricingMuleProsRepositoryTestSetup testSetup = new AITM_PricingMuleProsRepositoryTestSetup().generateData();
       Test.startTest();
           AITM_PricingServiceMulePROSRepository pricingService = new AITM_PricingServiceMulePROSRepository();
           AITM_Tender_Location_Line_Item__c item = pricingService.validateMulesoftResponse('error', lineItem.Id,Insertlog.Id);    
       Test.stopTest();
       system.assertNotEquals(null, item); 
    }
        
   /**
     * @description class implementing HttpCalloutMock to mock error service response
   */
    public with sharing class PricingServiceSuccessResponseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String RESPONSE_BODY = '{"Defaults" : {"getElements" : true,"uomCode" : "CM","date" : "20200617","perQuantity" : 1,"currencyCode" : "EUR","orderVolume" : 1.0,"getScales" : false},"PriceEvaluation" : {"evaluationMethod" : "RW Target Price","getElements" : true,"uomCode" : "CM","date" : "20200617","perQuantity" : 1,"currencyCode" : "EUR","orderVolume" : 1.0},"Dimensions" : {"location" : "HAM","customerGRN" : "5128077"},"EvaluationMethodElements" : {"customerSegmentValue" : "Base","locationVolume" : 0,"locationStrategyValue" : "None","tenderVolume" : 2,"priceStartDate" : "20200617","priceEndDate" : "20200621","offerDifferential" : 0,"volumeDifferential" : 2,"creditDays" : "0","salesPricingBasis" : "","supplyPricingBasis" : "","invoiceFrequency" : "","unitRebate" : 0,"density" : "330.215","customerSpecificIntoPlaneCosts" : 0,"creditRatingofCustomer" : "","additionalMarginfromLineItems" : 0,"jVProfitDividend" : 0}}';
            response.setBody(RESPONSE_BODY);
            response.setStatusCode(200);
            return response; 
        } 
    }
    
   /**
     * @description class to create test data extending AITM_TestSetup
   */  
     private with sharing class AITM_PricingMuleProsRepositoryTestSetup extends AITM_TestSetup {
        
       public AITM_PricingMuleProsRepositoryTestSetup generateData() { 
            setting = new AITM_Http_Request__c();
            setting.Name = 'MulePros_Request';
            setting.AITM_Client_Id__c = 'clientId';
            setting.AITM_Client_Secret__c = 'sectetId';
            insert setting;
    
            AITM_TestSetup setup = new AITM_TestSetup();
            accounts = setup.createAccounts(ITEMS_SIZE);
            AITM_Contracting_Entity__c contractingObj = new AITM_Contracting_Entity__c();
            contractingObj.Name = 'test';
            insert contractingObj;
            
            for(Account acc : accounts){
                acc.AITM_GRN__c = 'test';
                acc.AITM_Credit_Rating__c = '1'; 
                acc.AITM_Customer_Segment__c = 'Base';
                acc.Alternate_Customer_Name__c = 'test'; 
                acc.AITM_Customer_Segment__c = 'IATA';
                acc.AITM_Contracting_Entity__c = contractingObj.Id;
                acc.AITM_Exchange_Rate__c = 'IATA';
                acc.Credit_Days__c = '2';
                acc.AITM_Credit_Days1__c = '2';
                acc.AITM_Credit_Days__c =  0.2;
                acc.AITM_Invoice_Frequency__c = 'Daily';
            }
            insert accounts;
    
            locations = setup.createLocations(ITEMS_SIZE);
            for(AITM_Location__c location : locations){
                location.AITM_Country__c = 'Spain';
                location.AITM_IATA__c = 'test';
            }
            insert locations;
    
            tender = setup.createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            tender.AITM_Stage__c = 'Awaiting Price';
            insert tender;         
            
            AITM_Pricing_Basis__c pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test');
            insert pricingBasis;
                
            lineItem = new AITM_Tender_Location_Line_Item__c();
            lineItem.AITM_Pricing_Basis__c = pricingBasis.Id;
            lineItem.AITM_Delivery_Point__c = '1';
            lineItem.AITM_Account__c = accounts[0].id;
            lineItem.AITM_Tender__c = tender.id;
            lineItem.AITM_Location__c= locations[0].id;
            lineItem.AITM_Currency__c = 'USD';
            lineItem.AITM_Unit_Of_Measure__c = 'LT'; 
            lineItem.AITM_Offered_Differential__c = 1.0;  
            lineItem.AITM_Start_Date__c = Date.today();
            lineItem.AITM_End_Date__c = Date.today() + 1;
            lineItem.AITM_Volume__c = 12;
            lineItem.AITM_Rebate__c = 10;
            lineItem.AITM_Density__c =  '10';
            lineItem.AITM_Currency__c = 'EUR';
            lineItem.AITM_Credit_Days__c = 'PP';
            lineItem.AITM_Location_Size__c = 23;                                                                                                                                                                                                                                                           
            lineItem.AITM_Offered_Volume__c = 10;
            lineItem.AITM_Unit_Of_Measure__c = 'USG';
            lineItem.AITM_JV_Profit_Dividend__c = 40; 
            lineItem.AITM_Invoice_Frequency__c = 'Weekly';
            lineItem.AITM_Sales_Pricing_Period__c = 'CW'; 
            lineItem.AITM_Location_Strategy__c = 'Grow'; 
            lineItem.AITM_Replenishment_Pricing_Period__c = 'M-1';
            lineItem.AITM_Additional_Margin_From_Line_Items__c = 21;
            lineItem.AITM_Customer_Specific_Into_Plane_Costs__c = 20;
            insert lineItem;  
            
            Insertlog = new AITM_Log__c(
                AITM_Description__c = 'errorMessage',
                AITM_Method_Name__c = 'methodName',
                AITM_SourceRecordID__c = lineItem.Id,
                AITM_Error_Type__c = 'errorType',
                AITM_Request_Body__c = 'requestBody'                      
            );
            insert Insertlog;
            return null;
       } 
     }    
           
}