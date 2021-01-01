/************************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Used for storing queries related to Locations, Tender Customer, Tender Location Staging, 
 *                   Tender Location and Tender Location Line Item objects which can be reused in all related classes.

 * history
 * 01/December/2017  George          Created
 * 07/March/2018     Ravi Pamidi     Modified - AR-2523 Removed AITM_Currency_Pricing_Basis__c, 
 *                                   AITM_Currency_Rebate__c, AITM_Unit_Of_Measure_Rebate__c 
 *                                   fields as they were converted as formula fields.
 * 09/March/2018     srnandan        Modified - AR-2604 - modified the method "getFilteredTenderLocationLineItems" 
 *                                   by adding fields "AITM_Currency_Rebate1__c","AITM_Unit_Of_Measure_Rebate1__c" in query to pass info class AITM_PricingInformationController. 
 *                                   corrected the comments format as per coding standards                                               
 * 12/March/2018     srnandan        Modified - AR-2064 - indentation alignment and removed Id field in query
 *                                   as per coding standards. The Id field is always included with the results of every query.
 * 19/March/2018     Anusha          Modified - AR- 2728 - added field in soql i.e. "AITM_Previous_Round_Differential__c" to the method "getTenderLocation"
 * 20/March/2018     srnandan        Modified - AR- 2726 - added method getTenderLocationsWithLineItemsSummaryByCountry
 * 21/March/2018     srnandan        Modified - AR- 2726 - added method getTenderLocationsWithLineItemsDetailsByCountry
 * 22/March/2018     Ravi            Replaced AITM_Credit_Rating_of_Customer with AITM_Credit_Rating__c
 * 22/March/2018     srnandan        Modified - AR- 2733 - added method getMinimumOfferedDifferentialTenderLocationLineItems
 * 25/March/2018     srnandan        Modified - AR- 2733 - modified methods "getTenderLocationByTenderIdAndRoundNumber" and "getTenderLocation"
 *                                   changed the soql query adding AITM_Distance_From_Leading_Bid1__c
 * 27/March/2018     srnandan        Modified - AR- 2803 - modified method "getTenderAccountsByTenderId", "getTenderLocations(string tenderId)"
 *                                   and "getCurrentRoundTenderLocations" to include field "AITM_Unit_Of_Measure__c" in soql
 * 30/April/2018     srnandan        Modified - AR-2997 - modified method getFilteredTenderLocationLineItems soql added deliverypoint number and name
 * 13/May/2018       srnandan        Modified - AR-2782 - added method getTenderLocationLineItemsByTenderAndAccountId, getTenderLocationLineItemsByTender,
 *                                   updateTenderLocationsAccountId  
 * 14/May/2018       Ravi            Modified - AR-2986 - Added logic to Populate Exchange Rate field 
 *                                   from Account to TLLI
 * 16/May/2018       Shweta A        Modified - AR-2400 - Added method named as updateLineItemsDate for the updation of the New Start and End dates
 *                                    for the TLLI records.  
 * 17/May/2018       srnandan        Modified - AR-3169 - Modified the method getLineItemsWithPricingInformation to include credit days replacing aitm_days__c
 * 23/May/2018       srnandan        Modified - AR-1449 - DEPE Test results modified method - getDeBriefTenderLocationLineItems 
 *                                   soql change included two fields AITM_Currency_Rebate1__c, AITM_Unit_Of_Measure_Rebate1__c
 * 28/May/2018       srnandan        Modified - AR-3179 - Modified method getPricedTenderLocationsForAContract added fields in soql 
 *                                   AITM_Credit_Days__c, AITM_Delivery_Method__c
 * 29/May/2018       Anusha          Modified - AR-3161 - Modified methods getTenderLocationsWithChilds and getFilteredTenderLocationLineItems by adding Ad_hoc_volume__c 
 *                                   to the SOQL query
 * 10/June/2018      srnandan        Modified - AR-3164 - Modified method getTenderLocationsWithDeBriefLineItemsForFeedback included AITM_Density__c in soql
 * 14/June/2018      srnandan        Modified - AR-3543 - Modified method getTenderLocationsWithDeBriefLineItemsForFeedback to include AITM_Rebate__c in soql
 * 15/June/2018      Shweta          Modified - AR-3404 - Modified method getLineItemsWithPricingInformation(Id tenderLocationId) to remove the column AITM_Return_On_WC__c 
 * 15/June/2018      Shweta          Modified - AR-3404 - Modified method getLineItemsWithPricingInformation(Id tenderLocationId) to add the column AITM_Return_On_WC__c
 * 18/June/2018      Ravi            Modified - AR-3362 - Modified method getTenderLocationsWithChilds by adding AITM_Currency__c in query 
 * 29/June/2018      srnandan        Modified - AR-3527 - Modified method getTenderLocationsWithLineItemsDetailsByCountry added filter DEFAULT Record Type 
 * 05/July/2018      srnandan        Modified - AR-3708 - Modified method getTenderLocationsWithDeBriefLineItemsForFeedback included AITM_Duration__c, AITM_Quantity__c
 * 06/July/2018      Shweta          Modified - AR-3698 and AR-3591 - Modified method getTenderLocationsWithDeBriefLineItemsForFeedback,getTenderLocationsWithLineItemsForFeedback,getTenderLocationLineItems(Id tenderId, List<String> criterias, Id recordTypeId)->getFilteredTenderLocationLineItems(List<String> criterias, String tenderId, Id recordTypeId)
 *                                   to include the field AITM_Requested_Volume_UoM__c    
 * 12/July/2018      Ravi            Modified - AR-3716 - Modified method getSearchQueryForLocations to include Country in Locations Search.
 * 25/July/2018      saravana        Modified - AR -3879 - Modified the method getLineItemsWithPricingInformation. Added the fied AITM_JV_Profit_Dividend__c  to SOQL query.
 * 26/July/2018      Anusha          Modified - AR-3892 - Added AITM_Requested_Volume_UoM__c field in the query of getTenderLocationsWithChilds to display the value
 * 27/July/2018      Shweta          Modified - AR-3874 - modified method getTenderLocation(Id tenderLocationId)  to inlude the field AITM_No_Revision__c in the select query
 * 10/August/2018    srnandan        Modified - AR-4011 - added method getTenderLocationsWithLineItemsForFeedback(tenderId, locationType), getTenderLocationsWithDeBriefLineItemsForFeedback
 * 12/August/2018    srnandan        Modified - AR-3345 - added method getTenderLocationMarketLineItems extra param location type
 * 04/Sept/2018      Anusha          Modified - AR-4153 - modified method getTenderLocationLineItems to include the field AITM_Ad_hoc_Volume__c to show adhoc volumes in debrief Loc summary     
 * 03/Dec/2018       Anusha          Modified - AR-4713 - modified method getFilteredTenderResultLocationLineItems and other 4 methods related to debrief results to get AITM_Location__r.AITM_Internal_code__c
 * 03/Dec/2018       Shweta          Modified - AR-4644 - Added 2 new methods getDeliveryPoints
 * 03/Dec/2018       Shweta          Modified - AR-4644 -- Added new method getTenderLocationLineItemsGroupedByAccount
 * 11/December/2018  srnandan        Modified - AR-4624 - Modified methods getLocationsGroupedByResultGained,getLocationsGroupedByResultRetained,getLocationsGroupedByResultLost,
 *                                   getLocationsGroupedByResultMix,getTenderLocationsWithLineItemsForFeedback,getTenderLocationsWithDeBriefLineItemsForFeedback
 *                                   to include deliverypoint new field AITM_Delivery_Point_External_Name__c
 * 23/December/2018  srnandan        Modified - AR-4876 Modified getTenderLocationsWithChilds,getTenderLocationsWithLineItemsDetailsByCountry add fields in soql
 * 29/December/2018  srnandan        Modified - AR-4875 Modified - getTenderLocationWithSectorInformation added in soql fields
 * 02/Jan/2019       Ravi            Modified - AR-4626 - updated Delivery Point related Locations to display in Offer and Contract PDF
 * 07/January/2019   srnandan        Modified - getTenderLocationsWithChilds method to include soql field AITM_Pricer_No_Default_Delivery_Points__r
 * 17/January/2019   srnandan        Modified - AR-4914 added field AITM_Tender_Owner_Profile__c in soql
 * 10/Jan/2019       Anusha          Modified - AR-4645 - Added fields in getTenderLocationWithSectorInformation to display in TLLI page
 * 21/January/2019   saravan         Modified - AR-4911 - Modified the method getTenderLocationsWithLineItemsDetailsByCountry added AITM_Pricer_No_Default_Delivery_Points__r.Name in SOQL
 * 21/January/2019   srnandan        Modified - soql field AITM_Ad_hoc_Volume__c added in the method getTenderLocationLineItem
 * 21/January/2019   Anusha          Modified - AR-4913 - Modified the method getPricedTenderLocationsWithLineItems to get taxes and fees and additonal notes
 * 22/January/2019   srnandan        Modified - AR-4915 added method to delete line items
 * 23/January/2019   srnandan        Modified - AR-4913 included fields measure, taxesandfees, additional notes in soql method getPricedTenderLocationsForAContract
 * 24/January/2019   srnandan        Modified - AR-4913 included recordtypeid in soql getTenderLocationWithSectorInformation
 * 28/January/2019   srnandan        Modified - AR-4824 added soql fields in getTenderLocationsWithLineItemsForFeedback(tenderId)
 * 29/January/2019   srnandan        Modified - AR-4824 included taxesandfees, deliverymethod, additionalnotes field in soql for methods - getLocationsGroupedByResultGained,getLocationsGroupedByResultRetained
 *                                   getLocationsGroupedByResultLost, getLocationsGroupedByResultMix
 * 31/January/2019   Shweta          Modified - AR-4955/AR-4940 Added the fields to be cloned
 * 31/January/2019   srnandan        Modified - AR-4955 to include method insertCloneRecord
 * 04/February/2019  srnandan        Modified - AR-XXXX getFilteredTenderResultLocationLineItems to include inclusive rather negate of exclusive market items
 * 14/Febriuary/2019  Shweta         Modified -AR-4981  Updated the method getTenderLocationLineItem(lineItemId) method
 * 12/February/2019  srnandan        Modified - AR-XXXX added method getTenderLocationLineItemsByTenderForXLS offer generation
 * 17/March/2019     srnandan        Modified - AR-5087 - updated method getTenderLocationsSummaryByCountry adding sorting by country
 * 18/March/2019     saravan         Modified - AR-5080 modified method getTenderLocationsWithLineItemsDetailsByCountry
 * 27/March/2019     Ravi            Modified - AR-5110 Updated the getLocationsGroupedByResultGained, getLocationsGroupedByResultRetained, getLocationsGroupedByResultLost, getLocationsGroupedByResultMix to populate Measure from TLLI
 * 28/March/2019     Ravi            Modified - AR-5114 Updated the getTenderLocationLineItems to populate Internal Code from Delivery Point
 * 01/April/2019     Ravi            Modified - AR-5115 Updated the getPricedTenderLocationsForAffiliatesInContract for Populating Affiliates Account Locations to the Contract PDF generation
 * 17/April/2019     srnandan        Modified - AR-xxxx added new method getRepresentedCurrentRoundCountTenderLocations
 * 29/April/2019     Ravi            Modified - AR-5144 added new method getTenderLocationLineItemsByTenderForFeedbackXLS to populate TLLI fields for Feedback Generate XLS
 * 29/April/2019     Ravi            Modified - AR-5132 added new method getTenderLocationLineItemsByTenderForInvitationkXLS to populate TLLI fields for Invitation Generate XLS
 * 25/May/2019       srnandan        Modified - AR-5029 added soql fields product type, density and product density to method getTenderLocationsWithChilds
 * 10/June/2019      Ravi            Modified - AR-5216 code refined for Large Tenders
 * 13/June/2019      srnandan        Modified - AR-xxxx added new overloaded method getPricedTenderLocationsForAContract takes list of accounts  
 * 16/July/2019      Ravi            Modified - AR-5257 Added getBGBRLocationsCount method for getting count of Debrief Tender results
 * 30/July/2019      srnandan        Added new method for debrief results table display getTenderLocationLineItemsForDebriefResults and getFilteredTenderLocationLineItemsDebriefResults
 * 30/July/2019      srnandan        Modified soql for pricing service in tenderlineitemdao to include aitm_product_default and aitm_density
 * 31/July/2019      srnandan        Added method getTenderLocationLineItemsForTender to resolve large tenders for debrief records
 * 29/August/2019    kunal           WorkItem(677287) - Added method getDebriefLineItemRecords
 * 29/August/2019    kunal           WorkItem(677362) - Modified method getSearchQueryForLocations for Search Refinement on IATA requirement
 * 23/September/2019 srnandan        WorkItem(703002) - Modified method getTenderLocationLineItemsForTender to include soql field AITM_Include_Notes_in_Contract__c
 * 30/Sept/2019      Saravan         WorkItem(737800) - Modified method getTenderLocationLineItem to copy Product Pricing Report in TLLI clone
 * 10/January/2020   Neeti           Added new method getTenderLocationById to replace process builder from apex class to initialize default values on creation.
 * 22/Apr/2020       Saravan         Modified - 108793 Modified the getTenderLocationLineItemsForTender to include Parent Id in  Query
 * 20/May/2020       Ravi            Modified to add validation and remove old taxes and fees field
 * 25/Oct/2020		 Saravan         Modified - For PBI 669532 modified getTenderLocationWithSectorInformation to include AITM_Is_Pricing_Basis_Not_Represented__c 
*************************************************************************************/
public without sharing class AITM_LocationsDao {

    public static final String TLLI_RECORD_TYPE_DEFAULT = 'AITM_Default';
    public static final String TLLI_RECORD_TYPE_DEBRIEF = 'AITM_Debrief';
    public static final String TLLI_RECORD_TYPE_DEBRIEF_NAME = 'De-brief';
    public static final String STATUS_NOT_REPRESENTED = 'Not Represented';
    public static final String STATUS_PRICED = 'Priced';
    public static final ID TLLI_ID_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
    public static final ID DEFAULT_RECORD_TYPE_ID = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId(); 
    public static final String POLISH_COUNTRY = 'POLAND';
    public static final String POLISH_FILTER = 'Polish';
    public static final String LOCATION_LIMIT_FILTER = '10';
	
    /**
    * @description returns list collection of location based on searchKey
    * @param searchKey of type string
    * @return List collection of AITM_Location__c
    */
    public List<AITM_Location__c> searchLocations(String searchKey) {
        /*String searchQuery = getSearchQueryForLocations(searchKey);
        List<List<sObject>> soslLocationsResult = Search.query(searchQuery);
        return (List<AITM_Location__c>) soslLocationsResult[0];
		List<AITM_Location__c> listOflocations = getSearchQueryForLocations(searchKey);
        return listOflocations;*/
		Set<AITM_Location__c> setofLocations = new Set<AITM_Location__c>();
        List<AITM_Location__c> listOfLocations = new List<AITM_Location__c>();
        
        TenderLocationLineItemsQueryBuilder soqlBuilder = new TenderLocationLineItemsQueryBuilder();
        List<AITM_Location__c> iata = Database.query(soqlBuilder.getSearchQueryForLocations(searchKey, 'iata', LOCATION_LIMIT_FILTER));
        setofLocations.AddAll(iata);
        
        if(setofLocations.size() < 11){
            Integer icaoLimit = Integer.valueOf(LOCATION_LIMIT_FILTER) - setofLocations.size();
            soqlBuilder = new TenderLocationLineItemsQueryBuilder();
            List<AITM_Location__c> icao = Database.query(soqlBuilder.getSearchQueryForLocations(searchKey, 'icao', String.valueOf(icaoLimit)));
            setofLocations.AddAll(icao);
        }
        if(setofLocations.size() < 11){
            Integer nameLimit = Integer.valueOf(LOCATION_LIMIT_FILTER) - setofLocations.size();
            soqlBuilder = new TenderLocationLineItemsQueryBuilder();
            List<AITM_Location__c> name = Database.query(soqlBuilder.getSearchQueryForLocations(searchKey, 'name', String.valueOf(nameLimit)));
            setofLocations.AddAll(name);
        }
        if(setofLocations.size() < 11){
            Integer countryLimit = Integer.valueOf(LOCATION_LIMIT_FILTER) - setofLocations.size();
            soqlBuilder = new TenderLocationLineItemsQueryBuilder();
            List<AITM_Location__c> country = Database.query(soqlBuilder.getSearchQueryForLocations(searchKey, 'country', String.valueOf(countryLimit)));
            setofLocations.AddAll(country);
        }
        
        listOfLocations.addAll(setofLocations);
        return listOfLocations;
    }

   /**
    * @description gets Tender Accounts based on filter tenderId.
    * @param tenderId of type string
    * @return List collection of AITM_Tender_Account__c
    */
    public List<AITM_Tender_Account__c> getTenderAccountsByTenderId(String tenderId) {
        return [SELECT AITM_Account__r.Name, AITM_Affiliates_Account__c, AITM_Affiliates_Account__r.Id,AITM_Account__r.AITM_GRN__c, AITM_Account__r.AITM_Exchange_Rate__c, AITM_Account__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Tender__c, AITM_Tender__r.AITM_Start_Date__c, AITM_Tender__r.AITM_End_Date__c, AITM_Tender__r.AITM_Unit_Of_Measure__c FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :tenderId];
    }

   /**
    * @description saves the records in tender location staging object
    * @param rawTenderLocations list collection of AITM_Tender_Location_Line_Item__c
    * @return void
    */
    public void saveTenderLocations(List<AITM_Tender_Location_Line_Item__c> rawTenderLocations) {
        List<Database.SaveResult> results = Database.insert(rawTenderLocations, false);
        
        List<AITM_Tender_Location_Staging__c> stagingObjects = new List<AITM_Tender_Location_Staging__c>();
        for (Integer index = 0; index < results.size(); index++) {
            if(!results[index].isSuccess()) {
                stagingObjects.add(parseLocationStaging(rawTenderLocations[index]));
                
            }
        }

        if (stagingObjects.size() > 0) {
            Database.insert(stagingObjects, false);
        }
    }

   /**
    * @description gets the map value of tender location staging and lineitem records
    * @param tenderId of Id
    * @return Map<Id, AITM_Tender_Location_Line_Item__c>
    */
    public Map<Id, AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsFromStaging(Id tenderId) {
        Map<Id, AITM_Tender_Location_Line_Item__c> mapLineItems = new Map<Id, AITM_Tender_Location_Line_Item__c>();
        for(AITM_Tender_Location_Staging__c staging : [SELECT AITM_Account__c, AITM_End_Date__c, AITM_Location__c, AITM_Start_Date__c, AITM_Tender__c, AITM_Unit_Of_Measure__c, AITM_Volume__c FROM AITM_Tender_Location_Staging__c where AITM_Tender__c =:tenderId]) {
            mapLineItems.put(staging.Id, parseLocationLineItem(staging));
        }
        return mapLineItems;
    }

   /**
    * @description updates the records in tender location staging object
    * @param rawTenderLocations list collection of AITM_Tender_Location_Line_Item__c
    * @return void
    */
    public void updateTenderLocationsAccountId(List<AITM_Tender_Location_Line_Item__c> rawTenderLocations) {
        Database.update(rawTenderLocations, false);
    }

   /**
    * @description updates the records in tender location line items
    * @param lineItems list collection of AITM_Tender_Location_Line_Item__c
    * @return void
    */
    public void updateLineItemsDate(List<AITM_Tender_Location_Line_Item__c> lineItems) {
        Database.update(lineItems, false);
        lineItems.clear();
    }

   /**
    * @description returns map location IATA,ICAO and Id
    * @param codes collection set of codes
    * @return Map collection of string and Id
    */
    public Map<String, Id> getLocationsGroupedByCodes(Set<String> codes) {
        Map<String, Id> result = new Map<String, Id>();
        for (AITM_Location__c location : this.getLocationsByCodes(codes)) {
            result.put(location.AITM_IATA__c, location.Id);
            result.put(location.AITM_ICAO__c, location.Id);
        }
        return result;
    }

   /**
    * @description This method used to get Locations group by code.
    * @param codes
    * @return List collection of AITM_Location__c
    */
    public List<AITM_Location__c> getLocationsByCodes(Set<String> codes) {
        return [SELECT AITM_IATA__c, AITM_ICAO__c FROM AITM_Location__c WHERE AITM_IATA__c IN :codes OR AITM_ICAO__c IN :codes];
    }

   /**
    * @description gets the tender locations based on filter tenderId
    * @param tenderId of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getTenderLocationsInDebrief(Id tenderId) {
        return [SELECT AITM_IATA_ICAO__c, AITM_Service_Level__c, AITM_Aircraft_Type__c, AITM_Total_Requested_Volume__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Ad_hoc_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Product__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, AITM_Location__r.AITM_Internal_code__c,(select Id, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Location__r.Name, AITM_Location__r.AITM_Country__c, AITM_Product_Default__c, AITM_Account__r.Name, AITM_Line_Item_Name_Account__c, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Delivery_Method__c, AITM_Measure__c, AITM_Tender_Location__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.AITM_Last_Tender_Result__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Location__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c FROM AITM_Tender_Location__r WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF ORDER BY AITM_Offered_Volume__c DESC) from AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId LIMIT 50];
    }

    /**
    * @description gets the tender locations based on filter tenderId
    * @param tenderId of type Id
    * @param locationtype of type String
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getTenderLocationsInDebrief(Id tenderId,String locationtype) {
        if(locationtype == POLISH_FILTER){
           return [SELECT AITM_IATA_ICAO__c,AITM_Location__r.Name,AITM_Location_Manager__r.Name,AITM_Service_Level__c,AITM_Aircraft_Type__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Locations_Filter__c = : POLISH_FILTER AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
        } else{
            return [SELECT AITM_IATA_ICAO__c,AITM_Location__r.Name,AITM_Location_Manager__r.Name,AITM_Service_Level__c,AITM_Aircraft_Type__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Locations_Filter__c != : POLISH_FILTER AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
        }
    }

   /**
    * @description gets the tender locations based on filter tenderId
    * @param tenderId of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getTenderLocations(Id tenderId) {
        return [SELECT AITM_Status__c, AITM_Tender__c, AITM_Tender__r.Name, AITM_Country__c, AITM_Round__c, AITM_Current_Round__c, AITM_Has_Feedback__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Email, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.FirstName, AITM_Location_Manager__r.LastName, AITM_Location__c, AITM_Location__r.AITM_Delegates__c, AITM_Location__r.Name, AITM_Tender__r.AITM_Unit_Of_Measure__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId];
    }

   /**
    * @description gets tender locations based on filter tenderid and round
    * @param tenderId of type Id
    * @param round of type Integer
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getTenderLocations(Id tenderId, Integer round) {
        return [SELECT AITM_Status__c, AITM_Tender__c, AITM_Tender__r.Name, AITM_Country__c, AITM_Round__c, AITM_Current_Round__c, AITM_Has_Feedback__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Email, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.FirstName, AITM_Location_Manager__r.LastName, AITM_Location__c, AITM_Location__r.AITM_Delegates__c, AITM_Location__r.Name FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Round__c = :round];
    }

   /**
    * @description This method is used to get Current Round Tender Locations.
    * @param Id of tenderId
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getCurrentRoundTenderLocations(Id tenderId) {
        return [SELECT AITM_Status__c, AITM_Country__c, AITM_Round__c, AITM_Current_Round__c, AITM_Has_Feedback__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Email, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.FirstName, AITM_Location_Manager__r.LastName, AITM_Location__c, AITM_Location__r.AITM_Delegates__c, AITM_Location__r.Name, AITM_Tender__c, AITM_Tender__r.Name, AITM_Tender__r.OwnerId, AITM_IATA_ICAO__c, AITM_Tender__r.AITM_Start_Date__c, AITM_Tender__r.AITM_End_Date__c, AITM_Tender__r.AITM_Unit_Of_Measure__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true Order by AITM_Location__r.Name ];
    }

   /**
    * @description gets Current Round Tender Locations.
    * @param tenderIds of type set collection Id
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getCurrentRoundTenderLocations(Set<Id> tenderIds) {
        return [SELECT AITM_Status__c, AITM_Country__c, AITM_Round__c, AITM_Current_Round__c, AITM_Has_Feedback__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Email, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.FirstName, AITM_Location_Manager__r.LastName, AITM_Location__c, AITM_Location__r.AITM_Delegates__c, AITM_Location__r.Name, AITM_Tender__c, AITM_Tender__r.Name, AITM_Tender__r.OwnerId, AITM_IATA_ICAO__c, AITM_Tender__r.AITM_Start_Date__c, AITM_Tender__r.AITM_End_Date__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c IN :tenderIds AND AITM_Is_Current_Round__c = true Order by AITM_Location__r.Name ];
    }

    /**
     * @description gets Tender Location Line Items by Record Type.
     * @param tenderLocationId of type Id
     * @param accId of type Id
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsBytenderLocationAndAccountId(Id tenderLocationId, Id accId) {
        return [SELECT Name, AITM_Account__c, AITM_Old_Taxes_Fees_Flag__c, AITM_Previous_Round_Differential__c, AITM_Account__r.AITM_GRN__c, AITM_Awarded_Volume__c, AITM_Account__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Location_Delivery_Point__c, AITM_Description__c, AITM_Pricing_Excellence__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.Name, AITM_Volume__c, AITM_Round__c, AITM_Requested_Volume_USG__c, AITM_Offered_Volume__c,  AITM_Percentage_Volume_Offered__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Differential__c,AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c,AITM_Delivery_Point_Info__c,AITM_Location_Delivery_Point__r.AITM_Pricing_Basis_CA__c FROM AITM_Tender_Location_Line_Item__c  WHERE AITM_Tender_Location__c = :tenderLocationId AND AITM_Account__c =:accId];
    }

    /**
     * @description gets Tender Location Line Items to delete
     * @param tenderLocationId of type Id
     * @param accId of type Id
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsBytenderLocationAndAccountIdForDelete(Id tenderLocationId, Id accId) {
        return [SELECT AITM_Tender_Owner_Profile__c FROM AITM_Tender_Location_Line_Item__c  WHERE AITM_Tender_Location__c = :tenderLocationId AND AITM_Account__c =:accId];
    }
    
    /**
     * @description gets Tender Location Line Items to delete
     * @param tenderLocationId of type Id
     * @param accId of type Id
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public String deleteTenderLocationLineItems(List<AITM_Tender_Location_Line_Item__c> lineItems) {
        String oErrorMsg = '';
        Database.DeleteResult[] drList = Database.delete(lineItems, false);
        for(Database.DeleteResult dr : drList) {
            if (!dr.isSuccess()) {
                // Operation failed, so get all errors
                for(Database.Error err : dr.getErrors()) {
                    oErrorMsg ='Error deleting tender Location Line Item record(s)';
                }
            }
        }
        return oErrorMsg;   
    }

    /**
     * @description get delivery points related to location
     * @param locationId of type Id    
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Delivery_Point__c>getDeliveryPointRelatedLocation(Id locationId) {
        return [Select Name, AITM_Is_Active__c, AITM_Default_Delivery_Point__c,AITM_BPInter_Location_DeliveryPoint_Cod__c,AITM_Pricing_Basis_CA__c,AITM_Pricing_Basis_GA__c  FROM AITM_Delivery_Point__c WHERE AITM_Location__c = :locationId AND AITM_Is_Active__c = true];
    }

   /**
    * @description gets Represented Current Round Tender Locations.
    * @param tenderId of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getRepresentedCurrentRoundTenderLocations(Id tenderId) {
        return [SELECT AITM_Status__c, AITM_Country__c, AITM_Round__c, AITM_Current_Round__c, AITM_Has_Feedback__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Email, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.FirstName, AITM_Location_Manager__r.LastName, AITM_Location__c, AITM_Location__r.AITM_Delegates__c, AITM_Location__r.Name, AITM_Tender__c, AITM_Tender__r.Name, AITM_Tender__r.OwnerId FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
    }

   /**
    * @description gets Represented Current Round Tender Locations count.
    * @param tenderId of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public Integer getRepresentedCurrentRoundCountTenderLocations(Id tenderId) {
        List<AggregateResult> result = [SELECT count(Id) total FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
        return Integer.valueOf(result[0].get('total'));
    }
    /**
    * @description gets Represented Current Round Tender Locations count.
    * @param tenderId of type Id
    * @param locationType of type String
    * @return List collection of AITM_Tender_Location__c
    */
    public Integer getRepresentedCurrentRoundCountTenderLocations(Id tenderId, String locationType) {
        List<AggregateResult> result;
        if(locationType == POLISH_FILTER) {
            result = [SELECT count(Id) total FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Locations_Filter__c = : POLISH_FILTER AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
            return Integer.valueOf(result[0].get('total'));
        }else{ 
        result = [SELECT count(Id) total FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Locations_Filter__c != : POLISH_FILTER AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
        return Integer.valueOf(result[0].get('total'));
        }
    }

   /**
    * @description gets Current Round Tender Locations count.
    * @param tenderId of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public Integer getCurrentRoundCountTenderLocations(Id tenderId) {
        List<AggregateResult> result = [SELECT count(Id) total FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true];
        return Integer.valueOf(result[0].get('total'));
    }
    /**
    * @description gets Current Round Tender Locations count.
    * @param tenderId of type Id
    * @param locationType of type String
    * @return List collection of AITM_Tender_Location__c
    */
    public Integer getCurrentRoundCountTenderLocations(Id tenderId, String locationType) {
        List<AggregateResult> result;
        if(locationType == POLISH_FILTER) {
            result = [SELECT count(Id) total FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Locations_Filter__c = : POLISH_FILTER AND AITM_Is_Current_Round__c = true];
            return Integer.valueOf(result[0].get('total'));
        }    
        result = [SELECT count(Id) total FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Locations_Filter__c != : POLISH_FILTER AND AITM_Is_Current_Round__c = true];
        return Integer.valueOf(result[0].get('total'));
    }

   /**
    * @description gets Tender Locations based on filter set collection tenderLocationId.
    * @param tenderLocationIds of type List collection of Id
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getTenderLocationsByIds(List<Id> tenderLocationsIds) {
        return [SELECT AITM_Is_Straddled__c,AITM_Apply_All_Tax_Fee_Check__c, AITM_Status__c, AITM_Tender__c, AITM_Total_Requested_Volume__c, AITM_Tender__r.Name, AITM_Tender__r.OwnerId, AITM_Country__c, AITM_Round__c, AITM_Current_Round__c, AITM_Has_Feedback__c, AITM_Recalculate_Total_Volume__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Email, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.FirstName, AITM_Location_Manager__r.LastName, AITM_Location__c, AITM_Location__r.AITM_Delegates__c, AITM_Location__r.Name, AITM_Location__r.AITM_IATA__c, AITM_Location__r.AITM_ICAO__c FROM AITM_Tender_Location__c WHERE Id IN  :tenderLocationsIds];
    }

   /**
    * @description gets Tender Locations with Line Items based on tenderId and collection of filter criteria.
    * @param tenderId of type Id 
    * @param criterias List collection of string
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getTenderLocationsWithLineItems(Id tenderId, List<String> criterias) {
        LocationsQueryBuilder locationSoqlBuilder = new LocationsQueryBuilder();
        return (List<AITM_Tender_Location__c>) Database.query(locationSoqlBuilder.getTenderLocationsWithChilds(criterias, tenderId, false));
    }

    /**
    * @description gets Tender Locations with Line Items based on tenderId and collection of filter criteria for large tenders
    * @param tenderId of type Id 
    * @param criterias List collection of string
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getTenderLocationsWithLineItemsForDisplay(Id tenderId, List<String> criterias,String profileName) {
        LocationsQueryBuilder locationSoqlBuilder = new LocationsQueryBuilder();
        return (List<AITM_Tender_Location__c>) Database.query(locationSoqlBuilder.getTenderLocationsWithChildsForDisplay(criterias, tenderId, false,profileName));
    }


   /**
    * @description gets delivery point when tender sector is CA
    * @param locationId of type Id
    * @return List collection of AITM_Delivery_Point__c
    */
    public List<AITM_Delivery_Point__c> getDeliveryPoints(Id locationId, Set<String> sector) {
        return [SELECT  Name, AITM_Is_Active__c,AITM_Default_Delivery_Point__c,AITM_BPInter_Location_DeliveryPoint_Cod__c,AITM_Pricing_Basis_CA__c,AITM_Pricing_Basis_GA__c  FROM AITM_Delivery_Point__c WHERE AITM_Location__c = :locationId AND AITM_Default_Delivery_Point__c IN :sector AND AITM_Is_Active__c = true];
    }

   /**
    * @description gets Priced Tender Locations with Line Itmes.
    * @param tenderId of type Id 
    * @param criterias List collection of type String
    * @param filterName of type string
    * @return List of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getPricedTenderLocationsWithLineItems(Id tenderId, List<String> criterias, String filterName) {
        LocationsQueryBuilder locationSoqlBuilder = new LocationsQueryBuilder();
        
        List<String> fieldCriterias = (criterias == null) ? new List<String>() : criterias;

        fieldCriterias.add('AITM_Is_Current_Round__c = true');
        
        if(filterName == 'represented locations'){
            fieldCriterias.add('AITM_Status__c = \'' + STATUS_PRICED + '\'');
        }else if(filterName == 'non-represented locations'){
            fieldCriterias.add('AITM_Status__c = \'' + STATUS_NOT_REPRESENTED + '\'');
        }else{
            fieldCriterias.add('(AITM_Status__c = \'' + STATUS_PRICED + '\' OR AITM_Status__c = \'' + STATUS_NOT_REPRESENTED + '\')');
        }

        return (List<AITM_Tender_Location__c>) Database.query(locationSoqlBuilder.getTenderLocationsWithChilds(fieldCriterias, tenderId, false));
    }

   /**
    * @description gets Tender Locations summary by country.
    * @param tenderId of type Id
    * @param roundNumber of type string
    * @return List collection of AggregateResult
    */
    public List<AggregateResult> getTenderLocationsSummaryByCountry(Id tenderId, Integer roundNumber) {
        return [SELECT AITM_Location__r.AITM_Country__c COUNTRY, AITM_Location_Manager__c LOCATIONMANAGERID, AITM_Location_Manager__r.Name LOCATIONMANAGER, count(Name) TOTALNUMBEROFLOCATIONS, sum(AITM_Volume__c) TOTALREQUESTEDVOLUMEUSG, sum(AITM_Total_Volume_Offered_To_The_Group__c) TOTALOFFEREDVOLUME, AITM_Status__c STATUS, AITM_Tender__r.AITM_Unit_Of_Measure__c UOM FROM AITM_Tender_Location__c where AITM_Tender__r.Id = :tenderId and AITM_Round__c =: roundNumber group by AITM_Location__r.AITM_Country__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Status__c, AITM_Tender__r.AITM_Unit_Of_Measure__c ORDER BY AITM_Location__r.AITM_Country__c ASC];
    }

   /**
    * @description gets Tender Locations summary by country specific user
    * @param tenderId of type Id
    * @param roundNumber of type string
    * @param userId of type Id
    * @return List collection of AggregateResult
    */
    public List<AggregateResult> getTenderLocationsSummaryByCountry(Id tenderId, Integer roundNumber, Id userId) {
        List<AggregateResult> results = new List<AggregateResult>();
        if(userId == null){
                results = getTenderLocationsSummaryByCountry(tenderId, roundNumber);
            } else {
                results = [SELECT AITM_Location__r.AITM_Country__c COUNTRY, AITM_Location_Manager__c LOCATIONMANAGERID, AITM_Location_Manager__r.Name LOCATIONMANAGER, count(Name) TOTALNUMBEROFLOCATIONS, sum(AITM_Volume__c) TOTALREQUESTEDVOLUMEUSG, sum(AITM_Total_Volume_Offered_To_The_Group__c) TOTALOFFEREDVOLUME, AITM_Status__c STATUS, AITM_Tender__r.AITM_Unit_Of_Measure__c UOM FROM AITM_Tender_Location__c where AITM_Tender__r.Id = :tenderId and AITM_Round__c =: roundNumber and AITM_Location_Manager__c =: userId group by AITM_Location__r.AITM_Country__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Status__c, AITM_Tender__r.AITM_Unit_Of_Measure__c ORDER BY AITM_Location__r.AITM_Country__c ASC];
            }    

        return results;
    }

    /**
    * @description gets Tender Locations summary by country specific user
    * @param tenderId of type Id
    * @param roundNumber of type string
    * @param userId of type Id
    * @return List collection of AggregateResult
    */

    public List<AggregateResult> getTenderLocationsSummaryByCountryLABPNONOWNER(Id tenderId, Integer roundNumber, Id userId) {
        List<AggregateResult> results = new List<AggregateResult>();
        if(userId == null){
                results = getTenderLocationsSummaryByCountry(tenderId, roundNumber);
            } else {
                results = [SELECT AITM_Location__r.AITM_Country__c COUNTRY, AITM_Location_Manager__c LOCATIONMANAGERID, AITM_Location_Manager__r.Name LOCATIONMANAGER, count(Name) TOTALNUMBEROFLOCATIONS, sum(AITM_Volume__c) TOTALREQUESTEDVOLUMEUSG, sum(AITM_Total_Volume_Offered_To_The_Group__c) TOTALOFFEREDVOLUME, AITM_Status__c STATUS, AITM_Tender__r.AITM_Unit_Of_Measure__c UOM FROM AITM_Tender_Location__c where AITM_Tender__r.Id = :tenderId and AITM_Round__c =: roundNumber  and AITM_Location__r.AITM_Country__c = :POLISH_COUNTRY group by AITM_Location__r.AITM_Country__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Status__c, AITM_Tender__r.AITM_Unit_Of_Measure__c ORDER BY AITM_Location__r.AITM_Country__c ASC];
            }    

        return results;
    }


   /**
    * @description gets Tender Locations with Line Items details by country.
    * @param tenderId of type Id
    * @param countryName of type string
    * @param userId of type Id
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationsWithLineItemsDetailsByCountry(Id tenderId, String countryName, Integer roundNumber, Id userId) {
        if(userId == null){
            return [SELECT AITM_Start_Date__c, AITM_Product_Default__c,AITM_Account__r.AITM_Account_Classification__c, AITM_Delivery_Method__c,AITM_End_Date__c,AITM_Pricing_Type__c,AITM_Account__r.AITM_GRN__c,AITM_Pricing_Basis__r.AITM_Type__c, AITM_Location__r.AITM_Country__c, AITM_Percentage_Volume_Offered__c, AITM_Tender_Location__r.AITM_Stage__c, AITM_Current_Value__c, AITM_Tender_Location__c,AITM_Location_Manager__c, AITM_Currency__c, AITM_Previous_Round_Differential__c, AITM_Unit_Of_Measure__c, AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.Name, AITM_Tender_Location__r.AITM_Include_In_Revised_Offer__c, AITM_Current_Round__c, AITM_Round__c, AITM_Requested_Volume_USG__c, AITM_Offered_Volume__c, AITM_Delivery_Point_Info__c, AITM_Status__c, AITM_Location__c, AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c, AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name, AITM_Tender_Location__r.AITM_Status__c, AITM_Location__r.Name, AITM_Tender__c, AITM_Tender__r.Name, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender_Location__r.AITM_IATA_ICAO__c, AITM_Account__c, AITM_Account__r.Name, AITM_Tender_Location__r.AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Pricer_No_Default_Delivery_Points__r.Name FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId and AITM_Tender_Location__r.AITM_Location__r.AITM_Country__c = :countryName and AITM_Round__c =:roundNumber and RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEFAULT order by AITM_Tender_Location__r.AITM_IATA_ICAO__c, AITM_Location__r.Name];
        } else {            
            return [SELECT AITM_Start_Date__c, AITM_Product_Default__c,AITM_Account__r.AITM_Account_Classification__c, AITM_Delivery_Method__c,AITM_End_Date__c,AITM_Pricing_Type__c,AITM_Account__r.AITM_GRN__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Location__r.AITM_Country__c, AITM_Percentage_Volume_Offered__c, AITM_Current_Value__c, AITM_Tender_Location__r.AITM_Stage__c, AITM_Tender_Location__c,AITM_Location_Manager__c, AITM_Currency__c, AITM_Previous_Round_Differential__c, AITM_Unit_Of_Measure__c, AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.Name, AITM_Tender_Location__r.AITM_Include_In_Revised_Offer__c, AITM_Current_Round__c, AITM_Round__c, AITM_Requested_Volume_USG__c, AITM_Offered_Volume__c, AITM_Delivery_Point_Info__c, AITM_Status__c, AITM_Location__c, AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c, AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name, AITM_Tender_Location__r.AITM_Status__c, AITM_Location__r.Name, AITM_Tender__c, AITM_Tender__r.Name, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender_Location__r.AITM_IATA_ICAO__c, AITM_Account__c, AITM_Account__r.Name, AITM_Tender_Location__r.AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Pricer_No_Default_Delivery_Points__r.Name FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId and AITM_Tender_Location__r.AITM_Location__r.AITM_Country__c = :countryName and AITM_Round__c =:roundNumber and AITM_Tender_Location__r.AITM_Location_Manager__c =: userId and RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEFAULT order by AITM_Tender_Location__r.AITM_IATA_ICAO__c, AITM_Location__r.Name];
        }
    }

   /**
    * @description gets Tender Locations with Line Items for Feedback.
    * @param tenderId of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationsWithLineItemsForFeedback(Id tenderId) {
        return [SELECT Id, AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c, AITM_Tender_Location__r.AITM_Location_Manager__r.Name, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_Position__c, AITM_Tender_Location__r.AITM_IATA_ICAO__c, AITM_Tender_Location__r.AITM_Comments__c, AITM_Tender_Location__r.AITM_Leading_Bid__c, AITM_Tender_Location__r.AITM_Location_Manager__c, AITM_Tender_Location__r.AITM_Location_Manager__r.Email, AITM_Location_Manager__r.Name, AITM_Tender_Location__r.AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, AITM_Location__r.AITM_Delegates__c, AITM_Location_Delivery_Point__c, AITM_Account__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c,AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Offered_Differential__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Account__r.AITM_GRN__c, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Gross_Profit__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Email,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Email,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c,AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Email,AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender__c, AITM_Tender_Location__r.AITM_Current_Round__c FROM AITM_Tender_Location_Line_Item__c WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEFAULT AND AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Status__c != :STATUS_NOT_REPRESENTED ORDER BY AITM_Requested_Volume_USG__c DESC NULLS LAST LIMIT 50];
    }

   /**
    * @description gets Tender Locations with Line Items for Feedback.
    * @param tenderId of type Id
    * @param locationType of type String
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getTenderLocationsWithLineItemsForFeedback(Id tenderId, String locationType) {
        if(locationType == AITM_TenderDao.POLISH) {
            return [Select AITM_IATA_ICAO__c,AITM_Location_Manager__r.Name,AITM_Comments__c,AITM_Position__c,AITM_Leading_Bid__c,AITM_Current_Round__c,(SELECT AITM_Requested_Volume_USG__c,AITM_Account__r.Name,AITM_Offered_Volume__c,AITM_Pricing_Basis__r.Name,AITM_Offered_Differential__c,AITM_Currency__c,AITM_Unit_Of_Measure__c from AITM_Tender_Location__r WHERE AITM_Record_Type_Name__c !='De-brief' ORDER BY AITM_Requested_Volume_USG__c ASC) from AITM_Tender_Location__c where AITM_Tender__c =:tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED AND AITM_Locations_Filter__c =:POLISH_FILTER LIMIT 50 ];

        } else {
            return [Select AITM_IATA_ICAO__c,AITM_Location_Manager__r.Name,AITM_Comments__c,AITM_Position__c,AITM_Leading_Bid__c,AITM_Current_Round__c,(select AITM_Requested_Volume_USG__c,AITM_Account__r.Name,AITM_Offered_Volume__c,AITM_Pricing_Basis__r.Name,AITM_Offered_Differential__c,AITM_Currency__c,AITM_Unit_Of_Measure__c from AITM_Tender_Location__r WHERE AITM_Record_Type_Name__c !='De-brief' ORDER BY AITM_Requested_Volume_USG__c ASC) from AITM_Tender_Location__c where AITM_Tender__c =:tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED AND AITM_Locations_Filter__c !=:POLISH_FILTER LIMIT 50];
            //return [ FROM AITM_Tender_Location_Line_Item__c WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEFAULT AND AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Locations_Filter__c !=:POLISH_FILTER AND AITM_Tender_Location__r.AITM_Status__c != :STATUS_NOT_REPRESENTED ORDER BY AITM_Requested_Volume_USG__c DESC NULLS LAST];
        }
    }

   /**
    * @description gets debrief Tender Locations Line Items for Feedback
    * @param tenderId of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    //public List<AITM_Tender_Location__c> getTenderLocationsWithDeBriefLineItemsForFeedback(Id tenderId) {
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationsWithDeBriefLineItemsForFeedback(Id tenderId) {
        //return [SELECT AITM_IATA_ICAO__c, AITM_Total_Volume_Offered_To_The_Group__c,AITM_Total_Requested_Volume__c, AITM_Ad_hoc_Volume__c, AITM_Location_Manager__c,AITM_Delivery_Method__c, AITM_Product__c, AITM_Density__c, AITM_Specification__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, (SELECT Id, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Location__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Variance__c, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Debrief_Notes__c FROM AITM_Tender_Location__r WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF) FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
        return [SELECT Id, AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Email, AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Email, AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Email, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c, AITM_Tender_Location__r.AITM_Current_Round__c, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_IATA_ICAO__c, AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c, AITM_Tender_Location__r.AITM_Total_Requested_Volume__c, AITM_Ad_hoc_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Tender_Location__r.AITM_Product__c, AITM_Density__c, AITM_Specification__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_Tender_Location__r.AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, AITM_Account__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Variance__c, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Debrief_Notes__c FROM AITM_Tender_Location_Line_Item__c WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF AND AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Status__c != :STATUS_NOT_REPRESENTED Limit 50];
    }

   /**
    * @description gets debrief Tender Locations Line Items for Feedback
    * @param tenderId of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    //public List<AITM_Tender_Location__c> getTenderLocationsWithDeBriefLineItemsForFeedback(Id tenderId, String locationType) {
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationsWithDeBriefLineItemsForFeedback(Id tenderId, String locationType) {
        if(locationType == AITM_TenderDao.POLISH) {
            //return [SELECT AITM_IATA_ICAO__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Ad_hoc_Volume__c,AITM_Total_Requested_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Product__c, AITM_Density__c, AITM_Specification__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, (SELECT Id, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Location__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Variance__c, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Debrief_Notes__c FROM AITM_Tender_Location__r WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF) FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Locations_Filter__c =:POLISH_FILTER AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
            return [SELECT Id, AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Email, AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Email, AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Email, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c, AITM_Tender_Location__r.AITM_Current_Round__c, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_IATA_ICAO__c, AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c, AITM_Tender_Location__r.AITM_Total_Requested_Volume__c, AITM_Ad_hoc_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Tender_Location__r.AITM_Product__c, AITM_Density__c, AITM_Specification__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_Tender_Location__r.AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, AITM_Account__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Variance__c, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Debrief_Notes__c FROM AITM_Tender_Location_Line_Item__c WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF AND AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Status__c != :STATUS_NOT_REPRESENTED Limit 50];
        } else {
            //return [SELECT AITM_IATA_ICAO__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Ad_hoc_Volume__c,AITM_Total_Requested_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Product__c, AITM_Density__c, AITM_Specification__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, (SELECT Id, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Location__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Variance__c, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Debrief_Notes__c FROM AITM_Tender_Location__r WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF) FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Locations_Filter__c !=:POLISH_FILTER AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
            return [SELECT Id, AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Email, AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Email, AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Email, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c, AITM_Tender_Location__r.AITM_Current_Round__c, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_IATA_ICAO__c, AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c, AITM_Tender_Location__r.AITM_Total_Requested_Volume__c, AITM_Ad_hoc_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Tender_Location__r.AITM_Product__c, AITM_Density__c, AITM_Specification__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_Tender_Location__r.AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, AITM_Account__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Variance__c, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Debrief_Notes__c FROM AITM_Tender_Location_Line_Item__c WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF AND AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Status__c != :STATUS_NOT_REPRESENTED Limit 50];
        }            
    }

     /**
     * @description to fetch LOms and Delegates of the Locations in To part of the debrief email
     * @param tenderId of Id
     * @param locationType of String
     * @return List of <AITM_Tender_Location__Line_Item__c
     */ 

     public List<AITM_Tender_Location_Line_Item__c> getTenderLocationsWithDeBriefLineItemsForLMs(Id tenderId, String locationType) {
        if(locationType == AITM_TenderDao.POLISH) {
            //return [SELECT AITM_IATA_ICAO__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Ad_hoc_Volume__c,AITM_Total_Requested_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Product__c, AITM_Density__c, AITM_Specification__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, (SELECT Id, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Location__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Variance__c, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Debrief_Notes__c FROM AITM_Tender_Location__r WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF) FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Locations_Filter__c =:POLISH_FILTER AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
            return [SELECT owner.email,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c FROM AITM_Tender_Location_Line_Item__c WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF AND AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED AND AITM_Tender_Location__r.AITM_Locations_Filter__c =:AITM_TenderDao.POLISH];
        } else {
            //return [SELECT AITM_IATA_ICAO__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Ad_hoc_Volume__c,AITM_Total_Requested_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Product__c, AITM_Density__c, AITM_Specification__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, (SELECT Id, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Location__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Variance__c, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Debrief_Notes__c FROM AITM_Tender_Location__r WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF) FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Locations_Filter__c !=:POLISH_FILTER AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
            return [SELECT owner.email,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c FROM AITM_Tender_Location_Line_Item__c WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF AND AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED AND AITM_Tender_Location__r.AITM_Locations_Filter__c !=:AITM_TenderDao.POLISH];
        }            
    }

   /**
    * @description gets Tender Result Filter in Debrief Tender Location Line Item
    * @param tenderId of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public Integer getBGBRLocationsCount(Id tenderId, String locationType) {
        List<AggregateResult> result;
        result = [SELECT count(Id) total FROM AITM_Tender_Location_Line_Item__c WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF AND AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Is_Current_Round__c = true AND AITM_Tender_Result__c in('BG', 'BR') AND AITM_Tender_Location__r.AITM_Locations_Filter__c =: locationType.replaceAll('\\s+', '')];
        return Integer.valueOf(result[0].get('total'));         
    }

   /**
    * @description gets Locations with Contacts.
    * @param locationIds set collection of Id
    * @return List collection of AITM_Location__c
    */
    public List<AITM_Location__c> getLocationsWithContacts(Set<Id> locationIds) {
        return [SELECT Id, (SELECT Id, Email, AITM_Location__c FROM AITM_DistributionList__r) FROM AITM_Location__c WHERE Id IN :locationIds];
    }
   
    /**
    * @description get Tender Location based on TenderlocationId
    * @param tenderLocIdS set collection of Id
    * @return List collection of AITM_Tender_Location__C
    */
    public List<AITM_Tender_Location__c> getTenderLocationById(set<Id> tenderLocIdS){
        return [SELECT AITM_Classification__c,AITM_Competition__c,AITM_Last_Look_To_Incumbent__c,AITM_Tender__c,AITM_Comments__c,AITM_Tender__r.AITM_Stage__c,AITM_Leading_Bid_Currency__c,AITM_IATA_ICAO__c,AITM_Leading_Bid_UoM__c,AITM_Location_Size__c,AITM_Measure__c,AITM_Number_Of_Rounds__c,AITM_Offered_Differential_Currency__c,AITM_Offered_Differential_UoM__c,AITM_Primary_Supply__c,AITM_Product__c,AITM_Quality_Of_Feedback__c,Name,AITM_Location__r.AITM_Classification__c,AITM_Location__r.AITM_Competition__c,AITM_Tender__r.AITM_Last_Look_To_Incumbent__c,AITM_Location__r.AITM_Currency__c,AITM_Location__r.AITM_Unit_Of_Measure__c,AITM_Location__r.AITM_Location_Size__c,AITM_Location__r.AITM_Measure__c,AITM_Tender__r.AITM_Number_Of_Rounds__c,AITM_Location__r.AITM_Primary_Supply__c,AITM_Location__r.AITM_Product__c,AITM_Tender__r.AITM_Quality_Of_Feedback__c,AITM_Location__r.AITM_IATA_ICAO__c,AITM_Location__r.Name FROM AITM_Tender_Location__c WHERE Id IN :tenderLocIdS ];
    }
   /**
    * @description gets Tender Locations based on filter collection set of tenderIds.
    * @param tenderIds set collection of Id
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getTenderLocations(Set<Id> tenderIds) {
        return [SELECT AITM_Volume__c, AITM_Ad_hoc_Volume__c, AITM_Total_Requested_Volume__c, AITM_Tender__c, AITM_Location__c, AITM_Tender__r.AITM_Start_Date__c, AITM_Tender__r.AITM_End_Date__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c IN :tenderIds AND AITM_Is_Current_Round__c = true];
    }

   /**
    * @description gets Tender Locations.
    * @param tenderIds set collection of Ids
    * @param locationIds set collection of Ids
    * @return List of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getTenderLocations(Set<Id> tenderIds, Set<Id> locationIds) {
        return [SELECT AITM_Volume__c, AITM_Ad_hoc_Volume__c, AITM_Total_Requested_Volume__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Tender__c, AITM_Location__c,AITM_Current_Round__c,AITM_Round__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c IN :tenderIds AND AITM_Location__c IN :locationIds FOR UPDATE];
    }

   /**
    * @description gets Priced Tender Locations For a Contract.
    * @param tenderId of type Id
    * @param accountId of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getPricedTenderLocationsForAContract(Id tenderId, Id accountId) {
        return [SELECT AITM_IATA__c, AITM_Comments__c, AITM_Include_Taxes_Fees_in_Contract__c, AITM_Include_Notes_in_Contract__c, AITM_Service_Level__c, AITM_Measure__c, AITM_IATA_ICAO__c, AITM_Specification__c, AITM_Current_Round__c, AITM_Round__c,AITM_Additional_Notes__c, AITM_Delivery_Method__c, AITM_Tender__c, AITM_Tender__r.AITM_Start_Date__c, AITM_Aircraft_Type__c, AITM_Product__c, AITM_Tender__r.AITM_End_Date__c, AITM_Ad_hoc_Volume__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Include_In_Revised_Offer__c, AITM_Location__r.Name, AITM_Location__c, AITM_Location__r.AITM_Location_Group__c, AITM_Country__c, AITM_Volume__c, AITM_Status__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, (SELECT id, AITM_Location__c,AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c,AITM_Account__c, AITM_Current_Value__c, AITM_Pricing_Basis_Description__c, AITM_Unit_Of_Measure__c, AITM_Currency__c, AITM_Ad_hoc_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Percentage_Volume_Offered__c, AITM_Offered_Volume__c, AITM_Offered_Differential__c, AITM_Duration__c, AITM_Tender_Location__r.AITM_Product__c,AITM_Product_Density_for_Pricing__c, AITM_Product_Default__c, AITM_Pricing_Basis__c,AITM_Pricing_Basis__r.AITM_Type__c, AITM_Pricing_Basis__r.Name, AITM_Credit_Days__c, AITM_Invoice_Frequency__c,AITM_Tender__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c, AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c, AITM_Location_Delivery_Point__r.Fuel_Provider_Service_Area_PDF_Display__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_Number__c, AITM_Requested_Volume_UoM__c, AITM_Taxes_Fees__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Measure__c, AITM_Include_Taxes_and_Fees_in_Contract__c, AITM_Delivery_Method__c,AITM_Tender_Location__r.AITM_Location__c FROM AITM_Tender_Location__r WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF AND AITM_Account__c = :accountId AND AITM_Tender_Result__c NOT IN ('LB', 'MI', 'MIX') ) FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
    }

   /**
    * @description gets Priced Tender Locations For a Contract.
    * @param tenderId of type Id
    * @param accountId of type Set<Id>
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getPricedTenderLocationsForAContract(Id tenderId, Set<Id> accountIds) {
        return [SELECT AITM_IATA__c, AITM_Comments__c, AITM_Include_Taxes_Fees_in_Contract__c, AITM_Include_Notes_in_Contract__c, AITM_Service_Level__c, AITM_Measure__c, AITM_IATA_ICAO__c, AITM_Specification__c, AITM_Current_Round__c, AITM_Round__c,AITM_Additional_Notes__c, AITM_Delivery_Method__c, AITM_Tender__c, AITM_Tender__r.AITM_Start_Date__c, AITM_Aircraft_Type__c, AITM_Product__c, AITM_Tender__r.AITM_End_Date__c, AITM_Ad_hoc_Volume__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Include_In_Revised_Offer__c, AITM_Location__r.Name, AITM_Location__c, AITM_Location__r.AITM_Location_Group__c, AITM_Country__c, AITM_Volume__c, AITM_Status__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, (SELECT AITM_Location__c,AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c,AITM_Account__c, AITM_Current_Value__c, AITM_Pricing_Basis_Description__c, AITM_Unit_Of_Measure__c, AITM_Currency__c, AITM_Ad_hoc_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Percentage_Volume_Offered__c, AITM_Offered_Volume__c, AITM_Offered_Differential__c, AITM_Duration__c, AITM_Tender_Location__r.AITM_Product__c,AITM_Product_Density_for_Pricing__c, AITM_Product_Default__c, AITM_Pricing_Basis__c,AITM_Pricing_Basis__r.AITM_Type__c, AITM_Pricing_Basis__r.Name, AITM_Credit_Days__c, AITM_Invoice_Frequency__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c, AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c, AITM_Location_Delivery_Point__r.Fuel_Provider_Service_Area_PDF_Display__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_Number__c, AITM_Requested_Volume_UoM__c, AITM_Taxes_Fees__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Measure__c, AITM_Include_Taxes_and_Fees_in_Contract__c, AITM_Delivery_Method__c,AITM_Tender_Location__r.AITM_Location__c FROM AITM_Tender_Location__r WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF AND AITM_Account__c = :accountIds AND AITM_Tender_Result__c NOT IN ('LB', 'MI', 'MIX') ) FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
    }

   /**
    * @description gets Priced Tender Locations For a Contract.
    * @param tenderId of type Id
    * @param accountId of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getPricedTenderLocationsForAffiliatesInContract(Id tenderId) {
        return [SELECT AITM_IATA__c, AITM_Comments__c, AITM_Include_Taxes_Fees_in_Contract__c, AITM_Include_Notes_in_Contract__c, AITM_Service_Level__c, AITM_Measure__c, AITM_IATA_ICAO__c, AITM_Specification__c, AITM_Current_Round__c, AITM_Round__c,AITM_Additional_Notes__c, AITM_Delivery_Method__c, AITM_Tender__c, AITM_Tender__r.AITM_Start_Date__c, AITM_Aircraft_Type__c, AITM_Product__c, AITM_Tender__r.AITM_End_Date__c, AITM_Ad_hoc_Volume__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Include_In_Revised_Offer__c, AITM_Location__r.Name, AITM_Location__c, AITM_Location__r.AITM_Location_Group__c, AITM_Country__c, AITM_Volume__c, AITM_Status__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, (SELECT AITM_Account__c, AITM_Current_Value__c, AITM_Pricing_Basis_Description__c, AITM_Unit_Of_Measure__c, AITM_Currency__c, AITM_Ad_hoc_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Percentage_Volume_Offered__c, AITM_Offered_Volume__c, AITM_Offered_Differential__c, AITM_Duration__c, AITM_Tender_Location__r.AITM_Product__c, AITM_Product_Density_for_Pricing__c, AITM_Pricing_Basis__c,AITM_Pricing_Basis__r.AITM_Type__c, AITM_Pricing_Basis__r.Name, AITM_Credit_Days__c, AITM_Invoice_Frequency__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c, AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c, AITM_Location_Delivery_Point__r.Fuel_Provider_Service_Area_PDF_Display__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_Number__c, AITM_Requested_Volume_UoM__c, AITM_Taxes_Fees__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Measure__c, AITM_Include_Taxes_and_Fees_in_Contract__c, AITM_Delivery_Method__c FROM AITM_Tender_Location__r WHERE RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF AND AITM_Tender_Result__c NOT IN ('LB', 'MI', 'MIX') ) FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c != :STATUS_NOT_REPRESENTED];
    }

   /**
    * @description gets Tender Location Line Items by Record Type. with related accountID
    * @param tenderLocationId of type Id
    * @param recordTypeId of type Id
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsGroupedByAccount(Id tenderLocationId, Id recordTypeId) {
        return [SELECT AITM_Account__c,AITM_Delivery_Point_Info__c from AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c = :tenderLocationId AND RecordTypeId = :recordTypeId ];
    }

   /**
    * @description gets Tender Id by Tender Location Id.
    * @param tenderLocationId of type Id
    * @return Id of AITM_Tender_Location__c
    */
    public Id getTenderIdByTenderLocationId(Id tenderLocationId) {
        return [SELECT AITM_Tender__c FROM AITM_Tender_Location__c WHERE Id = :tenderLocationId LIMIT 1][0].AITM_Tender__c;
    }

   /**
    * @description gets Tender Locaiton Line Items.
    * @param tenderId of type Id
    * @param criterias collection of string
    * @param recordTypeId of type Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItems(Id tenderId, List<String> criterias, Id recordTypeId) {
        TenderLocationLineItemsQueryBuilder locationSoqlBuilder = new TenderLocationLineItemsQueryBuilder();
        return (List<AITM_Tender_Location_Line_Item__c>) Database.query(locationSoqlBuilder.getFilteredTenderLocationLineItems(criterias, tenderId, recordTypeId));
    }

   /**
    * @description gets Tender Locaiton Line Items.
    * @param tenderId of type Id
    * @param criterias collection of string
    * @param recordTypeId of type Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsForDebriefResults(Id tenderId, List<String> criterias, Id recordTypeId, String profileName) {
        TenderLocationLineItemsQueryBuilder locationSoqlBuilder = new TenderLocationLineItemsQueryBuilder();
        return (List<AITM_Tender_Location_Line_Item__c>) Database.query(locationSoqlBuilder.getFilteredTenderLocationLineItemsDebriefResults(criterias, tenderId, recordTypeId, profileName));
    }

   /**
    * @description gets Tender Locaiton Line Items.
    * @param tenderId of type Id
    * @param criterias collection of string
    * @param recordTypeId of type Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationMarketLineItems(Id tenderId, List<String> tenderResult, Id recordTypeId) {
        TenderLocationLineItemsQueryBuilder locationSoqlBuilder = new TenderLocationLineItemsQueryBuilder();
        return (List<AITM_Tender_Location_Line_Item__c>) Database.query(locationSoqlBuilder.getFilteredTenderResultLocationLineItems(tenderResult, tenderId, recordTypeId, null));
    }

   /**
    * @description gets Tender Locaiton Line Items.
    * @param tenderId of type Id
    * @param criterias collection of string
    * @param recordTypeId of type Id 
    * @param locationType of type String 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationMarketLineItems(Id tenderId, List<String> tenderResult, Id recordTypeId, String locationType) {
        TenderLocationLineItemsQueryBuilder locationSoqlBuilder = new TenderLocationLineItemsQueryBuilder();        
        return (List<AITM_Tender_Location_Line_Item__c>) Database.query(locationSoqlBuilder.getFilteredTenderResultLocationLineItems(tenderResult, tenderId, recordTypeId, locationType));
    }

   /**
    * @description gets Tender Location Line Items for DeBriefPerMetrics.
    * @param tenderId of type Id
    * @param recordTypeID of type Id
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsForDeBriefPerMetrics(Id tenderId, Id recordTypeId) {
        return [SELECT RecordTypeId, AITM_Offered_Volume__c, AITM_Credit_Days__c, AITM_Gross_Profit__c, AITM_Working_Capital__c, AITM_History_Line_Item__c, AITM_PPI__c, AITM_History_Line_Item__r.AITM_Offered_Volume__c, AITM_History_Line_Item__r.AITM_Gross_Profit__c, AITM_History_Line_Item__r.AITM_Working_Capital__c, AITM_History_Line_Item__r.AITM_PPI__c,AITM_Awarded_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c =:tenderId AND AITM_Tender_Result__c NOT IN ('LB', 'MI', 'MIX') AND RecordTypeId = :recordTypeId ];
    }

   /**
    * @description gets Tender Location Line Items for DeBriefPerMetrics.
    * @param tenderId of type Id
    * @param recordTypeID of type Id
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsForDeBriefResults(Id tenderId) {
        return [SELECT AITM_Location__c, AITM_Location__r.Name, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Location__r.AITM_Country__c, AITM_Account__c, AITM_Account__r.Name, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Result__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.Name, AITM_Requested_Volume_USG__c, AITM_Awarded_Volume__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Rebate__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__r.AITM_Is_Current_Round__c = true AND AITM_Tender__c =:tenderId AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF ORDER BY AITM_Requested_Volume_USG__c DESC NULLS LAST  LIMIT 50];
    }

    /**
    * @description gets Tender Location Line Items for DeBriefPerMetrics.
    * @param tenderId of type Id
    * @param LocationType of type string
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsForDeBriefResults(Id tenderId,String LocationType) {
        if(LocationType == POLISH_FILTER){
           return [SELECT AITM_Location__c, AITM_Location__r.Name, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Location__r.AITM_Country__c, AITM_Account__c, AITM_Account__r.Name, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Result__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.Name, AITM_Requested_Volume_USG__c, AITM_Awarded_Volume__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Rebate__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__r.AITM_Is_Current_Round__c = true AND AITM_Tender__c =:tenderId AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF  AND AITM_Tender_Location__r.AITM_Locations_Filter__c = : POLISH_FILTER AND AITM_Is_Current_Round__c = true ORDER BY AITM_Requested_Volume_USG__c DESC NULLS LAST  LIMIT 50];
        }else{
               return [SELECT AITM_Location__c, AITM_Location__r.Name, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Location__r.AITM_Country__c, AITM_Account__c, AITM_Account__r.Name, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Result__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.Name, AITM_Requested_Volume_USG__c, AITM_Awarded_Volume__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Rebate__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__r.AITM_Is_Current_Round__c = true AND AITM_Tender__c =:tenderId AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF  AND AITM_Tender_Location__r.AITM_Locations_Filter__c != : POLISH_FILTER AND AITM_Is_Current_Round__c = true ORDER BY AITM_Requested_Volume_USG__c DESC NULLS LAST LIMIT 50];
            }
    }
    

   /**
    * @description gets Tender Location Line Item by Tender and Location Ids.
    * @param tenderIds 
    * @param locationIds set collection of Ids 
    * @param existingItems list collection of AITM_Tender_Location_Line_Item__c
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemByTenderIdsAndLocationIds(Set<Id> tenderIds, Set<Id> locationIds, List<AITM_Tender_Location_Line_Item__c> existingItems) {
        return [SELECT AITM_Volume__c, AITM_Account__c, AITM_Tender__c, AITM_Credit_Days__c, AITM_Ad_hoc_Volume__c, AITM_Location__c, RecordTypeId FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c IN :tenderIds AND AITM_Location__c IN :locationIds AND Id NOT IN :existingItems AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEFAULT ];
    }

   /**
    * @description gets Tender Location Line Items by Tender and Account Ids.
    * @param tenderIds collection set of Id 
    * @param accountIds collection set of Id
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByTenderAndAccountIds(Set<Id> tenderIds, Set<Id> accountIds) {
        return [SELECT AITM_Tender__c, AITM_Account__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c IN :tenderIds AND AITM_Account__c IN :accountIds];
    }

   /**
    * @description gets Tender Location Line Items by Tender and Account Id.
    * @param tenderId of type Id 
    * @param accountId of type Id
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByTenderAndAccountId(Id tenderId, Id accountId) {
        return [SELECT AITM_Tender__c, AITM_Account__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Account__c = :accountId];
    }

   /**
    * @description gets Tender Location Line Items by Tender
    * @param tenderId of type Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByTender(Id tenderId) {
        return [SELECT AITM_Tender__c, AITM_Account__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId];
    }
	
    /**
    * @description gets Tender Location Line Items by Tender
    * @param tenderId of Set Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByTender(Set<Id> tenderIds) {
        return [SELECT AITM_Tender__c, AITM_Account__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c IN: tenderIds];
    }

   /**
    * @description gets Tender Location Line Items by Tender for generating xls offer content
    * @param tenderId of type Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByTenderForXLS(Id tenderId) {
        return [SELECT AITM_Tender__c, AITM_Tender__r.Name, AITM_Account__r.Name, AITM_Location__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Quantity__c, AITM_Product_Density_for_Pricing__c, AITM_Measure__c, AITM_Pricing_Basis__r.Name, AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c, AITM_Yearly_Volume__c, AITM_Pricing_Basis_Description__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Invoice_Frequency__c, AITM_Credit_Days__c, AITM_Delivery_Method__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c, AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c, AITM_Location__r.AITM_Location_Group__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Taxes_Fees__c  FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true];
    }

   /**
    * @description gets Tender Location Line Items by Tender for generating xls offer content
    * @param tenderId of type Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByTenderForDebriefXLS(Id tenderId) {
        return [SELECT AITM_Tender__c, AITM_Product_Specification__c, AITM_Tender_Location__r.AITM_Service_Level__c, AITM_Tender_Location__r.AITM_Aircraft_Type__c, AITM_Currency_Rebate1__c, AITM_Unit_Of_Measure_Rebate1__c, AITM_Requested_Volume_USG__c, Owner.Name, AITM_Product_Default__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location__r.AITM_Country__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c, AITM_Tender_Result__c, AITM_Volume__c, AITM_Awarded_Volume__c, AITM_Exchange__c, AITM_Rebate__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Tender_Location__r.AITM_Total_Requested_Volume__c, AITM_Location_Delivery_Point__r.AITM_Product_Default__c, AITM_Density__c, AITM_Tender_Location__r.AITM_Specification__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Id, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name, AITM_Debrief_Notes__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_Tender__r.Name, AITM_Account__r.Name, AITM_Location__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Quantity__c, AITM_Tender_Location__r.AITM_Product__c, AITM_Measure__c, AITM_Pricing_Basis__r.Name, AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c, AITM_Yearly_Volume__c, AITM_Pricing_Basis_Description__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Invoice_Frequency__c, AITM_Credit_Days__c, AITM_Delivery_Method__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c, AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c, AITM_Location__r.AITM_Location_Group__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Taxes_Fees__c  FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF limit 850];
    }

   /**
    * @description gets Tender Location Line Items by Tender for generating xls offer content
    * @param tenderId of type Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByTenderForDebriefXLS(Id tenderId, String locationType) {
        if(locationType == POLISH_FILTER) {
            return [SELECT AITM_Tender__c, AITM_Product_Specification__c, AITM_Tender_Location__r.AITM_Service_Level__c, AITM_Tender_Location__r.AITM_Aircraft_Type__c, AITM_Currency_Rebate1__c, AITM_Unit_Of_Measure_Rebate1__c, AITM_Requested_Volume_USG__c, Owner.Name, AITM_Product_Default__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location__r.AITM_Country__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c, AITM_Tender_Result__c, AITM_Volume__c, AITM_Awarded_Volume__c, AITM_Exchange__c, AITM_Rebate__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Tender_Location__r.AITM_Total_Requested_Volume__c, AITM_Location_Delivery_Point__r.AITM_Product_Default__c, AITM_Density__c, AITM_Tender_Location__r.AITM_Specification__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Id, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name, AITM_Debrief_Notes__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_Tender__r.Name, AITM_Account__r.Name, AITM_Location__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Quantity__c, AITM_Tender_Location__r.AITM_Product__c, AITM_Measure__c, AITM_Pricing_Basis__r.Name, AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c, AITM_Yearly_Volume__c, AITM_Pricing_Basis_Description__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Invoice_Frequency__c, AITM_Credit_Days__c, AITM_Delivery_Method__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c, AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c, AITM_Location__r.AITM_Location_Group__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Taxes_Fees__c  FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Locations_Filter__c =: POLISH_FILTER AND AITM_Is_Current_Round__c = true AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF limit 850];
        } 
        return [SELECT AITM_Tender__c, AITM_Product_Specification__c, AITM_Tender_Location__r.AITM_Service_Level__c, AITM_Tender_Location__r.AITM_Aircraft_Type__c, AITM_Currency_Rebate1__c, AITM_Unit_Of_Measure_Rebate1__c, AITM_Requested_Volume_USG__c, Owner.Name, AITM_Product_Default__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location__r.AITM_Country__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c, AITM_Tender_Result__c, AITM_Volume__c, AITM_Awarded_Volume__c, AITM_Exchange__c, AITM_Rebate__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Tender_Location__r.AITM_Total_Requested_Volume__c, AITM_Location_Delivery_Point__r.AITM_Product_Default__c, AITM_Density__c, AITM_Tender_Location__r.AITM_Specification__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Id, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name, AITM_Debrief_Notes__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_Tender__r.Name, AITM_Account__r.Name, AITM_Location__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Quantity__c, AITM_Tender_Location__r.AITM_Product__c, AITM_Measure__c, AITM_Pricing_Basis__r.Name, AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c, AITM_Yearly_Volume__c, AITM_Pricing_Basis_Description__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Invoice_Frequency__c, AITM_Credit_Days__c, AITM_Delivery_Method__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c, AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c, AITM_Location__r.AITM_Location_Group__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Taxes_Fees__c  FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Locations_Filter__c !=: POLISH_FILTER AND AITM_Is_Current_Round__c = true AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF limit 850];         
    }

   /**
    * @description gets Tender Location Line Items by Tender for generating xls offer content
    * @param tenderId of type Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByTenderForFeedbackXLS(Id tenderId) {
        return [SELECT AITM_Tender__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location_Manager_Level_of_Interest__c, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_Comments__c, AITM_Tender_Location__r.AITM_Competitor_info__c, AITM_Tender_Location__r.AITM_Distance_from_Leading_Bid1__c, AITM_Tender_Location__r.AITM_Leading_Bid_Currency__c, AITM_Tender_Location__r.AITM_Leading_Bid_UoM__c, AITM_Tender_Location__r.AITM_Leading_Bid__c, AITM_Tender_Location__r.AITM_Offered_Differential_UoM__c, AITM_Tender_Location__r.AITM_Offered_Differential_Currency__c, AITM_Tender_Location__r.AITM_Offered_Differential__c, AITM_Tender_Location__r.AITM_Position__c, AITM_Tender_Location__r.AITM_Number_Of_Bidders__c, AITM_Tender_Location__r.AITM_Number_Of_Rounds__c, AITM_Tender_Location__r.AITM_Last_Look_To_Incumbent__c, AITM_Tender_Location__r.AITM_Quality_Of_Feedback__c, AITM_LM_Context_Strategic_Rationale_Info__c, AITM_Account_Manager_Notes_Instructions__c, AITM_Current_Round__c, AITM_Currency_Rebate1__c, AITM_Unit_Of_Measure_Rebate1__c, AITM_Requested_Volume_USG__c, Owner.Name, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location__r.AITM_Country__c, AITM_Account__r.AITM_GRN__c, AITM_Rebate__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_Tender__r.Name, AITM_Account__r.Name, AITM_Location__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Offered_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true limit 900];
    }

   /**
    * @description gets Tender Location Line Items by Tender for generating xls offer content
    * @param tenderId of type Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByTenderForFeedbackXLS(Id tenderId, String locationType) {
        if(locationType == POLISH_FILTER) {
            return [SELECT AITM_Tender__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location_Manager_Level_of_Interest__c, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_Comments__c, AITM_Tender_Location__r.AITM_Competitor_info__c, AITM_Tender_Location__r.AITM_Distance_from_Leading_Bid1__c, AITM_Tender_Location__r.AITM_Leading_Bid_Currency__c, AITM_Tender_Location__r.AITM_Leading_Bid_UoM__c, AITM_Tender_Location__r.AITM_Leading_Bid__c, AITM_Tender_Location__r.AITM_Offered_Differential_UoM__c, AITM_Tender_Location__r.AITM_Offered_Differential_Currency__c, AITM_Tender_Location__r.AITM_Offered_Differential__c, AITM_Tender_Location__r.AITM_Position__c, AITM_Tender_Location__r.AITM_Number_Of_Bidders__c, AITM_Tender_Location__r.AITM_Number_Of_Rounds__c, AITM_Tender_Location__r.AITM_Last_Look_To_Incumbent__c, AITM_Tender_Location__r.AITM_Quality_Of_Feedback__c, AITM_LM_Context_Strategic_Rationale_Info__c, AITM_Account_Manager_Notes_Instructions__c, AITM_Current_Round__c, AITM_Currency_Rebate1__c, AITM_Unit_Of_Measure_Rebate1__c, AITM_Requested_Volume_USG__c, Owner.Name, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location__r.AITM_Country__c, AITM_Account__r.AITM_GRN__c, AITM_Rebate__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_Tender__r.Name, AITM_Account__r.Name, AITM_Location__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Offered_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Locations_Filter__c =: POLISH_FILTER AND AITM_Is_Current_Round__c = true limit 900];
        } 
        return [SELECT AITM_Tender__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location_Manager_Level_of_Interest__c, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_Comments__c, AITM_Tender_Location__r.AITM_Competitor_info__c, AITM_Tender_Location__r.AITM_Distance_from_Leading_Bid1__c, AITM_Tender_Location__r.AITM_Leading_Bid_Currency__c, AITM_Tender_Location__r.AITM_Leading_Bid_UoM__c, AITM_Tender_Location__r.AITM_Leading_Bid__c, AITM_Tender_Location__r.AITM_Offered_Differential_UoM__c, AITM_Tender_Location__r.AITM_Offered_Differential_Currency__c, AITM_Tender_Location__r.AITM_Offered_Differential__c, AITM_Tender_Location__r.AITM_Position__c, AITM_Tender_Location__r.AITM_Number_Of_Bidders__c, AITM_Tender_Location__r.AITM_Number_Of_Rounds__c, AITM_Tender_Location__r.AITM_Last_Look_To_Incumbent__c, AITM_Tender_Location__r.AITM_Quality_Of_Feedback__c, AITM_LM_Context_Strategic_Rationale_Info__c, AITM_Account_Manager_Notes_Instructions__c, AITM_Current_Round__c, AITM_Currency_Rebate1__c, AITM_Unit_Of_Measure_Rebate1__c, AITM_Requested_Volume_USG__c, Owner.Name, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location__r.AITM_Country__c, AITM_Account__r.AITM_GRN__c, AITM_Rebate__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_Tender__r.Name, AITM_Account__r.Name, AITM_Location__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Offered_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Locations_Filter__c !=: POLISH_FILTER AND AITM_Is_Current_Round__c = true limit 900];         
    }

   /**
    * @description gets Tender Location Line Items by Tender for generating xls offer content
    * @param tenderId of type Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByTenderForInvitationXLS(Id tenderId) {
        return [SELECT AITM_Tender__c, AITM_Product_Specification__c, AITM_History_Line_Item__r.AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c, AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c, AITM_Location_Delivery_Point__c, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_Comments__c, AITM_Tender_Location__r.AITM_Offered_Differential_UoM__c, AITM_Tender_Location__r.AITM_Offered_Differential_Currency__c, AITM_Tender_Location__r.AITM_Offered_Differential__c, AITM_Account_Manager_Notes_Instructions__c, AITM_Current_Round__c, AITM_Requested_Volume_USG__c, Owner.Name, AITM_Product_Default__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location__r.AITM_Country__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c, AITM_Tender_Result__c, AITM_Volume__c, AITM_Exchange__c, AITM_Rebate__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Tender_Location__r.AITM_Total_Requested_Volume__c, AITM_Location_Delivery_Point__r.AITM_Product_Default__c, AITM_Tender_Location__r.AITM_Density__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Id, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_Tender__r.Name, AITM_Account__r.Name, AITM_Location__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Location__r.AITM_Product__c, AITM_Measure__c, AITM_Pricing_Basis__r.Name, AITM_Yearly_Volume__c, AITM_Pricing_Basis_Description__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location__r.AITM_Location_Group__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Taxes_Fees__c  FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true];
    }

   /**
    * @description gets Tender Location Line Items by Tender for generating xls offer content
    * @param tenderId of type Id 
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByTenderForInvitationXLS(Id tenderId, String locationType) {
        if(locationType == POLISH_FILTER) {
            return [SELECT AITM_Tender__c, AITM_Product_Specification__c, AITM_History_Line_Item__r.AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c, AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c, AITM_Location_Delivery_Point__c, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_Comments__c, AITM_Tender_Location__r.AITM_Offered_Differential_UoM__c, AITM_Tender_Location__r.AITM_Offered_Differential_Currency__c, AITM_Tender_Location__r.AITM_Offered_Differential__c, AITM_Account_Manager_Notes_Instructions__c, AITM_Current_Round__c, AITM_Requested_Volume_USG__c, Owner.Name, AITM_Product_Default__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location__r.AITM_Country__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c, AITM_Tender_Result__c, AITM_Volume__c, AITM_Exchange__c, AITM_Rebate__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Tender_Location__r.AITM_Total_Requested_Volume__c, AITM_Location_Delivery_Point__r.AITM_Product_Default__c, AITM_Tender_Location__r.AITM_Density__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Id, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_Tender__r.Name, AITM_Account__r.Name, AITM_Location__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Location__r.AITM_Product__c, AITM_Measure__c, AITM_Pricing_Basis__r.Name, AITM_Yearly_Volume__c, AITM_Pricing_Basis_Description__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location__r.AITM_Location_Group__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Taxes_Fees__c  FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Locations_Filter__c =: POLISH_FILTER AND AITM_Is_Current_Round__c = true];
        } 
        return [SELECT AITM_Tender__c, AITM_Product_Specification__c, AITM_History_Line_Item__r.AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c, AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c, AITM_Location_Delivery_Point__c, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_Comments__c, AITM_Tender_Location__r.AITM_Offered_Differential_UoM__c, AITM_Tender_Location__r.AITM_Offered_Differential_Currency__c, AITM_Tender_Location__r.AITM_Offered_Differential__c, AITM_Account_Manager_Notes_Instructions__c, AITM_Current_Round__c, AITM_Requested_Volume_USG__c, Owner.Name, AITM_Product_Default__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location__r.AITM_Country__c, AITM_Account__r.AITM_GRN__c, AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c, AITM_Tender_Result__c, AITM_Volume__c, AITM_Exchange__c, AITM_Rebate__c, AITM_Additional_Notes_Taxes_and_Fees__c, AITM_Tender_Location__r.AITM_Total_Requested_Volume__c, AITM_Location_Delivery_Point__r.AITM_Product_Default__c, AITM_Tender_Location__r.AITM_Density__c,AITM_History_Line_Item__c, AITM_History_Line_Item__r.Id, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Currency__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_Tender__r.Name, AITM_Account__r.Name, AITM_Location__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Location__r.AITM_Product__c, AITM_Measure__c, AITM_Pricing_Basis__r.Name, AITM_Yearly_Volume__c, AITM_Pricing_Basis_Description__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location__r.AITM_Location_Group__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Taxes_Fees__c  FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Locations_Filter__c !=: POLISH_FILTER AND AITM_Is_Current_Round__c = true];         
    }

   /**
    * @description gets Location by Id
    * @param locationId of type Id
    * @return AITM_Location__c
    */
    public AITM_Location__c getLocationById(Id locationId) {
        return [SELECT AITM_Delegates__c FROM AITM_Location__c WHERE Id = :locationId];
    }

   /**
    * @description gets locations with Owner Information.
    * @param ids set collection of Id
    * @return Map collection of id and AITM_Locations__c
    */
    public Map<Id, AITM_Location__c> getLocationsWithOwnerInformation(Set<Id> ids) {
        return new Map<Id, AITM_Location__c>([SELECT Id, OwnerId, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Pricing_Basis__c, (SELECT Id, AITM_Sector__c, AITM_Location_Manager__c FROM AITM_Location_Managers__r) FROM AITM_Location__c WHERE Id IN :ids]);
    }

   /**
    * @description gets Tender Location Line Item with Sector Information.
    * @param lineItems list collection of AITM_Tender_Location_Line_Item__c
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationWithSectorInformation(List<AITM_Tender_Location_Line_Item__c> lineItems) {
        return [SELECT AITM_Tender__r.OwnerId,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c,OwnerId, RecordTypeId, AITM_Measure__c, AITM_Product_Specification__c, AITM_Delivery_Method__c, AITM_Delivery_By__c,AITM_Product_Default__c,AITM_Additional_Refueling_Information__c, AITM_Taxes_Fees__c, AITM_Location__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Method__c, AITM_Location_Delivery_Point__r.AITM_Measure__c, AITM_Location_Delivery_Point__r.AITM_Product_Specification__c, AITM_Location_Delivery_Point__r.AITM_Delivery_By__c, AITM_Location_Delivery_Point__r.AITM_Product_Default__c, AITM_Location_Delivery_Point__r.AITM_Additional_Refueling_Information__c, AITM_Location_Delivery_Point__r.AITM_Taxes_Fees__c, AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c, AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c, AITM_Location__r.OwnerId,AITM_Tender_Location__c,AITM_Is_Clone__c,AITM_Pricer_No_Default_Delivery_Points__c,AITM_Location_Delivery_Point__c, AITM_Tender_location__r.AITM_Round__c, AITM_Is_Pricing_Basis_Not_Represented__c FROM AITM_Tender_Location_Line_Item__c WHERE Id IN :lineItems];
    }

   /**
    * @description gets Tender Location Line Items with Location Managers.
    * @param locations list collection AITM_Tender_Location__c
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsWithLocationManagers(List<AITM_Tender_Location__c> locations) {
        Set<Id> locationIds = new Map<Id, AITM_Tender_Location__c>(locations).keySet();
        return [SELECT AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c, AITM_Location__c, AITM_Location__r.AITM_Delegates__c, AITM_Location_Manager__c, AITM_Location_Manager__r.AITM_Delegates__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN :locationIds];
    }

    /**
    * @description gets Tender Location Line Items with Location Managers.
    * @param locations list collection AITM_Tender_Location__c
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsWithLocationManagers(AITM_Tender_Location__c location) {
       return [SELECT AITM_Tender__r.AITM_Tender_Sector__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name, AITM_Location__c, AITM_Location__r.AITM_Delegates__c, AITM_Location_Manager__c, AITM_Location_Manager__r.AITM_Delegates__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c = :location.Id];
    }

   /**
    * @description gets Minimum Offered Differential Tender Location Line Items per Location
    * @param locations list collection AITM_Tender_Location__c
    * @return Map collection of aggregateresult
    */
    public Map<Id, AggregateResult> getMinimumOfferedDifferentialTenderLocationLineItems(List<AITM_Tender_Location__c> locations) {
        Set<Id> locationIds = new Map<Id, AITM_Tender_Location__c>(locations).keySet();
        return new Map<Id, AggregateResult>([SELECT MIN(AITM_Offered_Differential__c) MINIMUMOFFEREDDIFFERENTIAL, AITM_Tender_Location__c Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN :locationIds GROUP BY AITM_Tender_Location__c]);
    }

   /**
    * @description gets Locations with Tender Location Managers
    * @param ids set collection of Ids
    * @return Map collection of Id and AITM_Location__c
    */
    public Map<Id, AITM_Location__c> getLocationsWithTenderLocationInfoByIds(Set<Id> ids) {
        //return new Map<Id, AITM_Location__c>([SELECT Id, OwnerId, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location_Size__c, AITM_Delivery_Method__c, AITM_Location_Strategy__c, AITM_Pricing_Basis__c, (SELECT Id, AITM_Sector__c, AITM_Location_Manager__c FROM AITM_Location_Managers__r) FROM AITM_Location__c WHERE Id IN :ids]);
        return new Map<Id, AITM_Location__c>([SELECT Id, OwnerId, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Location_Size__c, AITM_Delivery_Method__c, AITM_Location_Strategy__c, AITM_Pricing_Basis__c FROM AITM_Location__c WHERE Id IN :ids]);
    }
   
   /**
    * @description gets Tender Location Line Items by Ids
    * @param deleteRecordId set collection of string
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List <AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByIds(List<String> deleteRecordId)
    {
    return [SELECT AITM_Account__c,AITM_Tender_Location__c from AITM_Tender_Location_Line_Item__c where id IN: deleteRecordId];
    }

   /**
    * @description This method is used to Parse Location Staging.
    * @param lineItem
    * @return AITM_Tender_Location_Staging__c
    */
    public AITM_Tender_Location_Staging__c parseLocationStaging(AITM_Tender_Location_Line_Item__c lineItem) {
        return new AITM_Tender_Location_Staging__c(
            AITM_Account__c = lineItem.AITM_Account__c,
            AITM_Tender__c = lineItem.AITM_Tender__c,
            AITM_Location__c = lineItem.AITM_Location__c,
            AITM_Volume__c = lineItem.AITM_Volume__c,
            AITM_Start_Date__c = lineItem.AITM_Start_Date__c,
            AITM_End_Date__c = lineItem.AITM_End_Date__c,
            AITM_Unit_Of_Measure__c = lineItem.AITM_Unit_Of_Measure__c
        );
    }

   /**
    * @description assign values to location line item from staging
    * @param staging 
    * @return AITM_Tender_Location_Line_Item__c
    */
    public AITM_Tender_Location_Line_Item__c parseLocationLineItem(AITM_Tender_Location_Staging__c staging) {
        return new AITM_Tender_Location_Line_Item__c(
            AITM_Account__c = staging.AITM_Account__c,
            AITM_Tender__c = staging.AITM_Tender__c,
            AITM_Location__c = staging.AITM_Location__c,
            AITM_Volume__c = staging.AITM_Volume__c,
            AITM_Volume_Formatted_Text__c = staging.AITM_Volume__c != null ? staging.AITM_Volume__c.format() : null,
            AITM_Start_Date__c = staging.AITM_Start_Date__c,
            AITM_End_Date__c = staging.AITM_End_Date__c,
            AITM_Unit_Of_Measure__c = staging.AITM_Unit_Of_Measure__c
        );
    }

   /**
    * @description gets Search Query For Locations.
    * @param searchKey of type string
    * @return string result
    */
    /*private List<sobject> getSearchQueryForLocations(String searchKey) {
        String result = 'FIND \'' + String.escapeSingleQuotes(searchKey) + '*\' IN ALL FIELDS ';
        result += 'RETURNING AITM_Location__c(Name, AITM_IATA__c, AITM_ICAO__c, AITM_Country__c ORDER BY AITM_IATA__c ASC NULLS LAST) LIMIT 10';
        return result;
    }*/

   /**
    * @description gets Tender Location By Tender ID and Round Number.
    * @param tenderId of type Id 
    * @param locationId of type Id 
    * @param roundNumber of type Integer
    * @return List collection of AITM_Tender_Location__c
    */
    public AITM_Tender_Location__c getTenderLocationByTenderIdAndRoundNumber(Id tenderId, Id locationId, Integer roundNumber) {
        return [SELECT Name, AITM_Volume__c,  AITM_Country__c,  AITM_Comments__c, AITM_Competitor_info__c, AITM_Competitor_Info_Other__c, AITM_Current_Round__c, AITM_Recalculate_Total_Volume__c, AITM_Status__c, AITM_Tender__c, AITM_Tender__r.Name,  AITM_Tender__r.OwnerId, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Include_In_Revised_Offer__c, AITM_Include_Notes_in_Contract__c, AITM_Include_Taxes_Fees_in_Contract__c, AITM_Round__c, AITM_Has_Feedback__c, AITM_Quality_Of_Feedback__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c, AITM_Number_Of_Bidders__c, AITM_Position__c, AITM_Offered_Differential__c, AITM_Offered_Differential_Currency__c, AITM_Offered_Differential_UoM__c, AITM_Distance_From_Leading_Bid1__c, AITM_Leading_Bid__c, AITM_Leading_Bid_Currency__c, AITM_Leading_Bid_UoM__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Id, AITM_Location_Manager__r.Email, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.FirstName, AITM_Location_Manager__r.LastName, AITM_Location__c, AITM_Location__r.AITM_Delegates__c, AITM_Location__r.Name, AITM_Location__r.AITM_IATA__c, AITM_Location__r.AITM_ICAO__c FROM AITM_Tender_Location__c WHERE  AITM_Tender__c = :tenderId  AND AITM_Round__c = :roundNumber AND AITM_Location__c = :locationId];
    }

   /**
    * @description gets Tender Location
    * @param tenderLocationID of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public AITM_Tender_Location__c getTenderLocation(Id tenderLocationId) {
        return [SELECT Name,AITM_Approve_the_Service_Level__c,AITM_Customer_Service_Level__c,AITM_Location_Default_Service_Level__c,AITM_CustomerDefaultValue__c,AITM_LocationDefaultValue__c,AITM_Is_Straddled__c,AITM_Apply_All_Tax_Fee_Check__c, AITM_No_Revision__c, AITM_Volume__c, AITM_Country__c, AITM_Comments__c, AITM_Competitor_info__c, AITM_Competitor_Info_Other__c, AITM_Current_Round__c, AITM_Recalculate_Total_Volume__c, AITM_Status__c,AITM_Additional_Notes__c, AITM_Tender__c, AITM_Tender__r.Name,  AITM_Tender__r.OwnerId,  AITM_Total_Volume_Offered_To_The_Group__c, AITM_Include_In_Revised_Offer__c, AITM_Include_Notes_in_Contract__c, AITM_Include_Taxes_Fees_in_Contract__c, AITM_Round__c, AITM_Has_Feedback__c, AITM_Quality_Of_Feedback__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c, AITM_Number_Of_Bidders__c, AITM_Position__c, AITM_Offered_Differential__c, AITM_Offered_Differential_Currency__c, AITM_Offered_Differential_UoM__c, AITM_Distance_From_Leading_Bid1__c, AITM_Leading_Bid__c, AITM_Leading_Bid_Currency__c, AITM_Leading_Bid_UoM__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Email, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.FirstName, AITM_Location_Manager__r.LastName, AITM_Location__c, AITM_Location__r.AITM_Delegates__c, AITM_Location__r.Name, AITM_Location__r.AITM_IATA__c, AITM_Location__r.AITM_ICAO__c FROM  AITM_Tender_Location__c WHERE Id = :tenderLocationId];
    }

   /**
    * @description gets Tender Location Line Items.
    * @param tenderLocationId of type Id
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItems(Id tenderLocationId) {
        return [SELECT Name, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Credit_Days__c, AITM_Location_Delivery_Point__r.AITM_Internal_Code__c, AITM_Location_Delivery_Point__c, AITM_Description__c, AITM_Pricing_Excellence__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.Name, AITM_Volume__c, AITM_Round__c, AITM_Requested_Volume_USG__c, AITM_Offered_Volume__c,  AITM_Percentage_Volume_Offered__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Offered_Differential__c, AITM_History_Line_Item__r.AITM_Tender_Result__c FROM AITM_Tender_Location_Line_Item__c  WHERE AITM_Tender_Location__c = :tenderLocationId AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEFAULT];
    }

   /**
    * @description gets Tender Location Line Items by Record Type.
    * @param tenderLocationId of type Id
    * @param recordTypeId of type Id
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsByRecordType(Id tenderLocationId, Id recordTypeId) {
        return [SELECT Name,AITM_Old_Taxes_Fees_Flag__c, AITM_Account__c, AITM_Account__r.AITM_Account_Classification__c, AITM_Is_Straddled__c,AITM_Delivery_Method__c,AITM_Product_Default__c,AITM_Tender_Location__r.AITM_Apply_All_Tax_Fee_Check__c, AITM_Product_Density_for_Pricing__c,AITM_Location_Delivery_Point__c, AITM_Location__c, AITM_Previous_Round_Differential__c, AITM_Account__r.AITM_GRN__c, AITM_Awarded_Volume__c, AITM_Account__r.Name,AITM_Pricing_Basis__r.AITM_Type__c,AITM_Current_Value__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Description__c, AITM_Pricing_Excellence__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.Name, AITM_Volume__c, AITM_Round__c, AITM_Requested_Volume_USG__c, AITM_Offered_Volume__c,  AITM_Percentage_Volume_Offered__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Differential__c,AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c,AITM_Delivery_Point_Info__c,AITM_Location_Delivery_Point__r.AITM_Pricing_Basis_CA__c FROM AITM_Tender_Location_Line_Item__c  WHERE AITM_Tender_Location__c = :tenderLocationId AND RecordTypeId = :recordTypeId];
    }

    /** 
    * @description gets DeBrief Tender Location Line Items.
    * @param null
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getDeBriefTenderLocationLineItems() {
        return [SELECT AITM_Tender__r.AITM_Unit_Of_Measure__c, AITM_Currency_Rebate1__c, AITM_Unit_Of_Measure_Rebate1__c, AITM_Currency__c, AITM_Winning_Differential__c, AITM_Unit_Of_Measure_Winning_Differentia__c, AITM_Currency_Winning_Differential__c, AITM_Currency_Pricing_Basis1__c, AITM_GRN__c, AITM_Floor_Price__c, AITM_Exchange__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender__c, AITM_Volume__c, AITM_Invoice_Frequency__c, AITM_Tender_Result__c, AITM_Credit_Days__c, AITM_Rebate__c, AITM_Duration__c, AITM_Quantity__c, AITM_Pricing_Basis__r.Name, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_IATA__c, AITM_Tender_Location__r.AITM_Country__c, AITM_Tender_Location__r.AITM_Measure__c, AITM_Tender_Location__r.AITM_Delivery_Method__c, AITM_Tender_Location__r.AITM_Product__c, AITM_Tender_Location__r.AITM_Density__c FROM AITM_Tender_Location_Line_Item__c WHERE RecordTypeId = :TLLI_ID_RECORD_TYPE_DEBRIEF AND CreatedDate = LAST_N_DAYS:7]; 
    }

    /**
    * @description gets Represented Location Line Items.
    * @param tenderLocations list collection of AITM_Tender_Location__c
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getRepresentedLocationLineItems(List<AITM_Tender_Location__c> tenderLocations) {
        return [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN :tenderLocations AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEFAULT AND AITM_Pricing_Basis__r.AITM_Not_Represented__c = false];
    }

    /**
     * @description gets Non Represented Tender Locations
     * @param tenderLocations list collection of AITM_Tender_Location__c
     * @return List collection of AITM_Tender_Location__c
     */
    public List<AITM_Tender_Location__c> getNonRepresentedTenderLocations(List<AITM_Tender_Location__c> tenderLocations)
    {
        return [SELECT Name, AITM_Volume__c FROM AITM_Tender_Location__c WHERE Id IN :tenderLocations AND AITM_Status__c = :STATUS_NOT_REPRESENTED AND AITM_Is_Current_Round__c = true];  
    }

    /**
     * @description gets Represented  Gained Location Line Items.
     * @param tenderLocations list collection of AITM_Tender_Location__c
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getRepresentedGainedLocationLineItems(List<AITM_Tender_Location__c> tenderLocations) {
        return [SELECT Id FROM  AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN : tenderLocations AND AITM_Tender_Result__c='BG'];
    }
    /**
     * @description gets Represented  Gained Location Line Items.
     * @param tenderLocations list collection of AITM_Tender_Location__c
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getRepresentedGainedLocationLineItems(List<Id> tenderLocations) {
        return [SELECT Id FROM  AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN : tenderLocations AND AITM_Tender_Result__c='BG'];
    }

    /**
     * @description gets Represented Retained Location Line Items.
     * @param tenderLocations list collection of AITM_Tender_Location__c
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getRepresentedRetainedLocationLineItems(List<AITM_Tender_Location__c> tenderLocations) {
        return [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN : tenderLocations AND AITM_Tender_Result__c='BR'];
    }

    /**
     * @description gets Represented Retained Location Line Items.
     * @param tenderLocations list collection of AITM_Tender_Location__c
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getRepresentedRetainedLocationLineItems(List<Id> tenderLocations) {
        return [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN : tenderLocations AND AITM_Tender_Result__c='BR'];
    }

    /**
     * @description gets Represented Lost Location Line Items.
     * @param tenderLocations list collection of AITM_Tender_Location__c
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getRepresentedLostLocationLineItems(List<AITM_Tender_Location__c> tenderLocations) {
        return [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN : tenderLocations AND AITM_Tender_Result__c='LB'];
    }

    /**
     * @description gets Represented Lost Location Line Items.
     * @param tenderLocations list collection of AITM_Tender_Location__c
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getRepresentedLostLocationLineItems(List<Id> tenderLocations) {
        return [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN : tenderLocations AND AITM_Tender_Result__c='LB'];
    }

    /**
     * @description gets Represented Mix Location Line Items.
     * @param tenderLocations list collection of AITM_Tender_Location__c
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getRepresentedMixLocationLineItems(List<AITM_Tender_Location__c> tenderLocations) {
        return [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN : tenderLocations AND (AITM_Tender_Result__c='MI' OR AITM_Tender_Result__c='MIX')];
    }

    /**
     * @description gets Represented Mix Location Line Items.
     * @param tenderLocations list collection of AITM_Tender_Location__c
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getRepresentedMixLocationLineItems(List<Id> tenderLocations) {
        return [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN : tenderLocations AND (AITM_Tender_Result__c='MI' OR AITM_Tender_Result__c='MIX')];
    }

    /**
     * @description gets Represented Gained Locations
     * @param tenderLocations list collection of AITM_Tender_Location__c and Id as tenderId
     * @return List collection of AITM_Tender_Location_Line_C
     */
    public List<AITM_Tender_Location__c> getLocationsGroupedByResultGained(List<AITM_Tender_Location__c> tenderLocations,Id tenderId) {
        return [SELECT AITM_IATA_ICAO__c,AITM_Service_Level__c, AITM_Aircraft_Type__c, AITM_Total_Requested_Volume__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Ad_hoc_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Product__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, AITM_Location__r.AITM_Internal_code__c,(select Id, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Location__r.Name, AITM_Location__r.AITM_Country__c, AITM_Product_Default__c, AITM_Account__r.Name, AITM_Line_Item_Name_Account__c, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Delivery_Method__c, AITM_Measure__c, AITM_Tender_Location__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.AITM_Last_Tender_Result__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Location__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c FROM AITM_Tender_Location__r WHERE AITM_Tender_Location__c IN :tenderLocations AND AITM_Tender_Result__c='BG' AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF ORDER BY AITM_Offered_Volume__c DESC) from AITM_Tender_Location__c where AITM_Tender__c = :tenderId];
    }

    /**
     * @description gets Represented Retained Locations
     * @param tenderLocations list collection of AITM_Tender_Location__c and Id as tenderId
     * @return List collection of AITM_Tender_Location_Line_C
     */
    public List<AITM_Tender_Location__c> getLocationsGroupedByResultRetained(List<AITM_Tender_Location__c> tenderLocations,Id tenderId) {
        return [SELECT AITM_IATA_ICAO__c,AITM_Service_Level__c, AITM_Aircraft_Type__c, AITM_Total_Requested_Volume__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Ad_hoc_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Product__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, AITM_Location__r.AITM_Internal_code__c,(select Id, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Location__r.Name, AITM_Location__r.AITM_Country__c, AITM_Product_Default__c, AITM_Account__r.Name, AITM_Line_Item_Name_Account__c, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Delivery_Method__c, AITM_Measure__c, AITM_Tender_Location__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.AITM_Last_Tender_Result__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Location__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c FROM AITM_Tender_Location__r WHERE AITM_Tender_Location__c IN :tenderLocations AND AITM_Tender_Result__c='BR' AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF ORDER BY AITM_Offered_Volume__c DESC) from AITM_Tender_Location__c where AITM_Tender__c = :tenderId];
    }

    /**
     * @description gets Represented Lost Locations
     * @param tenderLocations list collection of AITM_Tender_Location__c and Id as tenderId
     * @return List collection of AITM_Tender_Location_Line_C
     */
    public List<AITM_Tender_Location__c> getLocationsGroupedByResultLost(List<AITM_Tender_Location__c> tenderLocations,Id tenderId) {
        return [SELECT AITM_IATA_ICAO__c,AITM_Service_Level__c, AITM_Aircraft_Type__c, AITM_Total_Requested_Volume__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Ad_hoc_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Product__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, AITM_Location__r.AITM_Internal_code__c,(select Id, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Location__r.Name, AITM_Location__r.AITM_Country__c, AITM_Product_Default__c, AITM_Account__r.Name, AITM_Line_Item_Name_Account__c, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Delivery_Method__c, AITM_Measure__c, AITM_Tender_Location__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.AITM_Last_Tender_Result__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Location__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c FROM AITM_Tender_Location__r WHERE AITM_Tender_Location__c IN :tenderLocations AND AITM_Tender_Result__c='LB' AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF ORDER BY AITM_Offered_Volume__c DESC) from AITM_Tender_Location__c where AITM_Tender__c = :tenderId];
    }

    /**
     * @description gets Represented Mix Locations
     * @param tenderLocations list collection of AITM_Tender_Location__c and Id as tenderId
     * @return List collection of AITM_Tender_Location_Line_C
     */
    public List<AITM_Tender_Location__c> getLocationsGroupedByResultMix(List<AITM_Tender_Location__c> tenderLocations,Id tenderId){
        return [SELECT AITM_IATA_ICAO__c,AITM_Service_Level__c, AITM_Aircraft_Type__c, AITM_Total_Requested_Volume__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Ad_hoc_Volume__c, AITM_Location_Manager__c, AITM_Delivery_Method__c, AITM_Product__c, AITM_Measure__c, AITM_Location_Manager__r.Name, AITM_IATA__c, AITM_Location__c, AITM_Location__r.Name, AITM_Location__r.AITM_Internal_code__c,(select Id, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Location__r.Name, AITM_Location__r.AITM_Country__c, AITM_Product_Default__c, AITM_Account__r.Name, AITM_Line_Item_Name_Account__c, AITM_Requested_Volume_USG__c, AITM_Requested_Volume_UoM__c, AITM_Offered_Volume__c, AITM_Pricing_Basis__r.Name, AITM_Description__c, AITM_Offered_Differential__c, AITM_Rebate__c, AITM_Pricing_Basis__r.AITM_Type__c, AITM_Current_Value__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Quantity__c, AITM_Duration__c, AITM_Tender_Result__c, AITM_Exchange__c, AITM_Account__r.AITM_GRN__c, AITM_Awarded_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Delivery_Method__c, AITM_Measure__c, AITM_Tender_Location__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.AITM_Last_Tender_Result__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Location__c, AITM_Location__r.AITM_IATA_ICAO__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c FROM AITM_Tender_Location__r WHERE AITM_Tender_Location__c IN :tenderLocations AND (AITM_Tender_Result__c='MI' OR AITM_Tender_Result__c='MIX') AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEBRIEF ORDER BY AITM_Offered_Volume__c DESC) from AITM_Tender_Location__c where AITM_Tender__c = :tenderId];
    }

    /**
     * @description gets Tender Location Line Items to Clone
     * @param tenderLocations list collection of AITM_Tender_Location__c
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsToClone(List<AITM_Tender_Location__c> tenderLocations) {
        List<Id> tenderLocationIds = new List<Id>();
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.fields.getMap();
        Set<String> fields = new Set<String>();

        for(String fieldName: schemaFieldMap.keySet()){
            fields.add(fieldName);
        }

        for(AITM_Tender_Location__c tenderLocation : tenderLocations){
            tenderLocationIds.add(tenderLocation.Id);
        }
        TenderLocationLineItemsQueryBuilder soqlBuilder = new TenderLocationLineItemsQueryBuilder();
        return (List<AITM_Tender_Location_Line_Item__c>) Database.query(soqlBuilder.getLocationsLineItems(tenderLocationIds, fields));
    }

    /**
     * @description gets Filtered Tender Location Line Items.
     * @param criterias list collection of string 
     * @param tenderId of type Id 
     * @param recordTypeID of type Id
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getFilteredTenderLocationLineItems(List<String> criterias, Id tenderId, Id recordTypeId) {
        List<Id> tenderLocationIds = new List<Id>();
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.fields.getMap();
        Set<String> fields = new Set<String>();

        for(String fieldName: schemaFieldMap.keySet()){
            fields.add(fieldName);
        }

        TenderLocationLineItemsQueryBuilder soqlBuilder = new TenderLocationLineItemsQueryBuilder();
        return (List<AITM_Tender_Location_Line_Item__c>) Database.query(soqlBuilder.getFilteredTenderLocationLineItems(criterias, tenderId, recordTypeId));
    }

    /**
     * @description gets Tender Location Line Items with Tender location Ids.
     * @param tenderLocations list collection of AITM_Tender_Location__c
     * @param fields set collection of string fieldNames to include in soql query
     * @return List of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationsLineItems(List<AITM_Tender_Location__c> tenderLocations, Set<String> fields) {
        List<Id> tenderLocationIds = new List<Id>();

        for(AITM_Tender_Location__c tenderLocation : tenderLocations){
            tenderLocationIds.add(tenderLocation.Id);
        }
        TenderLocationLineItemsQueryBuilder soqlBuilder = new TenderLocationLineItemsQueryBuilder();
        return (List<AITM_Tender_Location_Line_Item__c>) Database.query(soqlBuilder.getLocationsLineItems(tenderLocationIds, fields));
    }

    /**
     * @description gets Tender location Line Items for the list of tenderLocationIds.
     * @param tenderLocationIds list collection of Ids
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItems(List<Id> tenderLocationIds) {
        return [SELECT Name, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Description__c, AITM_Pricing_Excellence__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.Name, AITM_Volume__c, AITM_Requested_Volume_UoM__c, AITM_Round__c, AITM_Requested_Volume_USG__c, AITM_Offered_Volume__c, AITM_Percentage_Volume_Offered__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Offered_Differential__c, AITM_Tender_Location__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN :tenderLocationIds AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEFAULT];
    }

    /**
     * @description gets Tender Location Line Items with Non Blank Offered Volume by Tender Location Ids.
     * @param tenderLocationIds set collection of Ids
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsWithNonBlankOfferedVolumeByTenderLocationIds(Set<Id> tenderLocationIds) {
        return [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c IN : tenderLocationIds AND AITM_Offered_Volume__c != null AND AITM_Percentage_Volume_Offered__c != null];
    }

    /**
     * @description This method is used to get Tender Location Line Item.
     * @param lineItemId of type Id
     * @return AITM_Tender_Location_Line_Item__c
     */
    public AITM_Tender_Location_Line_Item__c getTenderLocationLineItem(Id lineItemId) {
        return [SELECT AITM_Tender__r.OwnerId, AITM_Straddled_Taxes_Fees__c, AITM_Straddled_Additional_Taxes_Fees__c,Name,AITM_Current_Value__c,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c,AITM_Pricer_No_Default_Delivery_Points__c,AITM_Location__r.OwnerId,AITM_Account__c,AITM_Is_Clone__c, AITM_Rebate__c, AITM_Previous_Round_Differential__c,AITM_Location__c,AITM_Round__c,AITM_Current_Round__c,AITM_Data_Capture_Delay__c,AITM_Location_Size__c,AITM_Yearly_Volume__c,AITM_Location_Strategy__c,AITM_Tender__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Location_Delivery_Point__c,AITM_Delivery_Method__c,AITM_Delivery_By__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Credit_Days__c, AITM_Pricing_Excellence__c, AITM_Pricing_Basis__c,AITM_Pricing_Basis_Description__c, AITM_Volume__c, AITM_Requested_Volume_USG__c, AITM_Offered_Volume__c,AITM_Unit_Of_Measure_Rebate__c,AITM_Duration__c,AITM_Quantity__c,AITM_Exchange__c, AITM_Percentage_Volume_Offered__c, AITM_Currency__c,AITM_Currency_Pricing_Basis__c,AITM_Unit_Of_Measure_Winning_Differentia__c,AITM_Currency_Winning_Differential__c, AITM_Unit_Of_Measure__c,AITM_Taxes_Fees__c,AITM_Security_Text_on_Offer__c,AITM_Payment_Currency__c,AITM_Security_Type__c,AITM_Additional_Notes_Taxes_and_Fees__c,AITM_Ad_hoc_Volume__c,AITM_Awarded_Volume__c,AITM_Include_Taxes_and_Fees_in_Contract__c,AITM_Include_Notes_in_Contract__c, AITM_Requested_Volume_UoM__c,AITM_Product_Specification__c,AITM_Additional_Refueling_Information__c,AITM_Measure__c,AITM_Product_Default__c, AITM_Product_Density_for_Pricing__c, AITM_Density__c, AITM_Offered_Differential__c, AITM_Tender_Location__c, AITM_Location_Manager__c, AITM_Tender_Owner_Profile__c, AITM_Status__c, OwnerId,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Overall_Credit_Days_Customer__c,AITM_Delivery_Point_Info__c,AITM_Invoice_Frequency__c,AITM_Credit_Rating__c,AITM_Credit_Rating_Of_Customer__c,AITM_Account_Manager_Notes_Instructions__c,AITM_Location_Manager_Level_of_Interest__c,AITM_LM_Context_Strategic_Rationale_Info__c,AITM_Bid_Expiry_Date__c,AITM_Target_Price__c,AITM_Floor_Price__c,AITM_Adjusted_Differential__c,AITM_Minimum_Selling_Price__c,AITM_Gross_Profit__c,AITM_Stock_Days__c,AITM_Working_Capital__c,AITM_Supplier_Credit_Days__c,AITM_Return_On_WC__c,AITM_Location_Neutral_WC_Payment_Days__c,AITM_PPI__c,AITM_Mark_Up_Customer_Segment__c,AITM_Mark_Up_Customer_Buying_Power__c,AITM_Mark_Up_Location_Strategy__c,AITM_Cost_Of_Product__c,AITM_Credit_Terms_Adjustment__c,AITM_Customer_Location_Specific_Revenue__c,AITM_Instrument__c,AITM_Premium__c,AITM_Sales_Pricing_Period__c,AITM_Product_Loss__c,AITM_Replenishment_Pricing_Period__c,AITM_CSO_Costs__c,AITM_Market_Structure_Cost__c,AITM_Other_Income_Variable__c,AITM_Other_Income_Fixed__c,AITM_Temperature_Adjustment_At_Location__c,AITM_Density_Adjustments__c,AITM_Pre_Airfield_Fixed__c,AITM_Pre_Airfield_Variable__c,AITM_On_Airfield_Fixed__c,AITM_On_Airfield_Variable__c,AITM_Customer_Specific_Into_Plane_Costs__c,AITM_JV_Profit_Dividend__c,AITM_Additional_Margin_From_Line_Items__c,AITM_Product_Pricing_Report__c, AITM_Old_Taxes_Fees_Flag__c, AITM_Volume_Display_PDF__c, AITM_Volume_Formatted_Text__c, AITM_Offered_Volume_Text__c, RecordTypeId FROM AITM_Tender_Location_Line_Item__c WHERE Id = :lineItemId AND AITM_Record_Type_Name__c ='Default' LIMIT 1];
    }

    /**
     * @description This method is used to get list of Tender Location Line Items.
     * @param lineItemId of type Id
     * @return AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItem(List<Id> lineItemId) {
        return [SELECT AITM_Tender__r.OwnerId, AITM_Straddled_Taxes_Fees__c, AITM_Straddled_Additional_Taxes_Fees__c,Name,AITM_Current_Value__c,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c,AITM_Pricer_No_Default_Delivery_Points__c,AITM_Location__r.OwnerId,AITM_Account__c,AITM_Is_Clone__c, AITM_Rebate__c, AITM_Previous_Round_Differential__c,AITM_Location__c,AITM_Round__c,AITM_Current_Round__c,AITM_Data_Capture_Delay__c,AITM_Location_Size__c,AITM_Yearly_Volume__c,AITM_Location_Strategy__c,AITM_Tender__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Location_Delivery_Point__c,AITM_Delivery_Method__c,AITM_Delivery_By__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Credit_Days__c, AITM_Pricing_Excellence__c, AITM_Pricing_Basis__c,AITM_Pricing_Basis_Description__c, AITM_Volume__c, AITM_Requested_Volume_USG__c, AITM_Offered_Volume__c,AITM_Unit_Of_Measure_Rebate__c,AITM_Duration__c,AITM_Quantity__c,AITM_Exchange__c, AITM_Percentage_Volume_Offered__c, AITM_Currency__c,AITM_Currency_Pricing_Basis__c,AITM_Unit_Of_Measure_Winning_Differentia__c,AITM_Currency_Winning_Differential__c, AITM_Unit_Of_Measure__c,AITM_Taxes_Fees__c,AITM_Security_Text_on_Offer__c,AITM_Payment_Currency__c,AITM_Security_Type__c,AITM_Additional_Notes_Taxes_and_Fees__c,AITM_Ad_hoc_Volume__c,AITM_Awarded_Volume__c,AITM_Include_Taxes_and_Fees_in_Contract__c,AITM_Include_Notes_in_Contract__c, AITM_Requested_Volume_UoM__c,AITM_Product_Specification__c,AITM_Additional_Refueling_Information__c,AITM_Measure__c,AITM_Product_Default__c, AITM_Product_Density_for_Pricing__c, AITM_Density__c, AITM_Offered_Differential__c, AITM_Tender_Location__c, AITM_Location_Manager__c, AITM_Tender_Owner_Profile__c, AITM_Status__c, OwnerId,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Overall_Credit_Days_Customer__c,AITM_Delivery_Point_Info__c,AITM_Invoice_Frequency__c,AITM_Credit_Rating__c,AITM_Credit_Rating_Of_Customer__c,AITM_Account_Manager_Notes_Instructions__c,AITM_Location_Manager_Level_of_Interest__c,AITM_LM_Context_Strategic_Rationale_Info__c,AITM_Bid_Expiry_Date__c,AITM_Target_Price__c,AITM_Floor_Price__c,AITM_Adjusted_Differential__c,AITM_Minimum_Selling_Price__c,AITM_Gross_Profit__c,AITM_Stock_Days__c,AITM_Working_Capital__c,AITM_Supplier_Credit_Days__c,AITM_Return_On_WC__c,AITM_Location_Neutral_WC_Payment_Days__c,AITM_PPI__c,AITM_Mark_Up_Customer_Segment__c,AITM_Mark_Up_Customer_Buying_Power__c,AITM_Mark_Up_Location_Strategy__c,AITM_Cost_Of_Product__c,AITM_Credit_Terms_Adjustment__c,AITM_Customer_Location_Specific_Revenue__c,AITM_Instrument__c,AITM_Premium__c,AITM_Sales_Pricing_Period__c,AITM_Product_Loss__c,AITM_Replenishment_Pricing_Period__c,AITM_CSO_Costs__c,AITM_Market_Structure_Cost__c,AITM_Other_Income_Variable__c,AITM_Other_Income_Fixed__c,AITM_Temperature_Adjustment_At_Location__c,AITM_Density_Adjustments__c,AITM_Pre_Airfield_Fixed__c,AITM_Pre_Airfield_Variable__c,AITM_On_Airfield_Fixed__c,AITM_On_Airfield_Variable__c,AITM_Customer_Specific_Into_Plane_Costs__c,AITM_JV_Profit_Dividend__c,AITM_Additional_Margin_From_Line_Items__c,AITM_Product_Pricing_Report__c, AITM_Old_Taxes_Fees_Flag__c, AITM_Volume_Display_PDF__c, AITM_Volume_Formatted_Text__c, AITM_Offered_Volume_Text__c, RecordTypeId,AITM_Parent_TLLI_Id__c, AITM_MIP_Parent_Id__c FROM AITM_Tender_Location_Line_Item__c WHERE Id = :lineItemId AND AITM_Record_Type_Name__c ='Default'];
    }

    /**
        * @description gets Tender Location Line Items with delivery point details.
        * @param tenderLocationId of type Id
        * @return List collection of AITM_Tender_Location_Line_Item__c
        */
        public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsWithDeliveryPointInfo(Id tenderLocationId) {
            return [SELECT AITM_Location_Delivery_Point__c, AITM_Tender__r.AITM_Tender_Sector__c, 
            AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c,
            AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c, AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c 
            FROM AITM_Tender_Location_Line_Item__c  
            WHERE AITM_Tender_Location__c = :tenderLocationId AND RecordType.DeveloperName = :TLLI_RECORD_TYPE_DEFAULT];
        }


    /**
     * @description inserts clone line item record
     * @param lineItem of type AITM_Tender_Location_Line_Item__c
     * @return void
     */
    public void insertCloneRecord(AITM_Tender_Location_Line_Item__c lineItem) {
        Database.insert(lineItem);
        lineitem.AITM_Is_Clone__c = false;
        Database.update(lineItem);

    }

    /**
     * @description inserts clone line item record
     * @param lineItem of type AITM_Tender_Location_Line_Item__c
     * @return void
     */
    public void insertCloneRecord(List<AITM_Tender_Location_Line_Item__c> lineItems) {
        Database.insert(lineItems);
        for(AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
            lineitem.AITM_Is_Clone__c = false;
        }
        Database.update(lineItems);
    }

    /**
     * @description class used for Tender Locations Line Items Dao used for queries.
     */
    public without sharing class TenderLocationLineItemsDao {

        /**
         * @description This method is used to get Line Items with Pricing Information
         * @param recordIds set collection of Ids
         * @return List collection of AITM_Tender_Location_Line_Item__c
         */
        public List<AITM_Tender_Location_Line_Item__c> getLineItemsWithPricingInformation(Set<Id> recordIds) {
            return [SELECT AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_Unit_Of_Measure__c, AITM_Replenishment_Pricing_Period__c, AITM_Offered_Differential__c, AITM_Sales_Pricing_Period__c, AITM_Location__r.AITM_IATA__c, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_Density__c, AITM_JV_Profit_Dividend__c, AITM_Location_Size__c, AITM_Location_Strategy__c, AITM_Customer_Specific_Into_Plane_Costs__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Additional_Margin_From_Line_Items__c, AITM_Credit_Rating__c, AITM_Currency__c, AITM_Instrument__c, AITM_Tender_Location__c, AITM_Product_Default__c, AITM_Location__c, AITM_Location__r.AITM_Location_Size__c, AITM_Location__r.AITM_ICAO__c, AITM_GRN__c, AITM_Account__c, AITM_Account__r.AITM_Customer_Segment__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_Volume__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_Offered_Volume__c, AITM_Credit_Days__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_Invoice_Frequency__c, AITM_Rebate__c, AITM_History_Line_Item__c FROM AITM_Tender_Location_Line_Item__c WHERE Id IN :recordIds];
        }

        /**
         * @description gets Line Itmes with Pricing information for the tenderLocationId.
         * @param tenderLocationId of type id
         * @return List collection of AITM_Tender_Location_Line_Item__c
         */
        public List<AITM_Tender_Location_Line_Item__c> getLineItemsWithPricingInformation(Id tenderLocationId) {
            return [SELECT Name, AITM_Adjusted_Differential__c, AITM_Gross_Profit__c, AITM_PPI__c, AITM_Target_Price__c, AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name, AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c, AITM_History_Line_Item__r.AITM_Volume__c, AITM_History_Line_Item__r.AITM_Variance__c, AITM_Volume__c, AITM_Unit_GP__c,AITM_Return_On_WC__c,AITM_Working_Capital__c, AITM_Credit_Days__c, AITM_Invoice_Frequency__c, AITM_Account__c, AITM_Account__r.Name, AITM_Account__r.AITM_GRN__c, AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c, AITM_History_Line_Item__r.AITM_Tender_Result__c, AITM_Currency__c, AITM_History_Line_Item__r.AITM_Offered_Differential__c, AITM_History_Line_Item__c, AITM_History_Line_Item__r.Name, AITM_History_Line_Item__r.AITM_Currency__c,AITM_History_Line_Item__r.AITM_Requested_Volume_USG__c FROM AITM_Tender_Location_Line_Item__c  WHERE AITM_Tender_Location__c = :tenderLocationId AND RecordType.DeveloperName = :AITM_LocationsDao.TLLI_RECORD_TYPE_DEFAULT AND AITM_Is_Current_Round__c = true];
        }

        /**
         * @description inserts multiple tender locations
         * @param items list collection of AITM_Tender_Location_Line_Item__c
         * @return void
         */
        public void insertMultipleTenderLocations(List<AITM_Tender_Location_Line_Item__c> items) {
            if (items.size() > 0) {
                Database.insert(items);
            }
        }

        /**
         * @description Get debrief records tender location line items
         * @param tenderid of type id
         * @return Integer
         */
        public Integer getDebriefLineItemsCount(Id tenderId) {
            List<AggregateResult> aggr = [SELECT COUNT(Id) total FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c =: tenderId AND AITM_Is_Current_Round__c = true AND AITM_Record_Type_Name__c = 'De-brief'];
            return Integer.valueOf(aggr[0].get('total')); 
        }
        
        /**
         * @description Get Line Item records collection
         * @param tenderId of type Id
         * @return List Collection
         */ 
        public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsForTender(Id tenderId) {
           List<AITM_Tender_Location_Line_Item__c> items = [SELECT AITM_Account__c, AITM_Start_Date__c, AITM_Bid_Expiry_Date__c, AITM_Tender__c, OwnerId,
                                                                AITM_Tender_Location__c, AITM_Ad_hoc_Volume__c, AITM_Currency__c, AITM_Current_Value__c,
                                                                AITM_Credit_Days__c, AITM_Location_Delivery_Point__c, AITM_Description__c, AITM_Details_Context__c,
                                                                AITM_Duration__c, AITM_Invoice_Frequency__c, AITM_End_Date__c, AITM_Exchange__c,
                                                                AITM_Last_Tender_Result__c, AITM_Level_Of_Interest__c, AITM_Location__c, 
                                                                AITM_Location_Manager__c, AITM_Offered_Differential__c, AITM_Offered_Volume__c, 
                                                                AITM_Pricing_Basis__c, AITM_Quantity__c, AITM_Requested_Volume_USG__c,
                                                                AITM_Requested_Volume_UoM__c, AITM_Round__c, AITM_Specification__c, AITM_Record_Type_Name__c,
                                                                AITM_Tender_Result__c, AITM_Unit_Of_Measure__c, AITM_Previous_TLLI_Id__c,
                                                                AITM_Volume__c, AITM_Rebate__c, AITM_Tender_Owner_Profile__c, AITM_Percentage_Volume_Offered__c, 
                                                                AITM_History_Line_Item__c, AITM_Taxes_Fees__c, AITM_Additional_Notes_Taxes_and_Fees__c, 
                                                                AITM_Product_Density_for_Pricing__c, AITM_Density__c, AITM_Product_Pricing_Report__c,
                                                                AITM_Measure__c, AITM_Include_Taxes_and_Fees_in_Contract__c, AITM_Include_Notes_in_Contract__c, 
                                                                AITM_Product_Specification__c, AITM_Product_Default__c, AITM_Delivery_Method__c,AITM_Old_Taxes_Fees_Flag__c,
                                                                AITM_Straddled_Taxes_Fees__c, AITM_Straddled_Additional_Taxes_Fees__c, AITM_Is_Straddled__c, AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Parent_TLLI_Id__c
                                                                FROM AITM_Tender_Location_Line_Item__c 
                                                                WHERE AITM_Tender__c =: tenderId AND AITM_Is_Current_Round__c = true AND AITM_Is_Pricing_Basis_Not_Represented__c = false
                                                                AND AITM_Record_Type_Name__c = 'Default'];
            return items;
        }

        /**
         * @description Get debreif Line Item result records collection
         * @param lineItemIds of type Set<Id> collection
         * @return Map Collection
         */ 
        public Map<Id, String> getTenderLocationDebriefResultsForIds(Set<Id> lineItemIds) {
           Map<Id, String> debriefResultsMap = new Map<Id, String>();
           List<AITM_Tender_Location_Line_Item__c> items = [SELECT AITM_Tender_Result__c, AITM_Previous_TLLI_Id__c
                                                                FROM AITM_Tender_Location_Line_Item__c 
                                                                WHERE AITM_Previous_TLLI_Id__c = : lineItemIds AND AITM_Is_Current_Round__c = true
                                                                AND AITM_Record_Type_Name__c = 'De-brief'];
            for(AITM_Tender_Location_Line_Item__c t :items){ 
               debriefResultsMap.put(t.AITM_Previous_TLLI_Id__c, t.Id + ':' + t.AITM_Tender_Result__c);
            }
            return debriefResultsMap;
        }
    }

       /**
        * @description class is used for Locations Query Builder which extends AITM_QueryBuilder.
        */
        public without sharing class LocationsQueryBuilder extends AITM_QueryBuilder {
        
        /**
         * @description default constructor
         * @param null
         */
        public LocationsQueryBuilder() {}

        /**
         * @description gets Tender Locations with child records.
         * @param criterias list collection of string with filters
         * @param tenderId of type Id
         * @param isPriced of type boolean
         * @return It returns String data type of getQuery 
         */
        public String getTenderLocationsWithChilds(List<String> criterias, Id tenderId, Boolean isPriced) {
            this.selectx(new Set<String>{'Id', 'AITM_IATA__c', 'AITM_Tender__r.AITM_Unit_Of_Measure__c', 'AITM_IATA_ICAO__c', 'AITM_Service_Level__c', 'AITM_Aircraft_Type__c', 'AITM_Specification__c', 'AITM_Current_Round__c', 'AITM_Round__c', 'AITM_Taxes_Fees__c', 'AITM_Additional_Notes__c', 'AITM_Tender__c', 'AITM_Tender__r.AITM_Start_Date__c', 'AITM_Product__c','AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c', 'AITM_Tender__r.AITM_End_Date__c', 'AITM_Ad_hoc_Volume__c', 'AITM_Total_Volume_Offered_To_The_Group__c', 'AITM_Include_In_Revised_Offer__c', 'AITM_Location__r.Name', 'AITM_Location__c', 'AITM_Location__r.AITM_Location_Group__c', 'AITM_Country__c', 'AITM_Volume__c', 'AITM_Status__c', 'AITM_Location_Manager__c', 'AITM_Location_Manager__r.Name', 'AITM_Measure__c', 'AITM_Delivery_Method__c', 'AITM_Service_Level__c','AITM_Total_Requested_Volume__c'});
            this.selectx(new Set<String>{ '(SELECT Id', 'AITM_Tender__r.AITM_Tender_Sector__c', 'AITM_Volume__c', 'AITM_Delivery_Method__c','RecordTypeId', 'AITM_Requested_Volume_UoM__c', 'AITM_Currency__c', 'AITM_Unit_Of_Measure__c', 'AITM_Currency_Winning_Differential__c', 'AITM_Unit_Of_Measure_Winning_Differentia__c', 'AITM_Account__c', 'AITM_Start_Date__c', 'AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c', 'AITM_Pricing_Basis_Description__c', 'AITM_End_Date__c', 'AITM_Account__r.Name', 'AITM_Product_Default__c','AITM_Requested_Volume_USG__c', 'AITM_Percentage_Volume_Offered__c', 'AITM_Offered_Volume__c','AITM_Location__c', 'AITM_Offered_Differential__c', 'AITM_Current_Value__c', 'AITM_Duration__c','AITM_Product_Density_for_Pricing__c', 'AITM_Tender_Location__r.AITM_Product__c', 'AITM_Pricing_Basis__c', 'AITM_Pricing_Basis__r.Name', 'AITM_Pricing_Basis__r.AITM_Type__c', 'AITM_Credit_Days__c', 'AITM_Ad_hoc_Volume__c', 'AITM_Invoice_Frequency__c', 'AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c', 'AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c', 'AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name', 'AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c', 'AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name','AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c', 'AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name', 'AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c','AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c', 'AITM_Location_Delivery_Point__r.Fuel_Provider_Service_Area_PDF_Display__c', 'AITM_Location_Delivery_Point__r.AITM_Delivery_Point_Number__c','AITM_Location_Delivery_Point__c','AITM_Is_Pricing_Basis_Not_Represented__c' , 'AITM_History_Line_Item__c', 'AITM_History_Line_Item__r.AITM_Tender_Result__c','AITM_Delivery_Point_Info__c','AITM_Pricer_No_Default_Delivery_Points__r.Name','AITM_Taxes_Fees__c','AITM_Additional_Notes_Taxes_and_Fees__c','AITM_Measure__c','Owner.Name'});
            this.fromx('AITM_Tender_Location__r');
            this.wherex('RecordType.DeveloperName = \'' + TLLI_RECORD_TYPE_DEFAULT + '\')');

            this.fromx('AITM_Tender_Location__c');

            this.wherex('AITM_Tender__c = \'' + tenderId + '\'');
            if (isPriced) {
                this.wherex('AITM_Status__c = \'Priced\'', 'AND');
                this.wherex('AITM_Is_Current_Round__c = true', 'AND');
            }
            if (criterias != null) {
                for (String criteria : criterias) {
                    this.wherex(criteria, 'AND');
                }
            }

            this.orderbyx('AITM_IATA__c, AITM_Country__c', 'ASC');
            return this.getQuery();
        }

        /**
         * @description gets Tender Locations with child records for display in large tenders
         * @param criterias list collection of string with filters
         * @param tenderId of type Id
         * @param isPriced of type boolean
         * @return It returns String data type of getQuery 
         */
         public String getTenderLocationsWithChildsForDisplay(List<String> criterias, Id tenderId, Boolean isPriced,String profileName) {
            this.selectx(new Set<String>{'Id', 'AITM_IATA__c', 'AITM_Tender__r.AITM_Unit_Of_Measure__c','AITM_Tender__r.OwnerId','AITM_IATA_ICAO__c', 'AITM_Service_Level__c', 'AITM_Aircraft_Type__c', 'AITM_Specification__c', 'AITM_Current_Round__c', 'AITM_Round__c', 'AITM_Taxes_Fees__c', 'AITM_Additional_Notes__c', 'AITM_Tender__c', 'AITM_Tender__r.AITM_Start_Date__c', 'AITM_Product__c', 'AITM_Tender__r.AITM_End_Date__c', 'AITM_Ad_hoc_Volume__c', 'AITM_Total_Volume_Offered_To_The_Group__c', 'AITM_Include_In_Revised_Offer__c', 'AITM_Location__r.Name', 'AITM_Location__c', 'AITM_Location__r.AITM_Location_Group__c', 'AITM_Country__c', 'AITM_Volume__c', 'AITM_Status__c', 'AITM_Location_Manager__c', 'AITM_Location_Manager__r.Name', 'AITM_Measure__c', 'AITM_Delivery_Method__c', 'AITM_Service_Level__c','AITM_Total_Requested_Volume__c'});
            this.selectx(new Set<String>{ '(SELECT Id','AITM_Delivery_Point_Info__c','Owner.Name','AITM_History_Line_Item__r.AITM_Tender_Result__c','AITM_Offered_Volume__c','AITM_Offered_Differential__c','AITM_Percentage_Volume_Offered__c'});
            this.fromx('AITM_Tender_Location__r');
            this.wherex('RecordType.DeveloperName = \'' + TLLI_RECORD_TYPE_DEFAULT + '\')');

            this.fromx('AITM_Tender_Location__c');

            this.wherex('AITM_Tender__c = \'' + tenderId + '\'');
            if (isPriced) {
                this.wherex('AITM_Status__c = \'Priced\'', 'AND');
                this.wherex('AITM_Is_Current_Round__c = true', 'AND');
            }
            if(AITM_BaseUtils.LABP_AMPROFILE.contains(profileName)) {
                 AITM_Tender__c t = [Select OwnerId from AITM_Tender__c where Id =:tenderId];
                 Id loggedUserid = UserInfo.getUserId();
                 if (t.ownerId != loggedUserid){
                       this.wherex('AITM_Location__r.AITM_Locations_Filter__c =\'' + String.escapeSingleQuotes(POLISH_FILTER) +'\'','AND');
                 }
                 
                
            } else if(AITM_BaseUtils.AIR_LMPROFILE.contains(profileName)) {
                      this.wherex('AITM_Location__r.AITM_Locations_Filter__c !=\'' + String.escapeSingleQuotes(POLISH_FILTER) +'\'','AND');
            } 
                if (criterias != null) {
                     for (String criteria : criterias) {
                             this.wherex(criteria, 'AND');
                }
            }

            this.orderbyx('AITM_IATA__c, AITM_Country__c', 'ASC');
            return this.getQuery();
        }

    }

   /**
    * @description class used for Tender Location Line Items Query Builder which extends AITM_QueryBuilder
    */
    public class TenderLocationLineItemsQueryBuilder extends AITM_QueryBuilder {
    
       /**
        * @description default constructor
        * @param null
        */
        public TenderLocationLineItemsQueryBuilder() {}
		
        /**
        * @description gets Search Query For Locations.
        * @param searchKey of type string
		* @param searchInType of type string
		* @param limitInteger of type string
        * @return string result
        */
        public String getSearchQueryForLocations(String searchKey, String searchInType, String limitInteger) {
            String tempInput = '%' + searchKey + '%';
            this.selectx(new Set<String>{'Name', 'AITM_IATA__c', 'AITM_ICAO__c', 'AITM_Country__c'});
            this.fromx('AITM_Location__c');
            if(searchInType == 'iata'){
                this.wherex('AITM_IATA__c LIKE \'' + String.escapeSingleQuotes(tempInput) + '\'');
                this.limitx(limitInteger);
            }
            if(searchInType == 'icao'){
                this.wherex('AITM_ICAO__c LIKE \'' + String.escapeSingleQuotes(tempInput) + '\'');
                this.limitx(limitInteger);
            }
            if(searchInType == 'name'){
                this.wherex('Name LIKE \'' + String.escapeSingleQuotes(tempInput) + '\'');
                this.limitx(limitInteger);
            }
            if(searchInType == 'country'){
                this.wherex('AITM_Country__c LIKE \'' + String.escapeSingleQuotes(tempInput) + '\'');
                this.limitx(limitInteger);
            }
            return this.getQuery();
        }
        
       /**
        * @description gets the Location Line Items
        * @param tenderLocationIds list collection of Id
        * @param fields set collection of fields to query
        * @return string 
        */
        public String getLocationsLineItems(List<Id> tenderLocationIds, Set<String> fields) {
            this.selectx(fields);
            this.fromx('AITM_Tender_Location_Line_Item__c');
            this.wherex('AITM_Tender_Location__c IN (\'' + String.join(tenderLocationIds, '\', \'') + '\')');
            this.wherex('RecordType.DeveloperName = \'' + TLLI_RECORD_TYPE_DEFAULT + '\'', 'AND');
            return this.getQuery();
        }

       /**
        * @description gets the filtered Tender Location Line Items.
        * @param criterias collection set of string
        * @param tenderId of type Id
        * @param recordTypeId of type Id
        * @return string 
        */
        public String getFilteredTenderLocationLineItems(List<String> criterias, String tenderId, Id recordTypeId) {
            this.selectx(new Set<String>{'Id', 'AITM_Location_Delivery_Point__r.AITM_IATA__c', 'AITM_Location_Delivery_Point__r.AITM_Internal_Code__c', 'AITM_Additional_Notes_Taxes_and_Fees__c','AITM_Taxes_Fees__c', 'AITM_Account__c', 'AITM_Location__r.AITM_Internal_code__c', 'AITM_Quantity__c', 'AITM_Previous_TLLI_Id__c', 'AITM_Exchange__c', 'AITM_Rebate__c', 'AITM_Currency_Rebate1__c', 'AITM_Unit_Of_Measure_Rebate1__c', 'AITM_Tender__r.AITM_Density__c', 'AITM_Tender_Location__r.AITM_Product__c', 'AITM_Duration__c', ' AITM_Start_Date__c', 'AITM_End_Date__c', 'AITM_Awarded_Volume__c', 'AITM_Account__r.AITM_GRN__c', 'AITM_Account__r.Name', 'AITM_Location__c', 'AITM_Location__r.AITM_IATA__c', 'AITM_Location__r.AITM_ICAO__c', 'AITM_Location__r.AITM_Country__c', 'AITM_Location__r.AITM_IATA_ICAO__c','AITM_Location__r.Name', 'AITM_Offered_Volume__c', 'AITM_Offered_Differential__c', 'AITM_Pricing_Basis__r.AITM_Type__c', 'AITM_Current_Value__c','AITM_Pricing_Basis__c', 'AITM_Pricing_Basis__r.Name', 'AITM_Currency__c', 'AITM_Unit_Of_Measure__c', 'AITM_Credit_Days__c', 'AITM_Delivery_Method__c', 'AITM_Last_Tender_Result__c', 'AITM_Tender_Result__c', 'AITM_Tender_Location__r.AITM_Is_Current_Round__c', 'AITM_Percentage_Volume_Offered__c', 'AITM_Requested_Volume_USG__c','AITM_Requested_Volume_UoM__c', 'AITM_Ad_hoc_Volume__c', 'AITM_Location_Delivery_Point__r.AITM_Delivery_Point_Number__c','AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c','AITM_History_Line_Item__c', 'AITM_History_Line_Item__r.AITM_Last_Tender_Result__c'});
            this.fromx('AITM_Tender_Location_Line_Item__c');
            this.wherex('AITM_Tender__c = \'' + String.escapeSingleQuotes(tenderId) + '\'');
            this.wherex('AITM_Tender_Location__r.AITM_Is_Current_Round__c = true', 'AND');
            if(recordTypeId != null) {
                this.wherex('RecordTypeId = \'' + recordTypeId + '\'', 'AND');
            }
            if (criterias != null) {
                for (String criteria : criterias) {
                    this.wherex(criteria, 'AND');
                }
            }
            this.orderbyx('AITM_Tender_Location__r.Name, AITM_Location__r.Name', 'ASC');
            return this.getQuery();
        }

       /**
        * @description gets the filtered Tender Location Line Items for debrief results component.
        * @param criterias collection set of string
        * @param tenderId of type Id
        * @param recordTypeId of type Id
        * @param profileName of type String
        * @return string 
        */
        public String getFilteredTenderLocationLineItemsDebriefResults(List<String> criterias, String tenderId, Id recordTypeId, String profileName) {
            this.selectx(new Set<String>{'Id','AITM_Tender__r.OwnerId','AITM_Previous_TLLI_Id__c', 'AITM_Account__r.AITM_GRN__c', 'AITM_Account__r.Name', 'AITM_Location__r.AITM_Internal_code__c', 'AITM_Location__r.AITM_IATA_ICAO__c', 'AITM_Location__r.Name','AITM_Location__c', 'AITM_Ad_hoc_Volume__c', 'AITM_Percentage_Volume_Offered__c','AITM_Tender_Result__c', 'AITM_Awarded_Volume__c', 'AITM_Offered_Differential__c', 'AITM_Pricing_Basis__r.AITM_Type__c', 'AITM_Current_Value__c', 'AITM_Pricing_Basis__r.Name', ' AITM_Start_Date__c', 'AITM_End_Date__c', 'AITM_Offered_Volume__c', 'AITM_Currency__c', 'AITM_Unit_Of_Measure__c',  'AITM_Requested_Volume_UoM__c',  'AITM_Location_Delivery_Point__c','AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c','AITM_History_Line_Item__c', 'AITM_History_Line_Item__r.AITM_Last_Tender_Result__c','AITM_Record_Type_Name__c'});
            this.fromx('AITM_Tender_Location_Line_Item__c');
            this.wherex('AITM_Tender__c = \'' + String.escapeSingleQuotes(tenderId) + '\'');
            this.wherex('AITM_Tender_Location__r.AITM_Is_Current_Round__c = true', 'AND');
            if(recordTypeId != null) {
                this.wherex('AITM_Record_Type_Name__c = \'' + TLLI_RECORD_TYPE_DEBRIEF_NAME + '\'', 'AND');
            }

            if(AITM_BaseUtils.LABP_AMPROFILE.contains(profileName)) {
                 Id loggedUserid = UserInfo.getUserId();
                 AITM_Tender__c t = [Select OwnerId from AITM_Tender__c where Id =:tenderId];
                 if(t.OwnerId != loggedUserid){
                     this.wherex('AITM_Location__r.AITM_Locations_Filter__c =\'' + String.escapeSingleQuotes(POLISH_FILTER) +'\'','AND');
                } 
                
            }            
            if(AITM_BaseUtils.LABP_LMPROFILE.contains(profileName)) {
                this.wherex('AITM_Location__r.AITM_Locations_Filter__c =\'' + String.escapeSingleQuotes(POLISH_FILTER) +'\'','AND');
                 } else if(AITM_BaseUtils.AIR_LMPROFILE.contains(profileName)) {
                          this.wherex('AITM_Location__r.AITM_Locations_Filter__c !=\'' + String.escapeSingleQuotes(POLISH_FILTER) +'\'','AND');
            } 
            
            if (criterias != null) {
                for (String criteria : criterias) {
                    this.wherex(criteria, 'AND');
                }
            }
            this.orderbyx('AITM_Tender_Location__r.Name, AITM_Location__r.Name', 'ASC');
            return this.getQuery();
        }
            

       /**
        * @description gets the filtered Tender Location Line Items.
        * @param criterias collection set of string
        * @param tenderId of type Id
        * @param recordTypeId of type Id
        * @return string 
        */
        public String getFilteredTenderResultLocationLineItems(List<String> tenderResult, String tenderId, Id recordTypeId, String locationType) {
            this.selectx(new Set<String>{'Id', 'AITM_Product_Density_for_Pricing__c', 'AITM_Account__c', 'AITM_Location__r.AITM_Internal_code__c','AITM_Quantity__c', 'AITM_Previous_TLLI_Id__c', 'AITM_Exchange__c','AITM_Location_Delivery_Point__r.AITM_Internal_Code__c', 'AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c', 'AITM_Location_Delivery_Point__r.Fuel_Provider_Service_Area_PDF_Display__c', 'AITM_Location_Delivery_Point__r.AITM_Delivery_Point_Number__c', 'AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c','AITM_Location_Delivery_Point__r.AITM_IATA__c' ,'AITM_Rebate__c', 'AITM_Currency_Rebate1__c', 'AITM_Unit_Of_Measure_Rebate1__c', 'AITM_Tender__r.AITM_Density__c', 'AITM_Tender_Location__r.AITM_Product__c', 'AITM_Duration__c', ' AITM_Start_Date__c', 'AITM_End_Date__c', 'AITM_Awarded_Volume__c', 'AITM_Account__r.AITM_GRN__c', 'AITM_Account__r.Name', 'AITM_Location__c', 'AITM_Location__r.AITM_IATA__c', 'AITM_Location__r.AITM_ICAO__c', 'AITM_Location__r.AITM_Country__c', 'AITM_Location__r.AITM_IATA_ICAO__c','AITM_Location__r.Name', 'AITM_Offered_Volume__c', 'AITM_Offered_Differential__c', 'AITM_Pricing_Basis__r.AITM_Type__c', 'AITM_Current_Value__c','AITM_Pricing_Basis__c', 'AITM_Pricing_Basis__r.Name', 'AITM_Currency__c', 'AITM_Unit_Of_Measure__c', 'AITM_Credit_Days__c', 'AITM_Tender_Location__r.AITM_Delivery_Method__c', 'AITM_Last_Tender_Result__c', 'AITM_Tender_Result__c', 'AITM_Tender_Location__r.AITM_Is_Current_Round__c', 'AITM_Percentage_Volume_Offered__c', 'AITM_Requested_Volume_USG__c','AITM_Requested_Volume_UoM__c', 'AITM_Ad_hoc_Volume__c', 'AITM_Location_Delivery_Point__r.AITM_Delivery_Point_Number__c','AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c','AITM_History_Line_Item__c', 'AITM_History_Line_Item__r.AITM_Last_Tender_Result__c'});
            this.fromx('AITM_Tender_Location_Line_Item__c');
            this.wherex('AITM_Tender__c = \'' + String.escapeSingleQuotes(tenderId) + '\'');
            this.wherex('AITM_Tender_Location__r.AITM_Is_Current_Round__c = true', 'AND');
            if(recordTypeId != null) {
                this.wherex('RecordTypeId = \'' + recordTypeId + '\'', 'AND');
            }
            if (tenderResult != null) {
                this.wherex('AITM_Tender_Result__c IN : tenderResult','AND');
            }
            if(locationType == AITM_TenderDao.POLISH) {
                this.wherex('AITM_Tender_Location__r.AITM_Locations_Filter__c =\''+ POLISH_FILTER +'\'','AND');
            } else if(locationType == AITM_TenderDao.NONPOLISH) {
                this.wherex('AITM_Tender_Location__r.AITM_Locations_Filter__c !=\''+ POLISH_FILTER +'\'','AND');
            }
            this.orderbyx('AITM_Tender_Location__r.Name, AITM_Location__r.Name', 'ASC');
            return this.getQuery();
        }
    }

    /**
     * @description gets the debrief line items records based on existing TLLI default records
     * @param lineItemIds collection set of Id
     * @return List<AITM_Tender_Location_Line_Item__c> 
     */
    public List<AITM_Tender_Location_Line_Item__c> getDebriefLineItemRecords(Set<Id> lineItemIds) {
        return [SELECT Name, AITM_Account__c, AITM_Ad_hoc_Volume__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Start_Date__c, AITM_End_Date__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Description__c, AITM_Pricing_Excellence__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.Name, AITM_Volume__c, AITM_Requested_Volume_UoM__c, AITM_Round__c, AITM_Requested_Volume_USG__c, AITM_Offered_Volume__c, AITM_Percentage_Volume_Offered__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Offered_Differential__c, AITM_Tender_Location__c, AITM_Previous_TLLI_Id__c, AITM_Tender__c, AITM_Tender__r.AITM_Stage__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Previous_TLLI_Id__c IN :lineItemIds AND RecordTypeId = :TLLI_ID_RECORD_TYPE_DEBRIEF];
    }
    
    /**
    * @description gets Tender Location
    * @param tenderLocationID of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getTenderLocationWithLineItem(Id tenderLocationId) {
        return [SELECT Id, Name, AITM_Location__c, AITM_Is_Straddled__c,AITM_Apply_All_Tax_Fee_Check__c, (SELECT Id, AITM_Account__c, AITM_Tender__c, AITM_Additional_Notes_Taxes_and_Fees__c,AITM_Taxes_Fees__c,AITM_Straddled_Additional_Taxes_Fees__c, AITM_Straddled_Taxes_Fees__c, AITM_Is_Straddled__c FROM AITM_Tender_Location__r) FROM AITM_Tender_Location__c WHERE Id = :tenderLocationId];
    }
    
    /**
    * @description gets Tender Account
    * @param tenderID of type Id, collection of Accountobject
    * @return List collection of AITM_Tender_Account__c
    */
    public List<AITM_Tender_Account__c> getTenderCustomerByTenderIdAndAccount(String tenderId, List<String> AccountIds) {
        return [SELECT AITM_Account__r.Name, AITM_Account__r.AITM_GRN__c, AITM_Account__r.AITM_Exchange_Rate__c, AITM_Account__c, AITM_Invoice_Frequency__c, AITM_Affiliates_Account__c, AITM_Affiliates_Account__r.id, AITM_Credit_Days1__c, AITM_Tender__c, AITM_Tender__r.AITM_Start_Date__c, AITM_Tender__r.AITM_End_Date__c, AITM_Tender__r.AITM_Unit_Of_Measure__c FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :tenderId AND AITM_Account__c = :AccountIds];
    }
    
    /**
    * @description gets Tender Location
    * @param tenderID of type Id
    * @return List collection of AITM_Tender_Location__c
    */
    public List<AITM_Tender_Location__c> getStraddledTenderLocations(Id tenderId) {
        return [SELECT AITM_Is_Straddled__c,(SELECT Id, AITM_Additional_Notes_Taxes_and_Fees__c,AITM_Taxes_Fees__c,AITM_Straddled_Additional_Taxes_Fees__c, AITM_Straddled_Taxes_Fees__c, AITM_Is_Straddled__c FROM AITM_Tender_Location__r) FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId AND AITM_Is_Straddled__c = true];
    }
	
	/**
    * @description gets AITM_Tender_Location_Line_Item__c
    * @param tenderId of type Id
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
	public static List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemsWithTaxFees(Id tenderId) {
       return [SELECT AITM_Tender_Location__r.AITM_Round__c, AITM_Delivery_Method__c, AITM_Location_Delivery_Point__c, AITM_Product_Default__c, AITM_Tender_Id__c, AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_Record_Type_Name__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Is_Current_Round__c = true AND AITM_Tender__c = :tenderId AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false];
    }
    
	      /**	
    * @description gets AITM_Tender_Location_Taxes_and_Fees__c	
    * @param tenderId of type Id	
    * @return List collection of AITM_Tender_Location_Taxes_and_Fees__c	
    */	
    public static List<AITM_Tender_Location_Taxes_and_Fees__c> getTenderLocationLineItemsWithTaxFeesPreRound(Id tenderId, Decimal round) {	
       return [SELECT Name, AITM_Fuel_type__c ,AITM_Level__c,AITM_FEE_TAX_GROUP__c,AITM_FEE_TAX_NAME__c,AITM_Charge_Type__c,AITM_Value__c,AITM_Display_Currency__c,AITM_Compulsory_Conditional__c,AITM_Unit_of_measure__c,AITM_Record_Type_Name__c,AITM_Tender_Sector__c, AITM_Select_to_Apply_in_Contract__c, Tender_Location_Line_Item_Id__c,Tender_Location_Line_Item_Id__r.AITM_tender__c,Tender_Location_Line_Item_Id__r.AITM_IATA_Internal_Code__c,Tender_Location_Line_Item_Id__r.AITM_GRN__c FROM AITM_Tender_Location_Taxes_and_Fees__c WHERE Tender_Location_Line_Item_Id__r.AITM_round__c =:round AND Tender_Location_Line_Item_Id__r.AITM_Tender__c =: tenderId];	
      }	
	  
    /**
    * @description gets Tender Location Line Item by LineItem ids.
    * @param setOfLineItemIds Set collection of AITM_Tender_Location_Line_Item__c
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public List<AITM_Tender_Location_Line_Item__c> getTenderLocationLineItemBySetOfIds(Set<Id> setOfLineItemIds) {
         return [SELECT AITM_Tender_Location__r.AITM_Round__c,AITM_round__c,AITM_IATA_Internal_Code__c,AITM_GRN__c, AITM_Delivery_Method__c, AITM_Location_Delivery_Point__c, AITM_Product_Default__c, AITM_Tender_Id__c, AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Start_Date__c, AITM_End_Date__c,AITM_MIP_Parent_Id__c, AITM_ManualClonedBy__c FROM AITM_Tender_Location_Line_Item__c WHERE Id IN :setOfLineItemIds];
    
    }
	
	
	/**
    * @description gets Tender Location taxes and fees by line item ids.
    * @param setOfLineItemIds Set collection of AITM_Tender_Location_Line_Item__c
    * @return List collection of AITM_Tender_Location_Taxes_and_Fees__c
    */
    public List<AITM_Tender_Location_Taxes_and_Fees__c> getTaxesAndFeesBySetOfItemIds(Set<Id> setOfLineItemIds) { 
        return [SELECT Name, AITM_Fuel_type__c, AITM_Select_to_Apply_in_Contract__c,AITM_Display_Currency__c,AITM_Compulsory_Conditional__c, AITM_Unit_of_measure__c, AITM_Manually_Saved_Tax__c, Tender_Location_Line_Item_Id__c FROM AITM_Tender_Location_Taxes_and_Fees__c WHERE Tender_Location_Line_Item_Id__c IN :setOfLineItemIds];
    }
    
    /**
    * @description gets AITM_Tender_Location_Line_Item__c
    * @param tenderId of type Id
    * @param recordTypeId of type Id
    * @return List collection of AITM_Tender_Location_Line_Item__c
    */
    public static List<AITM_Tender_Location_Line_Item__c> getLineItemsByTenderAndRecordTypeId(Id tenderId, Id recordTypeId) {
       return [SELECT AITM_Tender_Location__r.AITM_Round__c, AITM_Delivery_Method__c, AITM_Location_Delivery_Point__c, AITM_Product_Default__c, AITM_Tender_Id__c, AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_Record_Type_Name__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Is_Current_Round__c = true AND AITM_Tender__c = :tenderId AND RecordTypeId =:recordTypeId  AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false];
    }
}