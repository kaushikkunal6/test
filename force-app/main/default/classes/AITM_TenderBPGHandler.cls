/***********************************************************************************************
 * @author           Sushant
 * @date             22/June/2020
 * @group            AirBP
 * @description      Trigger handler class for TenderTrigger in BPG framework
 *************************************************************************************/
 
public with sharing class AITM_TenderBPGHandler extends BPG_Trigger_Handler_Utilities {

 AITM_TenderHelper helperInstance = new AITM_TenderHelper();   
 /****************************************************************************************************
  Before Insert Event Handler
 ****************************************************************************************************/
  public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {    
    if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.beforeInsertCheckTenderOldOrNew((List<AITM_Tender__c>) n);
  } 

  /****************************************************************************************************
  After Insert Event Handler
  ***************************************************************************************************/
  public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {    
    if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.afterInsertTenderLocationChatterNotificationHandler((List<AITM_Tender__c>) n);
  } 

  /****************************************************************************************************
  Before Update Event Handler
  ***************************************************************************************************/
  public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {     
     if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.beforeUpdateTenderInvitationalEmailInvoker((Map<Id, AITM_Tender__c>) oMap, (List<AITM_Tender__c>) n);
     if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.beforeUpdateTenderNewRoundStarter((Map<Id, AITM_Tender__c>) oMap,(List<AITM_Tender__c>) n);
     if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.beforeUpdateTenderLocationChatterNotificationHandler((Map<Id, AITM_Tender__c>) oMap,(List<AITM_Tender__c>) n);  
  }

  /****************************************************************************************************
  After Update Event Handler 
  ***************************************************************************************************/ 
  public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.afterUpdateTenderLocationChatterNotificationHandler((Map<Id, AITM_Tender__c>) oMap,(List<AITM_Tender__c>) n);    
    if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.afterUpdateMakeGetCalloutToMulePros((Map<Id, AITM_Tender__c>) oMap,(List<AITM_Tender__c>) n);    
    if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.afterUpdateTenderLocationUpdateNewRoundWhenTenderIsProceedingToNewRound((Map<Id, AITM_Tender__c>) oMap,(List<AITM_Tender__c>) n);
    if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.afterUpdateTenderLocationUpdateFeedbackInformation((Map<Id, AITM_Tender__c>) oMap, (List<AITM_Tender__c>) n);    
    if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.afterUpdateTenderLocationLineItemDebriefClone((Map<Id, AITM_Tender__c>) oMap, (List<AITM_Tender__c>) n); 
     if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.afterUpdateTenderLocationServiceLevelUpdate((Map<Id, AITM_Tender__c>) oMap, (List<AITM_Tender__c>) n);  
  }
    
 
  /****************************************************************************************************
  Before Delete Event Handler
  ***************************************************************************************************/ 
  public override void beforeDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {    
    if (sot.getDescribe().getName() == 'AITM_Tender__c') helperInstance.beforeDeleteTenderDeleteRelatedLineItems((List<AITM_Tender__c>) o);
  } 

  /****************************************************************************************************
  After Delete Event Handler
  ***************************************************************************************************/  
  public override void afterDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {

  } 
  
  /******************************************************************************************
  Handles finish method
 ******************************************************************************************/
  public override void finish() {
    system.debug('*** Finish method - should run once only!  ***');
  }

}