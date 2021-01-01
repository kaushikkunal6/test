/***********************************************************************************************
 * @author           shweta
 * @date             20/December/2020
 * @group            AirBP
 * @description      This class is used to calculate the service level on tender location level

 * history
 * 20/December/2020 shweta      Created 
 ************************************************************************************************/

public without sharing class AITM_AdditionalCustomerLocation {    /**
     * @description gets customer details based on tenderlocationid
     * @param tenderLocationId of type Id
     * @return List<PricingImpactAdapter>
     */
    public static @AuraEnabled List<AITM_Tender_Location__c> getLocations(Id tenderLocationId) {
        List<AITM_Tender_Location__c> customers = new List<AITM_Tender_Location__c>();
        customers = [SELECT Id,AITM_AM_Comments__c,AITM_LM_Comments__c,AITM_Location_Default_Service_Level__c,AITM_Customer_Service_Level__c,AITM_Aircraft_Type_Serrvice__c,AITM_Approve_the_Service_Level__c FROM AITM_Tender_Location__c  WHERE Id = :tenderLocationId];
         return customers;
    }

    /**
     * @description to update the tenderLocation on the basis of value update on UI
     * @param tenderLocation of type AITM_Tender_Location__c,latest of type String,whetherUpdated of type Boolean
     * @return Null
     */   
   
	public static  @AuraEnabled void updateTenderLocation(AITM_Tender_Location__c tenderLocation,String latest,Boolean whetherUpdated) {
        Map<String,Integer> serviceLevelMap = new Map<String,Integer>{'Level I'=>1,'Level II'=>2,'Level III'=>3};
        String currentLevel = tenderLocation.AITM_Customer_Service_Level__c;
        Boolean currentApprovalFlag = tenderLocation.AITM_Approve_the_Service_Level__c;
        if(whetherUpdated){
            if(currentApprovalFlag){
                           
                
                            tenderLocation.AITM_Customer_Service_Level__c = latest;
                            tenderLocation.AITM_Service_Level__c = latest;
                            tenderLocation.AITM_CustomerDefaultValue__c = 0;
                            tenderLocation.AITM_LocationDefaultValue__c = 1;
                               if(tenderLocation.AITM_Status__c == 'Priced'){
                                    tenderLocation.AITM_Status__c = 'Awaiting price';
                               }                        
                }else{
                   tenderLocation.AITM_Customer_Service_Level__c = latest;
                   tenderLocation.AITM_Service_Level__c = latest;
                   tenderLocation.AITM_CustomerDefaultValue__c = 1;
                   tenderLocation.AITM_LocationDefaultValue__c = 0;
            }
                               
        }else{
              Integer s = serviceLevelMap.get(latest);
              Integer y = serviceLevelMap.get(currentLevel);
              Decimal locationLevel = tenderLocation.AITM_LocationDefaultValue__c;
              tenderLocation.AITM_Customer_Service_Level__c = latest;
              tenderLocation.AITM_Service_Level__c = latest;
              tenderLocation.AITM_CustomerDefaultValue__c = s;
                if(s>locationLevel && tenderLocation.AITM_Status__c == 'Priced'){
                tenderLocation.AITM_Status__c = 'Awaiting price'; 
            }
        }  
     	update tenderLocation;
	}
    public class PricingImpactAdapter {
        public @AuraEnabled String amComments;
        public @AuraEnabled String lmComments;
        public @AuraEnabled String  locationDefaultServiceLevel;
        /*public @AuraEnabled String ;
        public @AuraEnabled String ;
        public @AuraEnabled String ;
        public @AuraEnabled String ;
        public @AuraEnabled String ;
        public @AuraEnabled String ;
        public @AuraEnabled String  ;*/
		
        /**
         * @description overloaded constructor
         * @param originalRecord of type AITM_Tender_Location_Line_Item__c
         */
        public PricingImpactAdapter(AITM_Tender_Location__c originalRecord) {
            this.amComments = originalRecord.AITM_AM_Comments__c;
            this.lmComments = originalRecord.AITM_LM_Comments__c;
            this.locationDefaultServiceLevel = originalRecord.AITM_Location_Default_Service_Level__c;
            /*this.targetPrice = getFormattedDecimalValue(originalRecord.AITM_Target_Price__c);
            this.adjustedDiff = getFormattedDecimalValue(originalRecord.AITM_Adjusted_Differential__c);
            this.ppi = getFormattedDecimalValue(originalRecord.AITM_PPI__c);
            this.newGP = getFormattedDecimalValue(originalRecord.AITM_Gross_Profit__c);
            this.newWC = getFormattedDecimalValue(originalRecord.AITM_Working_Capital__c);
            this.rowc = originalRecord.AITM_Return_On_WC__c;
            this.percentOfPortfolio = '';
            this.weightedAveragePorfolioDifferential = '';*/
        }

		/**
         * @description gets formmatted decimal value
         * @param originalValue of type Decimal
         * @return string
         */
        private String getFormattedDecimalValue(Decimal originalValue) {
            return originalValue == null ? '0.0' : originalValue.toPlainString();
        }
    }

}