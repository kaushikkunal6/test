/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Used for Tender Email Generator button to send email

 * history
 * 01/December/2017  George          Created
 * 26/March/2018     Ravi Pamidi     Modified - AR-2404 Commented De-brief Executive Summary fields to change from Text to Rich Text
 * 10/April/2018     Shweta          Modified - AR-2464 Updated the setLocationsSummary method to format the volume of the locations with comma in 
 *                                   the debrief email
 
 * 23/April/2018     srnandan        Modified - AR-2874 Updated method setAttachments to include debrief 
 *                                   in tender attachments
 * 20/May/2018       srnandan        Modified - AR-3091 Modified method setAddresses to include distribution list email addresses
 * 10/June/2018      srnandan        Modified - AR-3164 Add Density method getTableForLocations
 * 10/June/2018      srnandan        Modified - AR-3165 Add StartDate and EndDate method getRowForTenderLineItem
 * 10/June/2018      srnandan        Modified - AR-3543 Add REBATE and Change Label DIFFERENTIAL to DIFF/PRICE
 * 5th/July/2018     Shweta          Modified - AR-3591 Add method getUOM to show UOM in the airport notification email
 * 03/July/2018      Anusha          Modified - AR-1710 Add method to get Delegates from Location manager in the airport notification email
 * 05/July/2018      srnandan        Modified AR-3708 modified method getRowForTenderLineItem to include duration and quantity
 * 06/July/2018      Shweta          Modified - AR-3698 and AR-3591 Modified method getTenderCustomerTable to include the Unit of Measure as 'AITM_Requested_Volume_UoM__c'
 * 11/July/2018      Shweta          Modified - AR-3698 Modified method getTenderCustomerTable to hard code the Unit of measure as 'USG'
 * 24/July/2018      Shweta          Modified - AR-3785 Modified method getRowForTenderLineItem to show the volume as the offered volume of the last round.
 * 24/July/2018      Shweta          Modified -AR-3784 Modified the method getTableForLocations and added a new method named as 'TotalRequestedVolumeUSG' for TOTAL TENDERED VOLUME
 * 31/July/2018      Shweta          Modified  Method totalRequestedVolumeUSG and getRowForTenderLineItem to round off the total tendered volume.
 * 7/Aug/2018        Shweta          Modified  Method setKeyPerformance  to round off the value of the volume variance and the new variance in the key performance metrices
 * 08/Aug/2018       Shweta          Modified  Method getLocationsTable to show the history section in the debrief mail after te result section
 * 09/Aug/2018       Shweta          Modified  Method replaceFieldForRawBody to show offer and notes in the list same as Taxes and Fees in offer document.
 * 12/August/2018    srnandan        Modified - AR-3316 methods Generator, AirportEmailGenerator adding locationType as param
 * 23/August/2018    srnandan        Modified  LocationsWrapper method to add getProductDescription from AITM_BaseUtils class   
 * 05/Sep/2018       Saravana        Modified - AR-4161 setAddresses method to include Account Manager in CC     
 * 21/Oct/2018       srnandan        Modified - AR- XXXX AttachmentGenerator constructor extra parameter locationType
 * 10/Dec/2018       Anusha          Modified - AR- 4637 modified the location table to get current value for Pricing Basis 'C' type
 * 11/Dec/2018       srnandan        Modified - AR-4624 added deliverypoint details in history and line item sections
 * 19/January/2019   srnandan        Modified - AR-4457 modified method getRowForTenderLineItem to have comma for volume, rebate
 * 29/January/2019   srnandan        Modified - AR-4952 modified setAddresses changed to use set collection to remove duplicate emails
 * 30/January/2019   srnandan        Modified - AR-4939 taxes and fees to be shown from TLLI
 * 04/February/2019  srnandan        Modified - AR-XXXX added condition to generate attachments only for BG/BR results
 * 14/february/2019  Shweta          Modified - AR-4841 Updated the code to add awarded volume only for BR and BG results
 * 20/February/2019  Shweta          Modified - AR-5010 Updated the getAirportEmails to return non null values
 * 27/March/2019     Ravi            Modified - AR-5110 Updated the getRowForTenderLineItem to populate Delivery Method and Measure from TLLI
 * 09/April/2019     Ravi            Modified - AR-5122 Updated the setSubject to populate Tender Sector in Subject and body
 * 19/April/2019     srnandan        Modified - AR-5121 attaching excel debrief content
 * 30/May/2019        Ravi           Modified - AR-5179 Updated the body and content of email as per story attachment
 * 10/June/2019       Ravi           Modified - AR-5216 code refined for Large Tenders
 * 16/July/2019       Ravi           Modified - AR-5257 added linkForPricingReport for Pricing report generation
 * 27/Aug/2019        Ravi           Modified - Without sharing is used to pull Reports, Dashboards and chatter posts from org
 * 06/September/2019  srnandan       Modified - Workitem (701057) to include bp user email link for labp debrief email
 * 12/Sep/2019		 Saravan		 Modified - 714869  Updated the class to remove duplicates from To List
 **********************************************************************************************************************************************************************************/
