/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Used for storing queries related to Locations, Tender Customer, Tender Location Staging, 
 *                   Tender Location and Tender Location Line Item objects which can be reused in all related classes.

 * history
 * 01/December/2017  George          Created
 * 14/June/2018      srnandan        Modified - AR-2988 Added comments both at class and method level
 *************************************************************************************/
public with sharing class AITM_NewOfferTable {
    
	private static final ID ID_TLLI_RECORD_TYPE_DEFAULT = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
    
    /**
     * @description gets table data for a given tenderlocationid
     * @param tenderLocationId of type Id
     * @return Map<String, List<sObject>>
     */    
    @AuraEnabled
    public static Map<String, List<sObject>> getTableData(Id tenderLocationId) {
        List<AITM_Tender_Location_Line_Item__c> lineItems = new AITM_LocationsDao().getTenderLocationLineItemsByRecordType(tenderLocationId, ID_TLLI_RECORD_TYPE_DEFAULT);
        AITM_Tender_Location__c tenderLocation = new AITM_LocationsDao().getTenderLocation(tenderLocationId);

        Map<String, List<sObject>> tableData = new Map<String, List<sObject>>();
        tableData.put('lineItems', lineItems);
        tableData.put('tenderLocation', new List<AITM_Tender_Location__c>{tenderLocation});
        return tableData;

    }
}