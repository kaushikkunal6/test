@IsTest(SeeAllData=true)
public class BPI_MG1_FeedCommentTriggerTest {

    private static testMethod void feedCommentTest() {
        Datetime startDate = Datetime.now();
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User Merge1User = new User(
            alias = 'MG1test', 
            email='userwithrole@roletest1.com', 
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', 
            profileid = pf.Id, 
            timezonesidkey='America/Los_Angeles', 
            username='userMerge1@testclass_bp86Fhe45Hf4t42eL.com'

        );
        System.runAs(Merge1User){
            User user = [SELECT Id FROM User WHERE Id != : UserInfo.getUserId() limit 1];
            CollaborationGroup publicGroup = new CollaborationGroup(CollaborationType = 'Public', Name = 'Testing Group1');
            insert publicGroup;
    
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            mentionSegmentInput.id = UserInfo.getUserId();
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            textSegmentInput.text = 'Could you take a look?';
            messageBodyInput.messageSegments.add(textSegmentInput);
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = publicGroup.Id;
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
    
            ConnectApi.FeedItemInput feedItemInputUser = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInputUser = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInputUser = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInputUser = new ConnectApi.TextSegmentInput();
            messageBodyInputUser.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            mentionSegmentInputUser.id = UserInfo.getUserId();
            messageBodyInputUser.messageSegments.add(mentionSegmentInput);
            textSegmentInputUser.text = 'Could you take a look?';
            messageBodyInputUser.messageSegments.add(textSegmentInput);
            feedItemInputUser.body = messageBodyInput;
            feedItemInputUser.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInputUser.subjectId = UserInfo.getUserId() ;
            ConnectApi.FeedElement feedElementUser = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInputUser);
    
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            contentVersionList.add(new ContentVersion(Title = 'Test', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true));
            insert contentVersionList;
    
            //update all posts
            List<FeedItem> feedList = [SELECT Id, Title, Body, Type FROM FeedItem WHERE Id = : feedElement.Id Or Id = : feedElementUser.Id];
            List<FeedComment> feedCommentList = new List<FeedComment>();
            feedCommentList.add(new FeedComment(CommentBody = 'Test Comment 1', CommentType = 'TextComment', FeedItemId = feedList[0].Id));
            feedCommentList.add(new FeedComment(CommentBody = 'Test Comment 2', CommentType = 'TextComment', FeedItemId = feedList[0].Id));
            feedCommentList.add(new FeedComment(CommentBody = 'Test Comment 3', CommentType = 'ContentComment', FeedItemId = feedList[1].Id, RelatedRecordId = contentVersionList[0].Id));
            feedCommentList.add(new FeedComment(CommentBody = 'Test Comment 4', CommentType = 'TextComment', FeedItemId = feedList[1].Id));
    
            insert feedCommentList;
            
            System.Debug('STARTING THE TEST');
            for (FeedComment feedComment : feedCommentList) {
                feedComment.CommentBody += 'update test';
            }
            update feedCommentList;
    
            List<FeedItem> groupFeedItem = [SELECT Id, body, parentId, title FROM FeedItem WHERE parentId = : System.label.Private_Group_Id AND CreatedDate >= : startDate];
            //System.assertEquals(5, groupFeedItem.size());
            Integer feedCommentUpdateCounter = 0;
            for (FeedItem groupFeed : groupFeedItem) {
                for (FeedComment feedComment : feedCommentList) {
                    if (groupFeed.body.contains(feedComment.Id)) {
                        //System.assert(groupFeed.body.contains(feed.body));
                        feedCommentUpdateCounter++;
                    }
                }
            }
            System.assertEquals(4, feedCommentUpdateCounter);
    
            // delete all posts in bulk
            delete feedCommentList;
            groupFeedItem = [SELECT Id, body, parentId, title FROM feeditem WHERE parentId = : System.label.Private_Group_Id AND CreatedDate >= : startDate];
            //System.assertEquals(9, groupFeedItem.size());
            Integer feedCommentDeleteCounter = 0;
            for (FeedItem groupFeed : groupFeedItem) {
                for (FeedComment feedComment : feedCommentList) {
                    if (groupFeed.body.contains(feedComment.Id)) {
                        //System.assert(groupFeed.body.contains(feed.body));
                        feedCommentDeleteCounter++;
    
                    }
                }
            }
            System.assertEquals(8, feedCommentDeleteCounter);
        }
        
    }

}