/***************************************************************
 * @author           Ravi
 * @date             16/September/2019
 * @group            AirBP
 * @description      Test class for AITM_AddCustomerTenderLocation

 * history
 *16/Sept/2019   	 Ravi      Created
 **********************************************************/
@isTest 
public inherited sharing class AITM_AddCustomerTenderLocationTests {

    /**
      * @description tests to Show the grid and select customer then save TLLI to Tender Location
      * @param  null
      * @return void
      */
    @isTest 
    static void testSaveTenderLocationsWrapperWillPeformInsertWhenLocationAndVolumeAreFilled() {
        AddCustomerTenderLocationTestSetup testSetup = new AddCustomerTenderLocationTestSetup().generateData();

        Test.startTest();
            List<AITM_AddCustomerTenderLocation.TenderLocationWrapper> tenderLocations = AITM_AddCustomerTenderLocation.getAddCurrentTenderAccount(testSetup.tenderLocation.Id);
            for (AITM_AddCustomerTenderLocation.TenderLocationWrapper tenderLocation : tenderLocations) {
                tenderLocation.locationId = testSetup.locations[0].Id;
                tenderLocation.volume = 1;
                tenderLocation.isSelected = true;
            }
        String tenderId = testSetup.tender.Id;
        AITM_AddCustomerTenderLocation.TenderLocationWrapper tenderLocation_2 = new AITM_AddCustomerTenderLocation.TenderLocationWrapper(testSetup.tenderLocation, tenderId, testSetup.tenderAccount);
        tenderLocation_2.isSelected = true;
        String voidList = JSON.serialize(tenderLocation_2);
        system.debug('void List: ' + voidList);
        voidList = '[' +voidList+']';
    	system.debug('after append void List: ' + voidList);
            AITM_AddCustomerTenderLocation.saveTenderAccountWithRelatedData(voidList);
        Test.stopTest();

        System.assertEquals(2, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(1, totalVolume);
    }

    /**
      * @description class holds test data preparation
      */
    private class AddCustomerTenderLocationTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public AITM_Tender_Location__c tenderLocation;
        public AITM_Tender_Account__c tenderAccount;
        public AITM_Tender_Location_Line_Item__c tenderLocationLineItem;

        /**
          * @description generates test data
          * @param  null
          * @return AddCustomerTenderLocationTestSetup
          */
        public AddCustomerTenderLocationTestSetup generateData() {
            AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
			settings.AITM_IsActive__c = true;
			upsert settings AITM_DeactivateTriggerSetting__c.Id;
            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
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
          * @description creates tender location line items
          * @param  null
          * @return void
          */
        public void createTenderLocationLineItems() {
            insert createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }
    }

}