/******************************************************************************************
*  Date          : 6-SEP-2019
*  Author        : Palash Awasthi
*  Description   : Test Class for BPI_FeedItem_Trigger_Handler
*  Modifications : 13-SEP-2019  - Initial
*            
* ***************************************************************************************/

@isTest
public class BPI_FeedItem_Trigger_Handler_Test {
    
    /*
Test Data setup for BPI_FeedItem_Trigger_Handler
*/
    
    @testsetup
    static void testDataSetup(){
        
        List<User> usrList = new List<User>();
        List<Account> accountList = new List<Account>();
        Profile p = [SELECT Id FROM Profile WHERE Name='ICRM Base']; 
        User u1 = new User(Alias = 'ICRMBase', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='ICRMBase1@testorg.com');
        User u2 = new User(Alias = 'ICRMBase', Email='standarduser2@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='ICRMBase2@testorg.com');
        User u3 = new User(Alias = 'ICRMBase', Email='standarduser3@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='ICRMBase3@testorg.com');
        
        usrList.add(u1);
        usrList.add(u2);
        usrList.add(u3);
        insert usrList;
        
        BPI_MRL_User__c mrlUser = new BPI_MRL_User__c (BPI_Email__c = 'standarduser1@testorg.com', BPI_MRL_Status__c = 'Active');
        insert mrlUser;
        
        Account acc1 = new Account();
        string recTypeid1 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Legal Entity').getRecordTypeId();
        acc1.RecordTypeId = recTypeid1;
        acc1.Name = 'Test Account1 for attaching Feed Item record';
        acc1.Ownerid = u1.Id;
        accountList.add(acc1);
        
        Account acc2 = new Account();
        string recTypeid2 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc2.RecordTypeId = recTypeid2;
        acc2.Name = 'Test Account2 for attaching Feed Item record';
        acc2.Ownerid = u2.Id;
        accountList.add(acc2);
        
        Account acc3 = new Account();
        acc3.RecordTypeId = recTypeid2;
        acc3.Name = 'Test Account3 for attaching Feed Item record';
        acc3.Ownerid = u3.Id;
        accountList.add(acc3);
        
        Account acc4 = new Account();
        acc4.RecordTypeId = recTypeid2;
        acc4.Name = 'Test Account4 for attaching Feed Item record';
        acc4.Ownerid = u1.Id;
        accountList.add(acc4);
        
        insert accountList;
        
    }
    
    /*
Test Class method to test prevention of Post to chatter for MRL users
*/
    
    @isTest
    public static void testPreventFeedItemPostForMRL(){
        
        Account acc1 = [SELECT id FROM Account WHERE Name='Test Account1 for attaching Feed Item record'];
        User u1 = [SELECT id, UserName from User WHERE UserName = 'ICRMBase1@testorg.com' AND Email='standarduser1@testorg.com' AND LastName='Testing1'];
        
        //Test Before insert 
        FeedItem testFeedItem = new FeedItem(Body = 'Test Feed Item body', Type = 'TextPost', parentId = acc1.Id );
        System.runAs(u1){
            try{
                insert testFeedItem;
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains(System.Label.Prevent_MRL_Users_from_Chatter_Post));
            }
            
        }
        
    }
    
    /*
Test Class method to test allowing of Post to chatter for Non-MRL users
*/
    
    @isTest
    public static void testAllowFeedItemPostForNonMRL(){
        
        Account acc2 = [SELECT id FROM Account WHERE Name='Test Account2 for attaching Feed Item record'];
        User u2 = [SELECT id, UserName from User WHERE UserName = 'ICRMBase2@testorg.com' AND Email='standarduser2@testorg.com' AND LastName='Testing2'];
        
        //Test Before insert 
        FeedItem testFeedItem = new FeedItem(Body = 'Test Feed Item body', Type = 'TextPost', parentId = acc2.Id );
        System.runAs(u2){
            Test.startTest();
            insert testFeedItem;  
            Test.stopTest();
        }
        FeedItem testFeedItemCheck = [SELECT Body FROM FeedItem WHERE parentId =: acc2.Id ];
        System.assertEquals(testFeedItem.Body, testFeedItemCheck.Body, 'Test Class on Feed Comment Failed for non MRL users');
        
    }
    
    /*
Test Class method to test prevention of update to a chatter post for MRL users
*/
    
    @isTest
    public static void testPreventFeedItemPostUpdateForMRL(){
        
        Account acc3 = [SELECT id FROM Account WHERE Name='Test Account3 for attaching Feed Item record'];
        User u3 = [SELECT id, UserName from User WHERE UserName = 'ICRMBase3@testorg.com' AND Email='standarduser3@testorg.com' AND LastName='Testing3'];
        
        //Initially allow the user to Post to chatter when he is a NON-MRL user
        FeedItem testFeedItem = new FeedItem(Body = 'Test Feed Item body', Type = 'TextPost', parentId = acc3.Id );
        System.runAs(u3){
            insert testFeedItem;
        }
        
        //Make the user as an MRL user and confirm that he is not allowed to update that post now
        BPI_MRL_User__c mrlUser = new BPI_MRL_User__c (BPI_Email__c = 'standarduser3@testorg.com', BPI_MRL_Status__c = 'Active');
        insert mrlUser;
        FeedItem testFeedItemCheck = [SELECT Body FROM FeedItem WHERE parentId =: acc3.Id];
        testFeedItemCheck.Body = 'Updated Test Feed Item body';
        System.runAs(u3){
            try{
                update testFeedItemCheck;
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains(System.Label.Prevent_MRL_Users_from_Chatter_Post));
            }
            
        }
        
    }
    
