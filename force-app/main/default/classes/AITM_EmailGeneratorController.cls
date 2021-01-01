/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Controller class for AITM_EmailGenerator

 * history
 * 01/December/2017  George      Created 
 * 23/April/2018     srnandan    added comments at method and class level as per coding standards 
 * 29/Nov/2019       saravan     Modified-738253-Added new method sendEmailMessage                              
 ************************************************************************************************/

public with sharing class AITM_EmailGeneratorController {

	/**
     * @description to send email
     * @param  string
     * @return void
     */

    public @AuraEnabled static void sendEmail(String dto) {
        Messaging.SingleEmailMessage message = new EmailMessageFactory().create(new EmailDTOFactory().create(dto)).toSingleEmailMessage();
        AITM_BaseUtils.sendEmails(message);
    }
	
	/**
     * @description to send email with error message
     * @param  string
     * @return string
     */
    
    public @AuraEnabled static String sendEmailMessage(String dto) {        
        Messaging.SingleEmailMessage message = new EmailMessageFactory().create(new EmailDTOFactory().create(dto)).toSingleEmailMessage();
        return AITM_BaseUtils.sendEmailsMessage(message);
    }
    
    /**
     * @description to send email
     * @param  list
     * @return void
     */

    public void sendEmail(List<EmailDTO> rawEmails) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for (EmailDTO dto : rawEmails) {
            messages.add(new EmailMessageFactory().create(dto).toSingleEmailMessage());
        }
        if (messages.size() > 0) {
            AITM_BaseUtils.sendEmails(messages);
        }
    }
	
	/**
     * @description class EmailDTO
     */

    public inherited sharing class EmailDTO {
        public @AuraEnabled List<EmailAddress> emailAddresses;
        public @AuraEnabled String subject;
        public @AuraEnabled List<EmailBody> emailBodies;
        public @AuraEnabled List<EmailAttachment> emailAttachments;

        public EmailDTO() {
            emailAddresses = new List<EmailAddress>();
            emailBodies = new List<EmailBody>();
            emailAttachments = new List<EmailAttachment>();
        }
    }
	
	/**
     * @description class EmailDTOFactory
     */

    public inherited sharing class EmailDTOFactory {
        private EmailDTO instance; 
        
        public EmailDTOFactory() {
            instance = new EmailDTO();
        }

        public void addEmailAddress(Boolean isTo, String target) {
            instance.emailAddresses.add(new EmailAddress(isTo, target));
        }

        public void addSubject(String subject) {
            instance.subject = subject;
        }

        public void addEmailBody(Boolean isEditable, String htmlBody, String plainTextBody) {
            instance.emailBodies.add(new EmailBody(isEditable, htmlBody, plainTextBody));
        }

        public void addEmailAttachment(ContentVersion documentBody) {
            instance.emailAttachments.add(new EmailAttachment(documentBody));
        }

        public EmailDTO create() {
            return instance;
        }

        public EmailDTO create(String fromJSON) {
            return (AITM_EmailGeneratorController.EmailDTO) JSON.deserialize(fromJSON, AITM_EmailGeneratorController.EmailDTO.class);
        }
    }
	
	/**
     * @description class EmailMessage
     */

    public inherited sharing class EmailMessage {
        public List<String> to;
        public List<String> ccs;
        public String subject;
        public String htmlEmailBody;    
        public String plainTextEmailBody;
        public List<Messaging.EmailFileAttachment> emailAttachments;

        public EmailMessage() {
            this.to = new List<String>();
            this.subject = '';
            this.ccs = new List<String>();
            this.htmlEmailBody = '';
            this.plainTextEmailBody = '';
            this.emailAttachments = new List<Messaging.EmailFileAttachment>();
        }

        public String getHTMLBody() {
            return this.htmlEmailBody;
        }

        public Messaging.SingleEmailMessage toSingleEmailMessage() {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(to);
            message.setCcAddresses(ccs);
            message.setSubject(subject);
            message.setHtmlBody(htmlEmailBody);
            if (String.isBlank(htmlEmailBody) || htmlEmailBody == plainTextEmailBody) {
                message.setPlainTextBody(plainTextEmailBody);
            }
            message.setFileAttachments(emailAttachments);
            return message;
        }
    }
	
	 /**
     * @description class EmailMessageFactory
     */

    public inherited sharing class EmailMessageFactory {

        public EmailMessage create(EmailDTO dto) {
            EmailMessage emailMessageInstance = new EmailMessage();
            setAddresses(emailMessageInstance, dto);
            setSubject(emailMessageInstance, dto);
            setEmailBody(emailMessageInstance, dto);
            setEmailAttachments(emailMessageInstance, dto);
            return emailMessageInstance;
        }

        private void setAddresses(EmailMessage emailMessageInstance, EmailDTO dto) {
            for (EmailAddress emailAddressInstance : dto.emailAddresses) {
                if (emailAddressInstance.isTo) {
                    emailMessageInstance.to.add(emailAddressInstance.targetEmail);
                } else {
                    emailMessageInstance.ccs.add(emailAddressInstance.targetEmail);
                }
            }
        }

        private void setSubject(EmailMessage emailMessageInstance, EmailDTO dto) {
            emailMessageInstance.subject = dto.subject;
        }

        private void setEmailBody(EmailMessage emailMessageInstance, EmailDTO dto) {
            for (EmailBody emailBodyInstance : dto.emailBodies) {
                if (String.isNotBlank(emailBodyInstance.htmlBody)) {
                    emailMessageInstance.htmlEmailBody += emailBodyInstance.htmlBody;
                } else {
                    emailMessageInstance.htmlEmailBody += emailBodyInstance.plainTextBody;
                    emailMessageInstance.plainTextEmailBody += emailBodyInstance.plainTextBody;
                }
            }
        }

        private void setEmailAttachments(EmailMessage emailMessageInstance, EmailDTO dto) {
            Set<Id> contentVersionIds = new Set<Id>();
            List<EmailAttachment> notSavedEmailAttachments = new List<EmailAttachment>();
            for (EmailAttachment emailAttachmentInstance : dto.emailAttachments) {
                if(emailAttachmentInstance.documentId != null) {
                    contentVersionIds.add(emailAttachmentInstance.documentId);
                }else {
                    notSavedEmailAttachments.add(emailAttachmentInstance);
                }
            }

            Map<Id, Blob> attachmentBodies = new AITM_TenderDao().getContentVersionBodyByContentVersionIds(contentVersionIds);
            for (EmailAttachment emailAttachmentInstance : dto.emailAttachments) {
                if(emailAttachmentInstance.documentId != null) {
                    emailMessageInstance.emailAttachments.add(emailAttachmentInstance.toEmailFileAttachment(attachmentBodies.get(emailAttachmentInstance.documentId)));
                }
            }
            
            if(notSavedEmailAttachments.size() > 0) {
                for (EmailAttachment notSavedEmailAttachment : notSavedEmailAttachments) {
                    if(notSavedEmailAttachment.documentBody != null) {
                        emailMessageInstance.emailAttachments.add(notSavedEmailAttachment.toEmailFileAttachment(Blob.valueOf(notSavedEmailAttachment.documentBody)));
                    }
                }
            }
            
        }
    }
	
	/**
     * @description class EmailAddress
     */

    public inherited sharing class EmailAddress {
        public @AuraEnabled Boolean isTo;
        public @AuraEnabled String targetEmail;

        public EmailAddress(Boolean isTo, String targetEmail) {
            this.isTo = isTo;
            this.targetEmail = targetEmail;
        }
    }
	
	/**
     * @description class EmailBody
     */

    public inherited sharing class EmailBody {
        public @AuraEnabled Boolean isEditable;
        public @AuraEnabled String htmlBody;
        public @AuraEnabled String plainTextBody;

        public EmailBody(Boolean isEditable, String htmlBody, String plainTextBody) {
            this.isEditable = isEditable;
            this.htmlBody = htmlBody;
            this.plainTextBody = plainTextBody;
        }
    }
	
	/**
     * @description class EmailAttachment
     */

    public inherited sharing class EmailAttachment {
        public @AuraEnabled Id documentId;
        public @AuraEnabled String fileName;
        public @AuraEnabled Id documentLink;
        public @AuraEnabled String documentBody;
        public @AuraEnabled String documentUrl;

        public EmailAttachment(ContentVersion emailAttachmentDocument) {
            this.documentId = emailAttachmentDocument.Id;
            this.fileName = emailAttachmentDocument.PathOnClient;
            this.documentLink = emailAttachmentDocument.ContentDocumentId;
            this.documentBody = (documentId == null && emailAttachmentDocument.VersionData != null) ? emailAttachmentDocument.VersionData.toString() : null;
            this.documentUrl = (documentId == null && emailAttachmentDocument.ContentUrl != null) ? emailAttachmentDocument.ContentUrl : null;
        }

        public Messaging.EmailFileAttachment toEmailFileAttachment(Blob body) {
            Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
            emailFileAttachment.setFileName(fileName);
            emailFileAttachment.setBody(body);
            return emailFileAttachment;
        }
    }
}