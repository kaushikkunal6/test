/***************************************************************
 * @author           Shweta
 * @date             31/July/2019
 * @group            AirBP
 * @description      Test class for AITM_InsertTLLIBatch

 * history
 *31/July/2019   	 Shweta      Created
 **********************************************************/
@isTest
public inherited sharing class AITM_CloneTLLIBatchTest {

    /**
      * @description tests to run the batch
      * @param  null
      * @return void
      */
     @isTest  
    static void testInsertBatchGeneration() {
        CloneTenderLocationLineItemBatch testSetup = new CloneTenderLocationLineItemBatch().generateData();      
        List<AITM_Tender_Location__c> allTenderLocationLineItems = testSetup.tenderLocations;
        Map<Id,AITM_Tender_Location__c> newTenderLocationsByOldIds = new Map<Id,AITM_Tender_Location__c>();
        for(AITM_Tender_Location__c t1:allTenderLocationLineItems){
           newTenderLocationsByOldIds.put(t1.Id,t1) ;
        }
        map<string,id> mapOfNewTlli = new map<string,id>();
        list<AITM_Tender_Location_Taxes_and_Fees__c> listTenderTaxAndFee = new list<AITM_Tender_Location_Taxes_and_Fees__c>();
          for(AITM_Tender_Location_Line_Item__c tlli: testSetup.tenderLocationLineItems){
             mapOfNewTlli.put(tlli.AITM_IATA_Internal_Code__c+tlli.AITM_GRN__c+tlli.AITM_Tender__c, tlli.id);  
            }
        
        AITM_CloneTLLIBatch batches = new AITM_CloneTLLIBatch(newTenderLocationsByOldIds,allTenderLocationLineItems);
        Test.startTest();
            Database.executeBatch(batches);
			Database.executeBatch(new AITM_TenderLocationTaxFeeCloneBatch(testSetup.tender.Id,1,mapOfNewTlli));
       
        Test.stopTest();
		System.assertEquals(10, allTenderLocationLineItems.size(), 'Batch processing is success');
    }


    /**
      * @description class holds test data preparation
      */
     private inherited sharing class CloneTenderLocationLineItemBatch extends AITM_TestSetup {
          // variable to hold list of Accounts
        private List<Account> accounts;
        // variable to hold list of Accounts
        private List<AITM_Location__c> locations;
        // variable to hold list of Accounts
        private AITM_Tender__c tender;
        // variable to hold list of Accounts
        private List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        // variable to hold list of Accounts
        private List<AITM_Tender_Location__c> tenderLocations;
		// variable to hold list of tnf
        private List<AITM_Tender_Location_Taxes_and_Fees__c> tenderLocationTnF;
        // variable to hold list of Accounts
        private List<User> locationManagers;
        // variable to hold list of Accounts
        private List<User> delegates;        
     
    /**
      * @description generates test data
      * @param  null
      * @return InsertTenderLocationLineItemsBatch
      */
        private CloneTenderLocationLineItemBatch generateData(){

            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
			tender.AITM_Tender_Sector__c ='GA';
            insert tender;

            createTenderAccounts();

            locationManagers = createUsers(10, 'Air_TMLocation Manager');
            insert locationManagers;

            tenderLocations = createTenderLocations();
            insert tenderLocations;
			
			tenderLocationLineItems = createTenderLocationLineItems(tenderLocations);
            insert tenderLocationLineItems;
     
            tenderLocationTnF = createnewTnF();
            insert tenderLocationTnF;
                 
            attachLocationManagersToTenderLocations(locationManagers, tenderLocations);
            attachLocationManagersToTenderLocationLineitems(locationManagers,tenderLocationLineItems);

            return this;
        }
    /**
      * @description creates tender locations
      * @param  null
      * @return List collection of type AITM_Tender_Location__c
      */
        private List<AITM_Tender_Location__c> createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
            for(AITM_Location__c location : locations){
                AITM_Tender_Location__c tenderLocation = createTenderLocation(tender.Id, location.Id);
                tenderLocation.AITM_Status__c = 'Priced';
				tenderLocation.AITM_current_round__c = 1;
                tenderLocations.add(tenderLocation);
            }
            return tenderLocations;
        }
		
	 /**
      * @description creates tender locations
      * @param  null
      * @return List collection of type AITM_Tender_Location_Tax_n_Fee__c
      */
        private List<AITM_Tender_Location_Taxes_and_Fees__c> createnewTnF() {
           List<AITM_Tender_Location_Taxes_and_Fees__c> tfList = new  List<AITM_Tender_Location_Taxes_and_Fees__c>();
           for(AITM_Tender_Location_Line_Item__c tlli: tenderLocationLineItems){
           AITM_Tender_Location_Taxes_and_Fees__c tf = new  AITM_Tender_Location_Taxes_and_Fees__c();
            	tf.Tender_Location_Line_Item_Id__c = tlli.Id;
            	tf.AITM_Level__c = 'Country';
                tf.AITM_FEE_TAX_GROUP__c = 'Duties and Taxes';
                tf.AITM_FEE_TAX_NAME__c = 'Excise Duty 110 Jet';
                tf.AITM_Charge_Type__c = 'Variable';
                tf.AITM_Value__c = 52.343;
                tf.AITM_Display_Currency__c = 'GBX';
                tf.AITM_Compulsory_Conditional__c = 'Conditional';
                tf.AITM_Unit_of_measure__c = '	Litres';
                tf.AITM_Record_Type_Name__c ='Default';
                tf.AITM_Tender_Sector__c = 'GA';
                tf.AITM_Fuel_Type__c =  'Jet';
                tf.Name ='Value Added Tax (VAT)';
                tf.AITM_Select_to_Apply_in_Contract__c = true;
                tfList.add(tf);
            }
            return tfList;
        }
    /**
      * @description attach location managers to tender locations
      * @param  locationManagers list collection of users
      * @param  tenderLocations list collection of AITM_Tender_Location__c
      * @return void
      */
        private void attachLocationManagersToTenderLocations(List<User> locationManagers, List<AITM_Tender_Location__c> tenderLocations) {

            List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
            Integer index = 0;

            for(AITM_Tender_Location__c tenderLocation : tenderLocations){
                tenderLocation.AITM_Location_Manager__c = locationManagers[index].Id;
                result.add(tenderLocation);
                index++;
            }

            upsert result;

        }
    /**
      * @description attach location managers to tender locations
      * @param  locationManagers list collection of users
      * @param  tenderLocations list collection of AITM_Tender_Location_Line_Item__c
      * @return void
      */
        private void attachLocationManagersToTenderLocationLineitems(List<User> locationManagers, List<AITM_Tender_Location_Line_Item__c> tenderLocations) {

            List<AITM_Tender_Location_Line_Item__c> result = new List<AITM_Tender_Location_Line_Item__c>();
            Integer index = 0;

            for(AITM_Tender_Location_Line_Item__c tenderLocation : tenderLocations){
                tenderLocation.OwnerId = locationManagers[index].Id;
                result.add(tenderLocation);
                index++;
            }

            upsert result;

        }
    /**
      * @description creates tender accounts
      * @param  null
      * @return void
      */
        private void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }
    /**
      * @description creates tenderlocationitems
      * @param  null
      * @return void
      */
       private List<AITM_Tender_Location_Line_Item__c> createTenderLocationLineItems(list<AITM_Tender_Location__c> tenderLocations) {
          
             Integer index = 0;
              List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = new List<AITM_Tender_Location_Line_Item__c>();
            for(AITM_Tender_Location__c tenderLocation : tenderLocations){
                AITM_Tender_Location_Line_Item__c result= createTenderLocationLineItem(tender.Id, accounts[0].id,tenderLocation.AITM_Location__c,tenderLocation.id);
                tenderLocationLineItems.add(result);
                index++;
            }
            
            return tenderLocationLineItems;
        }
    /**
      * @description creates tenderlocationlineitem
      * @param  tenderId of type Id
      * @param  accountId of type Id
      * @return AITM_Tender_Location_Line_Item__c
      */
        private AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0,
				AITM_Round__c = 1,
                AITM_Offered_Volume__c = 1,
                RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId()
            );
        }

    }
}