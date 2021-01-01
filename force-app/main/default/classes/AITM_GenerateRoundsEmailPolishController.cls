/***********************************************************************************************
 * @author           srnandan
 * @date             12/August/2018
 * @group            AirBP
 * @description      To generate Tender Feedback html (attachments) 

 * history
 * 12/August/2018    srnandan       Created 
 * 21/Oct/2018       srnandan       Modified AR-XXXX attachEmail to update LABPFeedbacksent field
 *************************************************************************************/
public with sharing class AITM_GenerateRoundsEmailPolishController {
    
    /**
     * @description generates email content based on location type and tender
     * @param  tenderId of type Id
     * @param  locationType of type String
     * @return AITM_EmailGeneratorController.EmailDTO
     */
    public static @AuraEnabled AITM_EmailGeneratorController.EmailDTO generate(Id tenderId, String locationType) {
        if(!isTenderLocationsHasFeedback(tenderId) && !Test.isRunningTest()){
            throw new AuraHandledException(Label.AITM_EmptyFeedbackErrorMessage);   
        }
        AITM_RoundsEmailGenerator.Generator emailCreator = new AITM_RoundsEmailGenerator.Generator(tenderId, AITM_TenderDao.POLISH);
        return emailCreator.generate();
    }

    /**
     * @description pop up to update the bids in by date for new round
     * @param  tenderId of type Id
     * @param  newDate of type String
     * @return String
     */

    public static @AuraEnabled String updateBidsInByDate(Id tenderId,String newDate){
        AITM_Tender__c tender = [Select AITM_Bids_In_By__c from AITM_Tender__c where Id =:tenderId];
         if((Date.valueOf(newDate)< Date.today())){
              return('1');
          }else{        
               tender.AITM_Bids_In_By__c = Date.valueOf(newDate);         
               update(tender);      
              return('2');
          }
    }
    
    /**
     * @description generates email content based on location type and tender
     * @param  tenderId of type Id
     * @param  locationType of type String
     * @return AITM_EmailGeneratorController.EmailDTO
     */
    public static @AuraEnabled Boolean updateTenderChange(Id tenderId) {
       AITM_Tender__c tender = new AITM_TenderDao().getTenderStage(tenderId);
       
       if(tender.AITM_Stage__c == 'STATUS_AWAITING_PRICE' || tender.AITM_No_Feedback_Progress_To_De_Brief__c) {
            return true;
       }
       return false;
    }
    
    /**
     * @description pulls default values to checkboxes
     * @param  emailDTOWithTenderId of type string
     * @return null
     */
    public static @AuraEnabled void attachEmail(String emailDTOWithTenderId) {
        EmailDTOTenderId dataObject = (EmailDTOTenderId) JSON.deserialize(emailDTOWithTenderId, EmailDTOTenderId.class);
        AITM_RoundsEmailGenerator.AttachmentGenerator emailAsAttachmentGenerator = 
            new AITM_RoundsEmailGenerator.AttachmentGenerator(dataObject.tenderId, dataObject.emailDTO, AITM_TenderDao.POLISH);
        emailAsAttachmentGenerator.attach();
        try {
                AITM_TenderDao tenderDao = new AITM_TenderDao();
                tenderDao.updateLABPFeedbackSent(dataObject.tenderId);
            }catch(Exception ex) {
                throw new AuraHandledException('Error updating Feedback Notification');          
            }
    }
    
    /**
     * @description class holds email dto for a tender
     */
    private @testVisible class EmailDTOTenderId {
        public Id tenderId;
        public AITM_EmailGeneratorController.EmailDTO emailDTO;
    }
    
    /**
     * @description returns true if tenderlocations has feedback
     * @param  tenderId of type Id
     * @return Boolean
     */
    private static Boolean isTenderLocationsHasFeedback(Id tenderId){
        List<AITM_Tender_Location__c> tenderLocations = new AITM_LocationsDao().getRepresentedCurrentRoundTenderLocations(tenderId);
        Boolean result = false;

        for (AITM_Tender_Location__c tenderLocation : tenderLocations){
            if (tenderLocation.AITM_Has_Feedback__c) {
                result = true;
            }
        }

        return result;
    }
}