/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      To generate Tender Offer Batch

 * history
 * 01/December/2017  George       Created 
 * 23/August/2018    Ravi         Modified added comments to each method and header of class and with sharing
 * 23/December/2018  srnandan     Modified -method collect, assignDeliveryPoint and getLineItemWithDeliveryPoint 
 *                                based on tender sector line items
 * 07/January/2019   srnandan     Modified soql removing condition -  AND AITM_Default_Delivery_Point__c IN :deliveryPointSector
 * 11/March/2019     Shweta       Modified AR-4999 Updated the method getLineItemWithDeliveryPoint to include all the delivery point fields in the TLLI
 * 02/April/2019     Ravi         Modified - AR-5028 added currency and UOM to populate to TLLI in getLineItemWithDeliveryPoint
 * 21/May/2019       srnandan     Modified - AR-5029 to refer new field product and density TTLI and derive product and density values from metadata mapping
 * 30/Sep/2019     Saravan      WorkItem(684962) - Modified assignDeliveryPoint method to get GA deliverypoint for Military sector
 * 23/Oct/2019     Thanuja     - Added Additional Notes field in Delivery point query to display in line item additional notes as per New T&F changes
 * 20/May/2020       Ravi         Modified to add validation and remove old taxes and fees field 
 *************************************************************************************/
