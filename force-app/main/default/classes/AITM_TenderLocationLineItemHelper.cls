/***********************************************************************************************
 * @author           Sushant
 * @date             21/May/2020
 * @group            AirBP
 * @description      Trigger helper class for TenderLocationLineItemHandler1
 * 24/Sep/2020       Saravan      Modified to remove straddle flag to set as false 
 * 17/Oct/2020       Saravan	  Modified to change Start Date End Date validation to fix round2 issue 
 ***********************************************************************************************/
public with sharing class AITM_TenderLocationLineItemHelper { 
    
   // public static Map<Id, ChildAccountsForTenders> childAccountsByParentId = new Map<Id, ChildAccountsForTenders>();
    public  static Map<Id, Set<Id>> customerIdsByTenderId ;  
    private TenderLocationLineItemOperationalUnit unit;   
    private TenderLocationLineItemOperationalUnit operationalUnitInstance = new TenderLocationLineItemOperationalUnit();    
    public ID ID_TLLI_RECORD_TYPE_DEFAULT = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();   
    private Set<Id> lineItemIds = new Set<Id>();
    private Set<Id> tenderIds = new Set<Id>();
    
    /**
    * @description beforeStartEndDateValidation operation of trigger event
    * @param so of type SObject, Map to hold new values
    * @return void
    */
    public void beforeStartEndDateValidation(List<SObject> so, Map<Id,Sobject> oMap){           
        Map<Id,AITM_Tender_Location_Line_Item__c> oldMapTLLIRecords = (Map<Id, AITM_Tender_Location_Line_Item__c>) oMap;
        List<AITM_Tender_Location_Line_Item__c> listOfTLLIRecords = (List<AITM_Tender_Location_Line_Item__c>) so; 
        Set<Id> setOfLineItems = new Set<Id>();
        Map<id, Boolean> lineItemIdWithPricingbasis = new Map<id, Boolean>();
        
        for(AITM_Tender_Location_Line_Item__c lineItem : listOfTLLIRecords){
            setOfLineItems.add(lineItem.id);
        }
        List<AITM_Tender_Location_Line_Item__c> lisOfLineItems = [Select Id, AITM_Pricing_Basis__r.AITM_Not_Represented__c, AITM_Tender_Location__r.AITM_Status__c 
                                                                  FROM AITM_Tender_Location_Line_Item__c WHERE Id IN :setOfLineItems];
        for(AITM_Tender_Location_Line_Item__c  item: lisOfLineItems){
            lineItemIdWithPricingbasis.put(item.Id, item.AITM_Pricing_Basis__r.AITM_Not_Represented__c);
        }
        Integer datamigration = [SELECT Count() FROM Profile WHERE Id = :UserInfo.getProfileId() AND Name = 'AITM_Data_Migration' LIMIT 1];
        for(AITM_Tender_Location_Line_Item__c lineItem : listOfTLLIRecords){
               
			   // before insert date mandatory check
               if(!Test.isRunningTest() && datamigration != 1){
				   if((oldMapTLLIRecords == null || oldMapTLLIRecords.size() == 0) || oldMapTLLIRecords != null){
                       //below two if conditions changed by Saravan for NonRep validation
					   //if( !lineItemIdWithPricingbasis.get(lineItem.Id) && lineItem.AITM_Start_Date__c == null){
                       if( !lineItem.AITM_Is_Pricing_Basis_Not_Represented__c && lineItem.AITM_Status__c == 'Priced' && lineItem.AITM_Start_Date__c == null){
						  lineItem.addError('Start Date cannot be blank.');
					   }
					   //if(!lineItemIdWithPricingbasis.get(lineItem.Id) && lineItem.AITM_End_Date__c == null){
                       if(!lineItem.AITM_Is_Pricing_Basis_Not_Represented__c && lineItem.AITM_Status__c == 'Priced' && lineItem.AITM_End_Date__c == null){
						  lineItem.addError('End Date cannot be blank.');
					   }
				   }
				}
                               
               // before insert record
               if(oldMapTLLIRecords == null || oldMapTLLIRecords.size() == 0){
                   if(lineItem.AITM_Start_Date__c != null && lineItem.AITM_End_Date__c != null &&
                      lineItem.AITM_Start_Date__c >= lineItem.AITM_End_Date__c){
                      lineItem.addError('Start Date cannot be after the End Date. Please review the dates');
                   }
               }
               else if(oldMapTLLIRecords != null){ // before update record
                   AITM_Tender_Location_Line_Item__c oldInstance = oldMapTLLIRecords.get(lineItem.Id);
                   if(lineItem.AITM_Start_Date__c != null && lineItem.AITM_End_Date__c != null){
                      if(lineItem.AITM_Start_Date__c != oldInstance.AITM_Start_Date__c &&
                          lineItem.AITM_Start_Date__c >= lineItem.AITM_End_Date__c){
                          lineItem.addError('Start Date cannot be after the End Date. Please review the dates');
                       }		 
                       if(lineItem.AITM_End_Date__c != oldInstance.AITM_End_Date__c &&
                          lineItem.AITM_Start_Date__c >= lineItem.AITM_End_Date__c){
                          lineItem.addError('End Date cannot be before Start Date. Please review the dates');
                       }
                   }                   
               }
   			}
        }
    
    /**
     * @description gets operational unit
     * @param null
     * @return TenderLocationLineItemOperationalUnit class object
     */
    public TenderLocationLineItemOperationalUnit getOperationalUnit() {
        return unit;
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

    /**************************************************AITM_TenderLocationPricingService*************************************************************** */
    /**
     * @description calling on afterinsert OLD PROS AITM_TenderLocationPricingService
     * @param List<Sobject>
     * @return null
     */
    public void afterInsertTenderLocationOldPROSPricingService(List<Sobject> so){
      AITM_TenderLocationProsPricingService tenderLocationPROSPricingServiceHandler = new AITM_TenderLocationProsPricingService();
      if(!Test.isRunningTest()){
      AITM_SwitchProsCalloutApi__c checkPROSTypeToCall = AITM_SwitchProsCalloutApi__c.getValues('MuleProsCalloutClass');
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineitem :  tenderLocationLineItemList){
            if(checkPROSTypeToCall.AITM_OldProsCallout__c){
                tenderLocationPROSPricingServiceHandler.afterInsert(lineitem);   
            }
        }
      }
    }
    
    /**
     * @description calling on afterUpdate PROS AITM_TenderLocationPricingService
     * @param List<Sobject>
     * @return null
     */
    public void afterUpdateTenderLocationPROSPricingService(Map<Id,Sobject> soOldMap, List<Sobject> so){
        AITM_TenderLocationProsPricingService tenderLocationPROSPricingServiceHandler = new AITM_TenderLocationProsPricingService();
        Map<Id,AITM_Tender_Location_Line_Item__c> locationLineItemMap = (Map<Id,AITM_Tender_Location_Line_Item__c>) soOldMap;
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineitem :  tenderLocationLineItemList){
            tenderLocationPROSPricingServiceHandler.afterUpdate(locationLineItemMap.get(lineitem.Id), lineitem);    
        }
    }     
    
    /**************************************************PrePopulationFieldsFiller*************************************************************** */
     AITM_TenderLocationPrePopulationHandler tenderLocationPrePopulationHandler = new AITM_TenderLocationPrePopulationHandler();
     /**
         * @description before insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void beforeInsertPrePopulationFieldsFiller(List<Sobject> so) {
            List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItem = (List<AITM_Tender_Location_Line_Item__c>) so;
            for(AITM_Tender_Location_Line_Item__c lineitem : tenderLocationLineItem){
                 if (!lineitem.isClone()) {
                    tenderLocationPrePopulationHandler.collect(lineitem);
                 }
            }            
            tenderLocationPrePopulationHandler.prePopulateFields(tenderLocationLineItem);
        }

     /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return void
         */
        public void afterInsertPrePopulationFieldsFiller(List<Sobject> so) {
            //AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) so;
            //if((!lineItem.isClone() || lineItem.AITM_Is_Clone__c) && lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT){
                    //lineItem.AITM_Parent_TLLI_Id__c = lineItem.Id;  
                //}
            tenderLocationPrePopulationHandler.populateUserRelatedFields(so);
            tenderLocationPrePopulationHandler.populateParentId(so);            
        }
   
    /**************************************************AdHocVolumeModificator*************************************************************** */     
    
    /**
     * @description before insert trigger event
     * @param so of type SObject
     * @return void
     */
    public void beforeInsertmodifyVolumeAdHoc(List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItem = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineitem :  tenderLocationLineItem){
            modifyVolumeAdHoc(lineitem);
        }        
    } 

    /**
     * @description before update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeUpdatemodifyVolumeAdHoc(Map<Id,Sobject> oMap, List<SObject> so) {
        Map<Id,AITM_Tender_Location_Line_Item__c> oldLineItemMap = (Map<Id, AITM_Tender_Location_Line_Item__c>) oMap;
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItem = (List<AITM_Tender_Location_Line_Item__c>) so;        
        for(AITM_Tender_Location_Line_Item__c lineitem :  tenderLocationLineItem){
            if (!lineItem.isClone()) {
                 modifyVolumeAdHoc(oldLineItemMap.get(lineitem.Id), lineItem);
            }
        }
       
    }

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

    /**************************************************DeliveryPointsCreationHandler*************************************************************** */     
    AITM_TenderLocationDeliveryPointsHandler tenderLocationDeliveryPointsHandler = new AITM_TenderLocationDeliveryPointsHandler();

    /**
     * @description before insert operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeInsertDeliveryPointsCreationHandler(List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> locationLineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineitem :  locationLineItemList){
             if (!lineitem.isClone()) {
               tenderLocationDeliveryPointsHandler.collect(lineitem);
             }
        }        
        tenderLocationDeliveryPointsHandler.assignDeliveryPoint();
    }

    /**
     * @description after insert operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
     */
    public void afterInsertDeliveryPointsCreationHandler(List<SObject> so) {
        /*AITM_Tender_Location_Line_Item__c tenderLocationLineItem = (AITM_Tender_Location_Line_Item__c) so;
        if (!tenderLocationLineItem.isClone()) {
            tenderLocationDeliveryPointsHandler.collect(tenderLocationLineItem);
        }*/
      //  tenderLocationDeliveryPointsHandler.assignDeliveryPoint();
    }    

    /**************************************************RequestedAndOfferedVolumeCalculations*************************************************************** */     
    private final String NOT_REPRESENTED_STATUS = 'Not Represented';
   // private TenderLocationLineItemOperationalUnit operationalUnitInstance = this.getOperationalUnit();      

    /**
     * @description before delete operation of trigger event 
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeInsertRequestedAndOfferedVolumeCalculations(List<SObject> so) {
            List<AITM_Tender_Location_Line_Item__c> lineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
            for(AITM_Tender_Location_Line_Item__c lineitem :  lineItemList){
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
                        lineItem.RecordTypeId = operationalUnitInstance.TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID;
                    }
                }
            }
            
    }

    /**
     * @description before update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeUpdateRequestedAndOfferedVolumeCalculations(Map<Id,SObject> oldMap, List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> lineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        Map<Id, AITM_Tender_Location_Line_Item__c> lineItemMap = (Map<Id,AITM_Tender_Location_Line_Item__c>) oldMap;
        for(AITM_Tender_Location_Line_Item__c lineitem : lineItemList){
              if (!lineItem.isClone() && !isChangedRequestedVolume(lineItemMap.get(lineItem.Id), lineItem)) {
                if(!lineItem.AITM_Is_Pricing_Basis_Not_Represented__c) {
                    calculateOfferedVolumeAndPercentageOffered(lineItemMap.get(lineItem.Id), lineItem);    
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
    }
    
    /**
     * @description returns calculated requested volume 
     * @param unitOfMeasure of type string
     * @param volume of type decimal
     * @return decimal
     */
    private Decimal calculateRequestedVolume(String unitOfMeasure, Decimal volume,Boolean adhoc) {
        if (volume != null && unitOfMeasure != null) {
            return volume * operationalUnitInstance.UNIT_OF_MEASURE_TO_USG_FACTORS.get(unitOfMeasure);
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
                /*if (lineItem.AITM_Offered_Volume__c != null) {
                    lineItem.AITM_Offered_Volume_Text__c = lineItem.AITM_Requested_Volume_USG__c.format();
                }*/
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
            //lineItem.AITM_Offered_Volume_Text__c = lineItem.AITM_Offered_Volume__c.format();
            if(lineitem.AITM_Volume__c != null){
                lineItem.AITM_Offered_Volume_Text__c = (offeredVolume * lineItem.AITM_Volume__c / 100).format();    
                lineItem.AITM_Volume_Formatted_Text__c = String.valueOf(lineItem.AITM_Volume__c);
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

    /**************************************************LineItemToTenderLocationRecordMapper*************************************************************** */       
    //TenderLocationLineItemOperationalUnit operationalUnitInstance = new TenderLocationLineItemOperationalUnit();
    private ID TENDER_LOCATIONLINEITEM_DEFAULT_RECORDTYPE_ID = operationalUnitInstance.TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID;
    //private ID TENDER_LOCATIONLINEITEM_DEFAULT_RECORDTYPE_ID = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
    AITM_TenderLocationMappingHandler tenderLocationCreateUpdateHandler = new AITM_TenderLocationMappingHandler();
    
    /**
     * @description before insert operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeInsertLineItemToTenderLocationRecordMapper(List<SObject> so) {
        String insertEvent = 'onInsert';              
        List<AITM_Tender_Location_Line_Item__c> lineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        System.debug('--------lineItem----'+lineItemList);
        for(AITM_Tender_Location_Line_Item__c lineItem : lineItemList){
            if (mappingRequired(lineItem)) {
              tenderLocationCreateUpdateHandler.collect(lineItem);
            }            
        }
        tenderLocationCreateUpdateHandler.upsertTenderLocations(insertEvent);
    }
    
    /**
     * @description before update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeUpdateLineItemToTenderLocationRecordMapper(Map<Id,SObject> oMap, List<SObject> so) {
        String UpdateEvent = 'onUpdate';
        Map<Id,AITM_Tender_Location_Line_Item__c> oldLineItemMap = (Map<Id,AITM_Tender_Location_Line_Item__c>) oMap;
        List<AITM_Tender_Location_Line_Item__c> lineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineitem : lineItemList){
          if (!lineItem.isClone()) {
             tenderLocationCreateUpdateHandler.collect(oldLineItemMap.get(lineItem.Id), lineItem);
          }    
        }                    
        tenderLocationCreateUpdateHandler.upsertTenderLocations(UpdateEvent);
    }

    /**
     * @description before delete operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeDeleteLineItemToTenderLocationRecordMapper(List<SObject> so) {
        String deleteEvent = 'onDelete';
        List<AITM_Tender_Location_Line_Item__c> lineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineItem : lineItemList){
            tenderLocationCreateUpdateHandler.collect(lineItem, true);            
        }
        tenderLocationCreateUpdateHandler.upsertTenderLocations(deleteEvent);
    }

    /**
     * @description returns if tenderlocationitem is not cloned and matches default record type
     * @param tenderLocationLineItem of tenderlocationlineitem
     * @return boolean
     */
    private Boolean mappingRequired(AITM_Tender_Location_Line_Item__c tenderLocationLineItem) {
        system.debug('mapping---'+tenderLocationLineItem);
        return tenderLocationLineItem.RecordTypeId == TENDER_LOCATIONLINEITEM_DEFAULT_RECORDTYPE_ID
            && !tenderLocationLineItem.isClone();
    }
        

    /**************************************************OldRoundEditionBlock*************************************************************** */   
    private Boolean BYPASS_BLOCK_PERMISSION = AITM_BaseUtils.checkRunningUserIsSystemAdministrator();
    
    /**
     * @description before insert operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeInsertOldRoundEditionBlock(List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> locationLineItemList =(List<AITM_Tender_Location_Line_Item__c>) so;        
        for(AITM_Tender_Location_Line_Item__c lineItem : locationLineItemList){
            if(lineItem.AITM_Is_Clone__c == false){
            lineItem.AITM_Previous_Round_Differential__c = lineItem.AITM_Offered_Differential__c;
            if(lineItem.AITM_Location__c != null) {
               lineItem.Name = lineItem.AITM_Line_Item_Name_Account__c;   
            }  
        }          
        }
    }

    /**
     * @description before update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeUpdateOldRoundEditionBlock(Map<Id,SObject> oldSoMap, List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> locationLineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        Map<Id, AITM_Tender_Location_Line_Item__c> locationLineItemMap = (Map<Id,AITM_Tender_Location_Line_Item__c>) oldSoMap;
        for(AITM_Tender_Location_Line_Item__c lineitem : locationLineItemList){
                if (oldRoundRecordEdition(lineitem)) {
                    lineitem.addError(Label.AITM_EditOldRoundErrorMessage);
                }
                if(!lineitem.AITM_Is_Current_Round__c) {
                    lineitem.AITM_Previous_Round_Differential__c = locationLineItemMap.get(lineitem.Id).AITM_Offered_Differential__c ;
                }
                if(lineitem.AITM_Location__c != null && locationLineItemMap.get(lineitem.Id).AITM_Location__c != lineitem.AITM_Location__c) {
                    lineitem.Name = lineitem.AITM_Line_Item_Name_Account__c;   
                }            
        }
    }

    /**
     * @description returns true if round is not equal to current round
     * @param tenderLocationLineItem of AITM_Tender_Location_Line_Item__c
     * @return boolean
     */
    private Boolean oldRoundRecordEdition(AITM_Tender_Location_Line_Item__c tenderLocationLineItem) {
        return tenderLocationLineItem.AITM_Round__c != tenderLocationLineItem.AITM_Current_Round__c
            && !BYPASS_BLOCK_PERMISSION;
    }

    /*******************************************PopulateTenderHistoryLineItemHandler***********************************************************/        

    public void beforeInsertPopulateTenderHistoryLineItemHandler(List<SObject> so, Map<Id, Sobject>oMap){
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItem = (List<AITM_Tender_Location_Line_Item__c>) so;
        populateTenderHistoryLineItem(tenderLocationLineItem, null);
    }

    public void beforeUpdatePopulateTenderHistoryLineItemHandler(List<SObject> so, Map<Id, Sobject>oMap){
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItem = (List<AITM_Tender_Location_Line_Item__c>) so;
        populateTenderHistoryLineItem(tenderLocationLineItem, oMap);
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

    /*******************************************PopulateDeliveryPointDetailsInTLLI***********************************************************/        
    //private Set<Id> lineItemIds = new Set<Id>();
    private Set<Id> setOfTenderLocationIds  = new Set<Id>();
    private Set<Id> alltenderIds = new Set<Id>();
    private Set<Id> setOfLineItems = new Set<Id>();

    /**
     * @description bulk before update factory method operation SObject handler
     * @param oldSo
     * @param so
     * @return void
     */
    public void beforeUpdatePopulateDeliveryPointDetailsInTLLI(Map<Id,SObject> oldSoMap, List<SObject> so){
        List<AITM_Tender_Location_Line_Item__c> locationLineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        Map<Id,AITM_Tender_Location_Line_Item__c> tenderLocationLineItemMap = (Map<Id,AITM_Tender_Location_Line_Item__c>) oldSoMap;
        for(AITM_Tender_Location_Line_Item__c lineitem :  locationLineItemList){
            if(lineitem.AITM_Tender__c != null){
               alltenderIds.add(lineitem.AITM_Tender__c); 
            }            
        }                
    }

    /**
     * @description bulk after update factory method operation SObject handler
     * @param oldSo
     * @param so
     * @return void
     */
    public void afterUpdatePopulateDeliveryPointDetailsInTLLI(List<SObject> oldSo, List<SObject> so){
        List<AITM_Tender_Location_Line_Item__c> locationLineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        List<AITM_Tender_Location_Line_Item__c> oldTenderLocationLineItem = (List<AITM_Tender_Location_Line_Item__c>) oldSo;        
        for(AITM_Tender_Location_Line_Item__c lineitem : locationLineItemList){
            setOfLineItems.add(lineitem.Id);
            setOfTenderLocationIds.add(lineitem.AITM_Tender_Location__c);
            alltenderIds.add(lineitem.AITM_Tender__c);
        }
        updateLocationStatus(setOfTenderLocationIds, alltenderIds, setOfLineItems);
    }   

    public void beforeUpdateFinalPopulateDeliveryPointDetailsInTLLI(List<SObject> so, Map<Id, SObject> oMap){
        List<AITM_Tender_Location_Line_Item__c> tenderLLI = (List<AITM_Tender_Location_Line_Item__c>) so;
            AITM_Tender__c tender = new AITM_Tender__c();            
            for(AITM_Tender_Location_Line_Item__c lineItem : tenderLLI){
                alltenderIds.add(lineItem.AITM_Tender__c);
            }
            if(alltenderIds != null && alltenderIds.size() >0 ) {
                tender = [SELECT AITM_Tender_Sector__c FROM AITM_Tender__c WHERE Id IN :alltenderIds LIMIT 1];
            }
            updateDeliveryDetails(tenderLLI, oMap, tender);
    }

    private void updateLocationStatus(Set<Id> setOfTenderLocationIds, Set<Id> alltenderIds, Set<Id> setOfLineItems) {
        List<AITM_Tender_Location_Line_Item__c> listOfLineItems = new List<AITM_Tender_Location_Line_Item__c>();
        List<AITM_Tender_Location__c> listOfTenderLocations = new List<AITM_Tender_Location__c>();
        List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
        //system.assert(false, listOfTenderLocations+ ':::'+ setOfLineItems + ':::'+ setOfTenderLocationIds + ':::' + alltenderIds);
        if (setOfTenderLocationIds != null && setOfTenderLocationIds.size() > 0) {
            listOfTenderLocations = [SELECT AITM_Status__c, (SELECT AITM_Status__c, AITM_Pricing_Basis__r.AITM_Not_Represented__c FROM AITM_Tender_Location__r WHERE Id IN :setOfLineItems AND AITM_Tender_Location__c IN :setOfTenderLocationIds 
                AND AITM_Is_Current_Round__c = true) FROM AITM_Tender_Location__c WHERE Id IN :setOfTenderLocationIds AND AITM_Tender__c IN :alltenderIds AND AITM_Is_Current_Round__c = true];
                //system.assert(false, listOfTenderLocations+ ':::'+ setOfLineItems + ':::'+ setOfTenderLocationIds + ':::' + alltenderIds);
            for(AITM_Tender_Location__c TenderLocation : listOfTenderLocations){
                for(AITM_Tender_Location_Line_Item__c item : TenderLocation.AITM_Tender_Location__r){
                    if(!item.AITM_Pricing_Basis__r.AITM_Not_Represented__c){
                        if(tenderLocation.AITM_Status__c == 'Not Represented'){
                            tenderLocation.AITM_Status__c = 'Awaiting price';
                            tenderLocations.add(tenderLocation); 
                        }
                    }
                }
            }   
            /*listOfLineItems = [SELECT AITM_Status__c, AITM_Tender_Location__c, AITM_Tender_Location__r.AITM_Status__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.AITM_Not_Represented__c 
                                  FROM AITM_Tender_Location_Line_Item__c 
                                  WHERE AITM_Tender_Location__c IN :setOfTenderLocationIds 
                                    AND AITM_Tender__c IN :alltenderIds 
                                    AND AITM_Is_Current_Round__c = true
                                    AND AITM_Pricing_Basis__r.AITM_Not_Represented__c = true Limit 1];                 
            if(listOfLineItems != null && listOfLineItems.size() == 0){
                AITM_Tender_Location__c tenderLocation = [SELECT AITM_Status__c FROM AITM_Tender_Location__c WHERE Id IN :setOfTenderLocationIds];
                if(tenderLocation.AITM_Status__c == 'Not Represented'){
                    tenderLocation.AITM_Status__c = 'Awaiting price';
                    listOfTenderLocations.add(tenderLocation);
                }
            }*/
            if(tenderLocations != null && tenderLocations.size() > 0){
                update tenderLocations;
            }
        }
    }

   /* private List<AITM_Tender_Location_Line_Item__c> getLineItems() {
        if (lineItemIds != null && lineItemIds.size() > 0) {
            return [SELECT AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender_Location__c, AITM_By_Pass_Pricing_Basis_Validation__c, AITM_Tender_Location__r.AITM_Status__c, AITM_Status__c, AITM_Pricing_Basis__c, AITM_Pricing_Basis__r.AITM_Not_Represented__c 
                   FROM AITM_Tender_Location_Line_Item__c 
                   WHERE Id IN :lineItemIds];
        }
        return new List<AITM_Tender_Location_Line_Item__c>();
    }*/

    /**
     * @description updates line items related deliverypoint field mapping
     * @param tenderLLI list of tenderlocationlineitems
     * @param oldTenderLLI list of old tenderlocationlineitems
     * @return void
     */
    public void updateDeliveryDetails(List<AITM_Tender_Location_Line_Item__c> tenderLLI, map<id,sObject> oldTenderLLI , AITM_Tender__c tender) {
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
            Map<Id, AITM_Delivery_Point__c> deliveryRecords = new Map<Id, AITM_Delivery_Point__c>([SELECT AITM_Delivery_Method__c, AITM_Product_Specification__c, AITM_Delivery_By__c, AITM_Product_Default__c, AITM_Density__c, AITM_Product__c, AITM_Additional_Refueling_Information__c, AITM_Taxes_Fees__c, AITM_Measure__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Product_Pricing_Report__c,AITM_Pricing_Basis_GA__c,AITM_Pricing_Basis_GA__r.AITM_Not_Represented__c, AITM_Pricing_Basis_CA__c, AITM_Pricing_Basis_CA__r.AITM_Not_Represented__c, AITM_Additional_Notes_Taxes_Fees__c FROM AITM_Delivery_Point__c WHERE Id =:tenderDeliveryPointSet]); 
            if(deliveryRecords.size() > 0) {
                for(AITM_Tender_Location_Line_Item__c singleLocation : tenderLLI) {
                    if(singleLocation.AITM_Location_Delivery_Point__c != null) {
                        singleLocation.AITM_Delivery_Method__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Delivery_Method__c;
                        singleLocation.AITM_Delivery_By__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Delivery_By__c;
                        singleLocation.AITM_Product_Density_for_Pricing__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Product__c;
                        singleLocation.AITM_Density__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Density__c;
                        singleLocation.AITM_Product_Default__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Product_Default__c;
                        singleLocation.AITM_Additional_Refueling_Information__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Additional_Refueling_Information__c;
                        //system.assert(false, singleLocation.AITM_Old_Taxes_Fees_Flag__c);
                        //system.assert(false, singleLocation.AITM_Taxes_Fees__c);
                        if(singleLocation.AITM_Old_Taxes_Fees_Flag__c){
                            singleLocation.AITM_Taxes_Fees__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Taxes_Fees__c;
                        }
                        singleLocation.AITM_Measure__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Measure__c;
                        singleLocation.AITM_Product_Specification__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Product_Specification__c;
                        singleLocation.AITM_Currency__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Currency__c;
                        singleLocation.AITM_Unit_Of_Measure__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Unit_Of_Measure__c;
                        singleLocation.AITM_Product_Pricing_Report__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Product_Pricing_Report__c;
                        singleLocation.AITM_Additional_Notes_Taxes_and_Fees__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Additional_Notes_Taxes_Fees__c;
                        /*if(singleLocation.AITM_By_Pass_Pricing_Basis_Validation__c){*/
                            //system.assert(false,tender.AITM_Tender_Sector__c + '::'+ deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Pricing_Basis_GA__r.AITM_Not_Represented__c);
                            if(tender.AITM_Tender_Sector__c == 'GA' || tender.AITM_Tender_Sector__c == 'Military'){
                                singleLocation.AITM_Pricing_Basis__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Pricing_Basis_GA__c;
                                //system.assert(false, deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Pricing_Basis_GA__r.AITM_Not_Represented__c);
                                if(!deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Pricing_Basis_GA__r.AITM_Not_Represented__c){
                                    singleLocation.AITM_Status__c = 'Awaiting price';
                                    /*setOfTenderLocationIds.add(singleLocation.AITM_Tender_Location__c);
                                    alltenderIds.add(singleLocation.AITM_Tender__c);
                                    setOfLineItems.add(singleLocation.Id);
                                    updateLocationStatus(setOfTenderLocationIds, alltenderIds, setOfLineItems);*/
                                }
                            }else{
                                singleLocation.AITM_Pricing_Basis__c = deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Pricing_Basis_CA__c;
                                if(!deliveryRecords.get(singleLocation.AITM_Location_Delivery_Point__c).AITM_Pricing_Basis_CA__r.AITM_Not_Represented__c){
                                    singleLocation.AITM_Status__c = 'Awaiting price';
                                    /*setOfTenderLocationIds.add(singleLocation.AITM_Tender_Location__c);
                                    alltenderIds.add(singleLocation.AITM_Tender__c);
                                    setOfLineItems.add(singleLocation.Id);
                                    updateLocationStatus(setOfTenderLocationIds, allalltenderIds, setOfLineItems);*/
                                }
                            }
                        //}*/
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


/***********************************************DefaultStraddling********************************************************************************8****/        
    private List<Id> lstOftenderIds  = new List<Id>();   
    private List<Id> locationIds = new List<Id>();
    private Id leadCustomerLineItemId;    
    private List<AITM_Tender_Location_Line_Item__c> listOfItemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
    private Map<String, AITM_Tender_Location_Line_Item__c> mapOfAccountIdWithItem = new Map<String, AITM_Tender_Location_Line_Item__c>();
    private List<String> listOfAccountIds = new List<String>();
    String taxesAndfees;
    String additionalNotes;
    Boolean isAffiliates = false;

    /**
     * @description before update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeUpdateDefaultStraddling(Map<Id, SObject> oldMap, List<SObject> so) {
        Map<Id,AITM_Tender_Location_Line_Item__c> oldLineItemMap = (Map<Id,AITM_Tender_Location_Line_Item__c>) oldMap;
        List<AITM_Tender_Location_Line_Item__c> lineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineitem : lineItemList){
              if (checkDefaultStraddling(oldLineItemMap.get(lineItem.Id), lineItem)) {
               lineItem.addError('Please uncheck default straddling checkbox in the location new offer page before editing/updating the Taxes and Fees information here.');
              }
        }         
        andFinallyDefaultStraddling();
    }

     /**
     * @description after insert operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
     */
    public void afterInsertDefaultStraddling(List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> lineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineitem : lineItemList){
            if(lineItem.AITM_Record_Type_Name__c != 'De-brief') {
               UpdateLineitemWithLocationWithStraddling(lineItem);
            }
        }            
        andFinallyDefaultStraddling();
    }

    /**
     * @description finally block called for trigger handler 
     * @param null
     * @return void
     */
    public void andFinallyDefaultStraddling() {
        List<AITM_Tender_Location__c> commonTenderLocations = getCommonTenderLocations1();
        List<AITM_Tender_Account__c> getTenderAccounts = getTenderAccounts(); 
        Boolean isAffiliatesRelationPresent = isAffiliatesPresent(getTenderAccounts);
        if(isAffiliatesRelationPresent){
            handleDefaultStraddling(commonTenderLocations, getTenderAccounts);               
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
        lstOftenderIds.add(lineItem.AITM_Tender__c);
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
    private List<AITM_Tender_Location__c> getCommonTenderLocations1() {
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
        if (lstOftenderIds != null && lstOftenderIds.size() > 0) {
            return new AITM_LocationsDao().getTenderCustomerByTenderIdAndAccount(lstOftenderIds[0], listOfAccountIds);
        }
        return new List<AITM_Tender_Account__c>();
    }

   /***********************************************InsertNewTaxesFeesRecords***********************************************************/        
    private Set<Id> setofLineitemAlreadyHavingFeeRecords = new Set<Id>();
    private Map<Id, Boolean> mapOfLineItemWithBooleanProductDefault = new Map<Id, Boolean>();
    private Decimal roundValue = 0;
    private Boolean isClone = false;
    private Boolean isParentId =false;
    private list<Id> masterTLLI = new list<Id>();

    /**
     * @description before insert trigger event
     * @param so of type SObject
     * @return void
     */
    public void beforeInsertInsertNewTaxesFeesRecords(List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> lineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineitem : lineItemList){
            if(!lineItem.AITM_Old_Taxes_Fees_Flag__c && lineItem.AITM_Record_Type_Name__c != 'De-brief'){
                lineItem.AITM_Include_Notes_in_Contract__c = true;
            }
        }        
        andFinallyInsertNewTaxesFeesRecords();
    }

    /**
     * @description before update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return void
     */
    public void beforeUpdateInsertNewTaxesFeesRecords(Map<Id,SObject> oldSo, List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> lineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        Map<Id,AITM_Tender_Location_Line_Item__c> oldLineItemMap = (Map<Id,AITM_Tender_Location_Line_Item__c>) oldSo;
        for(AITM_Tender_Location_Line_Item__c lineitem : lineItemList){
            if(!lineItem.AITM_Old_Taxes_Fees_Flag__c){
                if(lineItem.AITM_Include_Notes_in_Contract__c){
                    lineItem.AITM_Show_Additional_Notes_For_Conga__c = lineItem.AITM_Additional_Notes_Taxes_and_Fees__c;
                } else{
                    lineItem.AITM_Show_Additional_Notes_For_Conga__c = null;
                }
                //this.checkFieldsForApplyAll(oldLineItemMap.get(lineItem.Id), lineItem);
				
                if(oldLineItemMap.get(lineItem.Id).AITM_Additional_Notes_Taxes_and_Fees__c != lineItem.AITM_Additional_Notes_Taxes_and_Fees__c){
                    lineItem.AITM_Is_Additional_Notes_Updated__c = true;
                }

                if (this.checkTaxesAndFeesFieldValidation(oldLineItemMap.get(lineItem.Id), lineItem)) {
                    lineItem.addError('Taxes and Fees field cannot be updated' + '\n' + 'Please use ‘Additional Notes (Taxes & Fees)’');
                }           
            }
        }        
        andFinallyInsertNewTaxesFeesRecords();
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
     * @description after insert operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
     */
    public void afterInsertInsertNewTaxesFeesRecords(List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> lineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineitem : lineItemList){
             if(!lineItem.AITM_Old_Taxes_Fees_Flag__c && lineItem.AITM_Record_Type_Name__c != 'De-brief'){
                mapOfLineItemWithBooleanProductDefault.put(lineItem.Id, false);
                roundValue = lineItem.AITM_round__c;
                isClone = lineItem.AITM_Is_Clone__c;
                if(lineItem.AITM_ManualClonedBy__c != null){
                masterTLLI.add(lineItem.AITM_ManualClonedBy__c);
                }
                if(lineItem.id == lineItem.AITM_MIP_Parent_Id__c){
                 isParentId =true;
                   
                 }
                 else{
                  isParentId =false;
                 }
             }
        }       
        andFinallyInsertNewTaxesFeesRecords();
    }

    /**
     * @description after update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return void
     */ 
    public void afterUpdateInsertNewTaxesFeesRecords(Map<Id,SObject> oldSoMap, List<SObject> so){
        List<AITM_Tender_Location_Line_Item__c> lineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        Map<Id,AITM_Tender_Location_Line_Item__c> lineItemOldMap = (Map<Id,AITM_Tender_Location_Line_Item__c>) oldSoMap;
        for(AITM_Tender_Location_Line_Item__c lineitem : lineItemList){
            if(!lineitem.AITM_Old_Taxes_Fees_Flag__c && lineitem.AITM_Record_Type_Name__c != 'De-brief') {
              checkLineItemUpdate(lineItemOldMap.get(lineitem.Id), lineitem, mapOfLineItemWithBooleanProductDefault);
            } 
        }      
        andFinallyInsertNewTaxesFeesRecords();
    }

    /**
     * @description finally block called for trigger handler  
     * @param null
     * @return void
     */
    public void andFinallyInsertNewTaxesFeesRecords() {
        List<AITM_Tender_Location_Line_Item__c> commonTenderLocationsLineItems = this.commonTenderLocationsLineItems();
        
        List<AITM_Tender_Location_Taxes_and_Fees__c> commonTaxesAndFeesAlreadyOnLineItem = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
        if(!setofLineitemAlreadyHavingFeeRecords.isEmpty()) {
            commonTaxesAndFeesAlreadyOnLineItem = this.commonTaxesAndFeesAlreadyOnLineItem();
        }
        
        if(!commonTaxesAndFeesAlreadyOnLineItem.isEmpty()){
            AITM_TenderApplyNewTaxesAndFees.deleteExistingTaxesAndFees(commonTaxesAndFeesAlreadyOnLineItem);
        }
        
        if(!commonTenderLocationsLineItems.isEmpty()){
            if(!masterTLLI.isEmpty()){
                AITM_TenderApplyNewTaxesAndFees.cloneTenderTaxesAndFee(commonTenderLocationsLineItems,roundValue,masterTLLI);
            }
            else
            if((roundValue <=1 && masterTLLI.isEmpty())|| (!isClone  && isParentId) ){
                AITM_TenderApplyNewTaxesAndFees.attachTaxAndFeeRecordsOnLineItem(commonTenderLocationsLineItems, null);
            }
        }         
        /*  if(!commonTenderLocationsLineItems.isEmpty() && roundValue >1){
            AITM_TenderApplyNewTaxesAndFees.cloneTenderTaxesAndFee(commonTenderLocationsLineItems,roundValue) ;
        }*/        
    }
    
       /**
     * @description calculate the service level when a location is inserted     
     * @param tenderLineItemList of type List
     * @return null
     */    
     public  void afterInsertLocationDefaultServiceLevel(List<AITM_Tender_Location_Line_Item__c> tenderLineItemList) {        
        
        Id tenderId = tenderLineItemList[0].AITM_Tender__c;
        List<AITM_Tender_Location_Line_Item__c> restLineItems = new List<AITM_Tender_Location_Line_Item__c>();
         AITM_Tender__c t = [Select Name,AITM_Allow_SLA__c,AITM_Customer_Service_Level__c,AITM_Aircraft_Type__c,
         (SELECT  AITM_Tender_Location__c,AITM_Tender_Location__r.AITM_Location_Default_Service_Level__c,AITM_Tender_Location__r.AITM_Customer_Service_Level__c,AITM_Tender_Location__r.AITM_Service_Level__c,AITM_Tender_Location__r.AITM_Aircraft_Type_Serrvice__c,AITM_Location__c,AITM_Location_Delivery_Point__c,AITM_Location_Delivery_Point__r.AITM_Service_Level_Provided__c,AITM_Tender__c,AITM_Ad_hoc_Volume__c FROM AITM_Tender_Location_Line_Items__r where ID IN:tenderLineItemList AND AITM_Record_Type_Name__c != 'De-brief' AND AITM_Is_Current_Round__c = true  ORDER BY createdDate DESC)
           from AITM_Tender__c where Id =:tenderId AND AITM_Allow_SLA__c =false] ;
        
           for(AITM_Tender_Location_Line_Item__c lineItem :t.AITM_Tender_Location_Line_Items__r){
              restLineItems.add(lineItem);
           }
        if(restLineItems!=null && restLineItems.size()>0){           AITM_ServiceLevelCalculation.calculationOfServiceLevels(restLineItems,tenderId,t);
        }
       
    }



    /**
     * @description check fields for Apply ALL
     * @param lineItem of type AITM_Tender_Location_Line_Item__c
     * @param oldLineItem of type AITM_Tender_Location_Line_Item__c
     * @return void
     */
    public void checkFieldsForApplyAll(AITM_Tender_Location_Line_Item__c oldLineItem, AITM_Tender_Location_Line_Item__c lineItem) {
        String oldAdditionalTaxAndFees = String.valueOf(oldLineItem.AITM_Additional_Notes_Taxes_and_Fees__c);
        String newAdditionalTaxAndFees = String.valueOf(lineItem.AITM_Additional_Notes_Taxes_and_Fees__c);
        if ((oldAdditionalTaxAndFees != newAdditionalTaxAndFees) || (oldLineItem.AITM_Include_Taxes_and_Fees_in_Contract__c != lineItem.AITM_Include_Taxes_and_Fees_in_Contract__c) 
            || (oldLineItem.AITM_Include_Notes_in_Contract__c != lineItem.AITM_Include_Notes_in_Contract__c)) {           
                
                //lineItem.AITM_Is_Eligible_Line_for_All_Tax_Fee__c = true; 
        }else {
                //lineItem.AITM_Is_Eligible_Line_for_All_Tax_Fee__c = false; 
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

    /*******************************************TenderLocationUpdateNonRepresentedAndRecalculateFlag***********************************************************/        
   // private TenderLocationLineItemOperationalUnit operationalUnitInstance = this.getOperationalUnit(); 
    private Set<Id> notRepresentedLocations = new Set<Id>();
    private Set<Id> recalculationRequiredLocations = new Set<Id>();         
     
     /**
     * @description after insert operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
     */
    public void afterInsertTenderLocationUpdateNonRepresentedAndRecalculateFlag(List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> locationLineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineitem : locationLineItemList){
              if (!lineitem.isClone()) {
                if (isPricingBasisNotRepresented(lineitem)) {
                    notRepresentedLocations.add(lineitem.AITM_Tender_Location__c);
                }
             } 
        }
         andFinallyTenderLocationUpdateNonRepresentedAndRecalculateFlag();      
   } 

    /**
     * @description after update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return void
     */
    public void afterUpdateTenderLocationUpdateNonRepresentedAndRecalculateFlag(Map<Id,SObject> oldSoMap, List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> locationLineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        Map<Id,AITM_Tender_Location_Line_Item__c> locationLineItemMap = (Map<Id, AITM_Tender_Location_Line_Item__c>) oldSoMap;

        for(AITM_Tender_Location_Line_Item__c lineitem :  locationLineItemList){
              if (recalculationRequired(lineitem, locationLineItemMap.get(lineitem.Id))) {
                 recalculationRequiredLocations.add(lineitem.AITM_Tender_Location__c);
              }
              if (isPricingBasisNotRepresented(lineitem)) {
                 notRepresentedLocations.add(lineitem.AITM_Tender_Location__c);
              }
        }
        andFinallyTenderLocationUpdateNonRepresentedAndRecalculateFlag();
    }
    
    /**
     * @description after delete operation of trigger event
     * @param so of type SObject to hold new values
     * @return void
     */
    public void afterDeleteTenderLocationUpdateNonRepresentedAndRecalculateFlag(List<SObject> so) {
        List<AITM_Tender_Location_Line_Item__c> locationLineItemList = (List<AITM_Tender_Location_Line_Item__c>) so;
        for(AITM_Tender_Location_Line_Item__c lineitem :  locationLineItemList){
           recalculationRequiredLocations.add(lineItem.AITM_Tender_Location__c);
        }            
        andFinallyTenderLocationUpdateNonRepresentedAndRecalculateFlag();
    }
    
    /**
     * @description finally block called for trigger handler 
     * @param null
     * @return void
     */
    public void andFinallyTenderLocationUpdateNonRepresentedAndRecalculateFlag() {
        List<AITM_Tender_Location__c> commonTenderLocations = getCommonTenderLocations();
        updateRecalculationFlag(commonTenderLocations);
        updateNonRepresentedLocationStatus(commonTenderLocations);
            
        if (commonTenderLocations.size() > 0) {
            Database.update(commonTenderLocations, false);
        }
    }   
   
    /**
     * @description returns true if tenderlocationlineitem recordtype is equal to 
     * operationalUnitInstance default record type and pricingbasis is not represented else false
     * @param tenderLocationLineItem of type AITM_Tender_Location_Line_Item__c
     * @return boolean
     */
    private Boolean isPricingBasisNotRepresented(AITM_Tender_Location_Line_Item__c tenderLocationLineItem) {
        return tenderLocationLineItem.RecordTypeId == operationalUnitInstance.TENDER_LOCATION_LINE_ITEM_DEFAULT_RECORDTYPE_ID
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
        if (recalculationRequiredLocations.size() > 0 || notRepresentedLocations.size() > 0){
            List<Id> listtenderLocationIds = new List<Id>(recalculationRequiredLocations);
            listtenderLocationIds.addAll(notRepresentedLocations);            
            return new AITM_LocationsDao().getTenderLocationsByIds(listtenderLocationIds);
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
                    tenderLocation.AITM_Status__c = operationalUnitInstance.NOT_REPRESENTED_STATUS;
                }
            }
        }            
    }
}