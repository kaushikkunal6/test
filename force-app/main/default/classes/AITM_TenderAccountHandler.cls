/*************************************************************************
* @author         Shweta Aggarwal
* @Luke Date      31/March/2020
* @group          AirBP
* @description    Trigger handler for Tender Account Objet

* * history
*31/March/2020  	 Shweta      Created
*************************************************************************/


public with sharing class AITM_TenderAccountHandler extends BPG_Trigger_Handler_Utilities {
    
 /****************************************************************************************************
  Before Insert Event Handler
 ****************************************************************************************************/
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'AITM_Tender_Account__c') AITM_Tender_Account_Helper.checkForDuplicates((List<AITM_Tender_Account__c>) n);
    if (sot.getDescribe().getName() == 'AITM_Tender_Account__c') AITM_Tender_Account_Helper.populateBankAccount((List<AITM_Tender_Account__c>) n,(Map<Id, AITM_Tender_Account__c>) oMap);
    if (sot.getDescribe().getName() == 'AITM_Tender_Account__c') AITM_Tender_Account_Helper.populateLegalEntityDetails((List<AITM_Tender_Account__c>) n,(Map<Id, AITM_Tender_Account__c>) oMap);    
  } 

  /****************************************************************************************************
  After Insert Event Handler
  ***************************************************************************************************/
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'AITM_Tender_Account__c') AITM_Tender_Account_Helper.addChildAccountsToInnerCollection((List<AITM_Tender_Account__c>) n,(Map<Id, AITM_Tender_Account__c>) oMap);
  } 

  /****************************************************************************************************
  Before Update Event Handler
  ***************************************************************************************************/
    public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'AITM_Tender_Account__c') AITM_Tender_Account_Helper.populateBankAccount((List<AITM_Tender_Account__c>) n,(Map<Id, AITM_Tender_Account__c>) oMap);
    if (sot.getDescribe().getName() == 'AITM_Tender_Account__c') AITM_Tender_Account_Helper.tenderAccountValidateAffiliates((List<AITM_Tender_Account__c>) n,(Map<Id, AITM_Tender_Account__c>) oMap);
    if (sot.getDescribe().getName() == 'AITM_Tender_Account__c') AITM_Tender_Account_Helper.populateLegalEntityDetails((List<AITM_Tender_Account__c>) n,(Map<Id, AITM_Tender_Account__c>) oMap);    
          
  }

  /****************************************************************************************************
  After Update Event Handler
  ***************************************************************************************************/ 
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'AITM_Tender_Account__c') AITM_Tender_Account_Helper.tenderAccountCreditTermsCopy((List<AITM_Tender_Account__c>) n,(Map<Id, AITM_Tender_Account__c>) oMap);
  } 

  /****************************************************************************************************
  Before Delete Event Handler
  ***************************************************************************************************/ 
    public override void beforeDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'AITM_Tender_Account__c') AITM_Tender_Account_Helper.removeDefaultStraddling((List<AITM_Tender_Account__c>) o);
  } 

  /****************************************************************************************************
  After Delete Event Handler
  ***************************************************************************************************/  
    public override void afterDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'AITM_Tender_Account__c') AITM_Tender_Account_Helper.tenderAccountDeleteRelatedLineItems((List<AITM_Tender_Account__c>) o);
  } 
    
}