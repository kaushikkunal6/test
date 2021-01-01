/***************************************************************
 * @author           Neeti 
 * @date             01/July/2020
 * @group            AirBP
 * @description      Test class for AITM_AirBPCountryAPIBatch

 * history
 * 16/June/2020     Neeti      Created 
 **********************************************************/
@isTest
private with sharing class AITM_Schedule_LocationTest {
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
     /**
     * @description test method for test class
     * @param  null
     * @return null
     */	 
     @isTest
    public static void testAITM_Schedule_LocationTest(){
        Test.startTest();        
        string JOBID = System.schedule('BP_Batch', CRON_EXP, new AITM_Schedule_NonBPLocationBatch());
        string JOBID1 = System.schedule('Non_BP_Batch', CRON_EXP, new AITM_Schedule_BPLocationBatch());
        Test.stopTest();
        List <AITM_API_Modified_Country_List__mdt> countryList = ([SELECT Id, AITM_Country_Id__c, AITM_LastModifiedDate__c, AITM_Record_Updated__c FROM AITM_API_Modified_Country_List__mdt WHERE AITM_Country_Id__c != 'NonAirBPOp' AND AITM_Record_Updated__c = True ORDER BY AITM_LastModifiedDate__c DESC LIMIT 1]);
        System.assertEquals(1,countryList.size(),'The size of the countryList is 1');
    }

}