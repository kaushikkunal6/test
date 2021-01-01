/***************************************************************
 * @author           Saravan
 * @date             21/Aug/2020
 * @group            AirBP
 * @description      Class for Mulesoft Location API Callout

 * history
 * 21/Aug/2020  	 Saravan      Created 
 **********************************************************/

public with sharing class AITM_Location_API_Callouts {
  static HTTPResponse hResp =new HTTPResponse();
  static HttpRequest req = new HttpRequest();
  static Http h = new Http();
  static String accsToken = '';
  static Map<string,AITM_Rest_Call_Attribute__mdt> restCallMap = new  Map<string,AITM_Rest_Call_Attribute__mdt>();
  
      /**
* @description constructor
* @param null  
* @return null
*/
    
   public AITM_Location_API_Callouts(){
     for(AITM_Rest_Call_Attribute__mdt restCallItem:[SELECT AITM_client_id__c,AITM_client_secret__c,AITM_Content_Type__c,AITM_Grant_type__c,AITM_requested_token_use__c,AITM_Resource__c,AITM_scope__c,AITM_SetMethod__c,DeveloperName,AITM_EndPoint__c,Label,Language,MasterLabel FROM AITM_Rest_Call_Attribute__mdt limit 1000]){
       restCallMap.put(restCallItem.Label,restCallItem);
     }
    
    }
    
      /**
* @description Method to send API Request
* @param Matadata Rest Call Attribute and Filter Param  
* @return HttpRequest
*/
  
    private HttpRequest createRequest(AITM_Rest_Call_Attribute__mdt param,String queryParam){
     
     HttpRequest  request = new HttpRequest();
     request.setMethod(param.AITM_SetMethod__c);
     request.setHeader('Content-Type',param.AITM_Content_Type__c);
    
     if(param.Label=='callout:Mule_Location_MDM')
     {  
      request.setEndpoint(param.AITM_EndPoint__c);   
      request.setBody('grant_type='+param.AITM_Grant_type__c+'&client_id='+param.AITM_client_id__c+'&client_secret='+param.AITM_client_secret__c+'&requested_token_use='+param.AITM_requested_token_use__c+'&resource='+param.AITM_Resource__c+' &scope='+param.AITM_scope__c);
     }
     else 
     {      
      request.setEndpoint('callout:Mule_Location_MDM'+param.AITM_EndPoint__c+queryParam);     
      request.setHeader('client_id',param.AITM_client_id__c);
      request.setHeader('client_secret',param.AITM_client_secret__c);       
     }
    
     return request;
    }
    
     /**
* @description Method to call Coutry List API
* @param Filter Param  
* @return HttpResponse
*/
    
    public HttpResponse getCountryListCallout(String queryParam) {
       AITM_Rest_Call_Attribute__mdt param = new AITM_Rest_Call_Attribute__mdt();
       param = restCallMap.get('callout:Mule_Country_API');
       
       req = createRequest(param,queryParam);     
       req.setTimeout(120000);
       
        
       try {
               hResp = h.send(req);                       
            } 
     catch(System.CalloutException e) {
                System.debug('@@@@'+e);
            }
       
      return hResp;
    }
    
    /**
* @description Method to call Modified Country API
* @param Filter Param  
* @return HttpResponse
*/
  
    public HttpResponse getCountryModifiedCallout(String queryParam) {
       AITM_Rest_Call_Attribute__mdt param = new AITM_Rest_Call_Attribute__mdt();
       param = restCallMap.get('callout:Mule_Country_Modified');
       req = createRequest(param,queryParam);
       req.setTimeout(120000);
       
       try {
                hResp = h.send(req);
                     
            } 
     catch(System.CalloutException e) {
                System.debug('@@@@'+e);
            }
       
      return hResp;
    }
    
     /**
* @description Method to call Modified Country API
* @param Filter Param  
* @return List of Countries
*/
    
    public List<String> getCountryModifiedCalloutOld(String queryParam) {
       AITM_Rest_Call_Attribute__mdt param = new AITM_Rest_Call_Attribute__mdt();
       param = restCallMap.get('callout:Mule_Country_Modified');
       req = createRequest(param,queryParam);
       req.setTimeout(120000);       
        List<String> allCountryIds = new List<String>();       
       try {
                hResp = h.send(req);                
                String str = hResp.getBody();
                str=str.replace('[', '');
                str=str.replace(']','');
                allCountryIds =  str.split(',');                    
                 
            } 
     catch(System.CalloutException e) {
                System.debug('@@@@'+e);
            }
       
            return allCountryIds;
    }
    
    /**
* @description Method to call NonBPOperatedLocation API
* @param Filter Param  
* @return List of Countries
*/
    
    public HttpResponse getNonBPOperatedLocationCallout(String queryParam) {
       AITM_Rest_Call_Attribute__mdt param = new AITM_Rest_Call_Attribute__mdt();
       param = restCallMap.get('callout:Mule_Non_BP_Operated_API');       
       req = createRequest(param,queryParam);
       req.setTimeout(120000);       
       try {
               hResp = h.send(req);
                   
            } 
     catch(System.CalloutException e) {
                System.debug('@@@@'+e);
            }
       
      return hResp;
    }
  
}