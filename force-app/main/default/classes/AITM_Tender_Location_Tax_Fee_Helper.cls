/****************************************************************************************************
 *  Date          : 04-Nov-2019
 *  Author        : Kunal Kaushik
 *  Description   : Helper class for Tender Location taxes and fees.
 *  Modifications : 
 ****************************************************************************************************/
public with sharing class AITM_Tender_Location_Tax_Fee_Helper {
    
    /**
     * @description update the Recenlty Modified tax fee record
     * @param collection of tax fee type list, old and new map of tax fee records
     * @return null
     */
    public static void setRecentlyModifiedTaxFeeFlag(List<AITM_Tender_Location_Taxes_and_Fees__c> listOfNewTaxfees, Map<Id, AITM_Tender_Location_Taxes_and_Fees__c> oldMap, Map<Id, AITM_Tender_Location_Taxes_and_Fees__c> newMap) {
        
        Set<Id> setOfRecentlyModifiedLineItemIds = new Set<Id>();
        List<AITM_Tender_Location_Line_Item__c> listOfLineItems = new List<AITM_Tender_Location_Line_Item__c>();
        List<AITM_Tender_Location_Line_Item__c> listOfLineItemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
        for (AITM_Tender_Location_Taxes_and_Fees__c taxFee : listOfNewTaxfees) {
            if((taxFee.Name != oldMap.get(taxFee.Id).Name)||(taxFee.AITM_FEE_TAX_GROUP__c != oldMap.get(taxFee.Id).AITM_FEE_TAX_GROUP__c)
               ||(taxFee.AITM_Charge_Type__c != oldMap.get(taxFee.Id).AITM_Charge_Type__c)||(taxFee.AITM_Compulsory_Conditional__c != oldMap.get(taxFee.Id).AITM_Compulsory_Conditional__c)
               ||(taxFee.AITM_Value__c != oldMap.get(taxFee.Id).AITM_Value__c)||(taxFee.AITM_Display_Currency__c != oldMap.get(taxFee.Id).AITM_Display_Currency__c)
               ||(taxFee.AITM_Unit_of_measure__c != oldMap.get(taxFee.Id).AITM_Unit_of_measure__c)||(taxFee.AITM_Select_to_Apply_in_Contract__c != oldMap.get(taxFee.Id).AITM_Select_to_Apply_in_Contract__c)) {
                
                taxFee.AITM_Manually_Saved_Tax__c = true;
                taxFee.Is_Recently_Modified_Loc_Tax_Fee__c = true;
                setOfRecentlyModifiedLineItemIds.add(taxFee.Tender_Location_Line_Item_Id__c);
             } else{
                 taxFee.Is_Recently_Modified_Loc_Tax_Fee__c = false;
             }
        }
        
        if(!setOfRecentlyModifiedLineItemIds.isEmpty()){
            listOfLineItems = getModifiedTenderLocationLineItems(setOfRecentlyModifiedLineItemIds);
        }
        
        for(AITM_Tender_Location_Line_Item__c item : listOfLineItems){
            item.AITM_Is_Eligible_Line_for_All_Tax_Fee__c = true;
            listOfLineItemsToUpdate.add(item);
        }
        if(!listOfLineItemsToUpdate.isEmpty()){
            update listOfLineItemsToUpdate;
        }
	} 
    
   /**
    * @description gets Modified tender locations
    * @param collection of Line item id of type Set
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    private static List<AITM_Tender_Location_Line_Item__c> getModifiedTenderLocationLineItems(Set<Id> setOfRecentlyModifiedLineItemIds) {
        return new List<AITM_Tender_Location_Line_Item__c>([SELECT AITM_Is_Eligible_Line_for_All_Tax_Fee__c FROM AITM_Tender_Location_Line_Item__c WHERE Id IN :setOfRecentlyModifiedLineItemIds]);
    }
}