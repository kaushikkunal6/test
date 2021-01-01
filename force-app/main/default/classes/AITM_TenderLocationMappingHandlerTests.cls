/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_TenderOfferPDFController

 * history
 * 01/December/2017      George       Created
 * 04/September/2018     Anusha       Modified - added method level comments as per coding standards 
 *******************************************************************/
@isTest  
private With Sharing class AITM_TenderLocationMappingHandlerTests {

    /**
     * @description tests to insert TL for Accounts
     * @param  null
     * @return void
     */
    @isTest  
    static void testInsertionOfTenderLocationsWillCreateRecordsIfThereAreNoRecordsForTenderAccountCombination() {
        TenderLocationMappingHandlerTestSetup testSetup = new TenderLocationMappingHandlerTestSetup().generateData();
        testSetup.createTenderLocationLineItems();

        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        Test.startTest();
            insert testSetup.tenderLocations;
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size(), [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(tenderLocationVolume*testSetup.tenderLocations.size(), totalVolume);
    }

    /**
     * @description tests to insert tenderLocations
     * @param  null
     * @return void
     */
    @isTest  
    static void testInsertionTenderLocationsWillUpdateRecordsIfTheyAreAlreadyCreated() {
        TenderLocationMappingHandlerTestSetup testSetup = new TenderLocationMappingHandlerTestSetup().generateData();
        
        testSetup.createTenderLocationLineItems();
        insert testSetup.tenderLocations;

        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
            tenderLocation.Id = null;
            tenderLocation.AITM_Volume__c = 5;
        }
        AITM_TenderLocationMappingHandler handler = new AITM_TenderLocationMappingHandler(); 
        Test.startTest();
            insert testSetup.tenderLocations;
            handler.upsertTenderLocations('onInsert');
            
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size()*2, [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c LIMIT 100]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals((5+1)*testSetup.tenderLocations.size(), totalVolume);
    }

    /**
     * @description tests insert adhoc volumes
     * @param  null
     * @return void
     */
    @isTest  
    static void testInsertWillUpdateRecordsIfTheyAreAdHocSoAllVolumesWillBeNull() {
        TenderLocationMappingHandlerTestSetup testSetup = new TenderLocationMappingHandlerTestSetup().generateData();
        
        testSetup.createTenderLocationLineItems();
        insert testSetup.tenderLocations;

        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
            tenderLocation.Id = null;
            tenderLocation.AITM_Volume__c = null;
            tenderLocation.AITM_Ad_hoc_Volume__c = true;
        }

        Test.startTest();
            insert testSetup.tenderLocations;
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size()*2, [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c == null ? 0 : tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals((1+0)*testSetup.tenderLocations.size(), totalVolume);
    }

    /**
     * @description tests to update TLLI with another TL
     * @param  null
     * @return void
     */
    @isTest  
    static void testUpdateOfTheTenderLocationLineItemTenderWillAlsoCreateAnotherTenderLocation() {
        TenderLocationMappingHandlerTestSetup testSetup = new TenderLocationMappingHandlerTestSetup().generateData();
        AITM_TenderLocationMappingHandler handler = new AITM_TenderLocationMappingHandler();

        testSetup.createTenderLocationLineItems();
        insert testSetup.tenderLocations;
        AITM_Tender__c newTender = testSetup.createNewTender();
        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
            tenderLocation.AITM_Tender__c = newTender.Id;
        }

        Test.startTest();           
            List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = testSetup.createTenderLocationLineItems(newTender);
            update testSetup.tenderLocations;
            handler.collect(tenderLocationLineItems[0]);
            handler.upsertTenderLocations('onUpdate'); 
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size(), [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :newTender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c LIMIT 100]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(tenderLocationVolume*testSetup.tenderLocations.size(), totalVolume);
      //  System.assertEquals(tenderLocationVolume*testSetup.tenderLocations.size(), [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :newTender.Id LIMIT 1][0].AITM_Volume__c);
    }

    /**
     * @description tests to verify attach record to another tenderLocation
     * @param  null
     * @return void
     */
    @isTest  
    static void testUpdateOfTheTenderLocationLineItemTenderWillAlsoAttachRecordsToAnotherTenderLocationIfItExists() {
        TenderLocationMappingHandlerTestSetup testSetup = new TenderLocationMappingHandlerTestSetup().generateData();
        AITM_TenderLocationMappingHandler handler = new AITM_TenderLocationMappingHandler();
        testSetup.createTenderLocationLineItems();
        insert testSetup.tenderLocations;
        
        Test.startTest();
            AITM_Tender__c newTender = testSetup.createNewTender();
            List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = testSetup.createTenderLocationLineItems(newTender);
            insert tenderLocationLineItems;
            handler.collect(tenderLocationLineItems[0]);
            handler.upsertTenderLocations('onInsert');
        
            handler.createTenderLocation(tenderLocationLineItems, 2);
            Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;
            for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
                tenderLocation.AITM_Tender__c = newTender.Id;
            }
            update testSetup.tenderLocations; 
            
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size()+tenderLocationLineItems.size(), [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :newTender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c LIMIT 100]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(tenderLocationVolume*(testSetup.tenderLocations.size()+tenderLocationLineItems.size()), totalVolume);
        //System.assertEquals(10, [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :newTender.Id LIMIT 1][0].AITM_Volume__c);
    }
    
    /**
     * @description tests to getClearDisabled
     * @param  null
     * @return void
     */
    @isTest 
    static void testGetClearDisabled() {
        Boolean flag = AITM_TenderLocationMappingHandler.getClearDisabled();
        System.assertEquals(false, flag);
    }
    
    /**
     * @description tests to delete TLLI with another TL
     * @param  null
     * @return void
     */
    @isTest  
    static void testDeleteOfTheTenderLocationLineItemTenderWillAlsoCreateAnotherTenderLocation() {
        TenderLocationMappingHandlerTestSetup testSetup = new TenderLocationMappingHandlerTestSetup().generateData();
        AITM_TenderLocationMappingHandler handler = new AITM_TenderLocationMappingHandler();
        testSetup.createTenderLocationLineItems();
        insert testSetup.tenderLocations;
        AITM_Tender__c newTender = testSetup.createNewTender();
        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
            tenderLocation.AITM_Tender__c = newTender.Id;
        }

        Test.startTest();
            delete testSetup.tenderLocations[0];
            List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = testSetup.createTenderLocationLineItems(newTender);
            handler.collect(tenderLocationLineItems[0], true);
            handler.upsertTenderLocations('onDelete');
        Test.stopTest();

        System.assertEquals(0 , [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :newTender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c LIMIT 100]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(tenderLocationVolume*testSetup.tenderLocations.size() - 1, totalVolume);
        //System.assertEquals(tenderLocationVolume*testSetup.tenderLocations.size() -1 , [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :newTender.Id LIMIT 1][0].AITM_Volume__c);
    }


    /**
     * @description test data tenderLocationMappingHandler inner class
     */ 
    private With Sharing class TenderLocationMappingHandlerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;

        /**
         * @description generates the test data for account, Location, Tender for the test class
         * @param  null
         * @return TenderLocationMappingHandlerTestSetup
         */

        public TenderLocationMappingHandlerTestSetup generateData(){
            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            insert tender;

            return this;
        }

        /**
         * @description tests to create TLLI
         * @param  null
         * @return void
         */

        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }

        /**
         * @description tests to create TLLI
         * @param  null
         * @return List
         */

        public List<AITM_Tender_Location_Line_Item__c> createTenderLocationLineItems(AITM_Tender__c anotherTender) {
            return createTenderLocationLineItems(new List<AITM_Tender__c>{anotherTender}, accounts, new List<AITM_Location__c>{locations[0]});
        }

        /**
         * @description tests to create tender
         * @param  null
         * @return void
         */

        public AITM_Tender__c createNewTender() {
            AITM_Tender__c result = createTender();
            result.Name = 'Test Another Tender';
            insert result;
            return result;
        }     
    }

}