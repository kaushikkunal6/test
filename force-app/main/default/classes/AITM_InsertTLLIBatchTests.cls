/***************************************************************
 * @author           Ravi
 * @date             28/May/2019
 * @group            AirBP
 * @description      Test class for AITM_InsertTenderLocationLineItemsBatch

 * history
 * 28/May/2019  	 Ravi      Created 
 **********************************************************/
@isTest 
public inherited sharing class AITM_InsertTLLIBatchTests {

    /**
     * @description tests to run the batch
     * @param  null
     * @return void
     */
    @isTest  
    static void testInsertBatchGeneration() {
        InsertTenderLocationLineItemsBatch testSetup = new InsertTenderLocationLineItemsBatch().generateData();      
        List<AITM_Tender_Location_Line_Item__c> allTenderLocationLineItems = testSetup.tenderLocationLineItems;

        AITM_InsertTenderLocationLineItemsBatch batchFactory = new AITM_InsertTenderLocationLineItemsBatch(testSetup.tender.Id, 'insert');
        Test.startTest();
            Database.executeBatch(batchFactory);
        Test.stopTest();
		System.assertEquals(10, allTenderLocationLineItems.size(), 'Batch processing is success');
    }

    /**
     * @description class holds test data preparation
     */
    private inherited sharing class InsertTenderLocationLineItemsBatch extends AITM_TestSetup {

        // variable to hold list of Accounts
        private List<Account> accounts;
        // variable to hold list of Accounts
        private List<AITM_Location__c> locations;
        // variable to hold list of Accounts
        private AITM_Tender__c tender;
        // variable to hold list of Accounts
        private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        // variable to hold list of Accounts
        private List<AITM_Tender_Location__c> tenderLocations;
        // variable to hold list of Accounts
        private List<User> locationManagers;
        // variable to hold list of Accounts
        private List<User> delegates;        

        /**
         * @description generates test data
         * @param  null
         * @return InsertTenderLocationLineItemsBatch
         */
        private InsertTenderLocationLineItemsBatch generateData(){

            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            insert tender;

            createTenderAccounts();

            locationManagers = createUsers(10, 'Air_TMLocation Manager');
            insert locationManagers;

            tenderLocations = createTenderLocations();
            insert tenderLocations;

            tenderLocationLineItems = createTenderLocationLineItems();
            insert tenderLocationLineItems;

            attachLocationManagersToTenderLocations(locationManagers, tenderLocations);
            attachLocationManagersToTenderLocationLineitems(locationManagers,tenderLocationLineItems);

            return this;
        }

        /**
         * @description creates tender locations
         * @param  null
         * @return List collection of type AITM_Tender_Location__c
         */
        private List<AITM_Tender_Location__c> createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
            for(AITM_Location__c location : locations){
                AITM_Tender_Location__c tenderLocation = createTenderLocation(tender.Id, location.Id);
                tenderLocation.AITM_Status__c = 'Priced';
                tenderLocations.add(tenderLocation);
            }
            return tenderLocations;
        }

        /**
         * @description attach location managers to tender locations
         * @param  locationManagers list collection of users
         * @param  tenderLocations list collection of AITM_Tender_Location__c
         * @return void
         */
        private void attachLocationManagersToTenderLocations(List<User> locationManagers, List<AITM_Tender_Location__c> tenderLocations) {

            List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
            Integer index = 0;

            for(AITM_Tender_Location__c tenderLocation : tenderLocations){
                tenderLocation.AITM_Location_Manager__c = locationManagers[index].Id;
                result.add(tenderLocation);
                index++;
            }

            upsert result;

        }

        /**
         * @description attach location managers to tender locations
         * @param  locationManagers list collection of users
         * @param  tenderLocations list collection of AITM_Tender_Location_Line_Item__c
         * @return void
         */
        private void attachLocationManagersToTenderLocationLineitems(List<User> locationManagers, List<AITM_Tender_Location_Line_Item__c> tenderLocations) {

            List<AITM_Tender_Location_Line_Item__c> result = new List<AITM_Tender_Location_Line_Item__c>();
            Integer index = 0;

            for(AITM_Tender_Location_Line_Item__c tenderLocation : tenderLocations){
                tenderLocation.OwnerId = locationManagers[index].Id;
                result.add(tenderLocation);
                index++;
            }

            upsert result;

        }

        /**
         * @description creates tender accounts
         * @param  null
         * @return void
         */
        private void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        /**
         * @description creates tenderlocationitems
         * @param  null
         * @return void
         */
        private List<AITM_Tender_Location_Line_Item__c> createTenderLocationLineItems() {
            tenderLocationLineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
           return tenderLocationLineItems;
        }

        /**
         * @description creates tenderlocationlineitem
         * @param  tenderId of type Id
         * @param  accountId of type Id
         * @return AITM_Tender_Location_Line_Item__c
         */
        private AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0,
                AITM_Offered_Volume__c = 1,
                RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId()
            );
        }
    }
}