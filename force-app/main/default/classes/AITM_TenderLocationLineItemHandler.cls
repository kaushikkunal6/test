/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Trigger handler class for TenderLocationLineItem
 
 * history
 * 01/December/2017  George       Created
 * 20/March/2018     srnandan     Modified - added code comments at method and class level 
 *                                as per coding standards and also fixed sonar qube issue                  
 * 27/March/2018     srnandan     Modified - AR-2803- modified constant UNIT_OF_MEASURE_TO_USG_FACTORS
 *                                to include KG conversion to USG and sonar cube issue fix
 * 29/May/2018       Ravi         Modified - AR-3152- commented Offer Differential value is null while Inserting
 * 06/July/2018      srnandan     Modified - AR-3527 - Modified before update on RequestedAndOfferedVolumeCalculations
 * 25/July/2018      Ravi         Modified - AR-2747 - Added code to populate Tender History line Item
 * 23/August/2018    Shweta       Modified - Ar-3920 - rounded off the percentage offered  in the updatePercentageVolumeOffered 
 * 14/Nov/2018       srnandan     Fix for 101 query deactivating workflow rules
 * 10/Jan/2019       Anusha       Modified - AR-4645 - Added code to get Location Delviery points fields in TLLI object
 * 19/January/2019   srnandan     Modified - AR-4645 to only update delivery point details added PopulateDeliveryPointDetailsInTLLI class 
 * 24/January/2019   srnandan     Modified - AR-4913 populate values from delivery point in TLLI when recortype is default
 * 04/February/2019  Shweta       Modified - AR-4955 Putting condition to make the fields null only when record is not getting cloned in the class OldRoundEditionBlock 
 * 27/March/2019     Ravi         Modified - AR-5111 updated LT and MT conversion 
 * 02/April/2019     Ravi         Modified - AR-5028 added currency and UOM to populate to TLLI in updateDeliveryDetails
 * 21/May/2019       srnandan     Modified - AR-5029 to map product and density at TLLI based on new field productdensitypricing mapping
 * 29/May/2019       srnandan     Modified - AR-5029 Added missing soql fields in updateDeliveryDetails
 * 06/Sep/2019       Neeti        Modified - 695657 Added conditional operator to handle null pointer exception for AITM_Offered_Volume_Text__c method beforeInsert
 * 02/Feb/2020		 Saravan	  Modified - 879621 Updated the history tender link logic
 * 22/Apr/2020		 Saravan      Modified - 108793 Called the new method populateParentId to update Parent Id for MIP feed
 * 20/May/2020       Ravi         Modified to add validation and remove old taxes and fees field
 * 24/Sep/2020       Saravan      Modified to remove straddle flag to set as false 
 ***********************************************************************************************/
