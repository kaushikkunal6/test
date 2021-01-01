/*************************************************************************
 * @author         Vitali
 * @date           01/December/2017
 * @group          AirBP
 * @description    TenderLocation Handler class

 * history
 * 01/December/2017   Vitali     Created 
 * 16/August/2018     srnandan   Modified -Added comments both at method and class level
 * 26/September/2018  Anusha     Modified AR-4083 Added logic to get getRoundsOptions previous round
 *                               in feedback table
 ****************************************************************************/
public with sharing class AITM_TenderLocationFeedback {
	
	/**
     * @description gets tender location based on id
     * @param tenderLocationId of type Id
     * @return AITM_Tender_Location__c
     */
	@AuraEnabled
	public static AITM_Tender_Location__c getTenderLocation(Id tenderLocationId) {
		return new AITM_LocationsDao().getTenderLocation(tenderLocationId);
	}

	/**
     * @description gets tender location for round
     * @param tenderLocationId of type Id
     * @param roundNumber of type Integer
     * @return AITM_Tender_Location__c
     */
	@AuraEnabled
	public static AITM_Tender_Location__c getTenderLocationForRound(Id tenderLocationId, Integer roundNumber) {
		AITM_Tender_Location__c tenderLocation = new AITM_LocationsDao().getTenderLocation(tenderLocationId);
		return new AITM_LocationsDao().getTenderLocationByTenderIdAndRoundNumber(tenderLocation.AITM_Tender__c, tenderLocation.AITM_Location__c, roundNumber);
	}

	/**
     * @description gets field access
     * @param objectName of type string
     * @return Map<String, Map<String, Boolean>>
     */
	@AuraEnabled(cacheable=true)
    public static Map<String, Map<String, Boolean>> getFieldsAccess(String objectName){
        Map<String, Map<String, Boolean>> fieldsAccess = new Map<String, Map<String, Boolean>>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldsMap = schemaMap.get(objectName).getDescribe().fields.getMap();
           for(String fieldName : fieldsMap.keySet()) {

                Map<String, Boolean> fieldAccess = new Map<String, Boolean>();
                fieldAccess.put('isUpdateable', fieldsMap.get(fieldName).getDescribe().isUpdateable());
                fieldAccess.put('isCreateable', fieldsMap.get(fieldName).getDescribe().isCreateable());
                fieldAccess.put('isAccessible', fieldsMap.get(fieldName).getDescribe().isAccessible());

                fieldsAccess.put(fieldName, fieldAccess);
         }

        return fieldsAccess;
        
    }

    /**
     * @description gets round options based on id
     * @param tenderLocationId of type Id
     * @return List<String>
     */
	@AuraEnabled
	public static  List<String> getRoundsOptions(Id tenderLocationId) {
        AITM_Tender_Location__c tenderLocation =  [SELECT AITM_Tender__c,AITM_Current_Round__c,AITM_Round__c FROM AITM_Tender_Location__c WHERE Id = :tenderLocationId];
        List<AggregateResult> result =  [SELECT Max(AITM_Round__c) maxRound FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderLocation.AITM_Tender__c];
        List<String> roundsOptions = new List<String>();
        Integer maxRound = Integer.valueOf(result[0].get('maxRound'));
        Integer currentRound = Integer.valueOf(tenderLocation.AITM_Round__c) ;
        
        for(Integer i=currentRound - 1;i!=0;i--){
            roundsOptions.add('Round ' + String.valueOf(i));
        }
        roundsOptions.add('Round ' + String.valueOf(currentRound));
        for(Integer i=currentRound;i<=maxRound;i++){
            if(!roundsOptions.contains('Round ' + String.valueOf(i))){
               roundsOptions.add('Round ' + String.valueOf(i)); 
            }
        }
 		
        return roundsOptions;
    }

    /**
     * @description update tender location 
     * @param tenderLocation of type AITM_Tender_Location__c
     * @return null
     */
	@AuraEnabled
	public static void updateTenderLocation(AITM_Tender_Location__c tenderLocation) {
		if(tenderLocation.AITM_Competitor_info__c != 'Other'){
			tenderLocation.AITM_Competitor_Info_Other__c = null;
		}
		update tenderLocation;
	}

	/**
     * @description gets pick list values
     * @param objectName of type string
     * @param auraIdToFieldName of type Map<String, String> 
     * @return Map<String, List<String>>
     */
	@AuraEnabled(cacheable=true)
	public static Map<String, List<String>> getPickValues(String objectName, Map<String, String> auraIdToFieldName){ 
		Map<String, List<String>> picklistResult = new Map<String, List<String>>();

		for(String auraId : auraIdToFieldName.keySet()){
			List<SelectOption> selectOptions = AITM_BaseUtils.getPickValues(objectName, auraIdToFieldName.get(auraId), NULL);
			List<String> stringValues = new List<String>();
			for(SelectOption so : selectOptions){
				stringValues.add(so.getValue());
			}
			picklistResult.put(auraId, stringValues);
		}

		return picklistResult;
	}

}