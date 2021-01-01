/******************************************************************************************
*  Date          : 6-SEP-2019
*  Author        : Palash Awasthi
*  Description   : Test Class for BPI_FeedComment_Trigger_Handler
*  Modifications : 11-SEP-2019  - Initial
*  Modifications : 13-SEP-2019  - Initial         
* ***************************************************************************************/

@isTest
public class BPI_FeedComment_Trigger_Handler_Test {
    
    /*
    Test Data setup for the class BPI_FeedComment_Trigger_Handler      
*/
    
    @testsetup
    static void testDataSetup(){
        
        //Inserting user details
        Profile p = [SELECT Id FROM Profile WHERE Name='ICRM Base']; 
        List<User> usrList = new List<User>();
        User u1 = new User(Alias = 'ICRMBase', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='ICRMBase1@testorg.com');
        User u2 = new User(Alias = 'ICRMBase', Email='standarduser2@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='ICRMBase2@testorg.com');
        
        usrList.add(u1);
        usrList.add(u2);
        // usrList.add(u3);
        
        insert usrList;
        
        List<Account> accountList = new List<Account>();
        
        //Inserting records on which the Post is done
        Account acc = new Account();
        string recTypeid = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Legal Entity').getRecordTypeId();
        acc.RecordTypeId = recTypeid;
        acc.Name = 'Test Account for attaching Feed Item record';
        acc.OwnerId = u1.Id;
        accountList.add(acc);
        
        Account acc1 = new Account();
        string recTypeid1 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Legal Entity').getRecordTypeId();
        acc1.RecordTypeId = recTypeid1;
        acc1.Name = 'Test Account for attaching Feed Item record1';
        acc1.OwnerId = u2.Id;
        accountList.add(acc1);
        
        Account acc2 = new Account();
        string recTypeid2 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Legal Entity').getRecordTypeId();
        acc2.RecordTypeId = recTypeid2;
        acc2.Name = 'Test Account for attaching Feed Item record2';
        acc2.OwnerId = u1.Id;
        accountList.add(acc2);
        
        Insert accountList;
        
        //Inserting the Post on Above created Record
        FeedItem testFeedItem = new FeedItem(Body = 'Test Feed Item body', Type = 'TextPost', parentId = acc.Id );
        insert testFeedItem;
        
        FeedItem testFeedItem1 = new FeedItem(Body = 'Test Feed Item body', Type = 'TextPost', parentId = acc1.Id );
        insert testFeedItem1;
        
        FeedItem testFeedItem2 = new FeedItem(Body = 'Test Feed Item body', Type = 'TextPost', parentId = acc2.Id );
        insert testFeedItem2;
        
        BPI_MRL_User__c mrlUser = new BPI_MRL_User__c(BPI_MRL_Status__c = 'Active', BPI_Email__c = 'standarduser1@testorg.com');
        insert mrlUser;
        
    }

    /*
    Unit Test for the Active Users      
*/    
    
    @isTest
    public static void testPostMRLUserActive(){
        
        User u1 = [SELECT id, UserName from User WHERE UserName = 'ICRMBase1@testorg.com' AND Email='standarduser1@testorg.com' AND LastName='Testing1'];
        
        Account acc = [SELECT id from Account WHERE Name = 'Test Account for attaching Feed Item record'];
        FeedItem testFeedItem = [SELECT Id FROM FeedItem WHERE parentId =:acc.Id];
        
        FeedComment testFeedComment = new FeedComment(CommentBody = 'Test Feed Comment body', CommentType = 'TextComment', FeedItemId = testFeedItem.Id );
        System.runAs(u1){
            try{
                insert testFeedComment;
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains(System.Label.Prevent_MRL_Users_from_Chatter_Post));
            }
            
        }
        
    }
    
       /*
    Unit Test for the Pending MRL Users      
*/ 
    
    @isTest
    public static void testPostMRLUserPending(){
        
        User u1 = [SELECT id, UserName from User WHERE UserName = 'ICRMBase1@testorg.com' AND Email='standarduser1@testorg.com' AND LastName='Testing1'];
        
        Account acc = [SELECT id from Account WHERE Name = 'Test Account for attaching Feed Item record'];
        FeedItem testFeedItem = [SELECT Id FROM FeedItem WHERE parentId =:acc.Id];
        
        BPI_MRL_User__c MRLUserPending = [Select BPI_MRL_Status__c from BPI_MRL_User__c WHERE BPI_Email__c = 'standarduser1@testorg.com'];
        MRLUserPending.BPI_MRL_Status__c = 'Pending';
        Update MRLUserPending;
        
        FeedComment testFeedComment = new FeedComment(CommentBody = 'Test Feed Comment body', CommentType = 'TextComment', FeedItemId = testFeedItem.Id );
        System.runAs(u1){
            try{
                insert testFeedComment;
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains(System.Label.Prevent_MRL_Users_from_Chatter_Post));
            }
            
        }
        
        
    }
    
           /*
    Unit Test for the MRL Users with status as Complete      
*/
    
    @isTest
    public static void testPostMRLUserComplete(){
        
        User u1 = [SELECT id, UserName from User WHERE UserName = 'ICRMBase1@testorg.com' AND Email='standarduser1@testorg.com' AND LastName='Testing1'];
        
        Account acc2 = [SELECT id from Account WHERE Name = 'Test Account for attaching Feed Item record2'];
        
        FeedItem testFeedItem2 = [SELECT Id FROM FeedItem WHERE parentId =:acc2.Id];
        
        
        BPI_MRL_User__c MRLUserCompleted = [Select BPI_MRL_Status__c from BPI_MRL_User__c WHERE BPI_Email__c = 'standarduser1@testorg.com'];
        MRLUserCompleted.BPI_MRL_Status__c = 'Complete';
        Update MRLUserCompleted;
        
        FeedComment testFeedComment1 = new FeedComment(CommentBody = 'Test Feed Comment body', CommentType = 'TextComment', FeedItemId = testFeedItem2.Id );
        System.runAs(u1){
            insert testFeedComment1;            
        }
        FeedComment testFeedCommentCheck = [SELECT CommentBody FROM FeedComment where FeedItemId =: testFeedItem2.Id ];
        System.assertEquals(testFeedComment1.CommentBody, testFeedCommentCheck.CommentBody, 'Test Class on Feed Comment Failed for non MRL users');
        
    }
    
    /*
     Unit Tests for the Non-MRL Users
*/
    
    @isTest
    public static void testPostNotMRLUser(){
        
        User u2 = [SELECT id, UserName from User WHERE UserName = 'ICRMBase2@testorg.com' AND Email='standarduser2@testorg.com' AND LastName='Testing2'];
        Account acc1 = [SELECT id from Account WHERE Name = 'Test Account for attaching Feed Item record1'];
        FeedItem testFeedItem1 = [SELECT Id FROM FeedItem WHERE parentId =:acc1.Id];
        FeedComment testFeedComment2 = new FeedComment(CommentBody = 'Test Feed Comment body', CommentType = 'TextComment', FeedItemId = testFeedItem1.Id );
        
        System.runAs(u2){
            insert testFeedComment2;        
        }
        FeedComment testFeedCommentCheck1 = [SELECT CommentBody FROM FeedComment where FeedItemId =: testFeedItem1.Id ];
        System.assertEquals(testFeedComment2.CommentBody, testFeedCommentCheck1.CommentBody, 'Test Class on Feed Comment Failed for non MRL users');
       
    }
    
}