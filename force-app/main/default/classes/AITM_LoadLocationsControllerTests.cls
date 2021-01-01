/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_LoadLocationsController
 * history
 * 01/December/2017  George       Created
 * 10/Aug/2018       Ravi         Modified - added method level comments as per coding standards
 * 02/February/2019  srnandan     Added new test methods
 *******************************************************************/
@isTest  
private class AITM_LoadLocationsControllerTests {

    /**
     * @description tests to Validation on GRN that will return error on No Tender Accont on a Tender
     * @param  null
     * @return void
     */    
    @isTest  
    static void testValidationOnGRNWillReturnErrorOnNoTenderAccountOnATender() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            String result = AITM_LoadLocationsController.validateGRNCodes(testSetup.tender.Id, testSetup.getGRNCodesLineglobalref());
        Test.stopTest();

        System.assert(String.isNotBlank(result));
        System.assert(result.contains('10'), 'At Least One Of The GRN Codes Should Be In Error Message');
    }

    

    /**
     * @description tests to Validation on IATA on Wrong IATA that will return error on invalid IATA codes
     * @param  null
     * @return void
     */
    @isTest  
    static void testValidationIATAOnWrongIATAWillReturnErrorLineOnInvalidIATACodes() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            String result = AITM_LoadLocationsController.validateLocationCodes(testSetup.getInvalidIATACodes());
        Test.stopTest();

        System.assert(String.isNotBlank(result));
        System.assert(result.contains('ZAZ'), 'At Least One Of The IATA Codes Should Be In Error Message');  
    }

    /**
     * @description tests to Validation on IATA on Correct IATA will retrun blank
     * @param  null
     * @return void
     */
    @isTest  
    static void testValidationIATAOnCorrectIATAWillReturnBlankString() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            String result = AITM_LoadLocationsController.validateLocationCodes(testSetup.getValidIATACodes());
        Test.stopTest();

        System.assert(String.isBlank(result));
    }

    /**
     * @description tests to Validation on ICAO on wrong ICAO will return error with invalid IACO Codes
     * @param  null
     * @return void
     */
    @isTest  
    static void testValidationICAOOnWrongICAOWillReturnErrorLineOnInvalidICAOCodes() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            String result = AITM_LoadLocationsController.validateLocationCodes(testSetup.getInvalidICAOCodes());
        Test.stopTest();

        System.assert(String.isNotBlank(result));
        System.assert(result.contains('ZZAZ'), 'At Least One Of The ICAO Codes Should Be In Error Message');  
    }

    /**
     * @description tests to Validation on ICAO on correct ICAO will return blank
     * @param  null
     * @return void
     */
    @isTest  
    static void testValidationICAOOnCorrectICAOWillReturnBlankString() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            String result = AITM_LoadLocationsController.validateLocationCodes(testSetup.getValidICAOCodes());
        Test.stopTest();

        System.assert(String.isBlank(result));
    }

    /**
     * @description tests to Validation on IATA and ICAO on Correct IATA and IACO to return blank
     * @param  null
     * @return void
     */
    @isTest 
    static void testValidationIATAAndICAOOnCorrectIATAAndICAOWillReturnBlankString() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        List<String> validIATAAndICAOCodes = testSetup.getValidICAOCodes();
        validIATAAndICAOCodes.addAll(testSetup.getValidIATACodes());

        Test.startTest();
            String result = AITM_LoadLocationsController.validateLocationCodes(validIATAAndICAOCodes);
        Test.stopTest();

        System.assert(String.isBlank(result));
    }

    /**
     * @description tests to Parse a dummy line will return that do no insert any of the Tender Locations
     * @param  null
     * @return void
     */
    @isTest  
    static void testParsingFromADummyLineWillReturnDoNotInsertAnyOfTheTenderLocations() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            AITM_LoadLocationsController.parse(testSetup.tender.Id, testSetup.getDummyLine(), testSetup.getGRNCodesLineglobalref());
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
    }

    /**
     * @description tests to Parse batch a dummy line will return that do no insert any of the Tender Locations
     * @param  null
     * @return void
     */
    @isTest  
    static void testParsingBatchFromADummyLineWillReturnDoNotInsertAnyOfTheTenderLocations() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            AITM_LoadLocationsController.parseBatch(testSetup.tender.Id, testSetup.getDummyLine(), testSetup.getGRNCodesLineglobalref());
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
    }

    /**
     * @description tests to Parse a real line will actually insert the records to the database
     * @param  null
     * @return void
     */
    @isTest  
    static void testParsingFromARealLineWillActuallyInsertTheRecordsToTheDatabase() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            AITM_LoadLocationsController.parse(testSetup.tender.Id, testSetup.getTenderLocationsLine(), testSetup.getGRNCodesLineglobalref());
        Test.stopTest();

        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = [SELECT Id, AITM_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id];
        System.assertEquals(18, tenderLocationLineItems.size());
        for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocationLineItems) {
            System.assertNotEquals(null, lineItem.AITM_Volume__c);
            System.assertEquals(testSetup.tender.AITM_Start_Date__c, lineItem.AITM_Start_Date__c);
            System.assertEquals(testSetup.tender.AITM_End_Date__c, lineItem.AITM_End_Date__c);
            System.assertEquals(testSetup.tender.Id, lineItem.AITM_Tender__c);   
        }
    }

    /**
     * @description tests to Parse batch a real line will actually insert the records to the database
     * @param  null
     * @return void
     */
    @isTest  
    static void testParsingBatchFromARealLineWillActuallyInsertTheRecordsToTheDatabase() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            AITM_LoadLocationsController.parseBatch(testSetup.tender.Id, testSetup.getTenderLocationsLine(), testSetup.getGRNCodesLineglobalref());
        Test.stopTest();

        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = [SELECT Id, AITM_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id];
        System.assertEquals(18, tenderLocationLineItems.size());
        for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocationLineItems) {
            System.assertNotEquals(null, lineItem.AITM_Volume__c);
            System.assertEquals(testSetup.tender.AITM_Start_Date__c, lineItem.AITM_Start_Date__c);
            System.assertEquals(testSetup.tender.AITM_End_Date__c, lineItem.AITM_End_Date__c);
            System.assertEquals(testSetup.tender.Id, lineItem.AITM_Tender__c);   
        }
    }

    /**
     * @description tests to Parse a real line will actually insert the records to the data base with custom dates
     * @param  null
     * @return void
     */
    @isTest 
    static void testParsingFromARealLineWillActuallyInsertTheRecordsToTheDatabaseWithTheCustomDates() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            AITM_LoadLocationsController.parse(testSetup.tender.Id, testSetup.getTenderLocationsLineWithDates(), testSetup.getGRNCodesLineglobalref());
        Test.stopTest();

        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = [SELECT Id, AITM_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id];
        System.assertEquals(18, tenderLocationLineItems.size());
        for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocationLineItems) {
            System.assertNotEquals(null, lineItem.AITM_Volume__c);
            System.assertEquals(Date.newInstance(2017, 4, 4), lineItem.AITM_Start_Date__c);
            System.assertEquals(Date.newInstance(2017, 4, 5), lineItem.AITM_End_Date__c);
            System.assertEquals(testSetup.tender.Id, lineItem.AITM_Tender__c);   
        }
    }

    /**
     * @description tests to Parse batch a real line will actually insert the records to the data base with custom dates
     * @param  null
     * @return void
     */
    @isTest 
    static void testParsingBatchFromARealLineWillActuallyInsertTheRecordsToTheDatabaseWithTheCustomDates() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            AITM_LoadLocationsController.parseBatch(testSetup.tender.Id, testSetup.getTenderLocationsLineWithDates(), testSetup.getGRNCodesLineglobalref());
        Test.stopTest();

        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = [SELECT Id, AITM_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id];
        System.assertEquals(18, tenderLocationLineItems.size());
        for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocationLineItems) {
            System.assertNotEquals(null, lineItem.AITM_Volume__c);
            System.assertEquals(Date.newInstance(2017, 4, 4), lineItem.AITM_Start_Date__c);
            System.assertEquals(Date.newInstance(2017, 4, 5), lineItem.AITM_End_Date__c);
            System.assertEquals(testSetup.tender.Id, lineItem.AITM_Tender__c);   
        }
    }

    /**
     * @description tests to Parse a real line will actually insert the records to the database with ICAO instead of IATA codes
     * @param  null
     * @return void
     */
    @isTest 
    static void testParsingFromARealLineWillActuallyInsertTheRecordsToTheDatabaseWithTheICAOInsteadOfIATACodes() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            AITM_LoadLocationsController.parse(testSetup.tender.Id, testSetup.getTenderLocationsLineWithICAO(), testSetup.getGRNCodesLineglobalref());
        Test.stopTest();

        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = [SELECT Id, AITM_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id];
        System.assertEquals(18, tenderLocationLineItems.size());
        for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocationLineItems) {
            System.assertNotEquals(null, lineItem.AITM_Volume__c);
            System.assertEquals(testSetup.tender.AITM_Start_Date__c, lineItem.AITM_Start_Date__c);
            System.assertEquals(testSetup.tender.AITM_End_Date__c, lineItem.AITM_End_Date__c);
            System.assertEquals(testSetup.tender.Id, lineItem.AITM_Tender__c);   
        }
    }

    /**
     * @description tests to Parse batch a real line will actually insert the records to the database with ICAO instead of IATA codes
     * @param  null
     * @return void
     */
    @isTest 
    static void testParsingBatchFromARealLineWillActuallyInsertTheRecordsToTheDatabaseWithTheICAOInsteadOfIATACodes() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            AITM_LoadLocationsController.parseBatch(testSetup.tender.Id, testSetup.getTenderLocationsLineWithICAO(), testSetup.getGRNCodesLineglobalref());
        Test.stopTest();

        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = [SELECT Id, AITM_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id];
        System.assertEquals(18, tenderLocationLineItems.size());
        for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocationLineItems) {
            System.assertNotEquals(null, lineItem.AITM_Volume__c);
            System.assertEquals(testSetup.tender.AITM_Start_Date__c, lineItem.AITM_Start_Date__c);
            System.assertEquals(testSetup.tender.AITM_End_Date__c, lineItem.AITM_End_Date__c);
            System.assertEquals(testSetup.tender.Id, lineItem.AITM_Tender__c);   
        }
    }

    /**
     * @description tests to load from staging table
     * @param  null
     * @return void
     */
    @isTest 
    static void testLoadFromStaging() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            AITM_LoadLocationsController.loadFromStaging(testSetup.tender.Id);
        Test.stopTest();

        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = [SELECT Id, AITM_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id];
        System.assertEquals(0, tenderLocationLineItems.size());
        for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocationLineItems) {
            System.assertNotEquals(null, lineItem.AITM_Volume__c);
            System.assertEquals(testSetup.tender.AITM_Start_Date__c, lineItem.AITM_Start_Date__c);
            System.assertEquals(testSetup.tender.AITM_End_Date__c, lineItem.AITM_End_Date__c);
            System.assertEquals(testSetup.tender.Id, lineItem.AITM_Tender__c);   
        }
    }

    /**
     * @description tests to check return done state if no job executed
     * @param  null
     * @return void
     */
    @isTest  
    static void testCheckWillReturnDoneStateIfNoJobExecuted() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            String result = AITM_LoadLocationsController.check();
        Test.stopTest();

        System.assertEquals(AITM_LoadLocationsController.DONE_STATE, result);
    }

    /**
     * @description tests to check batch return done state if no job executed
     * @param  null
     * @return void
     */
    @isTest  
    static void testCheckBatchWillReturnDoneStateIfNoJobExecuted() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            String result = AITM_LoadLocationsController.checkBatch();
        Test.stopTest();

        System.assertEquals(AITM_LoadLocationsController.DONE_STATE, result);
    }

    /**
     * @description tests to check return running state when job is executed and done state after finish
     * @param  null
     * @return void
     */
    @isTest  
    static void testCheckWillReturnRunningStateWhenJobIsExecutedAndDoneStateAfterFinish() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            AITM_LoadLocationsController.parse(testSetup.tender.Id, testSetup.getTenderLocationsLineWithDates(), testSetup.getGRNCodesLineglobalref());
        Test.stopTest();
        
        String finishResult = AITM_LoadLocationsController.check();

        System.assertEquals(AITM_LoadLocationsController.DONE_STATE, finishResult);
    }
    
    /**
     * @description tests to check batch return running state when job is executed and done state after finish
     * @param  null
     * @return void
     */
    @isTest  
    static void testCheckBatchWillReturnRunningStateWhenJobIsExecutedAndDoneStateAfterFinish() {
        LoadLocationsControllerTestSetup testSetup = new LoadLocationsControllerTestSetup().generateData();

        Test.startTest();
            AITM_LoadLocationsController.parseBatch(testSetup.tender.Id, testSetup.getTenderLocationsLineWithDates(), testSetup.getGRNCodesLineglobalref());
        Test.stopTest();
        
        String finishResult = AITM_LoadLocationsController.checkBatch();

        System.assertEquals(AITM_LoadLocationsController.DONE_STATE, finishResult);
    }
    
    /**
     * @description test data holder Load Locations controller inner class
     */
    private class LoadLocationsControllerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;

        /**
         * @description tests to generate data like Account and Locations
         * @param  null
         * @return void
         */

        public LoadLocationsControllerTestSetup generateData(){
            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            tender.AITM_Start_Date__c = Date.today().addYears(-10);
            tender.AITM_End_Date__c = Date.today().addYears(10);
            insert tender;
            
            return this;
        }

        /**
         * @description tests to create Tender Accounts
         * @param  null
         * @return void
         */
        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        /**
         * @description tests to get GRN Codes Line Global reference
         * @param  null
         * @return void
         */

        public String getGRNCodesLineglobalref() {
            return 'GLOBALREF 1000000 1000001 1000002 1000003 1000004 1000005 1000006';
        }

        /**
         * @description tests to get Dummy Line
         * @param  null
         * @return void
         */

        public String getDummyLine() {
            return 'dummy line';
        }

        /**
         * @description tests to get Tender locations line Item
         * @param  null
         * @return void
         */
        public String getTenderLocationsLine() {
            return   'Y0 "884,000"   LT  "2,000" "863,000"   "19,000"     -' + '\r\n'
                   + 'Y1 "23,231"    LT  "2,000"  -      "5,000" "16,231"' + '\r\n'
                   + 'Y2 "12,000"    LT  "2,000"  -      "10,000"     -'   + '\r\n'
                   + 'Y3 "15,000"    LT   -       -      "15,000"     -'   + '\r\n'
                   + 'Y4 "10,000"    LT   -       -      "10,000"     -'   + '\r\n'
                   + 'Y5 "16,000"    LT   -      "16,000"     -       -'   + '\r\n'
                   + 'Y6 "10,000"    LT   -      "10,000"     -       -'   + '\r\n'
                   + 'Y7 "7,000" LT   -      "4,000" "3,000"  -   '        + '\r\n'
                   + 'Y8 "7,000" LT   -      "4,000" "3,000"  -   '        + '\r\n'
                   + 'Y9 "7,000" LT   -      "4,000" "3,000"  -   ';
        }

        /**
         * @description tests to get Tender Locations Line items with ICAO
         * @param  null
         * @return void
         */

        public String getTenderLocationsLineWithICAO() {
            return   'CY0 "884,000"   LT  "2,000" "863,000"   "19,000"     -' + '\r\n'
                   + 'CY1 "23,231"    LT  "2,000"  -      "5,000" "16,231"' + '\r\n'
                   + 'CY2 "12,000"    LT  "2,000"  -      "10,000"     -'   + '\r\n'
                   + 'CY3 "15,000"    LT   -       -      "15,000"     -'   + '\r\n'
                   + 'CY4 "10,000"    LT   -       -      "10,000"     -'   + '\r\n'
                   + 'CY5 "16,000"    LT   -      "16,000"     -       -'   + '\r\n'
                   + 'CY6 "10,000"    LT   -      "10,000"     -       -'   + '\r\n'
                   + 'CY7 "7,000" LT   -      "4,000" "3,000"  -   '        + '\r\n'
                   + 'CY8 "7,000" LT   -      "4,000" "3,000"  -   '        + '\r\n'
                   + 'CY9 "7,000" LT   -      "4,000" "3,000"  -   ';
        }

        /**
         * @description tests to get Tender Locations Line Items with Dates
         * @param  null
         * @return void
         */

        public String getTenderLocationsLineWithDates() {
            return   'Y0:1:20170404:20170405 "884,000"   LT  "2,000" "863,000"   "19,000"     -' + '\r\n'
                   + 'Y1:1:20170404:20170405 "23,231"    LT  "2,000"  -      "5,000" "16,231"' + '\r\n'
                   + 'Y2:1:20170404:20170405 "12,000"    LT  "2,000"  -      "10,000"     -'   + '\r\n'
                   + 'Y3:1:20170404:20170405 "15,000"    LT   -       -      "15,000"     -'   + '\r\n'
                   + 'Y4:1:20170404:20170405 "10,000"    LT   -       -      "10,000"     -'   + '\r\n'
                   + 'Y5:1:20170404:20170405 "16,000"    LT   -      "16,000"     -       -'   + '\r\n'
                   + 'Y6:1:20170404:20170405 "10,000"    LT   -      "10,000"     -       -'   + '\r\n'
                   + 'Y7:1:20170404:20170405 "7,000" LT   -      "4,000" "3,000"  -   '        + '\r\n'
                   + 'Y8:1:20170404:20170405 "7,000" LT   -      "4,000" "3,000"  -   '        + '\r\n'
                   + 'Y9:1:20170404:20170405 "7,000" LT   -      "4,000" "3,000"  -   ';
        }

        /**
         * @description tests to get Invalid IATA Codes
         * @param  null
         * @return void
         */

        public List<String> getInvalidIATACodes() {
            return new List<String>{'ZAZ', 'GAZ', 'YZX', 'BSD', 'SJW', 'BWM', 'TYT'};
        }

        /**
         * @description tests to get Invalid ICAO Codes
         * @param  null
         * @return void
         */

        public List<String> getInvalidICAOCodes() {
            return new List<String>{'ZZAZ', 'ZGAZ', 'ZYZX', 'ZBSD', 'ZSJW', 'ABWM', '1TYT'};
        }

        /**
         * @description tests to get Valid IATA Codes
         * @param  null
         * @return void
         */

        public List<String> getValidIATACodes() {
            return new List<String>{'Y0', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6'};
        }

        /**
         * @description tests to get Valid ICAO Codes
         * @param  null
         * @return void
         */

        public List<String> getValidICAOCodes() {
            return new List<String>{'CY0', 'CY1', 'CY2', 'CY3', 'CY4', 'CY5', 'CY6'};
        }
    }

}