public without sharing class BPI_MG1_FeedCommentManager {

    public static void commentUpdatePost(List<FeedComment> feedCommentList, Set<Id> ownerIdSet, Set<Id> parentFeedIdSet, List<String> commentsIdString) {
        Set<Id> parentFeedParentGroupIdSet                        = new Set<Id>();
        Set<Id> parentFeedParentUserIdSet                         = new Set<Id>();
        Set<Id> userForFollowers                                  = new Set<Id>();
        Set<Id> mentionUserOrGroupId                              = new Set<Id>();
        List<FeedItem> insertPostList                             = new List<FeedItem>();
        List<String> postMentionFetchIds                          = new List<String>();
        Map<Id, ConnectApi.Comment> commentMentionMap             = new Map<Id, ConnectApi.Comment>();
        Map<Id, ConnectApi.FeedElement> postMentionFeedElementMap = new Map<Id, ConnectApi.FeedElement>();

        Map<Id, FeedItem> parentFeedMap = new Map<Id, FeedItem>([SELECT Id, CreatedBy.Email, CreatedBy.Name, ParentId FROM FeedItem WHERE Id In : parentFeedIdSet]);
        for (Id parentFeedId : parentFeedMap.keySet()) {
            FeedItem parentFeed = parentFeedMap.get(parentFeedId);
            if (Schema.CollaborationGroup.getSObjectType() == parentFeed.ParentId.getsobjecttype()) {
                parentFeedParentGroupIdSet.add(parentFeedMap.get(parentFeedId).ParentId);
            } else if (Schema.User.getSObjectType() == parentFeed.ParentId.getsobjecttype()) {
                parentFeedParentUserIdSet.add(parentFeedMap.get(parentFeedId).ParentId);
            }
            postMentionFetchIds.add(parentFeedId);
        }


        commentMentionMap         = fetchCommentMention(commentsIdString, mentionUserOrGroupId);
        postMentionFeedElementMap = fetchPostMentionFeedElement(postMentionFetchIds, mentionUserOrGroupId);

        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id In : ownerIdSet OR Id In : parentFeedParentUserIdSet OR Id In : mentionUserOrGroupId]);
        List<EntitySubscription> followersList = [SELECT Id, SubscriberId, Subscriber.name, Subscriber.email, Parentid from EntitySubscription where parentid In : parentFeedParentUserIdSet LIMIT 1000];
        Map<Id, List<EntitySubscription>> followerByUser = new Map<Id, List<EntitySubscription>>();
        for (EntitySubscription follower : followersList) {
            if (followerByUser.containsKey(follower.ParentId)) {
                followerByUser.get(follower.ParentId).add(follower);
            } else {
                followerByUser.put(follower.ParentId, new List<EntitySubscription>{follower});
            }
        }

        Map<Id, CollaborationGroup> parentGroupMap = new Map<Id, CollaborationGroup>([SELECT Id, Name, CollaborationType, MemberCount From CollaborationGroup WHERE Id In : parentFeedParentGroupIdSet OR Id In : mentionUserOrGroupId]);
        List<CollaborationGroupMember> parentGroupMemberMap = [SELECT MemberId, Member.Name, Member.Email, CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationGroupId In : parentGroupMap.keySet()];
        Map<Id, List<CollaborationGroupMember>> groupMemberByGroup = new Map<Id, List<CollaborationGroupMember>>();
        for (CollaborationGroupMember parentGroupMember : parentGroupMemberMap) {
            if (groupMemberByGroup.containsKey(parentGroupMember.CollaborationGroupId)) {
                groupMemberByGroup.get(parentGroupMember.CollaborationGroupId).add(parentGroupMember);
            } else {
                groupMemberByGroup.put(parentGroupMember.CollaborationGroupId, new List<CollaborationGroupMember>{parentGroupMember});
            }
        }

        for (FeedComment feedComment : feedCommentList) {
            FeedComment oldFeedComment = (FeedComment)Trigger.oldMap.get(feedComment.Id);
            User originalAuthor        = userMap.get(oldFeedComment.CreatedById);

            FeedItem post = new FeedItem();
            post.Type     = 'TextPost';
            post.Title    = 'Comment is updated';
            post.ParentId = System.label.Private_Group_Id;//the private Group ID where this post should appear

            post.Body = 'Comment is updated';
            post.Body+= String.Format('\n\nOriginal Comment Type: {0}', new String[]{oldFeedComment.CommentType});
            post.Body+= String.Format('\n\nOriginal Comment ID: {0}', new String[]{oldFeedComment.Id});
            post.Body+= String.Format('\nOriginal Comment Time: {0} at {1}', new String[]{oldFeedComment.SystemModstamp.format('MMMM d'),oldFeedComment.SystemModstamp.format('hh:mm aa')});


            if (Userinfo.getUserId() != oldFeedComment.CreatedById) {
                //if different than original author, show who updated the comment in message body
                post.Body+= String.Format('\nOriginal AuthorId: {0}', new String[]{originalAuthor.Id});
                post.Body+= String.Format('\nOriginal Author: <a href="emailto:{0}">{1}</a>', new String[]{originalAuthor.Email, originalAuthor.Name});
            }

            post.Body+= String.Format('\n\nOld Text: {0}', new String[]{oldFeedComment.CommentBody});
            post.Body+= String.Format('\n\nNew Text: {0}', new String[]{feedComment.CommentBody});
            post.Body += '\n\nOriginal Recipients: START';
            if (Userinfo.getUserId() != oldFeedComment.CreatedById) {
                //if different than original author, show who updated the comment in message body
                post.Body+= String.Format('\nOriginal Author: <a href="emailto:{0}">{1}</a>', new String[]{originalAuthor.Email, originalAuthor.Name});
               }
            FeedItem parentFeed = parentFeedMap.get(oldFeedComment.FeedItemId);
            post.Body+= String.Format('\nParent Post Author: <a href="emailto:{0}">{1}</a>', new String[]{parentFeed.CreatedBy.Email, parentFeed.CreatedBy.Name});
            Boolean parentIsGroup = Schema.CollaborationGroup.getSObjectType() == parentFeed.ParentId.getsobjecttype();
            Boolean parentIsUser = Schema.User.getSObjectType() == parentFeed.ParentId.getsobjecttype();
            Boolean parentGroupIsPublic = false;

            if (parentIsGroup) {
                CollaborationGroup parentGroup = parentGroupMap.get(parentFeed.ParentId);
                parentGroupIsPublic = parentGroup.CollaborationType == 'Public';
                post.Body+= String.Format('\nParent Post Group: {0}', new String[]{parentGroup.Name});
                //Get and print parent group members
                if (parentGroup.MemberCount > 0) {
                    LIST<CollaborationGroupMember> parentGroupMembers = groupMemberByGroup.get(parentGroup.Id);
                    if (parentGroupMembers != null && !parentGroupMembers.isEmpty()) {
                         String originalPostGroupMembersText = '';
                          for (CollaborationGroupMember parentGroupMember : parentGroupMembers) {
                            originalPostGroupMembersText+= String.Format('\nGroup Member: <a href="emailto:{0}">{1}</a>', new String[]{parentGroupMember.Member.Email,parentGroupMember.Member.Name});
                           }
                        post.Body+=originalPostGroupMembersText;
                    }
                }

            }


            if (parentIsUser) {
                User parentUser = userMap.get(parentFeed.ParentId);
                List<EntitySubscription> followers = followerByUser.get(parentUser.Id);
                if (followers != null && !followers.isEmpty()) {
                    String parentUserFollowersText = String.Format('\nOriginal Post Parent User: <a href="emailto:{0}">{1}</a>', new String[]{parentUser.Email, parentUser.Name});
                    for (EntitySubscription follower: followers) {
                        parentUserFollowersText+= String.Format('\nFollower: <a href="emailto:{0}">{1}</a>', new String[]{follower.subscriber.email,follower.subscriber.name});
                    }
                    post.Body+=parentUserFollowersText;
                }

            }

            //Get and print parent post mentions
            if ((parentIsGroup && parentGroupIsPublic) || parentIsUser) {
                String parentPostMentionsText = '';
                ConnectApi.FeedElement feedItem = postMentionFeedElementMap.get(parentFeed.Id);
                List<ConnectApi.MessageSegment> messageSegments = feedItem.body.messageSegments;
                for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                    if (messageSegment instanceof ConnectApi.MentionSegment) {
                        ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                        if (mentionSegment.record instanceof ConnectApi.User) {
                            User mentionedUser = userMap.get(mentionSegment.record.id);
                            parentPostMentionsText+= String.Format('\nMentioned user: <a href="emailto:{0}">{1}</a>', new String[]{mentionedUser.Email, mentionSegment.Name});
                        } else if (mentionSegment.record instanceof ConnectApi.ChatterGroup) {
                            parentPostMentionsText+= String.Format('\nMentioned Group: {0}', new String[]{mentionSegment.name});
                            LIST<CollaborationGroupMember> mentionedGroupMembers = groupMemberByGroup.get(mentionSegment.record.id);
                            if (mentionedGroupMembers != null && !mentionedGroupMembers.isEmpty()) {
                                for (CollaborationGroupMember mentionedGroupMember : mentionedGroupMembers) {
                                    parentPostMentionsText+= String.Format('\nMentioned Group member: <a href="emailto:{0}">{1}</a>', new String[]{mentionedGroupMember.Member.Email,mentionedGroupMember.Member.Name});
                                }
                            }
                        }
                    }
                }
                post.Body+=parentPostMentionsText;
            }

            //Get and print comment mentions
            String mentionsText = '';
            ConnectApi.Comment cmt = commentMentionMap.get(oldFeedComment.Id);
            List<ConnectApi.MessageSegment> messageSegments = cmt.body.messageSegments;
            for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                if (messageSegment instanceof ConnectApi.MentionSegment) {
                    ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                    if (mentionSegment.record instanceof ConnectApi.User) {
                        User mentionedUser = userMap.get(mentionSegment.record.id);
                        mentionsText+= String.Format('\nMentioned user: <a href="emailto:{0}">{1}</a>', new String[]{mentionedUser.Email, mentionSegment.Name});
                    } else if (mentionSegment.record instanceof ConnectApi.ChatterGroup) {
                        mentionsText+= String.Format('\nMentioned Group: {0}', new String[]{mentionSegment.name});
                        LIST<CollaborationGroupMember> mentionedGroupMembers = groupMemberByGroup.get(mentionSegment.record.id);
                        if (mentionedGroupMembers != null && !mentionedGroupMembers.isEmpty()) {
                            for (CollaborationGroupMember mentionedGroupMember : mentionedGroupMembers) {
                                mentionsText+= String.Format('\nMentioned Group member: <a href="emailto:{0}">{1}</a>', new String[]{mentionedGroupMember.Member.Email,mentionedGroupMember.Member.Name});
                            }
                        }
                    }
                }
            }

            post.Body+=mentionsText;
            post.Body += '\nOriginal Recipients: END';

            //Store additional info about original post
            post.Body += '\n\nOriginal Post Info: START';
            if (oldFeedComment.CommentType == 'ContentComment')    {
                post.Body+= String.Format('\nOriginal RelatedRecordId: {0}', new String[]{oldFeedComment.RelatedRecordId == null ? '' : oldFeedComment.RelatedRecordId});
            }
            post.Body += '\nOriginal Post Info: END';

            insertPostList.add(post);

        }

        if (insertPostList.size() > 0) {
            insert insertPostList;
        }
    }

    public static void commentDeletePost(List<FeedComment> feedCommentList, Set<Id> ownerIdSet, Set<Id> parentFeedIdList, Set<Id> contentCommentIdSet, List<String> commentsIdString) {
        Set<Id> parentFeedParentGroupIdSet                        = new Set<Id>();
        Set<Id> parentFeedParentUserIdSet                         = new Set<Id>();
        Set<Id> userForFollowers                                  = new Set<Id>();
        Set<Id> mentionUserOrGroupId                              = new Set<Id>();
        List<String> postMentionFetchIds                          = new List<String>();
        List<FeedItem> insertPostList                             = new List<FeedItem>();
        Map<Id, ConnectApi.Comment> commentMentionMap             = new Map<Id, ConnectApi.Comment>();
        Map<Id, ConnectApi.FeedElement> postMentionFeedElementMap = new Map<Id, ConnectApi.FeedElement>();


        Map<Id, FeedItem> parentFeedMap = new Map<Id, FeedItem>([SELECT Id, CreatedBy.Email, CreatedBy.Name, ParentId FROM FeedItem WHERE Id In : parentFeedIdList]);
        for (Id parentFeedId : parentFeedMap.keySet()) {
            FeedItem parentFeed = parentFeedMap.get(parentFeedId);
            if (Schema.CollaborationGroup.getSObjectType() == parentFeed.ParentId.getsobjecttype()) {
                parentFeedParentGroupIdSet.add(parentFeedMap.get(parentFeedId).ParentId);
            } else if (Schema.User.getSObjectType() == parentFeed.ParentId.getsobjecttype()) {
                parentFeedParentUserIdSet.add(parentFeedMap.get(parentFeedId).ParentId);
            }
            postMentionFetchIds.add(parentFeedId);
        }

        commentMentionMap         = fetchCommentMention(commentsIdString, mentionUserOrGroupId);
        postMentionFeedElementMap = fetchPostMentionFeedElement(postMentionFetchIds, mentionUserOrGroupId);

        Map<Id, CollaborationGroup> parentGroupMap          = new Map<Id, CollaborationGroup>([SELECT Id, Name, CollaborationType, MemberCount From CollaborationGroup WHERE Id In : parentFeedParentGroupIdSet OR Id In : mentionUserOrGroupId]);
        List<CollaborationGroupMember> parentGroupMemberMap = [SELECT MemberId, Member.Name, Member.Email, CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationGroupId In : parentGroupMap.keySet()]; // Groupby
        Map<Id, List<CollaborationGroupMember>> groupMemberByGroup = new Map<Id, List<CollaborationGroupMember>>();
        for (CollaborationGroupMember parentGroupMember : parentGroupMemberMap) {
            if (groupMemberByGroup.containsKey(parentGroupMember.CollaborationGroupId)) {
                groupMemberByGroup.get(parentGroupMember.CollaborationGroupId).add(parentGroupMember);
            } else {
                groupMemberByGroup.put(parentGroupMember.CollaborationGroupId, new List<CollaborationGroupMember>{parentGroupMember});
            }
        }

        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id In : ownerIdSet OR Id In : parentFeedParentUserIdSet OR Id In : mentionUserOrGroupId]);
        List<EntitySubscription> followersList = [SELECT Id, SubscriberId, Subscriber.name, Subscriber.email, Parentid from EntitySubscription where parentid In : parentFeedParentUserIdSet];
        Map<Id, List<EntitySubscription>> followerByUser = new Map<Id, List<EntitySubscription>>();
        for (EntitySubscription follower : followersList) {
            if (followerByUser.containsKey(follower.ParentId)) {
                followerByUser.get(follower.ParentId).add(follower);
            } else {
                followerByUser.put(follower.ParentId, new List<EntitySubscription>{follower});
            }
        }

        Map<Id, ContentVersion> contentCommentMap = new Map<Id,ContentVersion>([SELECT Title FROM ContentVersion WHERE Id In : contentCommentIdSet]);

        for (FeedComment feedComment : feedCommentList) {
            User originalAuthor = userMap.get(feedComment.CreatedById);

            FeedItem post = new FeedItem();
            post.Type     = 'TextPost';
            post.Title    = 'Comment is deleted';
            post.ParentId = System.label.Private_Group_Id;//the private Group ID where this post should appear

            post.Body = 'Comment is deleted';
            post.Body+= String.Format('\n\nOriginal Comment ID: {0}', new String[]{feedComment.Id});
            post.Body+= String.Format('\nOriginal Comment Time: {0} at {1}', new String[]{feedComment.SystemModstamp.format('MMMM d'),feedComment.SystemModstamp.format('hh:mm aa')});


            if (Userinfo.getUserId() != feedComment.CreatedById) {
                //if different than original author, show who updated the comment in message body
                post.Body+= String.Format('\nOriginal AuthorId: {0}', new String[]{originalAuthor.Id});
                post.Body+= String.Format('\nOriginal Author: <a href="emailto:{0}">{1}</a>', new String[]{originalAuthor.Email, originalAuthor.Name});
            }

            if (feedComment.CommentType == 'ContentComment' && feedComment.RelatedRecordId != null && contentCommentMap.containsKey(feedComment.RelatedRecordId)) {
                ContentVersion content = contentCommentMap.get(feedComment.RelatedRecordId);
                post.Body+= String.Format('\nTitle: {0}', new String[]{content.Title});
                post.Title = content.Title;
            }

            post.Body+= String.Format('\n\nNew Text: {0}', new String[]{feedComment.CommentBody});
            post.Body += '\n\nOriginal Recipients: START';
            if (Userinfo.getUserId() != feedComment.CreatedById) {
                //if different than original author, show who updated the comment in message body
                post.Body+= String.Format('\nOriginal Author: <a href="emailto:{0}">{1}</a>', new String[]{originalAuthor.Email, originalAuthor.Name});
            }
            FeedItem parentFeed = parentFeedMap.get(feedComment.FeedItemId);
            post.Body+= String.Format('\nParent Post Author: <a href="emailto:{0}">{1}</a>', new String[]{parentFeed.CreatedBy.Email, parentFeed.CreatedBy.Name});
            Boolean parentIsGroup = Schema.CollaborationGroup.getSObjectType() == parentFeed.ParentId.getsobjecttype();
            Boolean parentIsUser = Schema.User.getSObjectType() == parentFeed.ParentId.getsobjecttype();
            Boolean parentGroupIsPublic = false;

            if (parentIsGroup) {
                CollaborationGroup parentGroup = parentGroupMap.get(parentFeed.ParentId);
                parentGroupIsPublic = parentGroup.CollaborationType == 'Public';
                post.Body+= String.Format('\nParent Post Group: {0}', new String[]{parentGroup.Name});
                //Get and print parent group members
                if (parentGroup.MemberCount > 0) {
                    LIST<CollaborationGroupMember> parentGroupMembers = groupMemberByGroup.get(parentGroup.Id);
                    if (parentGroupMembers != null && !parentGroupMembers.isEmpty()) {
                         String originalPostGroupMembersText = '';
                          for (CollaborationGroupMember parentGroupMember : parentGroupMembers) {
                            originalPostGroupMembersText+= String.Format('\nGroup Member: <a href="emailto:{0}">{1}</a>', new String[]{parentGroupMember.Member.Email,parentGroupMember.Member.Name});
                           }
                        post.Body+=originalPostGroupMembersText;
                    }
                }

            }


            if (parentIsUser) {
                User parentUser = userMap.get(parentFeed.ParentId);
                List<EntitySubscription> followers = followerByUser.get(parentUser.Id);
                if (followers != null && !followers.isEmpty()) {
                    String parentUserFollowersText = String.Format('\nOriginal Post Parent User: <a href="emailto:{0}">{1}</a>', new String[]{parentUser.Email, parentUser.Name});
                    for (EntitySubscription follower: followers) {
                        parentUserFollowersText+= String.Format('\nFollower: <a href="emailto:{0}">{1}</a>', new String[]{follower.subscriber.email,follower.subscriber.name});
                    }
                    post.Body+=parentUserFollowersText;
                }

            }
             //Get and print parent post mentions
            if ((parentIsGroup && parentGroupIsPublic) || parentIsUser) {
                String parentPostMentionsText = '';
                ConnectApi.FeedElement feedItem = postMentionFeedElementMap.get(parentFeed.Id);
                List<ConnectApi.MessageSegment> messageSegments = feedItem.body.messageSegments;
                for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                    if (messageSegment instanceof ConnectApi.MentionSegment) {
                        ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                        if (mentionSegment.record instanceof ConnectApi.User) {
                            User mentionedUser = userMap.get(mentionSegment.record.id);
                            parentPostMentionsText+= String.Format('\nMentioned user: <a href="emailto:{0}">{1}</a>', new String[]{mentionedUser.Email, mentionSegment.Name});
                        } else if (mentionSegment.record instanceof ConnectApi.ChatterGroup) {
                            parentPostMentionsText+= String.Format('\nMentioned Group: {0}', new String[]{mentionSegment.name});
                            LIST<CollaborationGroupMember> mentionedGroupMembers = groupMemberByGroup.get(mentionSegment.record.id);
                            if (mentionedGroupMembers != null && !mentionedGroupMembers.isEmpty()) {
                                for (CollaborationGroupMember mentionedGroupMember : mentionedGroupMembers) {
                                    parentPostMentionsText+= String.Format('\nMentioned Group member: <a href="emailto:{0}">{1}</a>', new String[]{mentionedGroupMember.Member.Email,mentionedGroupMember.Member.Name});
                                }
                            }
                        }
                    }
                }
                post.Body+=parentPostMentionsText;
            }

            //Get and print comment mentions
            String mentionsText = '';
            ConnectApi.Comment cmt = commentMentionMap.get(feedComment.Id);
            List<ConnectApi.MessageSegment> messageSegments = cmt.body.messageSegments;
            for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                if (messageSegment instanceof ConnectApi.MentionSegment) {
                    ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                    if (mentionSegment.record instanceof ConnectApi.User) {
                        User mentionedUser = userMap.get(mentionSegment.record.id);
                        mentionsText+= String.Format('\nMentioned user: <a href="emailto:{0}">{1}</a>', new String[]{mentionedUser.Email, mentionSegment.Name});
                    } else if (mentionSegment.record instanceof ConnectApi.ChatterGroup) {
                        mentionsText+= String.Format('\nMentioned Group: {0}', new String[]{mentionSegment.name});
                        LIST<CollaborationGroupMember> mentionedGroupMembers = groupMemberByGroup.get(mentionSegment.record.id);
                        if (mentionedGroupMembers != null && !mentionedGroupMembers.isEmpty()) {
                            for (CollaborationGroupMember mentionedGroupMember : mentionedGroupMembers) {
                                mentionsText+= String.Format('\nMentioned Group member: <a href="emailto:{0}">{1}</a>', new String[]{mentionedGroupMember.Member.Email,mentionedGroupMember.Member.Name});
                            }
                        }
                    }
                }
            }

            post.Body+=mentionsText;

            post.Body += '\nOriginal Recipients: END';

            //Store additional info about original post
            post.Body += '\n\nOriginal Post Info: START';
            if (feedComment.CommentType == 'ContentComment')    {
                post.Body+= String.Format('\nOriginal RelatedRecordId: {0}', new String[]{feedComment.RelatedRecordId == null ? '' : feedComment.RelatedRecordId});
            }
            post.Body += '\nOriginal Post Info: END';

            insertPostList.add(post);

        }

        if (insertPostList.size() > 0) {
            insert insertPostList;
        }
    }

    public static Map<Id, ConnectApi.FeedElement> fetchPostMentionFeedElement(List<String> postMentionFetchIds, Set<Id> userAndGroupId) {
        Map<Id, ConnectApi.FeedElement> postMentionFeedElementMap = new Map<Id, ConnectApi.FeedElement>();
        List<ConnectApi.BatchResult> feedElementResult = ConnectApi.ChatterFeeds.getFeedElementBatch(null, postMentionFetchIds);
        for (ConnectApi.BatchResult batchResult : feedElementResult) {
            ConnectApi.FeedElement feedElement = (ConnectApi.FeedElement)batchResult.getResult();
            postMentionFeedElementMap.put((Id)feedElement.Id, feedElement);
            List<ConnectApi.MessageSegment> messageSegments = feedElement.body.messageSegments;
            for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                if (messageSegment instanceof ConnectApi.MentionSegment) {
                    ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                    userAndGroupId.add((Id)mentionSegment.record.Id);
                }
            }
        }
        return postMentionFeedElementMap;
    }

    public static Map<Id, ConnectApi.Comment> fetchCommentMention(List<String> commentsIdString, Set<Id> userAndGroupId) {
        Map<Id, ConnectApi.Comment> commentMentionMap  = new Map<Id, ConnectApi.Comment>();
        List<ConnectApi.BatchResult> commentResult = ConnectApi.ChatterFeeds.getCommentBatch(null, commentsIdString);
        for (ConnectApi.BatchResult batchResult : commentResult) {
            ConnectApi.Comment feedElement = (ConnectApi.Comment)batchResult.getResult();
            commentMentionMap.put((Id)feedElement.Id, feedElement);
            List<ConnectApi.MessageSegment> messageSegments = feedElement.body.messageSegments;
            for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                if (messageSegment instanceof ConnectApi.MentionSegment) {
                    ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                    userAndGroupId.add((Id)mentionSegment.record.Id);
                }
            }
        }
        return commentMentionMap;
    }

}