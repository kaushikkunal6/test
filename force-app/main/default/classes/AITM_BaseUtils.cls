/*************************************************************************
* @author         George
* @date           01/December/2017
* @group          AirBP
* @description    controller class when Generate Offer button was clicked. It attaches Tender Offer GT&C 
*                 and MSDS PDF files(email attachments).

* history
* 01/December/2017  George       Created
* 19/April/2018     srnandan     Modified - AR-2979 resolved governor limits
*                                added comments both at class and method level
* 23/April/2018     srnandan     Modified - AR-2874 Added new method updateContentVersion
* 16/August/2018    srnandan     Modified - AR-3342  Added new method to get tendering 
*                                and labp urls from metadata and getCommunityNetworkId for LABP
* 20/August/2018    srnandan     Modified - AR-XXXX added new method getProductDescription
* 02/February/2019  srnandan     Modified - AR-4939 added new method 
* 15/May/2019       dmahapatra   Modified - AR-4970 added new getTaxesFeesFuelType for Taxes and Fees 
* 21/May/2019       srnandan     Modified - AR-5029 added new method getProductDensity
* 30/July/2019      srnandan     Added constants profiles collection
* 02/August/2019    srnandan     Modified - AR-5287 added method checkCongaPermission for conga permission access check
* 28/August/2019    srnandan     Modified - Moved the methods i.e. getGenericLegalDocumentResource, legalDocumentNotGenerated, 
*                                getMSDSLegalDocumentResource from CongaOfferContainerController to BaseUtils for reusability
* 29/Nov/2019       saravan      Modified - 738253 - Added new method sendEmailsMessage
* 28/Feb/2020       Neeti        added - getDeliveryPointMapping
*************************************************************************/
public without sharing class AITM_BaseUtils {
    
    public static final Set<String> LABP_LMPROFILE = new Set<String>{'Air_TMLABPLM','Air_TMLABPLoginLM'};
    public static final Set<String> AIR_LMPROFILE = new Set<String>{'Air_TMLocation Manager'};
    public static final Set<String> AMPROFILE = new Set<String>{'Air_TMLABP','Air_TMAccount Manager', 'Air_TMLABPLogin'};
    private static final String CONTRACT_DOCUMENT_STATIC_RESOURCE = 'AITM_NewOfferContractTerms';
    private static final String CONTRACT_WORD_DOCUMENT_STATIC_RESOURCE = 'AITM_NewOfferContractTermsWord';
    public static final Map<String,String> MAP_NEWOFFER_MSDS_FILE_STATIC_RESOURCE = new Map<String,String>{'AITM_NewOfferMSDS2101ContractTerms'=>Label.AITM_NewOfferPDFMSDS2101FilePrefix,'AITM_NewOfferMSDS2102ContractTerms'=>Label.AITM_NewOfferPDFMSDS2102FilePrefix,'AITM_NewOfferMSDS2105ContractTerms'=>Label.AITM_NewOfferPDFMSDS2105FilePrefix};
    public static final Set<String> LABP_AMPROFILE = new Set<String>{'Air_TMLABP','Air_TMLABPLogin'};
    public static final String VALUE_TYPE_DOUBLE = 'DOUBLE';
    public static final String VALUE_TYPE_PERCENT = 'PERCENT';
    public static final String VALUE_TYPE_INTEGER = 'INTEGER';
    public static final String VALUE_TYPE_DATE = 'DATE';
    public static final String SHARING_REASON = 'Sharing_To_Pricing_Delegates__c';
    public final static Set<String> PROFILES_ALLOWED_TO_UPDATE = new Set<String>{
    'System Administrator',
    'Air_TMAccount Manager',
    'Air_TMLABP',
    'Air_TMLABPLogin'
    };
    private static final ID ID_TLLI_RECORD_TYPE_DEFAULT = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
    /**
     * @description creates email message
     * @param  targetObjId of type Id
     * @param  emailTemplate of type emailTemplate
     * @param  objectToPopulateId of type Id
     * @param  senderDisplayName of type String
     * @param  ccAddresses of type List collection
     * @return Messaging.SingleEmailMessage
     */
    public static Messaging.SingleEmailMessage createEmailMessage(Id targetObjId, EmailTemplate emailTemplate, Id objectToPopulateId, String senderDisplayName, List<String> ccAddresses ){

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTemplateID(emailTemplate.Id);
        message.setSaveAsActivity(false);
        message.setTargetObjectId(targetObjId);
        message.setWhatId(objectToPopulateId);
        message.setSenderDisplayName(senderDisplayName);

        if (ccAddresses.size() > 0) {
            message.setCCAddresses(ccAddresses);
        }

        return message;

    }

    /**
     * @description creates email message
     * @param  message of type Messaging.SingleEmailMessage
     * @return void
     */
    public static void sendEmails(Messaging.SingleEmailMessage message){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        mails.add(message);
        try {
            Messaging.sendEmail(mails);
        } catch(Exception e) {
            AITM_Log.createErrorMessage(e.getMessage() + ' Tender Details:' + message.getSubject());
        }
    }
	
	/**
     * @description creates email message
     * @param  message of type Messaging.SingleEmailMessage
     * @return void
     */
    public static String sendEmailsMessage(Messaging.SingleEmailMessage message){
        String errorMessage='';        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        mails.add(message);
        try {
            Messaging.sendEmail(mails);
        } catch(Exception e) {
            AITM_Log.createErrorMessage(e.getMessage() + ' Tender Details:' + message.getSubject());
            errorMessage=e.getMessage();
        }        
        return errorMessage;
    }

    /**
     * @description sends emails
     * @param  mails of type List<Messaging.SingleEmailMessage>
     * @return void
     */
    public static void sendEmails(List<Messaging.SingleEmailMessage> mails){
        try {
            Messaging.sendEmail(mails);
        } catch(Exception e) {
            AITM_Log.createErrorMessage(e.getMessage());
        }
    }

    /**
     * @description gets email template
     * @param  templateUniqueName of type string
     * @return EmailTemplate
     */
    public static EmailTemplate getEmailTemplate(String templateUniqueName) {
        return [SELECT id FROM EmailTemplate WHERE DeveloperName = :templateUniqueName];
    }

    /**
     * @description creates chatter message with mention
     * @param  subjectId of type Id
     * @param  mentionObjId of type Id
     * @param  chatterText of type string
     * @return ConnectApi.BatchInput
     */
    public static ConnectApi.BatchInput createChatterMessageWithMention(Id subjectId, Id mentionObjId, String chatterText) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        //Mention user here
        mentionSegmentInput.id = mentionObjId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        textSegmentInput.text = '\n'+ chatterText;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = subjectId;
        
        return new ConnectApi.BatchInput(feedItemInput);

    }

    /**
     * @description post to chatter
     * @param  message of type ConnectApi.BatchInput
     * @return List<ConnectApi.BatchInput>
     */
    public static List<ConnectApi.BatchInput> postToChatter(ConnectApi.BatchInput message) {

        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        batchInputs.add(message);

        if(!Test.isRunningTest()){
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchinputs);
            return batchInputs;
        }

        return null;

    }

    /**
     * @description post to chatter
     * @param  batchinputs of type List<ConnectApi.BatchInput>
     * @return List<ConnectApi.BatchInput>
     */
    public static List<ConnectApi.BatchInput> postToChatter(List<ConnectApi.BatchInput> batchinputs) {

        if(!Test.isRunningTest()){
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchinputs);
            return batchInputs;
        }

        return null;
    }

    /**
     * @description gets text by lines
     * @param  textBody of type string
     * @return List<String>
     */
    public static List<String> getTextByLines(String textBody) {
        if (textBody == null) {
            return new List<String>();
        }
        return textBody.split('\n');
    }

    /**
     * @description gets field value type
     * @param  objectName of type string
     * @param  fieldName of type string
     * @return String
     */
    public static String getFieldValueType(String objectName, String fieldName){
        Map <String, Schema.SObjectType> schemaDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sT = schemaDescribe.get(objectName);
        Schema.DescribeSObjectResult result = sT.getDescribe();
        Map<String, Schema.SObjectField> mapData = result.fields.getMap();
        String fieldType;
        for(Schema.SObjectField sField : mapData.values()){
            Schema.DescribeFieldResult fieldInfo = sField.getDescribe();
            if(fieldInfo.getName() == fieldName){
                fieldType = String.valueOf(fieldInfo.getType());
            }
        }

        return fieldType;
    }

    /**
     * @description gets picklist values of field 
     * @param  object_name of type string
     * @param  field_name of type string
     * @param  first_val of type string
     * @return List<selectOption>
     */
    public static List<selectOption> getPickValues(String object_name, String field_name, String first_val) {
        List<selectOption> options = new List<selectOption>(); 
        if (first_val != null) { 
            options.add(new selectOption(first_val, first_val));
        }
        sObject sObj = Schema.getGlobalDescribe().get(object_name).newSObject() ;
        Schema.sObjectType sobject_type = sObj.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
        List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); 
        for (Schema.PicklistEntry a : pick_list_values) {
            options.add(new selectOption(a.getValue(), a.getLabel())); 
        }
        return options; 
    }

    /**
     * @description creates chatter post relate to parentid
     * @param  body of type String
     * @param  parentId of type Id
     * @param  contentVersionId of type Id
     * @return FeedItem
     */
    public static FeedItem createChatterPostToRelate(String body, Id parentId, Id contentVersionId) {
        FeedItem feedItemElement = new FeedItem(
            Body = body, 
            ParentId = parentId, 
            RelatedRecordId = contentVersionId, 
            Type = 'ContentPost',
			Visibility = 'AllUsers'
        );
        insert feedItemElement;
        return feedItemElement;
    }
    
    /**
     * @description creates collection of chatter post relate to parentid
     * @param  body of type String
     * @param  parentId of type Id
     * @param  contentVersionList List collection of ContentVersion
     * @return List<FeedItem> collection of feed item
     */
    public static List<FeedItem> createChatterPostToRelate(String body, Id parentId, ContentVersion[] contentVersionList) {
        List<FeedItem> feedItemList = new List<FeedItem>();
        for(ContentVersion content : contentVersionList) {
            FeedItem feedItemElement = new FeedItem(
            Body = body, 
            ParentId = parentId, 
            RelatedRecordId = content.Id, 
            Type = 'ContentPost',
			Visibility = 'AllUsers'
            );    
            feedItemList.add(feedItemElement);
        }
        
        insert feedItemList;
        return feedItemList;
    }

    /**
     * @description creates content version
     * @param  fileBody of type Blob
     * @param  fileName of type String
     * @return ContentVersion
     */
    public static ContentVersion createContentVersion(Blob fileBody, String fileName) {
        ContentVersion contractFile = new ContentVersion(
            VersionData = fileBody,
            Origin = 'H',
            Title = fileName,
            PathOnClient = fileName
        );
        
        if(checkRunningUserIsLABP()) {
            if(getLABPCommunityId() != '') {
                contractFile.NetworkId = getLABPCommunityId();
            }
        }
        
        insert contractFile;
        return contractFile;
    }

    /**
     * @description creates collection of content version
     * @param  contentFiles of type List<StaticResource>
     * @param  fileResources of type Map<String,String>
     * @return List<ContentVersion>
     */
    public static List<ContentVersion> createContentVersion(List<StaticResource> contentFiles, Map<String,String> fileResources) {
        List<ContentVersion> contractFileList = new List<ContentVersion>();
        for(StaticResource msdsResource : contentFiles) {
            ContentVersion contractFile = new ContentVersion(
                VersionData = msdsResource.Body,
                Origin = 'H',
                Title = fileResources.get(msdsResource.Name) + '.pdf',
                PathOnClient = fileResources.get(msdsResource.Name) + '.pdf'
            );
            
            if(checkRunningUserIsLABP()) {
                if(getLABPCommunityId() != '') {
                    contractFile.NetworkId = getLABPCommunityId();
                } 
            }
            contractFileList.add(contractFile);
        }
        insert contractFileList;
        return contractFileList;
    }

    /**
     * @description updates content version
     * @param  fileBody of type Blob
     * @param  fileName of type String
     * @param  contentId of type Id
     * @return ContentVersion
     */
    public static ContentVersion updateContentVersion(Blob fileBody, String fileName, Id contentId) {
        ContentVersion contractFile = new ContentVersion(
            Id = contentId,
            VersionData = fileBody,
            Origin = 'H',
            Title = fileName,
            PathOnClient = fileName
        );

        if(checkRunningUserIsLABP()) {
          if(getLABPCommunityId() != '') {
             contractFile.NetworkId = getLABPCommunityId();
          } 
        }

        update contractFile;
        return contractFile;
    }

    /**
     * @description checks running user is system administrator
     * @param  null
     * @return Boolean
     */
    public static Boolean checkRunningUserIsSystemAdministrator(){
        return [SELECT Count() FROM Profile WHERE Id = :UserInfo.getProfileId() AND (Name = 'System Administrator' or Name = 'AITM_Data_Migration') LIMIT 1] > 0;
    }

    /**
     * @description checks community user is LABP
     * @param  null
     * @return Boolean
     */
    public static Boolean checkRunningUserIsLABP(){
        return [SELECT Count() FROM Profile WHERE Id = :UserInfo.getProfileId() AND (Name = 'Air_TMLABP' OR Name = 'Air_TMLABPLogin') LIMIT 1] > 0;
    }
    
    /**
     * @description checks conga permission assigned to user
     * @param  null
     * @return Boolean
     */
    public static Boolean checkCongaPermission(){
        return [SELECT Count() FROM PermissionSetAssignment p WHERE p.PermissionSet.IsOwnedByProfile = false AND permissionset.label = 'Composer User' AND p.Assignee.ID =: UserInfo.getUserId() LIMIT 1] > 0;
    }
    
    /**
     * @description gets LABP community URL
     * @param  null
     * @return String
     */
    public static String getLABPURL(){
        try {
                return [SELECT AITM_SiteURL__c FROM AITM_Site_URL_Setting__mdt  WHERE Label= 'LABPTendering' LIMIT 1].AITM_SiteURL__c;
            } catch(Exception ex) {
                return '';
            }
        
    }

    /**
     * @description gets Tendering site URL
     * @param  null
     * @return String
     */
    public static String getTenderingURL(){
        try {
                return [SELECT AITM_SiteURL__c FROM AITM_Site_URL_Setting__mdt  WHERE Label= 'Tendering' LIMIT 1].AITM_SiteURL__c;
            } catch(Exception ex) {
                return '';
            }
    }

    /**
     * @description This method is used to returns TMS Product Description mapping value
     * @param product of type string
     * @return String 
     */
     public static String getProductDescription(String product) {
        try {
           return [SELECT AITM_Product__c FROM AITM_Product_Density_Mapping__mdt WHERE AITM_TMS_Product_Density__c =: product LIMIT 1].AITM_Product__c;
        }
        catch(Exception ex) {
            return '';
        }
    }
    /**
        * @description This method is used to return Taxes and Fees Fuel Type mapping value
        * @param product of type string
        * @return String 
          Added for New T&F - Thanuja
        */
        public static String getTaxesFeesFuelType(String productTax) {
            try {
                return [SELECT AITM_TaxFees_Product__c FROM AITM_Product_Density_Mapping__mdt WHERE AITM_Product__c =: productTax LIMIT 1].AITM_TaxFees_Product__c;
            }
            catch(Exception ex) {
                return '';
            }
        }
        /**
     * @description This method is used to returns product and density based on ProductDensity passed
     * @param product of type string
     * @return List<AITM_Product_Density_Mapping__mdt> 
     */
     public static List<AITM_Product_Density_Mapping__mdt> getProductDensity(String product) {
        try {
           return [SELECT AITM_Product__c, AITM_Density__c, AITM_Description__c FROM AITM_Product_Density_Mapping__mdt WHERE AITM_TMS_Product_Density__c =: product LIMIT 1];
        }
        catch(Exception ex) {
            return new List<AITM_Product_Density_Mapping__mdt>();
        }
    }
    
    /**
     * @description This method is used to returns product and density based on ProductDensity passed
     * @param productSet of type Set<String>
     * @return Map<String, AITM_Product_Density_Mapping__mdt>
     */
     public static Map<String, AITM_Product_Density_Mapping__mdt> getProductDensityMap(Set<String> productSet) {
        Map<String, AITM_Product_Density_Mapping__mdt> mapProductDensity = new Map<String,AITM_Product_Density_Mapping__mdt>(); 
        try {
            List<AITM_Product_Density_Mapping__mdt> productDensityList = [SELECT AITM_TMS_Product_Density__c, AITM_Product__c, AITM_Density__c, AITM_Description__c FROM AITM_Product_Density_Mapping__mdt WHERE AITM_TMS_Product_Density__c =: productSet];
            for(AITM_Product_Density_Mapping__mdt productDensity : productDensityList) {
                mapProductDensity.put(productDensity.AITM_TMS_Product_Density__c, productDensity);
            }           
        } catch(Exception ex) {
            return mapProductDensity;
        }
        return mapProductDensity;
    }

    /**
     * @description This method is used to return LABP Community ID
     * @param null
     * @return String 
     */
     public static String getLABPCommunityId() {
        try {
           return [SELECT Id FROM Network WHERE Name like 'LABP%' LIMIT 1].Id;
        }
        catch(Exception ex) {
            return '';
        }
    }

    /**
     * @description This method is used to return tender permission accessible current user true or false
     * @param Id recordId
     * @return Boolean
     */
    public static Boolean checkTenderShareAccess(Id recordId) {
        List<AITM_Tender__share> tenderShare = [SELECT UserOrGroupId, AccessLevel FROM AITM_Tender__share WHERE ParentId =:recordId And UserOrGroupId=:UserInfo.getUserId()];
        return (tenderShare.size() > 0 && tenderShare[0].AccessLevel != 'Read'); //assumption always one record will be there for current user
    }

    /**
     * @description checks sharing permission for tender
     * @param recordId of type Id
     * @return Boolean
     */
    public static Boolean checkSharePermission(Id recordId) {
        if(checkRunningUserIsSystemAdministrator()) {
            return true;
        } else if(checkRunningUserIsLABP()){
            return true;
        } else {
            return checkTenderShareAccess(recordId);
        }
    }

    /**
     * @description returns StaticResource for generic legal document GT&C
     * @param  null
     * @return StaticResource object
     */
    public static StaticResource getGenericLegalDocumentResource() {
        return [SELECT Body FROM StaticResource WHERE Name = :CONTRACT_DOCUMENT_STATIC_RESOURCE LIMIT 1][0];
    }
    
    /**
     * @description returns StaticResource for generic legal document GT&C
     * @param  null
     * @return StaticResource object
     */
    public static StaticResource getGenericLegalDocumentResourceInWord() {
        return [SELECT Body FROM StaticResource WHERE Name = :CONTRACT_WORD_DOCUMENT_STATIC_RESOURCE LIMIT 1][0];
    }
    
    /**
     * @description returns list of static resource where name related to msds files
     * @param  null
     * @return List of type StaticResource
     */
    public static List<StaticResource> getMSDSLegalDocumentResource() {
        return [SELECT Name,Body FROM StaticResource WHERE Name in :MAP_NEWOFFER_MSDS_FILE_STATIC_RESOURCE.keySet() LIMIT 5];
    }

    /**
     * @description returns true if legaldocument not generated else false
     * @param  null
     * @return boolean
     */
    public static Boolean legalDocumentNotGenerated(String tenderId) {
        Boolean result = true;
        for (FeedItem item : [SELECT Id, RelatedRecordId FROM FeedItem WHERE Type = 'ContentPost' AND ParentId =: tenderId]) {
            if (item.RelatedRecordId != null) {
                result = false;
            }
        }
        return result;
    }

    /**
     * @description gets Delivery Point maaping between DP and TnF
     * @param  null
     * @return String
     */
   
    public static String getDeliveryPointMapping(String dpLabel){
       
       try{
            return [SELECT AITM_Tax_And_Fee_Delivery_Point__c FROM AITM_Delivery_Type_Mapping__mdt  WHERE Label=: dpLabel LIMIT 1].AITM_Tax_And_Fee_Delivery_Point__c;
         }
       catch(Exception ex) {
            return '';
         }
    }
}