/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Trigger handler for Tender

 * history
 * 01/December/2017  George          Created
 * 21/March/2018     srnandan        Modified - AR- 2729 - modified method "notifyRelatedTenderLocations"
 *                                   by adding boolean flag - "isMessageSent" to control chatter notifications per tender.
 *                                   Also added comments at method and class level as per coding standards
 * 22/March/2018     srnandan        Modified - AR - 2773 - modified methods "updateRelatedTenderLocationFeedback","afterUpdate"
 *                                   added new method "updateRelatedTenderLocationOfferedDiffFeedback" and variable "tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback"
 *                                   for the functionality to assign value of minimum offered differential tenderlineitems each location
 * 17/Aug/2018       Shweta          Modified for sonar qube fixes (Added with sharing )
 * 11/December/2018  srnandan        Modified - AR-4624 debrief clone records logic moved to trigger from flow
 * 23/January/2019   srnandan        Modified - AR-4913 to include taxes and fees related fields for debrief record 
 * 12/March/2019     Shweta          Modified - AR-5078 - Deleting a Tender not deleting the Tender Location Line Item
 * 02/April/2019     Ravi            Modified - AR-5028 - Populating Product and Product Specification from TLLI to Debrief record type in method cloneDebriefRecords
 * 22/May/2019       srnandan        Modified to check dmlrows limit and calling batch class for insertion
 * 27/May/2019       srnandan        Modfied - AR-5029 Product density values copying to debrief stage
 * 30/July/2019      srnandan        Modified - to handle debrief insert batch items 
 *************************************************************************************/
