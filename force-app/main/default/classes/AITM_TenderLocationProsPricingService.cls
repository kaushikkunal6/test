/***********************************************************************************************
 * @author           Sushant
 * @date             01/June/2020
 * @group            AirBP
 * @description      Implementation of Queueable interface and Insert new TLLI implementing BPG framework
 *************************************************************************************/

public with sharing class AITM_TenderLocationProsPricingService implements Queueable, Database.AllowsCallouts {
    private static final String PRICING_INFORMATION_REQUEST = 'Pricing Information';
    private static final String TARGET_PRICE_REQUEST = 'Target Price';
    private static final Integer MAX_CALLOUTS_PER_ONE_FUTURE = 5;
    private Set<Id> scopeIds;
    private String requestType;
    private Set<Id> recordsToSend = new Set<Id>();
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

    /**
     * @description gets the instance of AITM_TenderLocationPROSPricingService
     * @param null
     * @return AITM_TenderLocationPROSPricingService class object
     */
    public static AITM_TenderLocationProsPricingService getInstance() {
        if (instance == null) {
            instance = new AITM_TenderLocationProsPricingService(null, null);
        }
        return instance;
    }

    public AITM_TenderLocationProsPricingService(){}
        
    private static AITM_TenderLocationProsPricingService instance;
    
    /**
     * @description default constructor
     * @param scopeIds
     * @param requestType
     */
    public AITM_TenderLocationProsPricingService(Set<Id> scopeIds, String requestType) {
        this.scopeIds = scopeIds;
        this.requestType = requestType;
    }

    /**
     * @description execute the queueable context
     * @param null
     * @return void
     */
    public void execute(QueueableContext context) {
     AITM_SwitchProsCalloutApi__c checkPROSTypeToCall = AITM_SwitchProsCalloutApi__c.getValues('MuleProsCalloutClass');        
     
        if (scopeIds.size() > MAX_CALLOUTS_PER_ONE_FUTURE) {
            Set<Id> partialSet = new Set<Id>();
            for (Id locationLineItemId : scopeIds) {
                partialSet.add(locationLineItemId);
                if (partialSet.size() >= MAX_CALLOUTS_PER_ONE_FUTURE) {
                    break;
                }
            }
            if(checkPROSTypeToCall.AITM_OldProsCallout__c){
              this.retrievePricingInformation(partialSet, requestType);  
            }
            if(checkPROSTypeToCall.AITM_NewProsCallout__c){
              this.retrieveNewProsPricingInformation(partialSet);
            }            
            scopeIds.removeAll(partialSet);
            System.enqueueJob(new AITM_TenderLocationPROSPricingService(scopeIds, requestType));
        } else {
            if(checkPROSTypeToCall.AITM_OldProsCallout__c){
              this.retrievePricingInformation(scopeIds, requestType);  
            }
            if(checkPROSTypeToCall.AITM_NewProsCallout__c){
              this.retrieveNewProsPricingInformation(scopeIds);
            }
        }
    }
    
    
    /**
     * @description retrieve Pricing Information and update Line Item for OLDPROSSOAPCallout
     * @param recordIds
     * @param requestName
     * @return void
     */
    public void retrievePricingInformation(Set<Id> recordIds, String requestName) {
        List<AITM_Tender_Location_Line_Item__c> lineItems = new List<AITM_Tender_Location_Line_Item__c>();
        AITM_PricingServiceRepository.PricingService pricingService = AITM_PricingServiceRepository.getInstance().getPricingService();
        for (AITM_Tender_Location_Line_Item__c lineItem : new AITM_LocationsDao.TenderLocationLineItemsDao().getLineItemsWithPricingInformation(recordIds)) {
            if (requestName == AITM_TenderLocationProsPricingService.TARGET_PRICE_REQUEST) {
                lineItems.add((AITM_Tender_Location_Line_Item__c) pricingService.retrieveTargetPrice(lineItem));
            } else {
                lineItems.add((AITM_Tender_Location_Line_Item__c) pricingService.retrievePricingInformation(lineItem));
            }
        }
        Database.update(lineItems, false);
    }
    
    /**
     * @description retrieve Pricing Information and update Line Item as per NEWPROSRestCallout
     * @param recordIds
     * @param requestName
     * @return void
     */
    public void retrieveNewProsPricingInformation(Set<Id> recordIds) {        
        List<AITM_Tender_Location_Line_Item__c> lineItems = new List<AITM_Tender_Location_Line_Item__c>();
        AITM_PricingServiceMulePROSRepository repositoryInstance = new AITM_PricingServiceMulePROSRepository();
        if(!Test.isRunningTest()){
          for(AITM_Tender_Location_Line_Item__c lineItem : new AITM_LocationsDao.TenderLocationLineItemsDao().getLineItemsWithPricingInformation(recordIds)) {
            lineItems.add((AITM_Tender_Location_Line_Item__c) repositoryInstance.retrievePricingInformation(lineItem));
          }    
        }
        try{
            Database.SaveResult[] results = Database.update(lineItems, false);
        }catch(DMLException ex) {
            System.debug('exception' + ex.getMessage());
        }    
    }      

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
    if (recordsToSend.size() > 0) {
       sendRequest(recordsToSend, AITM_TenderLocationProsPricingService.TARGET_PRICE_REQUEST);
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
          if (recordsToSend.size() > 0) {
           this.sendRequest(recordsToSend, AITM_TenderLocationProsPricingService.PRICING_INFORMATION_REQUEST);
          }
      }
    } 
  }  
    
  /**
   * @description Tender Location Line Item Pricing System call for all required fields
   * @param scopeLineItemOld
   * @param scopeLineItem
   * @return Boolean true
   */
 /* private Boolean pricingSystemCallRequired(AITM_Tender_Location_Line_Item__c scopeLineItemOld, AITM_Tender_Location_Line_Item__c scopeLineItem) {
    Boolean allRequiredFieldsAvailable = true;

    for (String requiredField : this.REQUIRED_FIELDS_PROS_CALL.keySet()) {
      allRequiredFieldsAvailable = allRequiredFieldsAvailable && scopeLineItem.get(requiredField) != null;
      if (!allRequiredFieldsAvailable) {
        break;
      }
    }
    return allRequiredFieldsAvailable;
  }*/

  /**
   * @description Tender Location Line Item get all required fields for error
   * @param scopeLineItem
   * @return String
   */
  public String getRequiredFieldsError(AITM_Tender_Location_Line_Item__c scopeLineItem) {
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
    if (recordIds.size() > 0) {     
      System.enqueueJob(new AITM_TenderLocationPROSPricingService(recordIds, requestName));      
    }
  }
    
}