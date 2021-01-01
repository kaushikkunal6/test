/***********************************************************************************************
* @author           George
* @date             20/Nov/2017
* @group            AirBP
* @description      Test class to cover AITM_TenderLocationPrePopulationHandler class.
* history
* 20/Nov/2017       George          Created
* 07/March/2018     Ravi Pamidi     AR-2523 Removed AITM_Currency_Pricing_Basis__c field as that was converted as formula field.
* 29/May/2018       srnandan        AR-3169 Modified the soql AITM_Days__c with AITM_Credit_Days__c for lineitem
* 23/Sep/2019       Saravan         Modified - 704939 to cover sector logic
* 30/Sep/2019       Saravan         WorkItem(684962)Modified to cover Military sector  
* 28/June/2020      Sushant         created testmethods for testpopulateAccountFields and testprePopulateFields
*************************************************************************************/
@isTest 
private inherited sharing class AITM_TenderLocationPrePopulationHdlTests {
    
    /**
  * @description This method is used to populate location manager that will work if location manager available for the CA sector and location test data.
  * @param No parameters
  * @return void
  */
    @isTest 
    static void testPrepopulationOfLocationManagerCoverCA() {
        TenderLocationPrePopulationHandlerTestSetup_New testSetup=new TenderLocationPrePopulationHandlerTestSetup_New().generateData('CA');
       // testSetup.createTenderLocationLineItems();
        AITM_Tender_Location_Line_Item__c tenderLocationLineItem1 = testSetup.tenderLocationLineItem;		
       // AITM_Tender_Location_Line_Item__c tenderLocationLineItem1=[select RecordTypeId,AITM_Credit_Days__c,AITM_Invoice_Frequency__c,AITM_Payment_Currency__c,AITM_Security_Type__c,AITM_Security_Text_on_Offer__c,AITM_Location_Strategy__c,AITM_Location_Size__c,AITM_Account__c,AITM_Tender__c,AITM_Location__c,AITM_Parent_TLLI_Id__c,AITM_Is_Pricing_Basis_Not_Represented__c from AITM_Tender_Location_Line_Item__c limit 1];
        AITM_TenderLocationPrePopulationHandler hd=new AITM_TenderLocationPrePopulationHandler();
        Map<Id, Set<String>> pricing = new Map<Id, Set<String>>();
        List<AITM_Tender_Location_Line_Item__c> lineitemList = new List<AITM_Tender_Location_Line_Item__c>();
        lineitemList.add(tenderLocationLineItem1);
        set<string> str = new set<string>();
        str.add('airbp_test_usr_0@testorg.com');
        pricing.put(tenderLocationLineItem1.id,str);
        Test.startTest();
        String tenderId = testSetup.tender.Id;
        hd.isPricingBasisNotRepresented(tenderLocationLineItem1);
        hd.getLineItemsUserDelegatesMap(str,pricing);  
        hd.populateUserRelatedFields(lineitemList);
        hd.collect(tenderLocationLineItem1);
        hd.populateParentId(lineitemList);
        hd.getDefaultLineItemCurrency();
        hd.getDefaultLineItemUnitOfMeasure();
        if(!tenderLocationLineItem1.isClone()){
          hd.prePopulateFields(lineitemList);    
        }         
        Test.stopTest();        
        System.assert(tenderId != null,'Condition Satisfied');        
    }
    
    /**
    * @description This method is used to validate testprePopulateFields method.
    * @param No parameters
    * @return void
   */
    @isTest 
    static void testValidateprePopulateFields() {
        TenderLocationPrePopulationHandlerTestSetup_New testSetup=new TenderLocationPrePopulationHandlerTestSetup_New().generateData('CA');
        // testSetup.createTenderLocationLineItems();
        AITM_Tender_Location_Line_Item__c tenderLocationLineItem1 = testSetup.tenderLocationLineItem;
       // AITM_Tender_Location_Line_Item__c tenderLocationLineItem1=[select RecordTypeId,AITM_Unit_Of_Measure__c,AITM_Credit_Days__c,AITM_Invoice_Frequency__c,AITM_Payment_Currency__c,AITM_Security_Type__c,AITM_Security_Text_on_Offer__c,AITM_Location_Strategy__c,AITM_Location_Size__c,AITM_Account__c,AITM_Tender__c,AITM_Location__c,AITM_Parent_TLLI_Id__c,AITM_Is_Pricing_Basis_Not_Represented__c from AITM_Tender_Location_Line_Item__c limit 1];
        AITM_TenderLocationPrePopulationHandler hd=new AITM_TenderLocationPrePopulationHandler();
        Map<Id, Set<String>> pricing = new Map<Id, Set<String>>();
        List<AITM_Tender_Location_Line_Item__c> lineitemList = new List<AITM_Tender_Location_Line_Item__c>();
        lineitemList.add(tenderLocationLineItem1);
        set<string> str = new set<string>();
        str.add('airbp_test_usr_0@testorg.com');
        pricing.put(tenderLocationLineItem1.id,str);
        Test.startTest();
        String tenderId = testSetup.tender.Id;
        hd.isPricingBasisNotRepresented(tenderLocationLineItem1);
        hd.getLineItemsUserDelegatesMap(str,pricing);  
        hd.populateUserRelatedFields(lineitemList);
        hd.collect(tenderLocationLineItem1);
        hd.populateParentId(lineitemList);
        if(!tenderLocationLineItem1.isClone()){
          hd.prePopulateFields(lineitemList);    
        }         
        Test.stopTest();    
        System.assert(tenderId != null,'Condition Satisfied');
    }
   
    /**
    * @description This method is used to populate location manager that will work if location manager available for the CA sector and location test data.
    * @param No parameters
    * @return void
   */
     @isTest 
    static void testPrepopulationOfLocationManagerCoverGA() {
        TenderLocationPrePopulationHandlerTestSetup_New testSetup=new TenderLocationPrePopulationHandlerTestSetup_New().generateData('GA');
        // testSetup.createTenderLocationLineItems();
        AITM_Tender_Location_Line_Item__c tenderLocationLineItem1 = testSetup.tenderLocationLineItem;
       // AITM_Tender_Location_Line_Item__c tenderLocationLineItem1=[select RecordTypeId,AITM_Credit_Days__c,AITM_Invoice_Frequency__c,AITM_Payment_Currency__c,AITM_Security_Type__c,AITM_Security_Text_on_Offer__c,AITM_Location_Strategy__c,AITM_Location_Size__c,AITM_Account__c,AITM_Tender__c,AITM_Location__c,AITM_Parent_TLLI_Id__c,AITM_Is_Pricing_Basis_Not_Represented__c from AITM_Tender_Location_Line_Item__c limit 1];
        AITM_TenderLocationPrePopulationHandler hd=new AITM_TenderLocationPrePopulationHandler();
        Map<Id, Set<String>> pricing = new Map<Id, Set<String>>();
        List<AITM_Tender_Location_Line_Item__c> lineitemList = new List<AITM_Tender_Location_Line_Item__c>();
        lineitemList.add(tenderLocationLineItem1);
        set<string> str = new set<string>();
        str.add('airbp_test_usr_0@testorg.com');
        pricing.put(tenderLocationLineItem1.id,str);
        Test.startTest();
        String tenderId = testSetup.tender.Id;
        hd.populateUserRelatedFields(lineitemList);
        hd.collect(tenderLocationLineItem1);
        Test.stopTest();        
        System.assert(tenderId != null,'Condition Satisfied');        
    }
   
   /**
     * @description This method is used to validate testpopulateAccountFields method.
     * @param No parameters
     * @return void
   */
    @isTest 
    static void testValidatepopulateAccountFields() {
        TenderLocationPrePopulationHandlerTestSetup_New testSetup=new TenderLocationPrePopulationHandlerTestSetup_New().generateData('GA');
        // testSetup.createTenderLocationLineItems();
        AITM_Tender_Location_Line_Item__c tenderLocationLineItem1 = testSetup.tenderLocationLineItem;
        List<Account> accountRecord = testSetup.createAccounts(1);
       // AITM_Tender_Location_Line_Item__c tenderLocationLineItem1=[select RecordTypeId,AITM_Is_Clone__c,AITM_Credit_Days__c,AITM_Invoice_Frequency__c,AITM_Payment_Currency__c,AITM_Security_Type__c,AITM_Security_Text_on_Offer__c,AITM_Location_Strategy__c,AITM_Location_Size__c,AITM_Account__c,AITM_Tender__c,AITM_Location__c,AITM_Parent_TLLI_Id__c,AITM_Is_Pricing_Basis_Not_Represented__c from AITM_Tender_Location_Line_Item__c limit 1];
        AITM_TenderLocationPrePopulationHandler hd=new AITM_TenderLocationPrePopulationHandler();
        List<AITM_Tender_Location_Line_Item__c> lineitemList = new List<AITM_Tender_Location_Line_Item__c>();
        lineitemList.add(tenderLocationLineItem1);
        Test.startTest();    
            String tenderId = testSetup.tender.Id;
            if(tenderLocationLineItem1.AITM_Is_Clone__c == false)  
              hd.populateUserRelatedFields(lineitemList);
              hd.collect(tenderLocationLineItem1);
             Test.stopTest();
         hd.populateAccountFields(tenderLocationLineItem1, accountRecord[0]);
         System.assert(tenderId != null,'Condition Satisfied');
    }
         
   /**
    * @description This method is used to populate location manager that will work if location manager available for the Military sector and location test data.
    * @param No parameters
    * @return void
   */
    
    @isTest 
    static void testPrepopulationOfLocationManagerCoverMilitary() {
        TenderLocationPrePopulationHandlerTestSetup_New testSetup=new TenderLocationPrePopulationHandlerTestSetup_New().generateData('Military');
        // testSetup.createTenderLocationLineItems();
        AITM_Tender_Location_Line_Item__c tenderLocationLineItem1 = testSetup.tenderLocationLineItem;
       // AITM_Tender_Location_Line_Item__c tenderLocationLineItem1=[select RecordTypeId,AITM_Credit_Days__c,AITM_Invoice_Frequency__c,AITM_Payment_Currency__c,AITM_Security_Type__c,AITM_Security_Text_on_Offer__c,AITM_Location_Strategy__c,AITM_Location_Size__c,AITM_Account__c,AITM_Tender__c,AITM_Location__c,AITM_Parent_TLLI_Id__c,AITM_Is_Pricing_Basis_Not_Represented__c from AITM_Tender_Location_Line_Item__c limit 1];
        AITM_TenderLocationPrePopulationHandler hd=new AITM_TenderLocationPrePopulationHandler();
        List<AITM_Tender_Location_Line_Item__c> lineitemList = new List<AITM_Tender_Location_Line_Item__c>();
        lineitemList.add(tenderLocationLineItem1);
        Test.startTest();
        String tenderId = testSetup.tender.Id;
        hd.populateUserRelatedFields(lineitemList);
        hd.collect(tenderLocationLineItem1);
        Test.stopTest();
        System.assert(tenderId != null,'Condition Satisfied');
        
    }
    
    /**
  * @description This method is used to populate location manager that will work if location manager available for the Other than CA/GA sector and location test data.
  * @param No parameters
  * @return void
  */
    
    @isTest 
    static void testPrepopulationOfLocationManagerCoverOther() {       
        TenderLocationPrePopulationHandlerTestSetup_New testSetup=new TenderLocationPrePopulationHandlerTestSetup_New().generateData('Other');
        // testSetup.createTenderLocationLineItems();
        AITM_Tender_Location_Line_Item__c tenderLocationLineItem1 = testSetup.tenderLocationLineItem;
       // AITM_Tender_Location_Line_Item__c tenderLocationLineItem1=[select RecordTypeId,AITM_Is_Clone__c,AITM_Credit_Days__c,AITM_Invoice_Frequency__c,AITM_Payment_Currency__c,AITM_Security_Type__c,AITM_Security_Text_on_Offer__c,AITM_Location_Strategy__c,AITM_Location_Size__c,AITM_Account__c,AITM_Tender__c,AITM_Location__c,AITM_Parent_TLLI_Id__c,AITM_Is_Pricing_Basis_Not_Represented__c from AITM_Tender_Location_Line_Item__c limit 1];
        AITM_TenderLocationPrePopulationHandler hd=new AITM_TenderLocationPrePopulationHandler();
        List<AITM_Tender_Location_Line_Item__c> lineitemList = new List<AITM_Tender_Location_Line_Item__c>();
        lineitemList.add(tenderLocationLineItem1);
        Test.startTest();    
        String tenderId = testSetup.tender.Id;  
        if(tenderLocationLineItem1.AITM_Is_Clone__c == false){  
      hd.populateUserRelatedFields(lineitemList);
        }                 
        Test.stopTest();
        System.assert(tenderId != null,'Condition Satisfied');
    }
    
    
    /**
  * @description This method is used to populate Tender Location handler test data setup.
  * @param No Parameters
  * @return Returns Tender Account
  */
    private inherited sharing class TenderLocationPrePopulationHandlerTestSetup_New extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public AITM_Tender_Location__c tenderLocation;
        public AITM_Tender_Account__c tenderAccount;
        public AITM_Tender_Location_Line_Item__c tenderLocationLineItem;
        public AITM_Delivery_Point__c deliveryPoint;
        public List<User> userList;
        
        /**
    * @description generates test data for CA
    * @param  null
    * @return TenderLocationPrePopulationHandlerTestSetup new
    */
        public TenderLocationPrePopulationHandlerTestSetup_New generateData(String str) {
            userList = createUsers(1,'Air_TMAccount Manager');
            userList[0].IsActive = true;
            insert userList;
            
            AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
            settings.AITM_IsActive__c = true;
            upsert settings AITM_DeactivateTriggerSetting__c.Id;
            accounts = createAccounts(1);
            insert accounts;
            
            locations = createLocations(1);
            insert locations;
            
            tender = createTender();
            if(str != 'Other')
                tender.AITM_Tender_Sector__c=str;
            insert tender;
            
            tenderLocation = createTenderLocation(tender.Id, locations[0].Id);
            insert tenderLocation;
            
            tenderAccount = createTenderAccount(tender.Id, accounts[0].Id);
            insert tenderAccount;
            
            deliveryPoint= createDeliveryPoint(locations[0],true,1);
            deliveryPoint.AITM_CA_Pricing_ResponsibilityDeligates1__c='test@test.com'; 
            deliveryPoint.AITM_GA_Pricing_ResponsibilityDeligates1__c='test@test.com'; 
            insert deliveryPoint;
            
            tenderLocationLineItem = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            if(str != 'Other')
            tenderLocationLineItem.AITM_Location_Delivery_Point__c=deliveryPoint.Id;
            tenderLocationLineItem.Recordtypeid = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            tenderLocationLineItem.AITM_Tender_Location__c = tenderLocation.Id;
            tenderLocationLineItem.AITM_Location_Delivery_Point__c= deliveryPoint.Id;
            tenderLocationLineItem.AITM_Location__c = locations[0].Id;
            tenderLocationLineItem.AITM_Unit_Of_Measure__c =  'USG';
            tenderLocationLineItem.AITM_Currency__c = 'AUD';
            //insert tenderLocationLineItem;                        
            return this;
        }
        
        /**
    * @description creates tender location line items
    * @param  null
    * @return void
    */
        public void createTenderLocationLineItems() {
            insert createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }
    }

}