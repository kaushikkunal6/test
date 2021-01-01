/***************************************************************
 * @author           Neeti
 * @date             06/Nov/2019
 * @group            AirBP
 * @description      Batch to create t&f clone records: AITM_TenderLocationTaxFeeBatch

 * history
 * 05/March/2020     Neeti       Created 
 **********************************************************/
 public with sharing class AITM_TenderLocationTaxFeeCloneBatch implements Database.Batchable<SObject>{
    private final Id tenderRecordId;
    private final String operationType;
    private final Decimal preRound;
    private map<string,id> mapOfNewTlli = new map<string,id>();
    private static final String DEFAULT_TAXES_RECORDTYPE = 'Default';
    
    
    /**
     * @description overloaded constructor
     * @param  state of type BatchState
     */
    public AITM_TenderLocationTaxFeeCloneBatch(Id tenderId, Decimal round,map<string,id> mapOfAllNewTlli) {
        tenderRecordId = tenderId;
        preRound = round;
        mapOfNewTlli = mapOfAllNewTlli;
      }
    
    
    /**
     * @description start
     * @param  context of type Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext context) {	
     return Database.getQueryLocator('SELECT Name, AITM_Fuel_type__c ,AITM_Level__c,AITM_FEE_TAX_GROUP__c,AITM_FEE_TAX_NAME__c,AITM_Charge_Type__c,AITM_Value__c,AITM_Display_Currency__c,AITM_Compulsory_Conditional__c,AITM_Unit_of_measure__c,AITM_Record_Type_Name__c,AITM_Tender_Sector__c, AITM_Select_to_Apply_in_Contract__c, Tender_Location_Line_Item_Id__c,Tender_Location_Line_Item_Id__r.AITM_tender__c,Tender_Location_Line_Item_Id__r.AITM_MIP_Parent_Id__c ,Tender_Location_Line_Item_Id__r.AITM_IATA_Internal_Code__c,Tender_Location_Line_Item_Id__r.AITM_GRN__c, AITM_Manually_Saved_Tax__c FROM AITM_Tender_Location_Taxes_and_Fees__c WHERE AITM_Record_Type_Name__c = :DEFAULT_TAXES_RECORDTYPE AND Tender_Location_Line_Item_Id__r.AITM_round__c=:preRound AND Tender_Location_Line_Item_Id__r.AITM_Tender__c=:tenderRecordId');       	
          	
    }

 /**
     * @description execute
     * @param  context of type Database.BatchableContext
     * @param  scope of type List<AITM_Tender_Location_Taxes_and_Fees__c>
     * @return null
     */
    public void execute(Database.BatchableContext context, List<AITM_Tender_Location_Taxes_and_Fees__c> scope) {
     list<AITM_Tender_Location_Taxes_and_Fees__c> listTenderTaxAndFee = new list<AITM_Tender_Location_Taxes_and_Fees__c>();
      
      if (scope.size() > 0) {
          for(AITM_Tender_Location_Taxes_and_Fees__c oldTnf:scope){
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
                tenderLocTaxFee.AITM_Manually_Saved_Tax__c = oldTnf.AITM_Manually_Saved_Tax__c;
                //tenderLocTaxFee.Tender_Location_Line_Item_Id__c = mapOfNewTlli.get(oldTnf.Tender_Location_Line_Item_Id__r.AITM_MIP_Parent_Id__c);
				tenderLocTaxFee.Tender_Location_Line_Item_Id__c = mapOfNewTlli.get(oldTnf.Tender_Location_Line_Item_Id__c);
                tenderLocTaxFee.Name =oldTnf.Name;
                tenderLocTaxFee.AITM_Select_to_Apply_in_Contract__c = oldTnf.AITM_Select_to_Apply_in_Contract__c;
				if(tenderLocTaxFee.Tender_Location_Line_Item_Id__c != null){	
                    listTenderTaxAndFee.add(tenderLocTaxFee);
				}
          }
          
           if(!listTenderTaxAndFee.isEmpty()) {
             database.insert(listTenderTaxAndFee);
             
            } 
     }
     }

     /**
     * @description finish
     * @param  context of type Database.BatchableContext
     * @return null
     */    
    public void finish(Database.BatchableContext context) {}    
    
 }