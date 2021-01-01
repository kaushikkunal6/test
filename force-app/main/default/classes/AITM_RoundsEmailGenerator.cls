/***********************************************************************************************
 * @author           George
 * @date             05/Oct/2017
 * @group            AirBP
 * @description      Used for Pre-Populating the Tender Location record after Location is added.
 
 * history
 * 05/Oct/2017       George          Created
 * 07/March/2018     Ravi Pamidi     Modified - AR-2523 Removed AITM_Currency_Pricing_Basis__c fields 
 *                                   as it was converted as formula fields.
 * 13/June/2018      srnandan        Modified - AR-3169 - corrected the mapping replacing old field AITM_Credit_Days__c 
 *                                   on TenderAccount with new field AITM_Credit_Days1__c 
 * 12/August/2018    srnandan        Modified - AR-3391 - Modified overloaded constructor Generator
 * 05/Sep/2018       Saravana        Modified - AR-4161 setAddresses method to include Account Manager in CC    
 * 21/Oct/2018       srnandan        Modified - AR-XXXX AttachmentGenerator constructor added extra parameter locationType
 * 20/Feb/2019       Shweta          Updated the method prepareTenderLocationTable for the null check of the location manager
 * 09/April/2019     Ravi            Modified - AR-5122 Updated the setSubject to populate Tender Sector in Subject and body
 * 29/April/2019     Ravi            Modified - AR-5144 Updated the setAttachments to download xls as attachment
 * 12/Sep/2019		 Saravan		 Modified - 714869  Updated the class to remove duplicates from To List
 *****************************************************************************************************************************/
