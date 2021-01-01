/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP

 * history
 * 01/December/2017  George          Created
 * 15/June/2018      Shweta          Modified -AR-3404 Removed the rowc field in the method 
 *                                   PricingImpactAdapter as its data type has to be changed to text from number
 * 15/June/2018      Shweta          Modified-Ar-3404 Added the rowc field in the method PricingImpactAdapterAdapter 
                                     as its data type has to be changed to text from number  
 *********************************************************************************************/

public with sharing class AITM_OfferPricingImpactController {


    /**
     * @description gets customer details based on tenderlocationid
     * @param tenderLocationId of type Id
     * @return List<PricingImpactAdapter>
     */
    public static @AuraEnabled List<PricingImpactAdapter> getCustomers(Id tenderLocationId) {
        AITM_LocationsDao.TenderLocationLineItemsDao locationsData = new AITM_LocationsDao.TenderLocationLineItemsDao();

        List<PricingImpactAdapter> customers = new List<PricingImpactAdapter>();
        for(AITM_Tender_Location_Line_Item__c originalRecord : locationsData.getLineItemsWithPricingInformation(tenderLocationId)) {
            customers.add(new PricingImpactAdapter(originalRecord));
        }
        return customers;
    }
	
	/**
     * @description Inner class pricingimpact adapter
     */
    public class PricingImpactAdapter {
        public @AuraEnabled String recordId;
        public @AuraEnabled String name;
        public @AuraEnabled String targetPrice;
        public @AuraEnabled String adjustedDiff;
        public @AuraEnabled String ppi;
        public @AuraEnabled String newGP;
        public @AuraEnabled String newWC;
        public @AuraEnabled String rowc;
        public @AuraEnabled String percentOfPortfolio;
        public @AuraEnabled String weightedAveragePorfolioDifferential;
		
        /**
         * @description overloaded constructor
         * @param originalRecord of type AITM_Tender_Location_Line_Item__c
         */
        public PricingImpactAdapter(AITM_Tender_Location_Line_Item__c originalRecord) {
            this.recordId = originalRecord.AITM_Account__c;
            this.name = originalRecord.AITM_Account__r.Name;
            this.targetPrice = getFormattedDecimalValue(originalRecord.AITM_Target_Price__c);
            this.adjustedDiff = getFormattedDecimalValue(originalRecord.AITM_Adjusted_Differential__c);
            this.ppi = getFormattedDecimalValue(originalRecord.AITM_PPI__c);
            this.newGP = getFormattedDecimalValue(originalRecord.AITM_Gross_Profit__c);
            this.newWC = getFormattedDecimalValue(originalRecord.AITM_Working_Capital__c);
            this.rowc = originalRecord.AITM_Return_On_WC__c;
            this.percentOfPortfolio = '';
            this.weightedAveragePorfolioDifferential = '';
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