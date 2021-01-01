@IsTest(SeeAllData=true)
public class BPI_MG1_FeedItemTriggerTest {

    private static testMethod void feedItemTest() {
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
            CollaborationGroup publicGroup = new CollaborationGroup(CollaborationType = 'Public', Name = 'Testing Group1');
            insert publicGroup;
            Datetime startDate = Datetime.now();
            List<FeedItem> feedList = new List<FeedItem>();
            feedList.add(new FeedItem(Body = 'testing url feed item', linkURL = 'http://test.test.com', ParentId = UserInfo.getUserId()));
            feedList.add(new FeedItem(Body = 'testing feed item', title = 'QuestionPost',  ParentId = UserInfo.getUserId(), Type = 'QuestionPost'));
            feedList.add(new FeedItem(Body = 'testing group feed item', ParentId = publicGroup.Id));
            insert feedList;
    
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
    
            //update all posts
            feedList = [SELECT Id, Title, Body, Type FROM FeedItem WHERE Id In : feedList Or Id = : feedElement.id];
            for (FeedItem feed : feedList) {
                feed.Body += 'update test';
                if (feed.Type == 'QuestionPost') {
                    feed.Title = 'testingfeedtitle';
                }
            }
            update feedList;
    
            List<FeedComment> feedComments = new List<FeedComment>();
            feedComments.add(new FeedComment(feedItemId = feedList[0].Id, commentBody = 'first comment', commentType = 'TextComment'));
            feedComments.add(new FeedComment(feedItemId = feedList[0].Id, commentBody = 'second comment', commentType = 'TextComment'));
            feedComments.add(new FeedComment(feedItemId = feedList[0].Id, commentBody = 'third comment', commentType = 'TextComment'));
            insert feedComments;
    
            List<FeedItem> groupFeedItem = [SELECT Id, body, parentId, title FROM feeditem WHERE parentId = : System.label.Private_Group_Id AND CreatedDate >= : startDate];
            Integer feedUpdateCounter = 0;
            for (FeedItem groupFeed : groupFeedItem) {
                for (FeedItem feed : feedList) {
                    if (groupFeed.body.contains(feed.Id)) {
                        //System.assert(groupFeed.body.contains(feed.body));
                        feedUpdateCounter++;
                    }
                }
            }
            System.assertEquals(4, feedUpdateCounter);
    
            // delete all posts in bulk
            delete feedList;
            groupFeedItem = [SELECT Id, body, parentId, title FROM feeditem WHERE parentId = : System.label.Private_Group_Id AND CreatedDate >= : startDate];
            Integer feedDeleteCounter = 0;
            for (FeedItem groupFeed : groupFeedItem) {
                for (FeedItem feed : feedList) {
                    if (groupFeed.body.contains(feed.Id)) {
                        //System.assert(groupFeed.body.contains(feed.body));
                        feedDeleteCounter++;
    
                    }
                }
            }
            System.assertEquals(8, feedDeleteCounter);
        }
    }

}