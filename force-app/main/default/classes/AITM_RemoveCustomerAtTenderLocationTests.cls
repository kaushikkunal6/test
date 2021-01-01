/***************************************************************
 * @author           Ravi
 * @date             16/September/2019
 * @group            AirBP
 * @description      Test class for AITM_RemoveCustomerAtTenderLocation

 * history
 *16/Sept/2019   	 Ravi      Created
 **********************************************************/
@isTest
public inherited sharing class AITM_RemoveCustomerAtTenderLocationTests {
    
    /**
      * @description tests to Show the grid and select customer then remove TLLI to Tender Location
      * @param  null
      * @return void
      */
    @isTest
    static void testRemoveCustomerAtTenderLocation() {
        AITM_RemoveCustomerAtTenderLocationTestsSetup testSetup = new AITM_RemoveCustomerAtTenderLocationTestsSetup().generateData();
        testSetup.createTenderLocationLineItems();
        
        Test.startTest();
        List<AITM_RemoveCustomerAtTenderLocation.TenderLocationWrapper> tenderLocations = AITM_RemoveCustomerAtTenderLocation.getRemoveCurrentTenderAccount(testSetup.tenderLocation.Id);
        boolean selectedFlag = true;
        for (AITM_RemoveCustomerAtTenderLocation.TenderLocationWrapper tenderLocation : tenderLocations) {
            tenderLocation.locationId = testSetup.locations[0].Id;
            if(selectedFlag) {
                tenderLocation.isSelected = true;
                selectedFlag = false;		
            }else{
                tenderLocation.isSelected = false;
            }
        }
        
        String tenderId = testSetup.tender.Id;
        
        AITM_RemoveCustomerAtTenderLocation.TenderLocationWrapper tenderLocation_2 = new AITM_RemoveCustomerAtTenderLocation.TenderLocationWrapper(testSetup.tenderLocation, tenderId, testSetup.tenderAccount);
        tenderLocation_2.isSelected = true;

        String voidList = JSON.serialize(tenderLocation_2);
        voidList = '[' +voidList+']';
        AITM_RemoveCustomerAtTenderLocation.deleteRecords(voidList);
        Test.stopTest();
       System.assertEquals(0, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
       Decimal totalVolume = 0;
       for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
           totalVolume += tenderLocationLine.AITM_Volume__c;
       }
       System.assertEquals(0, totalVolume);
    }
    
    /**
      * @description class holds test data preparation
      */
    private class AITM_RemoveCustomerAtTenderLocationTestsSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public AITM_Tender_Location__c tenderLocation;
        public AITM_Tender_Account__c tenderAccount;
        public AITM_Tender_Location_Line_Item__c tenderLocationLineItem;
        
        /**
          * @description generates test data
          * @param  null
          * @return AITM_RemoveCustomerAtTenderLocationTestsSetup
          */
        public AITM_RemoveCustomerAtTenderLocationTestsSetup generateData() {
            AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
            settings.AITM_IsActive__c = true;
            upsert settings AITM_DeactivateTriggerSetting__c.Id;
            accounts = createAccounts(1);
            insert accounts;
            
            locations = createLocations(1);
            insert locations;
            
            tender = createTender();
            insert tender;
            
            tenderLocation = createTenderLocation(tender.Id, locations[0].Id);
            insert tenderLocation;
            
            tenderAccount = createTenderAccount(tender.Id, accounts[0].Id);
            insert tenderAccount;
            
            tenderLocationLineItem = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            insert tenderLocationLineItem;
            
            return this;
        }
        
        /**
          * @description removes tender location line items
          * @param  null
          * @return void
          */
        public void createTenderLocationLineItems() {
            insert createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }
    }
}