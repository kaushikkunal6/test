/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      class for TenderLocation Mapping Handler
 
 * history
 * 01/December/2017  George       Created
 * 20/March/2018     srnandan     Modified - added code comments at method and class level 
 *                                as per coding standards and also fixed sonar qube issue                  
 * 28/March/2018     srnandan     Modified - AR-2803- modified method "createTenderLocation"
 *                                to include calculation of totaloffervolume on tenderlocation
 * 23/August/2018    Ravi         Modified - Added with sharing to the main class for sonarqube fixes
 * 23/December/2018  srnandan     Modified - AR-4826 removed logic of existing tender locations condition
 * 29/December/2018  srnandan     Modified - AR-4875 line item owner changes to methods populateLocationManagers
 **********************************************************************************************/
public with sharing class AITM_TenderLocationMappingHandler {
    private Set<Id> tenderIds;
    private Set<Id> locationIds;
    private Map<String, List<AITM_Tender_Location_Line_Item__c>> volumeToIncreasePerTenderLocation;
    private Map<String, List<AITM_Tender_Location_Line_Item__c>> volumeToDecreasePerTenderLocation;
    private Map<Id, AITM_Location__c> locationsById;
    private Map<Id, String> tenderSectorById;
    private @testVisible static Boolean DISABLE_CLEAR = false;
    

    /**
     * @description gets clear disabled
     * @param null
     * @return boolean
     */
    public static Boolean getClearDisabled() {
        return DISABLE_CLEAR;
    }

    /**
     * @description default constructor mapping handler class 
     */
    public AITM_TenderLocationMappingHandler() {
        tenderIds = new Set<Id>();
        locationIds = new Set<Id>();
        locationsById = new Map<Id, AITM_Location__c>();
        tenderSectorById = new Map<Id, String>();

        volumeToIncreasePerTenderLocation = new Map<String, List<AITM_Tender_Location_Line_Item__c>>();
        volumeToDecreasePerTenderLocation = new Map<String, List<AITM_Tender_Location_Line_Item__c>>();
        
        AITM_TenderLocationMappingHandler.DISABLE_CLEAR = true;        
    }

    /**
     * @description collects collection of volumetoincrease per tenderlocation
     * @param tenderLocationLineItem of type AITM_Tender_Location_Line_Item__c
     * @return void
     */
    public void collect(AITM_Tender_Location_Line_Item__c tenderLocationLineItem) {
        locationIds.add(tenderLocationLineItem.AITM_Location__c);
        tenderIds.add(tenderLocationLineItem.AITM_Tender__c);
        String key = getKey(tenderLocationLineItem);
        if (!volumeToIncreasePerTenderLocation.containsKey(key)) {
            volumeToIncreasePerTenderLocation.put(key, new List<AITM_Tender_Location_Line_Item__c>());
        }
        volumeToIncreasePerTenderLocation.get(key).add(tenderLocationLineItem);
    }

    /**
     * @description collects collection of volumetodecrease per tenderlocation
     * @param tenderLocationLineItem of type AITM_Tender_Location_Line_Item__c
     * @param forDelete of type boolean
     * @return void
     */
    public void collect(AITM_Tender_Location_Line_Item__c tenderLocationLineItem, Boolean forDelete) {
        locationIds.add(tenderLocationLineItem.AITM_Location__c);
        tenderIds.add(tenderLocationLineItem.AITM_Tender__c);
        String key = getKey(tenderLocationLineItem);
        if (!volumeToDecreasePerTenderLocation.containsKey(key)) {
            volumeToDecreasePerTenderLocation.put(key, new List<AITM_Tender_Location_Line_Item__c>());
        }
        volumeToDecreasePerTenderLocation.get(key).add(tenderLocationLineItem); 
    }

    /**
     * @description collects collection of tenderlocationlineitem and oldtenderlocationlineitem
     * @param oldTenderLocationLineItem of type AITM_Tender_Location_Line_Item__c
     * @param tenderLocationLineItem of type AITM_Tender_Location_Line_Item__c
     * @return void
     */
    public void collect(AITM_Tender_Location_Line_Item__c oldTenderLocationLineItem, AITM_Tender_Location_Line_Item__c tenderLocationLineItem) {
        if (oldTenderLocationLineItem.AITM_Location__c != tenderLocationLineItem.AITM_Location__c 
         || oldTenderLocationLineItem.AITM_Tender__c != tenderLocationLineItem.AITM_Tender__c) {
            this.collect(tenderLocationLineItem);
            this.collect(oldTenderLocationLineItem, true);
        }
    }
    
    /**
     * @description upsert tender location 
     * @param String 
     * @return void
     */
    public void upsertTenderLocations(String eventCheck) {
        //locationsById = new AITM_LocationsDao().getLocationsWithTenderLocationInfoByIds(locationIds);
        //tenderSectorById =  new AITM_TenderDao().getMapedSectorsByIds(tenderIds);
        List<AITM_Tender_Location__c> tenderLocationsToUpsert = new List<AITM_Tender_Location__c>();
         
        if (eventCheck == 'onInsert') {
            tenderLocationsToUpsert = getTenderLocationsForInsert();
        } else if (eventCheck == 'onUpdate') {            
            tenderLocationsToUpsert = getTenderLocationsForUpdate();
        } else if (eventCheck == 'onDelete') {
            tenderLocationsToUpsert = getTenderLocationsForDelete();
        }      
        if (!tenderLocationsToUpsert.isEmpty()) {
            upsert tenderLocationsToUpsert;
            saveTenderLocations();
        }
    }

    /**
     * @description upsert tender location 
     * @param null
     * @return void
     */
    public void upsertTenderLocations() {
        //locationsById = new AITM_LocationsDao().getLocationsWithTenderLocationInfoByIds(locationIds);
        //tenderSectorById =  new AITM_TenderDao().getMapedSectorsByIds(tenderIds);
        List<AITM_Tender_Location__c> tenderLocationsToUpsert = new List<AITM_Tender_Location__c>();

        if (Trigger.isInsert) {
            tenderLocationsToUpsert = getTenderLocationsForInsert();
        } else if (Trigger.isUpdate) {
            tenderLocationsToUpsert = getTenderLocationsForUpdate();
        } else if (Trigger.isDelete) {
            tenderLocationsToUpsert = getTenderLocationsForDelete();
        }

        if (!tenderLocationsToUpsert.isEmpty()) {
            upsert tenderLocationsToUpsert;
            saveTenderLocations();
        }
    }

    /**
     * @description gets tenderlocations for insert
     * @param null
     * @return List collection AITM_Tender_Location__c
     */
    private List<AITM_Tender_Location__c> getTenderLocationsForInsert() {
        List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
        
        Map<String, AITM_Tender_Location__c> existingTenderLocations = getExistingTenderLocations();        
        for (String key : volumeToIncreasePerTenderLocation.keySet()) {
            List<AITM_Tender_Location_Line_Item__c> lineItems = volumeToIncreasePerTenderLocation.get(key);            
 
            if (existingTenderLocations.containsKey(key)) {
                
                AITM_Tender_Location__c existingTenderLocation = existingTenderLocations.get(key);				
                for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                    if (existingTenderLocation.AITM_Volume__c != null && existingTenderLocation.AITM_Volume__c!= lineItem.AITM_Volume__c) {                        
                        existingTenderLocation.AITM_Volume__c += lineItem.AITM_Volume__c == null ? 0 : lineItem.AITM_Volume__c;
                 }
                    if (existingTenderLocation.AITM_Total_Volume_Offered_To_The_Group__c != null && existingTenderLocation.AITM_Volume__c!= lineItem.AITM_Volume__c) {                        
                        existingTenderLocation.AITM_Total_Volume_Offered_To_The_Group__c += lineItem.AITM_Offered_Volume__c == null ? 0 : lineItem.AITM_Offered_Volume__c;
                    }
                    if (!existingTenderLocation.AITM_Ad_hoc_Volume__c) {
                        existingTenderLocation.AITM_Ad_hoc_Volume__c = lineItem.AITM_Ad_hoc_Volume__c;
                    }
                    if(existingTenderLocation.AITM_Total_Requested_Volume__c != null && existingTenderLocation.AITM_Volume__c!= lineItem.AITM_Volume__c){
                      existingTenderLocation.AITM_Total_Requested_Volume__c += lineItem.AITM_Requested_Volume_USG__c == null ? 0 : lineItem.AITM_Requested_Volume_USG__c;  
                    }
                }             
                result.add(existingTenderLocation);           
                
            } else {                   
                     result.add(createTenderLocation(lineItems));                                                   
                                
                    
                  }
        }

        return result;
    }

    /**
     * @description gets tenderlocations for update
     * @param null
     * @return List collection AITM_Tender_Location__c
     */
    private List<AITM_Tender_Location__c> getTenderLocationsForUpdate() {
        List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
        Map<Id, AITM_Tender_Location__c> tenderLocations = new Map<Id, AITM_Tender_Location__c>();

        Map<String, AITM_Tender_Location__c> existingTenderLocations = getExistingTenderLocations();		
        for (String key : volumeToDecreasePerTenderLocation.keySet()) {
            List<AITM_Tender_Location_Line_Item__c> lineItems = volumeToDecreasePerTenderLocation.get(key);
            if (existingTenderLocations.containsKey(key)) {
                AITM_Tender_Location__c existingTenderLocation = existingTenderLocations.get(key);
                for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                    if (existingTenderLocation.AITM_Volume__c != null) {
                        existingTenderLocation.AITM_Volume__c -= lineItem.AITM_Volume__c;
                    }
                }

                tenderLocations.put(existingTenderLocation.Id, existingTenderLocation);
            }
        }

        for (String key : volumeToIncreasePerTenderLocation.keySet()) {
            List<AITM_Tender_Location_Line_Item__c> lineItems = volumeToIncreasePerTenderLocation.get(key);
            if (existingTenderLocations.containsKey(key)) {
                AITM_Tender_Location__c existingTenderLocation = existingTenderLocations.get(key);

                for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                    if (existingTenderLocation.AITM_Volume__c != null) {
                        existingTenderLocation.AITM_Volume__c += lineItem.AITM_Volume__c == null ? 0 : lineItem.AITM_Volume__c;
                                           }
                    if (!existingTenderLocation.AITM_Ad_hoc_Volume__c) {
                        existingTenderLocation.AITM_Ad_hoc_Volume__c = lineItem.AITM_Ad_hoc_Volume__c;
                    }
                }

                if (tenderLocations.containsKey(existingTenderLocation.Id)) {
                    for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                        tenderLocations.get(existingTenderLocation.Id).AITM_Volume__c += lineItem.AITM_Volume__c ;
                    }
                } else {
                    tenderLocations.put(existingTenderLocation.Id, existingTenderLocation);
                }
            } else {
                result.add(createTenderLocation(lineItems));
            }
        }

        result.addAll(tenderLocations.values());
        return result;
    }

    /**
     * @description gets tenderlocations for delete
     * @param null
     * @return List collection AITM_Tender_Location__c
     */
    private List<AITM_Tender_Location__c> getTenderLocationsForDelete() {
        List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
        Map<String, AITM_Tender_Location__c> existingTenderLocations = getExistingTenderLocations();

        for (String key : volumeToDecreasePerTenderLocation.keySet()) {
            List<AITM_Tender_Location_Line_Item__c> lineItems = volumeToDecreasePerTenderLocation.get(key);
            if (existingTenderLocations.containsKey(key)) {
                AITM_Tender_Location__c existingTenderLocation = existingTenderLocations.get(key);
                for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                    if (existingTenderLocation.AITM_Volume__c != null) {
                        existingTenderLocation.AITM_Volume__c -= lineItem.AITM_Volume__c == null ? 0 : lineItem.AITM_Volume__c;
                    }
                }
                result.add(existingTenderLocation);
            }
        }

        return result;
    }

    /**
     * @description creates tender location sobject
     * @param lineItems list collection AITM_Tender_Location_Line_Item__c
     * @return AITM_Tender_Location__c
     */
    private AITM_Tender_Location__c createTenderLocation(List<AITM_Tender_Location_Line_Item__c> lineItems) {
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
            AITM_Ad_hoc_Volume__c = false,
            AITM_Volume__c = 0,
            AITM_Location__c = lineItems[0].AITM_Location__c,
            //AITM_Location_Manager__c = this.getLocationManagerId(locationsById.get(lineItems[0].AITM_Location__c), tenderSectorById.get(lineItems[0].AITM_Tender__c)),
            AITM_Tender__c = lineItems[0].AITM_Tender__c,
            AITM_Total_Volume_Offered_To_The_Group__c = 0,
            AITM_Total_Requested_Volume__c = 0,
            AITM_Round__c = lineItems[0].AITM_Round__c,
            AITM_Current_Round__c = lineItems[0].AITM_Round__c
        );
        
        for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
            tenderLocation.AITM_Volume__c += lineItem.AITM_Volume__c == null? 0 : lineItem.AITM_Volume__c;
            tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c += lineItem.AITM_Offered_Volume__c == null? 0 : lineItem.AITM_Offered_Volume__c;
            tenderLocation.AITM_Total_Requested_Volume__c += lineItem.AITM_Requested_Volume_USG__c == null ? 0:lineItem.AITM_Requested_Volume_USG__c;
            if (!tenderLocation.AITM_Ad_hoc_Volume__c) {
                tenderLocation.AITM_Ad_hoc_Volume__c = lineItem.AITM_Ad_hoc_Volume__c;
            }
        }

        return tenderLocation;
    }

     /**
     * @description creates tender location sobject
     * @param lineItems list collection AITM_Tender_Location_Line_Item__c and Integer i
     * @return AITM_Tender_Location__c
     */

     public AITM_Tender_Location__c createTenderLocation(List<AITM_Tender_Location_Line_Item__c> lineItems,Integer i) {
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
            AITM_Ad_hoc_Volume__c = false,
            AITM_Volume__c = 0,
            AITM_Location__c = lineItems[0].AITM_Location__c,
            //AITM_Location_Manager__c = this.getLocationManagerId(locationsById.get(lineItems[0].AITM_Location__c), tenderSectorById.get(lineItems[0].AITM_Tender__c)),
            AITM_Tender__c = lineItems[0].AITM_Tender__c,
            AITM_Total_Volume_Offered_To_The_Group__c = 0,
            AITM_Total_Requested_Volume__c = 0,
            AITM_Current_Round__c = i,
            AITM_Round__c = i

        );
        
        for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
            tenderLocation.AITM_Volume__c += lineItem.AITM_Volume__c == null? 0 : lineItem.AITM_Volume__c;
            tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c += lineItem.AITM_Offered_Volume__c == null? 0 : lineItem.AITM_Offered_Volume__c;
            tenderLocation.AITM_Total_Requested_Volume__c += lineItem.AITM_Requested_Volume_USG__c == null ? 0:lineItem.AITM_Requested_Volume_USG__c;
            if (!tenderLocation.AITM_Ad_hoc_Volume__c) {
                tenderLocation.AITM_Ad_hoc_Volume__c = lineItem.AITM_Ad_hoc_Volume__c;
            }
        }

        return tenderLocation;
    }

    /**
     * @description gets existing tenderlocations
     * @param null
     * @return Map collection 
     */
    private Map<String, AITM_Tender_Location__c> getExistingTenderLocations() {
        Map<String, AITM_Tender_Location__c> existingTenderLocations = new Map<String, AITM_Tender_Location__c>();
        for (AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getTenderLocations(tenderIds, locationIds)) {
            existingTenderLocations.put(getKey(tenderLocation), tenderLocation);
        }
        return existingTenderLocations;
    }

    /**
     * @description saves tender location details
     * @param null
     * @return void
     */
    private void saveTenderLocations() {
        List<AITM_Tender_Location_Line_Item__c> lineItemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
        Map<String, AITM_Tender_Location__c> existingTenderLocations = getExistingTenderLocations();

        for (String key : volumeToIncreasePerTenderLocation.keySet()) {
            List<AITM_Tender_Location_Line_Item__c> lineItems = volumeToIncreasePerTenderLocation.get(key);
            for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                if(existingTenderLocations.size() > 0 && existingTenderLocations.containsKey(key)) {
                    lineItem.AITM_Tender_Location__c = existingTenderLocations.get(key).Id;
                }
            }
        }
    }

    /**
     * @description returns key combination tenderlocationlineitem of location and tender
     * @param lineItem of type AITM_Tender_Location_Line_Item__c
     * @return string
     */
    private String getKey(AITM_Tender_Location_Line_Item__c lineItem) {
        return lineItem.AITM_Location__c + '-' + lineItem.AITM_Tender__c;
    }

    /**
     * @description returns key combination tenderlocation of location and tender
     * @param line of type AITM_Tender_Location__c
     * @return string
     */
    private String getKey(AITM_Tender_Location__c line) {
        return line.AITM_Location__c + '-' + line.AITM_Tender__c;
    }

    /**
     * @description gets location manager id
     * @param locationRecord of type AITM_Location__c
     * @param sector of type string
     * @return Id
     */
    private Id getLocationManagerId(AITM_Location__c locationRecord, String sector) {
        if (locationRecord.AITM_Location_Managers__r.size() > 0 && sector != null) {
            for (AITM_Location_Manager__c manager : locationRecord.AITM_Location_Managers__r) {
                if (manager.AITM_Sector__c == sector) {
                    return manager.AITM_Location_Manager__c;
                }
            }
            return locationRecord.OwnerId;
        } else {
            return locationRecord.OwnerId;
        }
    }
}