public with sharing class AITM_RoundsEmailGenerator {

    /**
     * @description Generator class extending TenderEmailGenerator
     */
    public class Generator extends AITM_TenderEmailGenerator {
        private final String FEEDBACK_PREFIX = 'FEEDBACK: ';
        private final String FEEDBACK_POLISH_PREFIX = 'LABP FEEDBACK: ';
        private final String EMAIL_TEMPLATE_NAME = 'AITM_TenderRoundsEmail';
        private final String FEEDBACK_XLS_URL = '/apex/AITM_FeedbackGenerateXLS?id=';
        private final String LOCATION_TYPE = '&locationType=';
        private Id tenderId;
        private String locationType;

        /**
         * @description overloaded constructor
         * @param tenderId of type Id
         * @param locationType of type string
         */
        public Generator(Id tenderId, String locationType) {
            super(tenderId, locationType);
            this.tenderId = tenderId;
            this.locationType = locationType;
        }

        /**
         * @description generate email data
         * @param null
         * @return AITM_EmailGeneratorController.EmailDTO
         */
        public override AITM_EmailGeneratorController.EmailDTO generate() {
            this.setAddresses();
            this.setSubject();
            this.setBody();
            //this.setAttachments();
            return emailDTOFactory.create();
        }

        /**
         * @description sets attachments
         * @param  null
         * @return void
         */
        private void setAttachments() {            
                String feedbackXLSFileName;
                if(locationType == AITM_TenderDao.NONPOLISH) {
                   feedbackXLSFileName = FEEDBACK_PREFIX + tenderData.tender.AITM_Tender_Sector__c + ' ' + tenderData.tender.Name + ' ' + getTenderDuration() + '.xls';    
                } else {
                    feedbackXLSFileName = FEEDBACK_POLISH_PREFIX + tenderData.tender.AITM_Tender_Sector__c + ' '  + tenderData.tender.Name + ' ' + getTenderDuration() + '.xls';    
                } 
                Blob fileBody = (!Test.isRunningTest() ?  new PageReference(FEEDBACK_XLS_URL + this.tenderId + LOCATION_TYPE + this.locationType).getContent() : Blob.valueOf('UNIT.TEST'));
                ContentVersion feedbackContent = AITM_BaseUtils.createContentVersion(fileBody, feedbackXLSFileName);
                if(!Test.isRunningTest()) {
                    AITM_BaseUtils.createChatterPostToRelate('', this.tenderId, feedbackContent.Id);
                }
                emailDTOFactory.addEmailAttachment(feedbackContent);                     
        }

        /**
         * @description gets tender duration
         * @param null
         * @return string
         */
        private String getTenderDuration() {
            String result = '';
            if (tenderData.tender.AITM_Start_Date__c != null && tenderData.tender.AITM_End_Date__c != null) {
                result = tenderData.tender.AITM_Start_Date__c.format() + ' - ' +  tenderData.tender.AITM_End_Date__c.format();
            }
            return result;
        }
        
        /**
         * @description sets addresses
         * @param null
         * @return null
         */
        private void setAddresses() {

            Set<String> locationManagerEmailSet = new Set<String>();
            Set<String> locationManagerDelegatesEmailSet = new Set<String>();
            for (String locationManagerEmail : tenderData.locationManagersEmail) {
                String locationManagerEmailIgnoreCase = locationManagerEmail.toLowerCase().trim();
                if(!locationManagerEmailSet.contains(locationManagerEmailIgnoreCase)) {
                    locationManagerEmailSet.add(locationManagerEmailIgnoreCase);
                    emailDTOFactory.addEmailAddress(true, locationManagerEmailIgnoreCase);
                
                }
            }    
            emailDTOFactory.addEmailAddress(false, tenderData.accountManagerEmail); 
            for (String delegateEmail : tenderData.locationManagerDelegatesEmail) {
                String[] splitDelegateEmail = delegateEmail.split(';');
                for(String singleDelegateEmail : splitDelegateEmail) {
                    String singleDelegateEmailIgnoreCase = singleDelegateEmail.toLowerCase().trim();
                    if(!locationManagerDelegatesEmailSet.contains(singleDelegateEmailIgnoreCase) && !locationManagerEmailSet.contains(singleDelegateEmailIgnoreCase)) {
                        locationManagerDelegatesEmailSet.add(singleDelegateEmailIgnoreCase);                        
                        emailDTOFactory.addEmailAddress(true, singleDelegateEmailIgnoreCase);
                    }
                }
            }
        }        

        /**
         * @description sets subject
         * @param null
         * @return null
         */
        private void setSubject() {
            if(locationType == AITM_TenderDao.NONPOLISH) {
                emailDTOFactory.addSubject(FEEDBACK_PREFIX + 
                                tenderData.tender.AITM_Tender_Sector__c + ' ' +
                                tenderData.tender.Name + ' ' + 
                                tenderData.tender.AITM_Start_Date__c.format() + ' - ' + 
                                tenderData.tender.AITM_End_Date__c.format() + ' Round ' +
                                tenderData.currentRound + ' ' + 'Bids in: ' + tenderData.tender.AITM_Bids_In_By__c.format());
            } else {
                emailDTOFactory.addSubject(FEEDBACK_POLISH_PREFIX + 
                                tenderData.tender.AITM_Tender_Sector__c + ' ' +
                                tenderData.tender.Name + ' ' + 
                                tenderData.tender.AITM_Start_Date__c.format() + ' - ' + 
                                tenderData.tender.AITM_End_Date__c.format() + ' Round ' +
                                tenderData.currentRound + ' ' + 'Bids in: ' + tenderData.tender.AITM_Bids_In_By__c.format());
            }
        }

        /**
         * @description sets body content
         * @param null
         * @return null
         */
        private void setBody() {
            String fullEmailTemplateMarkup = getEmailTemplateMarkup(EMAIL_TEMPLATE_NAME);
            String htmlBodyBeforeContext = prepareBodyBeforeContext(fullEmailTemplateMarkup.substringBefore('[[FEEDBACK CONTEXT]]'));
            String htmlBodyAfterContext = prepareBodyAfterContext(fullEmailTemplateMarkup.substringAfter('[[FEEDBACK CONTEXT]]'));
            String tenderLocationTableTemplate = htmlBodyAfterContext.substringBetween('[[LOCATION TABLE START]]', '[[LOCATION TABLE END]]');
            String legalText = htmlBodyAfterContext.substringAfter('[[LEGAL TEXT]]');
            htmlBodyAfterContext = htmlBodyAfterContext.substringBefore('[[LOCATION TABLE START]]');
            
            emailDTOFactory.addEmailBody(false, htmlBodyBeforeContext , '');
            emailDTOFactory.addEmailBody(true,  '' , '');
            emailDTOFactory.addEmailBody(false,  htmlBodyAfterContext , '');
            //Integer tenderLocationTableSize = 0;
            for (AITM_Tender_Location__c tenderLocation : tenderData.tenderLocations) {
                //if (tenderLocation.AITM_Tender_Location__r.size() > 0) {
                    String tenderLocationTable = prepareTenderLocationTable(tenderLocation, tenderLocationTableTemplate);
                    emailDTOFactory.addEmailBody(false,  tenderLocationTable , '');
                    //tenderLocationTableSize++;
                //}
                //if(tenderLocationTableSize >= 25){
                    //break;
                //}
            }

            emailDTOFactory.addEmailBody(false, legalText, '');
        }

        /**
         * @description prepare body content before context
         * @param rawBody of type string
         * @return string
         */
        private String prepareBodyBeforeContext(String rawBody) {
            rawBody = rawBody.replace('<messaging:emailTemplate subject="Feedback" recipientType="User" relatedToType="AITM_Tender__c"><messaging:plainTextEmailBody >', '');
            rawBody = rawBody.replace('[[TENDER TITLE]]', tenderData.tender.AITM_Tender_Sector__c + ' -' + tenderData.tender.Name + ' ' + 
                                                tenderData.tender.AITM_Start_Date__c.format() + ' - ' + 
                                                tenderData.tender.AITM_End_Date__c.format() + ' Round ' +
                                                tenderData.currentRound);
            Report reportName = new AITM_TenderDao().getTenderReport('Tender Feedback Report');                      
            if(locationType == AITM_TenderDao.POLISH) {
                 rawBody = rawBody.replace('[[TENDER LINK]]', AITM_BaseUtils.getLABPURL() + '/' + tenderData.tender.Id);     
                 rawBody = rawBody.replace('[[REPORT LINK]]', AITM_BaseUtils.getLABPURL() + System.Label.AITM_ReportURLLABP + '/' + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.POLISH.replaceAll('\\s+', ''));     
               } else {
                rawBody = rawBody.replace('[[TENDER LINK]]', AITM_BaseUtils.getTenderingURL() + '/' + tenderData.tender.Id);
                rawBody = rawBody.replace('[[REPORT LINK]]', AITM_BaseUtils.getTenderingURL() + System.Label.AITM_ReportURLTendering + '/' + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.NONPOLISH.replaceAll('\\s+', ''));     
              }
               
             return rawBody;
            }

        /**
         * @description prepare raw body content after context
         * @param rawBody of type string
         * @return string
         */
        private String prepareBodyAfterContext(String rawBody) {
            rawBody = rawBody.replace('</messaging:plainTextEmailBody></messaging:emailTemplate>', '');
            rawBody = rawBody.replace('[[CUSTOMER LIST]]', getCustomerList());
            rawBody = getNegotitationInstructions(rawBody);

            return rawBody;
        }

        /**
         * @description gets customer list
         * @param null
         * @return string
         */
        private String getCustomerList() {
            String customerList = '';
            for (AITM_Tender_Account__c tenderAccount : tenderData.tenderAccounts) {
                customerList += addLineForASingleCustomer(tenderAccount);
            }
            return customerList;
        }
        
        /**
         * @description add line for a single customer
         * @param tenderAccount of type AITM_Tender_Account__c
         * @return string
         */
        private String addLineForASingleCustomer(AITM_Tender_Account__c tenderAccount) {
            return '<tr style="padding-bottom: 5px;">' + getLineWrapperWithTD(tenderAccount.AITM_Account__r.Name) +
                          + getLineWrapperWithTD(tenderAccount.AITM_GRN__c) +
                          + getLineWrapperWithTD(tenderAccount.AITM_Customer_Segment__c) +
                          + getLineWrapperWithTD(tenderAccount.AITM_Credit_Days1__c) +
                          + getLineWrapperWithTD(tenderAccount.AITM_Invoice_Frequency__c) +
                          + getLineWrapperWithTD(tenderAccount.AITM_Security_Type__c) +
                          + getLineWrapperWithTD(tenderAccount.AITM_Tender__r.AITM_Density__c) +
                   '</tr>';
        }
        
        /**
         * @description gets negotiation instructions
         * @param rawBody of type string
         * @return string
         */
        private String getNegotitationInstructions(String rawBody) {
            rawBody = replaceFieldForRawBody(rawBody, '[[BIDS IN BY]]', tenderData.tender.AITM_Bids_In_By__c == null ? null : tenderData.tender.AITM_Bids_In_By__c.format());
            rawBody = replaceFieldForRawBody(rawBody, '[[NUMBER OF ROUNDS]]', String.valueOf(tenderData.tender.AITM_Number_Of_Rounds__c));
            rawBody = replaceFieldForRawBody(rawBody, '[[QUALITY OF FEEDBACK]]', tenderData.tender.AITM_Quality_Of_Feedback__c);
            rawBody = replaceFieldForRawBody(rawBody, '[[NOTES ON FEEDBACK]]', tenderData.tender.AITM_Notes_On_Feedback__c);
            rawBody = replaceFieldForRawBody(rawBody, '[[LAST INCUMBENT]]', tenderData.tender.AITM_Last_Look_To_Incumbent__c);
            rawBody = replaceFieldForRawBody(rawBody, '[[AIRLINE PROFILE]]', tenderData.tender.AITM_Arl_Prfl_And_Tndr_Information__c);
            return rawBody;
        }

        /**
         * @description prepare tender location table html content
         * @param tenderLocation of type Id
         * @param template of type string
         * @return string
         */
        private String prepareTenderLocationTable(AITM_Tender_Location__c tenderLocation, String template) {
            String result ='';
            result = template.replace('[[LOCATION HEADER]]', tenderLocation.AITM_IATA_ICAO__c + ' - ' + (tenderLocation.AITM_Location_Manager__r.Name == null ?'' : tenderLocation.AITM_Location_Manager__r.Name));
            result = buildBuyersCommentsBlock(tenderLocation.AITM_Comments__c, result);
            String locationsTable = '';
    
    
            for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocation.AITM_Tender_Location__r) {
                locationsTable += addLineForALocation(tenderLocation, lineItem);
            }

            return result.replace('[[LOCATIONS LIST]]', locationsTable);
        }

        /**
         * @description overloaded constructor
         * @param comments of type string
         * @param result of type string
         * @result string
         */
        private String buildBuyersCommentsBlock(String comments, String result) {
            if (comments == null) {
                result = result.replace(result.substringBetween('[[BUYERS COMMENTS BLOCK]]', '[[BUYERS COMMENTS BLOCK END]]'), '');
            } else {
                result = result.replace('[[BUYERS COMMENTS]]', comments);
            }
            result = result.replace('[[BUYERS COMMENTS BLOCK]]', '');
            result = result.replace('[[BUYERS COMMENTS BLOCK END]]', '');
            return result;
        }

        /**
         * @description add lines for each location html content
         * @param tenderLocation of type AITM_Tender_Location__c
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         * @return string
         */
        private String addLineForALocation(AITM_Tender_Location__c tenderLocation,  AITM_Tender_Location_Line_Item__c lineItem) {
            return '<tr style="padding-bottom: 5px;">' + getLineWrapperWithTD(lineItem.AITM_Account__r.Name) +
                          + getLineWrapperWithTD((lineItem.AITM_Requested_Volume_USG__c !=null ? String.valueOf(lineItem.AITM_Requested_Volume_USG__c.round(System.RoundingMode.HALF_UP)):'')) +
                          + getLineWrapperWithTD((lineItem.AITM_Offered_Volume__c !=null ? String.valueOf(lineItem.AITM_Offered_Volume__c.round(System.RoundingMode.HALF_UP)):'')) +
                          + getLineWrapperWithTD(lineItem.AITM_Pricing_Basis__r.Name) +
                          + getLineWrapperWithTD(String.valueOf(lineItem.AITM_Offered_Differential__c)) +
                          + getLineWrapperWithTD(lineItem.AITM_Currency__c) +
                          + getLineWrapperWithTD(lineItem.AITM_Unit_Of_Measure__c) +
                          + getLineWrapperWithTD(String.valueOf(tenderLocation.AITM_Position__c)) +
                          + getLineWrapperWithTD(String.valueOf(tenderLocation.AITM_Leading_Bid__c)) +
                   '</tr>';
        }
    }

    /**
     * @description AttachmentGenerator class holds email Attachments for tender
     */
    public class AttachmentGenerator extends AITM_TenderEmailGenerator.AttachmentGenerator {
        
        /**
         * @description overloaded constructor
         * @param tenderId of type Id
         * @param emailDTO of type AITM_EmailGeneratorController.EmailDTO
         */
        public AttachmentGenerator(Id tenderId, AITM_EmailGeneratorController.EmailDTO emailDTO, String locationType) {
            super(tenderId, emailDTO, locationType);
        }

        /**
         * @description gets chatter post details
         * @param emailToAttach of type AITM_EmailGeneratorController.EmailMessage
         * @return string
         */
        protected override String getChatterPost(AITM_EmailGeneratorController.EmailMessage emailToAttach) {
            return Label.AITM_GenerateFeedbackEmailChatterPost;
        }
    }
}