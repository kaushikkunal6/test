/*************************************************************************
 * @author         Vitali
 * @date           01/December/2017
 * @group          AirBP
 * @description    TenderLocation Handler class

 * history
 * 01/December/2017  Vitali     Created 
 * 16/August/2018    srnandan   Modified -Added comments both at method and class level
 * 23/August/2018    Ravi       Modified - Added with sharing to the main class for sonarqube fixes
 ****************************************************************************/
public with sharing class AITM_TenderLocationDuplicatesHandler {
    private Set<Id> tenderIds;
    private Set<Id> locationIds;
    private List<AITM_Tender_Location_Line_Item__c> tenderLocationsToDelete;

    /**
     * @description default constructor handler class 
     */

    public AITM_TenderLocationDuplicatesHandler() {
        tenderIds = new Set<Id>();
        locationIds = new Set<Id>(); 
        tenderLocationsToDelete = new List<AITM_Tender_Location_Line_Item__c>();
    }

    /**
     * @description check for duplicates and save
     * @param lineItems of type List<AITM_Tender_Location_Line_Item__c>
     * @return null
     */
    public void checkForDuplicatesAndSave(List<AITM_Tender_Location_Line_Item__c> lineItems) {
        for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
            this.collect(lineItem);
        }
        saveTenderLocations(lineItems);
        Database.delete([SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE Id IN :tenderLocationsToDelete], true);
    }
    
    /**
     * @description check for duplicates and save batch
     * @param lineItems of type List<AITM_Tender_Location_Line_Item__c>
     * @return null
     */
    public void checkForDuplicatesAndSaveBatch(List<AITM_Tender_Location_Line_Item__c> lineItems) {
        for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
            this.collect(lineItem);
        }
        saveTenderLocationsBatch(lineItems);
    }

    /**
     * @description save tender locations batch
     * @param rawTenderLocations of type List<AITM_Tender_Location_Line_Item__c>
     * @return null
     */
    private void saveTenderLocationsBatch(List<AITM_Tender_Location_Line_Item__c> rawTenderLocations) {
        List<AITM_Tender_Location_Line_Item__c> tenderLocationsToSave = new List<AITM_Tender_Location_Line_Item__c>();
        Map<String, List<AITM_Tender_Location_Line_Item__c>> existingTenderLocations = mapTenderLocationsByAccount();
        for (AITM_Tender_Location_Line_Item__c rawTenderLocation : rawTenderLocations) {
            String key = this.getKey(rawTenderLocation);
            tenderLocationsToSave.add(rawTenderLocation);                   
        }

        if (!tenderLocationsToSave.isEmpty()) {
            AITM_UploadLocationsBatch.BatchState batchState = new AITM_UploadLocationsBatch.BatchState(tenderLocationsToSave);
            new AITM_UploadLocationsBatch.BatchFactory().executeBatch(batchState); 
        }
    }
    
    /**
     * @description collect
     * @param lineItem of type AITM_Tender_Location_Line_Item__c
     * @return null
     */    
    private void collect(AITM_Tender_Location_Line_Item__c lineItem) {
        tenderIds.add(lineItem.AITM_Tender__c);
        locationIds.add(lineItem.AITM_Location__c);
    }

    /**
     * @description save tender locations
     * @param rawTenderLocations of type List<AITM_Tender_Location_Line_Item__c>
     * @return null
     */
    private void saveTenderLocations(List<AITM_Tender_Location_Line_Item__c> rawTenderLocations) {
        List<AITM_Tender_Location_Line_Item__c> tenderLocationsToSave = new List<AITM_Tender_Location_Line_Item__c>();
        Map<String, List<AITM_Tender_Location_Line_Item__c>> existingTenderLocations = mapTenderLocationsByAccount();
        for (AITM_Tender_Location_Line_Item__c rawTenderLocation : rawTenderLocations) {
            String key = this.getKey(rawTenderLocation);
            tenderLocationsToSave.add(rawTenderLocation);                   
        }

        if (!tenderLocationsToSave.isEmpty()) {
            new AITM_LocationsDao().saveTenderLocations(tenderLocationsToSave);
        }
    }

    /**
     * @description map tender locations by account
     * @param null
     * @return Map<String, List<AITM_Tender_Location_Line_Item__c>>
     */
    private Map<String, List<AITM_Tender_Location_Line_Item__c>> mapTenderLocationsByAccount() {
        Map<String, List<AITM_Tender_Location_Line_Item__c>> result = new Map<String, List<AITM_Tender_Location_Line_Item__c>>();
        for (AITM_Tender_Location_Line_Item__c tenderLocation : new AITM_LocationsDao().getTenderLocationLineItemByTenderIdsAndLocationIds(tenderIds, locationIds, new List<AITM_Tender_Location_Line_Item__c>())) {
            String key = this.getKey(tenderLocation);
            if (!result.containsKey(key)) {
                result.put(key, new List<AITM_Tender_Location_Line_Item__c>());
            }
            result.get(key).add(tenderLocation);
        }
        return result;
    }

    /**
     * @description get key
     * @param tenderLocation of type AITM_Tender_Location_Line_Item__c
     * @return string
     */
    private String getKey(AITM_Tender_Location_Line_Item__c tenderLocation) {
        return tenderLocation.AITM_Account__c + '-' + tenderLocation.AITM_Tender__c + '-' + tenderLocation.AITM_Location__c;
    }
}