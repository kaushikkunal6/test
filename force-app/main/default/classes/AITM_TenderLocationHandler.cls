/*************************************************************************
 * @author         Vitali
 * @date           01/December/2017
 * @group          AirBP
 * @description    TenderLocation Handler class

 * history
 * 01/December/2017  Vitali     Created 
 * 16/March/2018     Anusha     AR-2728 Updated logic to get the previous round to new offer Table in before update method
 * 17/Aug/2018       Shweta     AR-3910 Added the logic to make the No revision flag as false in the next round in the method clone tenderlocation
 * 23/August/2018    Ravi       Modified - Added with sharing to the main class for sonarqube fixes
 * 27/November/2018  srnandan   Modified - changed to without sharing in order to update tender object for LABP LM/AirBP LM
 * 04/December/2018  srnandan   Modified - AR-4630 clearing tender result on change of round
 * 21/January/2019   srnandan   Modified - AR-4911 Added static constant ISADMIN to correct 101 query issue summary by country test class
 * 08/April/2020     Neeti      Modified - Fixed round 2 issue.
 * 30/June/2020      saravan    Modified - 366103  Made the changes to fix displaying the salesforce Id as Name in tenderlocation when the location added in further rounds
 ****************************************************************************/
public with sharing class AITM_TenderLocationHandler implements AITM_TriggerFactory.SObjectHandler {
    private AITM_TriggerFactory.HandlerRepository handlersStorage;
    public static Boolean createTenderlocation = true;
	public static Boolean createTenderlocationCheck = false;
    private static final Boolean ISADMIN = AITM_BaseUtils.checkRunningUserIsSystemAdministrator();

    /**
     * @description default constructor trigger handler class registering instance of classes
     */
      public AITM_TenderLocationHandler() {
        handlersStorage = new HandlerRepository();
        handlersStorage.register(new OldRoundsEditValidationAndNotificationAdapter());
        handlersStorage.register(new TenderLocationValidationHandleRepo());
       
        
    }
    
      /**
     * @description bulk before
     * @param null
     * @return null
     */
    public void bulkBefore() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkBefore();
        }
    }

    /**
     * @description bulk after
     * @param null
     * @return null
     */
    public void bulkAfter() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkAfter();
        }
    }

    public void beforeInsert(SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeInsert(so);
        }
    }

    public void beforeUpdate(SObject oldSo, SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeUpdate(oldSo, so);
        }
    }

    public void beforeDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeDelete(so);
        }
    }

    public void afterInsert(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterInsert(so);
        }
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterUpdate(oldSo, so);
        }
    }

    public void afterDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterDelete(so);
        }
    }

    /**
     * @description finally method
     * @param null
     * @return null
     */
    public void andFinally() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.andFinally();
        }
    }

    private with sharing class HandlerRepository implements AITM_TriggerFactory.HandlerRepository {
        private List<AITM_TriggerFactory.SObjectHandler> handlers;
        private TenderLocationOperationalUnit unit;

        public HandlerRepository() {
            handlers = new List<AITM_TriggerFactory.SObjectHandler>();
            unit = new TenderLocationOperationalUnit();
        }

        public void register(AITM_TriggerFactory.SObjectHandler handler) {
            handlers.add(handler);
            if (handler instanceOf HandlerRepositoryAccessible) {
                ( (HandlerRepositoryAccessible) handler).setHandlerRepository(this);
            }
        }
        
        public List<AITM_TriggerFactory.SObjectHandler> handlers() {
            return handlers;
        }

        public TenderLocationOperationalUnit getOperationalUnit() {
            return unit;
        }
    }

    public with sharing class TenderLocationOperationalUnit {
        public final Map<String, String> LOCATION_STATUSES = new Map<String, String> {
            'AWAITING_PRICE' => 'Awaiting price',
            'STATUS_PRICED' => 'Priced',
            'NOT_REPRESENTED' => 'Not Represented'
        };

        public final Map<String, Map<String, String>> VALIDATION_FIELDS = new Map<String, Map<String, String>> {
            'PRICED_TENDER_LOCATION_LINE_ITEM' => new Map<String, String> {        
                'AITM_Pricing_Basis__c' => 'pricing basis', 
                'AITM_Delivery_Point__c' => 'delivery point', 
                'AITM_Currency__c' => 'currency', 
                'AITM_Unit_Of_Measure__c' => 'unit of measure'
            },

            'FEEDBACK_FIELDS' => new Map<String, String> {
                'AITM_Comments__c' => null,
                'AITM_Number_Of_Bidders__c'  => null,
                'AITM_Position__c' => null,
                'AITM_Offered_Differential__c' => null,
                'AITM_Offered_Differential_Currency__c' => null,
                'AITM_Offered_Differential_UoM__c' => null,
                'AITM_Distance_From_Leading_Bid__c' => null,
                'AITM_Leading_Bid__c' => null,
                'AITM_Leading_Bid_Currency__c' => null,
                'AITM_Leading_Bid_UoM__c' => null,
                'AITM_Competitor_info__c' => null,
                'AITM_Competitor_Info_Other__c' => null
            },

            'TENDER_LOCATION_PRICED_STAGES' => new Map<String, String> {
                'Priced' => null,
                'Not Represented' => null
            }
        };

        public final Map<String, Id> TENDER_LOCATION_LINE_ITEM_RECORDTYPES = new Map<String, Id> {
            'Default' =>  Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId()
        };

        public final Map<String, String> CHATTER_NOTIFICATION_TYPES = new Map<String, String> {
            'NOTIFY_BY_COUNTRY_BASIS' => 'notifyByCountryBasis',
            'NOTIFY_STATUS_CHANGED' => 'notifyStatusChanged'
        };

       
        public TenderLocationOperationalUnit(){}
    
    }

    private interface HandlerRepositoryAccessible {
        void setHandlerRepository(HandlerRepository allHandlers);
    }
    
     private with sharing class OldRoundsEditValidationAndNotificationAdapter implements AITM_TriggerFactory.SObjectHandler {
        private final Boolean PERMISSION_TO_EDIT_OLD_ROUND_RECORDS;
        private final String EDIT_OLD_ROUND_ERROR = Label.AITM_EditOldRoundErrorMessage;
        private list<AITM_Tender_Location__c> tenderLocation;
        List<AITM_Tender__c> updateTenderList = new List<AITM_Tender__c>();
        private Set<Id> tenderLocationUpdateIdSet;
        
        private AITM_TenderLocNotificationHandler tenderLocationNotificationHandler;

        public OldRoundsEditValidationAndNotificationAdapter() {
            PERMISSION_TO_EDIT_OLD_ROUND_RECORDS = ISADMIN;
            tenderLocation = new list<AITM_Tender_Location__c>();
            
            tenderLocationNotificationHandler = new AITM_TenderLocNotificationHandler();
            }

        /**
         * @description bulk before
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk before
         * @param null
         * @return null
         */
        public void bulkAfter(){}
        public void beforeInsert(SObject so){
             AITM_Tender_Location__c item = (AITM_Tender_Location__c) so;
             if(item.AITM_Round__c == 1 || item.AITM_Created_Round__c == Null){
             tenderLocation.add(item);
             }
         
        }
        /**
         * @description gets Tender Location old records and new records
         * @param null   
         * @return void
         */

        public void beforeUpdate(SObject oldSo, SObject so) {}

        public void beforeDelete(SObject so){}

         public void afterInsert(SObject so) {
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) so;
            tenderLocationNotificationHandler.collect(tenderLocation);
        }
        public void afterUpdate(SObject oldSo, SObject so){
          AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) so;
          AITM_Tender_Location__c oldTenderLocation = (AITM_Tender_Location__c) oldSo;
                if(oldTenderLocation.AITM_Tender__r.AITM_Stage__c  == 'Offer Submitted' &&(oldTenderLocation.AITM_Comments__c != tenderLocation.AITM_Comments__c || oldTenderLocation.AITM_Leading_Bid__c != tenderLocation.AITM_Leading_Bid__c|| oldTenderLocation.AITM_Offered_Differential__c != tenderLocation.AITM_Offered_Differential__c|| oldTenderLocation.AITM_Position__c != tenderLocation.AITM_Position__c || oldTenderLocation.AITM_Distance_from_Leading_Bid1__c != tenderLocation.AITM_Distance_from_Leading_Bid1__c)){
                   updateTenderList.add(new AITM_Tender__c (ID = oldTenderLocation.AITM_Tender__c, AITM_Stage__c = 'Feedback and Negotiation'));
                }
                
                 if (this.notificationRequired(tenderLocation, oldTenderLocation)) {
                    tenderLocationNotificationHandler.collect(tenderLocation);
                }
        }

        public void afterDelete(SObject so){}

        /**
         * @description finally method
         * @param null
         * @return null
         */
        public void andFinally() {
            this.UpdateDefaultValues();
            if(updateTenderList.size()>0){
              update updateTenderList;
            }
            
             tenderLocationNotificationHandler.updateTendersToSendNotifications();
            
        }
    
    private Boolean notificationRequired(AITM_Tender_Location__c tenderLocation, AITM_Tender_Location__c oldTenderLocation) {
            return tenderLocation.AITM_Status__c != oldTenderLocation.AITM_Status__c;
       }
       
     private void UpdateDefaultValues() {
         if(tenderLocation.size()>0){
           // List<AITM_Tender_Location__c> tenderLocationItems = new AITM_LocationsDao().getTenderLocationById(tenderLocationIdSet);         
            for(AITM_Tender_Location__c item : tenderLocation){
              item.AITM_Classification__c = item.AITM_Location__r.AITM_Classification__c;
              item.AITM_Competition__c = item.AITM_Location__r.AITM_Competition__c;
              item.AITM_Last_Look_To_Incumbent__c = item.AITM_Tender__r.AITM_Last_Look_To_Incumbent__c;
              item.AITM_Leading_Bid_Currency__c = item.AITM_Location__r.AITM_Currency__c;
              item.AITM_Leading_Bid_UoM__c = item.AITM_Location__r.AITM_Unit_Of_Measure__c;
              item.AITM_Location_Size__c = (item.AITM_Location__r.AITM_Location_Size__c!=null)?item.AITM_Location__r.AITM_Location_Size__c:item.AITM_Location_Size__c;
              item.AITM_Measure__c = item.AITM_Location__r.AITM_Measure__c;
              item.AITM_Number_Of_Rounds__c = item.AITM_Tender__r.AITM_Number_Of_Rounds__c;
              item.AITM_Offered_Differential_Currency__c = item.AITM_Location__r.AITM_Currency__c;
              item.AITM_Offered_Differential_UoM__c = item.AITM_Location__r.AITM_Unit_Of_Measure__c;
              item.AITM_Primary_Supply__c = item.AITM_Location__r.AITM_Primary_Supply__c;
              item.AITM_Product__c = item.AITM_Location__r.AITM_Product__c;
              item.AITM_Quality_Of_Feedback__c = item.AITM_Tender__r.AITM_Quality_Of_Feedback__c;
              item.Name = ( item.AITM_IATA_ICAO__c != null)?item.AITM_IATA_ICAO__c:item.AITM_Location__r.Name;
              item.AITM_Created_Round__c = item.AITM_Round__c;
             }
           
      
           }
           
           
         }
    

        private Boolean oldRoundEdition(AITM_Tender_Location__c tenderLocation, AITM_Tender_Location__c oldTenderLocation) {
            return !PERMISSION_TO_EDIT_OLD_ROUND_RECORDS 
                && tenderLocation.AITM_Round__c != oldTenderLocation.AITM_Current_Round__c;
        }
    }
    
     private with sharing class TenderLocationValidationHandleRepo implements AITM_TriggerFactory.SObjectHandler, HandlerRepositoryAccessible {
        
        private TenderLocationOperationalUnit operationalUnit;
        //from : PricedStatusTenderLocationValidation
        private Map<Id, AITM_Tender_Location__c> tenderLocationsInScope;
        private Map<String, String> TENDER_LOCATION_LINE_ITEM_PRICED_VALIDATION_FIELDS;
        private final Set<String> FIELDS_TO_SELECT_FOR_PRICED_TENDER_LOCATION_LINE_ITEMS = new Set<String>{'AITM_Account__r.Name', 'AITM_Tender_Location__c', 'AITM_Offered_Differential__c', 'AITM_Pricing_Basis__r.AITM_Type__c', ' AITM_Current_Value__c'};
        //from : NonRepresentedTenderLocationFieldsFlush
        private List<AITM_Tender_Location__c> nonRepresentedLocations;
        //from:TenderLocationTotalVolumeToTheGroupRecalculationHandler
        private List<AITM_Tender_Location__c> tenderLocationsToRecalculateVolumes;
        private Set<Id> tenderLocationIdsToClearChildsVolume;
        //from:TenderLocationFeedbackAvailabilityChecker
        private Set<String> FEEDBACK_FIELDS;
        //from:TenderLocationOnPricedStatusUpdateTenderToPriced
        private Set<String> TENDER_LOCATION_STATUSES_TO_CHECK;
        private String PRICED_STAGE;
        private String AWAITING_PRICE_STAGE;
        private Set<Id> tenderIdsToCheckRelatedLocationStatuses;
        //from:TenderLocationCloneOnNewRoundCreation
        private List<AITM_Tender_Location__c> newRoundTenderLocations;
        //from:TenderLocationChatterNotificationsOnStatusChanges
        private List<AITM_Tender_Location__c> countryNotificationList;
        

        public TenderLocationValidationHandleRepo() {
            //from : PricedStatusTenderLocationValidation
            tenderLocationsInScope = new Map<Id, AITM_Tender_Location__c>();
            //from : NonRepresentedTenderLocationFieldsFlush
            nonRepresentedLocations = new List<AITM_Tender_Location__c>();
            //from:TenderLocationTotalVolumeToTheGroupRecalculationHandler
            tenderLocationsToRecalculateVolumes = new List<AITM_Tender_Location__c>();
            tenderLocationIdsToClearChildsVolume = new Set<Id>();
            //from:TenderLocationOnPricedStatusUpdateTenderToPriced
            tenderIdsToCheckRelatedLocationStatuses = new Set<Id>();
            //from:TenderLocationCloneOnNewRoundCreation
            newRoundTenderLocations = new List<AITM_Tender_Location__c>();
            //from:TenderLocationChatterNotificationsOnStatusChanges
            countryNotificationList = new List<AITM_Tender_Location__c>();
            
        }

        public void setHandlerRepository(HandlerRepository allHandlers) {
            operationalUnit = allHandlers.getOperationalUnit();
            
            //from : PricedStatusTenderLocationValidation
            TENDER_LOCATION_LINE_ITEM_PRICED_VALIDATION_FIELDS = operationalUnit.VALIDATION_FIELDS.get('PRICED_TENDER_LOCATION_LINE_ITEM');
            //from:TenderLocationFeedbackAvailabilityChecker
            FEEDBACK_FIELDS = allHandlers.getOperationalUnit().VALIDATION_FIELDS.get('FEEDBACK_FIELDS').keySet();
            //from:TenderLocationOnPricedStatusUpdateTenderToPriced
            TENDER_LOCATION_STATUSES_TO_CHECK = allHandlers.getOperationalUnit().VALIDATION_FIELDS.get('TENDER_LOCATION_PRICED_STAGES').keySet();
            PRICED_STAGE = allHandlers.getOperationalUnit().LOCATION_STATUSES.get('STATUS_PRICED');
            AWAITING_PRICE_STAGE = allHandlers.getOperationalUnit().LOCATION_STATUSES.get('AWAITING_PRICE');
        }

         /**
         * @description set operational unit
         * @param operationalUnit of type TenderLocationOperationalUnit
         * @return null
         */
        public void setOperationalUnit(TenderLocationOperationalUnit operationalUnit) {
            this.operationalUnit = operationalUnit;
        }

        /**
         * @description bulk before
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after
         * @param null
         * @return null
         */
        public void bulkAfter(){}
        public void beforeInsert(SObject so){}

        public void beforeUpdate(SObject oldSo, SObject so) {
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) so;
            AITM_Tender_Location__c oldTenderLocation = (AITM_Tender_Location__c) oldSo;
            
            If(!AITM_CheckRecursive.setOfIDsBeforeUpdate.contains(so.Id)){
            this.setLeadFieldsOnLocation(tenderLocation, oldTenderLocation); 
              
            //from : PricedStatusTenderLocationValidation
            if (this.pricedStageSet(tenderLocation, oldTenderLocation)) {
                tenderLocationsInScope.put(tenderLocation.Id, tenderLocation);
            }
            //from:TenderLocationTotalVolumeToTheGroupRecalculationHandler
            if (this.isNotRepresented(tenderLocation, oldTenderLocation)) {
                tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c = null;
            } else if (tenderLocation.AITM_Recalculate_Total_Volume__c == true) {
                tenderLocationsToRecalculateVolumes.add(tenderLocation);
            } else if (tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c != oldTenderLocation.AITM_Total_Volume_Offered_To_The_Group__c) {
                tenderLocationIdsToClearChildsVolume.add(tenderLocation.Id);
            }
            //from:TenderLocationFeedbackAvailabilityChecker
            if (tenderLocation.AITM_Has_Feedback__c == false && this.feedbackFieldsEdited(tenderLocation, oldTenderLocation)) {
                tenderLocation.AITM_Has_Feedback__c = true;
            }
            
            //from:TenderLocationCloneOnNewRoundCreation  
            if (tenderLocation.AITM_Current_Round__c != oldTenderLocation.AITM_Current_Round__c && createTenderlocation) {
                  newRoundTenderLocations.add(tenderLocation);
            }
             AITM_CheckRecursive.setOfIDsBeforeUpdate.add(so.Id);
           }
        }

        public void beforeDelete(SObject so){}

        public void afterInsert(SObject so) {}

         public void afterUpdate(SObject oldSo, SObject so){
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) so;
            AITM_Tender_Location__c oldTenderLocation = (AITM_Tender_Location__c) oldSo;
            
            If(!AITM_CheckRecursive.setOfIDsAfterUpdate.contains(so.Id)){
            //from : NonRepresentedTenderLocationFieldsFlush
            if (this.isNotRepresented(tenderLocation, oldTenderLocation)) {
                nonRepresentedLocations.add(tenderLocation);
            }     
            //from:TenderLocationOnPricedStatusUpdateTenderToPriced
            if (this.checkForPricedTenderRequired(tenderLocation, oldTenderLocation)) {
                tenderIdsToCheckRelatedLocationStatuses.add(tenderLocation.AITM_Tender__c);
            }   
            //from:TenderLocationChatterNotificationsOnStatusChanges
            if (this.countryNotificationRequired(tenderLocation, oldTenderLocation)) {
                countryNotificationList.add(tenderLocation);
            }
            
              AITM_CheckRecursive.setOfIDsAfterUpdate.add(so.Id);
           }
        }

        public void afterDelete(SObject so){}

        /**
         * @description finally method
         * @param null
         * @return null
         */
        public void andFinally() {
            //from : PricedStatusTenderLocationValidation
            this.validatePricedTenderLocations();
            //from : NonRepresentedTenderLocationFieldsFlush
            this.flushNonRepresentedTenderLocationFields();
            //from:TenderLocationTotalVolumeToTheGroupRecalculationHandler
            this.recalculateTotalVolume();
            this.clearLineItemsVolume();
            //from:TenderLocationOnPricedStatusUpdateTenderToPriced
            this.updateTenderToPriced();
            //from:TenderLocationCloneOnNewRoundCreation  
            this.createNewRoundTenderLocations();
            //from:TenderLocationChatterNotificationsOnStatusChanges
            sendCountryNotificationList();
        }
         private void setLeadFieldsOnLocation(AITM_Tender_Location__c tenderLocation, AITM_Tender_Location__c oldTenderLocation){
             Double newfinalOutput = tenderLocation.AITM_Distance_From_Leading_Bid2__c != null ? tenderLocation.AITM_Distance_From_Leading_Bid2__c : 0;
             Double newofferedDiff = tenderLocation.AITM_Offered_Differential__c != null ? tenderLocation.AITM_Offered_Differential__c : 0;
             Double newleadingBid = tenderLocation.AITM_Leading_Bid__c != null ? tenderLocation.AITM_Leading_Bid__c : 0;
             Double oldfinalOutput = oldTenderLocation.AITM_Distance_From_Leading_Bid2__c != null ? oldTenderLocation.AITM_Distance_From_Leading_Bid2__c : 0;
             Double oldofferedDiff = oldTenderLocation.AITM_Offered_Differential__c != null ? oldTenderLocation.AITM_Offered_Differential__c : 0;
             Double oldleadingBid = oldTenderLocation.AITM_Leading_Bid__c != null ? oldTenderLocation.AITM_Leading_Bid__c : 0;
             
             if(oldfinalOutput != newfinalOutput){
                 newleadingBid = newofferedDiff - newfinalOutput;
                 tenderLocation.AITM_Leading_Bid__c = newleadingBid;
             } else if((oldofferedDiff != newofferedDiff) || (oldleadingBid != newleadingBid)){
                 tenderLocation.AITM_Distance_From_Leading_Bid2__c = newofferedDiff - newleadingBid;
             }
         }


        //from : PricedStatusTenderLocationValidation
        private Boolean pricedStageSet(AITM_Tender_Location__c tenderLocation, AITM_Tender_Location__c oldTenderLocation) {
            return tenderLocation.AITM_Status__c != oldTenderLocation.AITM_Status__c 
                && tenderLocation.AITM_Status__c == operationalUnit.LOCATION_STATUSES.get('STATUS_PRICED');
        }

        private void validatePricedTenderLocations() {
            if (tenderLocationsInScope.size() > 0) {
                Map<Id, List<AITM_Tender_Location_Line_Item__c>> tenderLineItemsByTenderLocationId = this.getTenderLocationLineItemsMappedByTenderLocationId();

                for (AITM_Tender_Location__c tenderLocation : tenderLocationsInScope.values()) {
                    this.checkValidationForPricingTenderLocation(tenderLocation, tenderLineItemsByTenderLocationId.get(tenderLocation.Id));
                }
            }
        }

        private Map<Id, List<AITM_Tender_Location_Line_Item__c>> getTenderLocationLineItemsMappedByTenderLocationId() {
            Map<Id, List<AITM_Tender_Location_Line_Item__c>> tenderLineItemsByTenderLocationId = new Map<Id, List<AITM_Tender_Location_Line_Item__c>>();
                Set<String> fieldsToSelect = new Set<String>(TENDER_LOCATION_LINE_ITEM_PRICED_VALIDATION_FIELDS.keySet());
                fieldsToSelect.addAll(FIELDS_TO_SELECT_FOR_PRICED_TENDER_LOCATION_LINE_ITEMS);
                for (AITM_Tender_Location_Line_Item__c tenderLocationLineItem : new AITM_LocationsDao().getTenderLocationsLineItems(tenderLocationsInScope.values(), fieldsToSelect)) {
                    if (!tenderLineItemsByTenderLocationId.containsKey(tenderLocationLineItem.AITM_Tender_Location__c)) {
                        tenderLineItemsByTenderLocationId.put(tenderLocationLineItem.AITM_Tender_Location__c, new List<AITM_Tender_Location_Line_Item__c>());
                    }
                    tenderLineItemsByTenderLocationId.get(tenderLocationLineItem.AITM_Tender_Location__c).add(tenderLocationLineItem);
                }
            return tenderLineItemsByTenderLocationId;
        }

        private void checkValidationForPricingTenderLocation(AITM_Tender_Location__c tenderLocation, List<AITM_Tender_Location_Line_Item__c> relatedItems) {
            List<String> allErrorMessages = new List<String>();
            /*if (tenderLocation.AITM_Taxes_Fees__c == null){
                allErrorMessages.add('taxes & fees');
            }*/

            if (relatedItems != null && relatedItems.size() > 0) {
                for (AITM_Tender_Location_Line_Item__c lineItem : relatedItems) {
                    String lineItemErrorMessage = this.getErrorMessageForLineItem(lineItem);
                    if (String.isNotBlank(lineItemErrorMessage)) {
                        allErrorMessages.add(lineItemErrorMessage);
                    }
                }
            }

            if (allErrorMessages.size() > 0) {
                tenderLocation.addError(String.join(allErrorMessages, ';<br/>'), false);
            }
        }

        private String getErrorMessageForLineItem(AITM_Tender_Location_Line_Item__c lineItem) {
            List<String> lineItemErrors = new List<String>();
            for (String requiredFieldName : TENDER_LOCATION_LINE_ITEM_PRICED_VALIDATION_FIELDS.keySet()) {
                if (lineItem.get(requiredFieldName) == null) {
                    lineItemErrors.add(TENDER_LOCATION_LINE_ITEM_PRICED_VALIDATION_FIELDS.get(requiredFieldName));
                }
            }

            this.validatePricingBasisType(lineItem, lineItemErrors);

            String result = '';
            if (lineItemErrors.size() > 0) {
                result = 'Please fill in fields: ';
                result += String.join(lineItemErrors, ', ');
                result += ' for line item ' + lineItem.AITM_Account__r.Name;               
            }
            return result;
        }

        private void validatePricingBasisType(AITM_Tender_Location_Line_Item__c lineItem, List<String> lineItemErrors) {
            if(lineItem.AITM_Pricing_Basis__c != null) {
                if(lineItem.AITM_Pricing_Basis__r.AITM_Type__c == 'c' && lineItem.AITM_Current_Value__c == null) {
                    lineItemErrors.add('current value');
                }else if(lineItem.AITM_Pricing_Basis__r.AITM_Type__c == 'd' && lineItem.AITM_Offered_Differential__c == null){
                    lineItemErrors.add('differential');
                }
            }
        }
     
        //from : NonRepresentedTenderLocationFieldsFlush
        private Boolean isNotRepresented(AITM_Tender_Location__c tenderLocation, AITM_Tender_Location__c oldTenderLocation) {
            return tenderLocation.AITM_Status__c != oldTenderLocation.AITM_Status__c 
                && tenderLocation.AITM_Status__c == operationalUnit.LOCATION_STATUSES.get('NOT_REPRESENTED');
        }

        private void flushNonRepresentedTenderLocationFields() {
            if (nonRepresentedLocations.size() > 0) {
                List<AITM_Tender_Location_Line_Item__c> representedLineItems = new AITM_LocationsDao().getRepresentedLocationLineItems(nonRepresentedLocations);
                for (AITM_Tender_Location_Line_Item__c lineItem : representedLineItems) {
                    lineItem.AITM_Offered_Volume__c = null;
                    lineItem.AITM_Percentage_Volume_Offered__c = null;
                    lineItem.AITM_Currency__c = null;
                    lineItem.AITM_Unit_Of_Measure__c = null;
                    lineItem.AITM_Start_Date__c = null;
                    lineItem.AITM_End_Date__c = null;
                }

                Database.update(representedLineItems, false);
            }
        }
     
        //from:TenderLocationTotalVolumeToTheGroupRecalculationHandler     

        /**
         * @description recalculate total volume
         * @param null
         * @return null
         */
        private void recalculateTotalVolume() {
            if (tenderLocationsToRecalculateVolumes.size() > 0) {
                Map<Id, Decimal> totalVolumesByTenderLocationId = getTotalVolumeByTenderLocationIdMap();
                for (AITM_Tender_Location__c tenderLocation : tenderLocationsToRecalculateVolumes) {
                    tenderLocation.AITM_Recalculate_Total_Volume__c = false;
                    tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c = totalVolumesByTenderLocationId.get(tenderLocation.Id);
                }
            }
        }

        /**
         * @description clear line items volume
         * @param null
         * @return null
         */
        private void clearLineItemsVolume() {
            if (!tenderLocationIdsToClearChildsVolume.isEmpty() && !AITM_TenderLocationMappingHandler.getClearDisabled()) {
                List<AITM_Tender_Location_Line_Item__c> lineItemsWithNonBlankVolume = new AITM_LocationsDao().getTenderLocationLineItemsWithNonBlankOfferedVolumeByTenderLocationIds(tenderLocationIdsToClearChildsVolume);
                for (AITM_Tender_Location_Line_Item__c lineItemToClearVolume : lineItemsWithNonBlankVolume) {
                    lineItemToClearVolume.AITM_Offered_Volume__c = null;
                    lineItemToClearVolume.AITM_Percentage_Volume_Offered__c = null;
                }

                Database.update(lineItemsWithNonBlankVolume, false);
            }
        }

        /**
         * @description gets TotalVolumeByTenderLocationIdMap
         * @param null
         * @return Map<Id, Decimal>
         */
        private Map<Id, Decimal> getTotalVolumeByTenderLocationIdMap() {
            Map<Id, Decimal> totalVolumesByTenderLocationId = new Map<Id, Decimal>();

            for (AITM_Tender_Location_Line_Item__c lineItemToCount : new AITM_LocationsDao().getTenderLocationLineItems(
                                                                     new List<Id>(
                                                                     new Map<Id, AITM_Tender_Location__c>(tenderLocationsToRecalculateVolumes).keySet()))) {
                if (!totalVolumesByTenderLocationId.containsKey(lineItemToCount.AITM_Tender_Location__c)) {
                    totalVolumesByTenderLocationId.put(lineItemToCount.AITM_Tender_Location__c, 0);
                }

                Decimal totalVolumeBefore = totalVolumesByTenderLocationId.get(lineItemToCount.AITM_Tender_Location__c) == null ? 0 : totalVolumesByTenderLocationId.get(lineItemToCount.AITM_Tender_Location__c);
                Decimal offeredVolumeToAdd = lineItemToCount.AITM_Offered_Volume__c != null ? lineItemToCount.AITM_Offered_Volume__c : 0;

                totalVolumesByTenderLocationId.put(lineItemToCount.AITM_Tender_Location__c, totalVolumeBefore+offeredVolumeToAdd);
            }

            return totalVolumesByTenderLocationId;
        }

        //from:TenderLocationFeedbackAvailabilityChecker
        private Boolean feedbackFieldsEdited(AITM_Tender_Location__c tenderLocation, AITM_Tender_Location__c oldTenderLocation) {
            Boolean feedbackFieldsEdited = false;
            for (String feedbackField : FEEDBACK_FIELDS) {
                feedbackFieldsEdited = feedbackFieldsEdited || tenderLocation.get(feedbackField) != oldTenderLocation.get(feedbackField);
                if (feedbackFieldsEdited) {
                    break;
                }
            }
            return feedbackFieldsEdited;
        }
   
        //from:TenderLocationOnPricedStatusUpdateTenderToPriced
        
        private Boolean checkForPricedTenderRequired(AITM_Tender_Location__c tenderLocation, AITM_Tender_Location__c oldTenderLocation) {
            return tenderLocation.AITM_Status__c != oldTenderLocation.AITM_Status__c
                && TENDER_LOCATION_STATUSES_TO_CHECK.contains(tenderLocation.AITM_Status__c);
        }

        private void updateTenderToPriced() {
            if (tenderIdsToCheckRelatedLocationStatuses.size() > 0) {
                List<AITM_Tender__c> tendersToUpdateStage = new List<AITM_Tender__c>();
                for (AITM_Tender__c tender : new AITM_TenderDao().getTenderWithCurrentRoundTenderLocations(tenderIdsToCheckRelatedLocationStatuses)) {
                    if (tender.AITM_Stage__c == AWAITING_PRICE_STAGE && this.isAllTenderLocationsHaveStatus(tender.AITM_Tender_Locations__r)) {
                        tender.AITM_Stage__c = PRICED_STAGE;
                        tendersToUpdateStage.add(tender);
                    }
                }
                
                Database.update(tendersToUpdateStage, false);    
            }
        }

        private Boolean isAllTenderLocationsHaveStatus(List<AITM_Tender_Location__c> tenderLocationsToCheck) {
            Boolean result = true;
            for (AITM_Tender_Location__c tenderLocationToCheck : tenderLocationsToCheck) {
                if (!TENDER_LOCATION_STATUSES_TO_CHECK.contains(tenderLocationToCheck.AITM_Status__c)) {
                    result = false;
                    break;
                }
            }

            return result;
        }
    
        //from:TenderLocationCloneOnNewRoundCreation 
         
        private void createNewRoundTenderLocations() {
            if (newRoundTenderLocations.size() > 0) {
                Map<Id, AITM_Tender_Location__c> newTenderLocationsByOldIds = new Map<Id, AITM_Tender_Location__c>();
                for (AITM_Tender_Location__c tenderLocation : newRoundTenderLocations) {
                    AITM_Tender_Location__c tenderLocationClone = this.cloneTenderLocation(tenderLocation);
                    newTenderLocationsByOldIds.put(tenderLocation.Id, tenderLocationClone);
                }

                Database.insert(newTenderLocationsByOldIds.values(), false);
                if(createTenderlocationCheck  == false){
                    this.sendAwaitingPriceNotifications(newTenderLocationsByOldIds.values());
				}
                this.createTenderLocationLineItemClone(newTenderLocationsByOldIds);
            }
        }

         private void sendAwaitingPriceNotifications(List<AITM_Tender_Location__c> clonedTenderLocation) {
            List<AITM_Tender_Location__c> tenderLocationsAwaitingPriceToBeNotified = new List<AITM_Tender_Location__c>();
            for (AITM_Tender_Location__c tenderLocationClone : clonedTenderLocation) {
                if (tenderLocationClone.AITM_Status__c == operationalUnit.LOCATION_STATUSES.get('AWAITING_PRICE')) {
                    tenderLocationsAwaitingPriceToBeNotified.add(tenderLocationClone);
                }
            }

            setOperationalUnit(operationalUnit);
            sendChatterNotification(tenderLocationsAwaitingPriceToBeNotified, operationalUnit.CHATTER_NOTIFICATION_TYPES.get('NOTIFY_STATUS_CHANGED'));
        }

        private void createTenderLocationLineItemClone(Map<Id, AITM_Tender_Location__c> newTenderLocationsByOldIds) {
		    createTenderlocationCheck = true;
            AITM_CloneTLLIBatch batch = new AITM_CloneTLLIBatch(newTenderLocationsByOldIds,newRoundTenderLocations);
            database.executeBatch(batch,50);         
        } 

        private AITM_Tender_Location__c cloneTenderLocation(AITM_Tender_Location__c tenderLocation) {
            Decimal round = tenderLocation.AITM_Current_Round__c; 
            AITM_Tender_Location__c tenderLocationClone = tenderLocation.clone(false, true, false, true);
            tenderLocationClone.AITM_Round__c = round;
            tenderLocationClone.AITM_Current_Round__c = round;
            tenderLocationClone.AITM_Created_Round__c = round;
			
			if(round == 1){
                for (String feedbackField : operationalUnit.VALIDATION_FIELDS.get('FEEDBACK_FIELDS').keySet()) {
                    tenderLocationClone.put(feedbackField, null);
                }
            }

            if (tenderLocationClone.AITM_Has_Feedback__c == true) {
                tenderLocationClone.AITM_Has_Feedback__c = false;
                tenderLocationClone.AITM_Status__c = (tenderLocationClone.AITM_Status__c != operationalUnit.LOCATION_STATUSES.get('NOT_REPRESENTED')) 
                                                    ? operationalUnit.LOCATION_STATUSES.get('AWAITING_PRICE') 
                                                    : operationalUnit.LOCATION_STATUSES.get('NOT_REPRESENTED');
                tenderLocationClone.AITM_Include_In_Revised_Offer__c = true;
                tenderLocationClone.AITM_No_Revision__c = false;
            } else {
                tenderLocationClone.AITM_Status__c = (tenderLocationClone.AITM_Status__c != operationalUnit.LOCATION_STATUSES.get('NOT_REPRESENTED')) 
                                                    ? operationalUnit.LOCATION_STATUSES.get('STATUS_PRICED') 
                                                    : operationalUnit.LOCATION_STATUSES.get('NOT_REPRESENTED');
                tenderLocationClone.AITM_Include_In_Revised_Offer__c = false;
            }
            return tenderLocationClone;           
       }

       private AITM_Tender_Location_Line_Item__c cloneTenderLocationLineItem(AITM_Tender_Location_Line_Item__c lineItem, Id tenderLocationId){
            AITM_Tender_Location_Line_Item__c lineItemClone = lineItem.clone(false, true, false, true);
            lineItemClone.AITM_Last_Tender_Result__c = lineItem.AITM_Tender_Result__c;
            lineItemClone.AITM_Tender_Location__c = tenderLocationId;
            lineItemClone.RecordTypeId = operationalUnit.TENDER_LOCATION_LINE_ITEM_RECORDTYPES.get('Default');
            return lineItemClone;
        }
        
       //from:TenderLocationChatterNotificationsOnStatusChanges
        
        /**
         * @description send chatter notification 
         * @param tenderLocationsToNotify of type List<AITM_Tender_Location__c>
         * @param notificationName of type string
         * @return null
         */
        public void sendChatterNotification(List<AITM_Tender_Location__c> tenderLocationsToNotify, String notificationName) {
            if (tenderLocationsToNotify.size() > 0) {
                List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            
                for (AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getTenderLocationsByIds(new List<Id>(new Map<Id, AITM_Tender_Location__c>(tenderLocationsToNotify).keySet()))) {
                    String chatterText = getNotificationMessage(tenderLocation, notificationName);
                    Id mentionObjectId = getChatterMessageReceiver(tenderLocation, notificationName);
                    ConnectApi.BatchInput message = AITM_BaseUtils.createChatterMessageWithMention(tenderLocation.AITM_Tender__c, mentionObjectId, chatterText);
                    batchInputs.add(message);
                }

                AITM_BaseUtils.postToChatter(batchInputs);
            }
        }

        /**
         * @description send country notification list
         * @param null
         * @return null
         */
        private void sendCountryNotificationList() {
            if (countryNotificationList.size() > 0) {
                List<AITM_Tender_Location__c> tenderLocationsToNotify = new List<AITM_Tender_Location__c>();
                Set<Id> tenderIds = getCountryTenderList();
                Map<String, Map<Id, List<AITM_Tender_Location__c>>> countryToTenderLocationsPriced = getSortedByCountryPricedTenderLocations(tenderIds);

                for (AITM_Tender_Location__c tenderLocation : countryNotificationList) {
                    if (countryToTenderLocationsPriced.get(tenderLocation.AITM_Country__c) != null && 
                        countryToTenderLocationsPriced.get(tenderLocation.AITM_Country__c).size() > 0 ) {
                        tenderLocationsToNotify.add(tenderLocation);
                    }
                }

                this.sendChatterNotification(tenderLocationsToNotify, operationalUnit.CHATTER_NOTIFICATION_TYPES.get('NOTIFY_BY_COUNTRY_BASIS'));
            }
        }

        /**
         * @description gets country tender list
         * @param null
         * @return Set<Id>
         */
        private Set<Id> getCountryTenderList() {
            Set<Id> result = new Set<Id>();
            for (AITM_Tender_Location__c tenderLocation : countryNotificationList) {
                result.add(tenderLocation.AITM_Tender__c);
            }

            return result;
        }

        /**
         * @description gets sorted by country priced tender locations
         * @param tenderIds of type Set collection
         * @return Map<String, Map<Id, List<AITM_Tender_Location__c>>>
         */
        public Map<String, Map<Id, List<AITM_Tender_Location__c>>> getSortedByCountryPricedTenderLocations(Set<Id> tenderIds){
            Map<String, Map<Id, List<AITM_Tender_Location__c>>>  countryToTenderLocations = new  Map<String, Map<Id, List<AITM_Tender_Location__c>>>();

            for (AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIds)) {  
                if (tenderLocation.AITM_Status__c == operationalUnit.LOCATION_STATUSES.get('STATUS_PRICED')) {
                    if (!countryToTenderLocations.containsKey(tenderLocation.AITM_Country__c)) {
                        countryToTenderLocations.put(tenderLocation.AITM_Country__c, new Map<Id, List<AITM_Tender_Location__c>>());
                    }
                    if (!countryToTenderLocations.get(tenderLocation.AITM_Country__c).containsKey(tenderLocation.AITM_Tender__c)) {
                        countryToTenderLocations.get(tenderLocation.AITM_Country__c).put(tenderLocation.AITM_Tender__c, new List<AITM_Tender_Location__c>());
                    }
                    countryToTenderLocations.get(tenderLocation.AITM_Country__c).get(tenderLocation.AITM_Tender__c).add(tenderLocation);
                }
            }

            return countryToTenderLocations;
        }
        
        /**
         * @description gets chatter message receiver
         * @param tenderLocation of type AITM_Tender_Location__c
         * @param chatterTextTemplate of type String
         * @return string
         */
        private String getNotificationMessage(AITM_Tender_Location__c tenderLocation, String chatterTextTemplate){
            String text = '';
            if (chatterTextTemplate == operationalUnit.CHATTER_NOTIFICATION_TYPES.get('NOTIFY_BY_COUNTRY_BASIS')) {
                text = 'Locations in ' + tenderLocation.AITM_Country__c + ' on tender ';
                text += '\'' + tenderLocation.AITM_Tender__r.Name + '\' have been changed to \'' + tenderLocation.AITM_Status__c + '\'. \n';
                text += 'For more details go here: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + tenderLocation.AITM_Tender__c;
            } else if (chatterTextTemplate == operationalUnit.CHATTER_NOTIFICATION_TYPES.get('NOTIFY_STATUS_CHANGED')){
                text = 'The tender location \'' + getTenderLocationName(tenderLocation) + '\' is now in ' + tenderLocation.AITM_Status__c + ' stage. \n';
                text += 'For more details go here: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + tenderLocation.Id;
            }
            return text;
        }

        /**
         * @description gets chatter message receiver
         * @param tenderLocation of type AITM_Tender_Location__c
         * @param chatterTextTemplate of type String
         * @return Id
         */
        private Id getChatterMessageReceiver(AITM_Tender_Location__c tenderLocation, String chatterTextTemplate){
            Id receiverId;
            if (chatterTextTemplate == operationalUnit.CHATTER_NOTIFICATION_TYPES.get('NOTIFY_BY_COUNTRY_BASIS')) {
                receiverId = tenderLocation.AITM_Tender__r.OwnerId;
            } else if (chatterTextTemplate == operationalUnit.CHATTER_NOTIFICATION_TYPES.get('NOTIFY_STATUS_CHANGED')) {
                receiverId = tenderLocation.AITM_Location_Manager__c;
            }
            return receiverId;
        }

        /**
         * @description gets tender location name
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return String
         */
        private String getTenderLocationName(AITM_Tender_Location__c tenderLocation) {
            String result = '';
            result = (tenderLocation.AITM_Location__r.AITM_IATA__c != null)? tenderLocation.AITM_Location__r.AITM_IATA__c + ' - ' : tenderLocation.AITM_Location__r.AITM_ICAO__c;
            result += tenderLocation.AITM_Location__r.Name;
            result += ' - Round '+ tenderLocation.AITM_Round__c;
            return result;
        }

        private Boolean countryNotificationRequired(AITM_Tender_Location__c tenderLocation, AITM_Tender_Location__c oldTenderLocation) {
            return tenderLocation.AITM_Status__c != oldTenderLocation.AITM_Status__c 
                && tenderLocation.AITM_Status__c == operationalUnit.LOCATION_STATUSES.get('STATUS_PRICED');
        }
    
    
     }
    }