/***********************************************************************************************
 * @author           Ravi
 * @date             16/September/2019
 * @group            AirBP
 * @description      controller class used by aura component to add new customer in Tender Location Level

 * history
 * 16/September/2019  Ravi      Created 
 ************************************************************************************************/
public with sharing class AITM_AddCustomerTenderLocation {    
    
    public static  List<AggregateResult> resultRound;
    public static Integer maxRound;
    public static List<AITM_Tender__c> tender;
    
    /**
     * @description gets tender accounts for a tender
     * @param recordId of type Id LocationId
     */
    @AuraEnabled
    public static List<TenderLocationWrapper> getAddCurrentTenderAccount(Id recordId) {

        List<TenderLocationWrapper> result = new List<TenderLocationWrapper>();
        List<AITM_Tender_Location__c> currentTenderId = [Select AITM_Location__c, AITM_Location__r.Name, AITM_IATA_ICAO__c, AITM_Tender__c, AITM_Tender__r.Name, AITM_Tender__r.AITM_Start_Date__c, AITM_Tender__r.AITM_End_Date__c, AITM_Tender__r.AITM_Unit_Of_Measure__c from AITM_Tender_Location__c where Id =: recordId];
        List<String> tenderIdValue = new List<String>();
        for(AITM_Tender_Location__c tender: currentTenderId){
            String t = tender.get('AITM_Tender__c').toString();
            tenderIdValue.add(t);
        }
        Set<AITM_Tender_Account__c> tenderCustomer = new set<AITM_Tender_Account__c> ([select AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Affiliates_Account__c, AITM_Affiliates_Account__r.Name, AITM_Account__c, AITM_Tender__c from AITM_Tender_Account__c Where AITM_Tender__c =: tenderIdValue[0]]);
   		Set<AITM_Tender_Location_Line_Item__c> lineItemAccount = new set<AITM_Tender_Location_Line_Item__c> ([select AITM_Account__c, AITM_Tender_Location__c From AITM_Tender_Location_Line_Item__c Where AITM_Tender_Location__c =: recordId]);
        Set<Id> tenderCustomerSet= New Set<Id>();
        Set<Id> lineItemAccountSet= new Set<Id>();

        /* Assign available Tender Accounts in Tender */
        for(AITM_Tender_Account__c t: tenderCustomer){
            tenderCustomerSet.add(t.AITM_Account__c);            
        }
        /* Assign Accounts in Tender Location Line Item */
        for(AITM_Tender_Location_Line_Item__c l: lineItemAccount){
            lineItemAccountSet.add(l.AITM_Account__c);            
        }
        /* Removed assigned Accounts in the Tender Location Line Item */
        tenderCustomerSet.removeAll(lineItemAccountSet);
        
        /* Remaining Accounts after deleted */
        Map<Id, AITM_Tender_Account__c> remainingAccounts = new Map<Id, AITM_Tender_Account__c>();
        
        /* Filling remaining Account object with reference of Account Id */
        for(AITM_Tender_Account__c t :tenderCustomer) {
            if(tenderCustomerSet.contains(t.AITM_Account__c)) {
                remainingAccounts.put(t.Id,t);
            }
        }
        
        /* Looping Account Id's to fill wrapper class */
        for(Id t :remainingAccounts.keySet()) {
            result.add(new TenderLocationWrapper(currentTenderId[0], tenderIdValue[0], remainingAccounts.get(t)));
        }
       return result;
    }
    
	@AuraEnabled
    public static void updateLocationAndLineItemToUnStraddled(Id locationId) {
        AITM_TenderLocationNewOffer.updateLocationAndLineItemToUnStraddled(locationId);
    }    

    /**
     * @description saves tenderaccount related data of tender id
     * @param jsonLocations of type string
     * @return void
     */
    public static @AuraEnabled void saveTenderAccountWithRelatedData(String jsonLocations) {
        AITM_AddCustomerTenderLocation controller = new AITM_AddCustomerTenderLocation();
        controller.saveTenderLocations(jsonLocations);  
    }

    /**
     * @description searches locations based on tenderid and key
     * @param jsonLocations of type string
     * @return void
     */
     private void saveTenderLocations(String jsonLocations) {
        List<AITM_Tender_Location_Line_Item__c> tenderLocations = new List<AITM_Tender_Location_Line_Item__c>();
        List<TenderLocationWrapper> wrappedLocations = (List<TenderLocationWrapper>) JSON.deserialize(jsonLocations, List<TenderLocationWrapper>.class);
        List<AITM_Tender_Location__c> currentLocationTenderId = [Select AITM_Tender__c, AITM_Is_Straddled__c from AITM_Tender_Location__c where Id =: wrappedLocations[0].tenderLocationId Limit 1];
        String tenderIdValue; 
        tenderIdValue = currentLocationTenderId[0].AITM_Tender__c;
        tender = [SELECT AITM_Number_Of_Locations__c  FROM AITM_Tender__c WHERE Id = :tenderIdValue];
        resultRound =  [SELECT Max(AITM_Round__c) maxRound FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderIdValue];
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

        Boolean isLocationStraddled = currentLocationTenderId[0].AITM_Is_Straddled__c;
        if(isLocationStraddled){
            updateLocationAndLineItemToUnStraddled(wrappedLocations[0].tenderLocationId);
        }
		if (!tenderLocations.isEmpty()) {
            new AITM_TenderLocationDuplicatesHandler().checkForDuplicatesAndSave(tenderLocations);
        }              
     }

    /**
     * @description tender location wrapper inner class
     */
    public class TenderLocationWrapper {
        public @AuraEnabled String accountName;
        public @AuraEnabled String accountGRN;
        public @AuraEnabled String affiliates;
        public @AuraEnabled String locationName;
        public @AuraEnabled String locationCode;
        public @AuraEnabled Boolean isSelected;
        public @AuraEnabled Boolean adHocVolume;
        public @AuraEnabled Integer volume;
        public @AuraEnabled Date startDate;
        public @AuraEnabled Date endDate;
        public @AuraEnabled String requestedVolumeUom;
        public @AuraEnabled Id accountId;
        public @AuraEnabled Id locationId;
        public @AuraEnabled Id tenderId;
        public @AuraEnabled Id tenderLocationId;

        /**
         * @description overloaded constructor
         * @param tenderLocation of type AITM_Tender_Location__c
         * @param tenderId of type string
         * @param tenderAccount of type AITM_Tender_Account__c
         */
        public TenderLocationWrapper(AITM_Tender_Location__c tenderLocation, String tenderId, AITM_Tender_Account__c tenderAccount) {
            this.accountName = tenderAccount.AITM_Account__r.Name;
            this.accountGRN = tenderAccount.AITM_Account__r.AITM_GRN__c;
            this.accountId = tenderAccount.AITM_Account__c;
            this.affiliates = tenderAccount.AITM_Affiliates_Account__r.Name;
            this.locationId = tenderLocation.AITM_Location__c;
            this.tenderLocationId = tenderLocation.Id;
            this.tenderId = tenderId;
            this.locationName = tenderLocation.AITM_Location__r.Name;
            this.locationCode = tenderLocation.AITM_IATA_ICAO__c;
            this.isSelected = false;
            this.adHocVolume = false;
            this.startDate = tenderLocation.AITM_Tender__r.AITM_Start_Date__c;
            this.endDate = tenderLocation.AITM_Tender__r.AITM_End_Date__c;
            this.volume = 0;
            this.requestedVolumeUom = tenderLocation.AITM_Tender__r.AITM_Unit_Of_Measure__c;
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
                AITM_Tender_Location__c = this.tenderLocationId,
                AITM_Volume__c = this.adHocVolume ? null : this.volume,
                AITM_Volume_Formatted_Text__c = this.adHocVolume ? null : this.volume.format(),
                AITM_Requested_Volume_UoM__c = this.requestedVolumeUom
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
                AITM_Tender_Location__c = this.tenderLocationId,
                AITM_Volume__c = this.adHocVolume ? null : this.volume,
                AITM_Volume_Formatted_Text__c = this.adHocVolume ? null : this.volume.format(),
                AITM_Requested_Volume_UoM__c = this.requestedVolumeUom,
                AITM_Round__c = i
            );
        }
    }
}