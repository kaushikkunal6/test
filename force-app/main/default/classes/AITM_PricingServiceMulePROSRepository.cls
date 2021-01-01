/*************************************************************************
 * @author         Sushant
 * @date           05/May/2020
 * @group          AirBP
 * @description    To get pricing/targetprice information by making a RESTApi callout to Mulesoft to PROS API (external system).
 
*************************************************************************/
public with sharing class AITM_PricingServiceMulePROSRepository {

    private static AITM_PricingServiceMulePROSRepository classinstance;
    private static Map<String, List<AITM_Pricing_Service_Mapping__mdt>> mappingCache;

    /**
     * @description default constructor
     */
    public AITM_PricingServiceMulePROSRepository(){
    }   

    /**
     * @description gets the instance of PricingService
     * @param null
     * @return PricingService class object
     */
    public List<AITM_Pricing_Service_Mapping__mdt> getPricingServiceMappings(String serviceName, Boolean isTargetPrice) {
        if (mappingCache == null) {
            mappingCache = new Map<String, List<AITM_Pricing_Service_Mapping__mdt>>();
        }
        if (!mappingCache.containsKey(serviceName)) { 
           mappingCache.put(serviceName, [SELECT Id, AITM_Field_Name__c,AITM_Required_For_A_Target_Price_Call__c, AITM_Response_Field__c, AITM_Type__c FROM AITM_Pricing_Service_Mapping__mdt WHERE AITM_Service_Name__c = :serviceName]);           
        }
        return mappingCache.get(serviceName);
    }
        
    /**
    * @description retrieves TargetPrice from PROS API call response
    * @param source of type SObject
    * @return SObject
    */
    public SObject retrievePricingInformation(SObject source) {
        SObject result = makePostCallout(source);
        return result;
    }        

    /*************************************************Salesforce to MuleSoft Integration Using RestApi********************************************************/
    private String ResponeFromMuleSoft;
    private String GENERATED_ACCESS_TOKEN;
    private String EMPTY_RESPONSE_MESSAGE = 'No response from pricing service';
    private String SUCCESS_RESPONSE_MESSAGE = 'OK';    
    
    /**
         * @description RestApi Callout method to get the response from MulePros Api
         * @param Sobject source
         * @return string
      */
    public SObject makePostCallout(Sobject source){    
        String LogResult;
        AITM_Http_Request__c reqdat = AITM_Http_Request__c.getValues('MulePros_Request');        
        AITM_Tender_Location_Line_Item__c result = (AITM_Tender_Location_Line_Item__c) source;
        AITM_JsonBodyRequest requestClassinstance = new AITM_JsonBodyRequest();
        String postBody = requestClassinstance.getRequest(result, 'Pricing Information');
        String requestBody = postBody.replace('}{', ',');
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();        
        request.setEndpoint('callout:AITM_MuleProsAPI'+reqdat.AITM_Endpoint_Url__c);
        request.setBody(requestBody);
        request.setTimeout(120000);                          
        request.setHeader('client_id', reqdat.AITM_Client_Id__c);   
        request.setHeader('client_secret', reqdat.AITM_Client_Secret__c);          
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setMethod('POST');  
        
        HTTPResponse response = new HTTPResponse();
        try{
          response = http.send(request); 
          LogResult = AITM_Log.createErrorMessage(String.valueof(request), requestBody, null, 'makePostCallout', String.valueof(result.Id), 'Info', null);  
        }catch (Exception e){            
       	  LogResult = AITM_Log.createErrorMessage(String.valueof(e.getMessage()), requestBody, null, 'makePostCallout', String.valueof(result.Id), 'Error', null);  
        }
        ResponeFromMuleSoft = response.getBody();
        if(ResponeFromMuleSoft != null)
        result = validateMulesoftResponse(ResponeFromMuleSoft, result.Id, LogResult);
        return result;
    }    
    
    /**
         * @description this method is used to validate the response data and errors.
         * @param String response 
         * @param Id sourceId
         * @return Sobject LineItem
      */
     @testVisible private AITM_Tender_Location_Line_Item__c validateMulesoftResponse(String response, Id sourceRecordId, String LogResultId) {
         String errorDetails;         
         AITM_Tender_Location_Line_Item__c result = new AITM_Tender_Location_Line_Item__c(Id = sourceRecordId, AITM_Last_Call_To_Pricing_System__c = System.now(), AITM_Data_Pricing_Calculation_Provided__c = false);
         
             if (String.isEmpty(response)) {
                 AITM_Log.createErrorMessage(null, null, response, 'validateMulesoftResponse', sourceRecordId, 'Error', LogResultId);
                 result.AITM_Pricing_Service_Call_Status__c = EMPTY_RESPONSE_MESSAGE;
             }           
             else if(response.containsIgnoreCase('errMsg')){
                AITM_Log.createErrorMessage(null, null, response, 'validateMulesoftResponse', sourceRecordId, 'Error', LogResultId);
                errorDetails = response.substringBetween('"errMsg": "', '"');            
                result.AITM_Pricing_Service_Call_Status__c = errorDetails;
             }
             else if(response.containsIgnoreCase('message')){
                 String error;   
                 if(response.substringBetween('"message": "', '"') != null){
                     error = response.substringBetween('"message": "', '"'); 
                 }else if(response.substringBetween('"message":"', '"') != null){
                     error = response.substringBetween('"message":"', '"'); 
                 }     
                errorDetails = error; 
                AITM_Log.createErrorMessage(null, null, response, 'validateMulesoftResponse', sourceRecordId, 'Error', LogResultId);                 
                result.AITM_Pricing_Service_Call_Status__c = errorDetails;         
             }            
            else if(response.containsIgnoreCase('error')){
                AITM_Log.createErrorMessage(null, null, response, 'validateMulesoftResponse', sourceRecordId, 'Error', LogResultId); 
                errorDetails = response.substringBetween('"error" : "', '"');  
                result.AITM_Pricing_Service_Call_Status__c = errorDetails;         
             }
             else{
                AITM_Log.createErrorMessage(null, null, response, 'validateMulesoftResponse', sourceRecordId, 'Info', LogResultId); 
                result.AITM_Pricing_Service_Call_Status__c = SUCCESS_RESPONSE_MESSAGE;
                AITM_PricingServiceMulePROSRepository instance = new AITM_PricingServiceMulePROSRepository();
                result = instance.fillMulesoftResultsData(result, response); 
             }
         return result;
     }
    
    /**
         * @description this method is used to map the response data to the tender lineitem object
         * @param String response 
         * @param AITM_Tender_Location_Line_Item__c reresultsponse
         * @return Sobject LineItem
    */
     @testVisible private AITM_Tender_Location_Line_Item__c fillMulesoftResultsData(AITM_Tender_Location_Line_Item__c result, String response) {      
        AITM_PricingServiceMulePROSRepository instance = new AITM_PricingServiceMulePROSRepository();
        Map<String, Object> parseJsonToSObject = (Map<String,Object>)JSON.deserializeUntyped(response);
        Map<String, Object> floorPricesData = (Map<String, Object>)parseJsonToSObject.get('floorPrices');
       
        if(floorPricesData != null){         
                List<Object> elementsData = (List<Object>)floorPricesData.get('elements');
                Map<String, String> mapOfElements = new Map<String, String>();
                
                if(elementsData != null){
                     for (Object item : elementsData) {
                        Map<String, Object> mapOfStringObject = (Map<String, Object>)item;
                        for(String elementName : mapOfStringObject.keyset()){                        
                               mapOfElements.put(elementName.trim(), String.valueof(mapOfStringObject.get(elementName)));
                        }
                     }        
                    if(mapOfElements != null){
                       for (AITM_Pricing_Service_Mapping__mdt pricingMappings : instance.getPricingServiceMappings('PROS', false)) { 
                             for(String elementValue : mapOfElements.keyset()){
                                if(String.isNotBlank(elementValue) && elementValue.equalsIgnoreCase(pricingMappings.AITM_Response_Field__c)){                            
                                    if (pricingMappings.AITM_Type__c == 'Number' && mapOfElements.get(elementValue) != null) {
                                        result.put(pricingMappings.AITM_Field_Name__c, Decimal.valueOf(mapOfElements.get(elementValue)));
                                    }
                                    else{
                                        result.put(pricingMappings.AITM_Field_Name__c, String.valueOf(mapOfElements.get(elementValue)));                              
                                    }
                                }
                             }               
                       }  
                    } 
                }
        }    
        return result; 
      }    
}