/***********************************************************************************************
 * @author           Shweta
 * @date             30/Aug/2018
 * @group            AirBP
 * @description      controller class used in aura component to add new groups to locations

 * history
 * 30/August/2018     Shweta      Created 
 ************************************************************************************************/
public with sharing class AITM_AddGroupController {

    /**
     * @description searches groups based on tenderid and key
     * @param key of type string
     * @param tenderId of type Id
     * @return List collection Account
     */
    public static @AuraEnabled List<Account> searchGroups(String key, Id tenderId) {
        Map<Id,Account> searchResult = new Map<Id,Account>(new AITM_AccountDao().searchgroups(key));       
        return searchResult.values();
    }
    
    /**
     * @description saves tenderaccount related data of tender id
     * @param accountId of type Id
     * @param tenderId of type Id
     * @return void
     */
    public static @AuraEnabled void saveTenderAccountWithRelatedData(Id accountId, Id tenderId) {
        AITM_AddGroupController controller = new AITM_AddGroupController();
        controller.saveTenderAccount(accountId, tenderId);
    }

    /**
     * @description validates tenderaccount related data of the accounts to be added for tender customer record
     * @param accountId of type Id
     * @return Boolean
     */
    public static @AuraEnabled List<Account> validateTenderAccountWithRelatedData(Id accountId){
        return new AITM_AccountDao().getValidateGroupAccount(accountId);
    }

    /**
     * @description saves tender account
     * @param accountId of type Id
     * @param tenderId of type Id
     * @return void
     */
    private void saveTenderAccount(Id accountId, Id tenderId) {
        new AITM_AccountDao.TenderAccountDao().createTenderAccountGroup(accountId, tenderId);
    }
}