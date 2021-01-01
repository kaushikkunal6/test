public class BPI_MG1_FeedCommentTriggerHandler extends BPI_MG1_TriggerHandler {

    public override void afterUpdate() {
        Set<Id> ownerIdSet            = new Set<Id>();
        Set<Id> parentFeedIdSet       = new Set<Id>();
        List<String> commentsIdString = new List<String>();
        List<FeedComment> feedCommentList = (List<FeedComment>) Trigger.new;
        for (FeedComment feedComment  : feedCommentList) {
            if (Userinfo.getUserId() != ((FeedComment)Trigger.oldMap.get(feedComment.Id)).CreatedById) {
                ownerIdSet.add(feedComment.CreatedById);
            }
            parentFeedIdSet.add(((FeedComment)Trigger.oldMap.get(feedComment.Id)).FeedItemId);
            commentsIdString.add((String)feedComment.Id);
        }
        BPI_MG1_FeedCommentManager.commentUpdatePost(feedCommentList, ownerIdSet, parentFeedIdSet, commentsIdString);
    }

    public override void beforeDelete() {
        Set<Id> ownerIdSet                = new Set<Id>();
        Set<Id> parentFeedIdSet           = new Set<Id>();
        Set<Id> contentCommentIdSet       = new Set<Id>();
        List<String> commentsIdString     = new List<String>();
        List<FeedComment> feedCommentList = (List<FeedComment>) Trigger.old;
        for (FeedComment feedComment  : feedCommentList) {
            if (Userinfo.getUserId() != feedComment.CreatedById) {
                ownerIdSet.add(feedComment.CreatedById);
            }
            if (feedComment.CommentType == 'ContentComment' && feedComment.RelatedRecordId != null) {
                contentCommentIdSet.add(feedComment.RelatedRecordId);
            }
            parentFeedIdSet.add(feedComment.FeedItemId);
            commentsIdString.add((String)feedComment.Id);

        }
        BPI_MG1_FeedCommentManager.commentDeletePost(feedCommentList, ownerIdSet, parentFeedIdSet, contentCommentIdSet, commentsIdString);
    }
}