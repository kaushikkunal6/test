/*************************************************************************
 * @author         Sushant
 * @date           11/May/2020
 * @group          AirBP
 * @description    To create a JSON body structure to make a RestApi Callout to MuleSoft(Pros system)
*************************************************************************/
public with sharing class AITM_JsonBodyRequest {
    
    private Boolean elementValue = true;
    private Integer quantityValue = 1;
    private Boolean getScaleValue = false;    
    private Decimal orderVolumeValue = 1.0;
    
    public AITM_Tender_Location_Line_Item__c getSourceObject(Id recordId){
       AITM_Tender_Location_Line_Item__c sourceLineItem = [SELECT ID,AITM_GRN__c,AITM_Unit_Of_Measure__c,AITM_Location__r.AITM_IATA__c,
                                                                  AITM_Sales_Pricing_Period__c,AITM_Replenishment_Pricing_Period__c,
                                                                  AITM_Offered_Differential__c,AITM_Offered_Volume__c,AITM_Credit_Days__c,
                                                                  AITM_Location_Strategy__c,AITM_Volume__c,AITM_Start_Date__c,AITM_End_Date__c,
                                                                  AITM_Account__r.AITM_Customer_Segment__c, AITM_Location_Size__c,AITM_Currency__c,                                                                                                                                                                                                                                                               
                                                                  AITM_Credit_Rating__c,AITM_Additional_Margin_From_Line_Items__c,AITM_JV_Profit_Dividend__c, 
                                                                  AITM_Invoice_Frequency__c,AITM_Rebate__c,AITM_Density__c,AITM_Customer_Specific_Into_Plane_Costs__c                                                                 
                                                                  FROM AITM_Tender_Location_Line_Item__c WHERE ID =: recordId];
      return sourceLineItem;                                                 
    }    
    
    /**
         * @description gets string formatted source date 
         * @param source of type date
         * @return string
      */
    private String getFormattedDate(Date source) {
            Date sourceDate = source == null ? Date.today() : source;
            return Datetime.newInstance(sourceDate.year(), sourceDate.month(), sourceDate.day()).format('yyyyMMdd');
    }
        
    /**
         * @description gets defaults value from source sobject
         * @param source of type SObject
         * @return string
      */    
    public String getDefaultsBody (SObject source){ 
        AITM_Tender_Location_Line_Item__c sourceLineItem = (AITM_Tender_Location_Line_Item__c) source;
        sourceLineItem = getSourceObject(sourceLineItem.Id);
        
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        jsonGen.writeFieldName('Defaults');
        jsonGen.writeStartObject();
        jsonGen.writeBooleanField('getElements', elementValue);
        jsonGen.writeStringField('uomCode', sourceLineItem.AITM_Unit_Of_Measure__c == null ? '' : sourceLineItem.AITM_Unit_Of_Measure__c);
        jsonGen.writeStringField('date', String.valueOf(this.getFormattedDate(Date.today())));
        jsonGen.writeNumberField('perQuantity', quantityValue);
        jsonGen.writeStringField('currencyCode', sourceLineItem.AITM_Currency__c == null ? '' : sourceLineItem.AITM_Currency__c);
        jsonGen.writeNumberField('orderVolume', orderVolumeValue);
        jsonGen.writeBooleanField('getScales', getScaleValue);
        jsonGen.writeEndObject();
        jsonGen.writeEndObject();
        String jsonData = jsonGen.getAsString();
        return jsonData;
    }
    
    /**
         * @description gets pricing evaluation
         * @param source of type SObject
         * @return string
      */
    public String getPriceEvaluationBody (SObject source){
        AITM_Tender_Location_Line_Item__c sourceLineItem = (AITM_Tender_Location_Line_Item__c) source;
        sourceLineItem =getSourceObject(sourceLineItem.Id);       
        
        JSONGenerator jsonGen = JSON.createGenerator(true);        
        jsonGen.writeStartObject();
        jsonGen.writeFieldName('PriceEvaluation');
        jsonGen.writeStartObject();
        jsonGen.writeStringField('evaluationMethod','RW Target Price');
        jsonGen.writeBooleanField('getElements', elementValue);
        jsonGen.writeStringField('uomCode', sourceLineItem.AITM_Unit_Of_Measure__c == null ? '' : sourceLineItem.AITM_Unit_Of_Measure__c); 
        jsonGen.writeStringField('date', String.valueOf(this.getFormattedDate(Date.today())));
        jsonGen.writeNumberField('perQuantity', quantityValue);
        jsonGen.writeStringField('currencyCode', sourceLineItem.AITM_Currency__c == null ? '' : sourceLineItem.AITM_Currency__c);
        jsonGen.writeNumberField('orderVolume', orderVolumeValue);
        jsonGen.writeEndObject();
        jsonGen.writeEndObject();
        String jsonData = jsonGen.getAsString();  
        return jsonData;
    }
    
    /**
         * @description gets dimension
         * @param source of type SObject
         * @return string
      */
    public String getDimensionBody(SObject source){
        AITM_Tender_Location_Line_Item__c sourceLineItem = (AITM_Tender_Location_Line_Item__c) source;
        sourceLineItem = getSourceObject(sourceLineItem.Id);                      
        
        JSONGenerator jsonGen = JSON.createGenerator(true);        
        jsonGen.writeStartObject();
        jsonGen.writeFieldName('Dimensions');
        jsonGen.writeStartObject();
        jsonGen.writeStringField('location', sourceLineItem.AITM_Location__r.AITM_IATA__c);
        jsonGen.writeStringField('customerGRN', String.valueof(sourceLineItem.AITM_GRN__c));
        jsonGen.writeEndObject();
        jsonGen.writeEndObject();
        String jsonData = jsonGen.getAsString();
        return jsonData;
    }
    
    /**
         * @description returns the PricingInformationEvaluation method element values of TenderLocationLineItem
         * @param sourceLineItem of type AITM_Tender_Location_Line_Item__c
         * @return string
       */
    public String getEvaluationMethodElementsBody(SObject source){
        AITM_Tender_Location_Line_Item__c sourceLineItem = (AITM_Tender_Location_Line_Item__c) source;
        sourceLineItem = getSourceObject(sourceLineItem.Id); 
        
        JSONGenerator jsonGen = JSON.createGenerator(true);        
        jsonGen.writeStartObject();
        jsonGen.writeFieldName('EvaluationMethodElements');
        jsonGen.writeStartObject();
        jsonGen.writeStringField('customerSegmentValue',sourceLineItem.AITM_Account__r.AITM_Customer_Segment__c == null ? 'None' : sourceLineItem.AITM_Account__r.AITM_Customer_Segment__c);
        jsonGen.writeNumberField('locationVolume', sourceLineItem.AITM_Location_Size__c == null ? 0 : sourceLineItem.AITM_Location_Size__c);             
        jsonGen.writeStringField('locationStrategyValue', sourceLineItem.AITM_Location_Strategy__c == null ? 'None' : sourceLineItem.AITM_Location_Strategy__c);         
        jsonGen.writeNumberField('tenderVolume', sourceLineItem.AITM_Volume__c == null ? 0 : sourceLineItem.AITM_Volume__c);        
        jsonGen.writeStringField('priceStartDate', String.valueOf(this.getFormattedDate(sourceLineItem.AITM_Start_Date__c)));
        jsonGen.writeStringField('priceEndDate', String.valueof(this.getFormattedDate(sourceLineItem.AITM_End_Date__c)));
        jsonGen.writeNumberField('offerDifferential', sourceLineItem.AITM_Offered_Differential__c == null ? 0 : sourceLineItem.AITM_Offered_Differential__c);
        jsonGen.writeNumberField('volumeDifferential', sourceLineItem.AITM_Offered_Volume__c == null ? 0 : sourceLineItem.AITM_Offered_Volume__c);        
        if(sourceLineItem.AITM_Credit_Days__c == null){
          jsonGen.writeStringField('creditDays', sourceLineItem.AITM_Credit_Days__c = '0');   
        }else if(sourceLineItem.AITM_Credit_Days__c == 'PP'){
          jsonGen.writeStringField('creditDays', sourceLineItem.AITM_Credit_Days__c = '-2');   
        }else{
          jsonGen.writeStringField('creditDays', sourceLineItem.AITM_Credit_Days__c);  
        }
      //  jsonGen.writeStringField('creditDays', (sourceLineItem.AITM_Credit_Days__c == 'PP' ? '-2' : sourceLineItem.AITM_Credit_Days__c));  
        jsonGen.writeStringField('salesPricingBasis', sourceLineItem.AITM_Sales_Pricing_Period__c == null ? '' : sourceLineItem.AITM_Sales_Pricing_Period__c);
        jsonGen.writeStringField('supplyPricingBasis', sourceLineItem.AITM_Replenishment_Pricing_Period__c == null ? '' : sourceLineItem.AITM_Replenishment_Pricing_Period__c);
        jsonGen.writeStringField('invoiceFrequency', sourceLineItem.AITM_Invoice_Frequency__c == null ? '' : sourceLineItem.AITM_Invoice_Frequency__c);
        jsonGen.writeNumberField('unitRebate', sourceLineItem.AITM_Rebate__c == null ? 0 : sourceLineItem.AITM_Rebate__c);
        jsonGen.writeStringField('density', sourceLineItem.AITM_Density__c == null ? '' : sourceLineItem.AITM_Density__c);
        jsonGen.writeNumberField('customerSpecificIntoPlaneCosts', sourceLineItem.AITM_Customer_Specific_Into_Plane_Costs__c == null ? 0 : sourceLineItem.AITM_Customer_Specific_Into_Plane_Costs__c);
        jsonGen.writeStringField('creditRatingofCustomer', sourceLineItem.AITM_Credit_Rating__c == null ? '' : sourceLineItem.AITM_Credit_Rating__c);
        jsonGen.writeNumberField('additionalMarginfromLineItems', sourceLineItem.AITM_Additional_Margin_From_Line_Items__c == null ? 0 : sourceLineItem.AITM_Additional_Margin_From_Line_Items__c);        
        jsonGen.writeNumberField('jVProfitDividend', sourceLineItem.AITM_JV_Profit_Dividend__c == null ? 0 : sourceLineItem.AITM_JV_Profit_Dividend__c);
        jsonGen.writeEndObject();
        jsonGen.writeEndObject();
        String jsonData = jsonGen.getAsString();
        return jsonData;
    }
    
    /**
         * @description retrieves JsonBody Request for Post Callout to Mulesoft.
         * @param source of type SObject
         * @return SObject
       */
    public String getRequest(SObject source, String requestName) {
        String result;
        result = this.getDefaultsBody(source) + this.getPriceEvaluationBody(source) + this.getDimensionBody(source) + this.getEvaluationMethodElementsBody(source);
        return result;
    }
}