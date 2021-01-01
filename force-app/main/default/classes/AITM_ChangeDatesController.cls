/***********************************************************************************************
* @author           Shweta
* @date             10/May/2018
* @group            AirBP
* @description      controller class used in aura component to change line item start and end dates 
*                   for a tender

* history
* 10/May/2018       Shweta    Created AR-2400
* 07/June/2019      Shweta    Modified AR-5221 Updated the method getTenderLocationLineItemsStartDates & getTenderLocationLineItemsEndDates for showing the unique values of the dates
************************************************************************************************/
public with sharing class AITM_ChangeDatesController {
    /**
     * @description gets the startdates of lineitems for dropdownlist binding
     * @param tenderId of type Id
     * @return List<String> collectionDates
     */
    public static @AuraEnabled List<String> getTenderLocationLineItemsStartDates(Id tenderId) {  
        List<AggregateResult> tenderLocationLineItems = [SELECT AITM_Start_Date__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_Start_Date__c != Null GROUP BY AITM_Start_Date__c LIMIT 5];
        List<String> distinctStartDates = new List<String>();
        for(AggregateResult lineItem : tenderLocationLineItems) {             
            String startDate = Date.valueOf(lineItem.get('AITM_Start_Date__c')).format();
            distinctStartDates.add(startDate);
            
        }
       
        return distinctStartDates;
    }
    
    /**
     * @description gets the enddates of line items for dropdownlist binding
     * @param tenderId of type Id
     * @return List<String> collection Dates
     */
    public static @AuraEnabled List<String> getTenderLocationLineItemsEndDates(Id tenderId) {         
        List<AggregateResult> tenderLocationLineItems = [SELECT AITM_End_Date__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_End_Date__c != Null group by AITM_End_Date__c LIMIT 5];
       
        List<String> distinctEndDates = new List<String>();
        for(AggregateResult lineItem : tenderLocationLineItems) {
            String endDate = Date.valueOf(lineItem.get('AITM_End_Date__c')).format();
            distinctEndDates.add(endDate);
        }   
        return distinctEndDates;
    }
    
    /**
     * @description parse string to date //todo unsure why this method was written
     * @param dateValue of type String
     * @return String
    */
    //@AuraEnabled
    //public static String parseDateValue(String dateValue) {
    // return dateValue;
    
    
    /**
     * @description updates the line items with new startdate
     * @param tenderId of type Id
     * @param oldStartDate of type Date
     * @param newStartDate of type Date
     * @return void
     */
    @AuraEnabled
    public static void updateLineItems(Id tenderId, String oldStartDate, String newStartDate,String oldEndDate,String newEndDate) { 
        If(newStartDate!=Null)
        {
        Date startDate = Date.parse(oldStartDate);        
        List<AITM_Tender_Location_Line_Item__c> lineitems = [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_START_Date__c = :startDate];
        List<AITM_Tender_Location_Line_Item__c> updateLineItemsStartDates = new List<AITM_Tender_Location_Line_Item__c>();
        system.debug('lineitems for startdate filter'+ lineItems);
        for(AITM_Tender_Location_Line_Item__c lineItem : lineitems)
        {
            lineItem.AITM_Start_Date__c = Date.valueOf(newStartDate);
            system.debug('The new start date is' +newStartDate);
            system.debug('The old start date is' +oldStartDate);
            updateLineItemsStartDates.add(lineItem);
        }
        new AITM_LocationsDao().updateLineItemsDate(updateLineItemsStartDates); 
    } 
      if(newEndDate!=Null)
        {
          Date endDate = Date.parse(oldEndDate);        
        List<AITM_Tender_Location_Line_Item__c> lineitems = [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :tenderId AND AITM_End_Date__c = :endDate];
        List<AITM_Tender_Location_Line_Item__c> updateLineItemsenddates = new List<AITM_Tender_Location_Line_Item__c>();
        system.debug('lineitems for enddate filter'+ updateLineItemsenddates);
        for(AITM_Tender_Location_Line_Item__c lineItem : lineitems)
        {
            lineItem.AITM_End_Date__c = Date.valueOf(newEndDate);
           
            updateLineItemsenddates.add(lineItem);
        }
        new AITM_LocationsDao().updateLineItemsDate(updateLineItemsenddates);   
        }
    }
    
    
}