public with sharing class AITM_TenderLocationTaxesFeesController {
    
	@AuraEnabled
	public static AITM_Tender_Location__c getTenderLocation(Id tenderLocationId) {
		return new AITM_LocationsDao().getTenderLocation(tenderLocationId);
	}
    
	@AuraEnabled
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
    
	@AuraEnabled
	public static void updateTenderLocation(AITM_Tender_Location__c tenderLocation) {
		update tenderLocation;
	}
    
}