/**
* @author: Gabriela Matos
* @date: 11/06/2020
* @group: BPG
* @description: Util class for BPG_Social_Media_Account__mdt custom metadata type object.
* @name BPG_SocialMediaAccountUtil.cls
*/

public with sharing class BPG_SocialMediaAccountUtil {

    /** 
     * @description: to guery all BPG_Social_Media_Account__mdt custom metadata type records (social media)
     * @author Gabriela Matos | 11/06/2020
     * @return Map of BPG_Social_Media_Account__mdt record by Social Account Id
     * */
    public static Map<String, BPG_Social_Media_Account__mdt> SOCIAL_MEDIA_ACCOUNTS {
        get {
            if (SOCIAL_MEDIA_ACCOUNTS == null) {
                SOCIAL_MEDIA_ACCOUNTS = new Map<String, BPG_Social_Media_Account__mdt>();
                for(BPG_Social_Media_Account__mdt social : [SELECT DeveloperName, 
                                                               BPG_Days_To_Reopen_Case__c, 
                                                               BPG_Social_Account_Id__c, 
                                                               BPG_Project_Prefix__c,
                                                               BPG_Default_Account_Name__c,
                                                               BPG_Default_Account_RT__c,
                                                               BPG_Default_Case_Owner__c,
                                                               BPG_Default_Case_RT__c,
                                                               BPG_Default_Contact_RT__c,
                                                               BPG_Case_Owner_Is_Queue__c,
                                                               BPG_Business_Unit__c,
                                                               BPG_Run_Case_Assignment_Rules__c
                                                          FROM BPG_Social_Media_Account__mdt LIMIT :Limits.getLimitQueryRows()]){

                    SOCIAL_MEDIA_ACCOUNTS.put(social.BPG_Social_Account_Id__c, social);                                          
                }
            }
            return SOCIAL_MEDIA_ACCOUNTS;
        }
        set;
    }
}