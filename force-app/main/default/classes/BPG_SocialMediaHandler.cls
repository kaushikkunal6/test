/**
* @author: Provided by Salesforce
* @date: 11/06/2020
* @group: BPG
* @description: Handler class used by Social Studio when a Case is sent to Salesforce
* @name BPG_SocialMediaAccountUtil.cls
* @History      11/06/2020  by Gabriela Matos
                            Customised to read BPG_Social_Media_Account__mdt custom metadata type to identify which Social Account and its attributes;
                            Customised search for existing customers (accounts);
                            Customised when create a new Contact for a social persona, and associate w/ a default account;
                            Customised create Case to set the right RecordType based on the team and then drive automaation
*/

global virtual without sharing class BPG_SocialMediaHandler implements Social.InboundSocialPostHandler{

    //getting social media used by the ORG and its settings
    @TestVisible private static Map<String, BPG_Social_Media_Account__mdt> accIdSocialMediaMap = BPG_SocialMediaAccountUtil.SOCIAL_MEDIA_ACCOUNTS;
    @TestVisible private static BPG_Social_Media_Account__mdt socialAccountInContext;

    final static Integer CONTENT_MAX_LENGTH = SocialPost.Content.getDescribe().getLength();
    final static Integer SUBJECT_MAX_LENGTH = Case.Subject.getDescribe().getLength();
    Boolean isNewCaseCreated = false;
    // Reopen case if it has not been closed for more than this number
    global virtual Integer getMaxNumberOfDaysClosedToReopenCase() {
        if(socialAccountInContext != null && socialAccountInContext.BPG_Days_To_Reopen_Case__c != null){
            return Integer.valueOf(socialAccountInContext.BPG_Days_To_Reopen_Case__c);
        }
        return 5;
    }
    // Create a case if one of these post tags are on the SocialPost, regardless of the skipCreateCase indicator.
    global virtual Set<String> getPostTagsThatCreateCase(){
        return new Set<String>();
    }
    // If true, use the active case assignment rule if one is found
    global virtual Boolean getUsingCaseAssignmentRule(){

        if(socialAccountInContext != null){
            return socialAccountInContext.BPG_Run_Case_Assignment_Rules__c;
        }
        return false;
    }

    /** 
     * @description: get the default Account Id based on the social account settings
     * @author Gabriela Matos | 11/06/2020
     * @return Account Id
     * */
    global virtual String getDefaultAccountId() {

        if(socialAccountInContext != null && 
           socialAccountInContext.BPG_Default_Account_Name__c != null &&
           socialAccountInContext.BPG_Default_Account_RT__c != null){

            List<Account> defaultAcc = [SELECT Id 
                                          FROM Account 
                                         WHERE Name = :socialAccountInContext.BPG_Default_Account_Name__c
                                           AND RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(socialAccountInContext.BPG_Default_Account_RT__c).getRecordTypeId()
                                           LIMIT 1];
            
            if(defaultAcc != null && !defaultAcc.isEmpty()){
                return defaultAcc[0].Id;
            }                
        }
        
        return null;
    }

    global virtual String getCaseSubject(SocialPost post) {
        String caseSubject = post.Name;
        if (hasReview(post)) {
            String reviewStr = hasRecommendationReview(post) ?
            getRecommendedReviewString(post) : getRatingString(post);
            caseSubject = reviewStr + ' • ' + caseSubject;
        }
        return caseSubject;
    }

    global Social.InboundSocialPostResult handleInboundSocialPost(SocialPost post, SocialPersona persona, Map<String, Object> rawData) {
        
        //get the right project prefix based on the account
        if(accIdSocialMediaMap != null && !accIdSocialMediaMap.isEmpty()){
            if(post.Recipient != null && accIdSocialMediaMap.containsKey(post.Recipient)){
                socialAccountInContext = accIdSocialMediaMap.get(post.Recipient);
            }
        }

        Social.InboundSocialPostResult result = new Social.InboundSocialPostResult();
        result.setSuccess(true);
        matchPost(post);
        matchPersona(persona);
        if ((post.Content != null) && (post.Content.length() > CONTENT_MAX_LENGTH)) {
            post.Content = post.Content.abbreviate(CONTENT_MAX_LENGTH);
        }
        if (post.Id != null) {
            handleExistingPost(post, persona);
            return result;
        }
        setReplyTo(post, persona);
        buildPersona(persona);
        Case parentCase = buildParentCase(post, persona, rawData);
        setRelationshipsOnPost(post, persona, parentCase);
        setModeration(post, rawData);
        upsert post;
        if(isNewCaseCreated){
            updateCaseSource(post, parentCase);
        }
            handlePostAttachments(post, rawData);
        return result;
    }

    @TestVisible
    private void setModeration(SocialPost post, Map<String, Object> rawData){
        //if we don't automatically create a case, we should flag the post as requiringmoderator review.
        if(post.parentId == null && !isUnsentParent(rawData))
            post.reviewedStatus = 'Needed';
    }

    @TestVisible
    private void updateCaseSource(SocialPost post, Case parentCase){
        if(parentCase != null) {
            parentCase.SourceId = post.Id;
            //update as a new sobject to prevent undoing any changes done by insert triggers
            update new Case(Id = parentCase.Id, SourceId = parentCase.SourceId);
        }
    }

    @TestVisible
    private void handleExistingPost(SocialPost post, SocialPersona persona) {
        
        List<SocialPost> existingPosts = [SELECT Recipient, IsOutbound FROM SocialPost WHERE id = :post.Id limit 1];
    
        // for any existing outbound post, we don't overwrite its recipient field
        if (!existingPosts.isEmpty() && existingPosts[0].IsOutBound == true && String.isNotBlank(existingPosts[0].Recipient)) {
            post.Recipient = existingPosts[0].Recipient;
        }
        update post;
        if (persona.id != null)
            updatePersona(persona);
    }
    
    @TestVisible
    private void setReplyTo(SocialPost post, SocialPersona persona) {
        SocialPost replyTo = findReplyTo(post, persona);
        if(replyTo.id != null) {
            post.replyToId = replyTo.id;
            post.replyTo = replyTo;
        }
    }

    @TestVisible
    private SocialPersona buildPersona(SocialPersona persona) {
        if (persona.Id == null)
            createPersona(persona);
        else
            updatePersona(persona);

        return persona;
    }

    @TestVisible
    private void updatePersona(SocialPersona persona) {
        try{
            if (socialPersonaShouldBeUpdated(persona)){
                update persona;
            }
        }catch(Exception e) {
            System.debug('Error updating social persona: ' + e.getMessage());
        }
    }
    
    @TestVisible
    private Case buildParentCase(SocialPost post, SocialPersona persona, Map<String, Object> rawData){

        if(!isUnsentParent(rawData)) {
            Case parentCase = findParentCase(post, persona);
            if (parentCase != null) {
                if (!parentCase.IsClosed) {
                    return parentCase;
                }
                else if (caseShouldBeReopened(parentCase)) {
                    reopenCase(parentCase);
                    return parentCase;
                }
            }

            if(shouldCreateCase(post, rawData)){
                isNewCaseCreated = true;
                return createCase(post, persona);
            }
        }
        return null;
    }

    @TestVisible
    private boolean caseShouldBeReopened(Case c){
        return c.id != null && c.isClosed && c.closedDate != null && System.now() <
        c.closedDate.addDays(getMaxNumberOfDaysClosedToReopenCase());
    }

    @TestVisible
    private boolean socialPersonaShouldBeUpdated(SocialPersona persona){
        //Do not update if persona was updated within a day because SocialPersona doesn't change often
        SocialPersona p = [SELECT Id, LastModifiedDate FROM SocialPersona WHERE Id =:persona.Id LIMIT 1];
        return !((p.LastModifiedDate != null) && (System.now() <
        p.LastModifiedDate.addDays(1)));
    }

    @TestVisible
    private void setRelationshipsOnPost(SocialPost postToUpdate, SocialPersona persona, Case parentCase) {
        if (persona.Id != null) {
            postToUpdate.PersonaId = persona.Id;
            if(persona.ParentId.getSObjectType() != SocialPost.sObjectType) {
                postToUpdate.WhoId = persona.ParentId;
            }
        }
        if(parentCase != null) {
            postToUpdate.ParentId = parentCase.Id;
        }
    }

    @TestVisible
    private Boolean hasReview(SocialPost post) {
        return post.ReviewScore != null;
    }

    @TestVisible
    private Boolean hasRecommendationReview(SocialPost post) {
        return post.ReviewScale == 1;
    }

    @TestVisible
    private String getRatingString(SocialPost post) {
        Integer maxNumberOfStars = 5;
        Double reviewScore = post.ReviewScore;
        Double reviewScale = post.ReviewScale;
        
        if (reviewScore == null) {
            reviewScore = 0;
        }
        
        if (reviewScale == null) {
            reviewScale = maxNumberOfStars;
        }

        Integer numberOfStars = Math.floor((reviewScore / reviewScale) * maxNumberOfStars).intValue();
        return numberOfStars.format() + '-Star';
    }

    @TestVisible
    private String getRecommendedReviewString(SocialPost post) {
        if (post.ReviewScore > 0) {
            return Label.socialpostrecommendation.recommends;
        } else {
            return Label.socialpostrecommendation.doesnotrecommend;
        }
    }

    /** 
     * @description: get default queue Id - queue name provided in Social Account Settings
     * @author Gabriela Matos | 11/06/2020
     * @return Queue Id
     * */
    @TestVisible
    private Id getQueueId(String devName){

        List<Group> queueList = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :devName];
        if(queueList != null && !queueList.isEmpty()){
            return queueList[0].Id;
        }
        return null;
    }

    /** 
     * @description: get default username Id - username provided in Social Account Settings
     * @author Gabriela Matos | 11/06/2020
     * @return User Id
     * */
    @TestVisible
    private Id getUserId(String userName){

        List<User> userList = [SELECT Id FROM User WHERE Username = :userName];
        if(userList != null && !userList.isEmpty()){
            return userList[0].Id;
        }
        return null;
    }

    /** 
     * @description: method modified to fit BP needs. Check Social Media Accounts settings to identify key information to create the case
     * @author Gabriela Matos | 11/06/2020
     * @return Case record
     * */
    @TestVisible
    private Case createCase(SocialPost post, SocialPersona persona) {

        String caseSubject = getCaseSubject(post).abbreviate(SUBJECT_MAX_LENGTH);
        //instance of new case considering social account settings
        Case newCase = new Case(subject = caseSubject, 
                                Description = post.Content.replaceAll('[^a-zA-Z0-9\\s+]', ''));
        
        if (persona != null && persona.ParentId != null) {
            if (persona.ParentId.getSObjectType() == Contact.sObjectType) {
                newCase.ContactId = persona.ParentId;
            } else if (persona.ParentId.getSObjectType() == Account.sObjectType) {
                //newCase.AccountId = persona.ParentId;
                newCase.ContactId = [SELECT PersonContactId FROM Account WHERE Id = :persona.ParentId].PersonContactId;
            }
        }

        if (post != null && post.Provider != null) {
            newCase.Origin = post.Provider.trim();
        }

        //getting default values from custom metadata type
        if(socialAccountInContext != null){
            //setting default record type
            if(socialAccountInContext.BPG_Default_Case_RT__c != null){
                newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(socialAccountInContext.BPG_Default_Case_RT__c).getRecordTypeId();
            }

            //setting default owner
            if(socialAccountInContext.BPG_Default_Case_Owner__c != null){
                if(socialAccountInContext.BPG_Case_Owner_Is_Queue__c){
                    newCase.OwnerId = getQueueId(socialAccountInContext.BPG_Default_Case_Owner__c);
                } else {
                    newCase.OwnerId = getUserId(socialAccountInContext.BPG_Default_Case_Owner__c);
                }
            }

            //setting default business unit
            if(socialAccountInContext.BPG_Business_Unit__c != null){
                newCase.BPCM_Business_Unit__c = socialAccountInContext.BPG_Business_Unit__c;
            }

        }

        if (getUsingCaseAssignmentRule()){
            //Find the active assignment rules on case
            AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            if (rules.size() > 0){
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= rules[0].id;
                //Setting the DMLOption on Case instance
                newCase.setOptions(dmlOpts);
            }
        }
        insert newCase;
        return newCase;
    }

    @TestVisible
    private Case findParentCase(SocialPost post, SocialPersona persona) {
        
        Case parentCase = null;
        if (!isChat(post) && (isReplyingToOutboundPost(post) &&
            isSocialPostRecipientSameAsPersona(post.ReplyTo, persona)) ||
            (!isReplyingToOutboundPost(post) && isReplyingToSelf(post,persona))) {
                parentCase = findParentCaseFromPostReply(post);
                if (isParentCaseValid(parentCase)) {
                    return parentCase;
                }
        }
        parentCase = findParentCaseFromPersonaAndRecipient(post, persona);
        if (parentCase == null && isChat(post)) {
            parentCase = findParentCaseOfChatFromPersonaAndRecipient(post, persona);
        }
        return parentCase;
    }

    @TestVisible
    private boolean isChat(SocialPost post) {
        return post.messageType == 'Private' || post.messageType == 'Direct';
    }

    @TestVisible
    private boolean isParentCaseValid(Case parentCase) {
        return parentCase != null && (!parentCase.IsClosed || caseShouldBeReopened(parentCase));
    }

    @TestVisible
    private Case findParentCaseFromPostReply(SocialPost post) {
        
        if (post.ReplyTo != null && String.isNotBlank(post.ReplyTo.ParentId)) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE Id = :post.ReplyTo.ParentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

    // reply to outbound post
    @TestVisible
    private boolean isReplyingToOutboundPost(SocialPost post) {
        return (post != null && post.ReplyTo != null && post.ReplyTo.IsOutbound);
    }

    // replyTo.recipient == inboundSocialPost.persona.externalId
    @TestVisible
    private boolean isSocialPostRecipientSameAsPersona(SocialPost postWithRecipient, SocialPersona persona) {
        return (postWithRecipient != null && postWithRecipient.Recipient == persona.ExternalId);
    }

    // is replying to self
    @TestVisible
    private boolean isReplyingToSelf(SocialPost post, SocialPersona persona) {
        return (post != null &&
        persona != null &&
        String.isNotBlank(persona.Id) &&
        post.ReplyTo != null &&
        String.isNotBlank(post.ReplyTo.PersonaId) &&
        post.ReplyTo.PersonaId == persona.id);
    }
    
    @TestVisible
    private Case findParentCaseFromPersona(SocialPost post, SocialPersona persona) {
    
        SocialPost lastestInboundPostWithSamePersona = findLatestInboundPostBasedOnPersona(post, persona);
        if (lastestInboundPostWithSamePersona != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersona.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

    @TestVisible
    private Case findParentCaseFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        SocialPost lastestInboundPostWithSamePersonaAndRecipient = findLatestInboundPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestInboundPostWithSamePersonaAndRecipient != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersonaAndRecipient.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

    @TestVisible
    private Case findParentCaseOfChatFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        SocialPost lastestReplyToPost = findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestReplyToPost != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestReplyToPost.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

    @TestVisible
    private void reopenCase(Case parentCase) {
        SObject[] status = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = false AND IsDefault = true];
        parentCase.Status = ((CaseStatus)status[0]).MasterLabel;
        update parentCase;
    }

    @TestVisible
    private void matchPost(SocialPost post) {
        if (post.Id != null) return;
            performR6PostIdCheck(post);
        if (post.Id == null){
            performExternalPostIdCheck(post);
        }
    }

    @TestVisible
    private void performR6PostIdCheck(SocialPost post){
        if(post.R6PostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE R6PostId =:post.R6PostId LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }

    @TestVisible
    private void performExternalPostIdCheck(SocialPost post) {
        if (post.provider == 'Facebook' && post.messageType == 'Private') return;
        if (post.provider == null || post.externalPostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE ExternalPostId =:post.ExternalPostId AND Provider = :post.provider LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }

    @TestVisible
    private SocialPost findReplyTo(SocialPost post, SocialPersona persona) {
        if(post.replyToId != null && post.replyTo == null)
            return findReplyToBasedOnReplyToId(post);
        if(post.responseContextExternalId != null){
            if((post.provider == 'Facebook' && post.messageType == 'Private') || (post.provider == 'Twitter' && post.messageType == 'Direct')) {
                SocialPost replyTo = findReplyToBasedOnResponseContextExternalPostIdAndProvider(post);
                if(replyTo.id != null)
                    return replyTo;
            }
            return findReplyToBasedOnExternalPostIdAndProvider(post);
        }
        return new SocialPost();
    }

    @TestVisible
    private SocialPost findReplyToBasedOnReplyToId(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient FROM SocialPost WHERE id = :post.replyToId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();

        return posts[0];
    }

    @TestVisible
    private SocialPost findReplyToBasedOnExternalPostIdAndProvider(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient 
                                    FROM SocialPost 
                                   WHERE Provider = :post.provider 
                                     AND ExternalPostId =:post.responseContextExternalId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();

        return posts[0];
    }

    @TestVisible
    private SocialPost findReplyToBasedOnResponseContextExternalPostIdAndProvider(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId 
                                    FROM SocialPost
                                   WHERE Provider = :post.provider 
                                     AND Recipient = :post.Recipient 
                                     AND responseContextExternalId = :post.responseContextExternalId 
                                ORDER BY posted DESC NULLS LAST LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();

        return posts[0];
    }

    @TestVisible
    private SocialPost findLatestInboundPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null && String.isNotBlank(post.Recipient)) {
            List<SocialPost> posts = [SELECT Id, ParentId 
                                        FROM SocialPost 
                                       WHERE Provider = :post.provider 
                                        AND Recipient = :post.Recipient 
                                        AND PersonaId = :persona.id 
                                        AND IsOutbound = false 
                                   ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }

    @TestVisible
    private SocialPost findLatestInboundPostBasedOnPersona(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null) {
            List<SocialPost> posts = [SELECT Id, ParentId 
                                        FROM SocialPost 
                                       WHERE Provider = :post.provider 
                                         AND PersonaId = :persona.id 
                                         AND IsOutbound = false 
                                    ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }

    @TestVisible
    private SocialPost findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null) {
            List<ExternalSocialAccount> accounts = [SELECT Id 
                                                      FROM ExternalSocialAccount
                                                     WHERE ExternalAccountId = :post.Recipient];
            if (!accounts.isEmpty()) {
                ExternalSocialAccount account = accounts[0];
                List<SocialPost> posts = [SELECT Id, ParentId 
                                            FROM SocialPost 
                                           WHERE Provider = :post.provider 
                                            AND Recipient = :persona.ExternalId 
                                            AND OutboundSocialAccountId =:account.Id 
                                            AND IsOutbound = true 
                                       ORDER BY CreatedDate DESC LIMIT 1];
                if (!posts.isEmpty()) {
                    return posts[0];
                }
            }
        }
        return null;
    }

    @TestVisible
    private void matchPersona(SocialPersona persona) {
        if (persona != null) {
            List<SocialPersona> personaList = new List<SocialPersona>();
            if (persona.Provider != 'Other') {
                if (String.isNotBlank(persona.ExternalId)) {
                    personaList = [SELECT Id, ParentId 
                                    FROM SocialPersona
                                   WHERE Provider = :persona.Provider 
                                     AND ExternalId = :persona.ExternalId LIMIT 1];
                } else if (String.isNotBlank(persona.Name)) {
                    //this is a best-effort attempt to match: persona.Name is not guaranteedto be unique for all networks
                    personaList = [SELECT Id, ParentId 
                                     FROM SocialPersona 
                                    WHERE Provider = :persona.Provider 
                                      AND Name = :persona.Name LIMIT 1];
                }
            } else if(persona.Provider == 'Other' && String.isNotBlank(persona.ExternalId) && String.isNotBlank(persona.MediaProvider)) {
                    personaList = [SELECT Id, ParentId 
                                     FROM SocialPersona 
                                     WHERE MediaProvider = :persona.MediaProvider 
                                     AND ExternalId = :persona.ExternalId LIMIT 1];

            } else if(persona.Provider == 'Other' && String.isNotBlank(persona.Name) && String.isNotBlank(persona.MediaProvider)) {
                    personaList = [SELECT Id, ParentId 
                                     FROM SocialPersona
                                    WHERE MediaProvider = :persona.MediaProvider 
                                      AND Name = :persona.Name LIMIT 1];
            }

            if (!personaList.isEmpty()) {
                persona.Id = personaList[0].Id;
                persona.ParentId = personaList[0].ParentId;
            }
        }
    }

    @TestVisible
    private void createPersona(SocialPersona persona) {
        if (persona == null || String.isNotBlank(persona.Id) || !isThereEnoughInformationToCreatePersona(persona))
            return;

        SObject parent = createPersonaParent(persona);
        persona.ParentId = parent.Id;
        insert persona;
    }

    @TestVisible
    private boolean isThereEnoughInformationToCreatePersona(SocialPersona persona) {
        return String.isNotBlank(persona.Name) && String.isNotBlank(persona.Provider) && String.isNotBlank(persona.MediaProvider);
    }

    @TestVisible
    private boolean shouldCreateCase(SocialPost post, Map<String, Object> rawData) {
        return !isUnsentParent(rawData) && (!hasSkipCreateCaseIndicator(rawData) || hasPostTagsThatCreateCase(post));
    }

    @TestVisible
    private boolean isUnsentParent(Map<String, Object> rawData) {
        Object unsentParent = rawData.get('unsentParent');
        return unsentParent != null && 'true'.equalsIgnoreCase(String.valueOf(unsentParent));
    }

    @TestVisible
    private boolean hasSkipCreateCaseIndicator(Map<String, Object> rawData) {
        Object skipCreateCase = rawData.get('skipCreateCase');
        return skipCreateCase != null && 'true'.equalsIgnoreCase(String.valueOf(skipCreateCase));
    }

    @TestVisible
    private boolean hasPostTagsThatCreateCase(SocialPost post){
        Set<String> postTags = getPostTags(post);
        postTags.retainAll(getPostTagsThatCreateCase());
        return !postTags.isEmpty();
    }

    @TestVisible
    private Set<String> getPostTags(SocialPost post){
        Set<String> postTags = new Set<String>();
        if(post.postTags != null)
            postTags.addAll(post.postTags.split(',', 0));

        return postTags;
    }

    global String getPersonaFirstName(SocialPersona persona) {
        String name = getPersonaName(persona);
        String firstName = '';
        if (name.contains(' ')) {
            firstName = name.substringBeforeLast(' ');
        }
        firstName = firstName.abbreviate(40);
        return firstName;
    }

    global String getPersonaLastName(SocialPersona persona) {
        String name = getPersonaName(persona);
        String lastName = name;
        if (name.contains(' ')) {
            lastName = name.substringAfterLast(' ');
        }
        lastName = lastName.abbreviate(80);
        return lastName;
    }
    
    @TestVisible
    private String getPersonaName(SocialPersona persona) {
        String name = persona.Name.trim();
        if (String.isNotBlank(persona.RealName)) {
            name = persona.RealName.trim();
        }
        return name;
    }

    /** 
     * @description: method modified to fit BP needs. 
     * 1. Added to search for an existing customer (person account) based on Account Name
     * 2. Check Social Media Accounts settings to identify key information to create the Contact
     * @author Gabriela Matos | 11/06/2020
     * @return SObject record (Contact or Account)
     * */
    global virtual SObject createPersonaParent(SocialPersona persona) {
        String firstName = getPersonaFirstName(persona);
        String lastName = getPersonaLastName(persona);

        Account existingCustomer = getExistingCustomerRecord(firstName, lastName);
        if(existingCustomer != null){
            return existingCustomer;

        } else {

            Id contDefaultRTId;
            if(socialAccountInContext != null && socialAccountInContext.BPG_Default_Contact_RT__c != null){
                contDefaultRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(socialAccountInContext.BPG_Default_Contact_RT__c).getRecordTypeId();
            }
            Contact contact = new Contact(LastName = lastName, 
                                         FirstName = firstName);

            String defaultAccountId = getDefaultAccountId();

            if (defaultAccountId != null)
                contact.AccountId = defaultAccountId;

            if (contDefaultRTId != null){
                contact.RecordTypeId = contDefaultRTId;
            }

            insert contact;
            return contact;
        }
    }

    /** 
     * @description: get existing customer record base on the Name. If it returns more than one, it won't assigned the Case to any existing Account.
     * @author Gabriela Matos | 11/06/2020
     * @return Account
     * */
    @TestVisible
    private Account getExistingCustomerRecord(String firstName, String lastName){

        String accName = firstName+' '+lastName;
        List<Account> existingAccount = [SELECT Id, PersonContactId FROM Account WHERE IsPersonAccount = TRUE AND Name = :accName LIMIT 1];
        if(existingAccount != null && !existingAccount.isEmpty() && existingAccount.size() == 1){
            return existingAccount[0];
        }
        return null;
    }

    @TestVisible
    private void handlePostAttachments(SocialPost post, Map<String, Object> rawData) {
        List<PostAttachment> attachments = rawData.containsKey('attachments') ? 
        (List<PostAttachment>)  JSON.deserialize(JSON.serialize(rawData.get('attachments')), List<PostAttachment>.class) : null;
        if (attachments != null && !attachments.isEmpty()) {
            createAttachments(post, attachments);
        } else if (rawData.containsKey('mediaUrls')) {
            List<LegacyPostAttachment> legacyAttachments = (List<LegacyPostAttachment>)
            JSON.deserialize(JSON.serialize(rawData.get('mediaUrls')), List<LegacyPostAttachment>.class);
            if (legacyAttachments != null && !legacyAttachments.isEmpty()) {
                createLegacyAttachments(post, legacyAttachments);
            }
        }
    }

    @TestVisible
    private void createAttachments(SocialPost post, List<PostAttachment> attachments) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(PostAttachment attachment : attachments) {
            ContentVersion contentVersion = createAttachment(attachment);
            if(contentVersion != null){
                contentVersions.add(contentVersion);
            }
        }
        if (!contentVersions.isEmpty()) {
            insert(contentVersions);
            createLinksForAttachmentsToSocialPost(post, contentVersions);
        }
    }

    @TestVisible
    private ContentVersion createAttachment(PostAttachment attachment){
        List<PostAttachmentFacet> facets = attachment.facets;
        if(facets != null && !facets.isEmpty()){
            facets.sort();
            for(PostAttachmentFacet facet : facets) {
                if(facet.url != null && String.isNotBlank(facet.url) && facet.url.length()
                <= ContentVersion.ContentUrl.getDescribe().getLength()) {
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.contentUrl = facet.url;
                    contentVersion.contentLocation = 'L';
                    return contentVersion;
                }
            }
        }
        // No valid facet, fall back to embeddedUrl
        if(attachment.embeddedUrl != null && String.isNotBlank(attachment.embeddedUrl) &&
        attachment.embeddedUrl.length() <= ContentVersion.ContentUrl.getDescribe().getLength()){
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.contentUrl = attachment.embeddedUrl;
            contentVersion.contentLocation = 'L';
            return contentVersion;
        }
        return 
        null;
    }

    @TestVisible
    private void createLinksForAttachmentsToSocialPost(SocialPost post, List<ContentVersion> contentVersions) {
        List<Id> versionIds = new List<Id>(new Map<Id, ContentVersion>(contentVersions).keySet());
        List<ContentDocument> contentDocuments = [SELECT Id 
                                                    FROM ContentDocument 
                                                   WHERE LatestPublishedVersionId IN :versionIds];

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for(ContentDocument contentDocument : contentDocuments) {
            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.contentDocumentId = contentDocument.Id;
            contentDocLink.linkedEntityId = post.Id;
            contentDocLink.shareType = 'I';
            contentDocLink.visibility = 'AllUsers';
            contentDocumentLinks.add(contentDocLink);
        }
        if (!contentDocumentLinks.isEmpty()) {
            insert(contentDocumentLinks);
        }
    }

    public class PostAttachment {
        public String thumbnailUrl;
        public String embeddedUrl;
        public List<PostAttachmentFacet> facets;
        public PostAttachment(String mediaType, String mediaUrl, List<PostAttachmentFacet> facets) {
            this.thumbnailUrl = thumbnailUrl;
            this.embeddedUrl = embeddedUrl;
            this.facets = facets;
        }
    }

    public class PostAttachmentFacet implements Comparable {
        public String url;
        public String mimeType;
        public PostAttachmentFacet(String url, String mimeType){
            this.url = url;
            this.mimeType = mimeType;
        }

        public Integer compareTo(Object compareTo) {
            PostAttachmentFacet compareToFacet = (PostAttachmentFacet)compareTo;
            return getMimetypeValue(mimeType) - getMimetypeValue(compareToFacet.mimeType);
        }

        @TestVisible
        private Integer getMimetypeValue(String mimetype){
            final List<String> typePreference = new List<String> {'video', 'audio', 'image', 'text', 'application'};
            // Prefer known mimetype than null
            if(mimetype == null || String.isBlank(mimetype))
                return typePreference.size();
            
            String type = getTypeFromMimeType(mimetype);
            if(type != null && String.isNotBlank(type) && typePreference.contains(type.toLowercase())){
                return typePreference.indexOf(type);
            }

            return typePreference.size();
        }

        @TestVisible
        private String getTypeFromMimeType(String mimetype) {
            if(mimetype.contains('/')) {
                return mimetype.substring(0, mimetype.indexOf('/'));
            }
            return null;
        }
    }

    @TestVisible
    private void createLegacyAttachments(SocialPost post, List<LegacyPostAttachment> attachments) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        
        for(LegacyPostAttachment attachment : attachments) {
            if (String.isNotBlank(attachment.mediaUrl) && attachment.mediaUrl != null &&
            attachment.mediaUrl.length() <= ContentVersion.ContentUrl.getDescribe().getLength()) {
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.contentUrl = attachment.mediaUrl;
                contentVersion.contentLocation = 'L';
                contentVersions.add(contentVersion);
            }
        }

        if (!contentVersions.isEmpty()) {
            insert(contentVersions);
            createLinksForLegacyAttachmentsToSocialPost(post, contentVersions);
        }
    }

    @TestVisible
    private void createLinksForLegacyAttachmentsToSocialPost(SocialPost post, List<ContentVersion> contentVersions) {
        List<Id> versionIds = new List<Id>(new Map<Id, ContentVersion>(contentVersions).keySet());
        List<ContentDocument> contentDocuments = [SELECT Id 
                                                    FROM ContentDocument 
                                                   WHERE LatestPublishedVersionId IN :versionIds];
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for(ContentDocument contentDocument : contentDocuments) {
            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.contentDocumentId = contentDocument.Id;
            contentDocLink.linkedEntityId = post.Id;
            contentDocLink.shareType = 'I';
            contentDocLink.visibility = 'AllUsers';
            contentDocumentLinks.add(contentDocLink);
        }

        if (!contentDocumentLinks.isEmpty()) {
            insert(contentDocumentLinks);
        }
    }

    public class LegacyPostAttachment {
        public String mediaType;
        public String mediaUrl;
        public LegacyPostAttachment(String mediaType, String mediaUrl) {
            this.mediaType = mediaType;
            this.mediaUrl = mediaUrl;
        }
    }
}