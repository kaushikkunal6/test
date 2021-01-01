/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      controller class used by aura component to add new locations to tender

 * history
 * 01/December/2017  George      Created 
 * 27/March/2018     srnandan    added comments at method and class level as per coding standards
 *                               AR-2803-modified method "TenderLocationWrapper" to assign uom 
 *                               of tender to locationlineitem requestedvolumeuom 
 * 14/May/2018       Ravi        Modified - AR-2986 - Added logic to Populate Exchange Rate field 
 *                               from Account to TLLI
 * 23/July/2018      Ravi        Modified - AR-3797 - Commented logic to search locations based on Tender Sector
 * 3rd/Dec/2018      Shweta      Modified - AR-4644 -- Added the logic to create TLLI based on tender sectors
 * 02/February/2019  srnandan    Modified - AR-4939 Added condition to check access before calling save
 ************************************************************************************************/
public with sharing class AITM_AddLocationsController {
    private static AITM_LocationsDao model = new AITM_LocationsDao();
    private static List<AITM_Tender_Account__c> tenderAccountsCache;
    public final static String Tender_Sector = 'CA';
    public static  List<AggregateResult> resultRound;
    public static Integer maxRound;
    public static List<AITM_Tender__c> tender;

    /**
     * @description searches locations based on tenderid and key
     * @param tenderId of type Id
     * @param key of type string
     * @return List collection AITM_Location__c
     */
    public static @AuraEnabled List<AITM_Location__c> searchLocations(Id tenderId, String key) {
        Map<Id, AITM_Location__c> allLocations = new Map<Id, AITM_Location__c>(model.searchLocations(key));
        return allLocations.values();
    }

    /**
     * @description gets tenderlocations for a tender
     * @param tenderId of type string
     * @return List collection of TenderLocationWrapper
     */
    public static @AuraEnabled List<TenderLocationWrapper> getTenderLocations(String tenderId) {
        List<TenderLocationWrapper> result = new List<TenderLocationWrapper>();
        if (tenderAccountsCache == null) {
            tenderAccountsCache = AITM_AddLocationsController.getTenderAccounts(tenderId);
        }

        for (AITM_Tender_Account__c tenderAccount : tenderAccountsCache) {
            result.add(new TenderLocationWrapper(tenderAccount, tenderId));
        }

        return result;
    }

    /**
     * @description saves tenderlocations
     * @param jsonLocations of type string json format
     * @return void
     */
    public static @AuraEnabled void saveTenderLocations(String jsonLocations,Id tenderId) {
        List<AITM_Tender_Location_Line_Item__c> tenderLocations = new List<AITM_Tender_Location_Line_Item__c>();
        List<TenderLocationWrapper> wrappedLocations = (List<TenderLocationWrapper>) JSON.deserialize(jsonLocations, List<TenderLocationWrapper>.class);
		Id locations;
		locations = wrappedLocations[0].locationId;
        tender = [SELECT AITM_Number_Of_Locations__c  FROM AITM_Tender__c WHERE Id = :tenderId];
        resultRound =  [SELECT Max(AITM_Round__c) maxRound FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId];
        maxRound = Integer.valueOf(resultRound[0].get('maxRound'));
        if(tender[0].AITM_Number_Of_Locations__c == 0 || maxRound == 1){
             for(TenderLocationWrapper wrappedRecord : wrappedLocations) {
                 if(wrappedRecord.isFilled() && wrappedRecord.isSelected) {
                 tenderLocations.add(wrappedRecord.unwrap());
                }
             } 
        }
        else{
            if(maxRound >1){          
                  for(TenderLocationWrapper wrappedRecord : wrappedLocations) {
                      if (wrappedRecord.isFilled() && wrappedRecord.isSelected){
                          tenderLocations.add(wrappedRecord.unwrapRoundLocations(maxRound));                     
                       } 
                  }
            }
        }

        if (!tenderLocations.isEmpty()) {
            Id newtenderId = tenderLocations[0].AITM_Tender__c; //assuming save will occur only for one tender
            Id newlocationId = tenderLocations[0].AITM_Location__c; //assuming save will occur only for one location
            if(AITM_BaseUtils.checkSharePermission(newtenderId)) {
            	new AITM_TenderLocationDuplicatesHandler().checkForDuplicatesAndSave(tenderLocations);    
            } else {
                throw new AuraHandledException(Label.AITM_LackingPermissions);
            }
        }
    } 	               
       

    /**
     * @description gets tender accounts for a tender
     * @param tenderId of type string
     * @return List collection AITM_Tender_Account__c
     */
    private static List<AITM_Tender_Account__c> getTenderAccounts(String tenderId) {
        return model.getTenderAccountsByTenderId(String.escapeSingleQuotes(tenderId));
    }

    /**
     * @description tenderlocation wrapper inner class
     */
    public class TenderLocationWrapper {
        public @AuraEnabled String accountName;
        public @AuraEnabled String accountGRN;
        public @AuraEnabled Boolean isSelected;
        public @AuraEnabled Boolean adHocVolume;
        public @AuraEnabled Integer volume;
        public @AuraEnabled Date startDate;
        public @AuraEnabled Date endDate;
        public @AuraEnabled String requestedVolumeUom;
        public @AuraEnabled Id accountId;
        public @AuraEnabled Id locationId;
        public @AuraEnabled Id tenderId;
        public @AuraEnabled String exchangeRate;

        /**
         * @description overloaded constructor
         * @param tenderAccount of type AITM_Tender_Account__c
         * @param tenderId of type String
         */
        public TenderLocationWrapper(AITM_Tender_Account__c tenderAccount, String tenderId) {
            this.accountId = tenderAccount.AITM_Account__c;
            this.tenderId = tenderId;
            this.accountName = tenderAccount.AITM_Account__r.Name;
            this.accountGRN = tenderAccount.AITM_Account__r.AITM_GRN__c;
            this.isSelected = false;
            this.adHocVolume = false;
            this.startDate = tenderAccount.AITM_Tender__r.AITM_Start_Date__c;
            this.endDate = tenderAccount.AITM_Tender__r.AITM_End_Date__c;
            this.volume = 0;
            this.requestedVolumeUom = tenderAccount.AITM_Tender__r.AITM_Unit_Of_Measure__c;
            this.exchangeRate = tenderAccount.AITM_Account__r.AITM_Exchange_Rate__c;
        }

        /**
         * @description returns true if volume and adhocvolume has value for a location
         * @param null
         * @return boolean
         */
        public Boolean isFilled() {
            return this.locationId != null && (this.volume != null || this.adHocVolume);
        }

        /**
         * @description initialized tenderlocationlineitem sobject with values
         * @param null
         * @return AITM_Tender_Location_Line_Item__c
         */
        public AITM_Tender_Location_Line_Item__c unwrap() {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Account__c = this.AccountId,
                AITM_Ad_hoc_Volume__c = this.adHocVolume,
                AITM_Start_Date__c = this.startDate,
                AITM_End_Date__c = this.endDate,
                AITM_Location__c = this.locationId,
                AITM_Tender__c = this.tenderId,
                AITM_Volume__c = this.adHocVolume ? null : this.volume,
                AITM_Volume_Formatted_Text__c = this.adHocVolume ? null : this.volume.format(),
                AITM_Requested_Volume_UoM__c = this.requestedVolumeUom,
                AITM_Exchange__c = this.exchangeRate
            );
        }

         /**
         * @description initialized tenderlocationlineitem sobject with values
         * @param of type i
         * @return AITM_Tender_Location_Line_Item__c
         */
        public AITM_Tender_Location_Line_Item__c unwrapRoundLocations(Integer i) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Account__c = this.AccountId,
                AITM_Ad_hoc_Volume__c = this.adHocVolume,
                AITM_Start_Date__c = this.startDate,
                AITM_End_Date__c = this.endDate,
                AITM_Location__c = this.locationId,
                AITM_Tender__c = this.tenderId,
                AITM_Volume__c = this.adHocVolume ? null : this.volume,
                AITM_Volume_Formatted_Text__c = this.adHocVolume ? null : this.volume.format(),
                AITM_Requested_Volume_UoM__c = this.requestedVolumeUom,
                AITM_Exchange__c = this.exchangeRate,
                AITM_Round__c = i
            );
        }
    }
}