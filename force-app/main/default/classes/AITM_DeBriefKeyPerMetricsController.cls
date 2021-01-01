/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    class contains key metrics data of tender for debrief record type

 * history
 * 06/December/2017  George       Created 
 * 02/March/2018     srnandan     Modified - added code comments as per coding standards for class and methods
* 14/May/2019       Neeti        Remove Code for check 0 and null for Prev Volume   AR-5180  Ability to edit historical volume in KPIs 
 *************************************************************************/
public with sharing class AITM_DeBriefKeyPerMetricsController {

	/**
     * @description gets the tender details
     * @param tender of type AITM_Tender__c
     * @return AITM_Tender__c object
     */
	@AuraEnabled
	public static AITM_Tender__c getTender(AITM_Tender__c tender) {
		TenderAdapter tenderAdapter = new TenderAdapter(tender);
		return tenderAdapter.tender;
	}

	/**
     * @description Adapter class to hold tender details
     */ 
	public class TenderAdapter{
		public AITM_Tender__c tender;
		private final ID TLLI_ID_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();

		/**
     	 * @description overloaded constructor
     	 * @param tender of type AITM_Tender__c
    	 */
		public TenderAdapter(AITM_Tender__c tender){
			this.tender = tender;
			this.assignValuesForNewContract();
		}

		/**
     	 * @description assigns values for the new contract
     	 * @param null
     	 * @return void
    	 */
		private void assignValuesForNewContract(){
			List<AITM_Tender_Location_Line_Item__c> deBriefCurrentRoundLineItems = new AITM_LocationsDao().getTenderLocationLineItemsForDeBriefPerMetrics(tender.Id,  TLLI_ID_RECORD_TYPE_DEBRIEF);
			Boolean updateTenderFlag = false;
			Decimal volumeNewContract = 0;
			Decimal grossProfitNewContract = 0;
			Decimal workingCaptialNewContract = 0;
			Decimal ppiAndVolumeMultiplicationSumNewContract = 0;
			Decimal volumePrevContract = 0;
			Decimal grossProfitPrevContract = 0;
			Decimal workingCaptialPrevContract = 0;
			Decimal ppiAndVolumeMultiplicationSumPrevContract = 0;
			
			//loop through List collection of deBriefCurrentRoundLineItems
			for(AITM_Tender_Location_Line_Item__c lineItem : deBriefCurrentRoundLineItems) {
				if(lineItem.AITM_Awarded_Volume__c != null) {
			    	volumeNewContract += lineItem.AITM_Awarded_Volume__c;
				}
				if(lineItem.AITM_Gross_Profit__c != null) {
					grossProfitNewContract += lineItem.AITM_Gross_Profit__c;
				}
				if(lineItem.AITM_Working_Capital__c != null) {
					workingCaptialNewContract = lineItem.AITM_Working_Capital__c;
				}
				if(lineItem.AITM_History_Line_Item__r.AITM_Offered_Volume__c != null) {
			    	volumePrevContract += lineItem.AITM_History_Line_Item__r.AITM_Offered_Volume__c;
				}
				if(lineItem.AITM_History_Line_Item__r.AITM_Gross_Profit__c != null) {
					grossProfitPrevContract += lineItem.AITM_History_Line_Item__r.AITM_Gross_Profit__c;
				}
				if(lineItem.AITM_History_Line_Item__r.AITM_Working_Capital__c != null) {
					workingCaptialPrevContract = lineItem.AITM_History_Line_Item__r.AITM_Working_Capital__c;
				}
				if(lineItem.AITM_PPI__c != null && lineItem.AITM_PPI__c != 0 && lineItem.AITM_Offered_Volume__c != null && lineItem.AITM_Offered_Volume__c != 0) {
					ppiAndVolumeMultiplicationSumNewContract += lineItem.AITM_PPI__c*lineItem.AITM_Offered_Volume__c;
				}
				if(lineItem.AITM_History_Line_Item__r.AITM_PPI__c != null && lineItem.AITM_History_Line_Item__r.AITM_PPI__c != 0 && lineItem.AITM_History_Line_Item__r.AITM_Offered_Volume__c != null && lineItem.AITM_History_Line_Item__r.AITM_Offered_Volume__c != 0) {
					ppiAndVolumeMultiplicationSumPrevContract += lineItem.AITM_History_Line_Item__r.AITM_PPI__c*lineItem.AITM_History_Line_Item__r.AITM_Offered_Volume__c;
				}

			}

			tender.AITM_Volume_New_Contract__c = volumeNewContract;
				
			if(tender.AITM_Gross_Profit_New_Contract__c == null || tender.AITM_Gross_Profit_New_Contract__c == 0) {
				tender.AITM_Gross_Profit_New_Contract__c = grossProfitNewContract;
				updateTenderFlag = true;
			}
			if(tender.AITM_Working_Capital_New_Contract__c == null || tender.AITM_Working_Capital_New_Contract__c == 0) {
				tender.AITM_Working_Capital_New_Contract__c = workingCaptialNewContract;
				updateTenderFlag = true;
			}
			if((tender.AITM_Gross_Profit_New_Contract__c != null && tender.AITM_Gross_Profit_New_Contract__c != 0) || (tender.AITM_Working_Capital_New_Contract__c != null && tender.AITM_Working_Capital_New_Contract__c != 0)) {
				if(tender.AITM_Working_Capital_New_Contract__c != null && tender.AITM_Working_Capital_New_Contract__c != 0) {
					tender.AITM_ROWC_New_Contract__c = tender.AITM_Gross_Profit_New_Contract__c/tender.AITM_Working_Capital_New_Contract__c;
				}
				else {
					tender.AITM_ROWC_New_Contract__c = tender.AITM_Gross_Profit_New_Contract__c;
				}
				updateTenderFlag = true;
			}
			if(tender.AITM_Price_Perf_Index_New_Contract__c == null || tender.AITM_Price_Perf_Index_New_Contract__c == 0) {
				if(volumeNewContract != 0) {
					tender.AITM_Price_Perf_Index_New_Contract__c = ppiAndVolumeMultiplicationSumNewContract/volumeNewContract;
				}
				else {
					tender.AITM_Price_Perf_Index_New_Contract__c = ppiAndVolumeMultiplicationSumNewContract;
				}
				updateTenderFlag = true;
			}
			if((tender.AITM_Volume_Previous_Contract__c== null || tender.AITM_Volume_Previous_Contract__c ==0) && (tender.AITM_Price_Perf_Index_Prev_Contract__c ==null)) {
                 tender.AITM_Volume_Previous_Contract__c=volumePrevContract ;
                  updateTenderFlag = true;
            }
					if(tender.AITM_Gross_Profit_Previous_Contract__c == null || tender.AITM_Gross_Profit_Previous_Contract__c == 0) {
				tender.AITM_Gross_Profit_Previous_Contract__c = grossProfitPrevContract;
				updateTenderFlag = true;
			}
			if(tender.AITM_Working_Capital_Previous_Contract__c == null || tender.AITM_Working_Capital_Previous_Contract__c == 0) {
				tender.AITM_Working_Capital_Previous_Contract__c = workingCaptialPrevContract;
				updateTenderFlag = true;
			}
			if((tender.AITM_Gross_Profit_Previous_Contract__c != null && tender.AITM_Gross_Profit_Previous_Contract__c != 0) || (tender.AITM_Working_Capital_Previous_Contract__c != null && tender.AITM_Working_Capital_Previous_Contract__c != 0)) {
				if(tender.AITM_Working_Capital_Previous_Contract__c != null && tender.AITM_Working_Capital_Previous_Contract__c != 0) {
					tender.AITM_ROWC_Previous_Contract__c = tender.AITM_Gross_Profit_Previous_Contract__c/tender.AITM_Working_Capital_Previous_Contract__c;
				}
				else {
					tender.AITM_ROWC_Previous_Contract__c = tender.AITM_Gross_Profit_Previous_Contract__c;
				}
				updateTenderFlag = true;
			}
			if(tender.AITM_Price_Perf_Index_Prev_Contract__c == null || tender.AITM_Price_Perf_Index_Prev_Contract__c == 0) {
				if(volumePrevContract != 0) {
					tender.AITM_Price_Perf_Index_Prev_Contract__c = ppiAndVolumeMultiplicationSumPrevContract/volumePrevContract;
				}
				else {
					tender.AITM_Price_Perf_Index_Prev_Contract__c = ppiAndVolumeMultiplicationSumPrevContract;
				}
				updateTenderFlag = true;
			}

			//if flag is true update tender
			if(updateTenderFlag) {
				update tender;
			}
		}
	}
}