public with sharing class AITM_TenderLocationDeliveryPointsHandler {
  private Map<Id,AITM_Tender_Location_Line_Item__c> locationIdToLineItemId;
  private Map<Id, AITM_Tender_Location_Line_Item__c> idToLineItem;
  private List<AITM_Tender_Location_Line_Item__c> lineItemToUpdate;
    private Set<Id> tenderIds;
    private Set<String> deliveryPointSector;
    private List<AITM_Tender_Location_Line_Item__c> lineItems;
	private AITM_Pricing_Basis__c nonRepresentedPricingBasis ;
    /**
     * @description default constructor handler class 
     */
  public AITM_TenderLocationDeliveryPointsHandler(){
    locationIdToLineItemId = new Map<Id,AITM_Tender_Location_Line_Item__c>();
    idToLineItem = new Map<Id, AITM_Tender_Location_Line_Item__c>();
    lineItemToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
        lineItems = new List<AITM_Tender_Location_Line_Item__c>();
        tenderIds = new Set<Id>();
      if(!Test.isRunningTest()){
        nonRepresentedPricingBasis = [SELECT Id, Name FROM AITM_Pricing_Basis__c WHERE Name =: 'None - Air BP not Represented' LIMIT 1];
        }
      }

    /**
     * @description collect AITM_Tender_Location_Line_Item__c
     * @param lineItems
     * @return null
     */
    public void collect(AITM_Tender_Location_Line_Item__c lineItem) {
      if(lineItem.AITM_Location_Delivery_Point__c == null) {
        locationIdToLineItemId.put(lineItem.AITM_Location__c, lineItem);
          idToLineItem.put(lineItem.Id, lineItem);
            tenderIds.add(lineItem.AITM_Tender__c);
            lineItems.add(lineItem);
      }
    }

    /**
     * @description assign Deliver Point
     * @param null
     * @return null
     */
    public void assignDeliveryPoint() {
      if(locationIdToLineItemId.keySet().size() > 0) {
            AITM_Tender__c singleItem = [SELECT AITM_Tender_Sector__c, AITM_Select_to_Apply_Old_Taxes_and_Fees__c, OwnerId from AITM_Tender__c WHERE Id IN: tenderIds LIMIT 1];
            String ownerProfile = new AITM_UsersDao().getProfileName(singleItem.OwnerId);
          deliveryPointSector = new Set<String>();
          if(singleItem.AITM_Tender_Sector__c == 'Military'){
                deliveryPointSector.add('GA');  
            }else{
                 deliveryPointSector.add(singleItem.AITM_Tender_Sector__c);       
            }
          deliveryPointSector.add('BOTH');
            
          Map<id,List<AITM_Delivery_Point__c>> mapDpLoc = new Map<id,List<AITM_Delivery_Point__c>>();
          for(AITM_Delivery_Point__c deliveryPoint : [SELECT Name, AITM_Is_Active__c,AITM_Currency__c,AITM_Additional_Notes_Taxes_Fees__c,AITM_Unit_of_Measure__c,AITM_Location__c, AITM_Default_Delivery_Point__c, AITM_BPInter_Location_DeliveryPoint_Cod__c, AITM_Pricing_Basis_CA__c, AITM_Pricing_Basis_GA__c,AITM_Location_Manager1__c,AITM_Delivery_Method__c,AITM_Delivery_By__c, AITM_Product__c, AITM_Density__c, AITM_Product_Default__c, AITM_Product_Pricing_Report__c, AITM_Additional_Refueling_Information__c,AITM_Taxes_Fees__c,AITM_Measure__c,AITM_Product_Specification__c FROM AITM_Delivery_Point__c WHERE AITM_Location__c = :locationIdToLineItemId.keySet()  AND AITM_Is_Active__c = true]) {
               if(!mapDpLoc.containsKey(deliveryPoint.AITM_Location__c)) {
                    mapDpLoc.put(deliveryPoint.AITM_Location__c, new List<AITM_Delivery_Point__c>{deliveryPoint});    
                } else{
                    mapDpLoc.get(deliveryPoint.AITM_Location__c).add(deliveryPoint);
                }
          } 
              
       
                 for(AITM_Tender_Location_Line_Item__c item : lineItems) {
                     if(mapDpLoc.containsKey(item.AITM_Location__c)){
                     
                        for(AITM_Delivery_Point__c deliveryPoint : mapDpLoc.get(item.AITM_Location__c)){
                          if(item.AITM_Location__c == deliveryPoint.AITM_Location__c && item.AITM_Tender__c == singleItem.Id) {
                          item.AITM_Tender_Owner_Profile__c = ownerProfile;
                          lineItemToUpdate.add(getLineItemWithDeliveryPoint(deliveryPoint, item, singleItem.AITM_Select_to_Apply_Old_Taxes_and_Fees__c));         
                          }
                         } 
                     }
                     else{
                         if(nonRepresentedPricingBasis != null){
                        	item.AITM_Pricing_Basis__c = nonRepresentedPricingBasis.id;
                         }
           				item.AITM_Delivery_Method__c = null; 
                        lineItemToUpdate.add(item); 
                     }
                         
                }
       
      }
    }

    /**
     * @description get Line Item with Delivery Point
     * @param deliveryPoint
     * @return deliveryPoint to lineItem
     */
    public AITM_Tender_Location_Line_Item__c getLineItemWithDeliveryPoint(AITM_Delivery_Point__c deliveryPoint, AITM_Tender_Location_Line_Item__c lineItem, boolean isNewTaxesTender){
      //Id lineItemId = locationIdToLineItemId.get(deliveryPoint.AITM_Location__c);
    //AITM_Tender_Location_Line_Item__c lineItem = locationIdToLineItemId.get(deliveryPoint.AITM_Location__c);
        if(deliveryPointSector.contains('CA') && deliveryPointSector.contains(deliveryPoint.AITM_Default_Delivery_Point__c)) {
           lineItem.AITM_Location_Delivery_Point__c = deliveryPoint.Id; 
           lineItem.AITM_Pricing_Basis__c = deliveryPoint.AITM_Pricing_Basis_CA__c;
           lineItem.AITM_Delivery_Method__c = deliveryPoint.AITM_Delivery_Method__c; 
           lineItem.AITM_Delivery_By__c = deliveryPoint.AITM_Delivery_By__c; 
           lineItem.AITM_Product_Density_for_Pricing__c = deliveryPoint.AITM_Product__c;
           lineItem.AITM_Product_Default__c = deliveryPoint.AITM_Product_Default__c;
           lineItem.AITM_Density__c = deliveryPoint.AITM_Density__c;
           lineItem.AITM_Additional_Refueling_Information__c = deliveryPoint.AITM_Additional_Refueling_Information__c;
           if(isNewTaxesTender){
                lineItem.AITM_Taxes_Fees__c = deliveryPoint.AITM_Taxes_Fees__c;
           }
           lineItem.AITM_Additional_Notes_Taxes_and_Fees__c = deliveryPoint.AITM_Additional_Notes_Taxes_Fees__c; 
		   lineItem.AITM_Show_Additional_Notes_For_Conga__c = deliveryPoint.AITM_Additional_Notes_Taxes_Fees__c;
           lineItem.AITM_Measure__c = deliveryPoint.AITM_Measure__c;
           lineItem.AITM_Product_Specification__c = deliveryPoint.AITM_Product_Specification__c;  
           lineItem.AITM_Currency__c = deliveryPoint.AITM_Currency__c;
           lineItem.AITM_Unit_Of_Measure__c = deliveryPoint.AITM_Unit_of_Measure__c;
           lineItem.AITM_Product_Pricing_Report__c = deliveryPoint.AITM_Product_Pricing_Report__c;
           
        } else if(deliveryPointSector.contains('GA') && deliveryPointSector.contains(deliveryPoint.AITM_Default_Delivery_Point__c)){
            lineItem.AITM_Pricing_Basis__c = deliveryPoint.AITM_Pricing_Basis_GA__c;
            lineItem.AITM_Location_Delivery_Point__c = deliveryPoint.Id;
            lineItem.AITM_Delivery_Method__c = deliveryPoint.AITM_Delivery_Method__c; 
            lineItem.AITM_Delivery_By__c = deliveryPoint.AITM_Delivery_By__c; 
            lineItem.AITM_Product_Density_for_Pricing__c = deliveryPoint.AITM_Product__c;
            lineItem.AITM_Product_Default__c = deliveryPoint.AITM_Product_Default__c;
            lineItem.AITM_Density__c = deliveryPoint.AITM_Density__c;
            lineItem.AITM_Additional_Refueling_Information__c = deliveryPoint.AITM_Additional_Refueling_Information__c;
            if(isNewTaxesTender){
                lineItem.AITM_Taxes_Fees__c = deliveryPoint.AITM_Taxes_Fees__c;
            }
            lineItem.AITM_Additional_Notes_Taxes_and_Fees__c = deliveryPoint.AITM_Additional_Notes_Taxes_Fees__c; 
			lineItem.AITM_Show_Additional_Notes_For_Conga__c = deliveryPoint.AITM_Additional_Notes_Taxes_Fees__c;
            lineItem.AITM_Measure__c = deliveryPoint.AITM_Measure__c;
            lineItem.AITM_Product_Specification__c = deliveryPoint.AITM_Product_Specification__c;
            lineItem.AITM_Currency__c = deliveryPoint.AITM_Currency__c;
            lineItem.AITM_Unit_Of_Measure__c = deliveryPoint.AITM_Unit_of_Measure__c;
            lineItem.AITM_Product_Pricing_Report__c = deliveryPoint.AITM_Product_Pricing_Report__c;
        } 
        else {
           lineItem.AITM_Pricer_No_Default_Delivery_Points__c = deliveryPoint.AITM_Location_Manager1__c;
            //lineItem.AITM_Location_Delivery_Point__c = deliveryPoint.Id;
       }
	   if(deliveryPoint.AITM_Is_Active__c = false){
	     lineItem.AITM_Location_Delivery_Point__c = null;
	   }
    return lineItem;
    }
}