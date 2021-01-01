/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      acts as data access object for all account related queries

 * history
 * 01/December/2017  George      Created 
 * 01/March/2018     srnandan    Modified AR-2591 - Added constant "TITLE_MSDS_PREFIX_LEGALFILE",
 *                               modified method "addEmailAttachments" to include msds pdf attachments
 *                               for Generate offer button  functionality
 * 05/March/2018     Anusha      Modified AR-2542 Contracting bank details and changed it to 
 *                               Bank account details in a method called "getTenderAccountWithOfferInformation"
 * 20/March/2018     srnandan    added comments at method and class level as per coding standards
 * 10/May/2018       Ravi        Added AITM_Account__r.AITM_Offer_Valid_Until__c in TenderAccountDao class.
 * 11/May/2018       Anusha      Modified AR-3091 Distribution List of Email Ids of contacts using Account Id and GRN
 * 13/May/2018       srnandan    Modified - AR-2872 - Added methods -  deleteTenderAccount,getTenderAccountsForTenderWithAccount
 * 18/May/2018       Martin      Modified - AR-3099 - update query with signatory fields "getTenderAccountWithOfferInformation"
 * 30/May/2018       Ravi        Modified - AR-3240 - Updated query from AITM_Tender__r.AITM_Currency__c to AITM_Payment_Currency__c in Tender Account
 * 12/June/2018      srnandan    Modified - AR-3361 - Replaced AITM_Credit_Days__c field with AITM_Credit_Days1__c
 * 11/July/2018      Anusha      Modified - AR-3585 and AR-3584 - Added a method to query Account fields.
 * 23/July/2018      Anusha      Modified - AR-3795 - Added method - getDistributionListofAccount query list of AITM_DistributionEmail__c from Account
 * 07/Aug/2018       Anusha      Modified - AR-3157 - Added logic - getSearchQueryForCustomers query for blank values for MDM data
 * 06/Sept/2018      Shweta      Modified - AR-4084 - Added Method - searchgroups to add the customers related to a group account in tender customer object
 * 20/Sept/2018      Shweta      Modified - AR-4243 - Added Method - getvalidategroupaccount to check the mandatory fields in the accounts to be added as group
 * 04/Oct/2018       Shweta      Modified - AR-4450 - Updated the method getSearchQueryForCustomers to fetch only the non grouped accounts in the Add Customer Modal
 * 04/October/2018   Ravi        Modified - AR-4355 - Modified getTenderAccountForTender method to add Bespoke Contract and Bespoke Offer fields
 * 03/Dec/2018       Shweta      Modified-AR-4644 -- Added a new method getAccountsByTenderLocationLineItemAccountId
 * 17/Dec/2018       srnandan    Modified - Added comments
 * 27/Dec/2018       Anusha      Modified - AR-2745 - Added a newly created field Account classifications in SOQL query
 * 15/May/2019       srnandan    Modified - AR-5190 added new method getAffiliates
 * 13/June/2019      srnandan    Modified - AR-XXXX Added new overloaded method getAffiliates which returns map
 * 06/Nov/2019       srnandan    Modified - AR-XXXX modifed method getTenderAccountForTender to add new field AITM_Select_to_Apply_Old_Taxes_and_Fees__c in soql
 *************************************************************************************************************************/
 public with sharing class AITM_AccountDao {
    private final ID CUSTOMER_ACCOUNTING_DETAILS_RECORDTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Accounting Details').getRecordTypeId();

    /**
     * @description default constructor
     */ 
    public AITM_AccountDao() {}
    
    /**
     * @description gets accounts groupd by GRN, with given GRN
     * @param grns set collection of type string   
     * @return Map collection containing GRN and Id of account
     */
    public Map<String, Id> getAccountsGroupedByGRN(Set<String> grns) {
        Map<String, Id> result = new Map<String, Id>();
        for (Account accountRecord : this.getAccountsByGRN(grns)) {
            result.put(accountRecord.AITM_GRN__c, accountRecord.Id);
        }
        return result;
    }

    /**
     * @description gets accounts list, with account Id
     * @param accountId
     * @return Boolean 
     */
    public boolean getValidateAccount(Id accountId){
        boolean val = false;
        List<Account> acc = [SELECT Id FROM Account WHERE Account.AITM_Contracting_Entity__c != null AND AITM_Credit_Days1__c != null AND AITM_Customer_Segment__c !=null AND Id = :accountId];
        if (acc != null && acc.size() > 0) {
        val = true;
           } 
            return val;
     }

     /**
     * @description gets accounts list, with account Id
     * @param accountId
     * @return Boolean 
     */
    public List<Account> getValidateGroupAccount(Id accountId){     
        return [SELECT Id,Name,AITM_GRN__c FROM Account WHERE (Account.AITM_Contracting_Entity__c = null OR AITM_Credit_Days1__c  = null OR AITM_Customer_Segment__c = null) AND AITM_Group__c = :accountId];
     }

    /**
     * @description gets accounts with given set of grns
     * @param grns set collection of type string   
     * @return List collection of account (sobject)
     */
    public List<Account> getAccountsByGRN(Set<String> grns) {
        return [SELECT AITM_GRN__c FROM Account WHERE AITM_GRN__c IN :grns];
    }

    /**
     * @description gets accounts with given set of Ids
     * @param Ids set collection of type Id   
     * @return List collection of account (sobject)
     */
    public List<Account> getAccountsByTenderLocationLineItemAccountId(Set<Id> Ids) {
        return [SELECT AITM_GRN__c,Name FROM Account WHERE Id IN :Ids];
    }

    /**
     * @description gets accounts with credit terms info by Account ID
     * @param ids set collection of type Id   
     * @return Map collection of Id and account (sobject)
     */
    public Map<Id, Account> getAccountsWithTenderLocationInfoByIds(Set<Id> ids) {
        return new Map<Id, Account>([SELECT Id, AITM_Credit_Days1__c, AITM_Invoice_Frequency__c,AITM_Security_Type__c, AITM_Payment_Currency__c, AITM_Security_Text_on_Offer__c FROM Account WHERE Id IN :ids]);
    }
    
    /**
     * @description gets tender accounts by related account Id and tender Id
     * @param tenderIds set collection of type Id   
     * @param accountIds set collection of type Id
     * @return Map collection of string and tender account (sobject)
     */
    public Map<String, AITM_Tender_Account__c> getTenderAccountsWithTenderAndAccountIds(Set<Id> tenderIds, Set<Id> accountIds) {
        Map<String, AITM_Tender_Account__c>  mp = new Map<String, AITM_Tender_Account__c>();
        for(AITM_Tender_Account__c ta:  [SELECT AITM_Account__c, AITM_Tender__c, AITM_Credit_Days1__c, AITM_Invoice_Frequency__c, AITM_Payment_Currency__c,
                                            AITM_Security_Text_on_Offer__c, AITM_Security_Type__c FROM AITM_Tender_Account__c WHERE AITM_Account__c IN :accountIds and AITM_Tender__c in :tenderIds])
        {
            mp.put(ta.AITM_Account__c+'-'+ta.AITM_Tender__c , ta);
        }
        return mp;
    }

    /**
     * @description gets account with its child Accounts Ids
     * @param ids set collection of type Id   
     * @return List collection of account (sobject)
     */
    public List<Account> getAccountsWithItsChilds(Set<Id> ids) {
        return [SELECT Id, (SELECT Id FROM ChildAccounts) FROM Account WHERE Id IN :ids];
    }

    /**
     * @description searches customers based on searchKey
     * @param searchKey of type string
     * @return List collection of account (sobject)
     */
    public List<Account> searchCustomers(String searchKey) {
        String searchQuery = getSearchQueryForCustomers(searchKey);
        List<List<sObject>> soslCustomerResult = Search.query(searchQuery);
        return (List<Account>) soslCustomerResult[0];
    }

    /**
     * @description searches customers and their information based on the searchKey
     * @param searchKey of type string
     * @return string SOSL query
     */
    private String getSearchQueryForCustomers(String searchKey) {
        String enddate = '';
        String grn = '';
        String result = 'FIND \'' + String.escapeSingleQuotes(searchKey) + '*\' IN ALL FIELDS ';
        result += 'RETURNING Account(Name, AITM_GRN__c, AITM_Credit_Days1__c, AITM_Payment_Currency__c, AITM_Security_Type__c, AITM_Invoice_Frequency__c WHERE AITM_GRN__c != \'' + String.escapeSingleQuotes(grn) + '\' AND AITM_End_Date__c = \''+ String.escapeSingleQuotes(enddate) + '\' AND RecordTypeId = \'' + CUSTOMER_ACCOUNTING_DETAILS_RECORDTYPE + '\') LIMIT 50';
        return result;
    }
     
     

    /**
     * @description searches groups based on searchKey
     * @param searchKey of type string
     * @return List collection of account (sobject)
     */
    public List<Account> searchgroups(String searchKey) {
        String searchQuery = getSearchQueryForGroups(searchKey);
        List<List<sObject>> soslGroupResult = Search.query(searchQuery);     
  
        return (List<Account>) soslGroupResult[0];
    }   

    /**
     * @description searches groups and their information based on the searchKey
     * @param searchKey of type string
     * @return string SOSL query
     */
    private String getSearchQueryForGroups(String searchKey) {
        String enddate = '';
        String grn = '';
        String result1 = 'FIND \'' + String.escapeSingleQuotes(searchKey) + '*\' IN ALL FIELDS ';
        result1 += 'RETURNING Account(Name WHERE AITM_GRN__c = \'' + String.escapeSingleQuotes(grn) + '\' AND AITM_End_Date__c = \''+ String.escapeSingleQuotes(enddate) + '\' AND RecordTypeId = \'' + CUSTOMER_ACCOUNTING_DETAILS_RECORDTYPE + '\') LIMIT 50';
        return result1;
    }

    /**
     * @description acts as data access layer for tenderAccountLineItem queries and database operations
     */
    public without sharing class TenderAccountLineItemDao {
        /**
         * @description gets accounts with given set of Ids
         * @param Ids set collection of type Id   
         * @return List collection of account (sobject)
         */
        public List<Account> getAccountsByTenderLocationLineItemAccountId(Set<Id> Ids) {
            return [SELECT AITM_GRN__c,Name FROM Account WHERE Id IN :Ids];
        }   
    }
    
    /**
     * @description acts as data access layer for tenderAccount queries and database operations
     */
    public inherited sharing class TenderAccountDao {
        /**
         * @description gets tenderaccount with offer information based on tenderaccount Id
         * @param recordId of type string
         * @return AITM_Tender_Account__c sobject
         */
        public AITM_Tender_Account__c getTenderAccountWithOfferInformation(String recordId) {
            return [SELECT AITM_Contracting_Entity__c,AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account_Classification__c, AITM_Legal_Entity__r.BillingStreet, AITM_Legal_Entity__r.BillingCity, AITM_Legal_Entity__r.BillingState, AITM_Legal_Entity__r.BillingCountry, AITM_Legal_Entity__r.BillingPostalCode, AITM_Legal_Entity__c, JV_terms__c, AITM_Affiliates_Account__r.Name, AITM_Security_Text_on_Offer__c, AITM_Contracting_Entity_Title__c, AITM_Contracting_Entity_Signatory__c, AITM_Contracting_Entity__r.Name, AITM_Contracting_Entity__r.AITM_Country__c, AITM_Contracting_Entity__r.AITM_Address__c, AITM_Account__c, AITM_Tender__r.AITM_Offer_Valid_Until__c, AITM_Account__r.Name, AITM_Account__r.BillingCountry, AITM_Account__r.BillingStreet, AITM_Account__r.BillingCity, AITM_Account__r.BillingState, AITM_Account__r.BillingPostalCode, AITM_Tender__c, AITM_Payment_Currency__c, AITM_Bank_Account__r.AITM_Bank_Account_Number__c, AITM_Bank_Account__r.AITM_Bank_IBAN_Number__c, AITM_Bank_Account__r.Name, AITM_Bank_Account__r.AITM_Bank_Address__c, AITM_Bank_Account__r.AITM_Bank_City__c, AITM_Credit_Terms__c, AITM_Affiliates__c, AITM_Contracting_Entity__r.AITM_Email__c, AITM_Email__c, AITM_Contracting_Entity__r.AITM_Governing_Law__c, AITM_Contracting_Entity__r.AITM_Arbritation__c, AITM_Resellers__c, AITM_Contracting_Entity__r.AITM_Signatory__c, AITM_Contracting_Entity__r.AITM_Title__c FROM AITM_Tender_Account__c WHERE Id = :recordId LIMIT 1][0];
        }
    
        /**
         * @description returns child affiliate account names for the lead account
         * @param  accountId of type Id 
         * @param  tenderId of type Id 
         * @return List<String>
         */
        public List<String> getAffiliates(Id accountId, Id tenderId) {
            List<String> affiliateAccounts = new List<String>();
            try {
                for(AITM_Tender_Account__c tenderAccount : [SELECT AITM_Account__r.Name FROM AITM_Tender_Account__c WHERE AITM_Affiliates_Account__c =:accountId AND AITM_Tender__c =:tenderId]) {
                    affiliateAccounts.add(tenderAccount.AITM_Account__r.Name);                    
                }
            }catch(DMLException ex){
                return affiliateAccounts;
            }
            finally{
                return affiliateAccounts;
            }
            return affiliateAccounts;            
        }
        
        /**
         * @description returns child affiliate account names for the lead account
         * @param  accountId of type Id 
         * @param  tenderId of type Id 
         * @return List<String>
         */
        public Map<Id,String> getAffiliatesMap(Id accountId, Id tenderId) {
            Map<Id,String> affiliateAccounts = new Map<Id,String>();
            try {
                for(AITM_Tender_Account__c tenderAccount : [SELECT AITM_Account__r.Name FROM AITM_Tender_Account__c WHERE AITM_Affiliates_Account__c =:accountId AND AITM_Tender__c =:tenderId]) {
                    affiliateAccounts.put(tenderAccount.AITM_Account__c, tenderAccount.AITM_Account__r.Name);                    
                }
            }catch(DMLException ex){
                return affiliateAccounts;
            }
            finally{
                return affiliateAccounts;
            }
            return affiliateAccounts;            
        }

        /**
         * @description gets accounts with given string of grns
         * @param grns distribution email of type string   
         * @return List collection of account (sobject)
         */
        public List<Account> getDistributionListofAccount(String grn){
             return[SELECT AITM_DistributionEmail__c FROM Account WHERE AITM_GRN__c = :grn];  
           }


        /**
         * @description gets tenderaccount with offer information based on list of tenderaccount Ids
         * @param recordsIds list collection of Id
         * @return List collection of type AITM_Tender_Account__c 
         */
        public List<AITM_Tender_Account__c> getTenderAccountWithOfferInformation(List<Id> recordsIds) {
            return [SELECT AITM_Contracting_Entity__c, AITM_Contracting_Entity_Title__c,AITM_Account_Classification__c, AITM_Contracting_Entity_Signatory__c, AITM_Account__r.AITM_Contracting_Entity__c, AITM_Account__r.AITM_Contracting_Entity__r.AITM_Title__c, AITM_Account__r.AITM_Contracting_Entity__r.AITM_Signatory__c FROM AITM_Tender_Account__c WHERE Id IN :recordsIds];
        }

        /**
         * @description gets tenderaccount for a tender
         * @param tenderId of type Id
         * @return List collection of type AITM_Tender_Account__c
         */
        public List<AITM_Tender_Account__c> getTenderAccountForTender(Id tenderId) {
            return [SELECT AITM_Tender__c, AITM_Account__r.AITM_Bespoke_Template__c, AITM_Account__r.AITM_Bespoke_Offer_Template__c, AITM_Tender__r.AITM_Density__c, AITM_Security_Type__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Customer_Segment__c, AITM_GRN__c, AITM_Account_Classification__c, AITM_Account__c, AITM_Account__r.Name, AITM_Tender__r.Name, AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__r.AITM_GRN__c FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :tenderId];
        }

        /**
         * @description gets tenderaccount for a set of tenders
         * @param tenderIds set collection of Id
         * @return List collection of AITM_Tender_Account__c 
         */
        public List<AITM_Tender_Account__c> getTenderAccountsForTenders(Set<Id> tenderIds) {
            return [SELECT AITM_Account__c, AITM_Tender__c FROM AITM_Tender_Account__c WHERE AITM_Tender__c IN :tenderIds];
        }
        
        /**
         * @description gets tenderaccount for a set of tenders
         * @param tenderIds set collection of Id
         * @return List collection of AITM_Tender_Account__c 
         */
        public List<AITM_Tender_Account__c> getTenderAccountsForTenderWithAccount(Id tenderId, Id accountId) {
            return [SELECT AITM_Account__c, AITM_Tender__c FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :tenderId and AITM_Account__c = :accountId];
        }

        
        /**
         * @description saves the tenderaccounts to database
         * @param tenderAccountsToSave list collection of AITM_Tender_Account__c
         * @return void
         */
        public void saveTenderAcccounts(List<AITM_Tender_Account__c> tenderAccountsToSave) {
            Database.insert(tenderAccountsToSave, false);
        }

        /**
         * @description create tenderaccount
         * @param accountId of type Id
         * @param tenderId of type Id
         * @return void 
         */
        public void createTenderAccount(Id accountId, Id tenderId) {
            AITM_Tender_Account__c tenderAccount = new AITM_Tender_Account__c(AITM_Tender__c = tenderId, AITM_Account__c = accountId);
            insert tenderAccount;
        }     

        /**
         * @description create tenderaccount based on the group account
         * @param accountId of type Id
         * @param tenderId of type Id
         * @return void 
         */

        public void createTenderAccountGroup(Id accountId, Id tenderId) {         
        List<Account> accgroup = new List<Account>([SELECT Id FROM Account WHERE AITM_Group__c = :accountId]);
        List<AITM_Tender_Account__c> newlist = new List<AITM_Tender_Account__c>();
         for(Account a:accgroup){
            AITM_Tender_Account__c tenderAccount = new AITM_Tender_Account__c(AITM_Tender__c = tenderId, AITM_Account__c = a.Id);
            newlist.add(tenderAccount);           
         
            }         
         insert newlist;          
           
        }

        /**
         * @description delete tenderaccount
         * @param accountId of type Id
         * @param tenderId of type Id
         * @return void 
         */
        public void deleteTenderAccount(Id accountId, Id tenderId) {
            List<AITM_Tender_Account__c> tenderAccounts = getTenderAccountsForTenderWithAccount(tenderId, accountId);

            if(!tenderAccounts.isEmpty()) {
                Database.delete(tenderAccounts, false);
            }
        }
    }
}