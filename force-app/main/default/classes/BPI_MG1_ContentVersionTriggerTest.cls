@IsTest
public class BPI_MG1_ContentVersionTriggerTest {

    private static testMethod void contentVersionTest() {
        Datetime startDate = Datetime.now();
        User user = [SELECT Id FROM User WHERE Id != : UserInfo.getUserId() limit 1];
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        contentVersionList.add(new ContentVersion(Title = 'Test1', PathOnClient = 'Test.png', VersionData = EncodingUtil.base64Decode('Test Content Data1')));
        contentVersionList.add(new ContentVersion(Title = 'Test2', PathOnClient = 'Test2.png', VersionData = EncodingUtil.base64Decode('Test Content Data2')));
        contentVersionList.add(new ContentVersion(Title = 'Test3', PathOnClient = 'Test3.jpg', VersionData = Blob.valueOf('Test Content Data3')));
        contentVersionList.add(new ContentVersion(Title = 'Test4', PathOnClient = 'Test4.jpg', VersionData = Blob.valueOf('Test Content Data4')));
        insert contentVersionList;
        List<FeedItem> groupFeedItem = [SELECT Id, body, parentId, title FROM feeditem WHERE parentId = : System.label.Private_Group_Id AND CreatedDate >= : startDate];
        System.assertEquals(8, groupFeedItem.size());
        for (FeedItem groupFeed : groupFeedItem) {
            for (ContentVersion conVers : contentVersionList) {
                if (groupFeed.body.contains(conVers.Id)) {
                    System.assertEquals(groupFeed.Title, conVers.Title);
                    System.assert(groupFeed.body.contains(conVers.Title));
                }
            }
        }

        List<ContentDocument> contentDocumentList =  [SELECT Id, ParentId, Latestpublishedversionid FROM  ContentDocument WHERE Latestpublishedversionid In : contentVersionList];
        contentVersionList = new List<ContentVersion>();
        contentVersionList.add(new ContentVersion(Title = 'Test v1', PathOnClient = 'Testv2.jpg', VersionData = Blob.valueOf('Test Content Data5'), ReasonForChange = 'Lets Update this', ContentDocumentId = contentDocumentList[0].Id));
        contentVersionList.add(new ContentVersion(Title = 'Test V2', PathOnClient = 'Test2v2.jpg', VersionData = Blob.valueOf('Test Content Data6'), ReasonForChange = 'Lets Update this', ContentDocumentId = contentDocumentList[1].Id));
        insert contentVersionList;

        groupFeedItem = [SELECT Id, body, parentId, title FROM feeditem WHERE parentId = : System.label.Private_Group_Id AND CreatedDate >= : startDate];
        System.assertEquals(12, groupFeedItem.size());
        for (FeedItem groupFeed : groupFeedItem) {
            for (ContentVersion conVers : contentVersionList) {
                if (groupFeed.body.contains(conVers.Id)) {
                    System.assertEquals(groupFeed.Title, conVers.Title);
                    System.assert(groupFeed.body.contains(conVers.Title));
                }
            }
        }

        contentDocumentList =  [SELECT Id, ParentId, Latestpublishedversionid FROM  ContentDocument WHERE Latestpublishedversionid In : contentVersionList];
        List<ContentVersion> contentVersionListUpdate = new List<ContentVersion>();
        for (ContentDocument contentDocument : contentDocumentList) {
            contentVersionListUpdate.add(new ContentVersion(Id = contentDocument.Latestpublishedversionid, Title = 'Test title', Description = 'Test title'));
        }
        System.runAs(user) {
            update contentVersionListUpdate;
        }

        groupFeedItem = [SELECT Id, body, parentId, title FROM feeditem WHERE parentId = : System.label.Private_Group_Id AND CreatedDate >= : startDate];
        System.assertEquals(16, groupFeedItem.size());
    }

}