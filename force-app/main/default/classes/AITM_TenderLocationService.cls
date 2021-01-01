/**
 * Created by Aru Singhal on 23-10-2020.
 * @description Service class to work with UI Screens functionality.
 */

public with sharing class AITM_TenderLocationService {
    
    /**
     * @description gets Taxes And Fees
     * @param sObjectName sobject name
     * @param lineID of type Id
     * @return List<SObject>
     */  
    @AuraEnabled(cacheable=true)
    public static List<SObject> getTaxesAndFees(Id lineId, String sObjectname) {
        String parameter = 'Tender_Location_Line_Item_Id__c';
        List<SObject> queryResult = queryRecordsById(
                                        AITM_Tender_Location_Taxes_and_Fees__c.SObjectType, 
                                        fieldsToQuery(sObjectname), 
                                        lineId, 
                                        parameter
                                    );
        return queryResult;
    }
    
    /**
     * @description gets Records By Id
     * @param SObjectType of SObjectType
     * @param fieldsToQuery of type Set<String>
     * @param lineID of type Id
     * @param parameter of type String
     * @return List<SObject>
     */
    public static List<SObject> queryRecordsById(SObjectType sObjectType, Set<String> fieldsToQuery, Id lineId, String parameter) {
        if (fieldsToQuery == null || fieldsToQuery.isEmpty()) fieldsToQuery.add('Id');
        return Database.query(
            String.format(
                'SELECT {0} FROM {1} WHERE '+ parameter + '=: lineId',
                new List<String>{
                    String.join(new List<String>(fieldsToQuery), ','),
                    String.valueOf(sObjectType.getDescribe().getName())
                }
            )
        );
    }
    
    /**
     * @description gets all fields
     * @param sObjectName sobject name
     * @return Set<String>
     */
    public static Set<String> fieldsToQuery(String sObjectname){
        return Schema.getGlobalDescribe().get(sObjectname).getDescribe().SObjectType.getDescribe().fields.getMap().keySet();
    }
    
     /**
     * @description saves T&F
     * @param List<AITM_Tender_Location_Taxes_and_Fees__c> of type string
     * @param List<AITM_Tender_Location_Taxes_and_Fees__c>
     * @param lineId of type Id
     * @param notes of type String
     * @param taxesNotes of type String
     * @param includeTFContract of type Boolean
     * @param includeNotesContract of type Boolean
     * @return null
     */ 
    @AuraEnabled
    public static void saveTaxesAndFees(List<AITM_Tender_Location_Taxes_and_Fees__c> updatedFees, List<AITM_Tender_Location_Taxes_and_Fees__c> newFees, ID lineId, String notes, String taxesNotes, Boolean includeTFContract, Boolean includeNotesContract) {
        try{  
            List<AITM_Tender_Location_Taxes_and_Fees__c> deletedFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>(); 
            String sobjectName = 'AITM_Tender_Location_Taxes_and_Fees__c';      
            List<AITM_Tender_Location_Line_Item__c> updateNotesOnLines = new List<AITM_Tender_Location_Line_Item__c>();
            updateNotesOnLines.add(
                new AITM_Tender_Location_Line_Item__c(
                    Id = lineId,
                    AITM_Taxes_Fees__c = taxesNotes,
                    AITM_Additional_Notes_Taxes_and_Fees__c = notes,
                    AITM_Include_Taxes_and_Fees_in_Contract__c = includeTFContract,
                    AITM_Include_Notes_in_Contract__c = includeNotesContract
                )
            );
            new AITM_WithoutSharing().doUpdate(updateNotesOnLines);    
            AITM_MassEditRLCtrl.saveRecords(sobjectName, newFees, updatedFees , deletedFees, newFees);
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }       
    }
    
    /**
     * @description updates TLLI
     * @param selectedLOI of type string
     * @param locID of type Id
     * @return null
     */ 
    @AuraEnabled
    public static void updateAllLinesWithMasterLOI(String locId, String selectedLOI) {
        try{  
            Map<Id, AITM_Tender_Location_Line_Item__c> mapOfLineItems = new Map<Id, AITM_Tender_Location_Line_Item__c>();   

            mapOfLineItems = new Map<Id, AITM_Tender_Location_Line_Item__c>((List<AITM_Tender_Location_Line_Item__c>)fetchLineItems(locId));
            
            for(AITM_Tender_Location_Line_Item__c line: mapOfLineItems.values()){
                line.AITM_Location_Manager_Level_of_Interest__c = selectedLOI;
            }
            
            new AITM_WithoutSharing().doUpdate(mapOfLineItems.values());    
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }       
    }
    
    public without sharing class AITM_WithoutSharing {
        public void doInsert(List<SObject> records) {
            insert records;
        }

        public void doUpdate(List<SObject> records) {
            update records;
        }
        
        public void doUpsert(List<SObject> records) {
            upsert records;
        }

        public void doDelete(Id recordId) {
            Database.delete(recordId);
        }
    }
    
     /**
     * @description gets all Line Items
     * @param locId of type Id
     * @return Set<String>
     */
    public static List<AITM_Tender_Location_Line_Item__c> fetchLineItems(Id locId) {
         return [
            SELECT
                Id, Name,
                RecordType.DeveloperName, 
                AITM_Tender__c,
                AITM_Product_Density_for_Pricing__c,
                AITM_Density__c, 
                AITM_Level_Of_Interest__c,
                AITM_Credit_Days__c,
                AITM_Invoice_Frequency__c, 
                AITM_Exchange__c,
                AITM_Measure__c, 
                AITM_Credit_Rating__c,
                AITM_Product_Default__c,
                AITM_Account__c, 
                AITM_Delivery_Method__c,
                AITM_Account__r.AITM_Credit_Days1__c,
                AITM_Account__r.AITM_Invoice_Frequency__c,
                AITM_Account__r.AITM_Credit_Rating__c,
                AITM_Location_Delivery_Point__r.Name,
                AITM_Location_Delivery_Point__c,
                AITM_Last_Tender_Result__c,
                AITM_Currency__c,
                AITM_Location_Manager_Level_of_Interest__c,
                AITM_Offered_Differential__c,
                AITM_Unit_Of_Measure__c,
                AITM_Requested_Volume_USG__c,
                AITM_Tender_Location__r.AITM_Service_Level__c
            FROM AITM_Tender_Location_Line_Item__c
            WHERE AITM_Tender_Location__c = :locId
            ORDER BY AITM_Requested_Volume_USG__c DESC
        ];
    }
    
    /**
     * @description gets all Customers
     * @param tendorID of type Id
     * @return List<AITM_Tender_Account__c>
     */  
    public static List<AITM_Tender_Account__c> fetchCustomersOrderByCustomerAffiliates(Id tendorId) {
         return [
            SELECT
                Id, Name, 
                AITM_Tender__c,
                AITM_Affiliates_Account__c,
                AITM_Affiliates_Account__r.Name,
                AITM_Account__c, 
                AITM_Account__r.Name
            FROM AITM_Tender_Account__c
            WHERE AITM_Tender__c = :tendorId
            AND AITM_Affiliates_Account__c != null
            ORDER BY AITM_Account__r.Name ASC, AITM_Affiliates_Account__r.Name ASC
        ];
    }
    
    /**
     * @description gets all Lines Based on condition
     * @param sObjectName sobject name
     * @param locID of type Id
     * @return List<SObject>
     */   
    @AuraEnabled(cacheable=true)
    public static List<SObject> getLineItems(Id locId, String sObjectname) {
        String parameter = 'AITM_Tender_Location__c';
        List<SObject> queryResult = queryRecordsById(
                                        AITM_Tender_Location_Line_Item__c.SObjectType, 
                                        fieldsToQuery(sObjectname), 
                                        locId, 
                                        parameter
                                    );
        return queryResult;
    }
    
    /**
     * @description gets wrapper
     * @param sObjectName sobject name
     * @param locID of type Id
     * @return AITMLineItemModel
     */   
    @AuraEnabled(cacheable=true)
    public static AITMLineItemModel getWrapperTLLIFields(String locId, String sObjectname) {
        if(String.isNotBlank(locId) && !fetchLineItems(locId).isEmpty()){   
            Id tendorId;
            Boolean highestVolumeLineFound = false;   
            String parameter = 'Tender_Location_Line_Item_Id__c';           
            Map<Id, AITM_Tender_Location_Line_Item__c> aggregatedLines = new Map<Id,AITM_Tender_Location_Line_Item__c>();
            Map<Id,Integer> maxVolumeWithLineIdMap = new Map<Id,Integer>();
            Map<Id,Integer> maxVolumeWithLocIdMap = new Map<Id,Integer>();
            Map<Id, AITM_Tender_Location_Line_Item__c> mapOfLineItems = new Map<Id, AITM_Tender_Location_Line_Item__c>();
            Map<String, String> colorCodes = new Map<String,String>();
            colorCodes = new AITM_TenderLocationService().initializeColorCodes();
            
            mapOfLineItems = new Map<Id, AITM_Tender_Location_Line_Item__c>((List<AITM_Tender_Location_Line_Item__c>)fetchLineItems(locId));
            tendorId = mapOfLineItems.values()[0].AITM_Tender__c;
            
            if(!mapOfLineItems.isEmpty() && mapOfLineItems.size() == 1)
                return new AITMLineItemModel(mapOfLineItems.values()[0], colorcodes);
  
            for(AggregateResult ar : [SELECT Id,
                                            MAX(AITM_Requested_Volume_USG__c)                                     
                                        FROM AITM_Tender_Location_Line_Item__c 
                                        WHERE AITM_Tender_Location__c =: locId                                       
                                        GROUP BY Id
                                     ]){
                Decimal volNum = (ar.get('expr0') == null)? 0: (Decimal)ar.get('expr0');
                maxVolumeWithLineIdMap.put((Id)ar.get('Id'), volNum.intValue());
                maxVolumeWithLocIdMap.put(locId, volNum.intValue());
            }
                                    
            for(AITM_Tender_Location_Line_Item__c line: mapOfLineItems.values()){
                if(line.AITM_Requested_Volume_USG__c != maxVolumeWithLocIdMap.get(locId))
                    highestVolumeLineFound = true;
            }
            
            if(highestVolumeLineFound)
                return new AITMLineItemModel(mapOfLineItems.get(fetchLineItems(locId)[0].Id), 
                                                        fetchColorCode(
                                                            mapOfLineItems, 
                                                            mapOfLineItems.get(fetchLineItems(locId)[0].Id), 
                                                            colorCodes
                                                        )
                                                    );
            
            if(!highestVolumeLineFound && !fetchCustomersOrderByCustomerAffiliates(tendorId).isEmpty()){
                String uniqueTendorWithCustomerId = tendorId + '-' + fetchCustomersOrderByCustomerAffiliates(tendorId)[0].AITM_Account__c;
                Map<String, String> affiliates = new Map<String, String>();
                Map<String, AITM_Tender_Location_Line_Item__c> mapOfUniqueKeyWithLineItem = new Map<String, AITM_Tender_Location_Line_Item__c>();
                
                for(AITM_Tender_Account__c customer: fetchCustomersOrderByCustomerAffiliates(tendorId)){
                    if(customer.AITM_Affiliates_Account__c != null)
                        affiliates.put(customer.AITM_Affiliates_Account__r.Name, customer.AITM_Tender__c + '-' + customer.AITM_Account__c);
                }
                
                for(AITM_Tender_Location_Line_Item__c item: mapOfLineItems.values()){
                    mapOfUniqueKeyWithLineItem.put(item.AITM_Tender__c + '-' + item.AITM_Account__c, item);
                }
                
                if(!affiliates.isEmpty()){
                    List<String> highestAffiliate = new List<String>(affiliates.keySet());
                    highestAffiliate.sort();
                    uniqueTendorWithCustomerId = affiliates.get(highestAffiliate[affiliates.size()-1]);
                }    
                            
                return new AITMLineItemModel(mapOfUniqueKeyWithLineItem.get(uniqueTendorWithCustomerId), 
                                                    fetchColorCode(
                                                        mapOfLineItems, 
                                                        mapOfUniqueKeyWithLineItem.get(uniqueTendorWithCustomerId), 
                                                        colorCodes
                                                    )
                                                );
            }else{            
                return new AITMLineItemModel(mapOfLineItems.get(new List<Id>(maxVolumeWithLineIdMap.keySet())[0]), 
                                                    fetchColorCode(
                                                        mapOfLineItems, 
                                                        mapOfLineItems.get(new List<Id>(maxVolumeWithLineIdMap.keySet())[0]), 
                                                        colorCodes
                                                    )
                                                );                                             
            }
        }
        return null;
    }    
    
    /**
     * @description gets color codes
     * @param  Map<Id, AITM_Tender_Location_Line_Item__c>
     * @param  AITM_Tender_Location_Line_Item__c
     * @param Map<String,String> of type map
     * @return Map<String,String>
     */   
    @AuraEnabled(cacheable=true)
    public static Map<String,String> fetchColorCode(Map<Id, AITM_Tender_Location_Line_Item__c> mapOfLineItems, AITM_Tender_Location_Line_Item__c highestVolumeLineItem, Map<String,String> colorCodes) {
        
        for(AITM_Tender_Location_Line_Item__c line: mapOfLineItems.values()){
            if(!colorCodes.isEmpty() && colorCodes.containsKey(System.Label.AITM_LastTenderColorCodeLabel) 
                && colorCodes.get(System.Label.AITM_LastTenderColorCodeLabel) != System.Label.AITM_RedColorLabel
                && (line.AITM_Offered_Differential__c != highestVolumeLineItem.AITM_Offered_Differential__c
                    || line.AITM_Unit_Of_Measure__c != highestVolumeLineItem.AITM_Unit_Of_Measure__c
                    || line.AITM_Currency__c != highestVolumeLineItem.AITM_Currency__c
                    || line.AITM_Last_Tender_Result__c != highestVolumeLineItem.AITM_Last_Tender_Result__c)
              )             
                colorCodes.put(System.Label.AITM_LastTenderColorCodeLabel, System.Label.AITM_RedColorLabel);
                    
            if(!colorCodes.isEmpty() && colorCodes.containsKey(System.Label.AITM_ProductDensityColorCodeLabel) 
                && colorCodes.get(System.Label.AITM_ProductDensityColorCodeLabel) != System.Label.AITM_RedColorLabel                                 
                && (line.AITM_Density__c != highestVolumeLineItem.AITM_Density__c
                    || line.AITM_Product_Default__c != highestVolumeLineItem.AITM_Product_Default__c))
                colorCodes.put(System.Label.AITM_ProductDensityColorCodeLabel, System.Label.AITM_RedColorLabel);
            
            if(!colorCodes.isEmpty() && colorCodes.containsKey(System.Label.AITM_DeliveryMethodColorCodeLabel) 
                && colorCodes.get(System.Label.AITM_DeliveryMethodColorCodeLabel) != System.Label.AITM_RedColorLabel
                && line.AITM_Delivery_Method__c != highestVolumeLineItem.AITM_Delivery_Method__c)            
                colorCodes.put(System.Label.AITM_DeliveryMethodColorCodeLabel, System.Label.AITM_RedColorLabel);
                                
            if(!colorCodes.isEmpty() && colorCodes.containsKey(System.Label.AITM_MeasureColorCodeLabel) 
                && colorCodes.get(System.Label.AITM_MeasureColorCodeLabel) != System.Label.AITM_RedColorLabel                                 
                && line.AITM_Measure__c != highestVolumeLineItem.AITM_Measure__c) 
                colorCodes.put(System.Label.AITM_MeasureColorCodeLabel, System.Label.AITM_RedColorLabel);
            
            if(!colorCodes.isEmpty() && colorCodes.containsKey(System.Label.AITM_RiskRatingCodeLabel) 
                && colorCodes.get(System.Label.AITM_RiskRatingCodeLabel) != System.Label.AITM_RedColorLabel                              
                && line.AITM_Credit_Rating__c != highestVolumeLineItem.AITM_Credit_Rating__c) 
                colorCodes.put(System.Label.AITM_RiskRatingCodeLabel, System.Label.AITM_RedColorLabel);
                               
            if(!colorCodes.isEmpty() && colorCodes.containsKey(System.Label.AITM_CreditDaysCodeLabel) 
                && colorCodes.get(System.Label.AITM_CreditDaysCodeLabel) != System.Label.AITM_RedColorLabel
                && (line.AITM_Credit_Days__c != highestVolumeLineItem.AITM_Credit_Days__c
                    || line.AITM_Invoice_Frequency__c != highestVolumeLineItem.AITM_Invoice_Frequency__c)) 
                colorCodes.put(System.Label.AITM_CreditDaysCodeLabel, System.Label.AITM_RedColorLabel);
                                
            if(!colorCodes.isEmpty() && colorCodes.containsKey(System.Label.AITM_ExchangeCodeLabel) 
                && colorCodes.get(System.Label.AITM_ExchangeCodeLabel) != System.Label.AITM_RedColorLabel                                 
                && line.AITM_Exchange__c != highestVolumeLineItem.AITM_Exchange__c) 
                colorCodes.put(System.Label.AITM_ExchangeCodeLabel, System.Label.AITM_RedColorLabel); 
            
            if(!colorCodes.isEmpty() && colorCodes.containsKey(System.Label.AITM_LevelCodeLabel) 
                && colorCodes.get(System.Label.AITM_LevelCodeLabel) != System.Label.AITM_RedColorLabel                                 
                && line.AITM_Tender_Location__r.AITM_Service_Level__c != highestVolumeLineItem.AITM_Tender_Location__r.AITM_Service_Level__c) 
                colorCodes.put(System.Label.AITM_LevelCodeLabel, System.Label.AITM_RedColorLabel);    
        }
        return colorCodes;
    }

    public with sharing class AITMLineItemModel {
        @AuraEnabled
        public AITM_Tender_Location_Line_Item__c record;
        @AuraEnabled
        public Map<String, String> colorCodes;
 
        public AITMLineItemModel(AITM_Tender_Location_Line_Item__c record, 
                                    Map<String, String> colorCodes) {
            this.record = record;
            this.colorCodes = colorCodes;
        }
    }
    
    /**
     * @description gets all Color Codes
     * @return Map<String, String>
     */
    public Map<String, String> initializeColorCodes(){
        Map<String, String> colorCodes = new Map<String, String>();
        colorCodes.put(System.Label.AITM_LastTenderColorCodeLabel, System.Label.AITM_BlackColorLabel);
        colorCodes.put(System.Label.AITM_ProductDensityColorCodeLabel, System.Label.AITM_BlackColorLabel);
        colorCodes.put(System.Label.AITM_DeliveryMethodColorCodeLabel, System.Label.AITM_BlackColorLabel);
        colorCodes.put(System.Label.AITM_MeasureColorCodeLabel, System.Label.AITM_BlackColorLabel);
        colorCodes.put(System.Label.AITM_RiskRatingCodeLabel, System.Label.AITM_BlackColorLabel);
        colorCodes.put(System.Label.AITM_CreditDaysCodeLabel, System.Label.AITM_BlackColorLabel);
        colorCodes.put(System.Label.AITM_ExchangeCodeLabel, System.Label.AITM_BlackColorLabel);
        colorCodes.put(System.Label.AITM_LevelCodeLabel, System.Label.AITM_BlackColorLabel);
        return colorCodes;
    }
    
    /**
     * @description returns Current User Details
     * @param null
     * @return User Info
    */
    @AuraEnabled 
    public static User fetchUser(){
       return [SELECT ID, Name, AITM_SBC_Enhanced_Version__c FROM User WHERE ID =: userInfo.getUserId()];
    }
    
    /**
     * @description returns Picture Details
     * @param null
     * @return List<ContentVersion>
    */
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getPictures() {      
        Set<Id> contentIds = new Set<Id>();
        List<AITM_Images__c> image = new List<AITM_Images__c>();
        image = [SELECT ID, 
                    Name,
                    AITM_Unique_Identifier__c
                FROM AITM_Images__c 
                WHERE OwnerId =: userInfo.getUserId()
                ];
        if(!image.isEmpty()){
            List<ContentDocumentLink> links = [SELECT ID, 
                                                    LinkedEntityId, 
                                                    ContentDocumentId                                           
                                              FROM ContentDocumentLink
                                              WHERE
                                                LinkedEntityId = :image[0].ID
                                                AND ContentDocument.FileType IN ('PNG', 'JPG', 'GIF')
                                            ];
            if (links.isEmpty()) {
                return null;
            }
    
            for (ContentDocumentLink link : links) {
                contentIds.add(link.ContentDocumentId);
            }
        }

        return [
            SELECT Id, 
                Title
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentIds 
            ORDER BY CreatedDate DESC
        ];
    }
    
    /**
     * @description gets filter round options list
     * @param tenderId of type Id
     * @return List collection AITM_RelatedRecordsHolderController.FilterOption
     */
    public static @AuraEnabled Integer getRound(Id tenderId) {
        Integer maxRound = 1;
        List<AggregateResult> result =  [SELECT Max(AITM_Round__c) maxRound FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId];
        
        if (result[0].get('maxRound') != null)
            maxRound = Integer.valueOf(result[0].get('maxRound'));
        
        return maxRound;
    }
    
    /**
     * @description get the list of delivery point of a location
     * @param lineItemRecord  of type AITM_Tender_Location_Line_Item__c
     * @return List of AITM_Delivery_Point__c
     */
    @AuraEnabled(cacheable=true)
    public static List<AITM_Delivery_Point__c> getDeliveryRecords(Id locationId) {       
        List<AITM_Delivery_Point__c> deliveryPoints =  new AITM_LocationsDao().getDeliveryPointRelatedLocation(locationId);
        return deliveryPoints;
    }
}