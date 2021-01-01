/***********************************************************************************************
 * @author           George
 * @date             05/Oct/2017
 * @group            AirBP
 * @description      Used for Pre-Populating the Tender Location record after Location is added.
 
 * history
 * 05/Oct/2017       George          Created
 * 07/March/2018     Ravi Pamidi     Modified - AR-2523 Removed AITM_Currency_Pricing_Basis__c fields 
 *                                   as it was converted as formula fields.
 * 12/June/2018      srnandan        Modified - AR-3361 - Added AITM_Currency__c in LOCATIONS_PREPOPULATED_FIELDS
 *                                   corrected the mapping replacing old field AITM_Days__c on lineitem with new field AITM_Credit_Days__c 
 * 18/June/2018      srnandan        Modified - AR-3361 - Added condition for default currency for the method populateLocationFields
 *                                   and UOM for USG
 * 23/August/2018    Ravi            Modified - Added with sharing to the main class for sonarqube fixes
 * 29/December/2018  srnandan        Modified - AR-4875 line item owner changes to methods populateLocationManagers
 * 02/Jan/2019        Shweta         Modified - populateLocationManagers to populate correct LM as the owner of the tender location line Item
 * 02/January/2019   srnandan        Modified - populateLocationManagers to avoid duplicate ids updating tenderlocation 
 * 08/Jan/2019       Anusha          Modified - populateLocationManagers added TLLI fields to get data from LocationDeliveryPoint
 * 24/January/2019   srnandan        Modified - AR-4913 added condition to prepopulate delivery point on TLLI only on default recordtype
 * 31/January/2019   Shweta          Modified - AR-4955/AR-4940 Updated the method populateLocationManagers for clone 
 * 04/March/2019     Shweta          Modified - AR-4620 Updated the method populateLocationManagers to get CA/GA delegates
 * 11/March/2019     Shweta          Modified - AR-4999 Updated the method populateLocationManagers to remove updating of the TLLI fields
 * 02/April/2019     Ravi            Modified - AR-5028 - commented Currency and UOM
 * 02/May/2019		 Saravan		 Modified - AR-5147 - Created a new set to populate pricing delegates to share the TLLI
 * 10/Jun/2019		 Saravan		 Modified - AR-5235 - Updated the method populateLocationManagers to reinitialize 
 * 									 lineItemPricingDelegates set instead of clear
 * 12/Sep/2019		 Saravan		 Modified - 704939 - Updated the method populateLocationManagers to create delegates sharing records
 * 									 in next rounds		
 * 30/Sep/2019		 Saravan         Workitem(684962) - Modified populateLocationManagers method to assign GA pricing Manager, GA Delegates
 * 									 etc for Military sector
 * 22/Apr/2020		 Saravan         Modified - 108793 Created the new method populateParentId to update Parent Id for MIP feed
 * 01/June/2020      Sushant         Modified - Modified the methods by adding parameters populateParentId,populateUserRelatedFields,prePopulateFields
 * 10/Oct/2020       Saravan         Modified - For PBI 669532 modifiedcode to update location manager and pricing responsibility
*************************************************************************************************************************/
public with sharing class AITM_TenderLocationPrePopulationHandler {
    private Set<Id> locationIds;
    private Set<Id> accountIds;
    private Set<Id> tenderIds;
    public static final ID ID_TLLI_RECORD_TYPE_DEFAULT = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
    private static final String NOT_REPRESENTED_STATUS = 'Not Represented';
    public static final String SHARING_REASON = 'Sharing_To_Pricing_Delegates__c';
    private final Map<String, String> LOCATIONS_PREPOPULATED_FIELDS = new Map<String, String> {
        //'AITM_Unit_Of_Measure__c' => 'AITM_Unit_Of_Measure__c',
        //'AITM_Currency__c' => 'AITM_Currency__c',
        'AITM_Location_Size__c' => 'AITM_Location_Size__c',
        'AITM_Location_Strategy__c' => 'AITM_Location_Strategy__c'
    };
    private static final Set<String> LABP_AMPROFILE = new Set<String>{'Air_TMLABP','Air_TMLABPLogin'};
    private static final String CURRENT_USER_PROFILE = new AITM_UsersDao().getProfileName(UserInfo.getUserId());
    
    /**
     * @description This is a constructor for the class AITM_TenderLocationPrePopulationHandler
     * @param No Parameters
     * @return No return
     */
    public AITM_TenderLocationPrePopulationHandler() {
        locationIds = new Set<Id>();
        accountIds = new Set<Id>();
        tenderIds = new Set<Id>();
    }
    
    /**
     * @description This method is to Populate User Related Fields.
     * @param No Parameters
     * @return void
     */
    public void populateUserRelatedFields(List<Sobject> listOfsobjects) {
        List<AITM_Tender_Location_Line_Item__c> lstOflineItems = (List<AITM_Tender_Location_Line_Item__c>) listOfsobjects;
        if (!System.isFuture()) {
            this.populateLocationManagers(lstOflineItems);
        }
    }
    
   /**
     * @description This method is to Populate User Related Fields.
     * @param No Parameters
     * @return void
     */
    public void populateUserRelatedFields() {
        if (Trigger.isAfter && Trigger.isInsert && !System.isFuture()) {
            this.populateLocationManagers(Trigger.new);
        }
    }
    
    /**
     * @description This method is to Populate Parent Id Fields.
     * @param No Parameters
     * @return void
     */
    public void populateParentId(List<Sobject> listOfsobjects) {
        Set<Id> tenderLocationLIIds = new Set<Id>();
        if (!System.isFuture()){      
            for (SObject lineItemSObject : listOfsobjects){
                AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) lineItemSObject;  
                if((!lineItem.isClone() || lineItem.AITM_Is_Clone__c) && lineItem.AITM_Parent_TLLI_Id__c == NULL && lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT){                   
                    tenderLocationLIIds.add(lineItem.Id);
                } 
            }      
            List<AITM_Tender_Location_Line_Item__c> tlliList = new List<AITM_Tender_Location_Line_Item__c>([Select Id, AITM_Parent_TLLI_Id__c from AITM_Tender_Location_Line_Item__c where Id in :tenderLocationLIIds]);    
            for(AITM_Tender_Location_Line_Item__c tlli:tlliList){
                tlli.AITM_Parent_TLLI_Id__c = tlli.Id;
            }
            if(!tlliList.isEmpty()) {
                update tlliList;    
            }    
        }      
    }

    /**
     * @description This method is to Populate Parent Id Fields.
     * @param No Parameters
     * @return void
     */
    public void populateParentId() {
        Set<Id> tenderLocationLIIds = new Set<Id>();
        if (Trigger.isAfter && Trigger.isInsert && !System.isFuture()) {
            
            for (SObject lineItemSObject : Trigger.New) {
                
                AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) lineItemSObject;  
                if((!lineItem.isClone() || lineItem.AITM_Is_Clone__c) && lineItem.AITM_Parent_TLLI_Id__c == NULL && lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT){
                    tenderLocationLIIds.add(lineItem.Id);  
                }
            }  
            
            List<AITM_Tender_Location_Line_Item__c> tlliList = new List<AITM_Tender_Location_Line_Item__c>([Select Id, AITM_Parent_TLLI_Id__c from AITM_Tender_Location_Line_Item__c where Id in :tenderLocationLIIds]);
            
            for(AITM_Tender_Location_Line_Item__c tlli:tlliList){
                tlli.AITM_Parent_TLLI_Id__c = tlli.Id;
            }
            if(!tlliList.isEmpty()) {
                update tlliList;
            }
            
        }      
        
    }    

    /**
     * @description This method is to Collect Line Items
     * @param lineItem
     * @return void
     */
    public void collect(AITM_Tender_Location_Line_Item__c lineItem) {
        locationIds.add(lineItem.AITM_Location__c);
        accountIds.add(lineItem.AITM_Account__c);
        tenderIds.add(lineItem.AITM_Tender__c);
    }
    
    /**
     * @description This method is to Prepopulate fields in Tender Account.
     * @param No Parameters
     * @return Void
     */
    public void prePopulateFields(List<Sobject> listOfsobjects) {
        Map<Id, AITM_Location__c> locations = new AITM_LocationsDao().getLocationsWithTenderLocationInfoByIds(locationIds);
        Map<String, AITM_Tender_Account__c> mpTenderAccs = new AITM_AccountDao().getTenderAccountsWithTenderAndAccountIds(tenderIds, accountIds);
        for (SObject lineItemSObject : listOfsobjects) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) lineItemSObject;
            if(!lineItem.isClone() && lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT){
                populateLocationFields(lineItem, locations.get(lineItem.AITM_Location__c));
                populateTenderAccountFields(lineItem, mpTenderAccs.get(lineItem.AITM_Account__c+'-'+lineItem.AITM_Tender__c));
            }
        }
    }
    
    /**
     * @description This method is to Prepopulate fields in Tender Account.
     * @param No Parameters
     * @return Void
     */
    public void prePopulateFields() {
        if (Trigger.isBefore && Trigger.isInsert) {
            Map<Id, AITM_Location__c> locations = new AITM_LocationsDao().getLocationsWithTenderLocationInfoByIds(locationIds);
      Map<String, AITM_Tender_Account__c> mpTenderAccs = new AITM_AccountDao().getTenderAccountsWithTenderAndAccountIds(tenderIds, accountIds);
            for (SObject lineItemSObject : Trigger.New) {
                AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) lineItemSObject;
                if(!lineItem.isClone() && lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT){
                    populateLocationFields(lineItem, locations.get(lineItem.AITM_Location__c));
                    populateTenderAccountFields(lineItem, mpTenderAccs.get(lineItem.AITM_Account__c+'-'+lineItem.AITM_Tender__c));
                }
            }
        }
    }

    /**
     * @description This method is to Populate Location Managers.
     * @param List of lineItems 
     * @return void
     */
    private void populateLocationManagers(List<AITM_Tender_Location_Line_Item__c> lineItems) {
        
        List<AITM_Tender_Location_Line_Item__c> reselectedLineItems = new List<AITM_Tender_Location_Line_Item__c>();
        List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
        Set<Id> tenderLocationIds = new Set<Id>();
        Set<String> pricingDelegates = new Set<String>();
        Set<String> lineItemPricingDelegates;
        Map<Id,Set<String>> pricingDelegatesEmailMap = new Map<Id,Set<String>>();
        
        for (AITM_Tender_Location_Line_Item__c lineItem : new AITM_LocationsDao().getTenderLocationWithSectorInformation(lineItems)) {
            lineItem.AITM_Round__c = lineItem.AITM_Tender_location__r.AITM_Round__c;
            if(lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT){
                lineItem.AITM_Record_Type_Name__c = 'Default';
            }
            lineItemPricingDelegates = new Set<String>();
            if (lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'CA' && lineitem.AITM_Location_Delivery_Point__c != null && (lineItem.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'CA' || lineItem.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'BOTH')) {
                String delegatesCA = lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c; 
                if(delegatesCA != null){
                    pricingDelegates.addAll(delegatesCA.toLowerCase().split(';'));
                    lineItemPricingDelegates.addAll(delegatesCA.toLowerCase().split(';'));
                }      
                pricingDelegatesEmailMap.put(lineitem.Id,lineItemPricingDelegates);
                if(lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT && lineItem.AITM_Is_Clone__c == false) { 
                    if (lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c != null) {
                        lineItem.OwnerId = lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c;
                    }else if(lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c != null) {
                        lineItem.OwnerId = lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c;
                    }else {
                        //lineItem.OwnerId = lineItem.AITM_Location__r.OwnerId;
						lineItem.OwnerId=lineItem.AITM_Tender__r.OwnerId;
                    }
                }
            } else if(lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'GA' && lineitem.AITM_Location_Delivery_Point__c != null && (lineItem.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'GA' || lineItem.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'BOTH')){
                String delegatesGA = lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c;
                if(delegatesGA != null){
                    pricingDelegates.addAll(delegatesGA.toLowerCase().split(';'));
                    lineItemPricingDelegates.addAll(delegatesGA.toLowerCase().split(';'));
                } 
                pricingDelegatesEmailMap.put(lineitem.Id,lineItemPricingDelegates);
                if(lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT && lineItem.AITM_Is_Clone__c == false) { 
                    if (lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c != null) {
                        lineItem.OwnerId = lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c;                        
                    } else if(lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c != null) {
                        lineItem.OwnerId = lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c;
                    } else {
                        //lineItem.OwnerId = lineItem.AITM_Location__r.OwnerId;
						lineItem.OwnerId=lineItem.AITM_Tender__r.OwnerId;
                    }
                }
            } else if(lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'Military' && lineitem.AITM_Location_Delivery_Point__c != null && (lineItem.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'GA' || lineItem.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'BOTH')){
                String delegatesGA = lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c;
                if(delegatesGA != null){
                    pricingDelegates.addAll(delegatesGA.toLowerCase().split(';'));
                    lineItemPricingDelegates.addAll(delegatesGA.toLowerCase().split(';'));
                } 
                pricingDelegatesEmailMap.put(lineitem.Id,lineItemPricingDelegates);
                if(lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT && lineItem.AITM_Is_Clone__c == false) { 
                    if (lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c != null) {
                        lineItem.OwnerId = lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c;                        
                    } else if(lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c != null) {
                        lineItem.OwnerId = lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c;
                    } else {
                        //lineItem.OwnerId = lineItem.AITM_Location__r.OwnerId;
						lineItem.OwnerId=lineItem.AITM_Tender__r.OwnerId;
                    }
                }
            } else {
                if(lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT && lineItem.AITM_Is_Clone__c == false) { 
                    //lineItem.OwnerId = lineItem.AITM_Pricer_No_Default_Delivery_Points__c;
					lineItem.OwnerId=lineItem.AITM_Tender__r.OwnerId;
                }
            }
            if(lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT && lineItem.AITM_Is_Clone__c == false) {  
                if(lineItem.AITM_Tender_Location__c != null) {
                    AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c();
                    tenderLocation.Id = lineitem.AITM_Tender_Location__c;
					if(!lineItem.AITM_Is_Pricing_Basis_Not_Represented__c){
						tenderLocation.AITM_Location_Manager__c = lineItem.OwnerId;
					}
                    if(!tenderLocationIds.contains(tenderLocation.Id)) {
                        tenderLocations.add(tenderLocation);   
                    }
                    tenderLocationIds.add(tenderLocation.Id);    
                }
            }
            reselectedLineItems.add(lineItem);
        }
        Map<String,String> lineItemsUserMap = getLineItemsUserDelegatesIDMap(pricingDelegates, pricingDelegatesEmailMap);
        List<Id> lineItemIds = new List<Id>();
        lineItemIds.addAll(pricingDelegatesEmailMap.keyset()); 
        
        if(!reselectedLineItems.isEmpty()) {
            Database.SaveResult[] srList = Database.update(reselectedLineItems, false);  
             If(LABP_AMPROFILE.contains(CURRENT_USER_PROFILE)){
                for(AITM_Tender_Location_Line_Item__c l:reselectedLineItems){             
                String s = String.valueOf(l.Id) + '/' + String.valueOf( l.AITM_Tender__r.OwnerId);
                 lineItemsUserMap.put(s, l.AITM_Tender__r.OwnerId);                            
               }
            }         
                       
            AITM_LightningSharing.grantPermissionForDelegatesWithID(lineItemsUserMap,'Edit');
        }

        if(!tenderLocations.isEmpty()) {
        	update tenderLocations;    
        }
    }

    /**
     * @description This method is to Populate Location Fields.
     * @param Object paramater lineItem and location
     * @return void
     */
    private void populateLocationFields(AITM_Tender_Location_Line_Item__c lineItem, AITM_Location__c location) {
        for (String lineItemFieldName : LOCATIONS_PREPOPULATED_FIELDS.keySet()) {
            if (lineItem.get(lineItemFieldName) == null || lineItem.get(lineItemFieldName) == getDefaultLineItemCurrency()) {
                lineItem.put(lineItemFieldName, location.get(LOCATIONS_PREPOPULATED_FIELDS.get(lineItemFieldName)));
            } else if (lineItem.get(lineItemFieldName) == null || lineItem.get(lineItemFieldName) == getDefaultLineItemUnitOfMeasure()) {
                lineItem.put(lineItemFieldName, location.get(LOCATIONS_PREPOPULATED_FIELDS.get(lineItemFieldName)));
            }else if (lineItem.get(lineItemFieldName) == null) {
                lineItem.put(lineItemFieldName, location.get(LOCATIONS_PREPOPULATED_FIELDS.get(lineItemFieldName)));
            }
        }
    }
    
    /**
     * @description gets default line item currency
     * @param null
     * @return String
     */
    @testVisible
    private String getDefaultLineItemCurrency() {
        String defaultVal = '';
        Schema.DescribeFieldResult F = AITM_Tender_Location_Line_Item__c.AITM_Currency__c.getDescribe();
        List <Schema.PicklistEntry> pickVals = F.getPicklistValues();
        for (Schema.PicklistEntry pickEntry: pickVals) {
            if (pickEntry.isDefaultValue()) {
                defaultVal = pickEntry.getValue();
                return defaultVal;
            }
        }
        return defaultVal;
    }

    /**
     * @description gets default line item Unit Of Measure
     * @param null
     * @return String
     */
    @testVisible
    private String getDefaultLineItemUnitOfMeasure() {
        String defaultVal = '';
        Schema.DescribeFieldResult F = AITM_Tender_Location_Line_Item__c.AITM_Unit_Of_Measure__c.getDescribe();
        List <Schema.PicklistEntry> pickVals = F.getPicklistValues();
        for (Schema.PicklistEntry pickEntry: pickVals) {
            if (pickEntry.isDefaultValue()) {
                defaultVal = pickEntry.getValue();
                return defaultVal;
            }
        }
        return defaultVal;
    }
    
    /**
     * @description This method is used to Populate Account Fields.
     * @param lineItem from Tender Location Line Item Obejct and customer from Account
     * @return void
     */
   @testVisible private void populateAccountFields(AITM_Tender_Location_Line_Item__c lineItem, Account customer) {
        if (lineItem.AITM_Credit_Days__c == null) {
            lineItem.AITM_Credit_Days__c = customer.AITM_Credit_Days1__c;
        }
        if (lineItem.AITM_Invoice_Frequency__c == null) {
            lineItem.AITM_Invoice_Frequency__c = customer.AITM_Invoice_Frequency__c;
        }
    }
	
    /**
     * @description This method is used to populate Tender Account Fields.
     * @param lineItem from Tender Location Line Item and tenderCustomer from Tender Account object.
     * @return void
     */
    private void populateTenderAccountFields(AITM_Tender_Location_Line_Item__c lineItem, AITM_Tender_Account__c tenderCustomer) {
        if(tenderCustomer != null)
        {    
            if (lineItem.AITM_Credit_Days__c == null) {
               lineItem.AITM_Credit_Days__c = tenderCustomer.AITM_Credit_Days1__c;
            }
            if (lineItem.AITM_Invoice_Frequency__c == null) {
                lineItem.AITM_Invoice_Frequency__c = tenderCustomer.AITM_Invoice_Frequency__c;
            }
            if (lineItem.AITM_Payment_Currency__c != null) {
                lineItem.AITM_Payment_Currency__c = tenderCustomer.AITM_Payment_Currency__c;
            }
            if (lineItem.AITM_Security_Type__c == null) {
                lineItem.AITM_Security_Type__c = tenderCustomer.AITM_Security_Type__c;
            }
            if (lineItem.AITM_Security_Text_on_Offer__c == null) {
                lineItem.AITM_Security_Text_on_Offer__c = tenderCustomer.AITM_Security_Text_on_Offer__c;
            }
        }    
    }
    
    /**
     * @description This method is used to find out Pricing Basis Not Represented to true or false.
     * @param lineItem
     * @return Returns Boolean for AITM_Tender_Location_Line_Item__c
     */
    public Boolean isPricingBasisNotRepresented(AITM_Tender_Location_Line_Item__c lineItem) {
        return lineItem.RecordTypeId == ID_TLLI_RECORD_TYPE_DEFAULT && lineItem.AITM_Is_Pricing_Basis_Not_Represented__c;
    }
    
    public Map<Id, Set<String>> getLineItemsUserDelegatesMap(Set<String> pricingDelegates, Map<Id, Set<String>> pricingDelegatesEmailMap) {
        Map<Id, String> pricingUserEmailMap = new AITM_UsersDao().getPricingUsersAndDelegates(pricingDelegates);
        Map<Id, Set<String>> lineItemsUserMap = new Map<Id, Set<String>>();
        for(Id tenderLocationLineItemId : pricingDelegatesEmailMap.keySet()){
        	Set<String> delegatesEmailAddress = pricingDelegatesEmailMap.get(tenderLocationLineItemId);
            Set<String> userIdSet = new Set<String>();
            for(Id userId : pricingUserEmailMap.keySet()) {
                if(delegatesEmailAddress.contains(pricingUserEmailMap.get(userId))) {
                    userIdSet.add(userId);    
                }
            }
            lineItemsUserMap.put(tenderLocationLineItemId, userIdSet);
        }
        return lineItemsUserMap;
    }
    
    public Map<String,String> getLineItemsUserDelegatesIDMap(Set<String> pricingDelegates, Map<Id,Set<String>> pricingDelegatesEmailMap) {
        Map<Id, String> pricingUserEmailMap = new AITM_UsersDao().getPricingUsersAndDelegates(pricingDelegates);
        Map<String,String> lineItemsUserMap = new Map<String,String>();
        String result = '';
        for(Id tenderLocationLineItemId : pricingDelegatesEmailMap.keySet()){
        	Set<String> delegatesEmailAddress = pricingDelegatesEmailMap.get(tenderLocationLineItemId);            
             for(Id userId : pricingUserEmailMap.keySet()) {
                if(delegatesEmailAddress.contains(pricingUserEmailMap.get(userId))) {
                    //userIdSet.add(userId);
                     result = String.valueOf(tenderLocationLineItemId) + '/' + String.valueOf(userId);
                     lineItemsUserMap.put(result,userId);

                }
             }       
         }
        return lineItemsUserMap;
    }
}