/***************************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            IBM
 * @description      Controller class is called when GenerateContractEmail button was clicked. It attaches Tender Contract PDF (email attachments).

 * history
 * 01/December/2017  George       Created
 * 01/March/2018     srnandan     Modified - AR-2591 Added constant "TITLE_MSDS_PREFIX_LEGALFILE", modified method "addEmailAttachments" 
 *                                to include msds pdf attachments for send contract functionality 
 * 05/Sep/2018       Saravana     Modified - AR-4161 build method to include Account Manager in CC	
 * 18/February/2019  srnandan     Modified - AR-2745  addEmailAttachments to include appendix4 attachment 
 ***************************************************************************************************/
public with sharing class AITM_GenerateContractEmailBtnCntrl {

    public static final String TITLE_PREFIX_PDF_LEGALFILE =  Label.AITM_NewOfferPDFLegalFilePrefix;
    public static final String TITLE_PREFIX_PDF_OFFER =  Label.AITM_NewOfferPDFOfferPrefix;
    public static final String TITLE_PREFIX_PDF_APPENDIX = Label.AITM_NewContractPDFAppendix4Prefix;
    public static final List<String> TITLE_MSDS_PREFIX_LEGALFILE = new List<String>{Label.AITM_NewOfferPDFMSDS2101FilePrefix,Label.AITM_NewOfferPDFMSDS2102FilePrefix,Label.AITM_NewOfferPDFMSDS2105FilePrefix};
    public static final String TITLE_PREFIX_PDF_CONTRACT =  Label.AITM_NewContractPDFContractPrefix;
    public static final String TITLE_PREFIX_PDF_LOCATION_AGREEMENT =  Label.AITM_ContractLocationAgreement;
    public static final String TITLE_PREFIX_PDF_CONTRACT_FFSA = Label.AITM_ContractFFSA;

    /*
        @description:  returns error message based on OfferEmailValidity for the tenderid passed
        @param : tenderId of type Id
        @return: String errorMessage
    */
    public @AuraEnabled static String getTenderAvailableForEmailSending(Id tenderId) {
        String errorMessage = new TenderActiveRecord(tenderId).getOfferEmailValidityErrorMessage();
        return errorMessage;  
    }

    /*
        @description: updates the tender contract the field AITM_Contract_Is_Sent_To_A_Customer__c to true 
        @param : tenderId of type Id
        @return: void
    */
    public @AuraEnabled static void updateTenderAfterEmailSent(Id tenderId) {
        TenderActiveRecord activeRecord = new TenderActiveRecord(tenderId);
        activeRecord.updateTenderContractSent();
    }

    
    /*
        @description: builds the tender offers email content with attachments 
        @param : tenderId of type Id
        @return: AITM_EmailGeneratorController.EmailDTO class object
    */
    public @AuraEnabled static AITM_EmailGeneratorController.EmailDTO getEmail(Id tenderId) {
        TenderOffersEmailBuilder emailBuilder = new TenderOffersEmailBuilder(tenderId);
        return emailBuilder.build();
    }

    public class TenderActiveRecord {
        private AITM_Tender__c tender;
        private final String DEBRIEF_STAGE = 'Debrief';

        /**
         * @description overloaded constructor 
         * @param  tenderId of type Id
        */
        public TenderActiveRecord(Id tenderId) {
            tender = new AITM_TenderDao().getTender(tenderId);
        }

        /**
         * @description returns errormessage string based on tender stage and contract attachment generated
         * @param  null
         * @return string
        */
        public String getOfferEmailValidityErrorMessage() {
            String errorMessage = null;
            
            if (tender.AITM_Stage__c != DEBRIEF_STAGE) {
                errorMessage = Label.AITM_GeneratedOfferButtonNotDebriefStage;
            }else if (!isAttachmentGenerated(TITLE_PREFIX_PDF_CONTRACT) && !isAttachmentGenerated(TITLE_PREFIX_PDF_LOCATION_AGREEMENT)
                && !isAttachmentGenerated(TITLE_PREFIX_PDF_CONTRACT_FFSA)) {
                    
                errorMessage = Label.AITM_ContractIsNotGenerated;   
            }
            return errorMessage; 
        }

        /**
         * @description updates field AITM_Contract_Is_Sent_To_A_Customer__c to true of tender
         * @param  null
         * @return void
        */
        public void updateTenderContractSent() {
            tender.AITM_Contract_Is_Sent_To_A_Customer__c = true;
            update tender; 
        }

        /**
         * @description returns true if titleprefix is not empty else false
         * @param  titlePrefix of type string
         * @return boolean
        */
        public Boolean isAttachmentGenerated(String titlePrefix) {
            TenderOffersEmailBuilder emailBuilder = new TenderOffersEmailBuilder(tender.Id);
            return (emailBuilder.getAttachmentsByTitlePrefix(titlePrefix).isEmpty()) ? false : true;
        }
    }

    public class TenderOffersEmailBuilder {
        private AITM_Tender__c tender;
        private AITM_TenderDao tendersDao;

        /**
         * @description overloaded constructor
         * @param  tenderId of type Id
        */
        public TenderOffersEmailBuilder(Id tenderId) {
            tender = new AITM_TenderDao().getTender(tenderId);
            tendersDao = new AITM_TenderDao();
        }

        /**
         * @description builds the emaildto object
         * @param  null
         * @return AITM_EmailGeneratorController.EmailDTO class object
        */
        public AITM_EmailGeneratorController.EmailDTO build() {
            AITM_EmailGeneratorController.EmailDTOFactory emailDTOFactory = new AITM_EmailGeneratorController.EmailDTOFactory();
            if (String.isNotBlank(tender.AITM_Email__c)) {
                emailDTOFactory.addEmailAddress(true, tender.AITM_Email__c);
            }
            emailDTOFactory.addEmailAddress(false, tender.Owner.Email);
            Date startDate = tender.AITM_Start_Date__c;
            Date endDate = tender.AITM_End_Date__c;
            emailDTOFactory.addSubject('Air BP Contract: ' + tender.Name + ' (' + startDate.format() + ' - ' + endDate.format() + ') ' );
            emailDTOFactory.addEmailBody(true, '', '');
            addEmailAttachments(emailDTOFactory);
            return emailDTOFactory.create();
        }

        /**
         * @description builds the emaildto object
         * @param  null
         * @return AITM_EmailGeneratorController.EmailDTO class object
        */
        public void addEmailAttachments(AITM_EmailGeneratorController.EmailDTOFactory emailDTOFactory) {
            List<ContentVersion> gtcOffers = getAttachmentsByTitlePrefix(AITM_GenerateContractEmailBtnCntrl.TITLE_PREFIX_PDF_LEGALFILE);
            //List<ContentVersion> contracts = getAttachmentsByTitlePrefix(AITM_GenerateContractEmailBtnCntrl.TITLE_PREFIX_PDF_CONTRACT);
            
            Boolean isLatestTenderDocumentIsContract = tendersDao.isLatestTenderDocumentIsContract(tender.Id);
            List<ContentVersion> contracts = tendersDao.getLatestTenderDocumentContractInPdf(tender.Id, isLatestTenderDocumentIsContract);
  
            Map<String, ContentVersion> nameToAttachment = new Map<String, ContentVersion>();

            //loop through list of contracts and adds attachment to emailDTOFactory
            for (ContentVersion contract : contracts) {
                if(nameToAttachment.isEmpty()){
                    nameToAttachment.put(contract.PathOnClient, contract);
                    emailDTOFactory.addEmailAttachment(contract);
                }else{
                    if(nameToAttachment.get(contract.PathOnClient) == null ){
                        emailDTOFactory.addEmailAttachment(contract);
                    }
                }
            }
			
			//Appendix 4 Attachments
			/*List<ContentVersion> appendixContracts = getAttachmentsByTitlePrefix(AITM_GenerateContractEmailBtnCntrl.TITLE_PREFIX_PDF_APPENDIX);
            if(!appendixContracts.isEmpty()) {
                for (ContentVersion appendixContract : appendixContracts) {
                	if(nameToAttachment.isEmpty()){
                   		nameToAttachment.put(appendixContract.PathOnClient, appendixContract);
                    	emailDTOFactory.addEmailAttachment(appendixContract);
                	}else{
                    	if(nameToAttachment.get(appendixContract.PathOnClient) == null ){
                        	emailDTOFactory.addEmailAttachment(appendixContract);
                    	}
                	}    
                }
            }*/
            
            //loop through list of gtcoffers and adds attachment to emailDTOFactory
            if(isLatestTenderDocumentIsContract){
                for (ContentVersion gtcOffer : gtcOffers) {
                    emailDTOFactory.addEmailAttachment(gtcOffer);
                }
            }

            List<ContentVersion> msdsOffers = new List<ContentVersion>();
            for(String filePrefix : TITLE_MSDS_PREFIX_LEGALFILE) {
                if(getAttachmentsByTitlePrefix(filePrefix) != null) {
                    msdsOffers.addAll(getAttachmentsByTitlePrefix(filePrefix));
                }
            }

            //loop through msdsoffers and adds attachment to emailDTOFactory
            for (ContentVersion msdsOffer : msdsOffers) {
                emailDTOFactory.addEmailAttachment(msdsOffer);
            }
        }

        /**
         * @description returns list of contentversion documents for a given titleprefix
         * @param  titlePrefix of type string
         * @return List of ContentVersion
        */
        public List<ContentVersion> getAttachmentsByTitlePrefix(String titlePrefix){
            return tendersDao.getTenderDocuments(tender.Id, titlePrefix);
        }
    }
}