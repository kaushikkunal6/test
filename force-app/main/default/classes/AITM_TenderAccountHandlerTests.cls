/***************************************************************
 * @author           Shweta
 * @date             31/March/2020
 * @group            AirBP
 * @description      Test class for AITM_TenderAccountHandler

 * history
 * 31/March/2020 	 Shweta      Created 
 **********************************************************/
@isTest 
private  inherited sharing class AITM_TenderAccountHandlerTests {

    public static final Integer ACCOUNTS_SIZE = 20; 
    public static final Integer TENDER_SIZE = 4;

     /**
      * @description tests to insert tender accounts with  hierarchy 
      * @param  null
      * @return void
      */
    @isTest 
    static void testTenderAccountsSingleInsertionForHierarchyWillAlsoInsertHierarchyAccounts() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Payment_Currency__c = 'USD';
        singleTenderAccount.AITM_Credit_Days1__c = '2';
        singleTenderAccount.AITM_Invoice_Frequency__c = 'Daily';        
        List<AITM_Tender_Account__c> insertTenderAccount = new List<AITM_Tender_Account__c>();
        insertTenderAccount.add(singleTenderAccount);
        testSetup.createTenderLocationLineItems();   
        
        Test.startTest();
            AITM_Tender_Account_Helper.addChildAccountsToInnerCollection(insertTenderAccount,null);            
        Test.stopTest();      
        
        System.assertEquals(19, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tenders[0].Id], 'All Accounts Should Be Shared');
    }

     /**
      * @description tests to insert tender accounts without  hierarchy 
      * @param  null
      * @return void
      */

    @isTest 
    static void testTenderAccountsSingleInsertionWithoutHierarchyWillOnlyInsertThisAccount() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id;

        Test.startTest();
            insert singleTenderAccount;
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tenders[0].Id], 'Only One Account Should Be Shared');
    }

     /**
      * @description tests to insert tender accounts in bulk inserting only valid tender accounts
      * @param  null
      * @return void
      */

    @isTest 
    static void testTenderAccountsBulkInsertionWillInsertValidNumberOfTenderAccounts() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
        
        Test.startTest();
            insert testSetup.tenderAccounts;
        Test.stopTest();
        
        System.assertEquals(ACCOUNTS_SIZE*TENDER_SIZE, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c IN :testSetup.tenders], 'All Accounts Should Be Shared For All Tenders');
    }

     /**
      * @description tests to not to insert duplicates on a tender
      * @param  null
      * @return void
      */

    @isTest 
    static void testTenderAccountsOnInsertWillNotCreateDuplicates() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id;
        insert singleTenderAccount;
        AITM_Tender_Account__c headTenderAccount = testSetup.createSingleTenderAccounts();
        List<AITM_Tender_Account__c> tenderAccounts = new List<AITM_Tender_Account__c>();
        tenderAccounts.add(headTenderAccount);
        
        Test.startTest();
            AITM_Tender_Account_Helper.checkForDuplicates(tenderAccounts);            
        Test.stopTest();     
        
        System.assertEquals(1, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tenders[0].Id]);
    }

     /**
      * @description tests to update the inserted Tender Account without any error
      * @param  null
      * @return void
      */    

    @isTest 
    static void testUpdateWillWorkWithoutErrors() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id;
        insert singleTenderAccount;

        Test.startTest();
            singleTenderAccount.AITM_Credit_Days__c = 2;     
            update singleTenderAccount;
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tenders[0].Id AND AITM_Credit_Days__c = 2 AND AITM_Security_Type__c = 'BG - Bank Guarantee']);
    }

    /**
      * @description tests to delete the inserted Tender Account without any error
      * @param  null
      * @return void
      */       

    @isTest 
    static void testDeletionWillWorkWithoutErrors() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id;
        insert singleTenderAccount;
        List<AITM_Tender_Account__c> tenderAccounts = new List<AITM_Tender_Account__c>();
        tenderAccounts.add(singleTenderAccount);
        testSetup.createTenderLocationLineItems();
        System.assertEquals(testSetup.tenderLocations.size(),[SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE Id IN :testSetup.tenderLocations]);
        Test.startTest();
        AITM_Tender_Account_Helper.TenderAccountDeleteRelatedLineItems(tenderAccounts);
        Test.stopTest();
        System.assertEquals(19,[SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE Id IN :testSetup.tenderLocations]); 
        
    }

    /**
      * @description tests to populate the bank account on a tender account record
      * @param  null
      * @return void
      */   
    @isTest
    static void populateBankAccount() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();      
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Payment_Currency__c = 'USD';  
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id;
        singleTenderAccount.AITM_Contracting_Entity__c = testSetup.contractingEntities.Id; 
        insert singleTenderAccount;
        AITM_Contracting_Entity_Bank_Account__c newEntity = new AITM_Contracting_Entity_Bank_Account__c();
        newEntity.Name = 'Test Entity';
        newEntity.AITM_Contracting_Entity__c = testSetup.contractingEntities.Id; 
        newEntity.AITM_Bank_Account__c = testSetup.bankAccount.Id;        
        insert newEntity;         
        List<AITM_Tender_Account__c> tenderAccounts = new List<AITM_Tender_Account__c>();
        tenderAccounts.add(singleTenderAccount);
        Map<Id,AITM_Tender_Account__c> oMap = new Map<Id,AITM_Tender_Account__c>();
       
       
        Test.startTest();
        AITM_Tender_Account_Helper.populateBankAccount(tenderAccounts,Null);
        Test.stopTest();
        System.assertEquals(1,[SELECT Count() FROM AITM_Tender_Account__c WHERE Id = :singleTenderAccount.Id AND AITM_Bank_Account__c = NULL]); 
 
    }

    /**
      * @description tests to populate the Legal Entity Details in a tender account record
      * @param  null
      * @return void
      */   
     @isTest
    static void PopulateLegalEntityDetails(){
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
      
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id;
        singleTenderAccount.AITM_Contracting_Entity__c = testSetup.contractingEntities.Id;    
        
        insert singleTenderAccount;
        List<AITM_Tender_Account__c> tenderAccounts = new List<AITM_Tender_Account__c>();
        tenderAccounts.add(singleTenderAccount);
        Map<Id,AITM_Tender_Account__c> oMap = new Map<Id,AITM_Tender_Account__c>();
        oMap.put(singleTenderAccount.Id,null);       
        Test.startTest();
        AITM_Tender_Account_Helper.PopulateLegalEntityDetails(tenderAccounts,oMap);
        Test.stopTest();
        System.assertEquals(1,[SELECT Count() FROM AITM_Tender_Account__c WHERE Id =:singleTenderAccount.Id AND AITM_Legal_Entity__c = NULL]); 
        
        
    }

    /**
      * @description tests to check the correct ffiliates of a tender account populating
      * @param  null
      * @return void
      */   
    
    @isTest
    static void TenderAccountValidateAffiliates(){
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
      
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id; 
        insert singleTenderAccount;
        List<AITM_Tender_Account__c> tenderAccounts = new List<AITM_Tender_Account__c>();
        tenderAccounts.add(singleTenderAccount);
        Map<Id,AITM_Tender_Account__c> oMap = new Map<Id,AITM_Tender_Account__c>();
        oMap.put(singleTenderAccount.Id,singleTenderAccount);       
        Test.startTest();
        AITM_Tender_Account_Helper.TenderAccountValidateAffiliates(tenderAccounts,oMap);
        Test.stopTest();
        System.assertEquals(1,[SELECT Count() FROM AITM_Tender_Account__c WHERE Id =:singleTenderAccount.Id AND AITM_Affiliates_Account__c = NULL]); 
        
    }
    @isTest

    /**
      * @description tests to check the that the default straddling has been removed from a tender location and tender line item on deletion of a tender customer record
      * @param  null
      * @return void
      */     
    static void RemoveDefaultStraddling(){
         TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();      
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id;          
        insert singleTenderAccount;
        List<AITM_Tender_Account__c> tenderAccounts = new List<AITM_Tender_Account__c>();
        tenderAccounts.add(singleTenderAccount);
        testSetup.createTenderLocations();        
        Test.startTest();
        AITM_Tender_Account_Helper.RemoveDefaultStraddling(tenderAccounts);
        Test.stopTest();
        System.assertEquals(1,[SELECT Count() FROM AITM_Tender_Location__c WHERE AITM_Tender__c =:singleTenderAccount.AITM_Tender__c AND AITM_Is_Straddled__c = false]); 
        
    }

    /**
      * @description class holds test data preparation
      */
    private inherited sharing class TenderAccountHandlerTestSetup extends AITM_TestSetup {
        public List<AITM_Tender_Account__c> tenderAccounts;
        public List<Account> accountHierarchy;
        public List<AITM_Tender__c> tenders;
        public List<AITM_Location__c> locations;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        public AITM_Tender_Location__c tenderLocationsForStraddled;
        public AITM_Contracting_Entity__c contractingEntities;
        public AITM_Bank_Account__c bankAccount;

        
        /**
          * @description generates test data
          * @param  null
          * @return TenderAccountHandlerTestSetup
          */
        
        public TenderAccountHandlerTestSetup generateData(){
            tenders = createTenders(AITM_TenderAccountHandlerTests.TENDER_SIZE);
            insert tenders;
            contractingEntities = createContractingEntity();
            insert contractingEntities;
            bankAccount = createBankAccounts();
            insert bankAccount;           
            accountHierarchy = createAccounts(AITM_TenderAccountHandlerTests.ACCOUNTS_SIZE);
            
            for (Account acc :accountHierarchy) {
              acc.AITM_Security_Type__c = 'BG - Bank Guarantee'; 
              
            }
           
            insert accountHierarchy;
            locations = createLocations(1);
            insert locations;
            updateAccountsToFormHierarchy();
            tenderAccounts = createTenderAccounts(tenders, accountHierarchy);            
            return this;
        }

         /**
          * @description update the accounts
          * @param  null
          * @return void
          */

        public void updateAccountsToFormHierarchy() {
            for (Integer index = 1; index < accountHierarchy.size(); index++) {
                accountHierarchy[index].ParentId = accountHierarchy[0].Id;
            }
            update accountHierarchy;
        }

         /**
          * @description creates single tender Accounts
          * @param  null
          * @return AITM_Tender_Account__c
          */

        public AITM_Tender_Account__c createSingleTenderAccounts() {
            return new AITM_Tender_Account__c(AITM_Account__c = accountHierarchy[0].Id, AITM_Tender__c = tenders[0].Id);
        }

        /**
          * @description creates  tender Accounts without account hierarchy
          * @param  null
          * @return AITM_Tender_Account__c
          */

        public AITM_Tender_Account__c createTenderAccountWithoutAccountsHierarchy() {
            Account parentAccount = super.createAccount();
            insert parentAccount;
            return super.createTenderAccount(tenders[0].Id, parentAccount.Id);
        }

        /**
          * @description creates Tender Location Line Items records
          * @param  null
          * @return null
          */      

        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tenders[0]}, accountHierarchy, new List<AITM_Location__c>{locations[0]});
            insert tenderLocations;
        }

        /**
          * @description creates tender locations records
          * @param  null
          * @return null
          */
        public void createTenderLocations(){
            
            tenderLocationsForStraddled = createStraddledTenderLocation(tenders[0].Id,locations[0].Id);
            insert tenderLocationsForStraddled;
        }

    
         /** @description creates contracting entity record
          * @param  null
          * @return AITM_Contracting_Entity__c
          */        
        public  AITM_Contracting_Entity__c createContractingEntity(){
            AITM_Contracting_Entity__c c = new AITM_Contracting_Entity__c();
            c.Name = 'Test';
            return c;
        }

        /**
          * @description creates bank account record
          * @param  null
          * @return AITM_Bank_Account__c
          */        
        public AITM_Bank_Account__c createBankAccounts(){
            AITM_Bank_Account__c b = new AITM_Bank_Account__c();
            b.Name = 'First';
            b.AITM_Currency__c ='USD';
            return b;
        }
    }

}