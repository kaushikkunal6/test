/***********************************************************************************************
 * @author           George
 * @group             AirBP
 * @description      Used for sending the invitation mail to Location Manager when the tender is in awaiting price stage
 *
 * history
 * 01/December/2017  George          Created
 * 28/March/2018     Shweta          Modified - AR-2808 Added the dynamic value of the field AITM_Requested_Volume_UoM__c to be shown up
                                     with the requested volume.
 * 04/July/2018      srnandan        Modified - AR-3703 modified method getBodyHtml
 * 09/Aug/2018       Ravi            Modified - AR-4057 modified method getCustomerListHtml to hard code USG after totalVolume
 *                                   and method CustomerWrapper to change field to AITM_Credit_Days1__c 
 *                                   and method getCustomerListHtml to update airline Profile info field    
 * 10/August/2018    srnandan        Modified - AR-4011 - Modifed overloaded constructor Generator 
 * 05/Sep/2018       Saravan         Modified - AR-4161 setAddresses method to include Account Manager in CC    
 * 18/January/2019   srnandan        Modified method TenderWrapper to include tenderinfo and wrapContentWithAirlineAndProfile   
 * 22/January/2019   srnandan        Modified - AR-4939 removal duplicate email addresses using set collection
 * 29/January/2019   srnandan        Modified - AR-4939 remove duplicate for delegates split with ';'
 * 30/January/2019   Shweta          Modified - AR-4957/AR-4956 Updated the method getLocationsHtml to show only awaiting price locations with pricing responsibility
 * 09/April/2019     Ravi            Modified - AR-5132 Updated the setSubject to populate Tender Sector in Subject and body
 * 30/July/2019      Shweta          Modified - AR-5288 Updated the class to accomodate 20 GRNS and 1000 locations in the invitation email. 
 * 12/Sep/2019		 Saravan		 Modified - 714869  Updated the class to remove duplicates from To List 
 *************************************************************************************/
