/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Trigger handler class for TenderLocNotification
 
 * history
 * 01/December/2017  George       Created
 * 17/Aug/2018       Shweta       Modified Added comments for each method and added with sharing with class
 **********************************************************************************************/

public with sharing class AITM_TenderLocNotificationHandler {

	public static final String STATUS_AWAITING_PRICE = 'Awaiting price';
	private Set<Id> tenderIds;

	/**
     * @description This is a constructor for the class AITM_TenderLocationStagingHandler
     * @param No Parameters
     * @return No return
     */

	public AITM_TenderLocNotificationHandler(){
		tenderIds = new Set<Id>();
	}

	/**
     * @description collect tender location in 'Awaiting Price Status' in current round
     * @param tenderLocation of type AITM_Tender_Location__c 
     * @return null
     */

    public void collect(AITM_Tender_Location__c tenderLocation) {
    	if(tenderLocation.AITM_Status__c == STATUS_AWAITING_PRICE && tenderLocation.AITM_Is_Current_Round__c) {
    		tenderIds.add(tenderLocation.AITM_Tender__c);
    	}
    }

	/**
     * @description Update tenders to send notifications
     * @param Null 
     * @return null
     */

    public void updateTendersToSendNotifications() {
        List<AITM_Tender__c> tenders = new AITM_TenderDao().getTenderWithTenderLocations(new List<Id>(this.tenderIds));
        List<AITM_Tender__c> tendersToUpdate = new List<AITM_Tender__c>();

        for (AITM_Tender__c tender : tenders) {
        	if(tender.AITM_Send_Invitation_Notification__c == false) {
        		tender.AITM_Send_Invitation_Notification__c = true;
        		tendersToUpdate.add(tender);
        	}
        }

        update tendersToUpdate;
    }

}