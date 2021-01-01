/*************************************************************************
* @author         Thanuja Undralla
* @Luke Date           27/April/2019
* @group          AirBP
* @description    controller class for AITM_TenderLineTaxTrigger which adds the respective Tax and Fees records based on filter conditions

* history

*************************************************************************/
public without sharing class AITM_TenderTaxFeeCreation {
    
    public void TenderLocationHandler(AITM_Tender_Location_Line_Item__c lineInfo,Boolean productTypeFlag,string dmlOp ) {
       upsertNewTaxAndFee(lineInfo, null, productTypeFlag);
    }

    //Added for TenderSector value change 
    public void TenderHandler(AITM_Tender__c Tender) {
        if(!Tender.AITM_Select_to_Apply_Old_Taxes_and_Fees__c){
          upsertNewTaxAndFee(null, Tender,false);
        }
    }
      
    public static void upsertNewTaxAndFee(AITM_Tender_Location_Line_Item__c locLineItem, AITM_Tender__c tend,Boolean productTypeCheck) {
    
        set < ID > storeTLLISet = new Set < ID > ();
        set < Id > tenderLocIdSet = new Set < ID > ();
        set < String > tenderProduct = new Set < String > ();
        set < String > tenderDelMethodSet = new Set < String > ();
        set < String > concateSet = new Set < String > ();
        set < String > tenderSectorSet = new set < String > ();
        map < string, List < AITM_Taxes_Fees__c >> lineItemTaxFee = new map < String, List < AITM_Taxes_Fees__c >> ();
        map < id, String > lineItemMap = new map < id, String > ();
        map < String, Boolean > refreshLineItemMap = new map < String, Boolean > ();

        List <AITM_Taxes_Fees__c> taxesFeesList = new List < AITM_Taxes_Fees__c > ();
        List <AITM_Tender_Location_Taxes_and_Fees__c> taxfeelst = New List < AITM_Tender_Location_Taxes_and_Fees__c > ();
        List <AITM_Tender_Location_Taxes_and_Fees__c> TenderLocationTFLst = new List < AITM_Tender_Location_Taxes_and_Fees__c > ();
        string str;
        List <AITM_Tender_Location_Line_Item__c> tendLocationLineItemList = new List < AITM_Tender_Location_Line_Item__c > ();
        if (locLineItem != null) {
            str = locLineItem.id;
            tendLocationLineItemList = Database.query('SELECT AITM_Delivery_Method__c,AITM_Location_Delivery_Point__c,AITM_Product_Default__c, AITM_Tender_Id__c,AITM_Tender__c,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c,AITM_Account__c,AITM_Account__r.AITM_Account_Classification__c FROM AITM_Tender_Location_Line_Item__c where id =: str');

        } else {
            str = tend.id;
            tendLocationLineItemList = Database.query('SELECT AITM_Delivery_Method__c,AITM_Location_Delivery_Point__c,AITM_Product_Default__c, AITM_Tender_Id__c,AITM_Tender__c,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c,AITM_Account__c,AITM_Account__r.AITM_Account_Classification__c FROM AITM_Tender_Location_Line_Item__c where AITM_Tender__c =: str');

        }

        if (tendLocationLineItemList != null) {
            for (AITM_Tender_Location_Line_Item__c lineItemVar: tendLocationLineItemList) {
                storeTLLISet.add(lineItemVar.id);
                tenderLocIdSet.add(lineItemVar.AITM_Location_Delivery_Point__c);
                tenderDelMethodSet.add(lineItemVar.AITM_Delivery_Method__c);
                string tempStr = AITM_BaseUtils.getTaxesFeesFuelType(lineItemVar.AITM_Product_Default__c);
                tenderProduct.add(tempStr);
                concateSet.add(lineItemVar.AITM_Location_Delivery_Point__c + tempStr + lineItemVar.AITM_Delivery_Method__c);
                concateSet.add(lineItemVar.AITM_Location_Delivery_Point__c);
                lineItemMap.put(lineItemVar.id, lineItemVar.AITM_Location_Delivery_Point__c + tempStr + lineItemVar.AITM_Delivery_Method__c);
            }

            //Query existing AITM_Tender_Location_Taxes_and_Fees__c  for Deletion
            taxfeelst = [select id, name, AITM_Select_to_Apply_in_Contract__c,Tender_Location_Line_Item_Id__c,Tender_Location_Line_Item_Id__r.recordType.name from AITM_Tender_Location_Taxes_and_Fees__c where Tender_Location_Line_Item_Id__c IN: storeTLLISet];
               
            for (AITM_Tender_Location_Taxes_and_Fees__c taxfee: taxfeelst) {
                if(taxfee.Tender_Location_Line_Item_Id__r.recordType.name == 'Default'){
                    if(!refreshLineItemMap.containsKey(taxfee.name+'-'+taxfee.Tender_Location_Line_Item_Id__c)){
                        refreshLineItemMap.put(taxfee.name+'-'+taxfee.Tender_Location_Line_Item_Id__c, taxfee.AITM_Select_to_Apply_in_Contract__c);
                    }
                  }
                }


            //Create a Set for tenderSector and add other values like All, GA & Military, n/a
            tenderSectorSet.add(tendLocationLineItemList[0].AITM_Tender__r.AITM_Tender_Sector__c);
            tenderSectorSet.add('All');
            tenderSectorSet.add('GA & Military');
            tenderSectorSet.add('n/a');
            String accClassify = tendLocationLineItemList[0].AITM_Account__r.AITM_Account_Classification__c;

            //Get the List of Taxes and Fees from the Taxes and Fees based on the Tender Sector and Tender Line Item's Product Default, Fuel Type and Delivery Point     
            try {
                if (accClassify != 'CA reseller' && accClassify != 'GA reseller') {
                    for (AITM_Taxes_Fees__c txFee: [SELECT Name, AITM_Level__c, AITM_FEE_TAX_GROUP__c, AITM_FEE_TAX_NAME__c,
                            AITM_Charge_Type__c, AITM_Value__c, AITM_Currency__c, AITM_Include_in_Salesforce__c,
                            AITM_Delivery_Type__c, AITM_Fuel_type__c, AITM_Unit_of_measure_display__c, AITM_Compulsory_Conditional__c,
                            AITM_Delivery_Point__r.AITM_Additional_Notes_Taxes_Fees__c, AITM_Delivery_Point__c
                            FROM AITM_Taxes_Fees__c where
                            AITM_Delivery_Point__c IN: tenderLocIdSet
                            AND AITM_Fuel_type__c IN: tenderProduct
                            AND AITM_Include_in_Salesforce__c IN: tenderSectorSet
                            AND AITM_Delivery_Type__c IN: tenderDelMethodSet
                        ]) {
                        if (concateSet.contains(txFee.AITM_Delivery_Point__c + txFee.AITM_Fuel_type__c + txFee.AITM_Delivery_Type__c)) {
                            taxesFeesList.add(txFee);
                            List < AITM_Taxes_Fees__c > tempList = new List < AITM_Taxes_Fees__c > ();
                            if (lineItemTaxFee.containsKey(txFee.AITM_Delivery_Point__c + txFee.AITM_Fuel_type__c + txFee.AITM_Delivery_Type__c)) {

                                tempList = lineItemTaxFee.get(txFee.AITM_Delivery_Point__c + txFee.AITM_Fuel_type__c + txFee.AITM_Delivery_Type__c);
                            }
                            tempList.add(txFee);
                            lineItemTaxFee.put(txFee.AITM_Delivery_Point__c + txFee.AITM_Fuel_type__c + txFee.AITM_Delivery_Type__c, tempList);

                        }
                    }
                } else {
                    for (AITM_Taxes_Fees__c txFee: [SELECT Name, AITM_Level__c, AITM_FEE_TAX_GROUP__c, AITM_FEE_TAX_NAME__c,
                            AITM_Charge_Type__c, AITM_Value__c, AITM_Currency__c, AITM_Include_in_Salesforce__c,
                            AITM_Delivery_Type__c, AITM_Fuel_type__c, AITM_Unit_of_measure_display__c, AITM_Compulsory_Conditional__c,
                            AITM_Delivery_Point__r.AITM_Additional_Notes_Taxes_Fees__c, AITM_Delivery_Point__c
                            FROM AITM_Taxes_Fees__c where
                            AITM_Delivery_Point__c IN: tenderLocIdSet
                        ]) {
                        if (concateSet.contains(txFee.AITM_Delivery_Point__c)) {
                            taxesFeesList.add(txFee);
                            List < AITM_Taxes_Fees__c > tempList = new List < AITM_Taxes_Fees__c > ();
                            if (lineItemTaxFee.containsKey(txFee.AITM_Delivery_Point__c)) {

                                tempList = lineItemTaxFee.get(txFee.AITM_Delivery_Point__c);
                            }
                            tempList.add(txFee);
                            lineItemTaxFee.put(txFee.AITM_Delivery_Point__c, tempList);

                        }
                    }
                }
            } catch (Exception e) {
                System.debug('Exception raised-->' + e);
            }
            if (tendLocationLineItemList != null) {
                for (AITM_Tender_Location_Line_Item__c lineItemVar: tendLocationLineItemList) {
                    List < AITM_Taxes_Fees__c > TaxFeeList = new List < AITM_Taxes_Fees__c > ();
                    string tempStr = lineItemMap.get(lineItemVar.id);

                    if (lineItemTaxFee != null) {
                        if (accClassify != 'CA reseller' && accClassify != 'GA reseller') {
                            TaxFeeList = lineItemTaxFee.get(tempStr);
                        }else
                        TaxFeeList = lineItemTaxFee.get(lineItemVar.AITM_Location_Delivery_Point__c);
                        if (TaxFeeList != null)
                            for (AITM_Taxes_Fees__c TaxFee: TaxFeeList) {
                                AITM_Tender_Location_Taxes_and_Fees__c TndrLocTax = new AITM_Tender_Location_Taxes_and_Fees__c();

                                TndrLocTax.AITM_Level__c = TaxFee.AITM_Level__c == null ? '' : TaxFee.AITM_Level__c;
                                TndrLocTax.AITM_FEE_TAX_GROUP__c = (TaxFee.AITM_FEE_TAX_GROUP__c == null) ? '' : TaxFee.AITM_FEE_TAX_GROUP__c;
                                TndrLocTax.AITM_FEE_TAX_NAME__c = TaxFee.AITM_FEE_TAX_NAME__c;
                                TndrLocTax.AITM_Charge_Type__c = (TaxFee.AITM_Charge_Type__c == null) ? '' : TaxFee.AITM_Charge_Type__c;
                                TndrLocTax.AITM_Value__c = (TaxFee.AITM_Value__c == null) ? 0 : TaxFee.AITM_Value__c;
                                TndrLocTax.AITM_Display_Currency__c = (TaxFee.AITM_Currency__c == null) ? '' : TaxFee.AITM_Currency__c;
                                TndrLocTax.AITM_Compulsory_Conditional__c = (TaxFee.AITM_Compulsory_Conditional__c == null) ? '' : TaxFee.AITM_Compulsory_Conditional__c;
                                TndrLocTax.AITM_Unit_of_measure__c = TaxFee.AITM_Unit_of_measure_display__c;
                                
                                TndrLocTax.AITM_Tender_Sector__c = (TaxFee.AITM_Include_in_Salesforce__c == null) ? '' : TaxFee.AITM_Include_in_Salesforce__c;
                                TndrLocTax.AITM_Fuel_Type__c = (TaxFee.AITM_Fuel_type__c == null) ? '' : TaxFee.AITM_Fuel_type__c;
                                TndrLocTax.AITM_Record_Type_Name__c = 'Default';
                                if(productTypeCheck == false) {
                                TndrLocTax.AITM_Select_to_Apply_in_Contract__c = (refreshLineItemMap.containsKey(TaxFee.Name+'-'+lineItemVar.Id)) ? refreshLineItemMap.get(TaxFee.Name+'-'+lineItemVar.Id) : True;
                                }
                                TndrLocTax.Tender_Location_Line_Item_Id__c = lineItemVar.Id;
                                TndrLocTax.Name = (TaxFee.Name == null) ? '' : TaxFee.Name;
                                TenderLocationTFLst.add(TndrLocTax);

                            }
                    }
                }

                database.insert(TenderLocationTFLst);
            }
            if (taxfeelst != null) {
                database.delete(taxfeelst);
            }
        }
    }
    
      public static void insertTaXAndFeeBulkInsertTLLI(map<id,sObject> locLineItem1){
        Map<Id,AITM_Tender_Location_Line_Item__c> locLineItem= (locLineItem1!= null) ? (Map<Id,AITM_Tender_Location_Line_Item__c>)locLineItem1: new Map<Id,AITM_Tender_Location_Line_Item__c>();
         
         set < ID > storeTLLISet = new Set < ID > ();
         set < Id > tenderLocIdSet = new Set < ID > ();
         set < String > tenderProduct = new Set < String > ();
         set < String > concateSet = new Set < String > ();
         set < String > tenderSectorSet = new set < String > ();
         set < String > tenderDelMethodSet = new Set < String > ();
         List < AITM_Tender_Location_Line_Item__c > tendLocationLineItemList = new List < AITM_Tender_Location_Line_Item__c > ();
         List < AITM_Taxes_Fees__c > taxesFeesList = new List < AITM_Taxes_Fees__c > ();
        List < AITM_Tender_Location_Taxes_and_Fees__c > taxfeelst = New List < AITM_Tender_Location_Taxes_and_Fees__c > ();
        List < AITM_Tender_Location_Taxes_and_Fees__c > tenderLocationTFLst = new List < AITM_Tender_Location_Taxes_and_Fees__c > ();
        string str;
        
         map <id, String > accClassify = new map < id,String > ();
         map < string, List < AITM_Taxes_Fees__c >> lineItemTaxFee = new map < String, List < AITM_Taxes_Fees__c >> ();
        map < id, String > lineItemMap = new map < id, String > ();
         
           for (AITM_Tender_Location_Line_Item__c lineItemVar: [SELECT AITM_Delivery_Method__c,AITM_Location_Delivery_Point__c,AITM_Product_Default__c, AITM_Tender_Id__c,AITM_Tender__c,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c,AITM_Account__c,AITM_Account__r.AITM_Account_Classification__c FROM AITM_Tender_Location_Line_Item__c where id in: locLineItem.keySet() FOR UPDATE]) {
                tendLocationLineItemList.add(lineItemVar);
                storeTLLISet.add(lineItemVar.id);
                string tempStr = AITM_BaseUtils.getTaxesFeesFuelType(lineItemVar.AITM_Product_Default__c);
                tenderProduct.add(tempStr);
                concateSet.add(lineItemVar.AITM_Location_Delivery_Point__c + tempStr + lineItemVar.AITM_Delivery_Method__c);
                concateSet.add(lineItemVar.AITM_Location_Delivery_Point__c);
              
                accClassify.put(lineItemVar.id,lineItemVar.AITM_Account__r.AITM_Account_Classification__c);
                tenderSectorSet.add(lineItemVar.AITM_Tender__r.AITM_Tender_Sector__c);
                tempStr = AITM_BaseUtils.getTaxesFeesFuelType(lineItemVar.AITM_Product_Default__c);
                
                tenderProduct.add(tempStr);
                tenderLocIdSet.add(lineItemVar.AITM_Location_Delivery_Point__c);
                tenderDelMethodSet.add(lineItemVar.AITM_Delivery_Method__c);
           }
            for (AITM_Taxes_Fees__c txFee: [SELECT Name, AITM_Level__c, AITM_FEE_TAX_GROUP__c, AITM_FEE_TAX_NAME__c,
                            AITM_Charge_Type__c, AITM_Value__c, AITM_Currency__c, AITM_Include_in_Salesforce__c,
                            AITM_Delivery_Type__c, AITM_Fuel_type__c, AITM_Unit_of_measure_display__c, AITM_Compulsory_Conditional__c,
                            AITM_Delivery_Point__r.AITM_Additional_Notes_Taxes_Fees__c, AITM_Delivery_Point__c
                            FROM AITM_Taxes_Fees__c WHERE
                         (AITM_Delivery_Point__c IN: tenderLocIdSet)
                        ]) {
                        if (concateSet.contains(txFee.AITM_Delivery_Point__c + txFee.AITM_Fuel_type__c + txFee.AITM_Delivery_Type__c) || concateSet.contains(txFee.AITM_Delivery_Point__c)) {
                                  taxesFeesList.add(txFee);
                                  List <AITM_Taxes_Fees__c > tempList = new List < AITM_Taxes_Fees__c > ();
                                  if (lineItemTaxFee.containsKey(txFee.AITM_Delivery_Point__c + txFee.AITM_Fuel_type__c + txFee.AITM_Delivery_Type__c)) {
                                     tempList = lineItemTaxFee.get(txFee.AITM_Delivery_Point__c + txFee.AITM_Fuel_type__c + txFee.AITM_Delivery_Type__c);
                                  }
                                  lineItemTaxFee.put(txFee.AITM_Delivery_Point__c + txFee.AITM_Fuel_type__c + txFee.AITM_Delivery_Type__c, tempList);
                                  if (lineItemTaxFee.containsKey(txFee.AITM_Delivery_Point__c)) {
                                    tempList = lineItemTaxFee.get(txFee.AITM_Delivery_Point__c);
                                  }
                                  tempList.add(txFee);
                                  lineItemTaxFee.put(txFee.AITM_Delivery_Point__c, tempList);
                             }
                        }   
                  
            if (tendLocationLineItemList != null) {
                for (AITM_Tender_Location_Line_Item__c lineItemVar: tendLocationLineItemList) {
                    List < AITM_Taxes_Fees__c > taxFeeList = new List < AITM_Taxes_Fees__c > ();
                    string tempStr = lineItemMap.get(lineItemVar.id);
                    if (lineItemTaxFee != null) {
                            if (accClassify.get(lineItemVar.id) != 'CA reseller' && accClassify.get(lineItemVar.id) != 'GA reseller') { 
                            taxFeeList = lineItemTaxFee.get(tempStr);
                        } else
                            taxFeeList = lineItemTaxFee.get(lineItemVar.AITM_Location_Delivery_Point__c);
                        }
                    if (taxFeeList != null){
                        for (AITM_Taxes_Fees__c taxFee: taxFeeList) {
                            AITM_Tender_Location_Taxes_and_Fees__c tndrLocTax = new AITM_Tender_Location_Taxes_and_Fees__c();
                            tndrLocTax.AITM_Level__c = taxFee.AITM_Level__c == null ? '' : taxFee.AITM_Level__c;
                            tndrLocTax.AITM_FEE_TAX_GROUP__c = (taxFee.AITM_FEE_TAX_GROUP__c == null) ? '' : taxFee.AITM_FEE_TAX_GROUP__c;
                            tndrLocTax.AITM_FEE_TAX_NAME__c = taxFee.AITM_FEE_TAX_NAME__c;
                            tndrLocTax.AITM_Charge_Type__c = (taxFee.AITM_Charge_Type__c == null) ? '' : taxFee.AITM_Charge_Type__c;
                            tndrLocTax.AITM_Value__c = (taxFee.AITM_Value__c == null) ? 0 : taxFee.AITM_Value__c;
                            tndrLocTax.AITM_Display_Currency__c = (taxFee.AITM_Currency__c == null) ? '' : TaxFee.AITM_Currency__c;
                            tndrLocTax.AITM_Compulsory_Conditional__c = (taxFee.AITM_Compulsory_Conditional__c == null) ? '' : taxFee.AITM_Compulsory_Conditional__c;
                            tndrLocTax.AITM_Unit_of_measure__c = taxFee.AITM_Unit_of_measure_display__c;
                            tndrLocTax.AITM_Tender_Sector__c = (taxFee.AITM_Include_in_Salesforce__c == null) ? '' : taxFee.AITM_Include_in_Salesforce__c;
                            tndrLocTax.AITM_Fuel_Type__c = (taxFee.AITM_Fuel_type__c == null) ? '' : taxFee.AITM_Fuel_type__c;
                            tndrLocTax.AITM_Select_to_Apply_in_Contract__c = True;
                            tndrLocTax.Tender_Location_Line_Item_Id__c = lineItemVar.Id;
                            tndrLocTax.Name = (taxFee.Name == null) ? '' : taxFee.Name;
                            tenderLocationTFLst.add(tndrLocTax);
                        }
                    }
                }       
            }
            if (tenderLocationTFLst != null) {
                 database.insert(tenderLocationTFLst);
            }
      }
}