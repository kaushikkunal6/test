/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP

 * history
 * 01/December/2017  George          Created
 * 15/June/2018      Shweta          Modified -AR-3404 Removed the rowc field in the method 
 *                                   CustomerPerformanceAdapter as its data type has to be changed to text from number
 * 15/June/2018      Shweta          Modified-Ar-3404 Added the rowc field in the method CustomerPerformanceAdapter 
                                     as its data type has to be changed to text from number 
 *********************************************************************************************/
public with sharing class AITM_OfferCurrentPerformanceController {

    /**
     * @description gets customers based on tenderlocationid
     * @param tenderLocation of type Id
     * @return List<CustomerPerformanceAdapter>
     */
    public static @AuraEnabled List<CustomerPerformanceAdapter> getCustomers(Id tenderLocationId) {
        AITM_LocationsDao.TenderLocationLineItemsDao locationsData = new AITM_LocationsDao.TenderLocationLineItemsDao();

        List<CustomerPerformanceAdapter> customers = new List<CustomerPerformanceAdapter>();
        for(AITM_Tender_Location_Line_Item__c originalRecord : locationsData.getLineItemsWithPricingInformation(tenderLocationId)) {
            customers.add(new CustomerPerformanceAdapter(originalRecord));
        }
        return customers;
    }
	
    /**
     * @description inner class holds the customerperformance adapter
     */
    public class CustomerPerformanceAdapter {
        public @AuraEnabled String recordId;
        public @AuraEnabled String name;
        public @AuraEnabled String gp;
        public @AuraEnabled String wc;
        public @AuraEnabled String rowc;
        public @AuraEnabled String percentOfPortfolio;
		
		/**
         * @description overloaded constructor
         * @param originalRecord of type AITM_Tender_Location__Line_Item__c
         */
        public CustomerPerformanceAdapter(AITM_Tender_Location_Line_Item__c originalRecord) {
            this.recordId = originalRecord.AITM_Account__c;
            this.name = originalRecord.AITM_Account__r.Name;
            this.gp = this.getFormattedDecimalValue(originalRecord.AITM_Gross_Profit__c);
            this.wc = this.getFormattedDecimalValue(originalRecord.AITM_Working_Capital__c);
            this.rowc = originalRecord.AITM_Return_On_WC__c;
            this.percentOfPortfolio = '';
        }
		
		/**
         * @description gets formatted decimal value
         * @param originalValue of type decimal
         * @return string
         */
        private String getFormattedDecimalValue(Decimal originalValue) {
            return originalValue == null ? '0.0' : originalValue.toPlainString();
        }

    }
}