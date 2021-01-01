/****************************************************************************************************
 *  Date          : 31-Mar-2020
 *  Author        : Shweta Aggarwal
 *  Description   : Helper class for Tender Account Handler
 *  Modifications : 11 Nov 2020  Modified Shweta Updated the with sharing as without sharing for hiding the 5 digit GRNS
 ****************************************************************************************************/
public without sharing class AITM_Tender_Account_Helper {  
    
    public static Map<Id, ChildAccountsForTenders> childAccountsByParentId = new Map<Id, ChildAccountsForTenders>();
    public  static Map<Id, Set<Id>> customerIdsByTenderId ; 

    /**
     * @description add the child accounts
     * @param so of type AITM_Tender_Account__c list,oldTenderAccountMapArg of type map of AITM_Tender_Account__c records
     * @return null
     */   
    public static void addChildAccountsToInnerCollection(List<AITM_Tender_Account__c> so,Map<Id,AITM_Tender_Account__c> oldTenderAccountMapArg) {        
        AITM_Tender_Account__c tenderAccount = (AITM_Tender_Account__c) so[0];       
        if (!childAccountsByParentId.containsKey(tenderAccount.AITM_Account__c)) {
            ChildAccountsForTenders childAccounts = new ChildAccountsForTenders();           
            childAccountsByParentId.put(tenderAccount.AITM_Account__c, childAccounts);
        }
        childAccountsByParentId.get(tenderAccount.AITM_Account__c).tenderIds.add(tenderAccount.AITM_Tender__c);
        Set<Id> accountIdsInScope = childAccountsByParentId.keySet();
        if (accountIdsInScope.size() > 0) {
            for (Account accountInScope : new AITM_AccountDao().getAccountsWithItsChilds(accountIdsInScope)) {                
                childAccountsByParentId.get(accountInScope.Id).childAccounts = accountInScope.ChildAccounts;
            }
            insertNewTenderAccounts();
        }
        tenderAccountCreditTermsCopy(so,oldTenderAccountMapArg);
        
    }
    
    /**
     * @description to insert the tender accounts
     * @param null
     * @return null
     */   
    
    private static void insertNewTenderAccounts() {
        List<AITM_Tender_Account__c> allNewTenderAccounts = new List<AITM_Tender_Account__c>();
        
        for (ChildAccountsForTenders childAccounts : childAccountsByParentId.values()) {
            allNewTenderAccounts.addAll(childAccounts.toTenderAccounts());
        }
        if (!allNewTenderAccounts.isEmpty()) {
            new AITM_AccountDao.TenderAccountDao().saveTenderAcccounts(allNewTenderAccounts);
        }
    }

    /**
     * @description to check the duplicates for the tender accounts on a tender
     * @param tenderAccountsToSave of type AITM_Tender_Account__c list
     * @return null
     */   
    
    public static void checkForDuplicates(List<AITM_Tender_Account__c> tenderAccountsToSave){
        Set<Id> tenderIds = new Set<Id>();
        final String DUPLICATION_ERROR = Label.AITM_TenderAccountDuplicateError;
        for (AITM_Tender_Account__c tenderAccount : tenderAccountsToSave) {
            tenderIds.add(tenderAccount.AITM_Tender__c);
        }
        Map<String, AITM_Tender_Account__c> existingTenderAccounts = getExistingTenderAccountsByTenderAndAccount(tenderIds);
        for (AITM_Tender_Account__c tenderAccount : tenderAccountsToSave) {
            if (existingTenderAccounts.containsKey(getUniqueKey(tenderAccount))) {
                tenderAccount.addError(DUPLICATION_ERROR);
            }
        }
        
    }

    /**
     * @description to get the existng Tender Accounts on a tender
     * @param tenderIds of type Set of IDs
     * @return result of type Map
     */      
    private static Map<String, AITM_Tender_Account__c> getExistingTenderAccountsByTenderAndAccount(Set<Id> tenderIds) {
        Map<String, AITM_Tender_Account__c> result = new Map<String, AITM_Tender_Account__c>();
        for (AITM_Tender_Account__c tenderAccount : new AITM_AccountDao.TenderAccountDao().getTenderAccountsForTenders(tenderIds)) {
            result.put(getUniqueKey(tenderAccount), tenderAccount);
        }
        return result;
    }

    /**
     * @description to get the unique Key 
     * @param tenderAccount object of type AITM_Tender_Account__c
     * @return string
     */      
    
    private static String getUniqueKey(AITM_Tender_Account__c tenderAccount) {
        return tenderAccount.AITM_Tender__c+'-'+tenderAccount.AITM_Account__c;
    }

    /**
     * @description to delete the related AITM_Tender_Location_Line_Item__c records on deletion of an AITM_Tender_Account__c
     * @param tenderAccountsToDelete object of type AITM_Tender_Account__c
     * @return null
     */       
    public static void tenderAccountDeleteRelatedLineItems(List<AITM_Tender_Account__c> tenderAccountsToDelete){
        customerIdsByTenderId = new Map<Id, Set<Id>>();
        AITM_Tender_Account__c deletedTenderCustomer = (AITM_Tender_Account__c) tenderAccountsToDelete[0];       
        if (!customerIdsByTenderId.containsKey(deletedTenderCustomer.AITM_Tender__c)) {
            customerIdsByTenderId.put(deletedTenderCustomer.AITM_Tender__c, new Set<Id>());
        }
        customerIdsByTenderId.get(deletedTenderCustomer.AITM_Tender__c).add(deletedTenderCustomer.AITM_Account__c);
        if (!customerIdsByTenderId.isEmpty()) {
            deleteRelatedLineItems();
        }       
        
    }

    /**
     * @description to get the related AITM_Tender_Location_Line_Item__c records on deletion of an AITM_Tender_Account__c
     * @param null
     * @return null
     */   
    
    private static void deleteRelatedLineItems() {
        Set<Id> allCustomerIds = new Set<Id>();
        for (Set<Id> customerIds : customerIdsByTenderId.values()) {
            allCustomerIds.addAll(customerIds);
        }
        
        List<AITM_Tender_Location_Line_Item__c> lineItemsToDelete = new List<AITM_Tender_Location_Line_Item__c>();
        for (AITM_Tender_Location_Line_Item__c lineItem : new AITM_LocationsDao().getTenderLocationLineItemsByTenderAndAccountIds(customerIdsByTenderId.keySet(), allCustomerIds)) {
            for (Id customerId : customerIdsByTenderId.get(lineItem.AITM_Tender__c)) {
                if (lineItem.AITM_Account__c == customerId) {
                    lineItemsToDelete.add(lineItem);
                }
            }
        }
        
        if (lineItemsToDelete.size()>0) {
            new AITM_LocationsDao().deleteTenderLocationLineItems(lineItemsToDelete);
        }            
    }

    /**
     * @description to copy the Credit Terms from the AITM_Tender_Account__c record to the related AITM_Tender_Account__c record
     * @param tenderAccounts of type List of AITM_Tender_Account__c,oldTenderAccountMapArg of type Map 
     * @return null
     */    
    
    public static void tenderAccountCreditTermsCopy(List<AITM_Tender_Account__c> tenderAccounts,Map<Id,AITM_Tender_Account__c> oldTenderAccountMapArg){
        Map<Id,AITM_Tender_Account__c> oldTenderAccountMap = (Map<Id,AITM_Tender_Account__c>)oldTenderAccountMapArg;
        Set<Id> tenderIds = new Set<Id>();
        set<Id> accountIds = new set<id>();        
        for (AITM_Tender_Account__c tenderAccount : tenderAccounts) {            
            AITM_Tender_Account__c oldTA = (oldTenderAccountMap != null ? oldTenderAccountMap.get(tenderAccount.id) : null);
            if(oldTA != null && (tenderAccount.AITM_Payment_Currency__c != oldTA.AITM_Payment_Currency__c || tenderAccount.AITM_Security_Text_on_Offer__c != oldTA.AITM_Security_Text_on_Offer__c || tenderAccount.AITM_Security_Type__c != oldTA.AITM_Security_Type__c || tenderAccount.AITM_Invoice_Frequency__c != oldTA.AITM_Invoice_Frequency__c || tenderAccount.AITM_Credit_Days1__c != oldTA.AITM_Credit_Days1__c)){
                tenderIds.add(tenderAccount.AITM_Tender__c);
                accountIds.add(tenderAccount.AITM_Account__c);
            } else if(oldTA == null && (tenderAccount.AITM_Payment_Currency__c != null || tenderAccount.AITM_Credit_Days1__c != null || tenderAccount.AITM_Invoice_Frequency__c != null)) {
                tenderIds.add(tenderAccount.AITM_Tender__c);
                accountIds.add(tenderAccount.AITM_Account__c);
            }
        }        
        List<AITM_Tender_Location_Line_Item__c> lstTLitems = [select AITM_Tender__c, AITM_Account__c,AITM_Current_Round__c,AITM_Round__c from AITM_Tender_Location_Line_Item__c 
                                                              where AITM_Account__c in :accountIds and AITM_Tender__c in :tenderIds];
        Map<String, List<AITM_Tender_Location_Line_Item__c>> mpUniqId_to_TenderLineItems = new Map<String, List<AITM_Tender_Location_Line_Item__c>>();
        
        for(AITM_Tender_Location_Line_Item__c TLit : lstTLitems){
            String key = TLit.AITM_Account__c+'-'+TLit.AITM_Tender__c;
            if(mpUniqId_to_TenderLineItems.containsKey(key)){
                mpUniqId_to_TenderLineItems.get(key).add(TLit);
            } else{
                List<AITM_Tender_Location_Line_Item__c> tmpLst = new List<AITM_Tender_Location_Line_Item__c>();
                tmpLst.add(TLit);
                mpUniqId_to_TenderLineItems.put(key, tmpLst);
            }
        }
        List<AITM_Tender_Location_Line_Item__c> lstTLitemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
        Map<String,String> securityMap = new Map<String,String>();
        List<AITM_Security_Type__mdt> newMapping = [Select Contract_Text__c,AITM_MNMC__c from AITM_Security_Type__mdt LIMIT 15];
        for(AITM_Security_Type__mdt m:newMapping){
            securityMap.put(m.AITM_MNMC__c,m.Contract_Text__c);

        }
        for(AITM_Tender_Account__c tenderAccount : tenderAccounts) {
            String key = tenderAccount.AITM_Account__c+'-'+tenderAccount.AITM_Tender__c;
            if(mpUniqId_to_TenderLineItems.get(key) != null)
                for(AITM_Tender_Location_Line_Item__c TLit : mpUniqId_to_TenderLineItems.get(key)){
                    if(TLit.AITM_Round__c == TLit.AITM_Current_Round__c){
                        TLit.AITM_Payment_Currency__c = tenderAccount.AITM_Payment_Currency__c;
                        TLit.AITM_Security_Type__c = tenderAccount.AITM_Security_Type__c;
                        //AITM_Security_Type__mdt newMapping = [Select Contract_Text__c,AITM_MNMC__c from AITM_Security_Type__mdt where AITM_MNMC__c = :tenderAccount.AITM_Security_Type__c];
                        //TLit.AITM_Security_Text_on_Offer__c = newMapping.Contract_Text__c;
                        TLit.AITM_Security_Text_on_Offer__c = securityMap.get(tenderAccount.AITM_Security_Type__c);
                        TLit.AITM_Credit_Days__c = tenderAccount.AITM_Credit_Days1__c;
                        TLit.AITM_Invoice_Frequency__c = tenderAccount.AITM_Invoice_Frequency__c;                    
                        lstTLitemsToUpdate.add(TLit);
                    }
                }  
        }
        update lstTLitemsToUpdate; 
    }

    /**
     * @description to populate the Bank Account on a AITM_Tender_Account__c record
     * @param tenderAccounts of type List of AITM_Tender_Account__c,oldTenderAccountMapArg of type Map 
     * @return null
     */       
    public static void populateBankAccount(List<AITM_Tender_Account__c> tenderAccounts,Map<Id,AITM_Tender_Account__c> oldTenderAccountMapArg){
        Map<Id,AITM_Tender_Account__c> oldTenderAccountMap = (oldTenderAccountMapArg != null) ? (Map<Id,AITM_Tender_Account__c>)oldTenderAccountMapArg : new Map<Id,AITM_Tender_Account__c>();        
        Set<Id> accountIds = new Set<Id>();
        set<Id> contractingEntityIds = new set<id>();        
        List<AITM_Tender_Account__c> tenderAccountsCheck = new List<AITM_Tender_Account__c>();       
        
        for (AITM_Tender_Account__c tenderAccount : tenderAccounts) {
            AITM_Tender_Account__c oldTA = oldTenderAccountMap.get(tenderAccount.id);
            if(oldTA == null && tenderAccount.AITM_Account__c != null && tenderAccount.AITM_Contracting_Entity__c != null ){
                tenderAccountsCheck.add(tenderAccount);
                accountIds.add(tenderAccount.AITM_Account__c);
                contractingEntityIds.add(tenderAccount.AITM_Contracting_Entity__c);
            } else if(oldTA != null && (tenderAccount.AITM_Account__c != oldTA.AITM_Account__c || tenderAccount.AITM_Contracting_Entity__c != oldTA.AITM_Contracting_Entity__c) ){
                tenderAccountsCheck.add(tenderAccount);
                accountIds.add(tenderAccount.AITM_Account__c);
                contractingEntityIds.add(tenderAccount.AITM_Contracting_Entity__c);
            }   
        }
        
        if(tenderAccountsCheck.size() > 0) {
            Map<Id,Account> accountMap = new Map<Id,Account>([SELECT AITM_Payment_Currency__c,AITM_Preferred_Service_Level__c FROM Account WHERE id IN:accountIds]);
            List<AITM_Contracting_Entity_Bank_Account__c> lstCEBA = [SELECT AITM_Bank_Account__c, AITM_Contracting_Entity__c, AITM_Currency__c FROM AITM_Contracting_Entity_Bank_Account__c WHERE AITM_Contracting_Entity__c IN:contractingEntityIds];            
            Map<id,list<AITM_Contracting_Entity_Bank_Account__c>> mpCEtoCEBAs = new Map<id,list<AITM_Contracting_Entity_Bank_Account__c>>();
            for(AITM_Contracting_Entity_Bank_Account__c ceba : lstCEBA) {
                if(mpCEtoCEBAs.containsKey(ceba.AITM_Contracting_Entity__c)) {
                    mpCEtoCEBAs.get(ceba.AITM_Contracting_Entity__c).add(ceba);
                } else{
                    mpCEtoCEBAs.put(ceba.AITM_Contracting_Entity__c, new AITM_Contracting_Entity_Bank_Account__c[]{ceba});
                }
            }
            
            for(AITM_Tender_Account__c ta: tenderAccountsCheck) {
                Account ac = accountMap.get(ta.AITM_Account__c);
                if(ta.AITM_Account__c == null || ta.AITM_Contracting_Entity__c == null) {
                    ta.AITM_Bank_Account__c = null; 
                } else{
                    
                    if(mpCEtoCEBAs.get(ta.AITM_Contracting_Entity__c) == null) {
                        ta.AITM_Bank_Account__c = null;
                    } else{
                        List<AITM_Contracting_Entity_Bank_Account__c> lstRelatedBankAccount = mpCEtoCEBAs.get(ta.AITM_Contracting_Entity__c);
                        Id selectedBAID;
                        for(AITM_Contracting_Entity_Bank_Account__c ceba : lstRelatedBankAccount){
                            if(ac.AITM_Payment_Currency__c == ceba.AITM_Currency__c) {                                
                                selectedBAID = ceba.AITM_Bank_Account__c;
                            }
                        }
                        
                        if(selectedBAID != null) {
                            ta.AITM_Bank_Account__c = selectedBAID;  
                        }
                    }
                }
                ta.AITM_Preferred_Service_Level__c = ac.AITM_Preferred_Service_Level__c;
            }
        }
        
    }

    /**
     * @description to validate the Affiliates on a AITM_Tender_Account__c record
     * @param tenderAccounts of type List of AITM_Tender_Account__c,oldTenderAccountMapArg of type Map 
     * @return null
     */   
    
    public static void tenderAccountValidateAffiliates(List<AITM_Tender_Account__c> tenderAccounts,Map<Id,AITM_Tender_Account__c> oldTenderAccountMapArg){
        final String INVALID_AFFILIATE_ERROR = Label.AITM_AffiliatesError;
        Map<Id,AITM_Tender_Account__c> oldTenderAccountMap = (Map<Id,AITM_Tender_Account__c>)oldTenderAccountMapArg;
        Set<Id> accountIds = new Set<Id>();
        for(AITM_Tender_Account__c tenderAccountNew : [SELECT AITM_Account__c FROM AITM_Tender_Account__c WHERE AITM_Tender__c = : tenderAccounts[0].AITM_Tender__c]) {
            if(!accountIds.contains(tenderAccountNew.AITM_Account__c)) {
                accountIds.add(tenderAccountNew.AITM_Account__c);	       
            }    
        }
        for (AITM_Tender_Account__c tenderAccount : tenderAccounts) {
            AITM_Tender_Account__c oldTA = oldTenderAccountMap.get(tenderAccount.id);
            if(tenderAccount.AITM_Affiliates_Account__c != oldTA.AITM_Affiliates_Account__c) {
                if (tenderAccount.AITM_Affiliates_Account__c != null && !accountIds.contains(tenderAccount.AITM_Affiliates_Account__c)) {
                    tenderAccount.addError(INVALID_AFFILIATE_ERROR);
                }
            } 
        }
        
        
    }

    /**
     * @description to populate the legal entity details on  AITM_Tender_Account__c record for an account of record type Legal Entity
     * @param tenderAccounts of type List of AITM_Tender_Account__c,oldTenderAccountMap of type Map 
     * @return null
     */    
    
    public static void populateLegalEntityDetails(List<AITM_Tender_Account__c> tenderAccounts, Map<Id,sObject> oldTenderAccountMap){
        String legalEntityRecordId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
        Map<String, String> mapAccountingDetails = new Map<String, String>();
		Map<String,Account> mapLegalDetailsFor5Digit = new Map<String,Account>();
        Map<String, AITM_Tender_Account__c> mapLegalDetails = new Map<String, AITM_Tender_Account__c>();
        Map<String, Id> mapLegalEntityDetails = new Map<String, Id>();
        Set<Id> tenderAccountIds = new Set<Id>();
        for(AITM_Tender_Account__c tenderAccount : tenderAccounts) {
            tenderAccountIds.add(tenderAccount.Id);
        }
        
        for(AITM_Tender_Account__c tenderAccount : [SELECT AITM_Account__r.AITM_GRN__c FROM AITM_Tender_Account__c WHERE Id IN : tenderAccountIds]) {
            if(tenderAccount.AITM_Account__r.AITM_GRN__c != null) {
                mapLegalDetails.put(tenderAccount.AITM_Account__r.AITM_GRN__c.left(5), tenderAccount);
                mapAccountingDetails.put(tenderAccount.AITM_Account__r.AITM_GRN__c, tenderAccount.AITM_Account__r.AITM_GRN__c.left(5));
            }
        }
        
        for(Account acc : [Select AITM_GRN__c,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet FROM Account WHERE AITM_GRN__c IN : mapLegalDetails.keySet() AND RecordTypeId =: legalEntityRecordId]) {
            mapLegalEntityDetails.put(acc.AITM_GRN__c, acc.Id);
			mapLegalDetailsFor5Digit.put(acc.Id,acc);
        }
        
        for(AITM_Tender_Account__c tenderAccount : tenderAccounts) {
            tenderAccount.AITM_Legal_Entity__c = mapLegalEntityDetails.get(mapAccountingDetails.get(tenderAccount.AITM_GRN__c));
			 if(tenderAccount.AITM_Legal_Entity__c !=Null){	
	                	
	                //tenderAccount.1 = Account.Billingdetails from the testmap;	
	                Account a =  mapLegalDetailsFor5Digit.get(tenderAccount.AITM_Legal_Entity__c);	
	                //system.assert(false,a);	
	                    	
	                tenderAccount.AITM_Legal_Entity_BillingCity__c = a.BillingCity;	
	                tenderAccount.AITM_Legal_Entity_BillingCountry__c = a.BillingCountry;	
	                tenderAccount.AITM_Legal_Entity_BillingPostalCode__c = a.BillingPostalCode;	
	                tenderAccount.AITM_Legal_Entity_BillingState__c = a.BillingState;	
	                tenderAccount.AITM_Legal_Entity_BillingStreet__c = a.BillingStreet;	
	                	
	            }
        }
    
        
        
    }

    /**
     * @description to remove the default straddling from related tender location and tender location line items record on deletion of a tender account record
     * @param so of type List of AITM_Tender_Account__c
     * @return null
     */      
    
    public static void removeDefaultStraddling(List<AITM_Tender_Account__c> so){
        Id tenderId;
        List<AITM_Tender_Account__c> tenderAccountToDelete;
        AITM_Tender_Account__c tenderAccount = (AITM_Tender_Account__c) so[0];
        tenderId = tenderAccount.AITM_Tender__c;
        tenderAccountToDelete = new AITM_TenderDao().getTenderAccount(tenderId);
        if (!tenderAccountToDelete.isEmpty()){ 
            updateLocationIfStraddled(tenderAccountToDelete, tenderId);
        }
    }

    /**
     * @description to update the Is Straddled flag as false from related tender location and tender location line items record on deletion of a tender account record
     * @param tenderAccountToDelete of type List of AITM_Tender_Account__c,tenderId of type Id
     * @return null
     */    
    
    public static void updateLocationIfStraddled(List<AITM_Tender_Account__c> tenderAccountToDelete, Id tenderId) {  
        List<AITM_Tender_Location_Line_Item__c> listOfItemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
        List<AITM_Tender_Location__c> listOfLocationsToUpdate = new List<AITM_Tender_Location__c>();
        if(!tenderAccountToDelete.isEmpty() && tenderId != null) {
            List<AITM_Tender_Location__c> tenderLocations = new AITM_LocationsDao().getStraddledTenderLocations(tenderId);
            if(tenderLocations.size() > 0) {
                for(AITM_Tender_Location__c location : tenderLocations) {
                    location.AITM_Is_Straddled__c = false;
                    listOfLocationsToUpdate.add(location);
                    for(AITM_Tender_Location_Line_Item__c lineItem : location.AITM_Tender_Location__r) {
                        lineItem.AITM_Is_Straddled__c = false;
                        lineItem.AITM_Straddled_Taxes_Fees__c = null;
                        lineItem.AITM_Straddled_Additional_Taxes_Fees__c = null;
                        listOfItemsToUpdate.add(lineItem);
                    }
                }
            }
            if(!listOfLocationsToUpdate.isEmpty()) {
                database.update(listOfLocationsToUpdate, false);
            }
            if(!listOfItemsToUpdate.isEmpty()) {
                database.update(listOfItemsToUpdate, false);
            }
        }
    } 

    /*class to  initialize the variable childAccountsByParentId being used in method addChildAccountsToInnerCollection */
    
    private without sharing class ChildAccountsForTenders {
        public Set<Id> tenderIds;
        public List<Account> childAccounts;
        
        public ChildAccountsForTenders() {
            tenderIds = new Set<Id>();
            childAccounts = new List<Account>();
        }
        
        public List<AITM_Tender_Account__c> toTenderAccounts() {
            List<AITM_Tender_Account__c> result = new List<AITM_Tender_Account__c>();
            for (Id tenderId : tenderIds) {
                for (Account childAccount : childAccounts) {
                    result.add(new AITM_Tender_Account__c(
                        AITM_Account__c = childAccount.Id,
                        AITM_Tender__c = tenderId
                    ));
                }
            }
            
            return result;
        }
    }
    
    
    
}