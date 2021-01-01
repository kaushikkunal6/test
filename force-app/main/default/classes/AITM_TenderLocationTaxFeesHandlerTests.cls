/***************************************************************
 * @author          Kunal Kaushik
 * @date             01/Nov/2019
 * @group            AirBP
 * @description      Test class for AITM_TenderLocationTaxFeesHandler
 
  * history
 *01/Nov/2019   	 Kunal      Created
 **********************************************************/
@IsTest 
private class AITM_TenderLocationTaxFeesHandlerTests {
    
    /**
      * @description tests to update Tender Location Taxes and Fees
      * @param  null
      * @return void
      */
    @isTest 
    static void testUpdateTaxFeesRecentlyModifiedAsTrue() {
        TenderLocationTaxFeesTriggerTestSetup testSetup = new TenderLocationTaxFeesTriggerTestSetup();
        List<AITM_Tender_Location_Taxes_and_Fees__c> listOfLocationFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>(); 
        
        AITM_Tender_Location_Taxes_and_Fees__c locationTaxFee = testSetup.locationTaxAndFee;
        locationTaxFee.Name = 'test1';
        locationTaxFee.AITM_Charge_Type__c = 'new';
        locationTaxFee.AITM_Value__c = 2;
        locationTaxFee.AITM_Unit_of_measure__c = 'USX';
        listOfLocationFees.add(locationTaxFee);
        
        AITM_Tender__c tender = testSetup.tender;
        AITM_Tender_Location_Line_Item__c lineItem = testSetup.straddledLineItem;
        
        Test.startTest();
            update listOfLocationFees;
        Test.stopTest();

        System.assertEquals(true, listOfLocationFees[0].Is_Recently_Modified_Loc_Tax_Fee__c);
    }
    
    /**
      * @description tests to update Tender Location Taxes and Fees
      * @param  null
      * @return void
      */
    @isTest 
    static void testUpdateTaxFeesRecentlyModifiedAsFalse() {
        TenderLocationTaxFeesTriggerTestSetup testSetup = new TenderLocationTaxFeesTriggerTestSetup();
        List<AITM_Tender_Location_Taxes_and_Fees__c> listOfLocationFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>(); 
        
        AITM_Tender_Location_Taxes_and_Fees__c locationTaxFee = testSetup.locationTaxAndFee;
        locationTaxFee.Name = 'test';
        locationTaxFee.AITM_Compulsory_Conditional__c = 'Conditional';
        locationTaxFee.Is_Recently_Modified_Loc_Tax_Fee__c = false;
        listOfLocationFees.add(locationTaxFee);
        
        AITM_Tender__c tender = testSetup.tender;
        AITM_Tender_Location_Line_Item__c lineItem = testSetup.straddledLineItem;
        
        Test.startTest();
            update listOfLocationFees;
        Test.stopTest();

        System.assertEquals(false, listOfLocationFees[0].Is_Recently_Modified_Loc_Tax_Fee__c);
    }
    
    /**
      * @description class holds test data preparation
      */
    private class TenderLocationTaxFeesTriggerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public AITM_Tender_Location__c straddledLocation; 
        public AITM_Tender_Location_Line_Item__c straddledLineItem;
        public AITM_Taxes_Fees__c masterTFRecord;
        public AITM_Tender_Location_Taxes_and_Fees__c locationTaxAndFee;
        

        /**
          * @description generates test data
          * @param  null
          * @return TenderLocationTaxFeesTriggerTestSetup
          */
        public TenderLocationTaxFeesTriggerTestSetup(){
            accounts = createAccounts(1);
            insert accounts;
            locations = createLocations(1);
            insert locations;
            tender = createTender();
            insert tender;
            straddledLocation = createStraddledTenderLocation(tender.Id, locations[0].Id);
            insert straddledLocation;
            straddledLineItem = createStraddledTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id, straddledLocation.Id);
            insert straddledLineItem;
            masterTFRecord = createMasterDataTaxesAndFees();
            insert masterTFRecord; 
            locationTaxAndFee = createTenderLocationTaxesAndFee(straddledLineItem.Id);
            insert locationTaxAndFee;
            AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
			settings.AITM_IsActive__c = true;
			upsert settings AITM_DeactivateTriggerSetting__c.Id;
        }

        /**
          * @description creates tender location
          * @param  null
          * @return void
          */
        public void createTenderLocations() {
            insert createTenderAccount(tender.Id, accounts[0].Id);
            insert createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, new List<Account>{accounts[0]}, locations);  
        }
    }
}