    /*
Test Class method to test prevention of Post to chatter for Pending MRL users
*/
    
    @isTest
    public static void testPreventFeedItemPostForPendingMRL(){
        
        Account acc1 = [SELECT id FROM Account WHERE Name='Test Account1 for attaching Feed Item record'];
        FeedItem testFeedItem = new FeedItem(Body = 'Test Feed Item body', Type = 'TextPost', parentId = acc1.Id );
        
        User u1 = [SELECT id, UserName from User WHERE UserName = 'ICRMBase1@testorg.com' AND Email='standarduser1@testorg.com' AND LastName='Testing1'];
        BPI_MRL_User__c MRLUserPending = [Select BPI_MRL_Status__c from BPI_MRL_User__c WHERE BPI_Email__c = 'standarduser1@testorg.com'];
        MRLUserPending.BPI_MRL_Status__c = 'Pending';
        Update MRLUserPending;
        
        System.runAs(u1){
            try{
                insert testFeedItem;
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains(System.Label.Prevent_MRL_Users_from_Chatter_Post));
            }
            
        }
        
        
    }
    
    /*
Test Class method to test prevention of Post to chatter for MRL users where status as Complete
*/
    
    @isTest
    public static void testPreventFeedItemPostForCompleteMRL(){
        
        Account acc4 = [SELECT id FROM Account WHERE Name='Test Account4 for attaching Feed Item record'];
        User u1 = [SELECT id, UserName from User WHERE UserName = 'ICRMBase1@testorg.com' AND Email='standarduser1@testorg.com' AND LastName='Testing1'];
        FeedItem testFeedItem1 = new FeedItem(Body = 'Test Feed Item body1', Type = 'TextPost', parentId = acc4.Id );
        
        BPI_MRL_User__c MRLUserCompleted = [Select BPI_MRL_Status__c from BPI_MRL_User__c WHERE BPI_Email__c = 'standarduser1@testorg.com'];
        MRLUserCompleted.BPI_MRL_Status__c = 'Complete';
        Update MRLUserCompleted;
        
        System.runAs(u1){
            Test.startTest();
            insert testFeedItem1;  
            Test.stopTest();
        }
        FeedItem testFeedItemCheck = [SELECT Body FROM FeedItem WHERE parentId =: acc4.Id];
        System.assertEquals(testFeedItem1.Body, testFeedItemCheck.Body, 'Test Class on Feed Comment Failed for non MRL users');
        
    }
    
}