/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      To generate Tender Offer PDF (attachments) and update tender stage and offer sent.

 * history
 * 01/December/2017  George       Created 
 * 01/March/2018     srnandan     Modified AR-2591 - Added constant "TITLE_MSDS_PREFIX_LEGALFILE",
 *                                modified method "addEmailAttachments" to include msds pdf attachments 
 *                                for Generate offer button  functionality
 *                                added comments to each method and header of class
 * 24/August/2018    Ravi         Modified AR-3711 - commented error message in 
 * 								  getOfferEmailValidityErrorMessage method	
 * 05/Sep/2018       Saravana     Modified - AR-4161 build method to include Account Manager in CC	
 * 18/February/2019  srnandan     Modified - AR-2745  addEmailAttachments to include appendix4 attachment
 *************************************************************************************/
public with sharing class AITM_GeneratedOfferButtonController {

    /**
     * @description returns error message based on OfferEmailValidity for the tenderid passed
     * @param  tenderId of type Id
     * @return errorMessage of type string
     */
    public @AuraEnabled static String getTenderAvailableForEmailSending(Id tenderId) {
        String errorMessage = new TenderActiveRecord(tenderId).getOfferEmailValidityErrorMessage();
        return errorMessage;  
    }

    /**
     * @description updates the tender stage and offersent for the given tenderId
     * @param tenderId of type Id
     * @return void
     */
    public @AuraEnabled static void updateTenderAfterEmailSent(Id tenderId) {
        TenderActiveRecord activeRecord = new TenderActiveRecord(tenderId);
        activeRecord.updateTenderStageOfferSent();
    }

    /**
     * @description returns EmailDTO object for the given tenderId
     * @param  tenderId of type Id
     * @return AITM_EmailGeneratorController.EmailDTO class object
     */
    public @AuraEnabled static AITM_EmailGeneratorController.EmailDTO getEmail(Id tenderId) {
        TenderOffersEmailBuilder emailBuilder = new TenderOffersEmailBuilder(tenderId);
        return emailBuilder.build();
    }

    public class TenderActiveRecord {
        private AITM_Tender__c tender;
        private final String PRICED_STAGE = 'Priced';
        private final String OFFER_SENT_STAGE = 'Offer Submitted';

        /**
         * @description overloaded constructor 
         * @param  tenderId of type Id
         */
        public TenderActiveRecord(Id tenderId) {
            tender = new AITM_TenderDao().getTender(tenderId);
        }

        /**
         * @description returns error message based on OfferEmailValidity for the tenderid passed
         * @param  null
         * @return errorMessage of type string 
         */
        public String getOfferEmailValidityErrorMessage() {
            String errorMessage = null;
            if (tender.AITM_Stage__c != PRICED_STAGE) {
                errorMessage = Label.AITM_GeneratedOfferButtonNotPricedStage;
            }
            return errorMessage; 
        }

        /**
         * @description update the tender with Stage as "Offer Submitted" and OfferSentToCustomer to true
         * @param  null
         * @return void
         */
        public void updateTenderStageOfferSent() {
           /* if(getPolishAndNonPolishLocationMap().size() > 1) {
                if(tender.AITM_LABP_Offer_Sent_To_A_Customer__c) {
                    tender.AITM_Stage__c = OFFER_SENT_STAGE;
                }
            } else {
                tender.AITM_Stage__c = OFFER_SENT_STAGE;
            }*/
            tender.AITM_Stage__c = OFFER_SENT_STAGE;
            tender.AITM_Offer_Sent_To_A_Customer__c = true;
            update tender; 
        }

        /**
         * @description gets map of polish and nonpolish
         * @param  null
         * @return void
         */
        public Map<String,Boolean> getPolishAndNonPolishLocationMap() {
            AITM_Tender__c tenderData = new AITM_TenderDao().getTenderWithPricedTenderLocations(tender.Id);
            Map<String, Boolean> mapPolishAndNonPolishLocations = new Map<String, Boolean>();
            for(AITM_Tender_Location__c location : tenderData.AITM_Tender_Locations__r) {
                if(location.AITM_Country__c == AITM_locationsDao.POLISH_COUNTRY) {
                    if(!mapPolishAndNonPolishLocations.containsKey(AITM_TenderDao.POLISH)) {
                        mapPolishAndNonPolishLocations.put(AITM_TenderDao.POLISH, true);
                    }                        
                } else {
                    if(!mapPolishAndNonPolishLocations.containsKey(AITM_TenderDao.NONPOLISH)) { 
                        mapPolishAndNonPolishLocations.put(AITM_TenderDao.NONPOLISH, true);
                    }    
                }
            }
            return mapPolishAndNonPolishLocations;
        }

    }


    /**
     * @description class used for email content builder for tender offers
     */    
    public class TenderOffersEmailBuilder {
        private AITM_Tender__c tender;
        private final List<String> TITLE_MSDS_PREFIX_LEGALFILE = new List<String>{Label.AITM_NewOfferPDFMSDS2101FilePrefix,Label.AITM_NewOfferPDFMSDS2102FilePrefix,Label.AITM_NewOfferPDFMSDS2105FilePrefix};
        
        /**
         * @description overloaded constructor 
         * @param  tenderId of type Id
         */
        public TenderOffersEmailBuilder(Id tenderId) {
            tender = new AITM_TenderDao().getTender(tenderId);
        }

        /**
         * @description returns EmailDTO object with details such as Subject,EmailBody and attachments for the tender
         * @param  tenderId of type Id
         * @return AITM_EmailGeneratorController.EmailDTO class object
         */
        public AITM_EmailGeneratorController.EmailDTO build() {
            AITM_EmailGeneratorController.EmailDTOFactory emailDTOFactory = new AITM_EmailGeneratorController.EmailDTOFactory();
            if (String.isNotBlank(tender.AITM_Email__c)) {
                emailDTOFactory.addEmailAddress(true, tender.AITM_Email__c);
            }
            emailDTOFactory.addEmailAddress(false, tender.Owner.Email);	
            emailDTOFactory.addSubject('Air BP offer dated ' + Date.today().format() + ' ' + tender.Name);
            emailDTOFactory.addEmailBody(true, '', '');
            addEmailAttachments(emailDTOFactory);
            return emailDTOFactory.create();
        }

        /**
         * @description adds email attachments to the EmailDTOFactory for the given tender i.e. tenderoffer, MSDS and gtc
         * @param  emailDTOFactory of type AITM_EmailGeneratorController.EmailDTOFactory
         * @return void
         */
        public void addEmailAttachments(AITM_EmailGeneratorController.EmailDTOFactory emailDTOFactory) {
            AITM_TenderDao tendersDao = new AITM_TenderDao();
            List<ContentVersion> gtcOffers = tendersDao.getTenderDocuments(tender.Id, Label.AITM_NewOfferPDFLegalFilePrefix);
            List<ContentVersion> msdsOffers = new List<ContentVersion>();
           
            //loop through the list msdsprefixlegalfile 
            for(String filePrefix : TITLE_MSDS_PREFIX_LEGALFILE) {
                List<ContentVersion> msdsContent = tendersDao.getTenderDocuments(tender.Id, filePrefix);
                if(msdsContent != null) {
                    msdsOffers.addAll(msdsContent);
                }
            }

            //Check offer doc is latest generated or not in comparison to Location Agreement
            Boolean isLatestTenderDocumentIsOffer = tendersDao.isLatestTenderDocumentIsOffer(tender.Id);
			
            //get the latest tenderdocuments of either new offer and Appendix or FFSA and Location Agreement in pdf   
            List<ContentVersion> offers = tendersDao.getLatestTenderDocumentInPdf(tender.Id, isLatestTenderDocumentIsOffer);
			
			
            //add to the list offers i.e. gtcoffers and msdsoffers
            if(isLatestTenderDocumentIsOffer){
                offers.addAll(gtcOffers);
            }
            offers.addAll(msdsOffers);
            
            for (ContentVersion offer : offers) {
                emailDTOFactory.addEmailAttachment(offer);
            }
        }
    }
}