public with sharing class AITM_InvitationEmailGenerator {
    
    /**
     * @description Inner class Generator extending TenderEmailGenerator
     */
    public class Generator extends AITM_TenderEmailGenerator {
        private final String INVITATION_PREFIX = 'Invitation to Tender: ';
        private final String INVITATION_POLISH_PREFIX = 'LABP Invitation: ';
        private final String INVITATION_XLS_URL = '/apex/AITM_InvitationGenerateXLS?id=';
        private final String LOCATION_TYPE = '&locationType=';
        private Id tenderId;
        private AITM_Tender__c tender;
        public String locationType;
		
        /**
         * @description default constructor
         */
        public Generator() {
          super();            
        }
		
        /**
         * @description overloaded constructor
         * @param tenderId of type Id
         */
        public Generator(Id tenderId) {
            super(tenderId);
            this.tenderId = tenderId;
        }

        /**
         * @description overloaded constructor
         * @param tenderId of type Id
         * @param locationType of type String
         */
        public Generator(Id tenderId, String locationType) {
            super(tenderId, locationType);
            this.tenderId = tenderId;
            this.locationType = locationType;
        }

        /**
         * @description generates email structure
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
                String invitationXLSFileName;
                if(locationType == AITM_TenderDao.NONPOLISH) {
                   invitationXLSFileName = INVITATION_PREFIX + tenderData.tender.AITM_Tender_Sector__c + ' ' + tenderData.tender.Name + ' ' + getTenderDuration() + '.xls';    
                } else {
                    invitationXLSFileName = INVITATION_POLISH_PREFIX + tenderData.tender.AITM_Tender_Sector__c + ' '  + tenderData.tender.Name + ' ' + getTenderDuration() + '.xls';    
                } 
                Blob fileBody = (!Test.isRunningTest() ?  new PageReference(INVITATION_XLS_URL + this.tenderId + LOCATION_TYPE + this.locationType).getContent() : Blob.valueOf('UNIT.TEST'));
                ContentVersion invitationContent = AITM_BaseUtils.createContentVersion(fileBody, invitationXLSFileName);
                if(!Test.isRunningTest()) {
                    //AITM_BaseUtils.createChatterPostToRelate('', this.tenderId, invitationContent.Id);
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: invitationContent.Id].ContentDocumentId;
                    cdl.LinkedEntityId = this.tenderId;
                    cdl.ShareType = 'V';
                    insert cdl;
                }
                emailDTOFactory.addEmailAttachment(invitationContent);                     
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
            emailDTOFactory.addSubject(INVITATION_PREFIX + tenderData.tender.AITM_Tender_Sector__c + ' ' + tenderData.tender.Name + ' ' + getTenderDuration() + ' ' + 'Bids in: ' + tenderData.tender.AITM_Bids_In_By__c.format());
        }

        /**
         * @description sets body
         * @param null
         * @return null
         */
        private void setBody() {
            //emailDTOFactory.addEmailBody(true, '', getEditablePlainTextBody());
            emailDTOFactory.addEmailBody(false, getIntroduction(), '');
            emailDTOFactory.addEmailBody(false, getBodyHtml(), '');
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
         * @description get the first part of the mail
         * @param null
         * @return string
         */

         public String getIntroduction()
         {
             String html ='';
             html += '<hr style ="background-color:rgb(34,139,34);height:1px;border:none">';
             //html += '<hr class="greenColor">';
             html += '<br/>';
             //html += '<div class="width100">';
             html += '<div style="width: 100%; margin-bottom: 1rem;">';
             //html += '<div class="width25">' ;
             html += '<div style="display: inline-block; width: 25%; float: left ">';
             html += '<img src = "https://customers.airbp.com/static/img/logo.png" alt="Air BP logo">';
             //html += '<img src =' + {!URLFOR($Resource.AITM_InvitationEmailResources)} + ' alt="Air BP logo">';

             html += '     ';
             html += '</div>';
             //html += '<div class="width75">';
             html += '<div style="display: inline-block; width: 75%;">';
             //html += '<div class="headerGreenText">';
             //html += '<h2 title="Tender">Invitation to Price for your Tender Location(s)';
             html += '<div>';
             html += '<h2 style="padding-left:1.5rem;font-family:Salesforce Sans,Arial,sans-serif;font-weight:normal;Margin:0;color:rgb(34,139,34);font-size:24px;line-height:1.25;max-width:80%;overflow:hidden;text-overflow:ellipsis;"title="Tender">Invitation to Price for your Tender Location(s)';
             html += '</h2>';
             html += '</div>';
             html += '<br/>';
             //html += '<div class="lightGreenText">';
             html += '<div style="padding-left:1.5rem;font-family:Salesforce Sans,Arial,sans-serif;font-weight:normal;Margin:0;color:rgb(154,205,50);font-size:36px;text-decoration: none;">';
             html +=  tenderData.tender.AITM_Tender_Sector__c + ' -' +tenderData.tender.Name + '-' +  tenderData.tender.AITM_Start_Date__c.format() + '-' +  tenderData.tender.AITM_End_Date__c.format();
             html += '</div>';
             html += '<br/><br/>';
             html += '</div>';
             html += '</div>';
             html += '<br/>';
             //html += '<div class="greenHeight30">';
             html += '<div>';
             //html += 'style="width: 100%; height: 30px; background: rgb(34,139,34)" >';
             html += '</div>';
             html += '<br/>';
             html += '<div>';
             //html += '<p>Dear Location Manager(s),</p>';
             html += '<p style = "font-size:14px;font-family:Salesforce Sans,Arial,sans-serif;">Dear Location Manager(s),</p>';
             html += '<br/>';
             html += '<p style = "font-size:14px;font-family:Salesforce Sans,Arial,sans-serif;">I am pleased to invite you to price for your locations listed below.Please click on the link to take you to the Locations Listing section of this tender in Salesforce.</p>';
             //html += '<p>I am pleased to invite you to price for your locations listed below.Please click on the link to take you to the Locations Listing section of this tender in Salesforce.</p>';
             html += '</div>';
             return html;
         }

        /**
         * @description gets body html
         * @param null
         * @return string
         */
        private String getBodyHtml() {
            String bodyHtml = '';
            //this.tender = new AITM_TenderDao().getTenderWithAwaitAndNotRepresentTenderLocationsAndTenderAccounts(this.tenderId, this.locationType);
            this.tender = new AITM_TenderDao().getTenderWithAwaitAndNotRepresentTenderAndTenderAccounts(this.tenderId, this.locationType);
            //if(this.tender.AITM_Tender_Locations__r.size() > 0){
            List<AITM_Tender_Location__c> tenderLocations = new AITM_TenderDao().getTenderLocations(tenderId, locationType);
            if(tenderLocations.size() > 0) {
                TenderEmailDataHolder tenderEmailDataHolder = new TenderEmailDataHolder(this.tender, this.locationType);
                TenderEmailBuilder emailBuilder = new TenderEmailBuilder(tenderEmailDataHolder);
                bodyHtml = emailBuilder.getHtmlBody(this.locationType);
            }
            return bodyHtml;
        }

        /**
         * @description gets editable plain text body
         * @param null
         * @return string
         */
        public String getEditablePlainTextBody() {
            String text = '';
            text += 'Dear Location Manager, I am pleased to invite you to price for your locations listed below.\n';
            text += 'Please click on the link to take you to the Locations Listing section of this tender in Sales Force.';
            return text;
        }

        /**
         * @description post to chatter
         * @param null
         * @return List<String>
         */
        public List<String> postToChatter() {
            List<ConnectApi.BatchInput> chatterMessages = new List<ConnectApi.BatchInput>();
            List<String> chatterMessagesTexts = new List<String>();
            this.tender = new AITM_TenderDao().getTenderWithAwaitingPriceTenderLocationsAndTenderAccounts(this.tenderId, this.locationType);
            if(this.tender.AITM_Tender_Locations__r.size() > 0){
                TenderEmailDataHolder tenderEmailDataHolder = new TenderEmailDataHolder(this.tender, this.locationType);
                for (Id locationManagerId : tenderEmailDataHolder.chatterNotificationReceivers.keyset()) {
                    String chatterText = getChatterText(tenderEmailDataHolder.chatterNotificationReceivers, locationManagerId);
                    ConnectApi.BatchInput message = AITM_BaseUtils.createChatterMessageWithMention(this.tender.Id, locationManagerId, chatterText);
                    chatterMessages.add(message);
                    chatterMessagesTexts.add(chatterText);
                }
                AITM_BaseUtils.postToChatter(chatterMessages);
            }
            return chatterMessagesTexts;
        }

        /**
         * @description gets chatter text
         * @param chatterNotificationReceivers of type Map<Id, String>
         * @param locationManagerId of type Id
         * @return String
         */
        public String getChatterText(Map<Id, String> chatterNotificationReceivers, Id locationManagerId) {
            String chatterText = 'Please setup a Price value for the tender ' + '\'' + this.tender.Name + '\'';
            chatterText += ' on Location \'' + chatterNotificationReceivers.get(locationManagerId) + '\'';
            return chatterText;
        }

        /**
         * @description generates tender invitation emails bulk
         * @param tenderIds of type List<Id>
         * @return List<Messaging.SingleEmailMessage>
         */
        public List<Messaging.SingleEmailMessage> generateTenderInvitationEmailsBulk(List<Id> tenderIds){
            //List<AITM_Tender__c> tendersWithTenderLocationsAndAccounts =  new AITM_TenderDao().getTenderWithAwaitingPriceTenderLocationsAndTenderAccounts(tenderIds);
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(AITM_Tender__c tender : new AITM_TenderDao().getTenderWithAwaitingPriceTenderLocationsAndTenderAccounts(tenderIds)) {
                if(tender.AITM_Tender_Locations__r.size() > 0){
                    TenderEmailDataHolder tenderEmailDataHolder = new TenderEmailDataHolder(tender, this.locationType);
                    TenderEmailBuilder emailBuilder = new TenderEmailBuilder(tenderEmailDataHolder);
                    Messaging.SingleEmailMessage message = new AITM_EmailGeneratorController.EmailMessageFactory().create(emailBuilder.build(this.locationType)).toSingleEmailMessage();
                    mails.add(message);
                }
            }
            return mails;
        }

    }

    /**
     * @description holds tender data for email
     */
    public class TenderEmailDataHolder {
        public List<CustomerWrapper> customerList;
        public List<LineItemWrapper> lineItemsList;
        public Map<Id, List<LineItemWrapper>> tenderLocationIdToLineItems;
        public Map<Id, String> locationManagerIdToName;
        public List<AITM_Tender_Location__c> tenderLocations;
        public List<String> locationManagers;
        public List<String> locationDelegates;
        public Map<Id, String> chatterNotificationReceivers;
        public TenderWrapper tender;
        public Decimal totalVolume = 0;
        public Integer numberOfLocations = 0;

        private String DEFAULT_RECORD_TYPE_NAME = 'Default';

        /**
         * @description overloaded constructor
         * @param tender of type AITM_Tender__c
         */
        public TenderEmailDataHolder(AITM_Tender__c tender, String locationType) {
            this.customerList = new List<CustomerWrapper>();
            this.lineItemsList = new List<LineItemWrapper>();
            this.locationManagers = new List<String>();
            this.locationDelegates = new List<String>();
            this.tenderLocations = new List<AITM_Tender_Location__c>();
            this.tenderLocationIdToLineItems = new Map<Id, List<LineItemWrapper>>();
            this.locationManagerIdToName = new Map<Id, String>();
            this.chatterNotificationReceivers = new Map<Id, String>();
            this.prepareData(tender, locationType);
        }

        /**
         * @description prepares data
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void prepareData(AITM_Tender__c tender, String locationType) {
            this.addTender(tender);
            //this.addTenderLocations(tender.AITM_Tender_Locations__r);
            this.addTenderLocations(tender.Id, locationType);
            this.addCustomers(tender.AITM_Tender_Accounts__r);
            //this.addLineItems(tender.Id, locationType);
            //this.addLineItems(tender.AITM_Tender_Location_Line_Items__r);
        }

        /**
         * @description adds tender
         * @param tender of type AITM_Tender__c
         * @return null
         */
        public void addTender(AITM_Tender__c tender) {
            this.tender = new TenderWrapper(tender);
        }

        /**
         * @description adds customers
         * @param tenderAccounts of type List<AITM_Tender_Account__c>
         * @return null
         */
        public void addCustomers(List<AITM_Tender_Account__c> tenderAccounts) {
            for(AITM_Tender_Account__c tenderAccount : tenderAccounts) {
                this.customerList.add(new CustomerWrapper(tenderAccount));
            }
        }

        /**
         * @description adds tender locations
         * @param tenderLocations of type List<AITM_Tender_Location__c>
         * @return null
         */
        public void addTenderLocations(Id tenderId, String locationType) {
            for(AITM_Tender_Location__c tenderLocation : new AITM_TenderDao().getTenderWithAwaitAndNotRepresentLocations(tenderId, locationType)){
                this.totalVolume += (tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c != null) ? 
                                    tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c : 0;
                //this.locationManagers.add(tenderLocation.AITM_Location_Manager__r.Email);
                //this.addLocationDelegates(tenderLocation.AITM_Location__r.AITM_Delegates__c);
                //this.locationManagerIdToName.put(tenderLocation.AITM_Location_Manager__c, tenderLocation.AITM_Location_Manager__r.Name);
                this.chatterNotificationReceivers.put(tenderLocation.AITM_Location_Manager__c, tenderLocation.AITM_Location__r.Name);
                this.tenderLocations.add(tenderLocation);
            }
            
        }

        /**`
         * @description adds location delegates
         * @param delegates of type string
         * @return null
         */
        public void addLocationDelegates(String delegates){
            if(String.isNotBlank(delegates)) {
                List<String> delegatesAddresses = AITM_BaseUtils.getTextByLines(delegates);
                for(String delegateEmail : delegatesAddresses) {
                    this.locationDelegates.add(delegateEmail);
                }
            }
        }

        /**
         * @description adds line items
         * @param lineItems of type List<AITM_Tender_Location_Line_Item__c>
         * @return null
         */
        public void addLineItems(Id tenderId, String locationType) {
            for(AITM_Tender_Location_Line_Item__c lineItem : new AITM_TenderDao().getTenderWithAwaitAndNotRepresentTenderLocationLineItems(tenderId,locationType)) {
                if(lineItem.RecordType.Name == DEFAULT_RECORD_TYPE_NAME){
                    this.lineItemsList.add(new LineItemWrapper(lineItem));
                }
            }
        }

        /**
         * @description gets number of locations
         * @param null
         * @return integer
         */
        public Integer getNumberOfLocations(){
            return tenderLocations.size();
        }
        
        /**
         * @description get the nonreprsented  locations
         * @param null
         * @return List of AITM_Tender_Location__c type
         */
        public  List<AITM_Tender_Location__c> getNonRepresentedLocations(){
            List<AITM_Tender_Location__c> nonRepresentTenderLocations = new AITM_LocationsDao().getNonRepresentedTenderLocations(tenderLocations); 
            return nonRepresentTenderLocations;
        }

        /**
         * @description gets number of locations
         * @param null
         * @return integer
         */
        public Integer getNumberOfCustomers(){
            return customerList.size();
        }

        /**
         * @description gets tender locationid to lineitems
         * @param null
         * @return Map<Id, List<LineItemWrapper>>
         */
        public Map<Id, List<LineItemWrapper>> getTenderLocationIdToLineItems() {
            if(this.tenderLocationIdToLineItems.isEmpty()){
                Map<Id, List<LineItemWrapper>> idToLineItems = new Map<Id, List<LineItemWrapper>>();
                for(AITM_Tender_Location__c tenderLocation : this.tenderLocations){
                    List<LineItemWrapper> tenderLocationLineItems = new List<LineItemWrapper>();
                    for(LineItemWrapper lineItem : this.lineItemsList){
                        if(lineItem.tenderLocationId == tenderLocation.Id){
                            tenderLocationLineItems.add(lineItem);
                        }
                    }
                    idToLineItems.put(tenderLocation.Id, tenderLocationLineItems);
                }
                this.tenderLocationIdToLineItems = idToLineItems;
            }
            return this.tenderLocationIdToLineItems;
        }

    }

    /**
     * @description tender email builder
     */
    public class TenderEmailBuilder {
        private TenderEmailDataHolder tenderEmailDataHolder;
        private Map<String, String> styles;

        /**
         * @description overloaded constructor
         * @param tenderEmailDataHolder of type TenderEmailDataHolder
         */
        public TenderEmailBuilder(TenderEmailDataHolder tenderEmailDataHolder) {
            this.tenderEmailDataHolder = tenderEmailDataHolder;
            this.styles = new Map<String, String>();
            this.defineStyles();
        }

        /**
         * @description build emaildto
         * @param null
         * @return AITM_EmailGeneratorController.EmailDTO
         */
        public AITM_EmailGeneratorController.EmailDTO build(String locationType) {
            AITM_EmailGeneratorController.EmailDTOFactory emailDTOFactory = new AITM_EmailGeneratorController.EmailDTOFactory();
            emailDTOFactory.addSubject('Invitation to Tender: ' + tenderEmailDataHolder.tender.tenderSector + tenderEmailDataHolder.tender.name + ' (' + tenderEmailDataHolder.tender.startDate.format() + ' - ' + tenderEmailDataHolder.tender.endDate.format() + ') ' );
            emailDTOFactory.addEmailBody(true, getHtmlBody(locationType), '');

            return emailDTOFactory.create();
        }

        /**
         * @description define styles
         * @param null
         * @return null
         */
        public void defineStyles() {
            styles.put('main', 'style="font-family: \'Univers 45 Light\',\'Salesforce Sans\',Arial,sans-serif; overflow: auto;"');
            styles.put('table', 'style="border-collapse:separate;font-size:12px;border-top:1px solid rgb(216,221,230);border-bottom:1px solid rgb(216,221,230);width:100%"');
            styles.put('thead > tr', 'style="font-size: 12px; font-weight: 300; line-height: 1.25; color: rgb(84, 105, 141); text-transform: uppercase;letter-spacing: 1px;"');
            styles.put('thead > th', 'style="text-align:left; padding:.5rem; white-space:nowrap"');
            styles.put('tbody > tr', 'style="text-align:left; padding-left:.5rem; border-top:1px solid rgb(216,221,230); white-space:nowrap"');
            styles.put('td', 'style="border-top:1px solid rgb(216,221,230);white-space:nowrap;font-weight:400;padding:.5rem"');
            styles.put('h2', 'style="font-family: \'Univers 45 Light\',\'Salesforce Sans\',Arial,sans-serif;font-weight:400;font-size:18px;line-height:1.25;max-width:100%;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"');
            styles.put('h2.wrapper', 'style="border-bottom:1px solid rgb(216,221,230);background:rgb(247,249,251);padding:.75rem"');
            styles.put('p', 'style="color: #12872f;"');
            styles.put('row','style = "margin: 5 -30px "');
            styles.put('row1','style = "margin: 5px "');
            styles.put('column','style = "float: left;width:19%;padding:1px;box-sizing:border-box "');
            styles.put('card','style = "border:2px solid green;box-sizing:border-box;padding:1px;text-align:center; background-color:#ffffff "');
            styles.put('newtext','style = "Margin:0"');
            styles.put('bidsinbytext','style = "Margin:0;font-weight: bold;color:red"');
            styles.put('heading' ,'style="width: 100%; height: 19px; background: rgb(154,205,50)"');
            styles.put('green heading','style="width: 100%; height: 40px; background:forestgreen"');
            styles.put('header','style = "color: rgb(255,255,255); font-size:15px;font-weight:normal"');
            styles.put('subheading','style ="padding-left:1rem;font-family:Salesforce Sans,Arial,sans-serif;font-weight:bold;color:forestgreen;font-size:20px;line-height:1.25;max-width:80%;overflow:hidden;text-overflow:ellipsis;"');
        }

        /**
         * @description gets html body
         * @param null
         * @return string
         */
        public String getHtmlBody(String locationType) {
            String html = '';
            String tenderUrl ='';
            String reportUrl = '';
            Report reportName = new AITM_TenderDao().getTenderReport('Tender Invitation Report');            
            if(locationType == AITM_TenderDao.POLISH) {
               tenderUrl =  AITM_BaseUtils.getLABPURL() + '/' + tenderEmailDataHolder.tender.tenderId;
               reportUrl = AITM_BaseUtils.getLABPURL() + System.Label.AITM_ReportURLLABP + '/'  + reportName.Id + '/view?fv2=' + tenderEmailDataHolder.tender.tenderId + '&fv3=' + AITM_TenderDao.POLISH.replaceAll('\\s+', '');
               } else  {
               tenderUrl = AITM_BaseUtils.getTenderingURL() + '/' + tenderEmailDataHolder.tender.tenderId;
               reportUrl = AITM_BaseUtils.getTenderingURL() + System.Label.AITM_ReportURLTendering + '/' + reportName.Id + '/view?fv2=' + tenderEmailDataHolder.tender.tenderId + '&fv3=' + AITM_TenderDao.NONPOLISH.replaceAll('\\s+', ''); 
            }             
            html += '<div ' + styles.get('main') + '>';
            html += '<p style = "font-size:14px;">Salesforce link to the Tender:</p>';
            html += '<p style = "font-size:14px;"><a href="'+tenderUrl+'" target="_blank">' + tenderUrl + '</a></p><br/>';
            html += '<p style = "font-size:14px;">Salesforce Report link to the Tender:</p>';
            html += '<p style = "font-size:14px;"><a href="'+reportUrl+'" target="_blank">' + reportUrl + '</a></p><br/>';
            html += this.getCustomerListHtml() + '<br/>';
            html += this.getNegotiationInstructionsHtml() + '<br/>';
            html += this.getLocationsHtml(tenderEmailDataHolder.tender.tenderId,locationType) + '<br/>';
            html += this.getNonRepresentedTenderLocations() + '<br/>';
            html += this.getUserSignatures() + '<br/>' ;
            html += '</div>';
            return html;
        }

        /**
         * @description wrap content with th 
         * @param content of type string
         * @param styles of type string
         * @return string
         */
        public String wrapContentWithTH(String content, String styles) {
            return (content != null) ? '<th ' + styles + ' ><div class="slds-truncate">' + content + '</div></th>' : '<td ' + styles + ' ></th>';
        }       

        /**
         * @description wrap content with td 
         * @param content of type string
         * @return string
         */
        public String wrapContentWithTD(String content) {
            return (content != null) ? '<td ' + styles.get('td') + ' >' + content + '</td>' : '<td ' + styles.get('td') + ' ></td>';
        }        

        /**
         * @description wrap content with td 
         * @param content of type decimal
         * @return string
         */
        public String wrapContentWithTD(Decimal content) {
            return (content != null) ? '<td ' + styles.get('td') + ' >' + content.format() + '</td>' : '<td ' + styles.get('td') + ' ></td>';
        }

        /**
         * @description wrap content with td 
         * @param content of type date
         * @return string
         */
        public String wrapContentWithTD(Date content) {
            return (content != null) ? '<td ' + styles.get('td') + ' >' + content.format() + '</td>' : '<td ' + styles.get('td') + ' ></td>';
        }

        /**
         * @description wrap content with h2 
         * @param content of type string
         * @return string
         */
        public String wrapContentWithH2(String content) {
            String html = '';
            html += '<div ' + styles.get('h2.wrapper') + '>';
                html += '<div style="display:flex">';
                    html += '<div style="min-width:0">';
                        html += '<div style="display:flex">';
                            html += '<div style="display:flex">';
                                html += '<h2 ' + styles.get('h2') + '>' + content + '</h2>';
                            html += '</div>';
                        html += '</div>';
                    html += '</div>';
                html += '</div>';
            html += '</div>';
            return html;
        }
        
        /**
         * @description wrap content with h2 
         * @param content of type string
         * @return string
         */
        public String wrapContentWithHeaderBoxContent(String content) {
            String html = '';
            html += '<div ' + styles.get('heading') + '>';
            html += '<div ' + styles.get('header') + '>';
            html += content;
            html += '</div>';
            html += '</div>';
            html += '</br/>';
            //html += '<tbody>';
            html += '<div ' + styles.get('row') + '>';
            html += '<div ' + styles.get('column') + '>';
            html += '<div ' + styles.get('card') + '>';
            html +=  '<p '+ styles.get('newtext') + '>' + (tenderEmailDataHolder.totalVolume != null ? tenderEmailDataHolder.totalVolume.format() : '') + '</p>';
            html += '</br/>';
            html += '<p '+ styles.get('newtext') + '>' + 'Total Tender' + '</p>';           
            html += '<p '+ styles.get('newtext') + '>' + 'Volume' + '</p>';
            html += '<p '+ styles.get('newtext') + '>' + '(USG)' + '</p>';             
            html += '</div>';
            html += '</div>';
            html += '</div>';

            html += '<div ' + styles.get('row') + '>';
            html += '<div ' + styles.get('column') + '>';
            html += '<div ' + styles.get('card') + '>';
            html += '<p '+ styles.get('newtext') + '>' + tenderEmailDataHolder.getNumberOfCustomers() + '</p>';
            html += '</br/>';
            html += '<p '+ styles.get('newtext') + '>'+ 'Number' + '</p>' ;
            html += '<p '+ styles.get('newtext') + '>'+ 'Of' + '</p>' ;
            html += '<p '+ styles.get('newtext') + '>'+ 'Customers' + '</p>' ;              
            html += '</div>';
            html += '</div>';
            html += '</div>';

            html += '<div ' + styles.get('row') + '>';
            html += '<div ' + styles.get('column') + '>';
            html += '<div ' + styles.get('card') + '>';                                       
            html += '<p '+ styles.get('newtext') + '>' + tenderEmailDataHolder.getNumberOfLocations() + '/' + tenderEmailDataHolder.getNonRepresentedLocations().size() + '</p>' ;
            html += '</br/>';
            html += '<p '+ styles.get('newtext') + '>'+ 'Number Of' + '</p>' ;
            html += '<p '+ styles.get('newtext') + '>'+ 'Represented/' + '</p>' ;
            html += '<p '+ styles.get('newtext') + '>'+ 'NRepresented' + '</p>' ;        
                                                                      
            html += '</div>';
            html += '</div>';
            html += '</div>';
            
            html += '<div ' + styles.get('row') + '>';
            html += '<div ' + styles.get('column') + '>';
            html += '<div ' + styles.get('card') + '>';
            html += '<p '+ styles.get('bidsinbytext') + '>' + tenderEmailDataHolder.tender.bidsInBy.format() + '</p>' ;
            html += '</br/>';
            html += '<p '+ styles.get('bidsinbytext') + '>'+ 'Bids in' + '</p>' ;
            html += '<p '+ styles.get('bidsinbytext') + '>'+ 'by' + '</p>' ;
            html += '<p '+ styles.get('bidsinbytext') + '>'+ '(dd/mm/yyyy)' + '</p>' ;            
            html += '</div>';
            html += '</div>';
            html += '</div>'; 

            html += '<div ' + styles.get('row') + '>';
            html += '<div ' + styles.get('column') + '>';
            html += '<div ' + styles.get('card') + '>';
            html += '<p '+ styles.get('newtext') + '>' + (tenderEmailDataHolder.tender.lastLookToIncumbent == null ? '&nbsp;' : tenderEmailDataHolder.tender.lastLookToIncumbent) + '</p>' ;                        
            html += '</br/>';
            html += '<p '+ styles.get('newtext') + '>'+ 'Last Look' + '</p>' ;
            html += '<p '+ styles.get('newtext') + '>'+ 'To' + '</p>' ;
            html += '<p '+ styles.get('newtext') + '>'+ 'Incumbent' + '</p>' ;           
            html += '</div>';
            html += '</div>';
            html += '</div>';

            
            html += '<br/>'; 
            html += '<br/>';
            html += '<br/>';
            html += '<br/>';
            html += '<br/>';
            html += '<br/>';
            return html;
        } 
        
        /**
         * @description wrap content with Airline and Profile info 
         * @param content of type string
         * @return string
         */
        public String wrapContentWithAirlineAndProfile(String content) {
            String html = '';
            html += '<hr style ="background-color:rgb(0,128,0);height:1px;border:none">'; 
            html += content;
            html += '</br/>'; 
            html += (tenderEmailDataHolder.tender.airlineProfileInfo == null?'':tenderEmailDataHolder.tender.airlineProfileInfo);
            html += '</br/>';    
            html += '</br/>';  
            html += (tenderEmailDataHolder.tender.tenderInfo == null?'':tenderEmailDataHolder.tender.tenderInfo);        
            html += '<hr style ="background-color:rgb(0,128,0);height:1px;border:none">'; 
            //html += '</br/>'; 
            return html;
        }
        
        /**
         * @description wrap content with Header details
         * @param content of type string
         * @return string
         */
        public String wrapContentWithHeader(String content) {
            String html = '';
            html += '<div ' + styles.get('heading') + '>';
            html += '<div ' + styles.get('header') + '>'; 
            html += content;
            html += '</br/>';
            html += '</div>';
            html += '</div>';
            html += '</br/>';           
            return html;
        }
        
        /**
         * @description wrap content with Bold
         * @param content of type string
         * @return string
         */
        public String wrapContentWithBold(String content) {
            String html = '';
            html += '<b '+ styles.get('newtext') + '>' + content + '</b>';
            return html;
        }
        
        /**
         * @description gets customer list html
         * @param null
         * @return string
         */
        public String getCustomerListHtml() {
            String html = '';

            html += wrapContentWithHeaderBoxContent('Tender Summary');
            html += wrapContentWithAirlineAndProfile('Airline Profile & Tender Information:');
            html += wrapContentWithHeader('Customer List:');
            html += '<table '+ styles.get('table') + '>';
                html += '<thead>';
                    html += '<tr '+ styles.get('thead > tr') + '>';
                        html += wrapContentWithTH('Customer', styles.get('thead > th'));
                        html += wrapContentWithTH('GRN', styles.get('thead > th'));
                        html += wrapContentWithTH('Invoice Frequency', styles.get('thead > th'));
                        html += wrapContentWithTH('Credit Days', styles.get('thead > th'));
                        html += wrapContentWithTH('Security Type', styles.get('thead > th'));
                        html += wrapContentWithTH('Segment', styles.get('thead > th'));
                        html += wrapContentWithTH('Type', styles.get('thead > th'));
                        html += wrapContentWithTH('Aircraft', styles.get('thead > th'));
                        html += wrapContentWithTH('Density',styles.get('thead > th'));
                    html += '</tr>';
                html += '</thead>';
                html += '<tbody>';
                    for(CustomerWrapper customer : tenderEmailDataHolder.customerList) {
                        html += '<tr '+ styles.get('tbody > tr') + '>';
                            html += wrapContentWithTD(customer.customerName);
                            html += wrapContentWithTD(customer.grn);
                            html += wrapContentWithTD(customer.invoiceFrequency);
                            html += wrapContentWithTD(customer.creditDays);
                            html += wrapContentWithTD(customer.securityType);
                            html += wrapContentWithTD(customer.segment);
                            html += wrapContentWithTD(customer.customerType);
                            html += wrapContentWithTD(customer.aircraft);
                        html += '</tr>';
                    }
                html += '</tbody>';
            html += '</table>';
            return html;
        }

        /**
         * @description gets negotiation instruction html
         * @param null
         * @return string
         */
        public String getNegotiationInstructionsHtml() {
            String html = '';

            html += wrapContentWithHeader('Negotiation Instructions');  
            html += '<table '+ styles.get('table') + '>';
                html += '<thead>';
                    html += '<tr '+ styles.get('thead > tr') + '>';
                        html += wrapContentWithTH('Bids In By', styles.get('thead > th'));
                        html += wrapContentWithTH('Number of Rounds', styles.get('thead > th'));
                        html += wrapContentWithTH('Last Look To Incumbent', styles.get('thead > th'));
                        html += wrapContentWithTH('Quality Of Feedback', styles.get('thead > th'));
                        html += wrapContentWithTH('Notes On Feedback', styles.get('thead > th'));
                    html += '</tr>';
                html += '</thead>';
                html += '<tbody>';
                    html += '<tr>';
                        html += wrapContentWithTD(tenderEmailDataHolder.tender.bidsInBy);
                        html += wrapContentWithTD(tenderEmailDataHolder.tender.numberOfRounds);
                        html += wrapContentWithTD(tenderEmailDataHolder.tender.lastLookToIncumbent);
                        html += wrapContentWithTD(tenderEmailDataHolder.tender.qualityOfFeedback);
                        html += wrapContentWithTD(tenderEmailDataHolder.tender.notesOnFeedback);
                    html += '</tr>';
                html += '</tbody>';
            html += '</table>';
            return html;
        }

        /**
         * @description gets locations html
         * @param null
         * @return string
         */
        public String getLocationsHtml(Id tenderId,String locationType) {
            String html = '';
            List<LineItemWrapper> lineItems = new List<LineItemWrapper>();            
            html += '<b><font size ="3"> Locations listing * - number of locations: </font><b>';
            html += '(' + (tenderEmailDataHolder.getNumberOfLocations() - tenderEmailDataHolder.getNonRepresentedLocations().size()) + ')';
            html += '<br>';
            html += '<p ' + styles.get('row1') + '"><i>* Showing only the top 50 locations in this email (refer spreadsheet attached in email for complete list)</i></p><br/>';
            for(AITM_Tender_Location__c t1: new AITM_TenderDao().getTenderLocationsWithLineItemsForInvitation(tenderId,locationType)) {         
                for(AITM_Tender_Location_Line_Item__c lineItem :t1.AITM_Tender_Location__r){
                    lineItems.add(new LineItemWrapper(lineItem));                     
                }                
            html += '<p '+ styles.get('p') + '"><b>' + 'Pricing Responsibility' + ':' + '' + '</b></p>';            
            html += getPricingResponsibility(lineItems) + '<br>';
            String title = t1.AITM_IATA_ICAO__c + ' - ' + t1.AITM_Location__r.Name;                
            html+= '<p '+ styles.get('p') + '"><b>' + title + '</b></p>';                
            html += getLocationsRequestTableHtml(lineItems) + '<br>';             
            html += getLocationsHistoryTableHtml(lineItems) + '<br>';
            lineItems.clear();                  
            }        
            return html;        }
        
        /**
         * @description gets nonrepresented location names 
         * @param null
         * @return string
         */
         public String getNonRepresentedTenderLocations(){
            String html = '';
            html += '<div ' + styles.get('green heading') + '>';
            html += '<div ' + styles.get('header') + '>';
            html += 'Non Represented Locations' + '(' + tenderEmailDataHolder.getNonRepresentedLocations().size() + ')' ;
            html += '</div>';
            html += '</div>';
            html += '<hr style ="background-color:rgb(0,128,0);height:1px;border:none">';
            for (AITM_Tender_Location__c tenderLocation:tenderEmailDataHolder.getNonRepresentedLocations()){
                 String title = tenderLocation.Name;
                 html += wrapcontentwithTD(title);
            }

            html += '<hr style ="background-color:rgb(0,128,0);height:1px;border:none">';
            return html;
         }

         /**
         * @description gets sender info
         * @param null
         * @return string
         */
         public String getUserSignatures(){
             String html = '';
             html +=  '</br>' ;
             html += '<div ';
             html += 'style = "font-weight:bold">';
             html +=  UserInfo.getFirstName() + '  ' + UserInfo.getLastName() ;
             html += '</div>';
             html += UserInfo.getOrganizationName() + '</br>';           
             html += UserInfo.getUserName() ;
             html += '</br>' + '</br>' ;
             html += '<div ';
             html += 'style = "color:rgb(128,128,128); font-size: 12px">';          
             html += '</br>' + '</br>' + '</br>';
             html += 'Email disclaimer: The information in this e-mail is confidential and may be legally privileged.It is intended solely for the addressee(s) only.Access to this e-mail by anyone else is';
             html += 'unautorised.If you are not the intended recipent,any disclosure,copying,distribution or an action taken or omitted to be taken in reliance on it,is prohibited and may be unlawful.';              
             html += 'Within bounds of law,electronic transmissions through internal and external networks  may be monitored to ensure compliance with internal policies and legitimate business purposes.';               
             html += '</br>';            
             html += '</div>';             
             return html;
        
         }
        
        /**
         * @description gets LocationManager TenderLocations
         * @param tenderLocations of type List<AITM_Tender_Location__c>
         * @return Map<String, List<AITM_Tender_Location__c>>
         */
        public Map<String, List<AITM_Tender_Location__c>> getLocationManagerTenderLocations(List<AITM_Tender_Location__c> tenderLocations) {
            Map<String, List<AITM_Tender_Location__c>> locationManagerLocations = new Map<String, List<AITM_Tender_Location__c>>();
            for(AITM_Tender_Location__c tenderLocation : tenderEmailDataHolder.tenderLocations){
                List<AITM_Tender_Location__c> lmTenderLocations = new List<AITM_Tender_Location__c>();
                for(AITM_Tender_Location__c tl : tenderEmailDataHolder.tenderLocations){
                    if(tenderLocation.AITM_Location_Manager__c == tl.AITM_Location_Manager__c){
                        lmTenderLocations.add(tl);
                    }
                }
                locationManagerLocations.put(tenderLocation.AITM_Location_Manager__c, lmTenderLocations);
            }
            return locationManagerLocations;
        }
        
        /**
         * @description gets LocationManager TenderLocations
         * @param lineItems of type List<LineItemWrapper>
         * @return string
         */
        public String getLocationsRequestTableHtml(List<LineItemWrapper> lineItems) {
            String html = '';            
            html += wrapContentWithH2('Location Tender Request');  
            html += '<table '+ styles.get('table') + '>';
                html += '<thead>';
                    html += '<tr '+ styles.get('thead > tr') + '>';
                        html += wrapContentWithTH('Customer', styles.get('thead > th'));
                        //html += wrapContentWithTH('GRN', styles.get('thead > th'));
                        html += wrapContentWithTH('Requested Volume',styles.get('thead > th'));
                        html += wrapContentWithTH('Volume (USG)', styles.get('thead > th'));
                        html += wrapContentWithTH('Start Date', styles.get('thead > th'));
                        html += wrapContentWithTH('End Date', styles.get('thead > th'));
                               
                    html += '</tr>';
                html += '</thead>';
                html += '<tbody>';
                for(LineItemWrapper lineItem : lineItems) {
                    html += '<tr>';
                        html += wrapContentWithTD(lineItem.customerName);
                        //html += wrapContentWithTD(lineItem.grn);
                        html += wrapContentWithTD((lineItem.requestedVolume != null ? lineItem.requestedVolume.format() : '') + '    '  + lineItem.Uom);
                        html += wrapContentWithTD(lineItem.volumeUSG);
                        html += wrapContentWithTD(lineItem.startDate);
                        html += wrapContentWithTD(lineItem.endDate);
                    html += '</tr>';
                }
                html += '</tbody>';
            html += '</table>';
            return html;
        }
        /**
         * @description gets pricer responsibility for each TLLI
         * @param lineItems of type List<LineItemWrapper>
         * @return string
         */
        public String getPricingResponsibility(List<LineItemWrapper> lineItems) {
                   
            List<String> pricer = new List<String>();   
            Set<String> pricingResponsibilityNames = new Set<String>();      
            for(LineItemWrapper lineItem : lineItems) {
                if(lineItem.deliveryPointValue != null) { 
                    pricingResponsibilityNames.add(lineItem.ownerName);
                }    
            } 
                pricer.addAll(pricingResponsibilityNames);  
                //pricer.sort();   
         
                String html = String.join(pricer,',');
                
                   
            return html;
        }


        /**
         * @description gets Location History Table html
         * @param lineItems of type List<AITM_Tender_Location_Line_Item__c>
         * @return string
         */
        public String getLocationsHistoryTableHtml(List<LineItemWrapper> lineItems) {
            String html = '';
            html += wrapContentWithH2('Location History'); 
            html += '<table '+ styles.get('table') + '>';
                html += '<thead>';
                    html += '<tr '+ styles.get('thead > tr') + '>';
                        html += wrapContentWithTH('Customer', styles.get('thead > th'));
                        html += wrapContentWithTH('GRN', styles.get('thead > th'));
                        html += wrapContentWithTH('Result', styles.get('thead > th'));
                        html += wrapContentWithTH('Volume (Tendered)', styles.get('thead > th'));
                        html += wrapContentWithTH('Pricing Basis', styles.get('thead > th'));
                        html += wrapContentWithTH('Description', styles.get('thead > th'));
                        html += wrapContentWithTH('Delivery Point', styles.get('thead > th'));
                        html += wrapContentWithTH('Differential', styles.get('thead > th'));
                        html += wrapContentWithTH('Currency', styles.get('thead > th'));
                        html += wrapContentWithTH('Measure', styles.get('thead > th'));
                        html += wrapContentWithTH('GP', styles.get('thead > th'));
                    html += '</tr>';
                html += '</thead>';
                html += '<tbody>';
                for(LineItemWrapper lineItem : lineItems) {
                    if(lineItem.historyLineItem != null){
                    html += '<tr>';
                        html += wrapContentWithTD(lineItem.historyCustomerName);
                        html += wrapContentWithTD(lineItem.historyGRN);
                        html += wrapContentWithTD(lineItem.historyResult);
                        html += wrapContentWithTD(lineItem.historyRequestedVolume == null ? '' : String.valueOf(lineItem.historyRequestedVolume) + ' USG');
                        html += wrapContentWithTD(lineItem.historyPricingBasis);
                        html += wrapContentWithTD(lineItem.historyPricingBasisDescription);
                        html += wrapContentWithTD(lineItem.historyDeliveryPoint);
                        html += wrapContentWithTD(String.valueOf(lineItem.historyDifferential));
                        html += wrapContentWithTD(lineItem.historyCurrencyVal == null ? '' :  lineItem.historyCurrencyVal);
                        html += wrapContentWithTD(lineItem.historyMeasure == null ? '' : lineItem.historyMeasure);
                        html += wrapContentWithTD(lineItem.historyUom == null ? '' : lineItem.historyUom);
                    html += '</tr>';
                 }
             }   

            html += '</tbody>';
            html += '</table>';
            return html;
        }
    }

    /**
     * @description customer wrapper class 
     */
    public class CustomerWrapper {
        public String customerName {get; private set;}
        public String grn {get; private set;}
        public String invoiceFrequency {get; private set;}
        public String creditDays {get; private set;}
        public String securityType {get; private set;}
        public String segment {get; private set;}
        public String customerType {get; private set;}
        public String aircraft {get; private set;}

        /**
         * @description overloaded constructor
         * @param tenderAccount of type AITM_Tender_Account__c
         */
        public CustomerWrapper (AITM_Tender_Account__c tenderAccount) {
            this.customerName = tenderAccount.AITM_Customer_Name__c;
            this.grn = tenderAccount.AITM_GRN__c;
            this.invoiceFrequency = tenderAccount.AITM_Invoice_Frequency__c;
            this.creditDays = tenderAccount.AITM_Credit_Days1__c;
            this.securityType = tenderAccount.AITM_Security_Type__c;
            this.segment = tenderAccount.AITM_Customer_Segment__c;
            this.customerType = tenderAccount.AITM_Customer_Type__c;
            this.aircraft = tenderAccount.AITM_Aircraft_Fleet__c;
        }
    }

    /**
     * @description tender wrapper class 
     */
    public class TenderWrapper {
        public Id tenderId {get; private set;}
        public Date bidsInBy {get; private set;}
        public Decimal numberOfRounds {get; private set;}
        public String lastLookToIncumbent {get; private set;}
        public String qualityOfFeedback {get; private set;}
        public String notesOnFeedback {get; private set;}
        public String airlineProfileInfo {get; private set;}
        public String tenderInfo {get; private set;}
        public String name {get; private set;}
        public Date startDate {get; private set;}
        public Date endDate {get; private set;}
        public String tenderSector {get; private set;}

        /**
         * @description overloaded constructor
         * @param tender of type AITM_Tender__c
         */
        public TenderWrapper (AITM_Tender__c tender) {
            this.tenderId = tender.Id;
            this.bidsInBy = tender.AITM_Bids_In_By__c;
            this.numberOfRounds = tender.AITM_Number_Of_Rounds__c;
            this.lastLookToIncumbent = tender.AITM_Last_Look_To_Incumbent__c;
            this.qualityOfFeedback = tender.AITM_Quality_Of_Feedback__c;
            this.notesOnFeedback = tender.AITM_Notes_On_Feedback__c;
            this.airlineProfileInfo = tender.AITM_Arl_Prfl_And_Tndr_Information__c;
            this.tenderInfo = tender.AITM_Tender_Information__c;
            this.startDate = tender.AITM_Start_Date__c;
            this.endDate = tender.AITM_End_Date__c;
            this.name = tender.Name;
            this.tenderSector = tender.AITM_Tender_Sector__c;
        }
    }

    /**
     * @description line item wrapper class 
     */
    public class LineItemWrapper {
        public Id tenderLocationId {get; private set;}
        public String customerName {get; private set;}
       // public String grn {get; private set;}
        public Decimal requestedVolume {get; private set;}
        public Decimal volumeUSG {get; private set;}
        public Date startDate {get; private set;}
        public Date endDate {get; private set;}
        //public String result {get; private set;}
        public Decimal volumeTendered {get; private set;}
        public String pricingBasis {get; private set;}
        public String pricingBasisDescription {get; private set;} 
        //public String deliveryPoint {get; private set;} 
        public Decimal differential {get; private set;}
        public String currencyVal {get; private set;}
        public String measure {get; private set;}
        public String Uom {get; private set;}
        public String historyCustomerName {get; private set;}
        public String historyGRN {get; private set;}
        public Decimal historyRequestedVolume {get; private set;}
        public String historyResult {get; private set;}
        public String historyPricingBasis {get; private set;}
        public String historyPricingBasisDescription {get; private set;}
        public String historyDeliveryPoint {get; private set;} 
        public Decimal historyDifferential {get; private set;}
        public String historyCurrencyVal {get; private set;}
        public String historyMeasure {get; private set;}
        public String historyUom {get; private set;}       
        public String deliveryPointValue{get;private set;}
        //public String tenderSector{get;private set;}
        //public String tenderCAPricerName{get;private set;}
        //public String tenderCAPricingResponsibility{get;private set;}
        //public String tenderGAPricerName{get;private set;}
        //public String tenderGAPricingResponsibility{get;private set;}
        //public String deliveryPointLMId {get;private set;}
        //public String deliveryPointLMName{get;private set;}
        //public String noDefaultPricer {get;private set;}
        public String ownerName{get;private set;}
        public String historyLineItem{get;private set;}

        

        /**
         * @description overloaded constructor
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         */
        public LineItemWrapper (AITM_Tender_Location_Line_Item__c lineItem) {
            this.tenderLocationId = lineItem.AITM_Tender_Location__c;
            this.customerName = lineItem.AITM_Account__r.Name;
           // this.grn = lineItem.AITM_Account__r.AITM_GRN__c;
            this.requestedVolume = lineItem.AITM_Volume__c;
            this.volumeUSG = lineItem.AITM_Requested_Volume_USG__c;
            this.startDate = lineItem.AITM_Start_Date__c;
            this.endDate = lineItem.AITM_End_Date__c;
            //this.result = lineItem.AITM_Tender_Result__c;
            this.volumeTendered = lineItem.AITM_Offered_Volume__c;
            this.pricingBasis = lineItem.AITM_Pricing_Basis__r.Name;
            this.pricingBasisDescription = lineItem.AITM_Pricing_Basis_Description__c;
            //this.deliveryPoint = lineItem.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c;
            this.differential = lineItem.AITM_Offered_Differential__c;
            this.currencyVal = lineItem.AITM_Currency__c;
            this.measure = lineItem.AITM_Unit_Of_Measure__c;
            this.Uom = lineItem.AITM_Requested_Volume_UoM__c;
            this.historyCustomerName = lineItem.AITM_History_Line_Item__r.AITM_Account__r.Name;
            this.historyGRN = lineItem.AITM_History_Line_Item__r.AITM_Account__r.AITM_GRN__c;
            this.historyRequestedVolume = lineItem.AITM_History_Line_Item__r.AITM_Volume__c;
            this.historyPricingBasis = lineItem.AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name;
            this.historyPricingBasisDescription = lineItem.AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c;
            this.historyDeliveryPoint = lineItem.AITM_History_Line_Item__r.AITM_Delivery_Point_Info__c;
            this.historyDifferential = lineItem.AITM_History_Line_Item__r.AITM_Offered_Differential__c;
            this.historyCurrencyVal = lineItem.AITM_History_Line_Item__r.AITM_Currency__c;
            this.historyMeasure = lineItem.AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c;
            this.historyUom = lineItem.AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c;
            this.historyResult = lineItem.AITM_History_Line_Item__r.AITM_Tender_Result__c;          
            //this.tenderCAPricerName = lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name;
            //this.tenderCAPricingResponsibility = lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c;
            //this.tenderGAPricerName = lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name;
            //this.tenderGAPricingResponsibility = lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c;
            //this.deliveryPointLMId = lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c;
            //this.deliveryPointLMName = lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name;   
            //this.noDefaultPricer = lineItem.AITM_Pricer_No_Default_Delivery_Points__r.Name;         
            this.deliveryPointValue = lineItem.AITM_Location_Delivery_Point__c;
            //this.tenderSector = lineItem.AITM_Tender__r.AITM_Tender_Sector__c;
            this.ownerName = lineItem.Owner.Name;
            this.historyLineItem = lineItem.AITM_History_Line_Item__c;
        
        }
    }
}