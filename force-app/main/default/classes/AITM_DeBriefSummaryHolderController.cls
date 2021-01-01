public with sharing class AITM_DeBriefSummaryHolderController {
    
	@AuraEnabled
	public static AITM_Tender__c getTender(Id tenderId) {
		return new AITM_TenderDao().getTender(tenderId);
	}

	@AuraEnabled
	public static void saveTender(AITM_Tender__c tender) {
		update tender;
	}
    
}