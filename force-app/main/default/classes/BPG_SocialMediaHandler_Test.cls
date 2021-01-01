/**
* @author: Provided by Salesforce
* @date: 11/06/2020
* @description: Test class to cover BPG_SocialMediaAccountUtil.cls
* @name BPG_SocialMediaHandler_Test.cls
*/

@isTest
public class BPG_SocialMediaHandler_Test {
         
    static Map<String, Object> sampleSocialData;
    static BPG_SocialMediaHandler handler;
    
    static {
        handler = new BPG_SocialMediaHandler();
        sampleSocialData = getSampleSocialData('1');
    }
    @testSetup static void setupData() {
        
    BPG_SocialMediaAccountUtil.SOCIAL_MEDIA_ACCOUNTS = new map<string,BPG_Social_Media_Account__mdt>{
            '12345678'=> new BPG_Social_Media_Account__mdt(
             BPG_Case_Owner_Is_Queue__c = true,
             BPG_Days_To_Reopen_Case__c = 5,
             BPG_Default_Account_Name__c = 'BPCM Social Media' ,
             BPG_Default_Account_RT__c = 'BPCM_Location',
             BPG_Default_Case_Owner__c ='BPCM_CPS_Tier_1',
             BPG_Default_Case_RT__c = 'BPCM_Technical',
             BPG_Default_Contact_RT__c ='BPCM_Contact',
             BPG_Project_Prefix__c ='BPCM',
             BPG_Run_Case_Assignment_Rules__c = false,
             BPG_Social_Account_Id__c = '12345678'
             ),
             '1634359'=> new BPG_Social_Media_Account__mdt(
             BPG_Case_Owner_Is_Queue__c = false,
             BPG_Days_To_Reopen_Case__c = 5,
             BPG_Default_Account_Name__c = 'BPCM Social Media' ,
             BPG_Default_Account_RT__c = 'BPCM_Location',
             BPG_Default_Case_Owner__c = 'BPCM_CS_Tier_1',
             BPG_Default_Case_RT__c = 'BPCM_General_EV',
             BPG_Default_Contact_RT__c = 'BPCM_Contact',
             BPG_Project_Prefix__c = 'BPCM',
             BPG_Run_Case_Assignment_Rules__c = false,
             BPG_Social_Account_Id__c ='1634359'
             
             )
          };
           
    
    }

    static testMethod void verifyNewRecordCreation() {
        setupData();
        SocialPost post = getSocialPost(sampleSocialData);
        post.recipient = '12345678';
        SocialPersona persona = getSocialPersona(sampleSocialData);
        test.startTest();
        BPG_SocialMediaHandler.accIdSocialMediaMap = BPG_SocialMediaAccountUtil.SOCIAL_MEDIA_ACCOUNTS;
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        Contact createdContact = [SELECT Id FROM Contact];
        Case createdCase = [SELECT Id, ContactId,RecordTypeID FROM Case];
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        System.assertEquals(createdCase.ContactId, createdContact.Id, 'Contact is not linked to the Case.');
        System.assertEquals('BPCM_Technical',[SELECT id,DeveloperName from RecordType where id = :createdCase.RecordTypeID AND sObjectType='Case'].DeveloperName,'Case Record Type is picked from the Custom Metadata Type');
        }

    static testMethod void matchSocialPostRecord() {
        setupData();
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        insert existingPost;
        SocialPost post = getSocialPost(sampleSocialData);
        post.R6TopicId = existingPost.R6TopicId;
        SocialPersona persona = getSocialPersona(sampleSocialData);
        test.startTest();
        post.messageType = 'Private';
        post.replyToId = existingPost.id;
        BPG_SocialMediaHandler.accIdSocialMediaMap = BPG_SocialMediaAccountUtil.SOCIAL_MEDIA_ACCOUNTS;
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        handler.handleInboundSocialPost(existingPost , persona, sampleSocialData);
        List<BPG_SocialMediaHandler.PostAttachmentFacet> pafList = new List<BPG_SocialMediaHandler.PostAttachmentFacet>();
        BPG_SocialMediaHandler.PostAttachmentFacet paf = new BPG_SocialMediaHandler.PostAttachmentFacet('test','video');
        BPG_SocialMediaHandler.LegacyPostAttachment lpa = new BPG_SocialMediaHandler.LegacyPostAttachment('video','www.');
        BPG_SocialMediaHandler.PostAttachment pa = new BPG_SocialMediaHandler.PostAttachment('vide','www.',pafList);
        test.stopTest();
        system.assertEquals('Private',post.messageType,'Post Message Type is set to Private');
        system.assertEquals(post.replyToId,existingPost.id,'Reply to Id is updated as per Social Post');
        
        
    }

