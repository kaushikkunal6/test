/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Implementation of Queueable interface and Insert new TLLI.

 * history
 * 01/December/2017  George          Created
 * 15/March/2018     Ravi Pamidi     Updated Credit Rating of Customer to Credit Rating formula field.
 * 17/May/2018       srnandan        Modified - AR-3168 - Removed required field 'AITM_Rebate__c' => 'Rebate'
 * 10/May/2019       Saravan         Modified - AR-5004 - Removed the mandatory field call
 *************************************************************************************/
public with sharing class AITM_TenderLocationPricingService implements Queueable, Database.AllowsCallouts {
    private static final String PRICING_INFORMATION_REQUEST = 'Pricing Information';
    private static final String TARGET_PRICE_REQUEST = 'Target Price';
    private static final Integer MAX_CALLOUTS_PER_ONE_FUTURE = 5;

    /**
     * @description gets the instance of AITM_TenderLocationPricingService
     * @param null
     * @return AITM_TenderLocationPricingService class object
     */
    public static AITM_TenderLocationPricingService getInstance() {
        if (instance == null) {
            instance = new AITM_TenderLocationPricingService(null, null);
        }
        return instance;
    }

    private static AITM_TenderLocationPricingService instance;

    private Set<Id> scopeIds;
    private String requestType;

    /**
     * @description default constructor
     * @param scopeIds
     * @param requestType
     */
    public AITM_TenderLocationPricingService(Set<Id> scopeIds, String requestType) {
        this.scopeIds = scopeIds;
        this.requestType = requestType;
    }

    /**
     * @description execute the queueable context
     * @param null
     * @return void
     */
    public void execute(QueueableContext context) {
        if (scopeIds.size() > MAX_CALLOUTS_PER_ONE_FUTURE) {
            Set<Id> partialSet = new Set<Id>();
            for (Id locationLineItemId : scopeIds) {
                partialSet.add(locationLineItemId);
                if (partialSet.size() >= MAX_CALLOUTS_PER_ONE_FUTURE) {
                    break;
                }
            }
            this.retrievePricingInformation(partialSet, requestType);
            scopeIds.removeAll(partialSet);
            System.enqueueJob(new AITM_TenderLocationPricingService(scopeIds, requestType));
        } else {
            this.retrievePricingInformation(scopeIds, requestType);  
        }
    }

    /**
     * @description retrieve Pricing Information and update Line Item
     * @param recordIds
     * @param requestName
     * @return void
     */
    public void retrievePricingInformation(Set<Id> recordIds, String requestName) {
        List<AITM_Tender_Location_Line_Item__c> lineItems = new List<AITM_Tender_Location_Line_Item__c>();
        AITM_PricingServiceRepository.PricingService pricingService = AITM_PricingServiceRepository.getInstance().getPricingService();
        for (AITM_Tender_Location_Line_Item__c lineItem : new AITM_LocationsDao.TenderLocationLineItemsDao().getLineItemsWithPricingInformation(recordIds)) {
            if (requestName == AITM_TenderLocationPricingService.TARGET_PRICE_REQUEST) {
                lineItems.add((AITM_Tender_Location_Line_Item__c) pricingService.retrieveTargetPrice(lineItem));
            } else {
                lineItems.add((AITM_Tender_Location_Line_Item__c) pricingService.retrievePricingInformation(lineItem));
            }
        }
        Database.update(lineItems, false);
    }

    /**
     * @description Trigger Adapter class which implements SobjectHandler in Trigger factory
     * @param null
     */
    public class TriggerAdapter implements AITM_TriggerFactory.SObjectHandler {
        private final Map<String, String> REQUIRED_FIELDS_PROS_CALL = new Map<String, String> {
            'AITM_Invoice_Frequency__c' => 'Invoice Frequency',
            'AITM_Sales_Pricing_Period__c' => 'Sales Pricing Period',
            'AITM_Credit_Days__c' => 'Days',
            'AITM_Offered_Volume__c' => 'Offered Volume',
            'AITM_Offered_Differential__c' => 'Differential',
            'AITM_Volume__c' => 'Volume',
            'AITM_Instrument__c' => 'Instrument',
            'AITM_Credit_Rating__c' => 'Credit Rating Of Customer'
        };

        private Set<Id> recordsToSend;

        public TriggerAdapter() {
            recordsToSend = new Set<Id>();
        }

        public void bulkBefore(){}
        public void bulkAfter(){}
        public void beforeInsert(SObject so){}
        public void beforeUpdate(SObject oldSo, SObject so){}
        public void beforeDelete(SObject so){}

        /**
         * @description Tender Location line Item clone after insert
         * @param so
         * @return void
         */
        public void afterInsert(SObject so) {
            AITM_Tender_Location_Line_Item__c scopeLineItem = (AITM_Tender_Location_Line_Item__c) so; 
            if (!scopeLineItem.isClone()) {
                recordsToSend.add(scopeLineItem.Id);
            }
        }

        /**
         * @description Tender Location line Item Pricing Calculation after update
         * @param so
         * @param oldSo
         * @return void
         */
        public void afterUpdate(SObject oldSo, SObject so) {
            AITM_Tender_Location_Line_Item__c scopeLineItem = (AITM_Tender_Location_Line_Item__c) so; 
            AITM_Tender_Location_Line_Item__c scopeLineItemOld = (AITM_Tender_Location_Line_Item__c) oldSo; 
            if (scopeLineItem.AITM_Data_Pricing_Calculation_Provided__c) {
                if (!scopeLineItemOld.AITM_Data_Pricing_Calculation_Provided__c) {
                    recordsToSend.add(scopeLineItem.Id);
                }
            } 
        }

        public void afterDelete(SObject so){}

        /**
         * @description Tender Location Pricing service records to update
         * @param null
         * @return void
         */
        public void andFinally() {
            if (recordsToSend.size() > 0) {
                if (Trigger.isInsert && !System.isBatch()) {
                    this.sendRequest(recordsToSend, AITM_TenderLocationPricingService.TARGET_PRICE_REQUEST);
                } else if (Trigger.isUpdate) {
                    this.sendRequest(recordsToSend, AITM_TenderLocationPricingService.PRICING_INFORMATION_REQUEST);
                }
            }
        }

        /**
         * @description Tender Location Line Item Pricing System call for all required fields
         * @param scopeLineItemOld
         * @param scopeLineItem
         * @return Boolean true
         */
        private Boolean pricingSystemCallRequired(AITM_Tender_Location_Line_Item__c scopeLineItemOld, AITM_Tender_Location_Line_Item__c scopeLineItem) {
            Boolean allRequiredFieldsAvailable = true;

            for (String requiredField : this.REQUIRED_FIELDS_PROS_CALL.keySet()) {
                allRequiredFieldsAvailable = allRequiredFieldsAvailable && scopeLineItem.get(requiredField) != null;
                if (!allRequiredFieldsAvailable) {
                    break;
                }
            }

            return allRequiredFieldsAvailable;
        }

        /**
         * @description Tender Location Line Item get all required fields for error
         * @param scopeLineItem
         * @return String
         */
        private String getRequiredFieldsError(AITM_Tender_Location_Line_Item__c scopeLineItem) {
            String result = Label.AITM_PricingCallRequiredFieldsError;
            List<String> missingFields = new List<String>();
            for (String requiredField : this.REQUIRED_FIELDS_PROS_CALL.keySet()) {
                if (scopeLineItem.get(requiredField) == null) {
                    missingFields.add(this.REQUIRED_FIELDS_PROS_CALL.get(requiredField));
                }
            }
            result += String.join(missingFields, ', ');
            return result;
        }

        /**
         * @description Send recordIds request
         * @param recordIds
         * @param requestName
         * @return void
         */
        private void sendRequest(Set<Id> recordIds, String requestName) {
            if (recordIds.size() > 0 && !Test.isRunningTest()) {
                System.enqueueJob(new AITM_TenderLocationPricingService(recordIds, requestName));
            }
        }
    }
}