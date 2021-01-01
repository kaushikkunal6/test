public with sharing class AITM_TenderFeedbackComments {
    
    public static final String VALUE_TYPE_DOUBLE = 'DOUBLE';
    public static final String VALUE_TYPE_PERCENT = 'PERCENT';
    public static final String VALUE_TYPE_INTEGER = 'INTEGER';
    public static final String VALUE_TYPE_DATE = 'DATE';
    public static final String SHARING_REASON = 'Sharing_To_Pricing_Delegates__c';
    private static final String CURRENT_USER_PROFILE = new AITM_UsersDao().getProfileName(UserInfo.getUserId());
    public final static Set<String> PROFILES_ALLOWED_TO_UPDATE = new Set<String>{
        'System Administrator',
            'Air_TMAccount Manager',
            'Air_TMLABP',
            'Air_TMLABPLogin'
            };
               
    @AuraEnabled
    public static  List<TenderLocationAdapter>  getTenderLocationDetails(Id recordId, String currentRoundNumber) {
    	List<TenderLocationAdapter> locations = new List<TenderLocationAdapter>();
        locations = getBaseTenderLocations(recordId, currentRoundNumber);
        return locations;
    }                
    
    private static List<TenderLocationAdapter> getBaseTenderLocations(Id tenderId, String currentRoundNumber) {
        Decimal decimalRound = Decimal.valueOf(currentRoundNumber);
        List<TenderLocationAdapter> locations = new List<TenderLocationAdapter>();
        //List<AITM_Tender_Location__c> tenderDetails = [SELECT Id, AITM_Comments__c,Name,AITM_Location__c,AITM_Location__r.Name,AITM_LM_Comments__c,AITM_Level_Of_Interest__c,AITM_Number_Of_Bidders__c,AITM_Position__c,AITM_Leading_Bid__c,AITM_Distance_From_Leading_Bid2__c,AITM_Offered_Differential__c,AITM_Leading_Bid_Currency__c,AITM_Unit_Of_Measure__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c=:tenderId AND AITM_Round__c =:decimalRound];
        List<AITM_Tender_Location__c> tenderDetails = [SELECT Id, (SELECT id, name, Owner.Name,AITM_Offered_Differential__c, AITM_Pricing_Basis__r.Name FROM AITM_Tender_Location__r ), AITM_Comments__c,Name,AITM_Location__c,AITM_Location__r.Name,AITM_LM_Comments__c,AITM_Level_Of_Interest__c,AITM_Number_Of_Bidders__c,AITM_Position__c,AITM_Leading_Bid__c,AITM_Distance_From_Leading_Bid2__c,AITM_Offered_Differential__c,AITM_Leading_Bid_Currency__c,AITM_Unit_Of_Measure__c,AITM_Offered_Differential_Currency__c,AITM_Offered_Differential_UoM__c,AITM_Leading_Bid_UoM__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c=:tenderId AND AITM_Round__c =:decimalRound];
        for(AITM_Tender_Location__c tenderLocation : tenderDetails) {
            locations.add(new TenderLocationAdapter(tenderLocation)); 
        }
        return locations;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getPickValues(String objectName, String fieldName){ 
        Map<String, String> options = new Map<String, String>();
        List<SelectOption> selectOptions = AITM_BaseUtils.getPickValues(objectName, fieldName, NULL);
        List<String> stringValues = new List<String>();
        for(SelectOption so : selectOptions){
            options.put(so.getValue(),so.getLabel());
        }
        return options;
    }
    @AuraEnabled
    public static void saveTenderFeedbackComments(String tenderLocationList) {
        List<AITM_Tender_Location__c> tenderLocationListToUpdate = new List<AITM_Tender_Location__c>();
        List<TenderLocationUpdateWrapper> wrappedLocations = new List<TenderLocationUpdateWrapper>();
        if(tenderLocationList.contains('[')){
            wrappedLocations = (List<TenderLocationUpdateWrapper>) JSON.deserialize(tenderLocationList, List<TenderLocationUpdateWrapper>.class);
            for (TenderLocationUpdateWrapper wrappedRecord : wrappedLocations) {
                tenderLocationListToUpdate.add(wrappedRecord.unwrap());
            }
            update tenderLocationListToUpdate;
        }
    }
    public inherited sharing class TenderLocationUpdateWrapper {
        public @AuraEnabled String tenderlocId;
        public @AuraEnabled String locationName;
        public @AuraEnabled String pricingResponsibility;
        public @AuraEnabled String AMFeedback;
        public @AuraEnabled String LMFeedback;
        public @AuraEnabled String LevelOfInterest;
        public @AuraEnabled Decimal Bidders;
        public @AuraEnabled Decimal Position;
        public @AuraEnabled Decimal EstimatedleadingBid;
        public @AuraEnabled Decimal DistleadingBid;
        public @AuraEnabled Decimal CurrentDiff;
        public @AuraEnabled String currencylist;
        public @AuraEnabled String UOM;
        public @AuraEnabled String PricingBasis;
        
        public AITM_Tender_Location__c unwrap() {
            AITM_Tender_Location__c location = new AITM_Tender_Location__c();
            location.id = this.tenderlocId;
            //if(this.locationName != null){
                //location.AITM_Location__r.Name = this.locationName;
           //}
            location.AITM_Comments__c = this.AMFeedback != null ? this.AMFeedback : '';
            location.AITM_LM_Comments__c = this.LMFeedback != null ? this.LMFeedback : '';
            location.AITM_Level_Of_Interest__c = this.LevelOfInterest != 'None' ? this.LevelOfInterest : '';
            location.AITM_Number_Of_Bidders__c = this.Bidders != null ? this.Bidders : null;
            location.AITM_Position__c = this.Position != null ? this.Position : null;
            location.AITM_Leading_Bid__c = this.EstimatedleadingBid != null ? this.EstimatedleadingBid : null;
            location.AITM_Distance_From_Leading_Bid2__c = this.DistleadingBid != null ? this.DistleadingBid : null;
            location.AITM_Leading_Bid_Currency__c = this.currencylist != null ? this.currencylist : '';
            location.AITM_Offered_Differential_Currency__c = this.currencylist != null ? this.currencylist : '';
            location.AITM_Leading_Bid_UoM__c = this.UOM != null ? this.UOM : '';
            location.AITM_Offered_Differential_UoM__c = this.UOM != null ? this.UOM : '';
            location.AITM_Unit_Of_Measure__c = this.UOM != null ? this.UOM : '';
            return location;
        }
    }
    public inherited sharing class TenderLocationAdapter {
        public @AuraEnabled String tenderlocId;
        public @AuraEnabled String locationName;
        public @AuraEnabled String pricingResponsibility;
        public @AuraEnabled String AMFeedback;
        public @AuraEnabled String LMFeedback;
        public @AuraEnabled String LevelOfInterest;
        public @AuraEnabled Decimal Bidders;
        public @AuraEnabled Decimal Position;
        public @AuraEnabled Decimal EstimatedleadingBid;
        public @AuraEnabled Decimal DistleadingBid;
        public @AuraEnabled Decimal CurrentDiff;
        public @AuraEnabled String currencylist;
        public @AuraEnabled String UOM;
        public @AuraEnabled String PricingBasis;
        
        public TenderLocationAdapter(AITM_Tender_Location__c originalRecord) {
            this.tenderlocId = originalRecord.Id;
            this.locationName = originalRecord.AITM_Location__r.Name;
            this.setPricingResponsibilities(originalRecord);
            this.AMFeedback = originalRecord.AITM_Comments__c;
            this.LMFeedback = originalRecord.AITM_LM_Comments__c;
            this.LevelOfInterest =  originalRecord.AITM_Level_Of_Interest__c;
            this.Bidders = originalRecord.AITM_Number_Of_Bidders__c;
            this.Position = originalRecord.AITM_Position__c;
            this.EstimatedleadingBid = originalRecord.AITM_Leading_Bid__c;
            this.DistleadingBid = originalRecord.AITM_Distance_From_Leading_Bid2__c;
            this.currencylist = originalRecord.AITM_Leading_Bid_Currency__c;
            this.UOM = originalRecord.AITM_Unit_Of_Measure__c;
        }
        public void setPricingResponsibilities(AITM_Tender_Location__c originalRecord) {
            pricingResponsibility ='';
            List<String> pricingResponsibilityNamesList = new List<String>();
            Set<String> pricingResponsibilityNames = new Set<String>();
            List<String> pricingBasisList = new List<String>();
            Set<String> pricingBasisSet = new Set<String>();
            Map<Decimal,String> lineItemMap = new Map<Decimal,String>();
            List<Decimal> diffList = new List<Decimal>();
            for (AITM_Tender_Location_Line_Item__c lineItem : originalRecord.AITM_Tender_Location__r) {
                pricingResponsibilityNames.add(lineItem.Owner.Name);
            }
            pricingResponsibilityNamesList.addAll(pricingResponsibilityNames);
            this.pricingResponsibility = String.join(pricingResponsibilityNamesList,',');
            
            for (AITM_Tender_Location_Line_Item__c lineItem :  originalRecord.AITM_Tender_Location__r){
              lineItemMap.put( lineItem.AITM_Offered_Differential__c,lineItem.AITM_Pricing_Basis__r.Name);  
               diffList.add(lineItem.AITM_Offered_Differential__c);
            }
            
            if(!diffList.isEmpty()){
            diffList.sort();
            this.CurrentDiff = diffList[0];
                this.PricingBasis =  lineItemMap.get(diffList[0]); 
            }
            else{
            this.CurrentDiff = 0;
                this.PricingBasis = '';
            }
        }
    }
}