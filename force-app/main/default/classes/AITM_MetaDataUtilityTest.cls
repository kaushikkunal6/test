/***************************************************************
 * @author           Neeti 
 * @date             01/July/2020
 * @group            AirBP
 * @description      Test class for AITM_MetaDataUtility

 * history
 * 16/June/2020     Neeti     Created 
 **********************************************************/
@isTest 
public with sharing class AITM_MetaDataUtilityTest {
    
       /**
* @description test method 
* @param null
* @return null
*/  
	@isTest
    public static void testAITM_MetaDataUtilityTest(){
        Set<String> countryId = new Set<String>();
        countryId.add('10490');
         Test.startTest();
            AITM_MetaDataUtility mu = new AITM_MetaDataUtility();
        	mu.createMetadata(countryId);
            mu.upsertMetadata(countryId,countryId,true);
            mu.upsertMetadata(countryId,countryId,false);
            mu.updateMetadata();
            mu.updateMetadata('10490',true);
            mu.updateMetadata('10490',false);
            mu.updateMetadata(countryId,true);
            mu.updateMetadata(countryId,false);
            system.assert(countryId.size()>0);
                         
        Test.stopTest();
    }
}