public with sharing class AITM_OfferCustomerPlanController {

    public static @AuraEnabled List<CustomerPlanAdapter> getCustomers(Id tenderLocationId) {
        AITM_LocationsDao.TenderLocationLineItemsDao locationsData = new AITM_LocationsDao.TenderLocationLineItemsDao();

        List<CustomerPlanAdapter> customers = new List<CustomerPlanAdapter>();
        for(AITM_Tender_Location_Line_Item__c originalRecord : locationsData.getLineItemsWithPricingInformation(tenderLocationId)) {
            customers.add(new CustomerPlanAdapter(originalRecord));
        }
        return customers;
    }

    public class CustomerPlanAdapter {
        public @AuraEnabled String recordId;
        public @AuraEnabled String name;
        public @AuraEnabled String grn;
        public @AuraEnabled String customerPlan;
        public @AuraEnabled String interest;
        public @AuraEnabled String probability;
        public @AuraEnabled String requestedVolume;

        public CustomerPlanAdapter(AITM_Tender_Location_Line_Item__c originalRecord) {
            this.recordId = originalRecord.AITM_Account__c;
            this.name = originalRecord.AITM_Account__r.Name;
            this.grn = originalRecord.AITM_Account__r.AITM_GRN__c;
            this.customerPlan = '';
            this.interest = '';
            this.probability = '';
            this.requestedVolume = this.getFormattedDecimalValue(originalRecord.AITM_Volume__c);
        }

        private String getFormattedDecimalValue(Decimal originalValue) {
            return originalValue == null ? '0.0' : originalValue.toPlainString();
        }

    }
}