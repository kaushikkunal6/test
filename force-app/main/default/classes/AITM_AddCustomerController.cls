/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      controller class used in aura component to add new customers to locations

 * history
 * 01/December/2017  George      Created 
 * 28/March/2018     srnandan    added comments at method and class level as per coding standards
 *                               AR-2803-modified method "TenderLocationWrapper" to assign uom 
 *                               of tender to locationlineitem requestedvolumeuom 
 * 11/July/2018      Anusha      AR-3585 and AR-3584 added a new method to get the account details from Account Dao
 ************************************************************************************************/
public with sharing class AITM_AddCustomerController {

    /**
     * @description searches customers based on tenderid and key
     * @param key of type string
     * @param tenderId of type Id
     * @return List collection Account
     */

    public static @AuraEnabled List<Account> searchCustomers(String key, Id tenderId) {
        Map<Id, Account> searchResult = new Map<Id, Account>(new AITM_AccountDao().searchCustomers(key));
        for (AITM_Tender_Account__c existingAccount : new AITM_AccountDao.TenderAccountDao().getTenderAccountForTender(tenderId)) {
            if (searchResult.containsKey(existingAccount.AITM_Account__c)) {
                searchResult.remove(existingAccount.AITM_Account__c);
            }
        }

        return searchResult.values();
    }

    /**
     * @description gets tender locations based on tenderid
     * @param tenderId of type string
     * @return List collection TenderLocationWrapper
     */

    public static @AuraEnabled List<TenderLocationWrapper> getTenderLocations(String tenderId) {
        List<TenderLocationWrapper> result = new List<TenderLocationWrapper>();
        for (AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderId)) {
            result.add(new TenderLocationWrapper(tenderLocation, tenderId));
        }
        return result;
    }

    /**
     * @description saves tenderaccount related data of tender id
     * @param jsonLocations of type string
     * @param accountId of type Id
     * @param tenderId of type Id
     * @return void
     */

    public static @AuraEnabled void saveTenderAccountWithRelatedData(String jsonLocations, Id accountId, Id tenderId) {
        AITM_AddCustomerController controller = new AITM_AddCustomerController();
        controller.saveTenderAccount(accountId, tenderId);
		controller.updateLocationIfStraddled(accountId, tenderId);
        controller.saveTenderLocations(jsonLocations);
			
    }

    /**
     * @description validates tenderaccount related data of accountId
     * @param accountId of type Id
     * @return Boolean
     */
    public static @AuraEnabled Boolean validateTenderAccountWithRelatedData(Id accountId){
        return new AITM_AccountDao().getValidateAccount(accountId);
      
    }

    /**
     * @description saves tender account
     * @param accountId of type Id
     * @param tenderId of type Id
     * @return void
     */
    private void saveTenderAccount(Id accountId, Id tenderId) {
        new AITM_AccountDao.TenderAccountDao().createTenderAccount(accountId, tenderId);
    }

    /**
     * @description searches locations based on tenderid and key
     * @param jsonLocations of type string
     * @return void
     */
    private void saveTenderLocations(String jsonLocations) {
        List<AITM_Tender_Location_Line_Item__c> tenderLocations = new List<AITM_Tender_Location_Line_Item__c>();
        List<TenderLocationWrapper> wrappedLocations = (List<TenderLocationWrapper>) JSON.deserialize(jsonLocations, List<TenderLocationWrapper>.class);
        for (TenderLocationWrapper wrappedRecord : wrappedLocations) {
            if (wrappedRecord.isFilled() && wrappedRecord.isSelected) {
                tenderLocations.add(wrappedRecord.unwrap());
            }
        }

        if (!tenderLocations.isEmpty()) {
            new AITM_TenderLocationDuplicatesHandler().checkForDuplicatesAndSave(tenderLocations);
        }              
    }

    /**
     * @description tender location wrapper inner class
     */
    public class TenderLocationWrapper {
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

        /**
         * @description overloaded constructor
         * @param tenderLocation of type AITM_Tender_Location__c
         * @param tenderId of type string
         */
        public TenderLocationWrapper(AITM_Tender_Location__c tenderLocation, String tenderId) {
            this.locationId = tenderLocation.AITM_Location__c;
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
         * @description returns true if adhocVolume is false
         * @param null
         * @return boolean
         */
        public Boolean isFilled() {
            return this.accountId != null && (this.volume != null || this.adHocVolume);
        }

        /**
         * @description returns tender location line item
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
                AITM_Requested_Volume_UoM__c = this.requestedVolumeUom
            );
        }
    }
    
    /*
    * @description unstraddled location, lineitem if tender customer added
    * @param accountId of type Id
    * @param tenderId of type Id
    * @return void
    */
    @testVisible
	private void updateLocationIfStraddled(Id accountId, Id tenderId){
        List<AITM_Tender_Location_Line_Item__c> listOfItemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
        List<AITM_Tender_Location__c> listOfLocationsToUpdate = new List<AITM_Tender_Location__c>();
        if(accountId != null && tenderId != null) {
            List<AITM_Tender_Location__c> tenderLocations = new AITM_LocationsDao().getStraddledTenderLocations(tenderId);
            if(tenderLocations != null && tenderLocations.size() > 0) {
                for(AITM_Tender_Location__c location : tenderLocations) {
                    location.AITM_Is_Straddled__c = false;
                    listOfLocationsToUpdate.add(location);
                    for(AITM_Tender_Location_Line_Item__c lineItem : location.AITM_Tender_Location__r) {
                        lineItem.AITM_Is_Straddled__c = false;
                        lineItem.AITM_Straddled_Taxes_Fees__c = null;
                        lineItem.AITM_Straddled_Additional_Taxes_Fees__c = null;
                        listOfItemsToUpdate.add(lineItem);
                    }
                }
            }
            if(!listOfLocationsToUpdate.isEmpty()) {
                database.update(listOfLocationsToUpdate, false);
            }
            if(!listOfItemsToUpdate.isEmpty()) {
                database.update(listOfItemsToUpdate, false);
            }
        }
    }
}