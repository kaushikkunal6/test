/*************************************************************************
 * @author         srnandan
 * @date           05/June/2019filterCustomerOptions
 * @group          AirBP
 * @description    To generate Tender Conga Offer PDF (attachments) and show filter options before generate.

 * history
 * 05/June/2019     srnandan       Created
 * 14/Aug/2019      srnandan       Modified filter soql field Name to APXTConga4__Name__c
 * 27/Aug/2019      srnandan       Modified Removed without sharing keyword and added with sharing keyword
 * 06/November/2019 srnandan       Modified constructor AccountOption to include new variable assignment oldTaxFeeFlag
 * 12/December/2019 srnandan       Modified add property labpUrl to track site url based on community site
 * 20/May/2020      Kunal          Modified Fixed locations filters issue for Conga specific
 * 11/Nov/2020      Shweta         Modified Updated it to without sharing for 5 Digit GRN hiding
 **************************************************************************/
public without sharing class AITM_TenderCongaOfferContainerController {
    
    /**
     * @description returns true if legaldocument not generated else false
     * @param  null
     * @return boolean
     */
    public static @AuraEnabled List<AITM_RelatedRecordsHolderController.FilterOption> getFilterOptions(Id tenderId) {
        return AITM_RelatedTenderLocationsHolderCntrl.getFilterOptionsForConga(tenderId);
    }
    
    /**
     * @description returns true if legaldocument not generated else false
     * @param  null
     * @return String
     */
    public static @AuraEnabled String getFilterQueryDetails(String filterName, String tenderId, String selectedCustomerId, String tenderName, String selectedCustomerName, String selectedAffiliate, String bspokeTemplate, Boolean reseller, Boolean oldTaxFeeFlag, String offerSelection, String grnNumber,Boolean isWordDoc) {
        String queryCriteria;
        String congaURL2 = System.Label.AITM_CongaButtonURLPatch2;
        String filePrefix = System.Label.AITM_NewOfferPDFOfferPrefix;
        String filePrefixFFSA = System.Label.AITM_FFSA;
        String filePrefixLA = System.Label.AITM_LocationAgreement;
        String labpNetworkId = getLABPCommunityId();	
        Boolean isLABPConga = modifyLABPCongaURL();
        tenderName = removeSpecialCharacters(tenderName);
        selectedCustomerName = removeSpecialCharacters(selectedCustomerName);
        String fileName = filePrefix + Date.today().format().replaceAll('/','_') + tenderName + '_' + grnNumber + '-' + selectedCustomerName;
        String fileNameShort = fileName.replaceAll(':', '_');
        String fileNameFFSA = filePrefixFFSA + ' ' + DateTime.now().formatGMT('dd/MM/yyyy').replaceAll('/','-') + '-' + grnNumber + '-' + selectedCustomerName;
        String fileNameShortFFSA = fileNameFFSA.replaceAll(':', '_');
        String fileNameLA = filePrefixLA + ' ' + DateTime.now().formatGMT('dd/MM/yyyy').replaceAll('/','-') + '-' + grnNumber + '-' + selectedCustomerName;
        String fileNameShortLA = fileNameLA.replaceAll(':', '_');
        String appendixFileName = 'Offer Appendix4' + Date.today().format().replaceAll('/','_') + tenderName + '_' + grnNumber + '-' + selectedCustomerName;
        String classificationFilter = getCongaTemplates(fileNameShort, fileNameShortFFSA, fileNameShortLA, appendixFileName, bspokeTemplate, reseller, oldTaxFeeFlag, offerSelection);
        String templateGroup = tenderId + congaURL2 + classificationFilter + '&Qvar0Id='+ System.Label.AITM_CongaOfferLineItemAffiliates +'?pv0='+tenderId+'~pv1='+ selectedAffiliate +'~pv2='+ selectedCustomerId +'&Qvar0format=21000&QueryId=[TendOfferCustDet]'+System.Label.AITM_CongaCustomerDetail+'?pv0='+ tenderId +'~pv1='+ selectedCustomerId +',[LineItemsPriced]';
        if(filterName == 'All Locations') {
            if(oldTaxFeeFlag) {
                queryCriteria = System.Label.AITM_CongaLineItemsPriced +'?pv0='+tenderId+'~pv1='+ AITM_LocationsDao.STATUS_PRICED +'~pv2='+ AITM_LocationsDao.STATUS_NOT_REPRESENTED +'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +'';               
            } else {
                queryCriteria = System.Label.AITM_CongaLineItemsPricedWithTaxes +'?pv0='+tenderId+'~pv1='+ AITM_LocationsDao.STATUS_PRICED +'~pv2='+ AITM_LocationsDao.STATUS_NOT_REPRESENTED +'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +'';               
            }
        } else if(filterName == 'Locations with Priced' || filterName == 'Represented Locations') {
            if(oldTaxFeeFlag) {
                queryCriteria = System.Label.AITM_CongaLineItemsPriced +'?pv0='+tenderId+'~pv1='+ AITM_LocationsDao.STATUS_PRICED +'~pv2='+ AITM_LocationsDao.STATUS_PRICED +'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemPricedServices +'';
            } else {
                queryCriteria = System.Label.AITM_CongaLineItemsPricedWithTaxes +'?pv0='+tenderId+'~pv1='+ AITM_LocationsDao.STATUS_PRICED +'~pv2='+ AITM_LocationsDao.STATUS_PRICED +'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemPricedServices +'';
            }
        } else if(filterName == 'Non-represented Locations') {
            if(oldTaxFeeFlag) {
                queryCriteria = System.Label.AITM_CongaLineItemsPriced +'?pv0='+tenderId+'~pv1='+ AITM_LocationsDao.STATUS_NOT_REPRESENTED +'~pv2='+ AITM_LocationsDao.STATUS_NOT_REPRESENTED +'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +'';             
            } else {
                queryCriteria = System.Label.AITM_CongaLineItemsPricedWithTaxes +'?pv0='+tenderId+'~pv1='+ AITM_LocationsDao.STATUS_NOT_REPRESENTED +'~pv2='+ AITM_LocationsDao.STATUS_NOT_REPRESENTED +'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +'';             
            }
        } else if(filterName == 'Locations with Quotes') {
            if(oldTaxFeeFlag) {
              queryCriteria = System.Label.AITM_CongaLocationsQuotes + '?pv0='+tenderId+'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +'';
            } else {
                queryCriteria = System.Label.AITM_CongaLocationsQuotesTaxes + '?pv0='+tenderId+'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +'';
            }
        } else if(filterName == 'Locations with Volumes') {
            if(oldTaxFeeFlag) {
              queryCriteria = System.Label.AITM_CongaLocationsVolumes +'?pv0='+tenderId+'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +''; 
            } else {
              queryCriteria = System.Label.AITM_CongaLocationsVolumesTaxes +'?pv0='+tenderId+'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +''; 
            }
        } else if(filterName == 'Locations with AdHoc Volume') {
            if(oldTaxFeeFlag) {
              queryCriteria = System.Label.AITM_CongaAdhocVolume +'?pv0='+tenderId+'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +''; 
            } else {
              queryCriteria = System.Label.AITM_CongaAdhocVolumeTaxes +'?pv0='+tenderId+'~pv3={Qvar0},[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +''; 
            }
        } else {
            if(oldTaxFeeFlag) { 
              queryCriteria = System.Label.AITM_CongaLocationManager +'?pv0='+tenderId+'~pv1='+ filterName + ',[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +'';
            } else {
              queryCriteria = System.Label.AITM_CongaLocationManagerTaxes +'?pv0='+tenderId+'~pv1='+ filterName + ',[LineItemServices]'+ System.Label.AITM_CongaLineItemServices +'';  
            }
        } 
        String returnString = templateGroup + queryCriteria +',[Affiliates]'+ System.Label.AITM_CongaOfferAffiliate +'?pv0='+ tenderId +'~pv1='+ selectedAffiliate +'&APDF=0&DS7=13&Qmode=SalesforceFile&SC0=1&SC1=SalesforceFile';
        if(!isWordDoc){
            if(isLABPConga){
                return returnString + '&DefaultPDF=1&returnpath=/labptendering/' + tenderId + '&ContentNetworkId=' + labpNetworkId + '&contentShareType=V or &contentVisibility=AllUsers&ds7=401';
            } else{
                return returnString + '&DefaultPDF=1';
            }
        }else{
            if(isLABPConga){
                return returnString + '&DefaultPDF=0&returnpath=/labptendering/' + tenderId + '&ContentNetworkId=' + labpNetworkId + '&contentShareType=V or &contentVisibility=AllUsers&ds7=401';
            } else{
                return returnString + '&DefaultPDF=0';
            }
        }
    }
    
    /**
     * @description - remove special characters
     * @param tenderName of type String
     * @return String
     */
    private static String removeSpecialCharacters(String tenderName) {
        String plainText = tenderName.replaceAll('[^a-zA-Z0-9\\s+]', '');
        return plainText;
    }

    /**
     * @description - get conga template details
     * @param fileNameShort of type String
     * @param appendixFileName of type String
     * @param selectBSpoke of type String
     * @return String
     */
    private static String getCongaTemplates(String fileNameShort, String fileNameShortFFSA, String fileNameShortLA, String appendixFileName, String selectBSpoke, Boolean resellerFlag, Boolean oldTaxFeeFlag, String offerSelection) {
        String classificationFilter = '';
        String congaAppendix4 = System.Label.AITM_CongaAppendix4Template;
        String congaNonReseller = System.Label.AITM_CongaNonResellerTemplate;
        String congaReseller = System.Label.AITM_CongaResellerTemplate;
        String congaNonResellerTaxes = System.Label.AITM_CongaNonResellerTemplateTaxes;
        String congaResellerTaxes = System.Label.AITM_CongaResellerTemplateTaxes;
        String templateReseller = (oldTaxFeeFlag ? congaReseller : congaResellerTaxes);
        String templateNonReseller = (oldTaxFeeFlag ? congaNonReseller : congaNonResellerTaxes);
        String congaFFSA = System.Label.AITM_CongaFFSA;
        String locationAgreement = System.Label.AITM_CongaLocationAgreement;
        String locationAgreementTaxes = System.Label.AITM_CongaLocationAgreementTaxes;
        String congaLocationAgreement = (oldTaxFeeFlag ? locationAgreement : locationAgreementTaxes);

        if (fileNameShort != null && fileNameShort.length() > 80) {
            fileNameShort = fileNameShort.substring(0,79);
        }
        if(appendixFileName != null && appendixFileName.length() > 80){
            appendixFileName = appendixFileName.substring(0,79);
        }
        if (fileNameShortFFSA != null && fileNameShortFFSA.length() > 80) {
            fileNameShortFFSA = fileNameShortFFSA.substring(0,79);
        }
        if (fileNameShortLA != null && fileNameShortLA.length() > 80) {
            fileNameShortLA = fileNameShortLA.substring(0,79);
        }

        if(offerSelection == '2') {
            classificationFilter = '['+ fileNameShortFFSA + ']'+ congaFFSA; //'FFSA';                                
        }else if(offerSelection == '3') {
            classificationFilter = '['+ fileNameShortLA + ']'+ congaLocationAgreement; //'Location Agreement';                                
        }else if(String.isEmpty(selectBSpoke)) {
            if(resellerFlag) {
                classificationFilter = '['+ fileNameShort + ']'+ templateReseller+',['+ appendixFileName +']'+congaAppendix4; //'Reseller';                  
            } else {
                classificationFilter = '['+ fileNameShort + ']'+ templateNonReseller; //'NonReseller';                                
            }       
        } else {
            classificationFilter = '['+ fileNameShort + ']'+selectBSpoke; //'BSpoke Template';          
            if(resellerFlag) {
                classificationFilter = classificationFilter + ',['+ appendixFileName +']' + congaAppendix4; //BSpoke Template and Reseller
            }
        }
        return classificationFilter;
    }
    
    /**
     * @description get filter options to show BESPOKE and non Bespoke
     * @param tenderId of type Id
     * @return void
     */
    public static @AuraEnabled void createOfferLegalDocument(Id tenderId, Boolean isWordDoc) {
       if (AITM_BaseUtils.legalDocumentNotGenerated(tenderId)) {  
           if(isWordDoc){
               StaticResource genericLegalDocumentResource = AITM_BaseUtils.getGenericLegalDocumentResourceInWord();
               ContentVersion legalOffer = AITM_BaseUtils.createContentVersion(genericLegalDocumentResource.Body, Label.AITM_NewOfferPDFLegalFilePrefix + '.docx');
               AITM_BaseUtils.createChatterPostToRelate(Label.AITM_NewOfferPDFLegalChatterText, tenderId, legalOffer.Id);
           }else{
               StaticResource genericLegalDocumentResource = AITM_BaseUtils.getGenericLegalDocumentResource();
               ContentVersion legalOffer = AITM_BaseUtils.createContentVersion(genericLegalDocumentResource.Body, Label.AITM_NewOfferPDFLegalFilePrefix + '.pdf');
               AITM_BaseUtils.createChatterPostToRelate(Label.AITM_NewOfferPDFLegalChatterText, tenderId, legalOffer.Id);
           }
           List<StaticResource> msdsLegalDocumentResource = AITM_BaseUtils.getMSDSLegalDocumentResource();
           List<ContentVersion> msdsLegalOfferList = AITM_BaseUtils.createContentVersion(msdsLegalDocumentResource, AITM_BaseUtils.MAP_NEWOFFER_MSDS_FILE_STATIC_RESOURCE);
           AITM_BaseUtils.createChatterPostToRelate(Label.AITM_NewOfferPDFLegalChatterText, tenderId, msdsLegalOfferList);
       }          
    }
    
    /**
     * @description get LABP Tendering CommunityId
     * @param null
     * @return networkId of type String
     */
    public static @AuraEnabled String getLABPCommunityId() {
        string networkId = AITM_BaseUtils.getLABPCommunityId();
        return networkId;
    }
    
    /**
     * @description - remove special characters
     * @param tenderName of type String
     * @return String
     */
    private static Boolean modifyLABPCongaURL() {
        Boolean isLABPConga = AITM_BaseUtils.checkRunningUserIsLABP();
        return isLABPConga;
    }
    
    public static @AuraEnabled String check(Id tenderId, String fileName) {
       List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocument.Title, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: tenderId AND ContentDocument.Title =:fileName +'.pdf']; 
       if (contentDocumentLinks.size() < 1) return 'INPROGRESS';
       return 'DONE';
    }
    
    /**
     * @description get filter options to show BESPOKE and non Bespoke
     * @param tenderId of type Id
     * @return options
     */
    public static @AuraEnabled List<AccountOption> getFilterCustomerOptions(Id tenderId) {
        List<AccountOption> options = new List<AccountOption>();
        for (AITM_Tender_Account__c tenderAccount : new AITM_AccountDao.TenderAccountDao().getTenderAccountForTender(tenderId)) {
            if(tenderAccount.AITM_Account__r.AITM_Bespoke_Offer_Template__c != null) {
                options.add(new AccountOption(tenderAccount, 'BESPOKE'));    
            }            
            else {
                options.add(new AccountOption(tenderAccount));
            }
        }
        return options;
    }
    
    /**
     * @description wrapper class which stores information of tender customer and bspoke template
     */
    public inherited sharing class AccountOption {
        public @AuraEnabled Id tenderAccountId;
        public @AuraEnabled Id accountId;
        public @AuraEnabled String name;
        public @AuraEnabled Boolean reseller;
        public @AuraEnabled String tenderName;
        public @AuraEnabled String bSpokeTemplate;
        public @AuraEnabled Boolean oldTaxFeeFlag;
        public @AuraEnabled String labpUrl;
        public @AuraEnabled String grn;
        private Set<String> resellerSet = new Set<String>();

        /**
         * @description overloaded constructor
         * @param tenderAccount of type AITM_Tender_Account__c
         */
        public AccountOption(AITM_Tender_Account__c tenderAccount) {
            this.resellerSet.add('CA Reseller');
            this.resellerSet.add('GA Reseller');
            this.tenderAccountId = tenderAccount.Id;
            this.accountId = tenderAccount.AITM_Account__c;
            this.name = tenderAccount.AITM_Account__r.Name;
            this.reseller = (resellerSet.contains(tenderAccount.AITM_Account_Classification__c) ? true : false);
            this.tenderName = tenderAccount.AITM_Tender__r.Name;
            this.bSpokeTemplate = '';
            this.grn = tenderAccount.AITM_Account__r.AITM_GRN__c;
            this.oldTaxFeeFlag = tenderAccount.AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c;
            this.labpUrl = (AITM_BaseUtils.checkRunningUserIsLABP()?AITM_BaseUtils.getLABPURL():'');
        }
        
        /**
         * @description overloaded constructor
         * @param tenderAccount of type AITM_Tender_Account__c
         * @param bspoke of type String
         */
        public AccountOption(AITM_Tender_Account__c tenderAccount, String bspoke) {
            this.resellerSet.add('CA Reseller');
            this.resellerSet.add('GA Reseller');
            this.tenderAccountId = tenderAccount.Id;
            this.accountId = tenderAccount.AITM_Account__c;
            this.name = tenderAccount.AITM_Account__r.Name + ' ' + bspoke;
            this.reseller = (resellerSet.contains(tenderAccount.AITM_Account_Classification__c) ? true : false);
            this.tenderName = tenderAccount.AITM_Tender__r.Name;
            this.grn = tenderAccount.AITM_Account__r.AITM_GRN__c;
            this.bSpokeTemplate = getCongaBSpokeTemplateIdWithFeesCheck(tenderAccount.AITM_Account__r.AITM_Bespoke_Offer_Template__c, tenderAccount.AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c);
            this.oldTaxFeeFlag = tenderAccount.AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c;
            this.labpUrl = (AITM_BaseUtils.checkRunningUserIsLABP()?AITM_BaseUtils.getLABPURL():'');
        }
        
        /**
         * @description returns conga templateid for a specific bspoke template
         * @param bspoke of type String
		 * @param isTenderOld
         * @return String
         */
		public String getCongaBSpokeTemplateIdWithFeesCheck(String bspoke, Boolean isTenderOld) {
            String bspokeId = '';
            bspoke = isTenderOld ? bspoke : bspoke + 'Taxes';
            try{
                bspokeId = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c =:bspoke LIMIT 1].Id;
            }catch(Exception ex) {
                bspokeId = '';
            }
            return bspokeId;
        }
        
        /**
         * @description returns conga templateid for a specific bspoke template
         * @param bspoke of type String
         * @return String
         */
        public String getCongaBSpokeTemplateId(String bspoke) {
            String bspokeId = '';
            try{
                bspokeId = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c =:bspoke LIMIT 1].Id;
            }catch(Exception ex) {
                bspokeId = '';            
            }
            return bspokeId;
        }
    }
    
    /**
     * @description call the batch process to delete and create new Fees records
     * @param  tenderId of type String
     * @return void
     */
    public static @AuraEnabled void generateCongaOfferWithRefresh(String tenderId) {
        AITM_DeleteTaxFeeRecordsBatch.BatchState batchState = new AITM_DeleteTaxFeeRecordsBatch.BatchState(tenderId, AITM_LocationsDao.DEFAULT_RECORD_TYPE_ID, null);
        new AITM_DeleteTaxFeeRecordsBatch.BatchFactory().executeBatch(batchState);
    }
    
    /**
     * @description process to check the batch status
     * @param  null
     * @return String
     */
    public static @AuraEnabled String checkForCongaOffer() {
        AITM_DeleteTaxFeeRecordsBatch.BatchFactory feeBatchfactory = new AITM_DeleteTaxFeeRecordsBatch.BatchFactory();
        return feeBatchfactory.check();
    }
}