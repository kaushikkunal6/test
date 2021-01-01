public class BPI_MG1_ContentVersionTriggerHandler extends BPI_MG1_TriggerHandler {

    public override void afterinsert() {
        List<ContentVersion> fileList = new List<ContentVersion>();
        Set<Id> ownerIdSet            = new Set<Id>();

        List<ContentVersion> contentVersionList = (List<ContentVersion>)Trigger.new;
        for (ContentVersion cv : contentVersionList) {
            fileList.add(cv);
            if (Userinfo.getUserId() != cv.OwnerId) {
                ownerIdSet.add(cv.OwnerId);
            }

        }
        if (fileList.size() > 0) {
            BPI_MG1_ContentVersionManager.postToFeed(fileList, ownerIdSet);
        }
    }

    public override void afterupdate() {
        List<ContentVersion> fileList = new List<ContentVersion>();
        Set<Id> ownerIdSet            = new Set<Id>();

        List<ContentVersion> contentVersionList = (List<ContentVersion>)Trigger.new;
        for (ContentVersion cv : contentVersionList) {
            ContentVersion oldCV = (ContentVersion)Trigger.oldMap.get(cv.Id);
            if (oldCV != null && (cv.Title != oldCV.Title || cv.Description != oldCV.Description)) {
                fileList.add(cv);
                if (Userinfo.getUserId() != cv.OwnerId) {
                    ownerIdSet.add(cv.OwnerId);
                }
            }
        }
        
        if (fileList.size() > 0) {
            BPI_MG1_ContentVersionManager.postToFeed(fileList, ownerIdSet);
        }
    }

}