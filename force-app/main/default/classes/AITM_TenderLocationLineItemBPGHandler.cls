/***********************************************************************************************
 * @author           Sushant
 * @date             21/May/2020
 * @group            AirBP90;
 * @description      Trigger handler class for TenderLocationLineItem 
 ***********************************************************************************************/
public with sharing class AITM_TenderLocationLineItemBPGHandler extends BPG_Trigger_Handler_Utilities {
   
   
   /****************************************************************************************************
  Before Insert Event Handler
 ****************************************************************************************************/
   public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    AITM_TenderLocationLineItemHelper helperInstance = new AITM_TenderLocationLineItemHelper();
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeInsertPrePopulationFieldsFiller((List<Sobject>) n);   
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeInsertPopulateTenderHistoryLineItemHandler((List<SObject>) n, (Map<Id, SObject>) oMap);
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeInsertmodifyVolumeAdHoc((List<Sobject>) n);   
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeInsertDeliveryPointsCreationHandler((List<Sobject>) n);
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeInsertRequestedAndOfferedVolumeCalculations((List<Sobject>) n);    
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeInsertLineItemToTenderLocationRecordMapper((List<Sobject>) n);    
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeInsertOldRoundEditionBlock((List<Sobject>) n);    
   // if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeInsertPopulateDeliveryPointDetailsInTLLI((List<Sobject>) n);    
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeInsertInsertNewTaxesFeesRecords((List<Sobject>) n);           
    
  } 

  /****************************************************************************************************
  After Insert Event Handler
  ***************************************************************************************************/
   public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    AITM_TenderLocationLineItemHelper helperInstance = new AITM_TenderLocationLineItemHelper();
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.afterInsertPrePopulationFieldsFiller((List<Sobject>) n);    
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.afterInsertDefaultStraddling((List<Sobject>) n);
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.afterInsertInsertNewTaxesFeesRecords((List<Sobject>) n);
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.afterInsertTenderLocationUpdateNonRepresentedAndRecalculateFlag((List<Sobject>) n);
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.afterInsertTenderLocationOldPROSPricingService((List<SObject>) n);   
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.afterInsertLocationDefaultServiceLevel((List<SObject>) n);    
  } 

  /****************************************************************************************************
  Before Update Event Handler
  ***************************************************************************************************/
  public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    AITM_TenderLocationLineItemHelper helperInstance = new AITM_TenderLocationLineItemHelper();
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeUpdatemodifyVolumeAdHoc((Map<Id, SObject>) oMap, (List<Sobject>) n);
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeUpdateRequestedAndOfferedVolumeCalculations((Map<Id, SObject>) oMap, (List<SObject>) n);
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeUpdateLineItemToTenderLocationRecordMapper((Map<Id,SObject>) oMap, (List<SObject>) n);     
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeUpdateOldRoundEditionBlock((Map<Id,SObject>) oMap, (List<SObject>) n);     
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeUpdatePopulateTenderHistoryLineItemHandler((List<SObject>) n, (Map<Id, SObject>) oMap);             
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeUpdatePopulateDeliveryPointDetailsInTLLI((Map<Id,SObject>) oMap, (List<SObject>) n);         
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeUpdateFinalPopulateDeliveryPointDetailsInTLLI((List<SObject>) n, (Map<Id, SObject>) oMap);         
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeUpdateDefaultStraddling((Map<Id,SObject>) oMap, (List<Sobject>) n);                     
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeUpdateInsertNewTaxesFeesRecords((Map<Id,SObject>) oMap, (List<Sobject>) n);
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeStartEndDateValidation((List<Sobject>) n, (Map<Id,SObject>) oMap);
  }

  /****************************************************************************************************
  After Update Event Handler
  ***************************************************************************************************/ 
  public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
   AITM_TenderLocationLineItemHelper helperInstance = new AITM_TenderLocationLineItemHelper();
   if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.afterUpdatePopulateDeliveryPointDetailsInTLLI((List<Sobject>) o, (List<SObject>) n);  
   if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.afterUpdateInsertNewTaxesFeesRecords((Map<Id,Sobject>) oMap, (List<SObject>) n);   
   if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.afterUpdateTenderLocationUpdateNonRepresentedAndRecalculateFlag((Map<Id,SObject>) oMap, (List<SObject>) n);   
   if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.afterUpdateTenderLocationPROSPricingService((Map<Id,Sobject>) oMap, (List<SObject>) n);   
  } 

  /****************************************************************************************************
  Before Delete Event Handler
  ***************************************************************************************************/ 
  public override void beforeDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
   AITM_TenderLocationLineItemHelper helperInstance = new AITM_TenderLocationLineItemHelper();
   if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.beforeDeleteLineItemToTenderLocationRecordMapper((List<SObject>) o);
  } 

  /****************************************************************************************************
  After Delete Event Handler
  ***************************************************************************************************/  
  public override void afterDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    AITM_TenderLocationLineItemHelper helperInstance = new AITM_TenderLocationLineItemHelper();
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Line_Item__c') helperInstance.afterDeleteTenderLocationUpdateNonRepresentedAndRecalculateFlag((List<AITM_Tender_Location_Line_Item__c>) o);
  } 
    

}