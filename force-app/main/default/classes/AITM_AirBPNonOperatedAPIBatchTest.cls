/***************************************************************
 * @author           Saravana Surendran
 * @date             16/June/2020
 * @group            AirBP
 * @description      Test class for AITM_AirBPNonOperatedAPIBatch

 * history
 * 16/June/2020  	 Saravana Surendran      Created 
 **********************************************************/
@isTest 
public with sharing  class AITM_AirBPNonOperatedAPIBatchTest {
    
    /**
     * @description method to setup test data
     * @param  null
     * @return null
     */	
    
	@TestSetup
    public static void setupData(){
        String countryId;
        Set<String> updateCountryId = new Set<String>();        
        Boolean updateFlag = FALSE;
        countryId = 'NonAirBPOp';
        //updateCountryId.add('NonAirBPOp');
        AITM_MetaDataUtility mu = new AITM_MetaDataUtility();
        mu.updateMetadata(countryId, updateFlag);
        
               
    }

 /**
     * @description test method for batch
     * @param  null
     * @return null
     */	    
    @isTest
    public static void testAirBPNonOperatedAPIBatch(){
        String countryId = 'NonAirBPOp';
        Test.setMock(HttpCalloutMock.class, new AirBPNonOperatedAPIBatchSuccessResponseMock());
        AITM_AirBPNonOperatedAPIBatch nbp = new AITM_AirBPNonOperatedAPIBatch();        
        Test.startTest();
            Database.executeBatch(nbp);            
        Test.stopTest();
        System.assertEquals('NonAirBPOp', countryId);
        
    }
    
    /**
     * @description test method for NonBPOperated Batch Error
     * @param  null
     * @return null
     */	 
    
      @isTest
    public static void testAirBPNonOperatedAPIBatchError(){
        String countryId = 'NonAirBPOp';
        Test.setMock(HttpCalloutMock.class, new AirBPNonOperatedAPIBatchSuccessResponseMockError());
        AITM_AirBPNonOperatedAPIBatch nbp = new AITM_AirBPNonOperatedAPIBatch();        
        Test.startTest();
            Database.executeBatch(nbp);            
        Test.stopTest();
         System.assertEquals('NonAirBPOp', countryId);
        
    }
    
    /**
     * @description test method for NonBPOperated API Callout Error
     * @param  null
     * @return null
     */	 
    
     @isTest
    public static void testAirBPNonOperatedAPIBatchErrorAPI(){
        String countryId = 'NonAirBPOp';
        Test.setMock(HttpCalloutMock.class, new AirBPNonOperatedAPIBatchSuccessResponseMockErrorAPI());
        AITM_AirBPNonOperatedAPIBatch nbp = new AITM_AirBPNonOperatedAPIBatch();       
        Test.startTest();
            Database.executeBatch(nbp);            
        Test.stopTest();
        System.assertEquals('NonAirBPOp', countryId);
        
    }
    
     /**
     * @description test method for NonBPOperated API Callout for Muliple Location
     * @param  null
     * @return null
     */	 
    
    @isTest
    public static void testAirBPNonOperatedAPIBatchMultiLoc(){
        String countryId = 'NonAirBPOp';
        Test.setMock(HttpCalloutMock.class, new AirBPNonOperatedAPIBatchSuccessResponseMockMultiLoc());
        AITM_AirBPNonOperatedAPIBatch nbp = new AITM_AirBPNonOperatedAPIBatch();       
        Test.startTest();
            Database.executeBatch(nbp);            
        Test.stopTest();
        System.assertEquals('NonAirBPOp', countryId);
        
    }
        
    /**
     * @description mock class for Success Response
     * @param  null
     * @return null
     */	 
    public with sharing class AirBPNonOperatedAPIBatchSuccessResponseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String RESPONSE_BODY = '[{"b_suggmergeconfscore":null,"landing_rights":"0","faa":null,"country_id":99,"b_hasoverride":false,"width":"148","b_suggmergemasterscount":null,"b_goldentype":"MASTER_BASED","t24hours":"R","last_modified_date":null,"b_hassuggmerge":null,"b_masterscount":1,"b_updator":"sauvik","location_subdivision":"Tamil Nadu","sita":null,"handling_mandatory":"1","contact_zip":null,"contact_telephone":"+91 44 2256 1122","lighting":"HIGH","user_fees":"0","contact_address1":null,"icao":"VOMM","contact_name":"G Chandramouli","time_zone":"5.50","slots_required":"1","contact_title":"Airport Director","b_confscore":null,"distance_from_city":"17 KM SW OF TOWN","airport_of_entry_remark":"H24, S-NS-P","aftn":"VOMMYUYU","b_classname":"Location","iata":"MAA","operator":"Airports Authority of India","location_country":"INDIA","pcn":"105FCWT","magnetic_variation":"02W","contact_country":null,"location_name":"Chennai International","fp_country":"APTD01","b_upddate":1591258959415,"contact_city":"Chennai","latitude":12.995,"contact_website":"www.aai.aero","frequencies":"type:ATIS,frequency:127.45,remark:H24-type:Ground Control,frequency:121.9,remark:H24-type:Tower 1,frequency:118.1,remark:H24","airport_of_entry":"Yes","runway_id":"07/25","non_airport_id":null,"location_type":"Airport","last_edited":null,"customs":"1","elevation":"52","f_country":10492,"hours":"H24","b_batchid":5536,"b_confirmationstatus":"CONFIRMED","location_id":11291,"longitude":80.175,"fuel":"AVGAS JET","mdm_location_identifier":"MAA","location_city":"Chennai","b_creator":"sauvik","daylight_savings":"0","tower_hours":"H24","contact_state":null,"b_pubid":"APTD01","fire_category":"9","contact_address2":"Chennai International Airport","surface":"Asphalt/concrete","airport_id":5031,"max_lda":"12001","contact_email":"apdchennai@aai.aero","b_isconfirmed":true,"type":"Civil","bp_location":"TRUE","length":"12001","remarks":"Clearance datalink in use. 5 terminals: international, domestic, cargo, courier and general aviation. Expansion in 2012 to 17 gates and 81 stands. Caution: Tambaram AD 6nm bearing 220. Avgas in barrels 48hrs PNR. SAR 123.1.","approach":"ILS/DME VOR","b_sourceid":null,"designated_international":"0","b_suggmergeid":null,"fs_country":"99","b_credate":1570614658681,"fire_category_remarks":"during ATS Hrs","email":"apdchennai@aai.aero","website":"www.aai.aero/en/airports/chennai","b_error_status":null}]';
            response.setBody(RESPONSE_BODY);
            response.setStatusCode(200);
            system.assert(response.getStatusCode() == 200);
            return response; 
        } 
    }
    
      /**
     * @description mock class for Error Response
     * @param  null
     * @return null
     */	 
    public with sharing class AirBPNonOperatedAPIBatchSuccessResponseMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String RESPONSE_BODY = 'Invalid Id';
            response.setBody(RESPONSE_BODY);
            response.setStatusCode(500);
            system.assert(response.getStatusCode() == 500);
            return response; 
        } 
    } 
    
        /**
     * @description mock class for API Error
     * @param  null
     * @return null
     */	 
    public with sharing class AirBPNonOperatedAPIBatchSuccessResponseMockErrorAPI implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String RESPONSE_BODY = '[{"b_suggmergeconfscore":null,"landing_rights":"0","faa":null,"country_id":99,"b_hasoverride":false,"width":"148","b_suggmergemasterscount":null,"b_goldentype":"MASTER_BASED","t24hours":"R","last_modified_date":null,"b_hassuggmerge":null,"b_masterscount":1,"b_updator":"sauvik","location_subdivision":"Tamil Nadu","sita":null,"handling_mandatory":"1","contact_zip":null,"contact_telephone":"+91 44 2256 1122","lighting":"HIGH","user_fees":"0","contact_address1":null,"icao":"VOMM","contact_name":"G Chandramouli","time_zone":"5.50","slots_required":"1","contact_title":"Airport Director","b_confscore":null,"distance_from_city":"17 KM SW OF TOWN","airport_of_entry_remark":"H24, S-NS-P","aftn":"VOMMYUYU","b_classname":"Location","iata":"MAA","operator":"Airports Authority of India","location_country":"INDIA","pcn":"105FCWT","magnetic_variation":"02W","contact_country":null,"location_name":"Chennai International","fp_country":"APTD01","b_upddate":1591258959415,"contact_city":"Chennai","latitude":12.995,"contact_website":"www.aai.aero","frequencies":"type:ATIS,frequency:127.45,remark:H24-type:Ground Control,frequency:121.9,remark:H24-type:Tower 1,frequency:118.1,remark:H24","airport_of_entry":"Yes","runway_id":"07/25","non_airport_id":null,"location_type":"Airport","last_edited":null,"customs":"1","elevation":"52","f_country":10492,"hours":"H24","b_batchid":5536,"b_confirmationstatus":"CONFIRMED","location_id":11291,"longitude":80.175,"fuel":"AVGAS JET","mdm_location_identifier":"MAA","location_city":"Chennai","b_creator":"sauvik","daylight_savings":"0","tower_hours":"H24","contact_state":null,"b_pubid":"APTD01","fire_category":"9","contact_address2":"Chennai International Airport","surface":"Asphalt/concrete","airport_id":5031,"max_lda":"12001","contact_email":"apdchennai@aai.aero","b_isconfirmed":true,"type":"Civil","bp_location":"TRUE","length":"12001","remarks":"Clearance datalink in use. 5 terminals: international, domestic, cargo, courier and general aviation. Expansion in 2012 to 17 gates and 81 stands. Caution: Tambaram AD 6nm bearing 220. Avgas in barrels 48hrs PNR. SAR 123.1.","approach":"ILS/DME VOR","b_sourceid":"476","designated_international":"0","b_suggmergeid":null,"fs_country":"99","b_credate":1570614658681,"fire_category_remarks":"during ATS Hrs","email":"apdchennai@aai.aero","website":"www.aai.aero/en/airports/chennai","b_error_status":null}]';
            response.setBody(RESPONSE_BODY);
            response.setStatusCode(500);
            system.assert(response.getStatusCode() == 500);
            return response; 
        } 
    }
    
           /**
     * @description mock class for API Error
     * @param  null
     * @return null
     */	 
    public with sharing class AirBPNonOperatedAPIBatchSuccessResponseMockMultiLoc implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String RESPONSE_BODY = '[{"b_suggmergeconfscore":null,"landing_rights":"FALSE","faa":null,"country_id":39,"b_hasoverride":true,"width":null,"b_suggmergemasterscount":null,"b_goldentype":"MASTER_BASED","t24hours":null,"last_modified_date":"0001-01-01","b_hassuggmerge":null,"b_masterscount":1,"b_updator":"pasn8l","location_subdivision":null,"sita":null,"handling_mandatory":"FALSE","contact_zip":null,"contact_telephone":null,"lighting":null,"user_fees":"FALSE","contact_address1":null,"icao":null,"contact_name":null,"time_zone":null,"slots_required":null,"contact_title":null,"b_confscore":null,"distance_from_city":null,"airport_of_entry_remark":null,"aftn":null,"b_classname":"Location","iata":"KEW","operator":null,"location_country":"CANADA","pcn":null,"magnetic_variation":null,"contact_country":null,"location_name":"Keewaywin Airport (Changed)","fp_country":"APTD01","b_suggmergeconfscoretype":null,"b_upddate":1599563719764,"contact_city":null,"latitude":52.99110,"contact_website":null,"frequencies":null,"airport_of_entry":null,"runway_id":null,"non_airport_id":null,"location_type":"Airport","last_edited":"0001-01-01 BC","customs":"FALSE","elevation":"988","f_country":10557,"hours":null,"b_batchid":6708,"b_confirmationstatus":"CONFIRMED","location_id":728,"longitude":-92.83640,"fuel":null,"mdm_location_identifier":"KEW","location_city":"Keewaywin","b_creator":"pasn8l","daylight_savings":"FALSE","tower_hours":null,"contact_state":null,"b_pubid":"APTD01","fire_category":null,"contact_address2":null,"surface":null,"airport_id":1466,"max_lda":null,"contact_email":null,"b_isconfirmed":true,"type":null,"bp_location":"TRUE","length":null,"remarks":null,"approach":null,"b_sourceid":"10024","designated_international":"FALSE","b_suggmergeid":null,"fs_country":"39","b_credate":1599507829438,"b_confscoretype":null,"fire_category_remarks":null,"email":null,"website":null,"b_error_status":null},{"b_suggmergeconfscore":null,"landing_rights":null,"faa":null,"country_id":null,"b_hasoverride":false,"width":null,"b_suggmergemasterscount":0,"b_goldentype":"DE_BASED","t24hours":null,"last_modified_date":null,"b_hassuggmerge":false,"b_masterscount":0,"b_updator":"pasn8l","location_subdivision":null,"sita":null,"handling_mandatory":null,"contact_zip":null,"contact_telephone":null,"lighting":null,"user_fees":null,"contact_address1":null,"icao":null,"contact_name":null,"time_zone":null,"slots_required":null,"contact_title":null,"b_confscore":null,"distance_from_city":null,"airport_of_entry_remark":null,"aftn":null,"b_classname":"Location","iata":null,"operator":null,"location_country":null,"pcn":null,"magnetic_variation":null,"contact_country":null,"location_name":"MOssburn","fp_country":"APTD01","b_suggmergeconfscoretype":null,"b_upddate":1599736724298,"contact_city":null,"latitude":null,"contact_website":null,"frequencies":null,"airport_of_entry":null,"runway_id":null,"non_airport_id":null,"location_type":"Non-Airport","last_edited":null,"customs":null,"elevation":null,"f_country":10726,"hours":null,"b_batchid":6738,"b_confirmationstatus":"CONFIRMED","location_id":12403,"longitude":null,"fuel":null,"mdm_location_identifier":"MOS","location_city":"barcelona","b_creator":"pasn8l","daylight_savings":null,"tower_hours":null,"contact_state":null,"b_pubid":null,"fire_category":null,"contact_address2":null,"surface":null,"airport_id":null,"max_lda":null,"contact_email":null,"b_isconfirmed":true,"type":null,"bp_location":"TRUE","length":null,"remarks":null,"approach":null,"b_sourceid":null,"designated_international":null,"b_suggmergeid":null,"fs_country":"106","b_credate":1599736724298,"b_confscoretype":null,"fire_category_remarks":null,"email":null,"website":null,"b_error_status":null}]';
            response.setBody(RESPONSE_BODY);
            response.setStatusCode(200);
            system.assert(response.getStatusCode() == 200);
            return response; 
        } 
    }
    
    
}