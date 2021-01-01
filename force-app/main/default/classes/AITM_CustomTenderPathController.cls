/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    controller class used in aura component to display tender path stages 

 * history
 * 06/December/2017  George       Created 
 * 04/April/2018     srnandan     Modified - AR-2731 added method "toggleMarkStageButton", constant 
 *                                "PROFILES_NOTALLOWED_TO_UPDATE" and added code comments as per 
 *                                 coding standards for class and methods
 * 02/August/2018    srnandan     Modified - AR-3308 included labplm profile in PROFILES_NOTALLOWED_TO_UPDATE
 *************************************************************************/
public with sharing class AITM_CustomTenderPathController {
   
    private final static Set<String> PROFILES_NOTALLOWED_TO_UPDATE = new Set<String>{
        'Air_TMLocation Manager',
        'Air_TMLABPLM',
        'Air_TMLABPLoginLM'        
    };

    /**
     * @description toggle mark stage button as per current user profile permissions allowed to update
     * @param null
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean toggleMarkStageButton() {
      Boolean markStageButtonDisable = false;
      String currentUserProfile = new AITM_UsersDao().getProfileName(UserInfo.getUserId());
      if(PROFILES_NOTALLOWED_TO_UPDATE.contains(currentUserProfile)) {
        markStageButtonDisable = true;
      }
      return markStageButtonDisable; 
    }

   /**
     * @description gets stages for a tender
     * @param tenderId of type Id
     * @return TenderStages
     */
    @AuraEnabled
    public static TenderStages getStagesForTender(Id tenderId) {
        return new TenderStages(tenderId);
    }

    /**
     * @description sets stages for a tender
     * @param tenderId of type Id
     * @param stage of type string
     * @return string
     */
    @AuraEnabled
    public static String setStageForTender(Id tenderId, String stage) {
        try {
            update new AITM_Tender__c(Id = tenderId, AITM_Stage__c = stage);
        } catch (DmlException e) {
            return e.getDmlMessage(0);
        }
        return 'OK';
    }

    /**
     * @description sets stage as completed
     * @param tenderId of type Id
     * @return string
     */
    @AuraEnabled
    public static String setStageAsCompleted(Id tenderId) {
        try {
            update new AITM_Tender__c(Id = tenderId, AITM_Stage__c = new TenderStages(tenderId).uncompletedTenderStages.get(0));
        } catch (DmlException e) {
            return e.getDmlMessage(0);
        }
        return 'OK';
    }

    /**
     * @description class holds tender stages details
     */
    public class TenderStages {
        @AuraEnabled public List<String> completedTenderStages;
        @AuraEnabled public String currentTenderStage;
        @AuraEnabled public List<String> uncompletedTenderStages;

        /**
         * @description overloaded constructor with tenderid 
         * @param tenderId of type Id
         */
        public TenderStages(Id tenderId) {
            completedTenderStages = new List<String>();
            uncompletedTenderStages = new List<String>();
            currentTenderStage = new AITM_TenderDao().getTender(tenderId).AITM_Stage__c;
            sortValuesByAllStages(getAllAvailableValuesFromStageOfTender());
        }

        /**
         * @description gets all available stages of tender
         * @param null
         * @return List collection string
         */
        private List<String> getAllAvailableValuesFromStageOfTender() {
            List<Schema.PickListEntry> stageObjects = AITM_Tender__c.AITM_Stage__c.getDescribe().getPicklistValues();

            List<String> stageValues = new List<String>();
            for (Schema.PickListEntry pickListValue : stageObjects) {
                stageValues.add(pickListValue.getLabel());
            }
            return stageValues;
        }

        /**
         * @description sort values of all stages
         * @param List collection of string 
         * @return void
         */
        private void sortValuesByAllStages(List<String> allStages) {
            if (String.isBlank(currentTenderStage)) {
                uncompletedTenderStages.addAll(allStages);
            } else {
                Boolean hasCurrentStageBeenInCycle = false;
                for (String stage : allStages) {
                    if (!hasCurrentStageBeenInCycle) {
                        if (!stage.equals(currentTenderStage)) {
                            completedTenderStages.add(stage);
                        }
                        else {
                            hasCurrentStageBeenInCycle = true;
                        }
                    } 
                    else {
                        uncompletedTenderStages.add(stage);
                    }
                }
            }
        }
    }
}