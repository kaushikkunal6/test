public without sharing class BPI_MG1_FeedItemManager {

    public static void itemUpdatePost(List<FeedItem> feedItemList, Set<Id> ownerIdSet, List<String> feedItemIdString, Set<Id> parentIdSet) {
        Set<Id> userForFollowers                                  = new Set<Id>();
        Set<Id> mentionUserOrGroupId                              = new Set<Id>();
        List<FeedItem> insertPostList                             = new List<FeedItem>();
        Map<Id, ConnectApi.FeedElement> postMentionFeedElementMap = new Map<Id, ConnectApi.FeedElement>();

        postMentionFeedElementMap = fetchPostMentionFeedElement(feedItemIdString, mentionUserOrGroupId);

        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id In : ownerIdSet OR Id In : parentIdSet Or Id In : mentionUserOrGroupId]);
        List<EntitySubscription> followersList = [SELECT Id, SubscriberId, Subscriber.name, Subscriber.email, Parentid from EntitySubscription where parentId In : userMap.keySet() LIMIT 1000];
        Map<Id, List<EntitySubscription>> followerByUser = new Map<Id, List<EntitySubscription>>();
        for (EntitySubscription follower : followersList) {
            if (followerByUser.containsKey(follower.ParentId)) {
                followerByUser.get(follower.ParentId).add(follower);
            } else {
                followerByUser.put(follower.ParentId, new List<EntitySubscription>{follower});
            }
        }

        Map<Id, CollaborationGroup> parentGroupMap = new Map<Id, CollaborationGroup>([SELECT Id, Name, CollaborationType, MemberCount From CollaborationGroup WHERE Id In : parentIdSet OR Id In : mentionUserOrGroupId]);
        List<CollaborationGroupMember> parentGroupMemberMap = [SELECT MemberId, Member.Name, Member.Email, CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationGroupId In : parentGroupMap.keySet()];
        Map<Id, List<CollaborationGroupMember>> groupMemberByGroup = new Map<Id, List<CollaborationGroupMember>>();
        for (CollaborationGroupMember parentGroupMember : parentGroupMemberMap) {
            if (groupMemberByGroup.containsKey(parentGroupMember.CollaborationGroupId)) {
                groupMemberByGroup.get(parentGroupMember.CollaborationGroupId).add(parentGroupMember);
            } else {
                groupMemberByGroup.put(parentGroupMember.CollaborationGroupId, new List<CollaborationGroupMember>{parentGroupMember});
            }
        }


        for (FeedItem feedItem : feedItemList) {
            FeedItem oldFeedItem = (FeedItem)Trigger.oldMap.get(feedItem.Id);
            User originalAuthor  = userMap.get(oldFeedItem.CreatedById);

            FeedItem post = new FeedItem();
            post.Type     = 'TextPost';
            post.Title    = 'Post is updated';
            post.ParentId = System.label.Private_Group_Id;//the private Group ID where this post should appear

            post.Body = 'Post is updated';
            post.Body+= String.Format('\n\nOriginal Post ID: {0}', new String[]{oldFeedItem.Id});
            post.Body+= String.Format('\nOriginal Post Time: {0} at {1}', new String[]{oldFeedItem.SystemModstamp.format('MMMM d'),oldFeedItem.SystemModstamp.format('hh:mm aa')});

            if (Userinfo.getUserId() != oldFeedItem.CreatedById) {
                //if different than original author, show who updated the comment in message body
                post.Body+= String.Format('\nOriginal AuthorId: {0}', new String[]{originalAuthor.Id});
                post.Body+= String.Format('\nOriginal Author: <a href="emailto:{0}">{1}</a>', new String[]{originalAuthor.Email, originalAuthor.Name});
            }

            if (oldFeedItem.Type == 'QuestionPost' && !oldFeedItem.Title.equals(feedItem.Title)) {
                post.Body+= String.Format('\n<b>Old Title: </b>{0}', new String[]{oldFeedItem.Title});
                post.Body+= String.Format('\n<b>New Title: </b>{0}', new String[]{feedItem.Title});
            } else if (!String.isBlank(oldFeedItem.Title)) {
                post.Title = oldFeedItem.Title;
                post.Body+= String.Format('\n<b>Title: </b>{0}', new String[]{oldFeedItem.Title});
            }

            if (oldFeedItem.HasLink) {
                post.Body+= String.Format('\n<b>Link: </b>{0}', new String[]{oldFeedItem.LinkUrl});
            }

            post.Body+= String.Format('\n\n<b>Old Text: </b>{0}', new String[]{oldFeedItem.Body});
            post.Body+= String.Format('\n<b>New Text: </b>{0}', new String[]{feedItem.Body});

            post.Body += '\n\nOriginal Recipients: START';
            if (Userinfo.getUserId() != oldFeedItem.CreatedById) {
                //if different than original author, show who updated the comment in message body
                post.Body+= String.Format('\nOriginal Author: <a href="emailto:{0}">{1}</a>', new String[]{originalAuthor.Email, originalAuthor.Name});
            }

            Boolean parentIsGroup       = Schema.CollaborationGroup.getSObjectType() == oldFeedItem.ParentId.getsobjecttype();
            Boolean parentIsUser        = Schema.User.getSObjectType() == oldFeedItem.ParentId.getsobjecttype();
            Boolean parentGroupIsPublic = false;

            if (parentIsGroup) {
                CollaborationGroup parentGroup = parentGroupMap.get(oldFeedItem.ParentId);
                parentGroupIsPublic = parentGroup.CollaborationType == 'Public';
                post.Body+= String.Format('\nOriginal Post Group: {0}', new String[]{parentGroup.Name});
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
                User parentUser = userMap.get(oldFeedItem.ParentId);
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
                ConnectApi.FeedElement feedItemElement = postMentionFeedElementMap.get(oldFeedItem.Id);
                List<ConnectApi.MessageSegment> messageSegments = feedItemElement.body.messageSegments;
                for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                    if (messageSegment instanceof ConnectApi.MentionSegment) {
                        ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                        if (mentionSegment.record instanceof ConnectApi.User) {
                            User mentionedUser = userMap.get(mentionSegment.record.id);
                            parentPostMentionsText+= String.Format('\nMentioned user: <a href="emailto:{0}">{1}</a>', new String[]{mentionedUser.Email, mentionSegment.Name});
                        } else if (mentionSegment.record instanceof ConnectApi.ChatterGroup) {
                            parentPostMentionsText+= String.Format('\nMentioned Group: {0}', new String[]{mentionSegment.name});
                            List<CollaborationGroupMember> mentionedGroupMembers = groupMemberByGroup.get(mentionSegment.record.id);
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
            post.Body += '\nOriginal Recipients: END';

            //Store additional info about original post
            post.Body += '\n\nOriginal Post Info: START';
            if (oldFeedItem.Type == 'ContentPost') {
                post.Body += String.Format('\nOriginal RelatedRecordId: {0}', new String[]{oldFeedItem.RelatedRecordId == null ? '' : oldFeedItem.RelatedRecordId});
            }
            post.Body += '\nOriginal Post Info: END';
            insertPostList.add(post);
        }

        if (insertPostList.size() > 0) {
            insert insertPostList;
        }
    }

    public static void itemDeletePost(List<FeedItem> feedItemList, Set<Id> ownerIdSet, List<String> feedItemIdString, Set<Id> parentIdSet) {
        Set<Id> userForFollowers                                  = new Set<Id>();
        Set<Id> mentionUserOrGroupId                              = new Set<Id>();
        Map<Id, FeedItem> insertPostList                          = new Map<Id, FeedItem>();
        Map<Id, ConnectApi.FeedElement> postMentionFeedElementMap = new Map<Id, ConnectApi.FeedElement>();

        postMentionFeedElementMap = fetchPostMentionFeedElement(feedItemIdString, mentionUserOrGroupId);

        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id In : ownerIdSet OR Id In : parentIdSet OR Id In : mentionUserOrGroupId]);
        List<EntitySubscription> followersList = [SELECT Id, SubscriberId, Subscriber.name, Subscriber.email, Parentid from EntitySubscription where parentId In : userMap.keySet()];
        Map<Id, List<EntitySubscription>> followerByUser = new Map<Id, List<EntitySubscription>>();
        for (EntitySubscription follower : followersList) {
            if (followerByUser.containsKey(follower.ParentId)) {
                followerByUser.get(follower.ParentId).add(follower);
            } else {
                followerByUser.put(follower.ParentId, new List<EntitySubscription>{follower});
            }
        }

        Map<Id, CollaborationGroup> parentGroupMap = new Map<Id, CollaborationGroup>([SELECT Id, Name, CollaborationType, MemberCount From CollaborationGroup WHERE Id In : parentIdSet OR Id In : mentionUserOrGroupId]);
        List<CollaborationGroupMember> parentGroupMemberMap = [SELECT MemberId, Member.Name, Member.Email, CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationGroupId In : parentGroupMap.keySet()];
        Map<Id, List<CollaborationGroupMember>> groupMemberByGroup = new Map<Id, List<CollaborationGroupMember>>();
        for (CollaborationGroupMember parentGroupMember : parentGroupMemberMap) {
            if (groupMemberByGroup.containsKey(parentGroupMember.CollaborationGroupId)) {
                groupMemberByGroup.get(parentGroupMember.CollaborationGroupId).add(parentGroupMember);
            } else {
                groupMemberByGroup.put(parentGroupMember.CollaborationGroupId, new List<CollaborationGroupMember>{parentGroupMember});
            }
        }


        for (FeedItem feedItem : feedItemList) {
            User originalAuthor  = userMap.get(feedItem.CreatedById);

            FeedItem post = new FeedItem();
            post.Type     = 'TextPost';
            post.Title    = 'Post is deleted';
            post.ParentId = System.label.Private_Group_Id;//the private Group ID where this post should appear

            post.Body = 'Post is deleted';
            post.Body+= String.Format('\n\nOriginal Post ID: {0}', new String[]{feedItem.Id});
            post.Body+= String.Format('\nOriginal Post Time: {0} at {1}', new String[]{feedItem.SystemModstamp.format('MMMM d'),feedItem.SystemModstamp.format('hh:mm aa')});

            if (Userinfo.getUserId() != feedItem.CreatedById) {
                //if different than original author, show who updated the comment in message body
                post.Body+= String.Format('\nOriginal AuthorId: {0}', new String[]{originalAuthor.Id});
                post.Body+= String.Format('\nOriginal Author: <a href="emailto:{0}">{1}</a>', new String[]{originalAuthor.Email, originalAuthor.Name});
            }

            if (!String.isBlank(feedItem.Title)) {
                post.Title = feedItem.Title;
                post.Body+= String.Format('\n<b>Title: </b>{0}', new String[]{feedItem.Title});
            }

            if (feedItem.HasLink) {
                post.Body+= String.Format('\n<b>Link: </b>{0}', new String[]{feedItem.LinkUrl});
            }

            post.Body+= String.Format('\n\n<b>Text: </b>{0}', new String[]{feedItem.Body});

            post.Body += '\n\nOR:[';
            if (Userinfo.getUserId() != feedItem.CreatedById) {
                //if different than original author, show who updated the comment in message body
                post.Body+= String.Format('\nOr. Author: <a href="emailto:{0}">{1}</a>', new String[]{originalAuthor.Email, originalAuthor.Name});
            }

            Boolean parentIsGroup       = Schema.CollaborationGroup.getSObjectType() == feedItem.ParentId.getsobjecttype();
            Boolean parentIsUser        = Schema.User.getSObjectType() == feedItem.ParentId.getsobjecttype();
            Boolean parentGroupIsPublic = false;

            if (parentIsGroup) {
                CollaborationGroup parentGroup = parentGroupMap.get(feedItem.ParentId);
                parentGroupIsPublic = parentGroup.CollaborationType == 'Public';
                post.Body+= String.Format('\nOr.Pst. Grp: {0}', new String[]{parentGroup.Name});
                //Get and print parent group members
                if (parentGroup.MemberCount > 0) {
                    LIST<CollaborationGroupMember> parentGroupMembers = groupMemberByGroup.get(parentGroup.Id);
                    if (parentGroupMembers != null && !parentGroupMembers.isEmpty()) {
                         String originalPostGroupMembersText = '';
                          for (CollaborationGroupMember parentGroupMember : parentGroupMembers) {
                            originalPostGroupMembersText+= String.Format('\nGrp. Mmbr: <a href="emailto:{0}">{1}</a>', new String[]{parentGroupMember.Member.Email, parentGroupMember.Member.Name});
                           }
                        post.Body+=originalPostGroupMembersText;
                    }
                }

            }

            if (parentIsUser) {
                User parentUser = userMap.get(feedItem.ParentId);
                List<EntitySubscription> followers = followerByUser.get(parentUser.Id);
                if (followers != null && !followers.isEmpty()) {
                    String parentUserFollowersText = String.Format('\nOr.Pst.Prnt.Usr: <a href="emailto:{0}">{1}</a>', new String[]{parentUser.Email, parentUser.Name});
                    for (EntitySubscription follower: followers) {
                        parentUserFollowersText+= String.Format('\nFlwr: <a href="emailto:{0}">{1}</a>', new String[]{follower.subscriber.email,follower.subscriber.name});
                    }
                    post.Body+=parentUserFollowersText;
                }

            }

            //Get and print parent post mentions
            if ((parentIsGroup && parentGroupIsPublic) || parentIsUser) {
                String parentPostMentionsText = '';
                ConnectApi.FeedElement feedItemElement = postMentionFeedElementMap.get(feedItem.Id);
                List<ConnectApi.MessageSegment> messageSegments = feedItemElement.body.messageSegments;
                for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                    if (messageSegment instanceof ConnectApi.MentionSegment) {
                        ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                        if (mentionSegment.record instanceof ConnectApi.User) {
                            User mentionedUser = userMap.get(mentionSegment.record.id);
                            parentPostMentionsText+= String.Format('\nMent.user: <a href="emailto:{0}">{1}</a>', new String[]{mentionedUser.Email, mentionSegment.Name});
                        } else if (mentionSegment.record instanceof ConnectApi.ChatterGroup) {
                            parentPostMentionsText+= String.Format('\nMent.Grp: {0}', new String[]{mentionSegment.name});
                            List<CollaborationGroupMember> mentionedGroupMembers = groupMemberByGroup.get(mentionSegment.record.id);
                            if (mentionedGroupMembers != null && !mentionedGroupMembers.isEmpty()) {
                                for (CollaborationGroupMember mentionedGroupMember : mentionedGroupMembers) {
                                    parentPostMentionsText+= String.Format('\nMent.Grp.Mmbr: <a href="emailto:{0}">{1}</a>', new String[]{mentionedGroupMember.Member.Email, mentionedGroupMember.Member.Name});
                                }
                            }
                        }
                    }
                }
                post.Body+=parentPostMentionsText;
            }
            post.Body += '\n]:OR';//Original Recipients: END

            //Store additional info about original post
            post.Body += '\n\nOI:[';//Original Info: START
            post.Body += '\nM1FID:1';//schema version
            if (feedItem.Type == 'ContentPost') {
                post.Body += String.Format('\nOr.RelRecId: {0}', new String[]{feedItem.RelatedRecordId == null ? '' : feedItem.RelatedRecordId});
            }
            post.Body += '\n]:OI';//Original Info: END
            insertPostList.put(feedItem.Id, post);

        }

        if (insertPostList.size() > 0) {
            insert insertPostList.values();
            List<FeedComment> feedCommentsInsert = new List<FeedComment>();
            List<FeedComment> feedItemCommentList = [SELECT Id, CommentBody, CommentType, CreatedById, CreatedBy.Name,CreatedBy.Email, SystemModstamp, RelatedRecordId, FeedItemId FROM FeedComment WHERE FeedItemId In : insertPostList.Keyset()];
            Map<Id, List<FeedComment>> commentByFeedItems = new Map<Id, List<FeedComment>>();
            for (FeedComment comment : feedItemCommentList) {
                if (commentByFeedItems.containsKey(comment.FeedItemId)) {
                    commentByFeedItems.get(comment.FeedItemId).add(comment);
                } else {
                    commentByFeedItems.put(comment.FeedItemId, new List<FeedComment>{comment});
                }
            }
            for (Id postId : insertPostList.keySet()) {
                if (commentByFeedItems.containsKey(postId)) {
                    List<FeedComment> comments = commentByFeedItems.get(postId);
                    for (FeedComment comment : comments) {
                        String commentBody = comment.CommentBody;
                        commentBody += '\nOI:[';
                        commentBody += String.format('\nOr.Comm.Id:{0}', new String[]{comment.Id});
                        commentBody += String.format('\nOr.Comm.Author:{0}|{1}|{2}', new String[]{comment.CreatedById, comment.CreatedBy.Email, comment.CreatedBy.Name});
                        commentBody += String.format('\nOr.Comm.Time:{0}', new String[]{comment.SystemModstamp.format('yyyy-MM-dd\'T\'hh:mm:ss.000\'Z\'')});
                        commentBody += '\n]:OI';

                        FeedComment feedComment = new FeedComment(
                            feedItemId      = insertPostList.get(postId).Id,
                            relatedRecordId = comment.RelatedRecordId,
                            commentBody     = commentBody,
                            commentType     = comment.CommentType
                        );
                        feedCommentsInsert.add(feedComment);
                    }
                }
            }
            if (feedCommentsInsert.size() > 0) {
                insert feedCommentsInsert;
            }
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

}