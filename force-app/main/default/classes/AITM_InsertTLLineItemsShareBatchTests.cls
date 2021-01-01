/***************************************************************
 * @author          Saravan
 * @date             10/May/2019
 * @group            AirBP
 * @description      Test class for AITM_InsertTLLineItemsShareBatch

 * history
 * 10/May/2019  	 Saravan      Created 
 **********************************************************/
@isTest 
public inherited sharing class AITM_InsertTLLineItemsShareBatchTests {
    /**
* @description tests to verify tender location line item share records inserted
* @param  null
* @return void
*/
    @isTest  
    static void testInsertTenderLocationLineItemsShare() {
        
        InsertTLLineItemsShareBatchSetup testSetup = new InsertTLLineItemsShareBatchSetup().generateData();        
        List<AITM_Tender_Location_Line_Item__Share>  allTllShares = new List<AITM_Tender_Location_Line_Item__Share>();        
        List<AITM_Tender_Location_Line_Item__c> allTenderLocationLineItems = testSetup.tenderLocationLineItems;
        AITM_Tender_Location_Line_Item__Share  tllShare = new AITM_Tender_Location_Line_Item__Share();
        List<User> allDelegates = testSetup.delegates;
        
        for(User delegate : allDelegates){            
            tllShare.UserOrGroupId = delegate.id;
            tllShare.ParentId= allTenderLocationLineItems[0].id;
            tllShare.AccessLevel= 'Edit';
            tllShare.RowCause= 'Sharing_To_Pricing_Delegates__c';
            allTllShares.add(tllShare);
        }
        AITM_InsertTLLineItemsShareBatch.BatchFactory batchFactory = new AITM_InsertTLLineItemsShareBatch.BatchFactory();
        
        Test.startTest();
        System.assertEquals(1, allTllShares.size(), 'Sharing is success');
        batchFactory.executeBatch(new AITM_InsertTLLineItemsShareBatch.BatchState(allTllShares));
        Test.stopTest();
    }
    
    /**
* @description tests to check return done state if no job executed
* @param  null
* @return void
*/
    @isTest  
    static void testCheckWillReturnDoneStateIfNoJobExecuted() {
        InsertTLLineItemsShareBatchSetup testSetup = new InsertTLLineItemsShareBatchSetup().generateData();
        AITM_InsertTLLineItemsShareBatch.BatchFactory batchFactory = new AITM_InsertTLLineItemsShareBatch.BatchFactory();
        Test.startTest();
        String result = batchFactory.check();
        Test.stopTest();
        
        System.assertEquals('DONE', result, 'DONE');
    }
    
    /**
* @description class holds test data preparation
*/
    private inherited sharing class InsertTLLineItemsShareBatchSetup extends AITM_TestSetup {
        private List<Account> accounts;
        private List <AITM_Tender_Account__c> tenderAccount;
        private List<AITM_Location__c> locations;
        private List<AITM_Tender__c> tenders;
        private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        private List<User> delegates;        
        
        /**
* @description generates test data
* @param  null
* @return InsertTLLineItemsShareBatchSetup
*/
        private InsertTLLineItemsShareBatchSetup generateData(){
            accounts = createAccounts(10);
            insert accounts;
            
            tenders = createTenders(1);
            insert tenders;
            
            locations = createLocations(10);
            insert locations;
            
            tenderAccount = createTenderAccounts(tenders, accounts);
            insert tenderAccount;
            
            tenderLocationLineItems = createTenderLocationLineItems(tenders, accounts, locations);
            insert tenderLocationLineItems;
            
            delegates = createUsers(1, 'Air_TMLocation Manager');
            insert delegates;			
            
            return this;
        }
        
        
    }
    
}