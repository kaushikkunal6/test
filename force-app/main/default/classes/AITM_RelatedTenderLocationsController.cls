/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      controller being called from aura component "RelatedTenderLocations" holds TenderLocation details               

 * history
 * 01/December/2017  George     Created 
 * 20/March/2018     srnandan   Modified - AR- 2776 - added comments both at method 
 *                              and class level as per coding standards
 * 12/June/2018      Ravi       Modified - AR-3397 - Rounded decimals for offeredVolumeUSG
 * 04/July/2018      srnandan   Modified - Added null condition check for originalRecord.AITM_Total_Volume_Offered_To_The_Group__c
 * 16/August/2018    srnandan   Modified - AR-3342 - Added conditional display of locations based on profile
 * 23/December/2018  srnandan   Modified - AR-4824 Upload loading of locations modified methods getBaseTenderLocations
 *                              setPricingResponsibilities
 * 07/January/2019   Shweta     Modified - AR-4875 Method setPricingResponsibilities to assign the value of the pricer when there is no default delivery point addeed 
 * 09/January/2019   srnandan   Modified - Unique pricing responsibility names and del point to be displayed
 * 16/January/2019   Shweta     Modified - AR-4916 Updated the setpricingresponsibility method to populate location manager of the delivery point if the CA/GA pricer is blank .
 * 14/February/2019  Shweta     Modified - AR-4981 Updated the setpricingresponisbility to set owners of the TLLI on the location details table
 ******************************************************************************************/
