@isTest 
private class AITM_OfferCurrentPerformanceCntlrTests {
    @isTest 
    static void testVoidListWillBeReturned() {
        OfferCurrentPerformanceCntlrTestSetup testSetup = new OfferCurrentPerformanceCntlrTestSetup().generateData();

        AITM_Tender_Location__c tenderLocation=[select id from AITM_Tender_Location__c limiT 1];
        Test.startTest();
            List<AITM_OfferCurrentPerformanceController.CustomerPerformanceAdapter> adapters = AITM_OfferCurrentPerformanceController.getCustomers(tenderLocation.Id);
        Test.stopTest();

        System.assertEquals(10, adapters.size());
    }
    

    static @isTest void tesNonVoidListWillBeReturned() {
        OfferCurrentPerformanceCntlrTestSetup testSetup = new OfferCurrentPerformanceCntlrTestSetup().generateData();

        Test.startTest();
            List<AITM_OfferCurrentPerformanceController.CustomerPerformanceAdapter> adapters = AITM_OfferCurrentPerformanceController.getCustomers(testSetup.tenderLocation.Id);
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocationLineItems.size(), adapters.size());
    }

    private class OfferCurrentPerformanceCntlrTestSetup extends AITM_TestSetup {

        public AITM_OfferCurrentPerformanceController classUnderTest;
         
        public AITM_Location__c location;
        public AITM_Tender__c tender;
        public Account account;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        public AITM_Tender_Location__c tenderLocation;

        public final Integer ITEMS_COUNT = 10;
        private final ID TLLI_ID_RECORD_TYPE_DEFAULT = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        
        public OfferCurrentPerformanceCntlrTestSetup generateData(){

            classUnderTest = new AITM_OfferCurrentPerformanceController();
    

            account = this.createAccount();
            insert account;

            location = this.createLocation();
            insert location;

            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            tender.AITM_Stage__c = 'Awaiting Price';
            insert tender;

            tenderLocation = this.createTenderLocation(tender.Id, location.Id, 1);
            insert tenderLocation;

            tenderLocationLineItems = createTenderLocationLineItems();
            for(AITM_Tender_Location_Line_Item__c lineItem : tenderLocationLineItems) {
                lineItem.AITM_Tender_Location__c =tenderLocation.id;
            }
            insert tenderLocationLineItems;
            
            

            return this;
        }

        public List<AITM_Tender_Location_Line_Item__c> createTenderLocationLineItems() {
            List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
            for(Integer i = 0; i < this.ITEMS_COUNT; i++){
                items.add( 
                    this.createTenderLocationLineItem(tender.Id, account.Id, location.Id, tenderLocation.Id)
                    );
            }
            return items;
        }

        public AITM_Tender_Location__c createTenderLocation(Id tenderId, Id locationId, Integer round) {
            return new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = locationId,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = 'Ready',
                AITM_Current_Round__c = round,
                AITM_Round__c = round
            );
        }

        public AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0,
                AITM_Requested_Volume_USG__c = 1,
                AITM_Round__c = 1,
                AITM_Gross_Profit__c = 10.0,
                AITM_Working_Capital__c = 20,
                AITM_Return_On_WC__c = '30',
                RecordTypeId = TLLI_ID_RECORD_TYPE_DEFAULT
                
                );
        }
    }

}