    static testMethod void matchSocialPersonaRecord() {
        setupData();
        Contact existingContact = new Contact(LastName = 'LastName');
        insert existingContact;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);
        persona.ExternalId = existingPersona.ExternalId;
        test.startTest();
        BPG_SocialMediaHandler.accIdSocialMediaMap = BPG_SocialMediaAccountUtil.SOCIAL_MEDIA_ACCOUNTS;
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        persona.Provider = 'Other';
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        persona.ExternalId = '';
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        Contact createdContact = [SELECT Id FROM Contact];
        Case createdCase = [SELECT Id, ContactId FROM Case];
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        System.assertEquals(createdCase.ContactId, createdContact.Id, 'Contact is not linked to the Case.');
    }
    
    static testMethod void matchSocialPersonaRecord2() {
        setupData();
        Contact existingContact = new Contact(LastName = 'LastName');
        insert existingContact;
        String recipient = '12345678';
        
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ExternalId = '';
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        SocialPost post = getSocialPost(sampleSocialData);
        post.PersonaId = existingPersona.id;
        post.R6PostId = 'R6PostId';
        post.recipient = recipient;
        test.startTest();
        post.ReviewScale = 1;
        post.ReviewScore = 0;
        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        post.messageType = 'Direct';
        post.ReviewScale = 1;
        post.ReviewScore = 1;
        BPG_SocialMediaHandler.accIdSocialMediaMap = BPG_SocialMediaAccountUtil.SOCIAL_MEDIA_ACCOUNTS;
        sampleSocialData.put('skipCreateCase',true);
        sampleSocialData.put('unsentParent',true);
        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        test.stopTest();
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        Contact createdContact = [SELECT Id FROM Contact];
        Case createdCase = [SELECT Id, ContactId FROM Case];
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        System.assertEquals(createdCase.ContactId, createdContact.Id, 'Contact is not linked to the Case.');
    }


    static testMethod void matchCaseRecord() {
        setupData();
        Contact existingContact = new Contact(LastName = 'LastName');
        insert existingContact;

        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        
        Case existingCase = new Case(ContactId = existingContact.Id, Subject = 'Test Case');
        insert existingCase;
        
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        existingPost.ParentId = existingCase.Id;
        existingPost.WhoId = existingContact.Id;
        existingPost.PersonaId = existingPersona.Id;
        String recipient = '12345678';
        existingPost.recipient = recipient;
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.responseContextExternalId = existingPost.ExternalPostId;
        post.Recipient = recipient;
        test.startTest();
        BPG_SocialMediaHandler.accIdSocialMediaMap = BPG_SocialMediaAccountUtil.SOCIAL_MEDIA_ACCOUNTS;
        sampleSocialData.remove('attachments');
        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        test.stopTest();
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId 
                                    FROM SocialPost
                                   WHERE R6TopicId = :post.R6TopicId Limit 1];
        System.assertEquals(existingPersona.Id, createdPost.PersonaId, 'Post is not linked to the Persona.');
        System.assertEquals(existingContact.Id, createdPost.WhoId, 'Post is not linked to the Contact');
        System.assertEquals(existingCase.Id, createdPost.ParentId, 'Post is not linked to the Case.');
        System.assertEquals(1, [SELECT Id FROM Case].size(), 'There should only be 1 Case.');
    }

    static testMethod void reopenClosedCase() {
        setupData();
        Contact existingContact = new Contact(LastName = 'LastName');
        insert existingContact;
        
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        
        Case existingCase = new Case(ContactId = existingContact.Id, Subject = 'Test Case',
        Status = 'Closed');
        insert existingCase;
        
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        existingPost.ParentId = existingCase.Id;
        existingPost.WhoId = existingContact.Id;
        existingPost.PersonaId = existingPersona.Id;
        String recipient = '12345678';
        existingPost.recipient = recipient;
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.responseContextExternalId = existingPost.ExternalPostId;
        post.Recipient = recipient;
        test.startTest();
        BPG_SocialMediaHandler.accIdSocialMediaMap = BPG_SocialMediaAccountUtil.SOCIAL_MEDIA_ACCOUNTS;
        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        handler.isSocialPostRecipientSameAsPersona(existingPost,existingPersona);
        handler.hasPostTagsThatCreateCase(existingPost);
        handler.getPostTags(existingPost);
        handler.getUserID('test');
        test.stopTest();
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId 
                                    FROM SocialPost
                                   WHERE R6TopicId = :post.R6TopicId Limit 1];
        System.assertEquals(existingPersona.Id, createdPost.PersonaId, 'Post is not linked to the Persona.');
        System.assertEquals(existingContact.Id, createdPost.WhoId, 'Post is not linked to the Contact');
        System.assertEquals(existingCase.Id, createdPost.ParentId, 'Post is not linked to the Case.');
        System.assertEquals(1, [SELECT Id FROM Case].size(), 'There should only be 1 case');
        System.assertEquals(false, [SELECT Id, IsClosed FROM Case WHERE Id = :existingCase.Id].IsClosed, 'Case should be open.');
              
    }
    
    static testMethod void reopenClosedCase2() {
        setupData();
        Contact existingContact2 = new Contact(LastName = 'TestName');
        insert existingContact2;
        
        SocialPersona existingPersona2 = getSocialPersona(getSampleSocialData('3'));
        existingPersona2.ParentId = existingContact2.Id;
        insert existingPersona2;
        
        Case existingCase2 = new Case(ContactId = existingContact2.Id, Subject = 'Test Case 2',
        Status = 'Closed');
        insert existingCase2;
        
        SocialPost existingPost3 = getSocialPost(getSampleSocialData('3'));
        existingPost3.ParentId = existingCase2.Id;
        existingPost3.WhoId = existingContact2.Id;
        existingPost3.PersonaId = existingPersona2.Id;
        String recipient1 = 'scs';
        existingPost3.recipient = recipient1;
        insert existingPost3;
        
        SocialPost post2 = getSocialPost(sampleSocialData);
        post2.responseContextExternalId = existingPost3.ExternalPostId;
        post2.Recipient = recipient1;
        post2.provider='Facebook';
        post2.messageType='Private';
        
        test.startTest();
        BPG_SocialMediaHandler.accIdSocialMediaMap = BPG_SocialMediaAccountUtil.SOCIAL_MEDIA_ACCOUNTS;
        handler.handleInboundSocialPost(post2, existingPersona2, sampleSocialData);
        handler.findParentCaseFromPersona (existingPost3,existingPersona2);
        test.stopTest();
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId 
                                    FROM SocialPost
                                   WHERE R6TopicId = :post2.R6TopicId Limit 1];
        System.assertEquals(existingPersona2.Id, createdPost.PersonaId, 'Post is not linked to the Persona.');
        System.assertEquals(existingContact2.Id, createdPost.WhoId, 'Post is not linked to the Contact');
        System.assertEquals(existingCase2.Id, createdPost.ParentId, 'Post is not linked to the Case.');
        System.assertEquals(true, [SELECT Id, IsClosed FROM Case WHERE Id = :existingCase2.Id].IsClosed, 'Case should be open.');
              
    }

    static SocialPost getSocialPost(Map<String, Object> socialData) {
        SocialPost post = new SocialPost();
        post.Name = String.valueOf(socialData.get('source'));
        post.Content = String.valueOf(socialData.get('content'));
        post.Posted = Date.valueOf(String.valueOf(socialData.get('postDate')));
        post.PostUrl = String.valueOf(socialData.get('postUrl'));
        post.Provider = String.valueOf(socialData.get('mediaProvider'));
        post.MessageType = String.valueOf(socialData.get('messageType'));
        post.ExternalPostId = String.valueOf(socialData.get('externalPostId'));
        post.R6TopicId = String.valueOf(socialData.get('R6TopicId'));
        post.ReviewScore = integer.valueOf(socialData.get('reviewScore'));
        return post;
    }

    static SocialPersona getSocialPersona(Map<String, Object> socialData) {
        SocialPersona persona = new SocialPersona();
        persona.Name = String.valueOf(socialData.get('author'));
        persona.RealName = String.valueOf(socialData.get('realName'));
        persona.Provider = String.valueOf(socialData.get('mediaProvider'));
        persona.MediaProvider = String.valueOf(socialData.get('mediaProvider'));
        persona.ExternalId = String.valueOf(socialData.get('externalUserId'));
        return persona;
    }

    static Map<String, Object> getSampleSocialData(String suffix) {
        setupData();
        Map<String, Object> socialData = new Map<String, Object>();
        socialData.put('R6TopicId', '3242434');
        socialData.put('r6SourceId', 'R6SourceId' + suffix);
        socialData.put('postTags', null);
        socialData.put('externalPostId', 'ExternalPostId' + suffix);
        socialData.put('content', 'Content' + suffix);
        socialData.put('postDate', '2015-01-12T12:12:12Z');
        socialData.put('mediaType', 'Twitter');
        socialData.put('author', 'Author');
        socialData.put('skipCreateCase', false);
        socialData.put('mediaProvider', 'TWITTER');
        socialData.put('externalUserId', 'ExternalUserId');
        socialData.put('postUrl', 'PostUrl' + suffix);
        socialData.put('messageType', 'Tweet');
        socialData.put('source', 'Source' + suffix);
        socialData.put('replyToExternalPostId', null);
        socialData.put('realName', 'Real Name');
        socialData.put('reviewScore', 10);
        string jsonstr = '[{"thumbnailUrl":"Value1","embeddedUrl":"Value2","facets":[{"url":"Value3","mimeType": "video"}]}]';
        socialData.put('attachments',JSON.deserializeUntyped(jsonstr));
        string jsonstr2 = '[{"mediaType":"video","mediaUrl":"Value2"}]';
        socialData.put('mediaUrls',JSON.deserializeUntyped(jsonstr2));
        socialData.put('R6PostId','R6PostId');
        return socialData;
    }

}