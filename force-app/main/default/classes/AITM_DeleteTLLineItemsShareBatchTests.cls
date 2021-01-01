/***************************************************************
 * @author          Saravan
 * @date             10/May/2019
 * @group            AirBP
 * @description      Test class for AITM_DelTLLineItemsShareBatch

 * history
 * 10/May/2019  	 Saravan      Created 
 **********************************************************/
@isTest 
public inherited sharing class AITM_DeleteTLLineItemsShareBatchTests{
    /**
* @description tests to verify tender location line item share records deleted
* @param  null
* @return void
*/
    @isTest  
    static void testDelTenderLocLineItemsShareBatch() {
        Test.startTest();
        delTLLineItemsShareBatchSetup testSetup = new delTLLineItemsShareBatchSetup().generateData();
        
        List<AITM_Tender_Location_Line_Item__Share>  TllShareRecords = testSetup.tllShares;      
        AITM_DeleteTLLineItemsShareBatch.BatchFactory batchFactory = new AITM_DeleteTLLineItemsShareBatch.BatchFactory();       
        System.assertEquals(2, TllShareRecords.size(), 'Sharing is success');
        batchFactory.executeBatch(new AITM_DeleteTLLineItemsShareBatch.BatchState(TllShareRecords));
        Test.stopTest();    
    }
    
    /**
* @description tests to check return done state if no job executed
* @param  null
* @return void
*/
    @isTest  
    static void testCheckWillReturnDoneStateIfNoJobExecuted() {
        delTLLineItemsShareBatchSetup testSetup = new delTLLineItemsShareBatchSetup().generateData();
        AITM_DeleteTLLineItemsShareBatch.BatchFactory batchFactory = new AITM_DeleteTLLineItemsShareBatch.BatchFactory();
        Test.startTest();
        String result = batchFactory.check();
        Test.stopTest();
        
        System.assertEquals('DONE', result, 'DONE');
    }
    
    /**
* @description class holds test data preparation
*/
    private inherited sharing class delTLLineItemsShareBatchSetup extends AITM_TestSetup {
        private List<Account> accounts;
        private List <AITM_Tender_Account__c> tenderAccount;
        private List<AITM_Location__c> locations;
        private List<AITM_Tender__c> tenders;
        private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        private List<User> delegates;
        private List<AITM_Tender_Location_Line_Item__Share>  tllShares;        
        /**
* @description generates test data
* @param  null
* @return InsertTLLineItemsShareBatchSetup
*/
        private delTLLineItemsShareBatchSetup generateData(){
            accounts = createAccounts(1);
            insert accounts;
            
            tenders = createTenders(1);
            insert tenders;
            
            locations = createLocations(1);
            insert locations;
            
            tenderAccount = createTenderAccounts(tenders, accounts);
            insert tenderAccount;
            
            tenderLocationLineItems = createTenderLocationLineItems(tenders, accounts, locations);
            insert tenderLocationLineItems;
            
            delegates = createUsers(2, 'Air_TMLocation Manager');
            insert delegates;  
            
            tllShares = createTenderLocationLineItemsShare(tenderLocationLineItems[0].id, delegates);
            insert tllShares;
            return this;
        }
        /**
* @description creates tender location line item share records
* @param  null
* @return List collection of type AITM_Tender_Location_Line_Item__Share
*/
        private List<AITM_Tender_Location_Line_Item__Share> createTenderLocationLineItemsShare(Id actId, List<User> allDelegates){
            List<AITM_Tender_Location_Line_Item__Share>  allTllShares = new List<AITM_Tender_Location_Line_Item__Share>();
            for(User delegate : allDelegates){
                AITM_Tender_Location_Line_Item__Share  tllShare = new AITM_Tender_Location_Line_Item__Share();
                tllShare.UserOrGroupId = delegate.id;
                tllShare.ParentId= actId;
                tllShare.AccessLevel= 'Edit';
                tllShare.RowCause= 'Sharing_To_Pricing_Delegates__c';
                allTllShares.add(tllShare);
                
            }
            return allTllShares;       
            
        }
        
    }
    
}