public with sharing class AITM_TenderHandler implements AITM_TriggerFactory.SObjectHandler {
    private AITM_TriggerFactory.HandlerRepository handlersStorage;
      public static Boolean check = false;
      public static Boolean feedbackCheck = true;

    /**
     * @description constructor to initialize and register handlerrepository
     */
    public AITM_TenderHandler() {
        handlersStorage = new HandlerRepository();
        handlersStorage.register(new TenderInvitationalEmailInvoker());
        handlersStorage.register(new TenderNewRoundStarter());
        handlersStorage.register(new TenderDeleteRelatedLineItems());
        handlersStorage.register(new TenderLocationChatterNotificationHandler());
        handlersStorage.register(new TenderLocationUpdateFeedbackInformation());
        handlersStorage.register(new TenderLocationUpdateNewRoundWhenTenderIsProceedingToNewRound());
        handlersStorage.register(new TenderLocationLineItemDebriefClone());
        handlersStorage.register(new CheckTenderOldOrNew());
    }

    /**
     * @description bulk before factory method operation SObject handler
     * @param null
     * @return null
     */
    public void bulkBefore() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkBefore();
        }
    }

    /**
     * @description bulk after factory method operation SObject handler
     * @param null
     * @return null
     */
    public void bulkAfter() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkAfter();
        }
    }

    /**
     * @description before insert operation of trigger event
     * @param so of type SObject
     * @return null
     */
    public void beforeInsert(SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
		        concreteHandler.beforeInsert(so);
        }
    }

    /**
     * @description before update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return null
     */
    public void beforeUpdate(SObject oldSo, SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
		   concreteHandler.beforeUpdate(oldSo, so);
			
        }
    }

    /**
     * @description before delete operation of trigger event
     * @param so of type SObject to hold new values
     * @return null
     */
    public void beforeDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeDelete(so);
        }
    }

    /**
     * @description after insert operation of trigger event
     * @param so of type SObject to hold new values
     * @return null
     */
    public void afterInsert(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
		 concreteHandler.afterInsert(so);
			
        }
    }

    /**
     * @description after update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return null
     */
    public void afterUpdate(SObject oldSo, SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
			concreteHandler.afterUpdate(oldSo, so);
			
        }
    }

    /**
     * @description after delete operation of trigger event
     * @param so of type SObject to hold new values
     * @return null
     */
    public void afterDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterDelete(so);
        }
    }

    /**
     * @description finally block method called for trigger event
     * @param null
     * @return null
     */
    public void andFinally() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.andFinally();
        }
    }

    /**
     * @description class implementing HandlerRepository interface
     */
    private class HandlerRepository implements AITM_TriggerFactory.HandlerRepository {
        private List<AITM_TriggerFactory.SObjectHandler> handlers;

        /**
         * @description default constructor of handlerrepository class
         */
        public HandlerRepository() {
            handlers = new List<AITM_TriggerFactory.SObjectHandler>();
        }

        /**
         * @description registers/adds SObject handler to collection
         * @param handler of type AITM_TriggerFactory.SObjectHandler
         * @return null
         */
        public void register(AITM_TriggerFactory.SObjectHandler handler) {
            handlers.add(handler);
        }
        
        /**
         * @description returns list collection of SObjectHandler
         * @param null
         * @return List collection of type AITM_TriggerFactory.SObjectHandler
         */
        public List<AITM_TriggerFactory.SObjectHandler> handlers() {
            return handlers;
        }
    }

    /**
     * @description class which invokes chatter InvitationEmail
     */
    private class TenderInvitationalEmailInvoker implements AITM_TriggerFactory.SObjectHandler {
        private final String STAGE_AWAITING_PRICE = 'Awaiting Price';
        private Set<Id> tenderIdsRequiredToBeNotified;
        private final String STAGE_CLOSED = 'Closed';
        private final String STAGE_DEBRIEF = 'Debrief';

        /**
         * @description constructor to initialize set collection tenderIdsRequiredToBeNotified
         */
        public TenderInvitationalEmailInvoker() {
            tenderIdsRequiredToBeNotified = new Set<Id>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;
            this.tenderHasLostBusiness(tender, oldTender);
            if (this.notificationRequired(tender, oldTender)) {
                this.addToNotificationList(tender);
            }
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block called for trigger handler 
         * @param null
         * @return null
         */
        public void andFinally() {
            this.sendNotificationEmails();
        }

        /**
         * @description returns true when sendinvitationnotification value changed to true 
         * and stage is awaitingprice
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return boolean
         */
        private Boolean notificationRequired(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            return !oldTender.AITM_Send_Invitation_Notification__c 
                && tender.AITM_Send_Invitation_Notification__c
                && tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
        }
		
        /**
         * @description check tender has complete lost business
         * and stage is Closed
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return void
         */
        public void tenderHasLostBusiness(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            if(!oldTender.AITM_Contract_Is_Sent_To_A_Customer__c && oldTender.AITM_Stage__c == STAGE_DEBRIEF && tender.AITM_Stage__c == STAGE_CLOSED){
                Integer listOfBGBRLineItems = [Select Count() FROM AITM_Tender_Location_Line_Item__c 
                                               WHERE AITM_Tender__c = :tender.Id AND AITM_Is_Current_Round__c = true 
                                               AND AITM_Record_Type_Name__c = 'De-brief' AND AITM_Tender_Result__c IN ('BG', 'BR')]; 
                if(listOfBGBRLineItems == 0){
                    tender.AITM_Contract_Is_Sent_To_A_Customer__c = true;
                }
            }
        }

        /**
         * @description adds notification to list collection
         * and stage is awaitingprice
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void addToNotificationList(AITM_Tender__c tender) {
            tender.AITM_Send_Invitation_Notification__c = false;
            tenderIdsRequiredToBeNotified.add(tender.Id);            
        }

        /**
         * @description sends notification emails
         * @param null
         * @return null
         */
        private void sendNotificationEmails() {
            if (tenderIdsRequiredToBeNotified.size() > 0) {
                List<Id> notificationTenderIdAsList = new List<Id>(tenderIdsRequiredToBeNotified);
                AITM_InvitationEmailGenerator.Generator emailCreator = new AITM_InvitationEmailGenerator.Generator(notificationTenderIdAsList[0]);
                AITM_BaseUtils.sendEmails(emailCreator.generateTenderInvitationEmailsBulk(notificationTenderIdAsList));                
            }
        }        
    }

    /**
     * @description class holds tender rounds
     */
    private class TenderNewRoundStarter implements AITM_TriggerFactory.SObjectHandler {
        private final String STAGE_AWAITING_PRICE = 'Awaiting Price';
        private final String STAGE_FEEDBACK = 'Feedback and Negotiation';

        /**
         * @description default constructor
         */
        public TenderNewRoundStarter() {}

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;

            if (this.newRoundRequiredToBeStarted(tender, oldTender)) {
                this.startNewRound(tender);
            }
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block method called for trigger event
         * @param null
         * @return null
         */
        public void andFinally() {}

        /**
         * @description checks round required to be started
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return boolean
         */
       private Boolean newRoundRequiredToBeStarted(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            //TO DO Need to check multiple locations           
            AITM_TenderDao tenderInstance = new AITM_TenderDao();
            Map<String,Boolean> mapMultipleLocations = tenderInstance.multipleLocations(tender.Id);
            Set<String> TENDER_STAGE = new Set<String>{'Priced','Awaiting Price','Offer Submitted'};
            if(mapMultipleLocations.size() > 1) {
                 check = oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && tender.AITM_Send_Feedback_Notification__c
                  && tender.AITM_Send_LABP_Feedback_Notification__c
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
                                  
                if(check == false && oldTender.AITM_Stage__c == STAGE_FEEDBACK && !TENDER_STAGE.contains(tender.AITM_Stage__c)){
                   tender.AITM_Stage__c = STAGE_FEEDBACK ;             
                }
                if(tender.AITM_No_Feedback_Progress_To_De_Brief__c && oldTender.AITM_Stage__c == STAGE_FEEDBACK){
                    tender.AITM_Stage__c = 'Debrief';   
                }
              return check;
            } else {           
                  check = tender.AITM_Stage__c != oldTender.AITM_Stage__c 
                  && oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && (mapMultipleLocations.containsKey('NonPolish') ? tender.AITM_Send_Feedback_Notification__c : tender.AITM_Send_LABP_Feedback_Notification__c)
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
                return check;
                  
            }
        }


        /**
         * @description starts new round for tender
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void startNewRound(AITM_Tender__c tender) {
            //reset flags both feedback and feedbackpolish
            tender.AITM_Stage__c = STAGE_AWAITING_PRICE;
            tender.AITM_Offer_Sent_To_A_Customer__c = false;           
            tender.AITM_Send_Feedback_Notification__c = false;
            tender.AITM_Send_LABP_Feedback_Notification__c = false;
        }
    }

    /**
     * @description acts as ChatterNotificationHandler for TenderLocation
     */
    private @TestVisible class TenderLocationChatterNotificationHandler implements AITM_TriggerFactory.SObjectHandler {
        private final String STAGE_AWAITING_PRICE = 'Awaiting Price';
        private @TestVisible Set<Id> tenderIdsLocationsOfWhichShouldBeNotified;
		private Id tenderIdForNewTFWithSectorChange;
        private Map<Id, Boolean> mapOfLineItemWithBooleanProductDefault;
        private Map<String, Boolean> mapOfUpdatedFeeWithSelectToApplyBoolean;
        private List<AITM_Tender_Location_Taxes_and_Fees__c> listOfExistingTaxesFees;

        /**
         * @description default constructor to initialize set collection tenderIdsLocationsOfWhichShouldBeNotified
         */
        public TenderLocationChatterNotificationHandler() {
            tenderIdsLocationsOfWhichShouldBeNotified = new Set<Id>();
            mapOfLineItemWithBooleanProductDefault = new Map<Id, Boolean>();
            mapOfUpdatedFeeWithSelectToApplyBoolean = new Map<String, Boolean>();
            listOfExistingTaxesFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so) {            
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;
                    
            if (this.notificationRequired(tender, oldTender, false)) {
                this.notifyRelatedTenderLocations(tender);
            }
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so){
            AITM_Tender__c tender = (AITM_Tender__c) so;

            if (this.notificationRequired(tender)) {
                this.notifyRelatedTenderLocations(tender);
            }
        }

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;

            if (this.notificationRequired(tender, oldTender)) {
                this.notifyRelatedTenderLocations(tender);
            }
            
            if((tender.AITM_Tender_Sector__c !=oldTender.AITM_Tender_Sector__c) && !tender.AITM_Select_to_Apply_Old_Taxes_and_Fees__c){
				tenderIdForNewTFWithSectorChange = tender.Id;
            }
        }

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block method called for trigger event
         * @param null
         * @return null
         */
        public void andFinally() {
            this.notifyRelatedTenderLocations();
            
            List<AITM_Tender_Location_Line_Item__c> commonTenderLocationLineItem = new List<AITM_Tender_Location_Line_Item__c>();
            if(tenderIdForNewTFWithSectorChange != null) {
                AITM_DeleteTaxFeeRecordsBatch.BatchState batchState = new AITM_DeleteTaxFeeRecordsBatch.BatchState(tenderIdForNewTFWithSectorChange, AITM_LocationsDao.DEFAULT_RECORD_TYPE_ID, null);
                new AITM_DeleteTaxFeeRecordsBatch.BatchFactory().executeBatch(batchState);
            }
        }

        /**
         * @description returns true when stage changed to awaiting price
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return boolean
         */
        private Boolean notificationRequired(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            return tender.AITM_Stage__c != oldTender.AITM_Stage__c
                && tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
        }

        /**
         * @description returns true when tender stage is awaiting price and send invitation is true
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @param tender of type boolean
         * @return boolean
         */
        private Boolean notificationRequired(AITM_Tender__c tender, AITM_Tender__c oldTender, Boolean forBeforeUpdate) {
            return !oldTender.AITM_Send_Invitation_Notification__c 
                && tender.AITM_Send_Invitation_Notification__c
                && tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
        }

        /**
         * @description sets the stage for notification required criteria
         * @param tender of type AITM_Tender__c
         * @return boolean
         */
        private Boolean notificationRequired(AITM_Tender__c tender) {
            return tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
        }

        /**
         * @description notify related tenderlocations adding to collection for the tender
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void notifyRelatedTenderLocations(AITM_Tender__c tender) {
            tenderIdsLocationsOfWhichShouldBeNotified.add(tender.Id);
        }

        /**
         * @description notifies related tenderlocations posting to chatter
         * @param null
         * @return List collection of ConnectApi.BatchInput
         */
        private @TestVisible List<ConnectApi.BatchInput> notifyRelatedTenderLocations() {
            List<ConnectApi.BatchInput> chatterMessages = new List<ConnectApi.BatchInput>();
            Boolean isMessageSent = false;
            if (tenderIdsLocationsOfWhichShouldBeNotified.size() > 0) {
                for (AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsLocationsOfWhichShouldBeNotified)) {
                    if (tenderLocation.AITM_Status__c == STAGE_AWAITING_PRICE) {
                        if(!isMessageSent) {
                            chatterMessages.add(this.generateChatterMessage(tenderLocation));
                            isMessageSent = true;
                        }    
                    }
                }
                AITM_BaseUtils.postToChatter(chatterMessages);
            }
            return chatterMessages;
        }
        
        /**
         * @description generates chatter message for a tenderlocation
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return ConnectApi.BatchInput
         */
        private ConnectApi.BatchInput generateChatterMessage(AITM_Tender_Location__c tenderLocation) {
            return AITM_BaseUtils.createChatterMessageWithMention(
                tenderLocation.AITM_Tender__c, 
                tenderLocation.AITM_Location_Manager__c, 
                this.getNotificationMessage(tenderLocation)
            );
        }

        /**
         * @description gets notification message for a tenderlocation
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return string
         */
        private String getNotificationMessage(AITM_Tender_Location__c tenderLocation){
            String text = 'The tender \'' + tenderLocation.AITM_Tender__r.Name + '\' is now in ' + tenderLocation.AITM_Status__c + ' stage. \n';
            if(tenderlocation.AITM_Country__c != null && tenderlocation.AITM_Country__c.toUpperCase() == AITM_LocationsDao.POLISH_COUNTRY) {
                //string prefix = 'labptendering';
                //text += 'For more details go here: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + prefix + '/' + tenderLocation.AITM_Tender__c;
                text += 'For more details go here: ' + AITM_BaseUtils.getLABPURL() + '/' + tenderLocation.AITM_Tender__c;
            } else {
                //text += 'For more details go here: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + tenderLocation.AITM_Tender__c;
                text += 'For more details go here: ' + AITM_BaseUtils.getTenderingURL() + '/' + tenderLocation.AITM_Tender__c;
            }
            return text;
        }
    }

    /**
     * @description class holds information to update Feedback for tenderlocation
     */
    private class TenderLocationUpdateFeedbackInformation implements AITM_TriggerFactory.SObjectHandler { 
        private Map<Id, AITM_Tender__c> tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback;
        private Map<Id, AITM_Tender__c> tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback;
        private final String STAGE_FEEDBACK = 'Feedback and Negotiation';
        
        /**
         * @description default constructor
         */ 
        public TenderLocationUpdateFeedbackInformation() {
            tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback = new Map<Id, AITM_Tender__c>();
            tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback = new Map<Id,AITM_Tender__c>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so){}

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @returnnull
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so){}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;
            
            if (this.feedbackUpdateRequired(tender, oldTender)) {
                this.updateRelatedTenderLocationFeedback(tender);
            } else if(tender.AITM_Stage__c == STAGE_FEEDBACK) {
                this.updateRelatedTenderLocationOfferedDiffFeedback(tender);
            }
        }

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block method called for trigger event
         * @param null
         * @return null
         */
        public void andFinally() {
            //this.updateRelatedTenderLocationFeedback();
        }

        /**
         * @description checks feedback update is required
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return boolean
         */
        private Boolean feedbackUpdateRequired(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            return tender.AITM_Quality_Of_Feedback__c != oldTender.AITM_Quality_Of_Feedback__c 
                || tender.AITM_Last_Look_To_Incumbent__c != oldTender.AITM_Last_Look_To_Incumbent__c 
                || tender.AITM_Number_Of_Rounds__c != oldTender.AITM_Number_Of_Rounds__c;
        }

        /**
         * @description map collection to update feedback for related tender
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void updateRelatedTenderLocationFeedback(AITM_Tender__c tender) {
            tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.put(tender.Id, tender);
            if(tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.size()>0){
                this.updateRelatedTenderLocationFeedback();
            }
        }

        /**
         * @description map collection to update feedback for related tender offered differential
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void updateRelatedTenderLocationOfferedDiffFeedback(AITM_Tender__c tender) {
            tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback.put(tender.Id, tender);
            if(tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback.size()>0){
                this.updateRelatedTenderLocationFeedback();
            }
        }
        /**
         * @description updates feedback and number of rounds for tenderlocations
         * @param null
         * @return null
         */
        private void updateRelatedTenderLocationFeedback() {
            if( feedbackCheck == true){
                feedbackCheck = false;
               List<AITM_Tender_Location__c> tenderLocations = null;               
                if(tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback.size() > 0) {                    
                    tenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback.keySet());
                }else {
                    tenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.keySet());
                }
            
            Map<Id, AggregateResult> tenderLocationAggregateResult = new AITM_LocationsDao().getMinimumOfferedDifferentialTenderLocationLineItems(tenderLocations);
            if(tenderLocations != null) {
                for (AITM_Tender_Location__c tenderLocation : tenderLocations) {
                    if(!tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.isEmpty()) {
                        AITM_Tender__c tender = tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.get(tenderLocation.AITM_Tender__c); 
                        if(tender != null) {
                            tenderLocation.AITM_Quality_Of_Feedback__c = tender.AITM_Quality_Of_Feedback__c;
                            tenderLocation.AITM_Last_Look_To_Incumbent__c = tender.AITM_Last_Look_To_Incumbent__c;
                            tenderLocation.AITM_Number_Of_Rounds__c = tender.AITM_Number_Of_Rounds__c;
                        }
                    }   
    
                    if(tenderLocationAggregateResult != null && tenderLocationAggregateResult.size() > 0 && tenderLocationAggregateResult.get(tenderLocation.Id) != null && tenderLocationAggregateResult.get(tenderLocation.Id).get('MINIMUMOFFEREDDIFFERENTIAL') != null) {
                        tenderLocation.AITM_Offered_Differential__c = (Decimal)tenderLocationAggregateResult.get(tenderLocation.Id).get('MINIMUMOFFEREDDIFFERENTIAL');
                    }
                }
            
               Database.update(tenderLocations, false);
           }
         }  
           
        }
    }

    /**
     * @description class holds information to update NewRound for tenderlocation
     */
    private class TenderLocationUpdateNewRoundWhenTenderIsProceedingToNewRound implements AITM_TriggerFactory.SObjectHandler {
        private final String STAGE_FEEDBACK = 'Feedback and Negotiation';

        private Set<Id> tenderIdsToChangeRelatedTenderLocationsRound;

        /**
         * @description default constructor
         */
        public TenderLocationUpdateNewRoundWhenTenderIsProceedingToNewRound() {
            tenderIdsToChangeRelatedTenderLocationsRound = new Set<Id>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so){}

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;

            if (this.newRoundRequiredToBeStarted(tender, oldTender)&& check) {
                this.changeRoundForTenderLocations(tender);
            }
        }

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block method called for trigger event
         * @param null
         * @return null
         */
        public void andFinally() {
            this.changeRoundForTenderLocations();
        }

        /**
         * @description new round required to start for tender
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return boolean
         */        
        private Boolean newRoundRequiredToBeStarted(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            AITM_TenderDao tenderInstance = new AITM_TenderDao();
            Map<String,Boolean> mapMultipleLocations = tenderInstance.multipleLocations(tender.Id);
            if(mapMultipleLocations.size() > 1) {
                return tender.AITM_Stage__c != oldTender.AITM_Stage__c 
                  && oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
            } else {
               return tender.AITM_Stage__c != oldTender.AITM_Stage__c 
                  && oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
            }
        }

        /**
         * @description changes round for tenderlocations for given tender
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void changeRoundForTenderLocations(AITM_Tender__c tender) {
            tenderIdsToChangeRelatedTenderLocationsRound.add(tender.Id);
        }

        /**
         * @description updates current round for tenderlocations
         * @param null
         * @return null
         */
        private void changeRoundForTenderLocations() {
            if (tenderIdsToChangeRelatedTenderLocationsRound.size() > 0) {
                List<AITM_Tender_Location__c> tenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsToChangeRelatedTenderLocationsRound);
                for (AITM_Tender_Location__c tenderLocation : tenderLocations) {
                    tenderLocation.AITM_Current_Round__c++;
                }
                 check = false;
                 Database.update(tenderLocations, false);
            }
        }

    }

    /**
     * @description class collects the line items to be deleted
     */
    private class TenderDeleteRelatedLineItems implements AITM_TriggerFactory.SObjectHandler {
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItemsToDelete;

        /**
         * @description default constructor
         */
        public TenderDeleteRelatedLineItems() {            
            this.tenderLocationLineItemsToDelete = new List<AITM_Tender_Location_Line_Item__c>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}
        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}
         /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so){}

         /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeDelete(SObject so){
            AITM_Tender__c deletedTender = (AITM_Tender__c) so;
            tenderLocationLineItemsToDelete =  new AITM_LocationsDao().getTenderLocationLineItemsByTender(deletedTender.Id);
          }

        public void andFinally(){           
                deleteRelatedLineItems();            
         }

        private void deleteRelatedLineItems() {      
            if (tenderLocationLineItemsToDelete.size() > Limits.getLimitDMLRows()){               
                //call apex batch job to delete records
               AITM_DeleteTenderLocationLineItemsBatch.BatchState batchState = new AITM_DeleteTenderLocationLineItemsBatch.BatchState(tenderLocationLineItemsToDelete);
               new AITM_DeleteTenderLocationLineItemsBatch.BatchFactory().executeBatch(batchState);
            } else {
                new AITM_LocationsDao().deleteTenderLocationLineItems(tenderLocationLineItemsToDelete);
            }            
        }
         /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so){}
         /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so){}

         /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */        
        public void afterDelete(SObject so) {}  

    }
   
    /**
     * @description class clones debrief line items
     */
    private class TenderLocationLineItemDebriefClone implements AITM_TriggerFactory.SObjectHandler {
        private final String STAGE_DEBRIEF = 'Debrief';
        private final String STAGE_FEEDBACK = 'Feedback and Negotiation';
        private final String DEBRIEF_RECORD_TYPE_ID = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
        private Set<Id> tenderIdsToChangeRelatedTenderLocationsRound;

        /**
         * @description default constructor
         */
        public TenderLocationLineItemDebriefClone() {
            tenderIdsToChangeRelatedTenderLocationsRound = new Set<Id>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so){}

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;
			
		    If(!AITM_CheckRecursive.setOfIDsAfterUpdate.contains(so.Id)){
                this.cloneDebriefRecords(tender, oldTender);
                AITM_CheckRecursive.setOfIDsAfterUpdate.add(so.Id);
			 }
			
        }
        
        /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block method called for trigger event
         * @param null
         * @return null
         */
        public void andFinally() {
            
        }

        /**
         * @description new round required to start for tender
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return void
         */        
        private void cloneDebriefRecords(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            
            if(tender.AITM_Stage__c != oldTender.AITM_Stage__c && oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && tender.AITM_No_Feedback_Progress_To_De_Brief__c) {
                
                Integer debriefCount = new AITM_LocationsDao.TenderLocationLineItemsDao().getDebriefLineItemsCount(tender.Id);
                if(debriefCount == 0) {
                    Database.executeBatch(new AITM_InsertTenderLocationLineItemsBatch(tender.Id, 'insert'));
                } else {
                    Database.executeBatch(new AITM_InsertTenderLocationLineItemsBatch(tender.Id, 'All'));
                }                                      
            }
        }
    }
    
    /**
     * @description class check for old and new tender
     */
    private class CheckTenderOldOrNew implements AITM_TriggerFactory.SObjectHandler {
        /**
         * @description default constructor
         */
        public CheckTenderOldOrNew() {}

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            this.checkTenderOldOrNew(tender);
        }

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so) {}

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block method called for trigger event
         * @param null
         * @return null
         */
        public void andFinally() {}

        /**
         * @description assigns values related to Adhoc volume fields of line item
         * @param lineItem of type 
         * @return void
         */
        public void checkTenderOldOrNew(AITM_Tender__c tender) {
            String[] userNames = label.AITM_AllowUserToNewTaxAndFee.split(',');
            if(userNames != null && userNames.size() > 0 && (userNames.contains(Userinfo.getUserName()) || userNames.contains('All'))){
                tender.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false;
            }else {
                tender.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = true;
            }
        }
    }
}