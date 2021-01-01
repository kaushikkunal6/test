/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Trigger handler class for TenderLocationsStaging
 
 * history
 * 01/December/2017  George       Created
 * 23/Aug/2018       Shweta        Added the keyword 'with sharing' for sonar qube fixes and added the comments for each method
 **********************************************************************************************/


public with sharing class AITM_TenderLocationStagingHandler implements AITM_TriggerFactory.SObjectHandler {

    private List<AITM_Tender_Location_Line_Item__c> lineItems;

    /**
     * @description This is a constructor for the class AITM_TenderLocationStagingHandler
     * @param No Parameters
     * @return No return
     */

    public AITM_TenderLocationStagingHandler() {
        lineItems = new List<AITM_Tender_Location_Line_Item__c>();
    }
    /**
     * @description bulk before factory method operation SObject handler
     * @param null
     * @return null
     */

    public void bulkBefore(){}

    /**
     * @description bulk after factory method operation SObject handler
     * @param null
     * @return null
     */
    public void bulkAfter(){}

    /**
     * @description before insert trigger event
     * @param so of type SObject
     * @return null
     */
    public void beforeInsert(SObject so){}

    /**
     * @description before update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return null
     */
    public void beforeUpdate(SObject oldSo, SObject so){}

    /**
     * @description before delete operation of trigger event
     * @param so of type SObject to hold new values
     * @return null
     */
    public void beforeDelete(SObject so){}

    /**
     * @description after insert operation of trigger event
     * @param so of type SObject to hold new values
     * @return null
     */

    public void afterInsert(SObject so){
        lineItems.add(new AITM_LocationsDao().parseLocationLineItem((AITM_Tender_Location_Staging__c) so));
    }

    /**
     * @description after update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return null
     */

    public void afterUpdate(SObject oldSo, SObject so){    }

    /**
     * @description after delete operation of trigger event
     * @param so of type SObject to hold new values
     * @return null
     */

    public void afterDelete(SObject so){}

    /**
     * @description finally block called for trigger handler 
     * @param null
     * @return null
     */

    public void andFinally() {
        if (Trigger.isInsert) {
            Database.insert(lineItems, false);
            Database.delete([SELECT Id FROM AITM_Tender_Location_Staging__c WHERE Id IN :Trigger.new], false);
        }
    }
}