/*************************************************************************
 * @author         srnandan
 * @date           05/June/2019
 * @group          AirBP
 * @description    To generate Tender Conga Contract PDF (attachments) and show filter options before generate.

 * history
 * 05/June/2019  	srnandan       Created
 * 14/Aug/2019      srnandan       Modified soql filter Name to APXTConga4__Name__c
 * 27/Aug/2019      srnandan       Modified Removed without sharing keyword and added with sharing keyword
 * 12/December/2019 srnandan       Modified to add labpUrl property for labp community
 **************************************************************************/
 public with sharing class AITM_CongaContractContainerController  {
         
    /**
     * @description get filter options to show BESPOKE and non Bespoke
     * @param tenderId of type Id
     * @return options
     */
    public static @AuraEnabled List<AccountOption> getFilterOptions(Id tenderId) {
        List<AccountOption> options = new List<AccountOption>();
        for (AITM_Tender_Account__c tenderAccount : new AITM_AccountDao.TenderAccountDao().getTenderAccountForTender(tenderId)) {
            if(tenderAccount.AITM_Account__r.AITM_Bespoke_Template__c != null) {
                options.add(new AccountOption(tenderAccount, 'BESPOKE'));    
            }            
            else {
                options.add(new AccountOption(tenderAccount));
            }
        }
        return options;
    }
     
    /**
     * @description attach Offer documents
     * @param tenderId of type String
     * @param accountId of type String
     * @return null
     */
    public static @AuraEnabled String attachOfferDocuments(String tenderId, String selectedCustomerId, String tenderName, String selectedCustomerName, String selectedAffiliate, String bspokeTemplate, Boolean reseller, String contractSelection, Boolean oldTaxFeeFlag, String grnNumber,Boolean isWordDoc) {
        String congaURL2 = System.Label.AITM_CongaButtonURLPatch2;
        String filePrefix = System.Label.AITM_NewContractPDFContractPrefix;
        String filePrefixFFSA = System.Label.AITM_ContractFFSA;
        String filePrefixLA = System.Label.AITM_ContractLocationAgreement;
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
        String appendixFileName = System.Label.AITM_NewContractPDFAppendix4Prefix + Date.today().format().replaceAll('/','_') + tenderName + '_' + grnNumber + '-' + selectedCustomerName.replaceAll(':','_');
        String classificationFilter = getCongaTemplates(fileNameShort, fileNameShortFFSA, fileNameShortLA, appendixFileName, bspokeTemplate, reseller, contractSelection, oldTaxFeeFlag);
        String templateGroup = tenderId + congaURL2 + classificationFilter + '&Qvar0Id='+ System.Label.AITM_CongaOfferLineItemAffiliates +'?pv0='+tenderId+'~pv1='+ selectedAffiliate +'~pv2='+ selectedCustomerId +'&Qvar0format=21000&QueryId=[TendOfferCustDet]'+System.Label.AITM_CongaCustomerDetail+'?pv0='+ tenderId +'~pv1='+ selectedCustomerId +',[LineItemsContract]';
        String queryCriteria;
        
        if(oldTaxFeeFlag) {
            queryCriteria = System.Label.AITM_CongaContractLineItems +'?pv0='+tenderId+'~pv1={Qvar0},[LineItemContractSev]'+ System.Label.AITM_CongaContractLineItemServices +'';               
        } else {
            queryCriteria = System.Label.AITM_CongaContractLineItemsTaxes +'?pv0='+tenderId+'~pv1={Qvar0},[LineItemContractSev]'+ System.Label.AITM_CongaContractLineItemServices +'';               
        }
        
        String returnString = templateGroup + queryCriteria +',[Affiliates]'+ System.Label.AITM_CongaOfferAffiliate +'?pv0='+ tenderId +'~pv1='+ selectedAffiliate +'&APDF=0&DS7=13&Qmode=SalesforceFile&SC0=1&SC1=SalesforceFile';
       
        if(!isWordDoc){
            if(isLABPConga){
                return returnString + '&DefaultPDF=1&returnpath=/labptendering/' + tenderId + '&ContentNetworkId=' + labpNetworkId + '&contentShareType=I or &contentVisibility=AllUsers&ds7=401';
            } else{
                return returnString + '&DefaultPDF=1';
            }
        }else{
            if(isLABPConga){
                return returnString + '&DefaultPDF=0&returnpath=/labptendering/' + tenderId + '&ContentNetworkId=' + labpNetworkId + '&contentShareType=I or &contentVisibility=AllUsers&ds7=401';
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
     * @description get LABP Tendering CommunityId
     * @param null
     * @return networkId of type String
     */
    public static @AuraEnabled String getLABPCommunityId() {
        string networkId = AITM_BaseUtils.getLABPCommunityId();
        return networkId;
    }
	
    /**
     * @description - Check user is LABP or not
     * @param null
     * @return isLABPConga of type Boolean
     */
    private static Boolean modifyLABPCongaURL() {
        Boolean isLABPConga = AITM_BaseUtils.checkRunningUserIsLABP();
        return isLABPConga;
    }

    /**
     * @description - get conga template details
     * @param fileNameShort of type String
     * @param appendixFileName of type String
     * @param selectBSpoke of type String
     * @return String
     */
    private static String getCongaTemplates(String fileNameShort, String fileNameShortFFSA, String fileNameShortLA, String appendixFileName, String selectBSpoke, Boolean resellerFlag, String contractSelection, Boolean oldTaxFeeFlag) {
        String classificationFilter = '';
        String congaAppendix4 = System.Label.AITM_CongaContractAppendix4Template;
        String congaNonReseller = System.Label.AITM_CongaContractNonResellerTemplate;
        String congaReseller = System.Label.AITM_CongaContractResellerTemplate;
        String congaNonResellerTaxes = System.Label.AITM_CongaContractNonResellerTemplateTaxes;
        String congaResellerTaxes = System.Label.AITM_CongaContractResellerTemplateTaxes;
        String templateReseller = (oldTaxFeeFlag ? congaReseller : congaResellerTaxes);
        String templateNonReseller = (oldTaxFeeFlag ? congaNonReseller : congaNonResellerTaxes);
        String congaFFSA = System.Label.AITM_CongaContractFFSA;	
        //String congaLocationAgreement = System.Label.AITM_CongaContractLocationAgreement;
        String locationAgreement = System.Label.AITM_CongaContractLocationAgreement;
        String locationAgreementTaxes = System.Label.AITM_CongaContractLocationAgreementTaxes;
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
        	
        if(contractSelection == '2') {	
            classificationFilter = '['+ fileNameShortFFSA + ']'+ congaFFSA; //'FFSA';                                	
        }else if(contractSelection == '3') {	
            classificationFilter = '['+ fileNameShortLA + ']'+ congaLocationAgreement; //'Location Agreement';                                	
        }else if(String.isEmpty(selectBSpoke)) {
            if(resellerFlag) {
                classificationFilter = '['+ fileNameShort + ']'+ templateReseller +',['+ appendixFileName +']'+congaAppendix4; //'Reseller';  	               
            } else {
                classificationFilter = '['+ fileNameShort + ']'+ templateNonReseller; //'NonReseller';  	                           
            }    	
        } else {
            classificationFilter = '['+ fileNameShort + ']'+ selectBSpoke; //'BSpoke Template';  	    
            if(resellerFlag) {
                classificationFilter = classificationFilter + ',['+ appendixFileName +']' + congaAppendix4; //BSpoke Template and Reseller
            }
        }
        
        return classificationFilter;
    }
 
    /**
     * @description inner class to store accountId and name from Tender Account
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
            this.grn = tenderAccount.AITM_Account__r.AITM_GRN__c;
            this.bSpokeTemplate = '';
            this.oldTaxFeeFlag = tenderAccount.AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c;
            this.labpUrl = (AITM_BaseUtils.checkRunningUserIsLABP()?AITM_BaseUtils.getLABPURL():'');
        }
        /**
         * @description overloaded constructor
         * @param tenderAccount of type AITM_Tender_Account__c
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
            this.bSpokeTemplate = getCongaBSpokeTemplateIdWithFeesCheck(tenderAccount.AITM_Account__r.AITM_Bespoke_Template__c, tenderAccount.AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c);
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
    public static @AuraEnabled void generateCongaContractWithRefresh(String tenderId) {
        AITM_DeleteTaxFeeRecordsBatch.BatchState batchState = new AITM_DeleteTaxFeeRecordsBatch.BatchState(tenderId, AITM_LocationsDao.TLLI_ID_RECORD_TYPE_DEBRIEF, null);
        new AITM_DeleteTaxFeeRecordsBatch.BatchFactory().executeBatch(batchState);
    }
    
    /**
     * @description process to check the batch status
     * @param  null
     * @return String
     */
    public static @AuraEnabled String checkForCongaContract() {
        AITM_DeleteTaxFeeRecordsBatch.BatchFactory feeBatchfactory = new AITM_DeleteTaxFeeRecordsBatch.BatchFactory();
        return feeBatchfactory.check();
    }
}