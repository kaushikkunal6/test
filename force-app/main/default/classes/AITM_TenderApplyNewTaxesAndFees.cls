/***************************************************************
 * @author           Kunal
 * @date             18/Nov/2019
 * @group            AirBP
 * @description      Tender Location New Taxes & Fees AITM_TenderApplyNewTaxesAndFees

 * history
 * 18/Nov/2019  	 Kunal       Created 
 * 27/Nov/2019       Neeti       Added new method cloneTenderTaxesAndFee
 * 23/Dec/2019       Thanuja     883841 logic has been added
 * 12/Mar/2020       Neeti       993088 logic has been added
 * 22/Apr/2020       Kunal       62578 logic has been added
  
 **********************************************************/
public without sharing class AITM_TenderApplyNewTaxesAndFees {
    public static String fuelType;
    public static String deliveryMethodWithAll = 'All';
    public static List<AITM_Taxes_Fees__c> listOfFeeToAttachOnLineItem = new List<AITM_Taxes_Fees__c>();
    public static List<AITM_Taxes_Fees__c> listOfFeeToAttachOnLineItemWithDelMethAll = new List<AITM_Taxes_Fees__c>();
    
    /**
      * @description attach New taxes and fees to Line item
      * @param listCollection of type AITM_Tender_Location_Line_Item__c
      * @param Map Collection of type Lineitem id, boolean
      * @param Map Collection of type String, boolean
      * @return void
      */
    public static void attachTaxAndFeeRecordsOnLineItem(List<AITM_Tender_Location_Line_Item__c> listOfLineItems, Map<String, Boolean> mapOfUniqueTaxKeyWithValue) {
        Set<Id> setOfDeliveryPointIds = new Set<Id>();
        Set<String> setOfDeliveryMethod = new Set<String>{'All'};
        Set<String> setOfStringToMatch = new Set<String>();
        Set<String> setOfTenderSector = new Set<String>{'All', 'n/a'};
        Map<Id, String> lineItemIdWithAccountClassification = new Map<Id, String>();
        Map<String, Boolean> refreshLineItemMap = new Map<String, Boolean>();
        Map<String, String> mapOfLineItemIdWithProductDefault = new Map<String, String>();
        Map<String, List<AITM_Taxes_Fees__c>> lineItemTaxFee = new Map<String, List<AITM_Taxes_Fees__c>>();
        Map<String, List<AITM_Taxes_Fees__c>> mapOfDelPointWithFeeForNonCAGA = new Map<String, List<AITM_Taxes_Fees__c>>();
        Map<String, List<AITM_Taxes_Fees__c>> mapOfDelPointWithFeeForCAGA = new Map<String, List<AITM_Taxes_Fees__c>>();
        List<String> listOfProductDefault = new List<String>();
         
        if (listOfLineItems != null) {
            for(AITM_Tender_Location_Line_Item__c lineItem: listOfLineItems) {
                string dpMap = AITM_BaseUtils.getDeliveryPointMapping(lineItem.AITM_Delivery_Method__c);
                setOfDeliveryPointIds.add(lineItem.AITM_Location_Delivery_Point__c);
                setOfDeliveryMethod.add(dpMap);
                String productDefault = AITM_BaseUtils.getTaxesFeesFuelType(lineItem.AITM_Product_Default__c);
                listOfProductDefault = new List<String>(productDefault.split(','));
                for(String prodDefault : listOfProductDefault){
                    mapOfLineItemIdWithProductDefault.put(lineItem.Id + '-' + prodDefault, prodDefault);   
                    setOfStringToMatch.add(lineItem.AITM_Location_Delivery_Point__c + prodDefault + dpMap);
                    setOfStringToMatch.add(lineItem.AITM_Location_Delivery_Point__c + prodDefault + 'All');
                }
                setOfStringToMatch.add(lineItem.AITM_Location_Delivery_Point__c);
                setOfTenderSector.add(lineItem.AITM_Tender__r.AITM_Tender_Sector__c);
                lineItemIdWithAccountClassification.put(lineItem.Id, lineItem.AITM_Account__r.AITM_Account_Classification__c);
                if((lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'Military') || (lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'GA')){
                    setOfTenderSector.add('GA & Military');
                }
                if((lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'Military') || (lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'CA')){
                    setOfTenderSector.add('CA & Military');
                }
                if((lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'CA') || (lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'GA')){
                    setOfTenderSector.add('CA & GA');
                }
            }
            
            for(AITM_Taxes_Fees__c fee : [SELECT Name, AITM_Level__c, AITM_FEE_TAX_GROUP__c, AITM_FEE_TAX_NAME__c,
                            AITM_Charge_Type__c, AITM_Value__c, AITM_Currency__c, AITM_Include_in_Salesforce__c,
                            AITM_Delivery_Type__c, AITM_Fuel_type__c, AITM_Unit_of_measure_display__c, AITM_Compulsory_Conditional__c,
                            AITM_Delivery_Point__r.AITM_Additional_Notes_Taxes_Fees__c, AITM_Delivery_Point__c
                            FROM AITM_Taxes_Fees__c 
                            WHERE AITM_Delivery_Point__c IN :setOfDeliveryPointIds]){
                if(!mapOfDelPointWithFeeForCAGA.containsKey(fee.AITM_Delivery_Point__c)) {
                    mapOfDelPointWithFeeForCAGA.put(fee.AITM_Delivery_Point__c, new List<AITM_Taxes_Fees__c>{fee});    
                } else{
                    mapOfDelPointWithFeeForCAGA.get(fee.AITM_Delivery_Point__c).add(fee);
                    listOfFeeToAttachOnLineItem = mapOfDelPointWithFeeForCAGA.get(fee.AITM_Delivery_Point__c);
                }
                if(mapOfLineItemIdWithProductDefault.values().contains(fee.AITM_Fuel_type__c) && setOfTenderSector.contains(fee.AITM_Include_in_Salesforce__c) && setOfDeliveryMethod.contains(fee.AITM_Delivery_Type__c)){
				    
                    if(!mapOfDelPointWithFeeForNonCAGA.containsKey(fee.AITM_Delivery_Point__c +'-'+ fee.AITM_Fuel_type__c +'-'+ fee.AITM_Delivery_Type__c)) {
                        mapOfDelPointWithFeeForNonCAGA.put(fee.AITM_Delivery_Point__c +'-'+ fee.AITM_Fuel_type__c +'-'+ fee.AITM_Delivery_Type__c, new List<AITM_Taxes_Fees__c>{fee});    
                    } else{
                        mapOfDelPointWithFeeForNonCAGA.get(fee.AITM_Delivery_Point__c +'-'+ fee.AITM_Fuel_type__c +'-'+ fee.AITM_Delivery_Type__c).add(fee);
                    }
                }
            }
            
            lineItemTaxFee = getTaxesFeesRecordsFromMaster(lineItemIdWithAccountClassification, listOfLineItems, mapOfDelPointWithFeeForNonCAGA, mapOfDelPointWithFeeForCAGA, setOfStringToMatch, lineItemTaxFee, mapOfLineItemIdWithProductDefault);
            processLineItemsWithFeeRecords(lineItemIdWithAccountClassification, listOfLineItems, lineItemTaxFee, mapOfLineItemIdWithProductDefault, mapOfUniqueTaxKeyWithValue);
        }
    }
    
    /**
      * @description processing master taxes and fees
      * @param list Collection of type AITM_Tender_Location_Line_Item__c
      * @param Map Collection of type Lineitem id, String
      * @param Map Collection of type String, List of type AITM_Taxes_Fees__c
      * @param Map Collection of type String, boolean
      * @param Map Collection of type Id, boolean
      * @return void
      */
    public static void processLineItemsWithFeeRecords(Map<Id, String> lineItemIdWithAccountClassification, List<AITM_Tender_Location_Line_Item__c> listOfLineItems, Map<String, List<AITM_Taxes_Fees__c>> lineItemTaxFee,
        Map<String, String> mapOfLineItemIdWithProductDefault, Map<String, Boolean> mapOfUniqueTaxKeyWithValue){

        if (listOfLineItems != null && lineItemTaxFee != null) {
            List<AITM_Tender_Location_Taxes_and_Fees__c> listOfFeeRecordsToInsert = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
            for (AITM_Tender_Location_Line_Item__c lineItem : listOfLineItems) {
                List<AITM_Taxes_Fees__c> listOfFeeRecordsToAttachLineItem = new List<AITM_Taxes_Fees__c>();
                Set<String> setOfUniqueTaxFeeProduct = new Set<String>();
                String classification = lineItemIdWithAccountClassification.get(lineItem.Id);
                String tempKey = '';
                if (classification != 'CA reseller' && classification != 'GA reseller'){

                    for(String IdWithProduct : mapOfLineItemIdWithProductDefault.keyset()){
                        if(IdWithProduct.split('-')[0].contains(lineItem.Id) && IdWithProduct.split('-').size() > 1){
                            setOfUniqueTaxFeeProduct.add(IdWithProduct.split('-')[1]);
                        }
                    }

                    for(String productDefault : setOfUniqueTaxFeeProduct){

                        tempKey = lineItem.AITM_Location_Delivery_Point__c + mapOfLineItemIdWithProductDefault.get(lineItem.Id + '-' + productDefault) + AITM_BaseUtils.getDeliveryPointMapping(lineItem.AITM_Delivery_Method__c);         
                        if(lineItemTaxFee.get(tempKey) != null){ 
                            listOfFeeRecordsToAttachLineItem = lineItemTaxFee.get(tempKey);
                        }

                        tempKey = lineItem.AITM_Location_Delivery_Point__c + mapOfLineItemIdWithProductDefault.get(lineItem.Id + '-' + productDefault) + 'All';         
                        if(lineItemTaxFee.get(tempKey) != null){      
                            listOfFeeRecordsToAttachLineItem = lineItemTaxFee.get(tempKey);
                        }
                    }
                } else {
                    tempKey = lineItem.AITM_Location_Delivery_Point__c;
                    listOfFeeRecordsToAttachLineItem = lineItemTaxFee.get(tempKey);
                }
                listOfFeeRecordsToInsert = createTenderLocationTaxFees(listOfFeeRecordsToAttachLineItem, lineItem, mapOfUniqueTaxKeyWithValue, listOfFeeRecordsToInsert);
            }
            
            if(!listOfFeeRecordsToInsert.isEmpty()) {
                database.insert(listOfFeeRecordsToInsert);
            }
        }
    }
    
    /**
      * @description processing master taxes and fees
      * @param list Collection of type AITM_Tender_Location_Line_Item__c
      * @param Map Collection of type Lineitem id, String
      * @param Map Collection of type String, List of type AITM_Taxes_Fees__c
      * @param Map Collection of type String, boolean
      * @param Map Collection of type Id, boolean
      * @return Map Collection fo type String, List<AITM_Taxes_Fees__c>
      */
    public static Map<String, List<AITM_Taxes_Fees__c>> getTaxesFeesRecordsFromMaster(Map<Id, String> lineItemIdWithAccountClassification, List<AITM_Tender_Location_Line_Item__c> listOfLineItems, Map<String, List<AITM_Taxes_Fees__c>> mapOfDelPointWithFeeForNonCAGA, 
        Map<String, List<AITM_Taxes_Fees__c>> mapOfDelPointWithFeeForCAGA, Set<String> setOfStringToMatch, Map<String, List<AITM_Taxes_Fees__c>> lineItemTaxFee, Map<String, String> mapOfLineItemIdWithProductDefault) {
                                                        
        for (AITM_Tender_Location_Line_Item__c lineItem : listOfLineItems) {
            List<AITM_Taxes_Fees__c> listOfFeeToAttachOnLineItemNonCAGA = new List<AITM_Taxes_Fees__c>();
            List<AITM_Taxes_Fees__c> listOfFeeToAttachOnLineItemCAGA = new List<AITM_Taxes_Fees__c>();
            String classification = lineItemIdWithAccountClassification.get(lineItem.Id);
            Set<String> setOfUniqueTaxFeeProduct = new Set<String>();
            if (classification != 'CA reseller' && classification != 'GA reseller' && !mapOfDelPointWithFeeForNonCAGA.keySet().isEmpty()) {
               
                for(String IdWithProduct : mapOfLineItemIdWithProductDefault.keyset()){
                    if(IdWithProduct.split('-')[0].contains(lineItem.Id) && IdWithProduct.split('-').size() > 1){
                        setOfUniqueTaxFeeProduct.add(IdWithProduct.split('-')[1]);
                    }
                }

                for(String productDefault : setOfUniqueTaxFeeProduct){
                    List<AITM_Taxes_Fees__c> feeOnLineItemNonCAGAUniqueProdDefault = new List<AITM_Taxes_Fees__c>();
                    if(mapOfDelPointWithFeeForNonCAGA.get(lineItem.AITM_Location_Delivery_Point__c +'-'+ mapOfLineItemIdWithProductDefault.get(lineItem.Id + '-' + productDefault) +'-'+ AITM_BaseUtils.getDeliveryPointMapping(lineItem.AITM_Delivery_Method__c)) != null){
                        feeOnLineItemNonCAGAUniqueProdDefault = mapOfDelPointWithFeeForNonCAGA.get(lineItem.AITM_Location_Delivery_Point__c +'-'+ mapOfLineItemIdWithProductDefault.get(lineItem.Id + '-' + productDefault) +'-'+ AITM_BaseUtils.getDeliveryPointMapping(lineItem.AITM_Delivery_Method__c));
                    }

                    if(mapOfDelPointWithFeeForNonCAGA.get(lineItem.AITM_Location_Delivery_Point__c +'-'+ mapOfLineItemIdWithProductDefault.get(lineItem.Id + '-' + productDefault) +'-All') != null){
                        feeOnLineItemNonCAGAUniqueProdDefault.addall(mapOfDelPointWithFeeForNonCAGA.get(lineItem.AITM_Location_Delivery_Point__c +'-'+ mapOfLineItemIdWithProductDefault.get(lineItem.Id + '-' + productDefault) +'-'+'All' ));
                    }
                    
                    listOfFeeToAttachOnLineItemNonCAGA.addAll(feeOnLineItemNonCAGAUniqueProdDefault);
                }

                List<AITM_Taxes_Fees__c> tempList = new List<AITM_Taxes_Fees__c>();
                for(AITM_Taxes_Fees__c masterFee : listOfFeeToAttachOnLineItemNonCAGA){
                    String key = masterFee.AITM_Delivery_Point__c + masterFee.AITM_Fuel_type__c + masterFee.AITM_Delivery_Type__c;
                    if(setOfStringToMatch.contains(key)) {
                        tempList.add(masterFee);
                    }
                    if(!lineItemTaxFee.containsKey(key)) {
                        lineItemTaxFee.put(key, tempList);
                    }
                }
            } else{
                if(!mapOfDelPointWithFeeForCAGA.keySet().isEmpty() && mapOfDelPointWithFeeForCAGA.get(lineItem.AITM_Location_Delivery_Point__c) != null){
                    listOfFeeToAttachOnLineItemCAGA = mapOfDelPointWithFeeForCAGA.get(lineItem.AITM_Location_Delivery_Point__c);
                    
                    List<AITM_Taxes_Fees__c> tempList = new List<AITM_Taxes_Fees__c>();
                    for(AITM_Taxes_Fees__c masterFee : listOfFeeToAttachOnLineItemCAGA){
                        String key = masterFee.AITM_Delivery_Point__c;
                        if(setOfStringToMatch.contains(key)) {
                            tempList.add(masterFee);
                        }
                        if(!lineItemTaxFee.containsKey(key)) {
                            lineItemTaxFee.put(key, tempList);
                        }
                    }
                }
            }
        }
        return lineItemTaxFee;
    }
    
    /**
      * @description processing master taxes and fees
      * @param listOfMasterFees Collection of type AITM_Taxes_Fees__c
      * @param lineItem type AITM_Tender_Location_Line_Item__c
      * @param mapOfUniqueTaxKeyWithValue Map Collection of type String, boolean
      * @param list Collection of type AITM_Tender_Location_Line_Item__c
      */
    public static List<AITM_Tender_Location_Taxes_and_Fees__c> createTenderLocationTaxFees(List<AITM_Taxes_Fees__c> listOfMasterFees, AITM_Tender_Location_Line_Item__c lineItem, Map<String, Boolean> mapOfUniqueTaxKeyWithValue, List<AITM_Tender_Location_Taxes_and_Fees__c> listOfFeeRecordsToInsert){
        if(listOfMasterFees != null){
            for (AITM_Taxes_Fees__c masterFeeRecord: listOfMasterFees) {
                AITM_Tender_Location_Taxes_and_Fees__c tenderLocTaxFee = new AITM_Tender_Location_Taxes_and_Fees__c();
        
                tenderLocTaxFee.AITM_Level__c = masterFeeRecord.AITM_Level__c == null ? '' : masterFeeRecord.AITM_Level__c;
                tenderLocTaxFee.AITM_FEE_TAX_GROUP__c = (masterFeeRecord.AITM_FEE_TAX_GROUP__c == null) ? '' : masterFeeRecord.AITM_FEE_TAX_GROUP__c;
                tenderLocTaxFee.AITM_FEE_TAX_NAME__c = masterFeeRecord.AITM_FEE_TAX_NAME__c;
                tenderLocTaxFee.AITM_Charge_Type__c = (masterFeeRecord.AITM_Charge_Type__c == null) ? '' : masterFeeRecord.AITM_Charge_Type__c;
                tenderLocTaxFee.AITM_Value__c = (masterFeeRecord.AITM_Value__c == null) ? 0 : masterFeeRecord.AITM_Value__c;
                tenderLocTaxFee.AITM_Display_Currency__c = (masterFeeRecord.AITM_Currency__c == null) ? '' : masterFeeRecord.AITM_Currency__c;
                tenderLocTaxFee.AITM_Compulsory_Conditional__c = (masterFeeRecord.AITM_Compulsory_Conditional__c == null) ? '' : masterFeeRecord.AITM_Compulsory_Conditional__c;
                tenderLocTaxFee.AITM_Unit_of_measure__c = masterFeeRecord.AITM_Unit_of_measure_display__c;
                if(lineItem.recordType.Name == 'De-brief') {
                    tenderLocTaxFee.AITM_Record_Type_Name__c = 'De-brief';
                } else {
                    tenderLocTaxFee.AITM_Record_Type_Name__c = 'Default';
                }
                tenderLocTaxFee.AITM_Tender_Sector__c = (masterFeeRecord.AITM_Include_in_Salesforce__c == null) ? '' : masterFeeRecord.AITM_Include_in_Salesforce__c;
                tenderLocTaxFee.AITM_Fuel_Type__c = (masterFeeRecord.AITM_Fuel_type__c == null) ? '' : masterFeeRecord.AITM_Fuel_type__c;
                tenderLocTaxFee.Tender_Location_Line_Item_Id__c = lineItem.Id;
                tenderLocTaxFee.Name = (masterFeeRecord.Name == null) ? '' : masterFeeRecord.Name;
                String key = tenderLocTaxFee.Name + '-' + tenderLocTaxFee.AITM_Compulsory_Conditional__c + '-' + tenderLocTaxFee.AITM_Fuel_Type__c + '-' + tenderLocTaxFee.AITM_Display_Currency__c + '-' + tenderLocTaxFee.AITM_Unit_of_measure__c + '-' + tenderLocTaxFee.Tender_Location_Line_Item_Id__c;
                /*if(mapOfUpdatedFeeWithSelectToApplyBoolean != null && mapOfUpdatedFeeWithSelectToApplyBoolean.get(tenderLocTaxFee.Name + '-' + tenderLocTaxFee.AITM_Fuel_type__c + '-' + lineItem.Id) != null) {
                    tenderLocTaxFee.AITM_Select_to_Apply_in_Contract__c = mapOfUpdatedFeeWithSelectToApplyBoolean.get(tenderLocTaxFee.Name + '-' + tenderLocTaxFee.AITM_Fuel_type__c + '-' + lineItem.Id);
                } else {*/
                    tenderLocTaxFee.AITM_Select_to_Apply_in_Contract__c = true;
                //}
				
                if(lineItem.AITM_Delivery_Method__c != 'Not Specified' && (mapOfUniqueTaxKeyWithValue == null || !mapOfUniqueTaxKeyWithValue.containsKey(key) || !mapOfUniqueTaxKeyWithValue.get(key))){
                    listOfFeeRecordsToInsert.add(tenderLocTaxFee);
                }
            }
        }
        return listOfFeeRecordsToInsert;
    }
	
     /**
      * @description clone existing taxes fees records from previous round
      * @param listOfExistingTaxesAndFees Collection of type AITM_Tender_Location_Line_Item and round
      * @return void
      */
 
    
     public static void cloneTenderTaxesAndFee(List<AITM_Tender_Location_Line_Item__c> listOfLineItems, Decimal Round, list<Id> ParentId){
     
       Set<Id> tenderId = new Set<Id>();
       map<string,id> mapOfNewTlli = new map<string,id>();
       list<AITM_Tender_Location_Taxes_and_Fees__c> listTenderTaxAndFee = new list<AITM_Tender_Location_Taxes_and_Fees__c>();
      
       for(AITM_Tender_Location_Line_Item__c tlli: listOfLineItems){ 
             mapOfNewTlli.put(tlli.AITM_ManualClonedBy__c, tlli.id);   
             tenderId.add(tlli.AITM_Tender__c);
           }
         
         for(AITM_Tender_Location_Taxes_and_Fees__c oldTnf:[SELECT Name, AITM_Fuel_type__c ,AITM_Level__c,AITM_FEE_TAX_GROUP__c,AITM_FEE_TAX_NAME__c,AITM_Charge_Type__c,
                                                            AITM_Value__c,AITM_Display_Currency__c,AITM_Compulsory_Conditional__c,AITM_Unit_of_measure__c,
                                                            AITM_Record_Type_Name__c,AITM_Tender_Sector__c, AITM_Select_to_Apply_in_Contract__c, 
                                                            Tender_Location_Line_Item_Id__c,Tender_Location_Line_Item_Id__r.AITM_tender__c,Tender_Location_Line_Item_Id__r.AITM_IATA_Internal_Code__c,
                                                            Tender_Location_Line_Item_Id__r.AITM_GRN__c, Tender_Location_Line_Item_Id__r.AITM_MIP_Parent_Id__c 
                                                            FROM AITM_Tender_Location_Taxes_and_Fees__c WHERE Tender_Location_Line_Item_Id__r.AITM_round__c =:Round 
                                                            AND Tender_Location_Line_Item_Id__c IN: ParentId]){
              AITM_Tender_Location_Taxes_and_Fees__c tenderLocTaxFee = new AITM_Tender_Location_Taxes_and_Fees__c();
               
                tenderLocTaxFee.AITM_Level__c = oldTnf.AITM_Level__c;
                tenderLocTaxFee.AITM_FEE_TAX_GROUP__c = oldTnf.AITM_FEE_TAX_GROUP__c;
                tenderLocTaxFee.AITM_FEE_TAX_NAME__c = oldTnf.AITM_FEE_TAX_NAME__c;
                tenderLocTaxFee.AITM_Charge_Type__c = oldTnf.AITM_Charge_Type__c;
                tenderLocTaxFee.AITM_Value__c = oldTnf.AITM_Value__c;
                tenderLocTaxFee.AITM_Display_Currency__c = oldTnf.AITM_Display_Currency__c;
                tenderLocTaxFee.AITM_Compulsory_Conditional__c = oldTnf.AITM_Compulsory_Conditional__c;
                tenderLocTaxFee.AITM_Unit_of_measure__c = oldTnf.AITM_Unit_of_measure__c;
                tenderLocTaxFee.AITM_Record_Type_Name__c = oldTnf.AITM_Record_Type_Name__c;
                tenderLocTaxFee.AITM_Tender_Sector__c = oldTnf.AITM_Tender_Sector__c;
                tenderLocTaxFee.AITM_Fuel_Type__c =  oldTnf.AITM_Fuel_Type__c;
                tenderLocTaxFee.Tender_Location_Line_Item_Id__c = mapOfNewTlli.get(oldTnf.Tender_Location_Line_Item_Id__c);
                tenderLocTaxFee.Name =oldTnf.Name;
                tenderLocTaxFee.AITM_Select_to_Apply_in_Contract__c = oldTnf.AITM_Select_to_Apply_in_Contract__c;
                listTenderTaxAndFee.add(tenderLocTaxFee);
          }
          
          if(!listTenderTaxAndFee.isEmpty()) {
             database.insert(listTenderTaxAndFee);
             
            } 
     }
     
    /**
      * @description delete existing taxes fees records
      * @param listOfExistingTaxesAndFees Collection of type AITM_Tender_Location_Taxes_and_Fees__c
      * @return void
      */
    public static void deleteExistingTaxesAndFees(List<AITM_Tender_Location_Taxes_and_Fees__c> listOfExistingTaxesAndFees){
        database.delete(listOfExistingTaxesAndFees);
    }
}