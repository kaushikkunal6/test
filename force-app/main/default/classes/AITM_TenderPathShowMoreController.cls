/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      To generate Tender Offer PDF (attachments) and update tender stage and offer sent.

 * history
 * 01/December/2017  George       Created 
 * 05/August/2018    srnandan     Modified added comments to each method and header of class
 * 12/August/2018    srnandan     Modified AR-3391 added method multipleLocations 
 *                                to show conditional display of email buttons for polish 
 *                                and non polish locations 
 * 07/January/2019   srnandan     Modified multipel locations to call getTenderWithTenderLocations
 * 02/February/2019  srnandan     declared static final for retrieving currentUserProfile and removed calling from
 *                                determineShowButtonsByProfile
 * 17/April/2019     srnandan     Modified - AR-XXXX multiplelocations condition with new filter AITM_Locations_Filter
 * 01/July/2019      srnandan     Modified - AR-5265 added reportID for download offer excel and inherited sharing for
 * 02/August/2019    srnandan     Modified - AR-5287 for conga permission access check
 * 12/December/2019  srnandan     Modified - Prod Fix for LABP License assignments bypass for community users
 *************************************************************************************/
public with sharing class AITM_TenderPathShowMoreController {
    static final String currentUserProfile = new AITM_UsersDao().getProfileName(UserInfo.getUserId());
    static Id userId = UserInfo.getUserId(); 
    
    /**
     * @description LABP Running user
     * @param  null
     * @return boolean
     */
    @AuraEnabled
    public static Boolean getLABPRunningUser(Id ownerId) {
        Boolean blnFlag = false;
        Boolean anflag = false ;
        if(ownerId == userId){
            anflag = true;
        }
        else{
            anflag = false;
        }
        
        blnFlag = (AITM_BaseUtils.checkRunningUserIsLABP() && anflag);
        return blnFlag;
    }
    
    /**
     * @description pulls default values to checkboxes
     * @param  tenderId of type Id
     * @return DefaultValuesToCheckboxes
     */
    @AuraEnabled
    public static DefaultValuesToCheckboxes pullDefaultValuesForCheckboxes(Id tenderId) {
        return new DefaultValuesToCheckboxes(tenderId);
    }

    /**
     * @description change feedback to debrief
     * @param  tenderId of type Id
     * @param  valueToSet of type Boolean
     * @return string
     */
    @AuraEnabled
    public static String changeFeedbackToDeBrief(Id tenderId, Boolean valueToSet) {
        try {
            update new AITM_Tender__c(Id = tenderId, AITM_No_Feedback_Progress_To_De_Brief__c = valueToSet);
        } catch (DMLException e) {
            return e.getDmlMessage(0);
        }
        return 'OK';
    }

    /**
     * @description class holds boolean flags to show buttons
     */
    public inherited sharing  class DefaultValuesToCheckboxes {
        @AuraEnabled public Boolean feedbackToDebrief;
        @AuraEnabled public Boolean showButtons;
        @AuraEnabled public Boolean showPolish;
        @AuraEnabled public Boolean showNonPolish;
        @AuraEnabled public Boolean showDownloadLABPExcel;
        @AuraEnabled public Boolean showConga;
        @AuraEnabled public String reportID;
        @AuraEnabled public String taxAndFeeReportID;
        @AuraEnabled public String additionalNotesReportID;
        @auraEnabled public Boolean isTenderOld;
        @auraEnabled public Boolean isGenerateOfferButton;
        @AuraEnabled public Boolean showReportTOLM;

        private final Set<String> PROFILES_WITH_BUTTONS_VISIBILITY = new Set<String> {
            'Air_TMAccount Manager',
            'Air_TMBusiness Admin',
            'Air_TMRegionalAccount Manager',
            'System Administrator',
            'AITM_Data_Migration_Mulesoft_PROS'
        };  
        private final Set<String> PROFILES_WITH_REPORT_BUTTON_VISIBILITY = new Set<String> {
            'Air_TMLocation Manager'
        };   

        /**
         * @description overloaded constructor
         * @param  tenderId of type Id
         */
        public DefaultValuesToCheckboxes(Id tenderId) {
            AITM_Tender__c tender = [SELECT OwnerId,AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Produce_Customer_Email__c, AITM_Generate_Offer__c, AITM_No_Feedback_Progress_To_De_Brief__c FROM AITM_Tender__c WHERE Id = :tenderId LIMIT 1][0];
            feedbackToDebrief = tender.AITM_No_Feedback_Progress_To_De_Brief__c;
            isTenderOld = tender.AITM_Select_to_Apply_Old_Taxes_and_Fees__c;
            isGenerateOfferButton = tender.AITM_Generate_Offer__c;
            showButtons = determineShowButtonsByProfile(tender.OwnerId);
            showReportTOLM = determineShowReportButtonsByProfile(tender.OwnerId);
            multipleLocations(tender.Id);
            showDownloadLABPExcel = AITM_BaseUtils.checkRunningUserIsLABP();
            showConga = (AITM_TenderPathShowMoreController.getLABPRunningUser(tender.OwnerId) ? true : AITM_BaseUtils.checkCongaPermission());
            Report reportName = new AITM_TenderDao().getTenderReport('AirBPOffer');
            if(reportName != null) {
                reportID = reportName.Id;
            }
            Report taxAndFeesReport = new AITM_TenderDao().getTenderReport('Offer Report - T&F Details');
            if(taxAndFeesReport != null) {
                taxAndFeeReportID = taxAndFeesReport.Id;
            }
            Report additionalNotesReport = new AITM_TenderDao().getTenderReport('Offer Report - Additional Notes');	
            if(additionalNotesReport != null) {
                additionalNotesReportID = additionalNotesReport.Id;	
            }
        }

        /**
         * @description overloaded constructor
         * @param  tenderId of type Id
         */
        
        private Boolean determineShowButtonsByProfile(Id OwnerId) {
             Boolean decide = false;
             decide = ((currentUserProfile == 'Air_TMLABP')||(currentUserProfile == 'Air_TMLABPLogin')) && (OwnerId == userId);
             if(decide){
                    return true;
                
                 } else {
                         return PROFILES_WITH_BUTTONS_VISIBILITY.contains(currentUserProfile);
                   }
        }
        
        /**
         * @description overloaded constructor
         * @param  tenderId of type Id
         */
        
        private Boolean determineShowReportButtonsByProfile(Id OwnerId) {
             Boolean decide = false;
             decide = ((PROFILES_WITH_REPORT_BUTTON_VISIBILITY.contains(currentUserProfile)) || ((currentUserProfile == 'Air_TMLABPLogin') && (OwnerId != userId)));
             if(decide){
                 return true;
             } else {
                 return decide;
             }
        }

        /**
         * @description multiple locations
         * @param  tenderId of type Id
         * @return null
         */
        public void multipleLocations(Id tenderId) {
           for(AITM_Tender_Location__c location : new AITM_TenderDao().getTenderWithTenderLocations(tenderId).AITM_Tender_Locations__r) {
               if(location.AITM_Locations_Filter__c != null && location.AITM_Locations_Filter__c == AITM_TenderDao.POLISH) {
                    showPolish = true;
               } else {
                    showNonPolish = true;
               }
           }
        }
    }
}