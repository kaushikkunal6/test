/***********************************************************************************************
* @author           Shweta Agg
* @date             17/May/2018
* @group            AirBP
* @description      controller class used in aura component to change the start dates and End dates

* history
* 17/May/2018     Shweta Agg   Created AR-2400
************************************************************************************************/
@isTest 
private class AITM_ChangeDatesControllerTests {
    @isTest 
    static void testLineitemsWithStartDates() {
        ChangeDatesControllerTestSetup testSetup = new ChangeDatesControllerTestSetup();
        Test.startTest();        
        List<String> results = AITM_ChangeDatesController.getTenderLocationLineItemsStartDates(testSetup.tender.Id);
        Test.stopTest();
        String date1 =  Date.today().format();       
        System.assertEquals(false,results.contains(date1),'The start date is not of today date');
    }
    
    @isTest 
    static void testLineItemsWithEndDates() {
        ChangeDatesControllerTestSetup testSetup = new ChangeDatesControllerTestSetup();
        Test.startTest();        
            List<String> results = AITM_ChangeDatesController.getTenderLocationLineItemsEndDates(testSetup.tender.Id);
        Test.stopTest();
        String date2 =  Date.today().addYears(1).format();         
        System.assertEquals(false,results.contains(date2),'The end date is not of today with one year ahead');
    }
    
    @isTest 
    static void updateStartAndEndDate() {
        ChangeDatesControllerTestSetup testSetup = new ChangeDatesControllerTestSetup(); 
        String oldStartDate = '30/4/2018';
        String oldEndDate = '30/4/2010';
        String newStartDate = '2018-05-27';
        String newEndDate = '2019-06-06';
        
        Test.startTest();
            AITM_ChangeDatesController.updateLineItems(testSetup.tender.Id,oldStartDate,newStartDate,oldEndDate,newEndDate);
        Test.stopTest();
        System.assertEquals(10,[SELECT count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id ]);
        System.assertEquals(10,[SELECT count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id ]);
    } 
    
    private class ChangeDatesControllerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        
        public ChangeDatesControllerTestSetup() {
            accounts = createAccounts(10);
            insert accounts;
            locations = createLocations(10);
            insert locations;
            tender = createTender();
            insert tender;
            createTenderLocationLineItems();
        }
        
        public void createTenderLocationLineItems() {
            List<AITM_Tender_Location_Line_Item__c> lineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, new List<Account>{accounts[0]}, locations);  
            for(AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                lineItem.AITM_Start_Date__c =  Date.today().addMonths(-1);
                lineItem.AITM_End_Date__c =  Date.today().addMonths(-1).addYears(1);
            }
            insert lineItems;
        }  
    }   
}