public with sharing class AITM_RelatedTenderLocationsController {
    private static final Set<String> LABP_LMPROFILE = new Set<String>{'Air_TMLABPLM','Air_TMLABPLoginLM'};
    private static final Set<String> AIR_LMPROFILE = new Set<String>{'Air_TMLocation Manager'};
    private static final Set<String> AMPROFILE = new Set<String>{'Air_TMLABP','Air_TMAccount Manager', 'Air_TMLABPLogin'};
    private static final String CURRENT_USER_PROFILE = new AITM_UsersDao().getProfileName(UserInfo.getUserId());
    private static final Boolean ISADMIN = AITM_BaseUtils.checkRunningUserIsSystemAdministrator();

    /**
     * @description returns list collection of TenderLocationAdapter based on 
     * tenderId and filter condition
     * @param tenderId of type Id
     * @param filter of type string
     * @return List collection of TenderLocationAdapter
     */
    public static @AuraEnabled List<TenderLocationAdapter> getLocationDetails(Id tenderId, String filter) {
        List<TenderLocationAdapter> locations = new List<TenderLocationAdapter>();
        if (filter == null) {
            locations = getBaseTenderLocations(tenderId);
        } else {
            AITM_RelatedRecordsHolderController.FilterOption parsedFilter = parseFilter(filter);
            if (parsedFilter.isSelectiveFilter()) {
                locations = getFilteredTenderLocations(tenderId, parsedFilter);
            } else {
                locations = getFilteredTenderLocations(tenderId, parsedFilter, true);
            }
        }
        return locations;
    }

    /**
     * @description returns AITM_RelatedRecordsHolderController.FilterOption json object 
     * parsing filter json string
     * @param filterJSON of type string
     * @return AITM_RelatedRecordsHolderController.FilterOption
     */
    private static AITM_RelatedRecordsHolderController.FilterOption parseFilter(String filterJSON) {
        if (filterJSON.contains('locationManagerId')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.LocationManagerFilterOption) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.LocationManagerFilterOption.class);
        } else if (filterJSON.contains('Locations With Volume Mismatch')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.LocationsVolumeMismatchOption) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.LocationsVolumeMismatchOption.class);
        }else if (filterJSON.contains('Locations with Awaiting Price')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.AwaitingPriceLocations) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.AwaitingPriceLocations.class);
        } else if (filterJSON.contains('Locations with Priced')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.PricedLocations) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.PricedLocations.class);
        }
         else if (filterJSON.contains('Represented Locations')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.RepresentedTenderLocations) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.RepresentedTenderLocations.class);
        } else if (filterJSON.contains('Non-represented Locations')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.NotRepresentedTenderLocations) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.NotRepresentedTenderLocations.class);
        } else if (filterJSON.contains('Locations with Quotes')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.LocationsWithQuotesOption) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.LocationsWithQuotesOption.class);
        } else if (filterJSON.contains('Locations without Quotes')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.LocationsWithoutQuotesOption) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.LocationsWithoutQuotesOption.class);
        } else if (filterJSON.contains('Locations with Volumes')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.LocationsWithSpecificVolumes) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.LocationsWithSpecificVolumes.class);
        } else if (filterJSON.contains('Locations with AdHoc Volume')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.LocationAdHocOption) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.LocationAdHocOption.class);
        } else if (filterJSON.contains('Locations to be included in revised offer')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.LocationsRevisedOffer) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.LocationsRevisedOffer.class);
        }
        return (AITM_RelatedRecordsHolderController.FilterOption) JSON.deserialize(filterJSON, AITM_RelatedRecordsHolderController.FilterOption.class);
    }

    /**
     * @description gets tender locations details for a given tender
     * @param tenderId of type Id
     * @return List collection of TenderLocationAdapter
     */
    private static List<TenderLocationAdapter> getBaseTenderLocations(Id tenderId) {
        List<TenderLocationAdapter> locations = new List<TenderLocationAdapter>();
        for(AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getTenderLocationsWithLineItemsForDisplay(tenderId, null,CURRENT_USER_PROFILE)) {
            /*if(LABP_LMPROFILE.contains(CURRENT_USER_PROFILE) && tenderlocation.AITM_Country__c == AITM_LocationsDao.POLISH_COUNTRY) {
                locations.add(new TenderLocationAdapter(tenderLocation));
            } else if(AIR_LMPROFILE.contains(CURRENT_USER_PROFILE) && tenderlocation.AITM_Country__c != AITM_LocationsDao.POLISH_COUNTRY) {
                locations.add(new TenderLocationAdapter(tenderLocation));                    
            } else if(AMPROFILE.contains(CURRENT_USER_PROFILE) || ISADMIN){
                locations.add(new TenderLocationAdapter(tenderLocation));
            } */
            locations.add(new TenderLocationAdapter(tenderLocation));           
        }
        return locations;
    }

    /**
     * @description gets filtered tender locations details for a given tender and parsedfilter passed
     * @param tenderId of type Id
     * @param parsedFilter of type AITM_RelatedRecordsHolderController.FilterOption
     * @return List collection of TenderLocationAdapter
     */
    private static List<TenderLocationAdapter> getFilteredTenderLocations(Id tenderId, AITM_RelatedRecordsHolderController.FilterOption parsedFilter) {
        List<TenderLocationAdapter> locations = new List<TenderLocationAdapter>();
        for(AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getTenderLocationsWithLineItemsForDisplay(tenderId, parsedFilter.getCriteria(),CURRENT_USER_PROFILE)) {
           /* if(LABP_LMPROFILE.contains(CURRENT_USER_PROFILE) && tenderlocation.AITM_Country__c == AITM_LocationsDao.POLISH_COUNTRY) {
                locations.add(new TenderLocationAdapter(tenderLocation));
            } else if(AIR_LMPROFILE.contains(CURRENT_USER_PROFILE) && tenderlocation.AITM_Country__c != AITM_LocationsDao.POLISH_COUNTRY) {
                locations.add(new TenderLocationAdapter(tenderLocation));                    
            } else if(AMPROFILE.contains(CURRENT_USER_PROFILE) || ISADMIN){
                locations.add(new TenderLocationAdapter(tenderLocation));
            }*/
            locations.add(new TenderLocationAdapter(tenderLocation));    

        }
        return locations;
    }

    /**
     * @description gets filtered tender locations details for a given tender and parsedfilter passed
     * @param tenderId of type Id
     * @param parsedFilter of type AITM_RelatedRecordsHolderController.FilterOption
     * @return List collection of TenderLocationAdapter
     */
    private static List<TenderLocationAdapter> getFilteredTenderLocations(Id tenderId, AITM_RelatedRecordsHolderController.FilterOption parsedFilter, Boolean selectivityFlag) {
        List<TenderLocationAdapter> locations = new List<TenderLocationAdapter>();
        for(AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getTenderLocationsWithLineItemsForDisplay(tenderId, null,CURRENT_USER_PROFILE)) {
            /*if (parsedFilter.isPassedFilter(tenderLocation)) {
                if(LABP_LMPROFILE.contains(CURRENT_USER_PROFILE) && tenderlocation.AITM_Country__c == AITM_LocationsDao.POLISH_COUNTRY) {
                    locations.add(new TenderLocationAdapter(tenderLocation));
                } else if(AIR_LMPROFILE.contains(CURRENT_USER_PROFILE) && tenderlocation.AITM_Country__c != AITM_LocationsDao.POLISH_COUNTRY) {
                    locations.add(new TenderLocationAdapter(tenderLocation));                    
                } else if(AMPROFILE.contains(CURRENT_USER_PROFILE) || ISADMIN){
                    locations.add(new TenderLocationAdapter(tenderLocation));
                }            
            }*/
            if (parsedFilter.isPassedFilter(tenderLocation)) {
            locations.add(new TenderLocationAdapter(tenderLocation));
            }   
        }
        return locations;
    }
    
    /**
     * @description adapter class for tenderlocation
     */
    public inherited sharing class TenderLocationAdapter {
        public @AuraEnabled String recordId;
        public @AuraEnabled String locationIdentificator;
        public @AuraEnabled String locationName;
        public @AuraEnabled String country;
        public @AuraEnabled Decimal volumeUSG;
        public @AuraEnabled Decimal offeredVolumeUSG;
        public @AuraEnabled String lastTenderResult;
        public @AuraEnabled String locationManager;
        public @AuraEnabled String locationManagerId;
        public @AuraEnabled String status;
        public @AuraEnabled Decimal round;
        public @AuraEnabled Decimal currentRound;
        public @AuraEnabled String includeRevisedOffer;
        public @AuraEnabled String defaultDelPoint;
        public @AuraEnabled String pricingResponsibility;

        //public @AuraEnabled Boolean displayLink;

        /**
         * @description overloaded constructor assigns values to variables
         * @param originalRecord of AITM_Tender_Location__c
         */
        public TenderLocationAdapter(AITM_Tender_Location__c originalRecord) {
            this.recordId = originalRecord.Id;
            this.locationIdentificator = originalRecord.AITM_IATA_ICAO__c;
            this.locationName = originalRecord.AITM_Location__r.Name;
            this.country = originalRecord.AITM_Country__c;
            this.status = originalRecord.AITM_Status__c;
            this.locationManagerId = originalRecord.AITM_Location_Manager__c;
            this.locationManager = originalRecord.AITM_Location_Manager__r.Name;
            this.lastTenderResult = this.getTenderResult(originalRecord);
            this.includeRevisedOffer = (originalRecord.AITM_Include_In_Revised_Offer__c) ? 'Yes' : 'No';
            this.offeredVolumeUSG = (originalRecord.AITM_Total_Volume_Offered_To_The_Group__c != null ? originalRecord.AITM_Total_Volume_Offered_To_The_Group__c.round(system.roundingMode.HALF_UP) : null);
            this.round = originalRecord.AITM_Round__c;
            this.currentRound = originalRecord.AITM_Current_Round__c;
            this.volumeUSG = (originalRecord.AITM_Total_Requested_Volume__c !=null ? originalRecord.AITM_Total_Requested_Volume__c.round(system.roundingMode.HALF_UP) : null);
            this.setDefaultDelPoints(originalRecord);
            if(originalRecord.AITM_Status__c != 'Not Represented'){
              this.setPricingResponsibilities(originalRecord);
            }
        }

        /**
         * @description sets volumeUSG
         * @param originalRecord of AITM_Tender_Location__c
         * @return void
         */
        public void setVolumes(AITM_Tender_Location__c originalRecord) {
            this.volumeUSG = 0.0;

            for (AITM_Tender_Location_Line_Item__c lineItem : originalRecord.AITM_Tender_Location__r) {
                if (lineItem.AITM_Requested_Volume_USG__c != null) {
                    volumeUSG += lineItem.AITM_Requested_Volume_USG__c;
                }
            }

            this.volumeUSG = this.volumeUSG.round(System.RoundingMode.HALF_UP);
        }


       /**
         * @description sets default delivery points
         * @param originalRecord of AITM_Tender_Location__c
         * @return void
         */
        public void setDefaultDelPoints(AITM_Tender_Location__c originalRecord) {
            this.defaultDelPoint = '';
            List<String> delpoint = new List<String>();
            Set<String> delPointSet = new Set<String>();

            for (AITM_Tender_Location_Line_Item__c lineItem : originalRecord.AITM_Tender_Location__r) {
                if (lineItem.AITM_Delivery_Point_Info__c != 'Select') {
                  delPointSet.add(lineItem.AITM_Delivery_Point_Info__c);
                }
                else {
                    delPointSet.add('None');
                }
            }
            delpoint.addAll(delPointSet);
            this.defaultDelPoint = String.join(delpoint,',');   
        }

        /**
         * @description sets pricing responsibilities
         * @param originalRecord of AITM_Tender_Location__c
         * @return void
         */
        public void setPricingResponsibilities(AITM_Tender_Location__c originalRecord) {
            pricingResponsibility ='';
            List<String> pricingResponsibilityNamesList = new List<String>();
            Set<String> pricingResponsibilityNames = new Set<String>();
            for (AITM_Tender_Location_Line_Item__c lineItem : originalRecord.AITM_Tender_Location__r) {
                  pricingResponsibilityNames.add(lineItem.Owner.Name);
            }
            pricingResponsibilityNamesList.addAll(pricingResponsibilityNames);
			this.pricingResponsibility = String.join(pricingResponsibilityNamesList,',');
        }

        /**
         * @description gets Tender Result History Item
         * @param originalRecord of AITM_Tender_Location__c
         * @return void
         */
        public String getTenderResult(AITM_Tender_Location__c originalRecord) {
            List<String> results = new List<String>();
            String tenderLastResult;

            for (AITM_Tender_Location_Line_Item__c lineItem : originalRecord.AITM_Tender_Location__r) {
                if(!results.contains(lineItem.AITM_History_Line_Item__r.AITM_Tender_Result__c)) {
                    results.add(lineItem.AITM_History_Line_Item__r.AITM_Tender_Result__c);
                }
            }
            if(results.size() == 1) {
                tenderLastResult = results[0];
            } else {
                tenderLastResult = 'XX';
            }
            return tenderLastResult;
        }
    }
}