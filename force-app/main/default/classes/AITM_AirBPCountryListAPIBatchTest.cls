/***************************************************************
 * @author           Saravana Surendran
 * @date             16/June/2020
 * @group            AirBP
 * @description      Test class for AITM_AirBPCoutryListAPIBatch

 * history
 * 16/June/2020  	 Saravana Surendran      Created 
 **********************************************************/
@isTest 
private with sharing class AITM_AirBPCountryListAPIBatchTest {
    
    /**
     * @description method to setup test data
     * @param  null
     * @return null
     */	 
    
    @TestSetup
    public static void setupData(){
        Set<String> countryId = new Set<String>();
        Set<String> updateCountryId = new Set<String>();
        Boolean updateFlag = FALSE;
        countryId.add('10490');
        updateCountryId.add('10591');
        AITM_MetaDataUtility mu = new AITM_MetaDataUtility();
        mu.upsertMetadata(countryId, updateCountryId, updateFlag);
               
    }
    
    /**
     * @description test method for batch
     * @param  null
     * @return null
     */	 
    
    @isTest
    public static void testAirBPCountryListAPIBatch(){
        setupData();
        String countryId = '10490';
        
        Test.setMock(HttpCalloutMock.class, new AITM_AirBPCountryListAPIBatchSuccessResponseMock());
        AITM_AirBPCountryListAPIBatch bp = new AITM_AirBPCountryListAPIBatch();
        
        Test.startTest();
            Database.executeBatch(bp);            
        Test.stopTest();     
      	       
        System.assertEquals('10490', countryId);
        
    }
    
    /**
     * @description mock class for test class
     * @param  null
     * @return null
     */	 
    public with sharing class AITM_AirBPCountryListAPIBatchSuccessResponseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String RESPONSE_BODY = '[10490,10640,10705,10557,10732,10686]';
            response.setBody(RESPONSE_BODY);
            response.setStatusCode(200);
            system.assert(response.getStatusCode() == 200);
            return response; 
        } 
    }

}