public with sharing class AITM_TenderLocationLineItemHandler implements AITM_TriggerFactory.SObjectHandler {
private AITM_TriggerFactory.HandlerRepository handlersStorage;
   
   /**
    * @description default constructor trigger handler class registering instance of classes
    */ 
   public AITM_TenderLocationLineItemHandler() {
        handlersStorage = new HandlerRepository();
        handlersStorage.register(new PrePopulationFieldsFiller());
        handlersStorage.register(new AdHocVolumeModificator());
        handlersStorage.register(new DeliveryPointsCreationHandler());
        handlersStorage.register(new TenderLocationUpdateNonRepresentedAndRecalculateFlag());
        handlersStorage.register(new RequestedAndOfferedVolumeCalculations());
        handlersStorage.register(new LineItemToTenderLocationRecordMapper());
        handlersStorage.register(new OldRoundEditionBlock());
        handlersStorage.register(new AITM_TenderLocationPricingService.TriggerAdapter());
        handlersStorage.register(new PopulateTenderHistoryLineItemHandler());
        handlersStorage.register(new PopulateDeliveryPointDetailsInTLLI());
        handlersStorage.register(new DefaultStraddling());
		handlersStorage.register(new InsertNewTaxesFeesRecords());
    }

    /**
     * @description bulk before factory method operation SObject handler
     * @param null
     * @return void
     */
    public void bulkBefore() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkBefore();
        }
    }

    /**
     * @description bulk after factory method operation SObject handler
     * @param null
     * @return void
     */
    public void bulkAfter() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkAfter();
        }
    }

    /**
     * @description before insert operation of trigger event
     * @param so of type SObject
     * @return void
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
     * @return void
     */
    public void beforeUpdate(SObject oldSo, SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeUpdate(oldSo, so);
        }
    }

    /**
     * @description before delete operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeDelete(so);
        }
    }

    /**
     * @description after insert operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
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
     * @return void
     */
    public void afterUpdate(SObject oldSo, SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterUpdate(oldSo, so);
        }
    }

    /**
     * @description after delete operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
     */
    public void afterDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
           concreteHandler.afterDelete(so);
        }
    }

    /**
     * @description finally block method called for trigger event
     * @param null
     * @return void
     */
    public void andFinally() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.andFinally();
        }
    }

    /**
     * @description interface to hold/set handler repository accessible
     */
    private interface HandlerRepositoryAccessible {
        void setHandlerRepository(HandlerRepository allHandlers);
    }

    /**
     * @description class implementing HandlerRepository interface
     */
    private with sharing class HandlerRepository implements AITM_TriggerFactory.HandlerRepository {
        private List<AITM_TriggerFactory.SObjectHandler> handlers;
        private TenderLocationLineItemOperationalUnit unit;

        /**
         * @description default constructor of handlerrepository class
         */
        public HandlerRepository() {
            handlers = new List<AITM_TriggerFactory.SObjectHandler>();
            unit = new TenderLocationLineItemOperationalUnit();
        }

        /**
         * @description registers/adds SObject handler to collection
         * @param handler of type AITM_TriggerFactory.SObjectHandler
         * @return void
         */
        public void register(AITM_TriggerFactory.SObjectHandler handler) {
            handlers.add(handler);
            if (handler instanceOf HandlerRepositoryAccessible) {
                ( (HandlerRepositoryAccessible) handler).setHandlerRepository(this);
            }
        }
        
        /**
         * @description returns list collection of SObjectHandler
         * @param null
         * @return List collection of type AITM_TriggerFactory.SObjectHandler
         */
        public List<AITM_TriggerFactory.SObjectHandler> handlers() {
            return handlers;
        }

        /**
         * @description gets operational unit
         * @param null
         * @return TenderLocationLineItemOperationalUnit class object
         */
        public TenderLocationLineItemOperationalUnit getOperationalUnit() {
            return unit;
        }
    }

    /**
     * @description class holding TenderLocationLineItem OperationUnit details
     */
    public with sharing class TenderLocationLineItemOperationalUnit {
        public final Id TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        public final Id TENDER_LOCATION_LINE_ITEM_DEBRIEF_RECORDTYPE_ID = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
        private final Map<String, Double> UNIT_OF_MEASURE_TO_USG_FACTORS = new Map<String, Double>{
            'USG' => 1,
            'LT' => 0.264172,
            'MT' => 330.215,
            'CM' => 264.1721,
            'KG' => 0.33
        };
        private final String NOT_REPRESENTED_STATUS = 'Not Represented';

        /**
         * @description default constructor
         */
        public TenderLocationLineItemOperationalUnit(){}
    }

    /**
     * @description class holding AdHocVolume modification details
     */
    private with sharing class AdHocVolumeModificator implements AITM_TriggerFactory.SObjectHandler {
        
        /**
         * @description default constructor
         */
        public AdHocVolumeModificator() {}

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkAfter(){}

        /**
         * @description before insert trigger event
         * @param so of type SObject
         * @return void
         */
        public void beforeInsert(SObject so) {
            AITM_Tender_Location_Line_Item__c tenderLocationLineItem = (AITM_Tender_Location_Line_Item__c) so;
            this.modifyVolumeAdHoc(tenderLocationLineItem);
        }

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeUpdate(SObject oldSo, SObject so) {
            AITM_Tender_Location_Line_Item__c oldLineItem = (AITM_Tender_Location_Line_Item__c) oldSo;
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;

            if (!lineItem.isClone()) {
                this.modifyVolumeAdHoc(oldLineItem, lineItem);
            }
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block called for trigger handler 
         * @param null
         * @return void
         */
        public void andFinally() {}

        /**
         * @description assigns values related to Adhoc volume fields of line item
         * @param lineItem of type 
         * @return void
         */
        public void modifyVolumeAdHoc(AITM_Tender_Location_Line_Item__c lineItem) {
            if (lineItem.AITM_Volume__c != null) {
                lineItem.AITM_Ad_hoc_Volume__c = false;
            } else if (lineItem.AITM_Ad_hoc_Volume__c) {
                lineItem.AITM_Volume__c = null;
                lineItem.AITM_Requested_Volume_USG__c = null;
                lineItem.AITM_Offered_Volume__c = null;
            }
        }

        /**
         * @description assign values related to Adhoc Volume fields of line item
         * @param oldLineItem of type SObject to hold old values
         * @param lineItem of type SObject to hold new values
         * @return void
         */
        public void modifyVolumeAdHoc(AITM_Tender_Location_Line_Item__c oldLineItem, AITM_Tender_Location_Line_Item__c lineItem) {
            if (!oldLineItem.AITM_Ad_hoc_Volume__c && lineItem.AITM_Ad_hoc_Volume__c) {
                lineItem.AITM_Volume__c = null;
                lineItem.AITM_Volume_Formatted_Text__c = null;
                lineItem.AITM_Requested_Volume_USG__c = null;
                lineItem.AITM_Offered_Volume__c = null;
                lineItem.AITM_Offered_Volume_Text__c = null;
            } else if (oldLineItem.AITM_Volume__c == null && lineItem.AITM_Volume__c != null
                       || oldLineItem.AITM_Requested_Volume_USG__c == null && lineItem.AITM_Requested_Volume_USG__c != null) {
                lineItem.AITM_Ad_hoc_Volume__c = false;
            }
        }
    }

    /**
     * @description class holds mapping of lineitem to tenderlocation
     */
    private with sharing class LineItemToTenderLocationRecordMapper implements AITM_TriggerFactory.SObjectHandler, HandlerRepositoryAccessible {
        private AITM_TenderLocationMappingHandler tenderLocationCreateUpdateHandler;
        private ID TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID;
        
        /**
         * @description default constructor
         */
        public LineItemToTenderLocationRecordMapper() {
            tenderLocationCreateUpdateHandler = new AITM_TenderLocationMappingHandler();
        }

        /**
         * @description sets tenderlocationlineitem default record type
         * @param allHandlers of HandlerRepository class
         * @return void
         */
        public void setHandlerRepository(HandlerRepository allHandlers) {
            TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID = allHandlers.getOperationalUnit().TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID;
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeInsert(SObject so) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;
            if (this.mappingRequired(lineItem)) {
                tenderLocationCreateUpdateHandler.collect(lineItem);
            }
        }

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeUpdate(SObject oldSo, SObject so) {
            AITM_Tender_Location_Line_Item__c oldLineItem = (AITM_Tender_Location_Line_Item__c) oldSo;
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;

            if (!lineItem.isClone()) {
                tenderLocationCreateUpdateHandler.collect(oldLineItem, lineItem);
            }
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeDelete(SObject so) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;
            tenderLocationCreateUpdateHandler.collect(lineItem, true);
        }

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block called for trigger handler 
         * @param null
         * @return void
         */
        public void andFinally() {
            tenderLocationCreateUpdateHandler.upsertTenderLocations();
        }

        /**
         * @description returns if tenderlocationitem is not cloned and matches default record type
         * @param tenderLocationLineItem of tenderlocationlineitem
         * @return boolean
         */
        private Boolean mappingRequired(AITM_Tender_Location_Line_Item__c tenderLocationLineItem) {
            return tenderLocationLineItem.RecordTypeId == TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID
                && !tenderLocationLineItem.isClone();
        }
    }
    
    /**
     * @description class handles prepopulation of field values
     */
    private with sharing class PrePopulationFieldsFiller implements AITM_TriggerFactory.SObjectHandler {
        private AITM_TenderLocationPrePopulationHandler tenderLocationPrePopulationHandler;
        
        /**
         * @description default constructor
         */
        public PrePopulationFieldsFiller() {
            tenderLocationPrePopulationHandler = new AITM_TenderLocationPrePopulationHandler();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeInsert(SObject so) {
            AITM_Tender_Location_Line_Item__c tenderLocationLineItem = (AITM_Tender_Location_Line_Item__c) so;
            if (!tenderLocationLineItem.isClone()) {
                tenderLocationPrePopulationHandler.collect(tenderLocationLineItem);
            }
        }

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeUpdate(SObject oldSo, SObject so) {}

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block called for trigger handler 
         * @param null
         * @return void
         */
        public void andFinally() {
            tenderLocationPrePopulationHandler.prePopulateFields();
            tenderLocationPrePopulationHandler.populateUserRelatedFields();
            tenderLocationPrePopulationHandler.populateParentId();
        }
    }

    /**
     * @description deliverypoints creation handler class
     */
    private with sharing class DeliveryPointsCreationHandler implements AITM_TriggerFactory.SObjectHandler {
        private AITM_TenderLocationDeliveryPointsHandler tenderLocationDeliveryPointsHandler;
        
        /**
         * @description default constructor
         */        
        public DeliveryPointsCreationHandler() {
            tenderLocationDeliveryPointsHandler = new AITM_TenderLocationDeliveryPointsHandler();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeInsert(SObject so) {
            AITM_Tender_Location_Line_Item__c tenderLocationLineItem = (AITM_Tender_Location_Line_Item__c) so;
            if (!tenderLocationLineItem.isClone()) {
                tenderLocationDeliveryPointsHandler.collect(tenderLocationLineItem);
            }
        }

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeUpdate(SObject oldSo, SObject so) {}

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block called for trigger handler 
         * @param null
         * @return void
         */
        public void andFinally() {
            tenderLocationDeliveryPointsHandler.assignDeliveryPoint();
        }
    } 

    /**
     * @description class holds requested and offered volume calculations
     */
    private with sharing class RequestedAndOfferedVolumeCalculations implements AITM_TriggerFactory.SObjectHandler, HandlerRepositoryAccessible {
        private TenderLocationLineItemOperationalUnit operationalUnit;
        private final String NOT_REPRESENTED_STATUS = 'Not Represented';
        
        /**
         * @description default constructor
         */
        public RequestedAndOfferedVolumeCalculations() {}

        /**
         * @description sets operationalunit from the handlerrepository
         * @param allHandlers of type HandlerRepository
         * @return void
         */
        public void setHandlerRepository(HandlerRepository allHandlers) {
            operationalUnit = allHandlers.getOperationalUnit();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkAfter(){}

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeInsert(SObject so) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;
            if (!lineItem.isClone()) {
                 lineItem.AITM_Requested_Volume_USG__c = this.calculateRequestedVolume(
                    lineItem.AITM_Requested_Volume_UoM__c, 
                    lineItem.AITM_Volume__c,lineItem.AITM_Ad_hoc_Volume__c 
                );

                if (lineItem.AITM_Percentage_Volume_Offered__c == null) {
                    lineItem.AITM_Percentage_Volume_Offered__c = 100;
                } else {
                    updateOfferedVolume(lineItem);
                }

                if (lineItem.AITM_Offered_Volume__c == null) {
                    lineItem.AITM_Offered_Volume__c = lineItem.AITM_Requested_Volume_USG__c;
					if(lineItem.AITM_Volume__c != null){
					    lineItem.AITM_Offered_Volume_Text__c = (lineItem.AITM_Requested_Volume_USG__c==null)?'':lineItem.AITM_Volume__c.format();
					}
                } else {
                    updatePercentageVolumeOffered(lineItem);
                }

                if (lineItem.RecordTypeId == null) {
                    lineItem.RecordTypeId = operationalUnit.TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID;
                }
            }
        }

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeUpdate(SObject oldSo, SObject so) {
             AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;
             AITM_Tender_Location_Line_Item__c lineItemOld = (AITM_Tender_Location_Line_Item__c) oldSo;
            if (!lineItem.isClone() && !this.isChangedRequestedVolume(lineItemOld, lineItem)) {
                if(!lineItem.AITM_Is_Pricing_Basis_Not_Represented__c) {
                    calculateOfferedVolumeAndPercentageOffered(lineItemOld, lineItem);    
                }else {
                    lineItem.AITM_Offered_Volume__c = null;
                    lineItem.AITM_Offered_Volume_Text__c = null;
                    lineItem.AITM_Percentage_Volume_Offered__c = null;
                    lineItem.AITM_Currency__c = null;
                    lineItem.AITM_Unit_Of_Measure__c = null;
                    lineItem.AITM_Start_Date__c = null;
                    lineItem.AITM_End_Date__c = null;
                    lineItem.AITM_Status__c = NOT_REPRESENTED_STATUS;
                }
            }
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeDelete(SObject so) {}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block called for trigger handler 
         * @param null
         * @return void
         */
        public void andFinally() {}
        
        /**
         * @description returns calculated requested volume 
         * @param unitOfMeasure of type string
         * @param volume of type decimal
         * @return decimal
         */
        private Decimal calculateRequestedVolume(String unitOfMeasure, Decimal volume,Boolean adhoc) {
            if (volume != null && unitOfMeasure != null) {
                return volume * operationalUnit.UNIT_OF_MEASURE_TO_USG_FACTORS.get(unitOfMeasure);
            }

            if(adhoc == true){
                return 0;   
            }
            return null;
        }

        /**
         * @description update volume and percentage offered
         * @param lineItemOld of type AITM_Tender_Location_Line_Item__c
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         * @return void
         */
        private void calculateOfferedVolumeAndPercentageOffered(AITM_Tender_Location_Line_Item__c lineItemOld, AITM_Tender_Location_Line_Item__c lineItem) {
            if (isChangedPercentage(lineItemOld, lineItem) && isChangedOfferedVolume(lineItemOld, lineItem)) {
                if (!isNull(lineItem.AITM_Offered_Volume__c)) {
                    updatePercentageVolumeOffered(lineItem);
                } else {
                    updateOfferedVolume(lineItem);
                }
            } else if (isChangedPercentage(lineItemOld, lineItem) && !isChangedOfferedVolume(lineItemOld, lineItem)) {
                if (isNull(lineItem.AITM_Percentage_Volume_Offered__c)) {
                    updatePercentageVolumeOffered(lineItem);
                } else {
                    updateOfferedVolume(lineItem);
                }
            } else if (!isChangedPercentage(lineItemOld, lineItem) && isChangedOfferedVolume(lineItemOld, lineItem)) {
                if (isNull(lineItem.AITM_Offered_Volume__c)) {
                    updateOfferedVolume(lineItem);
                } else {
                    updatePercentageVolumeOffered(lineItem);
                }
            }
        }

        /**
         * @description update percentage volume offered of lineitem
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         * @return void
         */
        private void updatePercentageVolumeOffered(AITM_Tender_Location_Line_Item__c lineItem) {
            Decimal percentageOffered = lineItem.AITM_Offered_Volume__c;
            if (percentageOffered != null && lineItem != null && lineItem.AITM_Requested_Volume_USG__c != null && lineItem.AITM_Requested_Volume_USG__c != 0) {
                lineItem.AITM_Percentage_Volume_Offered__c = (percentageOffered * 100 / lineItem.AITM_Requested_Volume_USG__c).round(system.roundingMode.HALF_UP);
            }
        }

        /**
         * @description update offeredvolume of lineitem
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         * @return void
         */
        private void updateOfferedVolume(AITM_Tender_Location_Line_Item__c lineItem) {
            Decimal offeredVolume = lineItem.AITM_Percentage_Volume_Offered__c;
            if (offeredVolume != null && lineItem.AITM_Requested_Volume_USG__c != null) {
                lineItem.AITM_Offered_Volume__c = offeredVolume * lineItem.AITM_Requested_Volume_USG__c / 100;
                if(lineitem.AITM_Volume__c != null){
                    lineItem.AITM_Offered_Volume_Text__c = (offeredVolume * lineItem.AITM_Volume__c / 100).format();    
                }
            }
        }

        /**
         * @description returns true if oldvalue of AITM_Percentage_Volume_Offered__c is not equal to new value else false
         * @param lineItemOld of type AITM_Tender_Location_Line_Item__c
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         * @return void
         */
        private Boolean isChangedPercentage(AITM_Tender_Location_Line_Item__c lineItemOld, AITM_Tender_Location_Line_Item__c lineItem) {
            return (lineItemOld.AITM_Percentage_Volume_Offered__c != lineItem.AITM_Percentage_Volume_Offered__c) ? true : false;
        }

        /**
         * @description returns true if change in PercentageVolumeOffered
         * @param lineItemOld of type AITM_Tender_Location_Line_Item__c
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         * @return void
         */
        private Boolean isChangedOfferedVolume(AITM_Tender_Location_Line_Item__c lineItemOld, AITM_Tender_Location_Line_Item__c lineItem) {
            return (lineItemOld.AITM_Offered_Volume__c != lineItem.AITM_Offered_Volume__c) ? true : false;
        }

        /**
         * @description returns true if change in requested volume else false
         * @param lineItemOld of type AITM_Tender_Location_Line_Item__c
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         * @return boolean
         */
        private Boolean isChangedRequestedVolume(AITM_Tender_Location_Line_Item__c lineItemOld, AITM_Tender_Location_Line_Item__c lineItem) {
            return (lineItemOld.AITM_Requested_Volume_UoM__c != lineItem.AITM_Requested_Volume_UoM__c) ? true : false;
        }

        /**
         * @description returns true if value is null else false
         * @param value of type decimal
         * @return boolean
         */
        private Boolean isNull(Decimal value) {
            return (value == null) ? true : false;
        }
    }

    /**
     * @description class holds requested and offered volume calculations
     */
    private with sharing class OldRoundEditionBlock implements AITM_TriggerFactory.SObjectHandler {
        private Boolean BYPASS_BLOCK_PERMISSION;

        public OldRoundEditionBlock() {
            BYPASS_BLOCK_PERMISSION = AITM_BaseUtils.checkRunningUserIsSystemAdministrator();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeInsert(SObject so) {
        
             AITM_Tender_Location_Line_Item__c tenderLocationLineItem =(AITM_Tender_Location_Line_Item__c) so;
              if(tenderLocationLineItem.AITM_Is_Clone__c == false){
                tenderLocationLineItem.AITM_Previous_Round_Differential__c = tenderLocationLineItem.AITM_Offered_Differential__c;
             
             
             if(tenderLocationLineItem.AITM_Location__c != null) {
                tenderLocationLineItem.Name = tenderLocationLineItem.AITM_Line_Item_Name_Account__c;   
             } 
              }  
         }
    
        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeUpdate(SObject oldSo, SObject so) {
            AITM_Tender_Location_Line_Item__c tenderLocationLineItem = (AITM_Tender_Location_Line_Item__c) so;
            AITM_Tender_Location_Line_Item__c oldTenderLocationLineItem = (AITM_Tender_Location_Line_Item__c) oldSo;
            if (this.oldRoundRecordEdition(tenderLocationLineItem)) {
                so.addError(Label.AITM_EditOldRoundErrorMessage);
            }

            if(!tenderLocationLineItem.AITM_Is_Current_Round__c) {
                tenderLocationLineItem.AITM_Previous_Round_Differential__c = oldTenderLocationLineItem.AITM_Offered_Differential__c ;
            }

            if(tenderLocationLineItem.AITM_Location__c != null && oldTenderLocationLineItem.AITM_Location__c != tenderLocationLineItem.AITM_Location__c) {
               tenderLocationLineItem.Name = tenderLocationLineItem.AITM_Line_Item_Name_Account__c;   
            }
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeDelete(SObject so) {}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block called for trigger handler 
         * @param null
         * @return void
         */
        public void andFinally() {}
        
        /**
         * @description returns true if round is not equal to current round
         * @param tenderLocationLineItem of AITM_Tender_Location_Line_Item__c
         * @return boolean
         */
        private Boolean oldRoundRecordEdition(AITM_Tender_Location_Line_Item__c tenderLocationLineItem) {
            return tenderLocationLineItem.AITM_Round__c != tenderLocationLineItem.AITM_Current_Round__c
                && !BYPASS_BLOCK_PERMISSION;
        }
    }

    /**
     * @description class holds tenderlocations with nonrepresented
     */
    private with sharing class TenderLocationUpdateNonRepresentedAndRecalculateFlag implements AITM_TriggerFactory.SObjectHandler, HandlerRepositoryAccessible {
        private TenderLocationLineItemOperationalUnit operationalUnit;
        private Set<Id> notRepresentedLocations;
        private Set<Id> recalculationRequiredLocations;
        
        /**
         * @description default constructor
         */
        public TenderLocationUpdateNonRepresentedAndRecalculateFlag() {
            notRepresentedLocations = new Set<Id>();
            recalculationRequiredLocations = new Set<Id>();
        }

        /**
         * @description sets operationunit from the handlerrepository
         */
        public void setHandlerRepository(HandlerRepository allHandlers) {
            operationalUnit = allHandlers.getOperationalUnit();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeInsert(SObject so) {}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeUpdate(SObject oldSo, SObject so) {}

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeDelete(SObject so) {}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterInsert(SObject so) {
            AITM_Tender_Location_Line_Item__c tenderLocationLineItem = (AITM_Tender_Location_Line_Item__c) so;
            if (!tenderLocationLineItem.isClone()) {
                if (this.isPricingBasisNotRepresented(tenderLocationLineItem)) {
                    notRepresentedLocations.add(tenderLocationLineItem.AITM_Tender_Location__c);
                }
            }
        }
        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterUpdate(SObject oldSo, SObject so) {
            AITM_Tender_Location_Line_Item__c oldTenderLocationLineItem = (AITM_Tender_Location_Line_Item__c) oldSo;
            AITM_Tender_Location_Line_Item__c tenderLocationLineItem = (AITM_Tender_Location_Line_Item__c) so;
        
            if (this.recalculationRequired(tenderLocationLineItem, oldTenderLocationLineItem)) {
                recalculationRequiredLocations.add(tenderLocationLineItem.AITM_Tender_Location__c);
            }
            if (this.isPricingBasisNotRepresented(tenderLocationLineItem)) {
                notRepresentedLocations.add(tenderLocationLineItem.AITM_Tender_Location__c);
            }
        }

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterDelete(SObject so) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;
            recalculationRequiredLocations.add(lineItem.AITM_Tender_Location__c);
        }

        /**
         * @description finally block called for trigger handler 
         * @param null
         * @return void
         */
        public void andFinally() {
            List<AITM_Tender_Location__c> commonTenderLocations = this.getCommonTenderLocations();
            this.updateRecalculationFlag(commonTenderLocations);
            this.updateNonRepresentedLocationStatus(commonTenderLocations);
            
            if (commonTenderLocations.size() > 0) {
                Database.update(commonTenderLocations, false);
            }
        }

        /**
         * @description returns true if tenderlocationlineitem recordtype is equal to 
         * operationalUnit default record type and pricingbasis is not represented else false
         * @param tenderLocationLineItem of type AITM_Tender_Location_Line_Item__c
         * @return boolean
         */
        private Boolean isPricingBasisNotRepresented(AITM_Tender_Location_Line_Item__c tenderLocationLineItem) {
            return tenderLocationLineItem.RecordTypeId == operationalUnit.TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID
                && tenderLocationLineItem.AITM_Is_Pricing_Basis_Not_Represented__c;
        }

        /**
         * @description returns true if change in value of offervolume and percentage volume offered else false 
         * @param tenderLocationLineItem of type AITM_Tender_Location_Line_Item__c to hold new values
         * @param oldTenderLocationLineItem of type AITM_Tender_Location_Line_Item__c to hold old values
         * @return boolean
         */
        private Boolean recalculationRequired(AITM_Tender_Location_Line_Item__c tenderLocationLineItem, AITM_Tender_Location_Line_Item__c oldTenderLocationLineItem) {
            return (tenderLocationLineItem.AITM_Offered_Volume__c != oldTenderLocationLineItem.AITM_Offered_Volume__c
                ||  tenderLocationLineItem.AITM_Percentage_Volume_Offered__c != oldTenderLocationLineItem.AITM_Percentage_Volume_Offered__c)
                && (tenderLocationLineItem.AITM_Offered_Volume__c != null 
                && tenderLocationLineItem.AITM_Percentage_Volume_Offered__c != null);
        }

        /**
         * @description gets common tender locations
         * @param null
         * @return List collection of AITM_Tender_Location__c
         */
        private List<AITM_Tender_Location__c> getCommonTenderLocations() {
            if (recalculationRequiredLocations.size() > 0 || notRepresentedLocations.size() > 0) {
                List<Id> tenderLocationIds = new List<Id>(recalculationRequiredLocations);
                tenderLocationIds.addAll(notRepresentedLocations);
                return new AITM_LocationsDao().getTenderLocationsByIds(tenderLocationIds);
            }
            return new List<AITM_Tender_Location__c>();
        }

        /**
         * @description updates recalculation flag
         * @param commonTenderLocations list collection of AITM_Tender_Location__c
         * @return void
         */
        private void updateRecalculationFlag(List<AITM_Tender_Location__c> commonTenderLocations) {
            if (commonTenderLocations.size() > 0 && recalculationRequiredLocations.size() > 0) {
                for (AITM_Tender_Location__c tenderLocation : commonTenderLocations) {
                    if (recalculationRequiredLocations.contains(tenderLocation.Id) && !tenderLocation.AITM_Recalculate_Total_Volume__c) {
                        tenderLocation.AITM_Recalculate_Total_Volume__c = true;
                    }
                }
            }
        }

        /**
         * @description updates non represented location status
         * @param commonTenderLocations list collection of type AITM_Tender_Location__c 
         * @return void
         */
        private void updateNonRepresentedLocationStatus(List<AITM_Tender_Location__c> commonTenderLocations) {
            if (commonTenderLocations.size() > 0) {
                for (AITM_Tender_Location__c tenderLocation : commonTenderLocations) {
                    if (notRepresentedLocations.contains(tenderLocation.Id)) {
                        tenderLocation.AITM_Status__c = operationalUnit.NOT_REPRESENTED_STATUS;
                    }
                }
            }            
        }
    }


    /**
     * @description class Populates Tender History Line Item
     */ 
    private with sharing class PopulateTenderHistoryLineItemHandler implements AITM_TriggerFactory.SObjectHandler {
       public PopulateTenderHistoryLineItemHandler() {}

       /**
        * @description bulk before factory method operation SObject handler
        * @param null
        * @return void
        */
       public void bulkBefore(){}
       
       /**
        * @description bulk after factory method operation SObject handler
        * @param null
        * @return void
        */
       public void bulkAfter(){}
       

       /**
        * @description bulk before insert factory method operation SObject handler
        * @param so
        * @return void
        */
       public void beforeInsert(SObject so){}

       /**
        * @description bulk before update factory method operation SObject handler
        * @param oldSo
        * @param so
        * @return void
        */
       public void beforeUpdate(SObject oldSo, SObject so){}

       /**
        * @description bulk before delete factory method operation SObject handler
        * @param so
        * @return void
        */
       public void beforeDelete(SObject so){}

       /**
        * @description bulk after insert factory method operation SObject handler
        * @param so
        * @return void
        */
       public void afterInsert(SObject so){}

       /**
        * @description bulk after update factory method operation SObject handler
        * @param oldSo
        * @param so
        * @return void
        */
       public void afterUpdate(SObject oldSo, SObject so){}

       /**
        * @description bulk after delete factory method operation SObject handler
        * @param so
        * @return void
        */
       public void afterDelete(SObject so){}

       
       /**
        * @description finally block called for trigger handler
        * @param null
        * @return void
        */
       public void andFinally() {
           if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert) ) {
               populateTenderHistoryLineItem(Trigger.new, trigger.oldmap);
           }
       }

       /**
        * @description updates non represented location status
        * @param tenderLLI
        * @param oldTenderLLI 
        * @return void
        */
       public void populateTenderHistoryLineItem(List<AITM_Tender_Location_Line_Item__c> tenderLLI, map<id,sObject> oldTenderLLI ) {           
           Map<Id,AITM_Tender_Location_Line_Item__c> oldTenderLocationLineItem = (oldTenderLLI != null) ? (Map<Id,AITM_Tender_Location_Line_Item__c>)oldTenderLLI : new Map<Id,AITM_Tender_Location_Line_Item__c>();
            Id debriefRecordtypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
            Set<Id> accountIds = new Set<Id>();
            set<Id> locationIds = new set<id>();
            set<Id> tenderLocationLIIds_inBatch = new set<id>();           
            List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItemCheck = new List<AITM_Tender_Location_Line_Item__c>();           
            
            for (AITM_Tender_Location_Line_Item__c tenderLocationLineItem : tenderLLI) {                
                AITM_Tender_Location_Line_Item__c oldTLLI = oldTenderLocationLineItem.get(tenderLocationLineItem.id);                
                if(oldTLLI == null && tenderLocationLineItem.AITM_Account__c != null && tenderLocationLineItem.AITM_Location__c != null ){
                    tenderLocationLineItemCheck.add(tenderLocationLineItem);                       
                    accountIds.add(tenderLocationLineItem.AITM_Account__c);
                    locationIds.add(tenderLocationLineItem.AITM_Location__c);                       
                } else if(oldTLLI != null && (tenderLocationLineItem.AITM_Account__c != oldTLLI.AITM_Account__c || tenderLocationLineItem.AITM_Location__c != oldTLLI.AITM_Location__c || tenderLocationLineItem.AITM_Location_Delivery_Point__c != oldTLLI.AITM_Location_Delivery_Point__c) ){
                    tenderLocationLineItemCheck.add(tenderLocationLineItem);                      
                    accountIds.add(tenderLocationLineItem.AITM_Account__c);
                    locationIds.add(tenderLocationLineItem.AITM_Location__c);
                    tenderLocationLIIds_inBatch.add(tenderLocationLineItem.id);                       
                }               
            }
            
            if(tenderLocationLineItemCheck.size() > 0) {                                                                
                Map<String, List<AITM_Tender_Location_Line_Item__c>> mpTenderLLI = new Map<String, List<AITM_Tender_Location_Line_Item__c>>();
                Map<String, List<AITM_Tender_Location_Line_Item__c>> mpTenderLLIDP = new Map<String, List<AITM_Tender_Location_Line_Item__c>>();
                // for(AITM_Tender_Location_Line_Item__c tlli: lstExistingLocationLineItems) {
                for(AITM_Tender_Location_Line_Item__c tlli : [SELECT AITM_Account__c, AITM_Location__c,AITM_Tender_Result__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender__c, AITM_Location_Delivery_Point__c, AITM_Tender__r.AITM_Stage__c FROM AITM_Tender_Location_Line_Item__c 
                                                              WHERE AITM_Account__c IN:accountIds AND AITM_Location__c IN:locationIds AND AITM_Tender_Result__c != NULL AND (AITM_Tender__r.AITM_Stage__c ='Closed' OR AITM_Tender__r.AITM_Stage__c ='Debrief') AND RecordTypeId=:debriefRecordtypeId AND AITM_End_Date__c != NULL AND id NOT IN:tenderLocationLIIds_inBatch ORDER BY AITM_End_Date__c DESC]) {
                                                                  String key = tlli.AITM_Account__c+'_'+tlli.AITM_Location__c;
                                                                  String keyDP = tlli.AITM_Account__c+'_'+tlli.AITM_Location__c+'_'+tlli.AITM_Location_Delivery_Point__c;
                                                                  if(mpTenderLLI.containsKey(key)) {
                                                                      mpTenderLLI.get(key).add(tlli);
                                                                  } else{
                                                                      mpTenderLLI.put(key,new AITM_Tender_Location_Line_Item__c[]{tlli});
                                                                  }
                                                                  if(tlli.AITM_Location_Delivery_Point__c != NULL){
                                                                      if(mpTenderLLIDP.containsKey(keyDP)) {
                                                                          mpTenderLLIDP.get(keyDP).add(tlli);
                                                                      } else{
                                                                          mpTenderLLIDP.put(keyDP,new AITM_Tender_Location_Line_Item__c[]{tlli});
                                                                      }
                                                                  }     
                                                              }                   
                
                for(AITM_Tender_Location_Line_Item__c tlli_toUpdate: tenderLocationLineItemCheck) {  
                    
                    String key = tlli_toUpdate.AITM_Account__c+'_'+tlli_toUpdate.AITM_Location__c;
                    String keyDP = tlli_toUpdate.AITM_Account__c+'_'+tlli_toUpdate.AITM_Location__c+'_'+tlli_toUpdate.AITM_Location_Delivery_Point__c;
                    
                    if (mpTenderLLIDP.containsKey(keyDP) && mpTenderLLIDP.get(keyDP) != null && mpTenderLLIDP.get(keyDP).size() >0){                            
                        for(AITM_Tender_Location_Line_Item__c existing_tlli :  mpTenderLLIDP.get(keyDP)) {                                
                            
                            if(tlli_toUpdate.AITM_Tender__c != existing_tlli.AITM_Tender__c && tlli_toUpdate.id != existing_tlli.id) {
                                tlli_toUpdate.AITM_History_Line_Item__c = existing_tlli.id;
                                break;
                            }                                
                        }
                        
                    }else if(mpTenderLLI.containsKey(key) && mpTenderLLI.get(key) != null && mpTenderLLI.get(key).size() >0) {                            
                        for(AITM_Tender_Location_Line_Item__c existing_tlli :  mpTenderLLI.get(key)) {                              
                            
                            if(tlli_toUpdate.AITM_Tender__c != existing_tlli.AITM_Tender__c && tlli_toUpdate.id != existing_tlli.id) {
                                tlli_toUpdate.AITM_History_Line_Item__c = existing_tlli.id;
                                break;
                            }                                
                        }
                    }
                } 
            }
        }
    }

    /**
     * @description class Populates Tender History Line Item
     */ 
    private with sharing class PopulateDeliveryPointDetailsInTLLI implements AITM_TriggerFactory.SObjectHandler {
        public PopulateDeliveryPointDetailsInTLLI() {}
        
        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkBefore(){}
        
        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkAfter(){}
        
        /**
         * @description bulk before insert factory method operation SObject handler
         * @param so
         * @return void
         */
        public void beforeInsert(SObject so){}
        
        /**
         * @description bulk before update factory method operation SObject handler
         * @param oldSo
         * @param so
         * @return void
         */
        public void beforeUpdate(SObject oldSo, SObject so){}
        
        /**
         * @description bulk before delete factory method operation SObject handler
         * @param so
         * @return void
         */
        public void beforeDelete(SObject so){}
        
        /**
         * @description bulk after insert factory method operation SObject handler
         * @param so
         * @return void
         */
        public void afterInsert(SObject so){}
        
        /**
         * @description bulk after update factory method operation SObject handler
         * @param oldSo
         * @param so
         * @return void
         */
        public void afterUpdate(SObject oldSo, SObject so){}
        
        /**
         * @description bulk after delete factory method operation SObject handler
         * @param so
         * @return void
         */
        public void afterDelete(SObject so){}
        
        
        /**
         * @description finally block called for trigger handler
         * @param null
         * @return void
         */
        public void andFinally() {
            if (Trigger.isBefore && Trigger.isUpdate) {
                updateDeliveryDetails(Trigger.new, trigger.oldmap);
            }
        }
        
        /**
         * @description updates line items related deliverypoint field mapping
         * @param tenderLLI list of tenderlocationlineitems
         * @param oldTenderLLI list of old tenderlocationlineitems
         * @return void
         */
        public void updateDeliveryDetails(List<AITM_Tender_Location_Line_Item__c> tenderLLI, map<id,sObject> oldTenderLLI ) {
            Set<Id> tenderDeliveryPointSet = new Set<Id>();
            Set<String> productDensitySet = new Set<String>();  
            Map<Id,AITM_Tender_Location_Line_Item__c> oldTenderLocationLineItem = (oldTenderLLI != null) ? (Map<Id,AITM_Tender_Location_Line_Item__c>)oldTenderLLI : new Map<Id,AITM_Tender_Location_Line_Item__c>();
            final Id TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            for(AITM_Tender_Location_Line_Item__c singleLocation : tenderLLI) {
                if(singleLocation.AITM_Location_Delivery_Point__c != oldTenderLocationLineItem.get(singleLocation.Id).AITM_Location_Delivery_Point__c && singleLocation.RecordTypeId == TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID) {
                    //if(tenderDeliveryPointSet.size() > 0) {
                        tenderDeliveryPointSet.add(singleLocation.AITM_Location_Delivery_Point__c); 
                    //} 
                } else if(singleLocation.AITM_Product_Density_for_Pricing__c != oldTenderLocationLineItem.get(singleLocation.Id).AITM_Product_Density_for_Pricing__c && singleLocation.AITM_Location_Delivery_Point__c == oldTenderLocationLineItem.get(singleLocation.Id).AITM_Location_Delivery_Point__c && singleLocation.RecordTypeId == TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID) {
          productDensitySet.add(singleLocation.AITM_Product_Density_for_Pricing__c);                    
                }    
            }
            if(tenderDeliveryPointSet.size() > 0) {
                Map<Id, AITM_Delivery_Point__c> deliveryRecords = new Map<Id, AITM_Delivery_Point__c>([SELECT AITM_Delivery_Method__c, AITM_Product_Specification__c, AITM_Delivery_By__c, AITM_Product_Default__c, AITM_Density__c, AITM_Product__c, AITM_Additional_Refueling_Information__c, AITM_Taxes_Fees__c, AITM_Measure__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Product_Pricing_Report__c, AITM_Is_Active__c FROM AITM_Delivery_Point__c WHERE Id =:tenderDeliveryPointSet AND AITM_Is_Active__c = true]); 
                if(deliveryRecords.size() > 0) {
                    for(AITM_Tender_Location_Line_Item__c singleLocation : tenderLLI) {
                        if(singleLocation.AITM_Location_Delivery_Point__c != null) {
                            singleLocation.AITM_Delivery_Method__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Delivery_Method__c;
                            singleLocation.AITM_Delivery_By__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Delivery_By__c;
                            singleLocation.AITM_Product_Density_for_Pricing__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Product__c;
                            singleLocation.AITM_Density__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Density__c;
                            singleLocation.AITM_Product_Default__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Product_Default__c;
                            singleLocation.AITM_Additional_Refueling_Information__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Additional_Refueling_Information__c;
                            if(singleLocation.AITM_Old_Taxes_Fees_Flag__c){
                                singleLocation.AITM_Taxes_Fees__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Taxes_Fees__c;
                            }
                            singleLocation.AITM_Measure__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Measure__c;
                            singleLocation.AITM_Product_Specification__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Product_Specification__c;
                            singleLocation.AITM_Currency__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Currency__c;
                            singleLocation.AITM_Unit_Of_Measure__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Unit_Of_Measure__c;
                            singleLocation.AITM_Product_Pricing_Report__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Product_Pricing_Report__c;
                        }
                    }
                }
            }

            if(!productDensitySet.isEmpty()) {
                Map<String, AITM_Product_Density_Mapping__mdt> mapProductDensity = AITM_BaseUtils.getProductDensityMap(productDensitySet);
                if(!mapProductDensity.isEmpty()) {
                  for(AITM_Tender_Location_Line_Item__c singleLocation : tenderLLI) {   
                       singleLocation.AITM_Density__c = mapProductDensity.get(singleLocation.AITM_Product_Density_for_Pricing__c).AITM_Density__c;
                      singleLocation.AITM_Product_Default__c = mapProductDensity.get(singleLocation.AITM_Product_Density_for_Pricing__c).AITM_Product__c;
                      singleLocation.AITM_Product_Pricing_Report__c = mapProductDensity.get(singleLocation.AITM_Product_Density_for_Pricing__c).AITM_Description__c;
                    }    
                }
            }       
        } 
    }
    
    /**
     * @description class handles default Straddling of taxes and fees
     */
    private with sharing class DefaultStraddling implements AITM_TriggerFactory.SObjectHandler {
        private List<Id> tenderIds;
    private List<Id> locationIds;
    private Id leadCustomerLineItemId;
    String taxesAndfees;
    String additionalNotes;
    Boolean isAffiliates = false;
    private List<AITM_Tender_Location_Line_Item__c> listOfItemsToUpdate;
        private Map<String, AITM_Tender_Location_Line_Item__c> mapOfAccountIdWithItem;
    private List<String> listOfAccountIds;
        
        /**
         * @description default constructor
         */
        public DefaultStraddling() {
        tenderIds = new List<Id>();
      mapOfAccountIdWithItem = new Map<String, AITM_Tender_Location_Line_Item__c>();
      locationIds = new List<Id>();
      listOfItemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
      listOfAccountIds = new List<String>();
      }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkAfter(){}

        /**
         * @description before insert trigger event
         * @param so of type SObject
         * @return void
         */
        public void beforeInsert(SObject so) {}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeUpdate(SObject oldSo, SObject so) {
            AITM_Tender_Location_Line_Item__c oldLineItem = (AITM_Tender_Location_Line_Item__c) oldSo;
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;

            if (this.checkDefaultStraddling(oldLineItem, lineItem)) {
                so.addError('Please uncheck default straddling checkbox in the location new offer page before editing/updating the Taxes and Fees information here.');
            }
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterInsert(SObject so) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;
            if(lineItem.AITM_Record_Type_Name__c != 'De-brief') {
                this.UpdateLineitemWithLocationWithStraddling(lineItem);
            }
        }

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block called for trigger handler 
         * @param null
         * @return void
         */
        public void andFinally() {
        List<AITM_Tender_Location__c> commonTenderLocations = this.getCommonTenderLocations();
      List<AITM_Tender_Account__c> getTenderAccounts = this.getTenderAccounts();
            Boolean isAffiliatesRelationPresent = this.isAffiliatesPresent(getTenderAccounts);
            if(isAffiliatesRelationPresent){
                this.handleDefaultStraddling(commonTenderLocations, getTenderAccounts);
                
                if (commonTenderLocations.size() > 0) {
                    Database.update(commonTenderLocations, false);
                }
                
                if (listOfItemsToUpdate.size() > 0) {
                    Database.update(listOfItemsToUpdate, false);
                }
            }
    }
    
        /**
         * @description handle default straddling with location, lineitem 
         * @param Collection of tender location and tender account type object
         * @return void
         */
    public void handleDefaultStraddling(List<AITM_Tender_Location__c> commonTenderLocations, List<AITM_Tender_Account__c> listOfTenderCustomers){
        if(commonTenderLocations != null && listOfTenderCustomers != null){
          for(AITM_Tender_Account__c customer : listOfTenderCustomers){
          for(String accountId : listOfAccountIds){
            if(accountId == customer.AITM_Account__c && customer.AITM_Affiliates_Account__c == null){
              isAffiliates = true;
                            for(String lineItemWithAccountId : mapOfAccountIdWithItem.keySet()){
                                if(lineItemWithAccountId.contains(accountId)){
                                    leadCustomerLineItemId = mapOfAccountIdWithItem.get(lineItemWithAccountId).Id;
                  taxesAndfees = mapOfAccountIdWithItem.get(lineItemWithAccountId).AITM_Taxes_Fees__c;
                  additionalNotes = mapOfAccountIdWithItem.get(lineItemWithAccountId).AITM_Additional_Notes_Taxes_and_Fees__c;
                                }
                            }
            }
          }
        }
      }
      
      if(isAffiliates && leadCustomerLineItemId != null) {
        for(AITM_Tender_Location__c location : commonTenderLocations) {
                    if(location.AITM_Tender_Location__r.size() > 1) {
            //location.AITM_Is_Straddled__c = true;
			location.AITM_Is_Straddled__c = false;
            for(AITM_Tender_Location_Line_Item__c lineItem : location.AITM_Tender_Location__r) {
                            if(leadCustomerLineItemId == lineItem.Id) {
                                //lineItem.AITM_Is_Straddled__c = true;
								lineItem.AITM_Is_Straddled__c = false;
                            }
                            lineItem.AITM_Straddled_Additional_Taxes_Fees__c = additionalNotes;
                            lineItem.AITM_Straddled_Taxes_Fees__c = taxesAndfees;
                            listOfItemsToUpdate.add(lineItem);
                        }
                    }
        }
      }
    }

        /**
         * @description check line item fields before updating taxe and fees
         * @param lineItem of type 
         * @return void
         */
        public Boolean checkDefaultStraddling(AITM_Tender_Location_Line_Item__c oldLineItem, AITM_Tender_Location_Line_Item__c lineItem) {
            Boolean isTaxAndFeeChange = false;
            String oldTaxAndFees = String.valueOf(oldLineItem.AITM_Taxes_Fees__c);
            String newTaxAndFees = String.valueOf(lineItem.AITM_Taxes_Fees__c);
            String oldAdditionalTaxAndFees = String.valueOf(oldLineItem.AITM_Additional_Notes_Taxes_and_Fees__c);
            String newAdditionalTaxAndFees = String.valueOf(lineItem.AITM_Additional_Notes_Taxes_and_Fees__c);
            if (lineItem.AITM_Is_Location_Straddled__c && ((oldTaxAndFees != newTaxAndFees) || (oldAdditionalTaxAndFees != newAdditionalTaxAndFees) || (oldLineItem.AITM_Include_Taxes_and_Fees_in_Contract__c != lineItem.AITM_Include_Taxes_and_Fees_in_Contract__c) || (oldLineItem.AITM_Include_Notes_in_Contract__c != lineItem.AITM_Include_Notes_in_Contract__c))) {           
                 isTaxAndFeeChange = true; 
             } else {
                 isTaxAndFeeChange = false;
             }
            return isTaxAndFeeChange;
        }
        
        /**
         * @description gets affiliate child relationship is present
         * @param Collection of tender Accounts
         * @return Boolean
         */
        public Boolean isAffiliatesPresent(List<AITM_Tender_Account__c> listOfTenderCustomers) {
            Boolean isAffiliatesRelationPresent = false;
            for(AITM_Tender_Account__c customer : listOfTenderCustomers){
                if(customer.AITM_Affiliates_Account__c != null){
                    isAffiliatesRelationPresent = true;
                    break;
                }
            }
            return isAffiliatesRelationPresent;
        }
        
        /**
         * @description gets location, tenderid, map of lineitemid with account
         * @param line Item of type object
         * @return void
         */
        public void UpdateLineitemWithLocationWithStraddling(AITM_Tender_Location_Line_Item__c lineItem) {
        locationIds.add(lineItem.AITM_Tender_Location__c);
      tenderIds.add(lineItem.AITM_Tender__c);
            mapOfAccountIdWithItem.put(lineItem.Id + '-' + lineItem.AITM_Account__c, lineItem);
      for(String AccountIds : mapOfAccountIdWithItem.keyset()){
        listOfAccountIds.add(AccountIds.split('-', 2)[1]);
      }
        }
    
        /**
         * @description gets common tender locations
         * @param null
         * @return List collection of AITM_Tender_Location__c
         */
        private List<AITM_Tender_Location__c> getCommonTenderLocations() {
            if (locationIds != null && locationIds.size() > 0) {
                return new AITM_LocationsDao().getTenderLocationWithLineItem(locationIds[0]);
            }
            return new List<AITM_Tender_Location__c>();
        }
    
        /**
         * @description gets tender Accounts
         * @param null
         * @return List collection of AITM_Tender_Account__c
         */
        private List<AITM_Tender_Account__c> getTenderAccounts() {
            if (tenderIds != null && tenderIds.size() > 0) {
                return new AITM_LocationsDao().getTenderCustomerByTenderIdAndAccount(tenderIds[0], listOfAccountIds);
            }
            return new List<AITM_Tender_Account__c>();
        }
    }
    
    /**
     * @description class Insert new Taxes and Fees Records
     */
    private with sharing class InsertNewTaxesFeesRecords implements AITM_TriggerFactory.SObjectHandler {
		private Set<Id> setofLineitemAlreadyHavingFeeRecords;
		private Map<Id, Boolean> mapOfLineItemWithBooleanProductDefault;
        private Decimal roundValue;
        
        /**
         * @description default constructor
         */
        public InsertNewTaxesFeesRecords() {
            setofLineitemAlreadyHavingFeeRecords = new Set<Id>();
			mapOfLineItemWithBooleanProductDefault = new Map<Id, Boolean>();
			roundValue = 0;
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return void
         */
        public void bulkAfter(){}

        /**
         * @description before insert trigger event
         * @param so of type SObject
         * @return void
         */
        public void beforeInsert(SObject so) {
			AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;
            if(!lineItem.AITM_Old_Taxes_Fees_Flag__c && lineItem.AITM_Record_Type_Name__c != 'De-brief'){
                lineItem.AITM_Include_Notes_in_Contract__c = true;
            }
		}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeUpdate(SObject oldSo, SObject so) {
			AITM_Tender_Location_Line_Item__c oldLineItem = (AITM_Tender_Location_Line_Item__c) oldSo;
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;
            if(!lineItem.AITM_Old_Taxes_Fees_Flag__c){
                if(lineItem.AITM_Include_Notes_in_Contract__c){
                    lineItem.AITM_Show_Additional_Notes_For_Conga__c = lineItem.AITM_Additional_Notes_Taxes_and_Fees__c;
                } else{
                    lineItem.AITM_Show_Additional_Notes_For_Conga__c = null;
                }
				if (this.checkTaxesAndFeesFieldValidation(oldLineItem, lineItem)) {
                    so.addError('Taxes and Fees field cannot be updated' + '\n' + 'Please use ‘Additional Notes (Taxes & Fees)’');
                }
            }
		}     
        

        /**
         * @description check line item fields before updating taxes and fees
         * @param lineItem of type 
         * @return void
         */
        public Boolean checkTaxesAndFeesFieldValidation(AITM_Tender_Location_Line_Item__c oldLineItem, AITM_Tender_Location_Line_Item__c lineItem) {
            Boolean isTaxAndFeeChange = false;
            String oldTaxAndFees = String.valueOf(oldLineItem.AITM_Taxes_Fees__c);
            String newTaxAndFees = String.valueOf(lineItem.AITM_Taxes_Fees__c);
            /* if any error in LABP community adding values then use below code
            if(oldTaxAndFees != null && !isBlank(oldTaxAndFees)){
                Integer oldTaxAndFeesCount = oldTaxAndFees.length();
            }
            if(newTaxAndFees != null && !isBlank(newTaxAndFees)){
                Integer newTaxAndFeesCount = newTaxAndFees.length();
            }*/
            //if((oldTaxAndFees != newTaxAndFees) && (oldTaxAndFees == newTaxAndFees)) {           
            if(oldTaxAndFees != newTaxAndFees) {
                 isTaxAndFeeChange = true; 
             } else {
                 isTaxAndFeeChange = false;
             }
            return isTaxAndFeeChange;
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterInsert(SObject so) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;
            if(!lineItem.AITM_Old_Taxes_Fees_Flag__c && lineItem.AITM_Record_Type_Name__c != 'De-brief'){
                mapOfLineItemWithBooleanProductDefault.put(lineItem.Id, false);
				roundValue = lineItem.AITM_round__c;
            }
        }

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return void
         */ 
        public void afterUpdate(SObject oldSo, SObject so){
		    AITM_Tender_Location_Line_Item__c oldTenderLocationLineItem = (AITM_Tender_Location_Line_Item__c) oldSo;
            AITM_Tender_Location_Line_Item__c tenderLocationLineItem = (AITM_Tender_Location_Line_Item__c) so;
			if(!tenderLocationLineItem.AITM_Old_Taxes_Fees_Flag__c && tenderLocationLineItem.AITM_Record_Type_Name__c != 'De-brief') {
			    this.checkLineItemUpdate(oldTenderLocationLineItem, tenderLocationLineItem, mapOfLineItemWithBooleanProductDefault);
			}
		}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block called for trigger handler  
         * @param null
         * @return void
         */
        public void andFinally() {
            List<AITM_Tender_Location_Line_Item__c> commonTenderLocationsLineItems = this.commonTenderLocationsLineItems();
            
            List<AITM_Tender_Location_Taxes_and_Fees__c> commonTaxesAndFeesAlreadyOnLineItem = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
            if(!setofLineitemAlreadyHavingFeeRecords.isEmpty()) {
                commonTaxesAndFeesAlreadyOnLineItem = this.commonTaxesAndFeesAlreadyOnLineItem();
            }
            
            if(!commonTaxesAndFeesAlreadyOnLineItem.isEmpty()){
			    AITM_TenderApplyNewTaxesAndFees.deleteExistingTaxesAndFees(commonTaxesAndFeesAlreadyOnLineItem);
			}
            
            if(!commonTenderLocationsLineItems.isEmpty()){
			    if(roundValue <=1){
			    AITM_TenderApplyNewTaxesAndFees.attachTaxAndFeeRecordsOnLineItem(commonTenderLocationsLineItems, null);
			   }
			}
						
        }

        /**
         * @description check line item fields before updating taxes and fees
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
		 * @param oldLineItem of type AITM_Tender_Location_Line_Item__c
         * @return Map<Id, Boolean>
         */
        public Map<Id, Boolean> checkLineItemUpdate(AITM_Tender_Location_Line_Item__c oldLineItem, AITM_Tender_Location_Line_Item__c lineItem, Map<Id, Boolean> mapOfLineItemWithBooleanProductDefault) {
            
            if(oldLineItem.AITM_Location_Delivery_Point__c != lineItem.AITM_Location_Delivery_Point__c || oldLineItem.AITM_Delivery_Method__c != lineItem.AITM_Delivery_Method__c || oldLineItem.AITM_Product_Default__c != lineItem.AITM_Product_Default__c) {
                String oldProductType = AITM_BaseUtils.getTaxesFeesFuelType(oldLineItem.AITM_Product_Default__c);
                String newProductType = AITM_BaseUtils.getTaxesFeesFuelType(lineItem.AITM_Product_Default__c);
                String oldDeliveryPoint = oldLineItem.AITM_Location_Delivery_Point__c;
                String newDeliveryPoint = lineItem.AITM_Location_Delivery_Point__c;
                String oldDeliveryMethod = oldLineItem.AITM_Delivery_Method__c;
                String newDeliveryMethod = lineItem.AITM_Delivery_Method__c;
                if((oldProductType != newProductType) || (oldDeliveryPoint != newDeliveryPoint) || (oldDeliveryMethod != newDeliveryMethod)){
                    setofLineitemAlreadyHavingFeeRecords.add(lineItem.Id);
					mapOfLineItemWithBooleanProductDefault.put(lineItem.Id, true);
                }
            }
            return mapOfLineItemWithBooleanProductDefault;
        }
    
        /**
         * @description gets common tender location line items
         * @param null
         * @return List collection of AITM_Tender_Location_Line_Item__c
         */
        private List<AITM_Tender_Location_Line_Item__c> commonTenderLocationsLineItems() {
            if(!mapOfLineItemWithBooleanProductDefault.keySet().isEmpty()) {
                return new AITM_LocationsDao().getTenderLocationLineItemBySetOfIds(mapOfLineItemWithBooleanProductDefault.keySet());
            }
            return new List<AITM_Tender_Location_Line_Item__c>();
        }
        
        /**
         * @description gets common Taxes and Fees
         * @param null
         * @return List collection of AITM_Tender_Location_Taxes_and_Fees__c
         */
        private List<AITM_Tender_Location_Taxes_and_Fees__c> commonTaxesAndFeesAlreadyOnLineItem() {
            if(!setofLineitemAlreadyHavingFeeRecords.isEmpty()) {
                return new AITM_LocationsDao().getTaxesAndFeesBySetOfItemIds(setofLineitemAlreadyHavingFeeRecords);
            }
            return new List<AITM_Tender_Location_Taxes_and_Fees__c>();
        }
    }
}