@isTest 
private class AITM_TenderLocationParserTests {

    @isTest 
    static void testGetGRNCodesWillParseOnlyGRNCodesFromGlobalRef() {
        TenderLocationParserTestSetup testSetup = new TenderLocationParserTestSetup().generateData();

        Test.startTest();
            List<String> results = testSetup.classUnderTest.getGRNCodes(testSetup.getGRNCodesLineglobalref());
        Test.stopTest();

        System.assertEquals(7, results.size());
    }

    @isTest 
    static void testGetGRNCodesWillParseOnlyTMSDIFF() {
        TenderLocationParserTestSetup testSetup = new TenderLocationParserTestSetup().generateData();

        Test.startTest();
            List<String> results = testSetup.classUnderTest.getGRNCodes(testSetup.getGRNCodesLinetmsdiff());
        Test.stopTest();

        System.assertEquals(7, results.size());
    }

    @isTest 
    static void testParsingFromADummyLineWillReturnAVoidListOfTenderLineAdapters() {
        TenderLocationParserTestSetup testSetup = new TenderLocationParserTestSetup().generateData();

        Test.startTest();
            List<AITM_TenderLocationParser.TenderLocationAdapter> results = testSetup.classUnderTest.parse(testSetup.tender.Id, testSetup.getDummyLine());
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    @isTest 
    static void testParsingFromARealLineWillReturnTheValidNumbersOfTenderLocationAdapter() {
        TenderLocationParserTestSetup testSetup = new TenderLocationParserTestSetup().generateData();

        Test.startTest();
            List<AITM_TenderLocationParser.TenderLocationAdapter> results = testSetup.classUnderTest.parse(testSetup.tender.Id, testSetup.getTenderLocationsLine());
        Test.stopTest();

        System.assertEquals(10, results.size());
        System.assertEquals(testSetup.tender.Id, results[0].tenderId);
    }

    @isTest 
    static void testFullParseWillReturnAVoidListOnVoidInput() {
        TenderLocationParserTestSetup testSetup = new TenderLocationParserTestSetup().generateData();

        Test.startTest();
           List<AITM_TenderLocationParser.TenderLocationAdapter> tenderAdapters = testSetup.classUnderTest.parse(testSetup.tender.Id, testSetup.getDummyLine());
           List<AITM_Tender_Location_Line_Item__c> results = testSetup.classUnderTest.getTenderLocations(JSON.serialize(tenderAdapters), new List<String>{'11', '12'});
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    @isTest 
    static void testFullParseWillReturnAValidResultOnAValidLineParsed() {
        TenderLocationParserTestSetup testSetup = new TenderLocationParserTestSetup().generateData();

        Test.startTest();
           List<AITM_TenderLocationParser.TenderLocationAdapter> tenderAdapters = testSetup.classUnderTest.parse(testSetup.tender.Id, testSetup.getTenderLocationsLine());
           List<String> grnCodes = new List<String>{'1000000','1000002','1000006','1000004'};
           List<AITM_Tender_Location_Line_Item__c> results = testSetup.classUnderTest.getTenderLocations(JSON.serialize(tenderAdapters), grnCodes);
        Test.stopTest();

        //18 - number on non-blank volumes in the test setup
        System.assertEquals(18, results.size());
        for (AITM_Tender_Location_Line_Item__c lineItem : results) {
            System.assertNotEquals(null, lineItem.AITM_Volume__c);
            System.assertEquals(testSetup.tender.AITM_Start_Date__c, lineItem.AITM_Start_Date__c);
            System.assertEquals(testSetup.tender.AITM_End_Date__c, lineItem.AITM_End_Date__c);
            System.assertEquals(testSetup.tender.Id, lineItem.AITM_Tender__c);   
        }
    }

    @isTest 
    static void testFullParseWillReturnAValidResultOnAValidLineParsedWithDates() {
        TenderLocationParserTestSetup testSetup = new TenderLocationParserTestSetup().generateData();

        Test.startTest();
           List<AITM_TenderLocationParser.TenderLocationAdapter> tenderAdapters = testSetup.classUnderTest.parse(testSetup.tender.Id, testSetup.getTenderLocationsLineWithDates());
           List<String> grnCodes = new List<String>{'1000000','1000002','1000006','1000004'};
           List<AITM_Tender_Location_Line_Item__c> results = testSetup.classUnderTest.getTenderLocations(JSON.serialize(tenderAdapters), grnCodes);
        Test.stopTest();

        //18 - number on non-blank volumes in the test setup
        System.assertEquals(18, results.size());
        for (AITM_Tender_Location_Line_Item__c lineItem : results) {
            System.assertNotEquals(null, lineItem.AITM_Volume__c);
            System.assertEquals(Date.newInstance(2017, 4, 4), lineItem.AITM_Start_Date__c);
            System.assertEquals(Date.newInstance(2018, 4, 4), lineItem.AITM_End_Date__c);
            System.assertEquals(testSetup.tender.Id, lineItem.AITM_Tender__c);   
        }
    }

    @isTest 
    static void testFullParseWillReturnAValidResultOnAValidLineParsedWithICAO() {
        TenderLocationParserTestSetup testSetup = new TenderLocationParserTestSetup().generateData();

        Test.startTest();
           List<AITM_TenderLocationParser.TenderLocationAdapter> tenderAdapters = testSetup.classUnderTest.parse(testSetup.tender.Id, testSetup.getTenderLocationsLineWithICAO());
           List<String> grnCodes = new List<String>{'1000000','1000002','1000006','1000004'};
           List<AITM_Tender_Location_Line_Item__c> results = testSetup.classUnderTest.getTenderLocations(JSON.serialize(tenderAdapters), grnCodes);
        Test.stopTest();

        //18 - number on non-blank volumes in the test setup
        System.assertEquals(18, results.size());
        for (AITM_Tender_Location_Line_Item__c lineItem : results) {
            System.assertNotEquals(null, lineItem.AITM_Volume__c);
            System.assertEquals(Date.newInstance(2017, 4, 4), lineItem.AITM_Start_Date__c);
            System.assertEquals(Date.newInstance(2018, 4, 4), lineItem.AITM_End_Date__c);
            System.assertEquals(testSetup.tender.Id, lineItem.AITM_Tender__c);   
        }
    }

    private class TenderLocationParserTestSetup extends AITM_TestSetup {
        public AITM_TenderLocationParser classUnderTest;
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;

        public TenderLocationParserTestSetup generateData(){
            classUnderTest = new AITM_TenderLocationParser();

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

        public String getGRNCodesLineglobalref() {
            return 'GLOBALREF 1000000 1000001 1000002 1000003 1000004 1000005 1000006';
        }

        public String getGRNCodesLinetmsdiff() {
            return 'TMSDIFF 1000000 1000001 1000002 1000003 1000004 1000005 1000006';
        }

        public String getDummyLine() {
            return 'dummy line';
        }

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

        public String getTenderLocationsLineWithDates() {
            return   'Y0:1:20170404:20180404 "884,000"   LT  "2,000" "863,000"   "19,000"     -' + '\r\n'
                   + 'Y1:1:20170404:20180404 "23,231"    LT  "2,000"  -      "5,000" "16,231"' + '\r\n'
                   + 'Y2:1:20170404:20180404 "12,000"    LT  "2,000"  -      "10,000"     -'   + '\r\n'
                   + 'Y3:1:20170404:20180404 "15,000"    LT   -       -      "15,000"     -'   + '\r\n'
                   + 'Y4:1:20170404:20180404 "10,000"    LT   -       -      "10,000"     -'   + '\r\n'
                   + 'Y5:1:20170404:20180404 "16,000"    LT   -      "16,000"     -       -'   + '\r\n'
                   + 'Y6:1:20170404:20180404 "10,000"    LT   -      "10,000"     -       -'   + '\r\n'
                   + 'Y7:1:20170404:20180404 "7,000" LT   -      "4,000" "3,000"  -   '        + '\r\n'
                   + 'Y8:1:20170404:20180404 "7,000" LT   -      "4,000" "3,000"  -   '        + '\r\n'
                   + 'Y9:1:20170404:20180404 "7,000" LT   -      "4,000" "3,000"  -   ';
        }

        public String getTenderLocationsLineWithICAO() {
            return   'CY0:1:20170404:20180404 "884,000"   LT  "2,000" "863,000"   "19,000"     -' + '\r\n'
                   + 'CY1:1:20170404:20180404 "23,231"    LT  "2,000"  -      "5,000" "16,231"' + '\r\n'
                   + 'CY2:1:20170404:20180404 "12,000"    LT  "2,000"  -      "10,000"     -'   + '\r\n'
                   + 'CY3:1:20170404:20180404 "15,000"    LT   -       -      "15,000"     -'   + '\r\n'
                   + 'CY4:1:20170404:20180404 "10,000"    LT   -       -      "10,000"     -'   + '\r\n'
                   + 'CY5:1:20170404:20180404 "16,000"    LT   -      "16,000"     -       -'   + '\r\n'
                   + 'CY6:1:20170404:20180404 "10,000"    LT   -      "10,000"     -       -'   + '\r\n'
                   + 'CY7:1:20170404:20180404 "7,000" LT   -      "4,000" "3,000"  -   '        + '\r\n'
                   + 'CY8:1:20170404:20180404 "7,000" LT   -      "4,000" "3,000"  -   '        + '\r\n'
                   + 'CY9:1:20170404:20180404 "7,000" LT   -      "4,000" "3,000"  -   ';
        }
    }

}