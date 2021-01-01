/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    controller class used in aura component to display debrief summary locations

 * history
 * 06/December/2017  George       Created 
 * 10/April/2018     Shweta       Modified - AR-2464  To display only IATA code for the locations in the debrief email modified method 
 *                                getLocationsSummaryInfo      
 * 31/July/2018      Shweta       Modified method getLocationsSummaryInfo for rounding off the volume.                        
 * 23/August/2018    Ravi         Modified - AR-4139 - Updated methods LocationSummaryAdapter and getLocationsSummaryInfo to add null check
 * 04/September/2018 Anusha       Modified - AR-4153 - Updated methods getLocationsummaryInfor to get debrief
                                  values for Adhoc locations    
 * 03/December/2018  srnandan     Modified - AR-4713 Added condition to check internal code and assign internal code if present to iata for display                                 
 * 19/January/2019   srnandan     Modified - AR-4457 modified method getLocationsSummaryInfo taking set to remove duplicates and volumes to format
 *************************************************************************/
public with sharing class AITM_DeBriefLocSummaryController {

	@AuraEnabled
	public static Map<String, String> getTenderSummaryValues(AITM_Tender__c tender) {
		LocationSummaryAdapter locSummaryWrapper = new LocationSummaryAdapter(tender);
		return locSummaryWrapper.tableValuesMap;
	}

	public class LocationSummaryAdapter {
		public Map<String, String> tableValuesMap;
		private final ID TLLI_ID_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();

		public LocationSummaryAdapter(AITM_Tender__c tender){
			//List<AITM_Tender_Location_Line_Item__c> deBriefCurrentRoundLineItems = new AITM_LocationsDao().getTenderLocationLineItems(tender.Id, null, TLLI_ID_RECORD_TYPE_DEBRIEF);
			this.tableValuesMap = new Map<String, String>();
			this.getLocationsSummaryInfo(tender.Id, null, TLLI_ID_RECORD_TYPE_DEBRIEF);
			
		}

		private void getLocationsSummaryInfo(Id tenderId, String filter, String recordTypeId) {
			Decimal gainedVolume = 0;
			List<String> gainedLocationsList = new List<String>();
			Set<String> gainedLocations = new Set<String>();
			Decimal retainedVolume = 0;
			List<String> retainedLocationsList = new List<String>();
			Set<String> retainedLocations = new Set<String>();
			Decimal lostVolume = 0;
			List<String> lostLocationsList = new List<String>();
			Set<String> lostLocations = new Set<String>();
			Decimal marketInformationVolume = 0;
    		List<String> marketInformationLocationsList = new List<String>();
			Set<String> marketInformationLocations = new Set<String>();

			for(AITM_Tender_Location_Line_Item__c lineItem: new AITM_LocationsDao().getTenderLocationLineItems(tenderId, null, recordTypeId)) { 
				if(lineItem.AITM_Offered_Volume__c != null){
				if(lineItem.AITM_Tender_Result__c == 'BG'){
					gainedVolume += (lineItem.AITM_Offered_Volume__c).round(system.roundingMode.HALF_UP);
					gainedLocations.add((lineItem.AITM_Location__r.AITM_Internal_Code__c != null ? lineItem.AITM_Location__r.AITM_Internal_Code__c : lineItem.AITM_Location__r.AITM_IATA__c));
				}else if(lineItem.AITM_Tender_Result__c == 'BR'){
					retainedVolume += (lineItem.AITM_Offered_Volume__c).round(system.roundingMode.HALF_UP);
					retainedLocations.add((lineItem.AITM_Location__r.AITM_Internal_Code__c != null ? lineItem.AITM_Location__r.AITM_Internal_Code__c : lineItem.AITM_Location__r.AITM_IATA__c));
				}else if(lineItem.AITM_Tender_Result__c == 'LB'){
					lostVolume += (lineItem.AITM_Offered_Volume__c).round(system.roundingMode.HALF_UP);
					lostLocations.add((lineItem.AITM_Location__r.AITM_Internal_Code__c != null ? lineItem.AITM_Location__r.AITM_Internal_Code__c : lineItem.AITM_Location__r.AITM_IATA__c));
				}else if(lineItem.AITM_Tender_Result__c == 'MI' || lineItem.AITM_Tender_Result__c == 'MIX'){
					marketInformationVolume += (lineItem.AITM_Offered_Volume__c).round(system.roundingMode.HALF_UP);
					marketInformationLocations.add((lineItem.AITM_Location__r.AITM_Internal_Code__c != null ? lineItem.AITM_Location__r.AITM_Internal_Code__c : lineItem.AITM_Location__r.AITM_IATA__c));
				}
			  }
			  
			  if(lineItem.AITM_Ad_hoc_Volume__c == true && lineItem.AITM_Awarded_volume__c != Null) {
					if(lineItem.AITM_Tender_Result__c == 'BG' ){
						gainedVolume += (lineItem.AITM_Awarded_volume__c).round(system.roundingMode.HALF_UP);
						gainedLocations.add((lineItem.AITM_Location__r.AITM_Internal_Code__c != null ? lineItem.AITM_Location__r.AITM_Internal_Code__c : lineItem.AITM_Location__r.AITM_IATA__c));
					}else if(lineItem.AITM_Tender_Result__c == 'BR'){
						retainedVolume += (lineItem.AITM_Awarded_volume__c).round(system.roundingMode.HALF_UP);
						retainedLocations.add((lineItem.AITM_Location__r.AITM_Internal_Code__c != null ? lineItem.AITM_Location__r.AITM_Internal_Code__c : lineItem.AITM_Location__r.AITM_IATA__c));
					}else if(lineItem.AITM_Tender_Result__c == 'LB'){
						lostVolume += (lineItem.AITM_Awarded_volume__c).round(system.roundingMode.HALF_UP);
     					lostLocations.add((lineItem.AITM_Location__r.AITM_Internal_Code__c != null ? lineItem.AITM_Location__r.AITM_Internal_Code__c : lineItem.AITM_Location__r.AITM_IATA__c));
					}else if(lineItem.AITM_Tender_Result__c == 'MI' || lineItem.AITM_Tender_Result__c == 'MIX'){
						marketInformationVolume += (lineItem.AITM_Awarded_volume__c).round(system.roundingMode.HALF_UP);
						marketInformationLocations.add((lineItem.AITM_Location__r.AITM_Internal_Code__c != null ? lineItem.AITM_Location__r.AITM_Internal_Code__c : lineItem.AITM_Location__r.AITM_IATA__c));
					}	
				}
			}

			gainedLocationsList.addAll(gainedLocations);
            retainedLocationsList.addAll(retainedLocations);
            lostLocationsList.addAll(lostLocations);
            marketInformationLocationsList.addAll(marketInformationLocations);

			this.tableValuesMap.put('gainedVolume', String.valueOf(gainedVolume.format()));
			this.tableValuesMap.put('gainedLocations', String.join(gainedLocationsList, ', '));
			this.tableValuesMap.put('retainedVolume', String.valueOf(retainedVolume.format()));
			this.tableValuesMap.put('retainedLocations', String.join(retainedLocationsList, ', '));
			this.tableValuesMap.put('lostVolume', String.valueOf(lostVolume.format()));
			this.tableValuesMap.put('lostLocations', String.join(lostLocationsList, ', '));
			this.tableValuesMap.put('marketInformationVolume', String.valueOf(marketInformationVolume.format()));
			this.tableValuesMap.put('marketInformationLocations', String.join(marketInformationLocationsList, ', '));
		}
	}
}