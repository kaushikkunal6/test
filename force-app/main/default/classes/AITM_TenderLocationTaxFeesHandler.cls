/*************************************************************************
* @author         Kunal Kaushik
* @Luke Date      31/Oct/2019
* @group          AirBP
* @description    Trigger handler for Tender Location Taxes and Fees

* * history
 *31/Oct/2019   	 Kunal      Created
*************************************************************************/
public with sharing class AITM_TenderLocationTaxFeesHandler extends BPG_Trigger_Handler_Utilities {
    
 /****************************************************************************************************
  Before Update Event Handler
 ****************************************************************************************************/
  public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'AITM_Tender_Location_Taxes_and_Fees__c') AITM_Tender_Location_Tax_Fee_Helper.setRecentlyModifiedTaxFeeFlag((List<AITM_Tender_Location_Taxes_and_Fees__c>) n, (Map<Id, AITM_Tender_Location_Taxes_and_Fees__c>) oMap, (Map<Id, AITM_Tender_Location_Taxes_and_Fees__c>) nMap);
  } 
}