/***************************************************************
 * @author           Ravi
 * @date             25/October/2019
 * @group            AirBP
 * @description      Test class for AITM_TenderLocationTaxFeesTrigger

 * history
 *25/October/2019   	 Ravi      Created
 **********************************************************/
@isTest 
public inherited sharing class AITM_TenderLocationTaxFeesTriggerTests {

    /**
      * @description tests to insert and update Tender Location Taxes and Fees
      * @param  null
      * @return void
      */
    @isTest 
    static void testTenderLocationTaxFeesTriggerUpdateValues() {
        TenderLocationTaxFeesTriggerTestSetup testSetup = new TenderLocationTaxFeesTriggerTestSetup();
        List<AITM_Tender_Location_Taxes_and_Fees__c> listOfLocationFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>(); 
        
        AITM_Tender_Location_Taxes_and_Fees__c locationTaxFee = testSetup.locationTaxAndFee;
        locationTaxFee.Name = 'locationTaxFee';
        locationTaxFee.Is_Recently_Modified_Loc_Tax_Fee__c = false;
        listOfLocationFees.add(locationTaxFee);
        
        Test.startTest();
            if(!listOfLocationFees.isEmpty()){
                update listOfLocationFees;
            }
        Test.stopTest();

        System.assertEquals('locationTaxFee', listOfLocationFees[0].Name);
    }

    /**
      * @description class holds test data preparation
      */
    private inherited sharing class TenderLocationTaxFeesTriggerTestSetup extends AITM_TestSetup {
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
            accounts = createAccounts(10);
            insert accounts;
            locations = createLocations(10);
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