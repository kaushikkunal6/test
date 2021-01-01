/***********************************************************************************************
 * @author           srnandan
 * @date             10/May/2018
 * @group            AirBP
 * @description      controller class used in aura component to change a customer

 * history
 * 10/May/2018     srnandan    Created AR-2782
 ************************************************************************************************/
public with sharing class AITM_ChangeCustomerController
{

    /**
     * @description getting the stage of the tender
     * @param tenderId of type Id     
     * @return String
     */

    public static @AuraEnabled String getTenderStage(Id tenderId){
        AITM_Tender__c t = [Select AITM_Stage__c from AITM_Tender__c where Id =:tenderId];
        return t.AITM_Stage__c;
    }
    /**
     * @description searches customers based on tenderid and key
     * @param key of type string
     * @param tenderId of type Id
     * @return List collection Account
     */
public
    static @AuraEnabled List<Account> searchCustomers(String key, Id tenderId)
    {
        Map<Id, Account> searchResult = new Map<Id, Account>(new AITM_AccountDao().searchCustomers(key));
        for (AITM_Tender_Account__c existingAccount : new AITM_AccountDao.TenderAccountDao().getTenderAccountForTender(tenderId))
        {
            if (searchResult.containsKey(existingAccount.AITM_Account__c))
            {
                searchResult.remove(existingAccount.AITM_Account__c);
            }
        }

        return searchResult.values();
    }

    /**
     * @description searches customers based on tenderid and key
     * @param key of type string
     * @param tenderId of type Id
     * @return List collection Account
     */
public
    static @AuraEnabled List<TenderAccountCustomerWrapper> getTenderAccountCustomers(Id tenderId)
    {
        List<TenderAccountCustomerWrapper> tenderAccountCustomerList = new List<TenderAccountCustomerWrapper>();

        for (AITM_Tender_Account__c tenderAccount : new AITM_AccountDao.TenderAccountDao().getTenderAccountForTender(tenderId))
        {
            tenderAccountCustomerList.add(new TenderAccountCustomerWrapper(tenderAccount, tenderId));
        }

        return tenderAccountCustomerList;
    }

    /**
     * @description gets tender locations based on tenderid
     * @param tenderId of type string
     * @return List collection TenderLocationWrapper
     */
public
    static @AuraEnabled List<TenderLocationItemWrapper> getTenderLocationLineItems(Id tenderId)
    {
        List<TenderLocationItemWrapper> result = new List<TenderLocationItemWrapper>();
        for (AITM_Tender_Location_Line_Item__c tenderLocationItem : new AITM_LocationsDao().getTenderLocationLineItemsByTender(tenderId))
        {
            result.add(new TenderLocationItemWrapper(tenderLocationItem, tenderId));
        }
        return result;
    }

    /**
     * @description saves tenderaccount related data of tender id
     * @param jsonLocations of type string
     * @param accountId of type Id
     * @param tenderId of type Id
     * @return void
     */
public
    static @AuraEnabled void saveTenderAccountWithRelatedData(String jsonLocations, Id accountId, Id oldAccountId, Id tenderId)
    {
        AITM_ChangeCustomerController controller = new AITM_ChangeCustomerController();
        controller.saveTenderAccount(accountId, tenderId);
        controller.saveTenderLocations(jsonLocations);
        controller.removeTenderAccount(oldAccountId, tenderId);
    }

    /**
     * @description saves tender account
     * @param accountId of type Id
     * @param tenderId of type Id
     * @return void
     */
private
    void removeTenderAccount(Id accountId, Id tenderId)
    {
        new AITM_AccountDao.TenderAccountDao().deleteTenderAccount(accountId, tenderId);
    }

    /**
     * @description saves tender account
     * @param accountId of type Id
     * @param tenderId of type Id
     * @return void
     */
private
    void saveTenderAccount(Id accountId, Id tenderId)
    {
        new AITM_AccountDao.TenderAccountDao().createTenderAccount(accountId, tenderId);
    }

    /**
     * @description searches locations based on tenderid and key
     * @param jsonLocations of type string
     * @return void
     */
private
    void saveTenderLocations(String jsonLocations)
    {
        List<AITM_Tender_Location_Line_Item__c> tenderLocations = new List<AITM_Tender_Location_Line_Item__c>();
        List<TenderLocationItemWrapper> wrappedLocations = (List<TenderLocationItemWrapper>)JSON.deserialize(jsonLocations, List<TenderLocationItemWrapper>.class);
        for (TenderLocationItemWrapper wrappedRecord : wrappedLocations)
        {
            tenderLocations.add(wrappedRecord.unwrap());
        }
        new AITM_LocationsDao().updateTenderLocationsAccountId(tenderLocations);
    }

    /**
     * @description tender location wrapper inner class
     */
public
    class TenderLocationItemWrapper
    {
    public
        @AuraEnabled Id accountId;
    public
        @AuraEnabled Id tenderId;
    public
        @AuraEnabled Id tenderLocationItemId;

        /**
         * @description overloaded constructor
         * @param tenderLocation of type AITM_Tender_Location__c
         * @param tenderId of type string
         */
    public
        TenderLocationItemWrapper(AITM_Tender_Location_Line_Item__c tenderLocation, Id tenderId)
        {
            this.tenderId = tenderId;
            this.accountId = tenderLocation.AITM_Account__c;
            this.tenderLocationItemId = tenderLocation.Id;
        }

        /**
         * @description returns tender location line item
         * @param null
         * @return AITM_Tender_Location_Line_Item__c
         */
    public
        AITM_Tender_Location_Line_Item__c unwrap()
        {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Account__c = this.AccountId,
                AITM_Tender__c = this.tenderId,
                Id = this.tenderLocationItemId);
        }
    }

    /**
     * @description tender location wrapper inner class
     */
    public class TenderAccountCustomerWrapper
    {
    public
        @AuraEnabled String accountName;
    public
        @AuraEnabled Id accountId;
    public
        @AuraEnabled Id tenderId;
    public
        @AuraEnabled Id tenderAccountId;
    public
        @AuraEnabled String grn;

        /**
         * @description overloaded constructor
         * @param tenderAccount of type AITM_Tender_Location__c
         * @param tenderId of type string
         */
    public
        TenderAccountCustomerWrapper(AITM_Tender_Account__c tenderAccount, String tenderId)
        {
            this.accountId = tenderAccount.AITM_Account__c;
            this.tenderId = tenderId;
            this.tenderAccountId = tenderAccount.Id;
            this.accountName = tenderAccount.AITM_Account__r.Name;
            this.grn = tenderAccount.AITM_GRN__c;
        }
    }
}