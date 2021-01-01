public class BPI_MG1_FeedItemTriggerHandler extends BPI_MG1_TriggerHandler {

    public override void afterUpdate() {
        Set<Id> ownerIdSet            = new Set<Id>();
        Set<Id> parentIdSet           = new Set<Id>();
        List<String> feedItemIdString = new List<String>();
        List<FeedItem> feedItemList   = (List<FeedItem>) Trigger.new;
        for (FeedItem feedItem  : feedItemList) {
            if (Userinfo.getUserId() != ((FeedItem)Trigger.oldMap.get(feedItem.Id)).CreatedById) {
                ownerIdSet.add(feedItem.CreatedById);
            }
            feedItemIdString.add((String)feedItem.Id);
            parentIdSet.add(((FeedItem)Trigger.oldMap.get(feedItem.Id)).ParentId);
        }
        BPI_MG1_FeedItemManager.itemUpdatePost(feedItemList, ownerIdSet, feedItemIdString, parentIdSet);
    }

    public override void beforeDelete() {
        Set<Id> ownerIdSet            = new Set<Id>();
        Set<Id> parentIdSet           = new Set<Id>();
        List<String> feedItemIdString = new List<String>();
        List<FeedItem> feedItemList   = (List<FeedItem>) Trigger.old;
        for (FeedItem feedItem  : feedItemList) {
            if (Userinfo.getUserId() != feedItem.CreatedById) {
                ownerIdSet.add(feedItem.CreatedById);
            }
            feedItemIdString.add((String)feedItem.Id);
            parentIdSet.add(feedItem.ParentId);
        }
        BPI_MG1_FeedItemManager.itemDeletePost(feedItemList, ownerIdSet, feedItemIdString, parentIdSet);
    }

}