public without sharing class AITM_DeBriefEmailGenerator  {
    public without sharing class Generator extends AITM_TenderEmailGenerator {
        private final String DEBRIEF_PREFIX = 'DEBRIEF ';
        private final String DEBRIEF_POLISH_PREFIX = 'LABP DEBRIEF ';
        private final String EMAIL_TEMPLATE_NAME = 'AITM_TenderDeBriefEmail';
        private final String PRICING_INFORMATION_URL = '/apex/AITM_PricingInformation?id=';
        private final String DEBRIEF_XLS_INFORMATION_URL = '/apex/AITM_DebriefGenerateXLS?id=';
        private final String LOCATION_TYPE = '&locationType=';
        private Id tenderId;
        private String locationType;

        /**
        * @description overloaded constructor
        * @param  tenderId of type Id
        */
        public Generator(Id tenderId) {
            super(tenderId);
            this.tenderId = tenderId;
        }

       /**
        * @description overloaded constructor
        * @param  tenderId of type Id
        * @param  locationType of type String
        */
        public Generator(Id tenderId, String locationType) {
            super(tenderId, locationType);
            this.tenderId = tenderId;
            this.locationType = locationType;
        }

        /**
         * @description generates EmailDTO
         * @param  null
         * @return AITM_EmailGeneratorController.EmailDTO
         */
        public override AITM_EmailGeneratorController.EmailDTO generate() {
            this.setAddresses();
            this.setSubject();
            this.setBody();
            this.setAttachments();
            return emailDTOFactory.create();
        }

        /**
         * @description sets attachments
         * @param  null
         * @return void
         */
        private void setAttachments() {
            String debriefFileName = getFileName();
            Blob fileBody;
            ContentVersion debriefContent;
            try{
             if(new AITM_LocationsDao().getBGBRLocationsCount(tenderId, locationType) > 0) {
                if(locationType == AITM_TenderDao.NONPOLISH) {
                    debriefFileName =  DEBRIEF_PREFIX+debriefFileName;
                }
                else {
                    debriefFileName =  DEBRIEF_POLISH_PREFIX+debriefFileName;
                }
                fileBody = (!Test.isRunningTest() ?  new PageReference(PRICING_INFORMATION_URL + this.tenderId + LOCATION_TYPE + this.locationType).getContent() : Blob.valueOf('UNIT.TEST'));
                debriefContent = AITM_BaseUtils.createContentVersion(fileBody, debriefFileName);
                if(!Test.isRunningTest()) {
                    AITM_BaseUtils.createChatterPostToRelate('', this.tenderId, debriefContent.Id);
                }
             }  
            } 
            catch(Exception e){
                  //System.debug('An exception occurred: ' + e.getMessage());
                  throw new AuraHandledException('Something went wrong: '+ e.getMessage());				  
            } 
                   
        }

        /**
         * @description gets filename
         * @param  null
         * @return string
         */
        private String getFileName() {
            AITM_Tender__c tender = this.tenderData.tender;
            return 'Pricing Information: ' + tender.Name + ' ' + tender.AITM_Start_Date__c.format() + ' - ' + tender.AITM_End_Date__c.format() + '.xls';
        }

        /**
         * @description sets addresses
         * @param  null
         * @return void
         */
        private void setAddresses() {
            Set<String> locationManagerEmailSet = new Set<String>();
            Set<String> locationManagerDelegatesEmailSet = new Set<String>();
            if(tenderData != null) {
              for (String locationManagerEmail : tenderData.locationManagersEmail) {
                String locationManagerEmailIgnoreCase = (locationManagerEmail != null ?locationManagerEmail.toLowerCase().trim():'');
                if(!locationManagerEmailSet.contains(locationManagerEmailIgnoreCase)) {
                    locationManagerEmailSet.add(locationManagerEmailIgnoreCase);
                    emailDTOFactory.addEmailAddress(true, locationManagerEmailIgnoreCase);
                }
              }
                 emailDTOFactory.addEmailAddress(false, tenderData.accountManagerEmail);    
              for (String distributionEmail : tenderData.getLocationsDistributionList()) {
                if (String.isNotEmpty(distributionEmail)) {
                    emailDTOFactory.addEmailAddress(false, distributionEmail);
                }
              }

              for (String delegateEmail : tenderData.locationManagerDelegatesEmail) {
                String[] splitDelegateEmail = delegateEmail.split(';');
                for(String singleDelegateEmail : splitDelegateEmail) {
                    String singleDelegateEmailIgnoreCase = (singleDelegateEmail != null ? singleDelegateEmail.toLowerCase().trim():'');
                    if(!locationManagerDelegatesEmailSet.contains(singleDelegateEmailIgnoreCase) && !locationManagerEmailSet.contains(singleDelegateEmailIgnoreCase)) {
                        locationManagerDelegatesEmailSet.add(singleDelegateEmailIgnoreCase);
                        emailDTOFactory.addEmailAddress(true, singleDelegateEmailIgnoreCase);
                    }    
                }
              }
            }
        }

        /**
         * @description sets subject
         * @param  null
         * @return null
         */
        private void setSubject() {
            if(locationType == AITM_TenderDao.NONPOLISH) {
                emailDTOFactory.addSubject(DEBRIEF_PREFIX + tenderData.tender.AITM_Tender_Sector__c + ' - ' + tenderData.tender.Name + ' ' + getTenderDuration());
            } else {
                emailDTOFactory.addSubject(DEBRIEF_POLISH_PREFIX + tenderData.tender.AITM_Tender_Sector__c + ' - '  + tenderData.tender.Name + ' ' + getTenderDuration());
            }
        }

        /**
         * @description sets body
         * @param  null
         * @return void
         */
        private void setBody() {
            String fullEmailTemplateMarkup = getEmailTemplateMarkup(EMAIL_TEMPLATE_NAME);

            String headerDetails = fullEmailTemplateMarkup.substringBefore('[[LOCATIONS SUMMARY START]]');
            headerDetails = setEmailHeaderDetails(headerDetails);
            emailDTOFactory.addEmailBody(false, headerDetails, '');

            String contextResultsSummary = fullEmailTemplateMarkup.substringBetween('[[TENDER CONTEXT RESULTS SUMMARY START]]', '[[TENDER CONTEXT RESULTS SUMMARY END]]');
            contextResultsSummary = setContextResultsSummary(contextResultsSummary);
            emailDTOFactory.addEmailBody(false, contextResultsSummary, '');
            
            String linkForTender = fullEmailTemplateMarkup.substringBetween('[[TENDER LINK START]]', '[[TENDER LINK END]]');
            linkForTender =  setLinkForTender(linkForTender);
            emailDTOFactory.addEmailBody(false, linkForTender, '');
            
            String linkForDashboard = fullEmailTemplateMarkup.substringBetween('[[DASHBOARD LINK START]]', '[[DASHBOARD LINK END]]');
            linkForDashboard =  setLinkForDashboard(linkForDashboard);
            emailDTOFactory.addEmailBody(false, linkForDashboard, '');
            
            String linkForReport = fullEmailTemplateMarkup.substringBetween('[[REPORT LINK START]]', '[[REPORT LINK END]]');
            linkForReport =  setLinkForReportByName(linkForReport, 'Debrief excel content');
            emailDTOFactory.addEmailBody(false, linkForReport, '');
			
            String linkForNotesReport = fullEmailTemplateMarkup.substringBetween('[[REPORT LINK START WITH NOTES]]', '[[REPORT LINK END WITH NOTES]]');
            linkForReport =  setLinkForReportByName(linkForNotesReport, 'Debrief excel content T&F Add\'l Notes');
            emailDTOFactory.addEmailBody(false, linkForReport, '');
            
            String linkForTFReport = fullEmailTemplateMarkup.substringBetween('[[REPORT LINK START FOR TF]]', '[[REPORT LINK END FOR TF]]');
            linkForReport =  setLinkForReportByName(linkForTFReport, 'Debrief excel content(T&F) exc Add-Notes');
            emailDTOFactory.addEmailBody(false, linkForReport, '');
            
            String linkForPricingReport = fullEmailTemplateMarkup.substringBetween('[[PRICING REPORT LINK START]]', '[[PRICING REPORT LINK END]]');
            linkForPricingReport =  setLinkForPricingReport(linkForPricingReport);
            emailDTOFactory.addEmailBody(false, linkForPricingReport, '');

            String boxData = fullEmailTemplateMarkup.substringBetween('[[BOX DATA START]]', '[[BOX DATA END]]');
            boxData = setBoxData(boxData);
            emailDTOFactory.addEmailBody(false, boxData, '');
            
            String locationsSummary = fullEmailTemplateMarkup.substringBetween('[[LOCATIONS SUMMARY START]]', '[[LOCATIONS SUMMARY END]]');
            locationsSummary = setLocationsSummary(locationsSummary);
            emailDTOFactory.addEmailBody(false, locationsSummary, ''); 
            
            String keyPerformance = fullEmailTemplateMarkup.substringBetween('[[KEY PERFORMANCE METRICS START]]', '[[KEY PERFORMANCE METRICS END]]');
            keyPerformance = setKeyPerformance(keyPerformance);
            emailDTOFactory.addEmailBody(false, keyPerformance, ''); 

            String customerSummary = fullEmailTemplateMarkup.substringBetween('[[CUSTOMER SUMMARY START]]', '[[CUSTOMER SUMMARY END]]');
            customerSummary = setCustomerSummary(customerSummary);
            emailDTOFactory.addEmailBody(false, customerSummary, '');
            
            String summaryAndLearnings = fullEmailTemplateMarkup.substringBetween('[[DETAILED LEARNINGS START]]', '[[DETAILED LEARNINGS END]]');
            summaryAndLearnings = setSummaryAndLearnings(summaryAndLearnings);
            emailDTOFactory.addEmailBody(false, summaryAndLearnings, '');

            String preTenderInformation = fullEmailTemplateMarkup.substringBetween('[[PRE-TENDER INFORMATION START]]', '[[PRE-TENDER INFORMATION END]]');
            preTenderInformation = setPreTenderInformation(preTenderInformation);
            emailDTOFactory.addEmailBody(false, preTenderInformation, '');

            String notesForTender = fullEmailTemplateMarkup.substringBetween('[[NOTES FOR TENDER CONTRACT SET-UP TERMS START]]', '[[NOTES FOR TENDER CONTRACT SET-UP TERMS END]]');
            notesForTender = setNotesForTender(notesForTender);
            emailDTOFactory.addEmailBody(false, notesForTender, '');

            String recognitionAndShoutOuts = fullEmailTemplateMarkup.substringBetween('[[RECOGNITION AND SHOUT OUTS START]]', '[[RECOGNITION AND SHOUT OUTS END]]');
            recognitionAndShoutOuts = setRecognitionAndShoutOuts(recognitionAndShoutOuts);
            emailDTOFactory.addEmailBody(false, recognitionAndShoutOuts, '');

            String locationList = fullEmailTemplateMarkup.substringBetween('[[LOCATION LIST HEADER START]]', '[[LOCATION TABLE END]]');
            locationList = setLocationList(locationList);
            emailDTOFactory.addEmailBody(false, locationList, '');

            String footer = fullEmailTemplateMarkup.substringAfter('[[FOOTER]]');
            footer = setFooter(footer);
            emailDTOFactory.addEmailBody(false, footer, '');
        }

        /**
         * @description sets email header details
         * @param  null
         * @return void
         */
        private String setEmailHeaderDetails(String target) {
            target = target.replace('<messaging:emailTemplate subject="DeBrief" recipientType="User" relatedToType="AITM_Tender__c"><messaging:plainTextEmailBody >', '');
            target = target.replace('</messaging:plainTextEmailBody></messaging:emailTemplate>', '');
            target = target.replace('[[TENDER TITLE]]', tenderData.tender.AITM_Tender_Sector__c + ' -' + tenderData.tender.Name + ' ' + getTenderDuration());
            return target;
        }
         
        /**
         * @description sets context results summary
         * @param target of type String
         * @return string of Target
         */
        private String setContextResultsSummary(String target) {
            target = replaceFieldForRawBody(target, '[[TENDER CONTEXT RESULTS SUMMARY]]', tenderData.tender.AITM_Tender_Context__c == null ? 'N/A' : tenderData.tender.AITM_Tender_Context__c);
            return target;
        }
        
        /**
        * @description sets link for the tender
        * @param target of type String
        * @return string of Target
        */
        public String setLinkForTender(String target){
            //String tenderurl = URL.getSalesforceBaseUrl().toExternalForm();
            if(locationType == AITM_TenderDao.POLISH) {
               target = target.replace('[[TENDER LINK]]', AITM_BaseUtils.getLABPURL() + '/' + tenderData.tender.Id);
            } else{
               target = target.replace('[[TENDER LINK]]', AITM_BaseUtils.getTenderingURL() + '/' + tenderData.tender.Id);  
            }
            return target;
            
        }
        
        /**
        * @description sets link for the tender
        * @param target of type String
        * @return string of Target
        */
        public String setLinkForDashboard(String target){
            String dashboardurl = URL.getSalesforceBaseUrl().toExternalForm();
            Dashboard dashboardName = new AITM_TenderDao().getDebriefDashboard();
            if(dashboardName != null){
                target = target.replace('[[DASHBOARD LINK]]', dashboardurl + '/' + dashboardName.Id);
            }else{
                target = '';
            }
            return target;
        }
        
        /**
        * @description sets link for the Repory
        * @param target of type String, String
        * @return string of Target
        */
        public String setLinkForReportByName(String target, String nameOfReport){
            String reporturl = AITM_BaseUtils.getTenderingURL();
            Report reportName = new AITM_TenderDao().getReportByName(nameOfReport);
            if(reportName != null && reportName.Name == 'Debrief excel content' && tenderData.tender.AITM_Select_to_Apply_Old_Taxes_and_Fees__c){
                if(locationType == AITM_TenderDao.NONPOLISH) {
                    target = target.replace('[[REPORT LINK]]', reporturl + '/lightning/r/report' + '/'  + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.NONPOLISH.replaceAll('\\s+', ''));
                }else{
                    //target = target.replace('[[REPORT LINK]]', reporturl + '/s/report' + '/' + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.POLISH);
                    target = target.replace('[[REPORT LINK]]', AITM_BaseUtils.getLABPURL() + System.Label.AITM_ReportURLLABP + '/' + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.POLISH.replaceAll('\\s+', ''));
                }
            }else if(reportName != null && (reportName.Name == 'Debrief excel content(T&F) exc Add-Notes' || reportName.Name == 'Debrief excel content T&F Add\'l Notes') && !tenderData.tender.AITM_Select_to_Apply_Old_Taxes_and_Fees__c) {
                if(locationType == AITM_TenderDao.NONPOLISH) {
                    target = target.replace('[[REPORT LINK]]', reporturl + '/lightning/r/report' + '/'  + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.NONPOLISH.replaceAll('\\s+', ''));
                }else{
                    //target = target.replace('[[REPORT LINK]]', reporturl + '/s/report' + '/' + reportName.Id + '/view?fv0=' + tenderData.tender.Id + '&fv1=' + AITM_TenderDao.POLISH);
                    target = target.replace('[[REPORT LINK]]', AITM_BaseUtils.getLABPURL() + System.Label.AITM_ReportURLLABP + '/' + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.POLISH.replaceAll('\\s+', ''));
                }
            }
            else{
                target = '';
            }
            return target;
        }
        
        /**
        * @description sets link for the tender
        * @param target of type String
        * @return string of Target
        */
        public String setLinkForPricingReport(String target){
            String reporturl = AITM_BaseUtils.getTenderingURL();
            Report reportName = new AITM_TenderDao().getTenderReport('Pricing Information');
            if(reportName != null){
                Integer locationsCount = new AITM_LocationsDao().getBGBRLocationsCount(tenderId, locationType);
                if(locationType == AITM_TenderDao.NONPOLISH){
                    target = target.replace('[[PRICING REPORT BP TEXT]]', 'font-size:14px;display:block');
                    target = target.replace('[[PRICING BP USERS]]', '');
                    target = target.replace('[[PRICING REPORT BP LINK TEXT]]', 'font-size:14px;font-color:blue;display:block');
                    target = target.replace('[[PRICING REPORT TEXT]]', 'display:none');
                    target = target.replace('[[PRICING REPORT LINK TEXT]]', 'display:none');
                    target = target.replace('[[PRICING REPORT TEXT]]', 'display:none');
                    target = target.replace('[[PRICING REPORT LINK]]', reporturl + System.Label.AITM_ReportURLTendering + '/'  + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.NONPOLISH.replaceAll('\\s+', ''));
                }else {
                    target = target.replace('[[PRICING REPORT TEXT]]', 'font-size:14px;display:block');
                    target = target.replace('[[PRICING BP USERS]]', '(BP users)');
                    target = target.replace('[[PRICING REPORT LINK TEXT]]', 'font-size:14px;font-color:blue;display:block');
                    target = target.replace('[[PRICING REPORT LABP LINK]]', AITM_BaseUtils.getLABPURL() + System.Label.AITM_ReportURLLABP + '/' + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.POLISH);
                    target = target.replace('[[PRICING REPORT BP TEXT]]', 'font-size:14px;display:block');
                    target = target.replace('[[PRICING REPORT BP LINK TEXT]]', 'font-size:14px;font-color:blue;display:block');
                    target = target.replace('[[PRICING REPORT LINK]]', reporturl + System.Label.AITM_ReportURLTendering + '/'  + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.POLISH);
                } 
                return target;
            } else {
                target = '';
            }
            return target;
        }
        
        /**
        * @description sets link for the tender
        * @param target of type String
        * @return string of Target
        */
        public String setLinkForReport(String target){
            String reporturl = AITM_BaseUtils.getTenderingURL();
            Report reportName = new AITM_TenderDao().getReport();
            if(reportName != null){
                if(locationType == AITM_TenderDao.NONPOLISH) {
                    target = target.replace('[[REPORT LINK]]', reporturl + System.Label.AITM_ReportURLTendering + '/'  + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.NONPOLISH.replaceAll('\\s+', ''));
                    }else{
                        target = target.replace('[[REPORT LINK]]', AITM_BaseUtils.getLABPURL() + System.Label.AITM_ReportURLLABP + '/' + reportName.Id + '/view?fv1=' + tenderData.tender.Id + '&fv2=' + AITM_TenderDao.POLISH.replaceAll('\\s+', ''));
                    }
            }else{
                target = '';
            }
            return target;
        }

       /**
        * @description sets customer summary for the tender
        * @param target of type String
        * @return string of Target
        */
        public String setCustomerSummary(String target) { 
            String customerItemTemplate = target.substringBetween('[[CUSTOMER LINE START]]', '[[CUSTOMER LINE END]]');
            String rows = '';
            List <AITM_Tender_Account__c> acclist = new AITM_TenderDao().getTenderAccount(tenderData.tender.Id);            
            for (AITM_Tender_Account__c a:acclist ) {
                rows += getRowForCustomer(customerItemTemplate,a);
            }
            target = target.substringBefore('[[CUSTOMER LINE START]]') + rows + target.substringAfter('[[CUSTOMER LINE END]]');
            return target;
        }

       /**
        * @description gets rows for the tender customer related to tender
        * @param target of type String and type tender account object
        * @return string of Target        
        */
        public String getRowForCustomer(String target,AITM_Tender_Account__c a) {
            target = replaceFieldForRawBody(target, '[[CUSTOMER NAME]]', a.AITM_Customer_Name__c);
            target = replaceFieldForRawBody(target, '[[GRN]]', a.AITM_GRN__c);
            target = replaceFieldForRawBody(target, '[[INVOICE FREQUENCY]]', a.AITM_Invoice_Frequency__c);
            target = replaceFieldForRawBody(target, '[[CREDIT DAYS]]', a.AITM_Credit_Days1__c);
            target = replaceFieldForRawBody(target, '[[SECURITY TYPE]]', a.AITM_Security_Type__c);
            target = replaceFieldForRawBody(target, '[[CUSTOMER SEGMENT]]', a.AITM_Customer_Segment__c);
            target = replaceFieldForRawBody(target, '[[CUSTOMER TYPE]]', a.AITM_Customer_Type__c);
            target = replaceFieldForRawBody(target, '[[AIRCRAFT]]', a.AITM_Aircraft_Fleet__c);
            //target = replaceFieldForRawBody(target, '[[DENSITY]]', a.AITM_Tender__r.AITM_Density__c);     
            return target;
        }

       /**
        * @description gets box data
        * @param target of type String
        * @return string of Target
        */
        public String setBoxData(String target) {
           //target = replaceFieldForRawBody(target, '[[TOTAL TENDERD VOLUME]]',totalTenderedVolumeUSG(tenderData.tenderLocationsWithDeBrief));
           //target = replaceFieldForRawBody(target,'[[TOTAL AWARDED VOLUME]]',totalAwardedVolumeUSG(tenderData.tenderLocationsWithDeBrief));
           //target = replaceFieldForRawBody(target,'[[NUMBER OF CUSTOMERS]]', getTenderAccountsSizeForTender(tenderData.tender.Id));
           //target = replaceFieldForRawBody(target,'[[NUMBER OF REPRESENTED LOCATIONS]]',getRepresentedCountOfLocations(tenderData.tender.Id));
           //target = replaceFieldForRawBody(target,'[[NUMBER OF GAINED]]',getCountOfGainedLocations(tenderData.tenderLocationsWithDeBrief));
           //target = replaceFieldForRawBody(target,'[[NUMBER OF RETAINED]]',getCountOfRetainedLocations(tenderData.tenderLocationsWithDeBrief));
           //target = replaceFieldForRawBody(target,'[[NUMBER OF LOST]]',getCountOfLostLocations(tenderData.tenderLocationsWithDeBrief));
           //target = replaceFieldForRawBody(target,'[[NUMBER OF MIX]]',getCountOfMixLocations(tenderData.tenderLocationsWithDeBrief));
           return target; 
        }

       /**
        * @description gets total count of locations which are represented
        * @param target of type tenderId
        * @return string of size of the represented locations linked to the tender with Id as tenderId
        */         
        public String getRepresentedCountOfLocations(Id tenderId) {        
           Integer representedLocations = new AITM_LocationsDao().getRepresentedCurrentRoundCountTenderLocations(tenderId,locationType);
           return String.valueof(representedLocations);        
        } 
        
        /**
         * @description sets locations summary
         * @param target of type String
         * @return string
         */
        private String setLocationsSummary(String target) {
            LocationSummaryBuilder summaryBuilder = new LocationSummaryBuilder(tenderData.tender.Id);
            target = target.replace('[[GAINED VOLUME]]', ((summaryBuilder.locationsSummary.get('gainedVolume') == null ? '0' : summaryBuilder.locationsSummary.get('gainedVolume'))));
            target = target.replace('[[GAINED LOCATIONS]]', (summaryBuilder.locationsSummary.get('gainedLocations') == null ? '' : summaryBuilder.locationsSummary.get('gainedLocations')));
            target = target.replace('[[RETAINED VOLUME]]', ((summaryBuilder.locationsSummary.get('retainedVolume') == null ? '0' : summaryBuilder.locationsSummary.get('retainedVolume'))));
            target = target.replace('[[RETAINED LOCATIONS]]', (summaryBuilder.locationsSummary.get('retainedLocations') == null ? '' : summaryBuilder.locationsSummary.get('retainedLocations')));
            target = target.replace('[[LOST VOLUME]]', ((summaryBuilder.locationsSummary.get('lostVolume') == null ? '0' : summaryBuilder.locationsSummary.get('lostVolume'))));
            target = target.replace('[[LOST LOCATIONS]]', (summaryBuilder.locationsSummary.get('lostLocations') == null ? '' : summaryBuilder.locationsSummary.get('lostLocations')));
            target = target.replace('[[MARKET VOLUME]]', ((summaryBuilder.locationsSummary.get('marketInformationVolume') == null ? '0' : summaryBuilder.locationsSummary.get('marketInformationVolume'))));
            target = target.replace('[[MARKET LOCATIONS]]', (summaryBuilder.locationsSummary.get('marketInformationLocations') == null ? '' : summaryBuilder.locationsSummary.get('marketInformationLocations')));
            return target;
        }

        /**
         * @description sets key performance
         * @param target of type String
         * @return string
         */
        private String setKeyPerformance(String target) {
            target = replaceFieldForRawBody(target, '[[GROSS PROFIT PREVIOUS CONTRACT]]', formatNumber(tenderData.tender.AITM_Gross_Profit_Previous_Contract__c));
            target = replaceFieldForRawBody(target, '[[GROSS PROFIT NEW CONTRACT]]', formatNumber(tenderData.tender.AITM_Gross_Profit_New_Contract__c));
            target = replaceFieldForRawBody(target, '[[GROSS PROFIT VARIANCE]]', formatNumber(getDifference(tenderData.tender.AITM_Gross_Profit_New_Contract__c, tenderData.tender.AITM_Gross_Profit_Previous_Contract__c)));
            target = replaceFieldForRawBody(target, '[[GROSS PROFIT NOTES]]', tenderData.tender.AITM_Gross_Profit_Notes__c);
            target = replaceFieldForRawBody(target, '[[VOLUME PREVIOUS CONTRACT]]', formatNumber(tenderData.tender.AITM_Volume_Previous_Contract__c));
            target = replaceFieldForRawBody(target, '[[VOLUME NEW CONTRACT]]',formatNumber((tenderData.tender.AITM_Volume_New_Contract__c!=null?tenderData.tender.AITM_Volume_New_Contract__c.round(system.roundingMode.HALF_UP):null)));
            target = replaceFieldForRawBody(target, '[[VOLUME VARIANCE]]', formatNumber((getDifference(tenderData.tender.AITM_Volume_New_Contract__c, tenderData.tender.AITM_Volume_Previous_Contract__c)).round(system.roundingMode.HALF_UP)));
            target = replaceFieldForRawBody(target, '[[VOLUME NOTES]]', tenderData.tender.AITM_Volume_Notes__c);
            target = replaceFieldForRawBody(target, '[[WORKING CAPITAL PREVIOUS CONTRACT]]', formatNumber(tenderData.tender.AITM_Working_Capital_Previous_Contract__c));
            target = replaceFieldForRawBody(target, '[[WORKING CAPITAL NEW CONTRACT]]', formatNumber(tenderData.tender.AITM_Working_Capital_New_Contract__c));
            target = replaceFieldForRawBody(target, '[[WORKING CAPITAL VARIANCE]]', formatNumber(getDifference(tenderData.tender.AITM_Working_Capital_New_Contract__c, tenderData.tender.AITM_Working_Capital_Previous_Contract__c)));
            target = replaceFieldForRawBody(target, '[[WORKING CAPITAL NOTES]]', tenderData.tender.AITM_Working_Capital_Notes__c);
            target = replaceFieldForRawBody(target, '[[PRICE PERFORMANCE PREVIOUS CONTRACT]]', formatNumber(tenderData.tender.AITM_Price_Perf_Index_Prev_Contract__c));
            target = replaceFieldForRawBody(target, '[[PRICE PERFORMANCE NEW CONTRACT]]', formatNumber(tenderData.tender.AITM_Price_Perf_Index_New_Contract__c));
            target = replaceFieldForRawBody(target, '[[PRICE PERFORMANCE VARIANCE]]', formatNumber(getDifference(tenderData.tender.AITM_Price_Perf_Index_New_Contract__c, tenderData.tender.AITM_Price_Perf_Index_Prev_Contract__c)));
            target = replaceFieldForRawBody(target, '[[PRICE PERFORMANCE NOTES]]', tenderData.tender.AITM_Price_Performance_Index_Notes__c);
            target = replaceFieldForRawBody(target, '[[ROWC PREVIOUS CONTRACT]]', formatNumber(tenderData.tender.AITM_ROWC_Previous_Contract__c));
            target = replaceFieldForRawBody(target, '[[ROWC NEW CONTRACT]]', formatNumber(tenderData.tender.AITM_ROWC_New_Contract__c));
            target = replaceFieldForRawBody(target, '[[ROWC VARIANCE]]', formatNumber(getDifference(tenderData.tender.AITM_ROWC_New_Contract__c, tenderData.tender.AITM_ROWC_Previous_Contract__c)));
            target = replaceFieldForRawBody(target, '[[ROWC NOTES]]', tenderData.tender.AITM_ROWC_Notes__c);     
            return target;
        }
    
        /**
         * @description returns target string of Summary and Learnings
         * @param target of type String
         * @return string
         */
        private String setSummaryAndLearnings(String target) {
            target = replaceFieldForRawBody(target, '[[TENDER PROCESS]]', tenderData.tender.AITM_Tender_Process__c);
            target = replaceFieldForRawBody(target, '[[TENDER PREPARATION]]', tenderData.tender.AITM_Tender_Preparation__c);
            target = replaceFieldForRawBody(target, '[[WHAT WENT WELL]]', tenderData.tender.AITM_What_Went_Well__c);
            target = replaceFieldForRawBody(target, '[[WHAT COULD HAVE GONE BETTER]]', tenderData.tender.AITM_What_Could_Have_Gone_Better__c);
            target = replaceFieldForRawBody(target, '[[WHAT WE LEARNT]]', tenderData.tender.AITM_What_Have_We_Learnt__c);
            return target;
        }

        /**
         * @description sets pre tender information
         * @param target of type String
         * @return string
         */
        private String setPreTenderInformation(String target) {
            target = replaceFieldForRawBody(target, '[[PRO-ACTIVE PACKAGE VALUE]]', prepareCheckboxValue(tenderData.tender.AITM_Is_Customer_Talk_Infl_Req_Conducted__c));
            target = replaceFieldForRawBody(target, '[[PRO-ACTIVE PACKAGE COMMENT]]', tenderData.tender.AITM_Pro_Active_Package_Offered_Comment__c);
            target = replaceFieldForRawBody(target, '[[MULTI-YEAR PACKAGE VALUE]]', prepareCheckboxValue(tenderData.tender.AITM_Is_Multi_Year_Int_Scheme_Offered__c));
            target = replaceFieldForRawBody(target, '[[MULTI-YEAR PACKAGE COMMENT]]', tenderData.tender.AITM_Multi_Year_Int_Offered_Comment__c);
            target = replaceFieldForRawBody(target, '[[CUSTOMER TALK VALUE]]', prepareCheckboxValue(tenderData.tender.AITM_Is_Customer_Talk_Infl_Req_Conducted__c));
            target = replaceFieldForRawBody(target, '[[CUSTOMER TALK COMMENT]]', tenderData.tender.AITM_Cust_Talk_Influence_Req_Conducted__c);
            return target;
        }

            
        /**
         * @description sets notes for tender
         * @param target of type String
         * @return string
         */
        private String setNotesForTender(String target) {
            target = replaceFieldForRawBody(target, '[[NOTES FOR TENDER CONTRACT SET-UP]]', tenderData.tender.AITM_Notes_For_Tender__c);
            return target;
        }

        /**
         * @description sets recognition and shout outs
         * @param target of type String
         * @return string
         */
        private String setRecognitionAndShoutOuts(String target) {
            target = replaceFieldForRawBody(target, '[[RECOGNITION AND SHOUT OUTS]]', tenderData.tender.AITM_Recognition_And_Shout_Outs__c);
            return target;
        }

        /**
         * @description sets recognition and shout outs
         * @param target of type String
         * @return string
         */
        private String setAirlineProfile(String target) {
            target = replaceFieldForRawBody(target, '[[AIRLINE PROFILE]]', tenderData.tender.AITM_Arl_Prfl_And_Tndr_Information__c);
            return target;
        }

        /**
         * @description sets location list
         * @param target of type String
         * @return string
         */
        private String setLocationList(String target) {
            String locationListHeader = target.substringBefore('[[LOCATION LIST HEADER END]]');
            locationListHeader = getTotalNumberOfLocations(locationListHeader);
            locationListHeader = setAirlineProfile( locationListHeader);
            emailDTOFactory.addEmailBody(false, locationListHeader, '');

            String locationTableTemplate = target.substringAfter('[[LOCATION TABLE START]]');
            LocationTableBuilder locationsTableBuilder = new LocationTableBuilder(locationTableTemplate, tenderData.tender,this.locationType);
            return locationsTableBuilder.getLocationTable();
        }
        
       /**
        * @description getsTotalNumberOfLocations linked to the tender
        * @param target of type String
        * @return string
        */
        public String getTotalNumberOfLocations(String target){
            target = replaceFieldForRawBody(target, '[[LOCATION COUNT]]', getRepresentedCountOfLocations(tenderData.tender.Id));
            return target;
        }
        
        /**
         * @description sets footer
         * @param target of type String
         * @return string
         */
        private String setFooter(String target) {
            target = replaceFieldForRawBody(target,'[[USER NAME]]', UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
            target = replaceFieldForRawBody(target,'[[USER ORG]]', UserInfo.getOrganizationName());
            target = replaceFieldForRawBody(target,'[[USER EMAIL]]', UserInfo.getUserName());
            target = target.replace('</messaging:plainTextEmailBody></messaging:emailTemplate>', '');
            return target;
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
         * @description returns Yes if value is true
         * @param value of type Boolean
         * @return string
         */
        private String prepareCheckboxValue(Boolean value) {
            return value ? 'Yes' : 'No';
        }

        /**
         * @description converts decimal value to string
         * @param value of type decimal
         * @return string 
         */
        private String formatNumber(Decimal value) {
            return (value != null)? value.format() : null;
        }

        /**
         * @description gets difference
         * @param value1 of type decimal
         * @param value2 of type decimal
         * @return decimal
         */
        private Decimal getDifference(Decimal value1, Decimal value2) {
            Decimal diff;

            if(value1 == null && value2 == null) {
                diff = 0;
            }else if(value1 == null) {
                diff = value2;
            }else if(value2 == null) {
                diff = value1;
            }else {
                diff = value1 - value2;
            }

            return diff;
        }
    }

    /**
     * @description wrapper class AirporteEmailGenerator
     */
    public without sharing class AirportEmailGenerator extends AITM_TenderEmailGenerator {
        private final String SUBJECT_PREFIX = 'Air BP Contract Change Notification: ';
        private final Map<String, String> EMAIL_TEMPLATES = new Map<String, String>{
            'ENG' => 'AITM_DeBriefAirportsEmail_ENG'
        };

        private final Map<String, String> LOCATION_RESULTS = new Map<String, String>{
            'BG' => 'Gained',
            'BR' => 'Retained',
            'LB' => 'Lost',
            'MI' => 'Market Information',
            'MIX' => 'Market Information'
        };

        private final String emailTemplateBody;

        /**
         * @description overloaded constructor
         * @param tenderId of type Id
         * @param  locationType of type String
         */
        public AirportEmailGenerator(Id tenderId, String locationType) {
            super(tenderId, locationType);
            emailTemplateBody = getEmailTemplateMarkup(mapEmailTemplateName());
        }

        /**
         * @description gets airport emails
         * @param null
         * @return List collection of AITM_EmailGeneratorController.EmailDTO
         */
        public List<AITM_EmailGeneratorController.EmailDTO> getAirportEmails() {
        if(emailTemplateBody!=null){
            List<AITM_EmailGeneratorController.EmailDTO> allEmails = new List<AITM_EmailGeneratorController.EmailDTO>();
             /*for (AITM_Tender_Location__c tenderLocation : tenderData.tenderLocationsWithDeBrief) {
                allEmails.add(this.getAirportEmail(tenderLocation));
             }*/
              return allEmails;
        } else {
              return null;
          }
    }
      

        /**
         * @description gets Airport Email
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return AITM_EmailGeneratorController.EmailDTO
         */
        private AITM_EmailGeneratorController.EmailDTO getAirportEmail(AITM_Tender_Location__c tenderLocation) {
            this.setAddresses(tenderLocation);
            this.setSubject();
            this.setBody(tenderLocation);
            AITM_EmailGeneratorController.EmailDTO result = emailDTOFactory.create();
            emailDTOFactory = new AITM_EmailGeneratorController.EmailDTOFactory();
            return result;
        }
        
        /**
         * @description sets addresses
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return null
         */
        private void setAddresses(AITM_Tender_Location__c tenderLocation) {
            
            Set<String> locationManagerEmailSet = new Set<String>();
            Set<String> locationManagerDelegatesEmailSet = new Set<String>();
            
            for (String locationManagerEmail : tenderData.locationManagersEmail) {
                String locationManagerEmailIgnoreCase = locationManagerEmail.toLowerCase();
                if(!locationManagerEmailSet.contains(locationManagerEmailIgnoreCase)) {
                    locationManagerEmailSet.add(locationManagerEmailIgnoreCase);
                    emailDTOFactory.addEmailAddress(true, locationManagerEmailIgnoreCase);
                }
            }
            
            for (String delegateEmail : tenderData.locationManagerDelegatesEmail) {
                String[] splitDelegateEmail = delegateEmail.split(';');
                for(String singleDelegateEmail : splitDelegateEmail) {
                    String singleDelegateEmailIgnoreCase = singleDelegateEmail.toLowerCase();
                    if(!locationManagerDelegatesEmailSet.contains(singleDelegateEmailIgnoreCase)) {
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
            emailDTOFactory.addSubject(SUBJECT_PREFIX + tenderData.tender.Name);
        }

        /**
         * @description sets body
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return null
         */
        private void setBody(AITM_Tender_Location__c tenderLocation) {
            String fullEmailTemplateMarkup = emailTemplateBody;
            fullEmailTemplateMarkup = mapDataNotRelatedToCustomer(fullEmailTemplateMarkup, tenderLocation);
            emailDTOFactory.addEmailBody(false, fullEmailTemplateMarkup.substringBefore('[[TENDER CUSTOMERS START]]'), '');

            String tenderCustomerlist = getTenderCustomerList(fullEmailTemplateMarkup.substringBetween('[[TENDER CUSTOMERS START]]', '[[TENDER CUSTOMERS END]]'), tenderLocation);
            emailDTOFactory.addEmailBody(false, tenderCustomerlist, '');

            emailDTOFactory.addEmailBody(false, fullEmailTemplateMarkup.substringAfter('[[TENDER CUSTOMERS END]]'), '');
        }

        /**
         * @description map email template name
         * @param null
         * @return string
         */
        private String mapEmailTemplateName() {
            return EMAIL_TEMPLATES.get('ENG');
        }

        /**
         * @description map data not related to customer
         * @param rawBody of type string
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return string
         */
        private String mapDataNotRelatedToCustomer(String rawBody, AITM_Tender_Location__c tenderLocation) {
            rawBody = rawBody.replace('[[LOCATION CODE]]', tenderLocation.AITM_IATA__c);
            rawBody = rawBody.replace('[[AIR BP ENTITY]]', '');
            return rawBody;
        }

        /**
         * @description gets tender customer list
         * @param tableTemplate of type string
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return string
         */
        private String getTenderCustomerList(String tableTemplate, AITM_Tender_Location__c tenderLocation) {
            String result = '';
            for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocation.AITM_Tender_Location__r) {
                if(!lineItem.AITM_Ad_hoc_Volume__c) {                   
                    String table = tableTemplate;
                    result += getTenderCustomerTable(table, lineItem);
                } else {
                    result = '';
                    return result;
                }
            }
            return result;
        }

        /**
         * @description gets tender customer table
         * @param tableTemplate of type string
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         * @return string
         */
        @TestVisible
        private String getTenderCustomerTable(String tableTemplate, AITM_Tender_Location_Line_Item__c lineItem) {
            tableTemplate = replaceFieldForRawBody(tableTemplate, '[[CUSTOMER GRN]]', lineItem.AITM_Account__r.AITM_GRN__c);
            tableTemplate = replaceFieldForRawBody(tableTemplate, '[[CUSTOMER NAME]]', lineItem.AITM_Account__r.Name);
            tableTemplate = replaceFieldForRawBody(tableTemplate, '[[AWARDED VOLUME]]', getAwardedVolume(lineItem));
            tableTemplate = replaceFieldForRawBody(tableTemplate, '[[UNIT OF MEASURE]]','USG');
            tableTemplate = replaceFieldForRawBody(tableTemplate, '[[STATUS STYLE]]', getStatusStyle(lineItem.AITM_Tender_Result__c));
            tableTemplate = replaceFieldForRawBody(tableTemplate, '[[LOCATION STATUS]]', getStatusByCode(lineItem.AITM_Tender_Result__c));
            tableTemplate = replaceFieldForRawBody(tableTemplate, '[[TENDER LOCATION PERIOD]]', getPeriod(lineItem));
            return tableTemplate;
        }

        /**
         * @description gets awarded volume
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         * @return string
         */
        private String getAwardedVolume(AITM_Tender_Location_Line_Item__c lineItem) {
            return lineItem.AITM_Ad_hoc_Volume__c ? 'ADHOC' : lineItem.AITM_Awarded_Volume__c == null ? '' : lineItem.AITM_Awarded_Volume__c.format();
        }

        /**
         * @description gets status style
         * @param result of type string
         * @return string
         */
        @TestVisible
        private String getStatusStyle(String result) {
            Set<String> wonResults = new Set<String>{'BG', 'BR'};
            Set<String> lostResults = new Set<String>{'LB'};
            if (wonResults.contains(result)) {
                return 'color: rgb(0, 95, 178);';
            } else if (lostResults.contains(result)) {
                return 'color: rgb(194, 57, 52);';
            } else {
                return '';
            }
        }

        /**
         * @description gets period
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         * @return string
         */
        private String getPeriod(AITM_Tender_Location_Line_Item__c lineItem) {
            return lineItem.AITM_Start_Date__c == null ? lineItem.AITM_End_Date__c == null ? '' : '' : lineItem.AITM_Start_Date__c.format() + ' to ' + lineItem.AITM_End_Date__c.format();
        }

        /**
         * @description gets status by code
         * @param result of type string
         * @return string
         */
        private String getStatusByCode(String result) {
            return LOCATION_RESULTS.get(result);
        }
    }

    /**
     * @description wrapper class AttachmentGenerator
     */
    public without sharing class AttachmentGenerator extends AITM_TenderEmailGenerator.AttachmentGenerator {
        public AttachmentGenerator(Id tenderId, AITM_EmailGeneratorController.EmailDTO emailDTO, String locationType) {
            super(tenderId, emailDTO, locationType);
        }

        /**
         * @description gets chatter post
         * @param emailToAttach of type AITM_EmailGeneratorController.EmailMessage
         * @return string
         */
        protected override String getChatterPost(AITM_EmailGeneratorController.EmailMessage emailToAttach) {
            return Label.AITM_GenerateDeBriefEmailChatterPost;
        }
    }

    /**
     * @description wrapper class location summary builder
     */
    private without sharing class LocationSummaryBuilder {
        public Map<String, String> locationsSummary;
        public Integer locationcount;
        
        /**
         * @description overloaded constructor
         * @param tenderId of type Id
         */
        public LocationSummaryBuilder(Id tenderId) {
            AITM_DeBriefLocSummaryController.LocationSummaryAdapter adapter = new AITM_DeBriefLocSummaryController.LocationSummaryAdapter(new AITM_Tender__c(Id = tenderId));
            locationsSummary = adapter.tableValuesMap;
        }
    }

    /**
     * @description wrapper class location table builder
     */
    private without sharing class LocationTableBuilder {

        private List<AITM_Tender_Location__c> deBriefTenderLocations;
        private String locationTableTemplate;
        private AITM_Tender__c tender;
        private String locationtype;
        
        /**
         * @description overloaded constructor
         * @param locationTableTemplate of type string
         * @param deBriefTenderLocations of type List collection AITM_Tender_Location__c
         */
        public LocationTableBuilder(String locationTableTemplate, List<AITM_Tender_Location__c> deBriefTenderLocations, AITM_Tender__c tender) {
            this.deBriefTenderLocations = deBriefTenderLocations;
            this.locationTableTemplate = locationTableTemplate;
            this.tender = tender;    
        }
        /**
         * @description overloaded constructor
         * @param locationTableTemplate of type string
         * @param deBriefTenderLocations of type List collection AITM_Tender_Location__c
         */
        public LocationTableBuilder(String locationTableTemplate, AITM_Tender__c tender,String locationType) {
            //this.deBriefTenderLocations = deBriefTenderLocations;
            this.locationTableTemplate = locationTableTemplate;
            this.tender = tender;  
             this.locationtype = locationType;  
        }
        
       /**
        * @description gets status style
        * @param result of type string
        * @return string
        */
        @TestVisible
        private String getResultStyle(String result) {
            Set<String> wonResults = new Set<String>{'BG'};
            Set<String> lostResults = new Set<String>{'LB'};
            Set<String> retainedResults = new Set<String>{'BR'};
            Set<String> mixResults = new Set<String>{'MIX'};
            if (wonResults.contains(result)) {
                return 'text-align: center;padding-left: .5rem;border-top: 1px solid rgb(216, 221, 230);white-space: nowrap; color: rgb(34, 139, 34); font-weight:bold;';
            } else if (lostResults.contains(result)) {
                return 'text-align: center;padding-left: .5rem;border-top: 1px solid rgb(216, 221, 230);white-space: nowrap; color: rgb(194, 57, 52); font-weight:bold;';
            } else if (retainedResults.contains(result)) {
                return 'text-align: center;padding-left: .5rem;border-top: 1px solid rgb(216, 221, 230);white-space: nowrap; color: rgb(0, 95, 178); font-weight:bold;';
            } else if (mixResults.contains(result)) {
                return 'text-align: center;padding-left: .5rem;border-top: 1px solid rgb(216, 221, 230);white-space: nowrap; color: rgb(0, 0, 0); font-weight:bold;';
            } else {
                return '';
            }
        }
        
        /**
         * @description gets location table
         * @param null
         * @return string
         */
        public String getLocationTable() {
            String result = ''; 
            List<AITM_Tender_Location__c> locationsList = new AITM_LocationsDao().getTenderLocationsInDebrief(tender.Id,locationtype);
            result += getTableForLocations(locationsList);
            return result;
        }

        /**
         * @description gets table for locations
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return string
         */
        private String getTableForLocations(List<AITM_Tender_Location__c> tenderLocations) {
            String result = locationTableTemplate;             
            //get Tender Location details
            for(AITM_Tender_Location__c tenderLocation:tenderLocations) {
                result = getTenderLocationDetails(result, tenderLocation);
            }
            result = result.replace('[[RESULT TABLE START]]', '');
            result = result.replace('[[RESULT TABLE END]]', '');
            String lineItemTemplate = result.substringBetween('[[CUSTOMER LINE FORMAT START]]', '[[CUSTOMER LINE FORMAT END]]');
            String rows = '';
            for(AITM_Tender_Location_Line_Item__c childItem : new AITM_LocationsDao().getTenderLocationLineItemsForDeBriefResults(tender.Id,locationType)) {
                      rows += getRowForTenderLineItem(lineItemTemplate, childItem);
            }
            result = result.substringBefore('[[CUSTOMER LINE FORMAT START]]') + rows + result.substringAfter('[[CUSTOMER LINE FORMAT END]]');    
            return result;
        }
        
        /**
         * @description gets Tender Location Details
         * @param result of type String
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return result of type String
         */ 
        private String getTenderLocationDetails(String result, AITM_Tender_Location__c tenderLocation) {
            result = replaceFieldForRawBody(result, '[[LOCATION NAME]]', tenderLocation.AITM_IATA_ICAO__c + ' - ' + tenderLocation.AITM_Location__r.Name + '-' + tenderLocation.AITM_Location_Manager__r.Name );
            result = replaceFieldForRawBody(result, '[[ADDITIONAL SERVICES STYLE]]',  getAdditionalServicesStyle(tenderLocation.AITM_Service_Level__c));
            result = replaceFieldForRawBody(result, '[[SERVICE LEVEL]]',  tenderLocation.AITM_Service_Level__c);
            result = replaceFieldForRawBody(result, '[[AIRCRAFT TYPE]]', tenderLocation.AITM_Aircraft_Type__c == null ? 'N/A' : tenderLocation.AITM_Aircraft_Type__c);    
            return result;
        }
        
        /** 
         * @description gets taxes and fees and additional notes for the locations
         * @param result of type String
         * @param tenderLocation of type AITM_Tender_Location__c
         * @param lineItemTemplate of type String
         * @return result of type String
         */
        private String getTaxesAndFeesAdditionalNotes(String result, AITM_Tender_Location__c tenderLocation, String lineItemTemplate) {
            String rows = '';
            //Snippet for debrief notes display for each location
            lineItemTemplate = result.substringBetween('[[CUSTOMER LINE FORMAT START]]','[[CUSTOMER LINE FORMAT END]]');
            for (AITM_Tender_Location_Line_Item__c childItem : tenderLocation.AITM_Tender_Location__r) {
                rows += getRowForTenderOfferNotes(lineItemTemplate, childItem);
            }
            result = result.substringBefore('[[CUSTOMER LINE FORMAT START]]') + rows + result.substringAfter('[[CUSTOMER LINE FORMAT END]]');    
            return result;
        }

        /** 
         * @description gets debrief notes for the locations
         * @param result of type String
         * @param tenderLocation of type AITM_Tender_Location__c
         * @param lineItemTemplate of type String
         * @return result of type String
         */
        private String getDebriefNotes(String result, AITM_Tender_Location__c tenderLocation, String lineItemTemplate) {
            String rows = '';
            //Snippet for debrief notes display for each location
            result = result.replace('[[DEBRIEF NOTES START]]','');
            result = result.replace('[[DEBRIEF NOTES END]]','');
            lineItemTemplate = result.substringBetween('[[CUSTOMER LINE FORMAT START]]','[[CUSTOMER LINE FORMAT END]]');
            for (AITM_Tender_Location_Line_Item__c childItem : tenderLocation.AITM_Tender_Location__r) {
                rows += getRowForTenderDebriefNotes(lineItemTemplate, childItem);
            }
            result = result.substringBefore('[[CUSTOMER LINE FORMAT START]]') + rows + result.substringAfter('[[CUSTOMER LINE FORMAT END]]');    
            return result;
        }
        
        /**
         * @description gets the TenderLocation History Line Item
         * @param result of type String
         * @param tenderLocation of type AITM_Tender_Location__c
         * @param lineItemTemplate of type String
         * @return result of type String
         */
        private String getTenderLocationHistoryLineItem(String result, AITM_Tender_Location__c tenderLocation, String lineItemTemplate) {
            String rows ='';
            result = result.replace('[[LINE ITEM HISTORY TABLE START]]','');
            result = result.replace('[[LINE ITEM HISTORY TABLE END]]','');
            lineItemTemplate = result.substringBetween('[[CUSTOMER LINE FORMAT START]]','[[CUSTOMER LINE FORMAT END]]');
            for (AITM_Tender_Location_Line_Item__c childItem : tenderLocation.AITM_Tender_Location__r) {
                rows += getRowForTenderHistoryLineItem(lineItemTemplate, childItem);
            }
            result = result.substringBefore('[[CUSTOMER LINE FORMAT START]]') + rows + result.substringAfter('[[CUSTOMER LINE FORMAT END]]') ;
            return result;
        }       
        
       /**
        * @description gets status style
        * @param result of type string
        * @return string
        */
        @TestVisible
        private String getAdditionalServicesStyle(String result) {
            if(result == 'Level I'){
                return 'display: none';
            }
            return '';
        }
        
        /**
         * @description gets total requested volume USG for the tender location
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return string
         */
        private String totalRequestedVolumeUSG(AITM_Tender_Location__c tenderLocation)
        {
            Decimal volumeUSG = 0.0;
            String totalVolume;
            if(tenderLocation.AITM_Total_Requested_Volume__c!=null)
            {
            volumeUSG = tenderLocation.AITM_Total_Requested_Volume__c;      
            volumeUSG = volumeUSG.round(system.roundingMode.HALF_UP);
            totalVolume = String.valueOf(volumeUSG.format());   
            }
            return totalVolume;
        }

        /**
         * @description gets rows for tender line item
         * @param template of type string
         * @param childItem of type AITM_Tender_Location_Line_Item__c
         * @return string
         */
        private String getRowForTenderLineItem(String template, AITM_Tender_Location_Line_Item__c childItem) {
            template = replaceFieldForRawBody(template, '[[IATA/ICAO]]', (childItem.AITM_Location__c != null ? childItem.AITM_Location__r.AITM_IATA_ICAO__c : ''));
            template = replaceFieldForRawBody(template, '[[AIRPORT NAME / COUNTRY]]', (childItem.AITM_Location__c != null ? childItem.AITM_Location__r.Name : '') + '\n' + (childItem.AITM_Location__c != null ? childItem.AITM_Location__r.AITM_Country__c : ''));
            template = replaceFieldForRawBody(template, '[[CUSTOMER NAME / GRN]]', (childItem.AITM_Account__r.Name + '\n' + childItem.AITM_Account__r.AITM_GRN__c));
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE DELIVERY POINT]]', childItem.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c);
            template = replaceFieldForRawBody(template, '[[START / END DATE]]', (childItem.AITM_Start_Date__c == null ? '' : childItem.AITM_Start_Date__c.format()) + ' \n ' + (childItem.AITM_End_Date__c == null ? '' : childItem.AITM_End_Date__c.format()));
            template = replaceFieldForRawBody(template, '[[RESULT STYLE]]', getResultStyle(childItem.AITM_Tender_Result__c));
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE RESULT]]', childItem.AITM_Tender_Result__c);
            template = replaceFieldForRawBody(template, '[[VOLUME TENDERED / AWARDED]]', ((childItem.AITM_Requested_Volume_USG__c == null ? '0' : string.valueOf(childItem.AITM_Requested_Volume_USG__c.format()) + 'USG') + '\n' + (childItem.AITM_Awarded_Volume__c == null ? '0' : string.valueOf(childItem.AITM_Awarded_Volume__c.format()) + ' USG')));
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE PRICING BASIS]]', childItem.AITM_Pricing_Basis__r.Name);
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE DIFFERENTIAL]]',childItem.AITM_Pricing_Basis__r.AITM_Type__c == 'C' ? string.valueOf(childItem.AITM_Current_Value__c):(childItem.AITM_Offered_Differential__c == null ? '' : string.valueOf(childItem.AITM_Offered_Differential__c.format()) + ' ' + childItem.AITM_Currency__c + '/' + childItem.AITM_Unit_Of_Measure__c));
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE REBATE]]', (childItem.AITM_Rebate__c == null ? '' : string.valueOf(childItem.AITM_Rebate__c) + ' ' + childItem.AITM_Currency__c + '/' + childItem.AITM_Unit_Of_Measure__c));
            template = replaceFieldForRawBody(template, '[[LAST TENDER RESULT]]', childItem.AITM_History_Line_Item__r.AITM_Tender_Result__c == null ? '' : childItem.AITM_History_Line_Item__r.AITM_Tender_Result__c);
            template = replaceFieldForRawBody(template, '[[VOLUME]]', childItem.AITM_History_Line_Item__r.AITM_Volume__c == null ? '' : String.valueOf(childItem.AITM_History_Line_Item__r.AITM_Volume__c.format()));
            template = replaceFieldForRawBody(template, '[[PRICING BASIS]]', (childItem.AITM_History_Line_Item__r.AITM_Pricing_Basis__c == null ? '' : childItem.AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name));
            template = replaceFieldForRawBody(template, '[[DIFF/CURR/UOM]]', (childItem.AITM_History_Line_Item__r.AITM_Offered_Differential__c == null ? '0' : string.valueOf(childItem.AITM_History_Line_Item__r.AITM_Offered_Differential__c.format()) + ' ' + childItem.AITM_Currency__c + '/' + childItem.AITM_Unit_Of_Measure__c));
            return template; 
        }
        
        /**
        * @description gets rows for tenderofferNotes
        * @param template of type string
        * @param childItem of type AITM_Tender_Location_Line_Item__c
        * @return string
        */
        private String getRowForTenderOfferNotes(String template, AITM_Tender_Location_Line_Item__c childItem) {
           // template = replaceFieldForRawBody(template, '[[CUSTOMER DELIVERY POINT]]', childItem.AITM_Line_Item_Name_Account__c + '-' + (childItem.AITM_Location_Delivery_Point__r != null ? childItem.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c : ''));
           // template = replaceFieldForRawBody(template, '[[LOCATIONS TAXES AND FEES]]', childItem.AITM_Taxes_Fees__c == null ? 'N/A' : childItem.AITM_Taxes_Fees__c);
           // template = replaceFieldForRawBody(template, '[[ADDITIONAL NOTES]]', childItem.AITM_Additional_Notes_Taxes_and_Fees__c == null ?'N/A' : childItem.AITM_Additional_Notes_Taxes_and_Fees__c);
            return template;
        }

       /**
        * @description gets rows for tenderDebriefNotes
        * @param template of type string
        * @param childItem of type AITM_Tender_Location_Line_Item__c
        * @return string
        */
        private String getRowForTenderDebriefNotes(String template, AITM_Tender_Location_Line_Item__c childItem)
        {
            template = replaceFieldForRawBody(template, '[[LOCATIONS COMMENTS]]', childItem.AITM_Debrief_Notes__c);
            return template;
        }
        
        /**
         * @description gets row for tender line item 
         * @param template of type string
         * @param childItem of type AITM_Tender_Location_Line_Item__c
         * @return string
         */
        private String getRowForTenderHistoryLineItem(String template, AITM_Tender_Location_Line_Item__c childItem) {
            template = replaceFieldForRawBody(template, '[[LINE ITEM HISTORY CUSTOMER TITLE]]', childItem.AITM_Account__r.Name);
            template = replaceFieldForRawBody(template, '[[LINE ITEM HISTORY CUSTOMER LINK]]', Url.getSalesforceBaseUrl().toExternalForm() + '/' + childItem.AITM_Account__c);
            template = replaceFieldForRawBody(template, '[[LINE ITEM HISTORY TENDER TITLE]]', childItem.AITM_History_Line_Item__r.Name);
            template = replaceFieldForRawBody(template, '[[LINE ITEM HISTORY TENDER LINK]]', Url.getSalesforceBaseUrl().toExternalForm() + '/' + childItem.AITM_History_Line_Item__c);
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE DELIVERY POINT]]', childItem.AITM_History_Line_Item__r.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c);
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE PRICING BASIS]]', childItem.AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name);
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE DESCRIPTION]]', childItem.AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c);
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE ACTUAL VOLUME]]', childItem.AITM_History_Line_Item__r.AITM_Volume__c == null ? '' : String.valueOf(childItem.AITM_History_Line_Item__r.AITM_Volume__c.format()) + ' USG');
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE LAST TENDER RESULT]]', childItem.AITM_History_Line_Item__r.AITM_Tender_Result__c);
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE UOM]]', childItem.AITM_Currency__c == null ? '' :  childItem.AITM_Currency__c + '/' + childItem.AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c == null ? '' : childItem.AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c);
            template = replaceFieldForRawBody(template, '[[CUSTOMER LINE DIFFERENTIAL]]', String.valueOf(childItem.AITM_History_Line_Item__r.AITM_Offered_Differential__c));
            return template;
        }

        /**
         * @description replace field for raw body
         * @param rawBody of type string
         * @param placeholder of type string
         * @param fieldValue of type string
         * @return string
         */
        private String replaceFieldForRawBody(String rawBody, String placeholder, String fieldValue) {
            if (fieldValue != null) {
                return rawBody.replace(placeholder, fieldValue.replace('\n','<br/>'));
            } else {
                return rawBody.replace(placeholder, '');
            }
        }
    }
}