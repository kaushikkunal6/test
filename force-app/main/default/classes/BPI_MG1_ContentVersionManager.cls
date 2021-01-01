public without sharing class BPI_MG1_ContentVersionManager {

    public static void postToFeed(List<ContentVersion> fileList, Set<Id> ownerIdSet) {
        List<FeedItem> postList = new List<FeedItem>();
        Map<Id, User> originalOwnerMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id In : ownerIdSet]);
        Set<Id> processedCVs = new Set<Id>();
        for (ContentVersion cv : fileList) {
            Boolean isUpload     = Trigger.isInsert;
            Boolean isEdit       = (isUpload && cv.VersionNumber != '1') || Trigger.isUpdate;
            ContentVersion oldCV = Trigger.isUpdate ? (ContentVersion)Trigger.oldMap.get(cv.Id) : null;

            FeedItem post = new FeedItem();
            post.Type     = 'TextPost';
            post.Title    = cv.Title;
            post.ParentId = System.label.Private_Group_Id;//the private Group ID where this post should appear
            post.Body     = 'File ' + (isEdit ? 'Edited' : 'Uploaded') + '\n';

            if (isUpload) {
                post.Body += String.Format('\nTitle: {0}', new String[]{cv.Title});
                if (isEdit) {
                    //a new version is uploaded
                    post.Body += String.Format('\nUploaded New Version: {0}', new String[]{cv.VersionNumber});
                    if (cv.ReasonForChange != null && cv.ReasonForChange != '') {
                        post.Body += String.Format('\nWhat changed: {0}', new String[]{cv.ReasonForChange});
                    }
                }
            }

            if (oldCV != null) { //Name or Description is updated
                if (cv.Title != oldCV.Title) {
                    post.Body+= String.Format('\n\nOld Title: {0}', new String[]{oldCV.Title});
                    post.Body+= String.Format('\n\nNew Title: {0}', new String[]{cv.Title});
                }
                if (cv.Description != oldCV.Description) {
                    post.Body+= String.Format('\n\nOld Description: {0}', new String[]{oldCV.Description});
                    post.Body+= String.Format('\n\nNew Description: {0}', new String[]{cv.Description});
                }
            }

            post.Title = cv.Title;

            //if different than original author, show who is the owner of the file in message body
            if (Userinfo.getUserId() != cv.OwnerId) {
                post.Body+= '\nFile OwnerId: ' + originalOwnerMap.get(cv.OwnerId).Id;
                post.Body+= '\nFile Owner: <a href="emailto:' + originalOwnerMap.get(cv.OwnerId).Email + '">' + originalOwnerMap.get(cv.OwnerId).Name + '</a>';
            }

            //Store additional info about original post
            post.Body += '\n\nOriginal Post Info: START';
            post.Body+= String.Format('\nOriginal RelatedRecordId: {0}', new String[]{cv.Id});
            post.Body += '\nOriginal Post Info: END';

            if (!processedCVs.contains(cv.Id)) {
                postList.add(post);
                processedCVs.add(cv.Id);
            }

        }
        if (postList.size() > 0) {
            insert postList;
        }
    }
}