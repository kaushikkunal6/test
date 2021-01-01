public with sharing class AITM_OfferCustomerBusinessController {

    public static @AuraEnabled List<CustomerBusinessAdapter> getCustomers(Id tenderLocationId) {
        AITM_LocationsDao.TenderLocationLineItemsDao locationsData = new AITM_LocationsDao.TenderLocationLineItemsDao();

        List<CustomerBusinessAdapter> customers = new List<CustomerBusinessAdapter>();
        for(AITM_Tender_Location_Line_Item__c originalRecord : locationsData.getLineItemsWithPricingInformation(tenderLocationId)) {
            customers.add(new CustomerBusinessAdapter(originalRecord));
        }
        return customers;
    }

    public class CustomerBusinessAdapter {	
		public @AuraEnabled String tenderlinkId;
        public @AuraEnabled String tenderlink;
        public @AuraEnabled String recordId;
        public @AuraEnabled String name;
        public @AuraEnabled String pricingBasis;
        public @AuraEnabled String description;
        public @AuraEnabled String actualsVolume;
        public @AuraEnabled String variance;
        public @AuraEnabled String lastTenderResult;
        public @AuraEnabled String averageUplift;
        public @AuraEnabled String curuom;
        public @AuraEnabled String differential;

        public CustomerBusinessAdapter(AITM_Tender_Location_Line_Item__c originalRecord) {
            this.tenderlinkId = originalRecord.AITM_History_Line_Item__c;
            this.tenderlink = originalRecord.AITM_History_Line_Item__r.Name;
            this.recordId = originalRecord.AITM_Account__c;
            this.name = originalRecord.AITM_Account__r.Name;
            this.pricingBasis = originalRecord.AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name;
            this.description = originalRecord.AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c;
            this.actualsVolume = this.getFormattedDecimalValue(originalRecord.AITM_History_Line_Item__r.AITM_Volume__c);
            this.variance = this.getFormattedDecimalValue(originalRecord.AITM_History_Line_Item__r.AITM_Variance__c);
            this.lastTenderResult = originalRecord.AITM_History_Line_Item__r.AITM_Tender_Result__c;
            this.averageUplift = '';
            this.curuom = originalRecord.AITM_Currency__c + '/' + originalRecord.AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c;
            this.differential = this.getFormattedDecimalValue(originalRecord.AITM_History_Line_Item__r.AITM_Offered_Differential__c);
            
        }

        private String getFormattedDecimalValue(Decimal originalValue) {
            return originalValue == null ? '0.0' : originalValue.toPlainString();
        }

    }
}