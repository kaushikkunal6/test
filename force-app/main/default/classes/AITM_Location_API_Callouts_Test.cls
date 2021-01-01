/***************************************************************
 * @author           Neeti
 * @date             21/Aug/2020
 * @group            AirBP
 * @description      Test class for AITM_Location_API_Callout_Test

 * history
 * 21/Aug/2020  	 Neeti      Created 
 **********************************************************/
@isTest
public with sharing class AITM_Location_API_Callouts_Test {
    
     /**
     * @description test method for Location API Callouts
     * @param  null
     * @return null
     */	 
 
      @isTest
    public static void testCalloutBatch(){
        Test.setMock(HttpCalloutMock.class, new CalloutSuccessResponseMock());
        AITM_Location_API_Callouts nbp = new AITM_Location_API_Callouts();
        
        Test.startTest();
           HttpResponse hr = nbp.getCountryListCallout(null);    
           hr=nbp.getCountryModifiedCallout(null);
           List<String> ls=nbp.getCountryModifiedCalloutOld(null);
           hr= nbp.getNonBPOperatedLocationCallout(null);
           system.assert(hr.getStatusCode() == 200);
        Test.stopTest();
        
    }
    
      // mockClass for test class
      /**
     * @description mockClass for test class
     * @param  null
     * @return null
     */	 
    public with sharing class CalloutSuccessResponseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String RESPONSE_BODY = 'Id';
            response.setBody(RESPONSE_BODY);
            response.setStatusCode(200);
            system.assert(response.getStatusCode() == 200);
            return response; 
        } 
    }  
}