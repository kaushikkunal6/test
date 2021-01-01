/**************************************************************************
 * @author           Usha
 * @date             20/November/2020
 * @group            AirBP
 * @description      Test class for AITM_customLookupController
 *******************************************************************/
@isTest 
Public with sharing class AITM_customLookupControllerTest {
    
    public static List<AITM_Pricing_Basis__c> pricingBasislst = new List<AITM_Pricing_Basis__c>();
     @isTest 
     Public static List<AITM_Pricing_Basis__c> createPricingBasis(){
         for (Integer i = 1; i <= 250; i++){
          AITM_Pricing_Basis__c  pricingBasis =  new AITM_Pricing_Basis__c (
                Name = 'P008' + i,
                AITM_Description__c = 'Barges FOB Rotterdam High Prior Month WD',
                AITM_Currency__c = 'USD',
                AITM_Unit_Of_Measure__c = 'USG'
                );
             pricingBasislst.add(pricingBasis);
         }
          INSERT pricingBasislst;
         AITM_customLookupController.fetchLookUpValues('P00','AITM_Pricing_Basis__c');
         return pricingBasislst;
        }
    
}