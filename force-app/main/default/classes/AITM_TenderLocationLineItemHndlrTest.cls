/***************************************************************
 * @author           Sushant
 * @date             31/March/2020
 * @group            AirBP
 * @description      Test class for AITM_TenderLocationLineItemBPGHandler
 **********************************************************/
@isTest
public with sharing class AITM_TenderLocationLineItemHndlrTest {
       
    private static Integer ITEMS_SIZE = 2;
    private static List<Account> accounts;
    private static AITM_Tender_Account__c tenderAccount;
    private static List<AITM_Location__c> locations;
    private static List<AITM_Tender_Location__c> tenderLocations;
    private static AITM_Tender_Location__c tenderLocation;
    private static AITM_Tender__c tender;
    private static AITM_Tender_Location_Line_Item__c lineItem;
    
     /**
     * @description class to create test data extending AITM_TestSetup
     */  
     private with sharing class AITM_TenderLocationLineItemHandlerTestSetup extends AITM_TestSetup {
         
      public AITM_TenderLocationLineItemHandlerTestSetup generateData() { 
            AITM_TestSetup setup = new AITM_TestSetup();
            accounts = setup.createAccounts(ITEMS_SIZE);
            AITM_Contracting_Entity__c contractingObj = new AITM_Contracting_Entity__c();
            contractingObj.Name = 'test';
            insert contractingObj;
            
            for(Account acc : accounts){
                acc.AITM_GRN__c = '8279300';
                acc.AITM_Credit_Rating__c = '1'; 
                acc.AITM_Customer_Segment__c = 'Base';
                acc.Alternate_Customer_Name__c = 'test'; 
                acc.AITM_Customer_Segment__c = 'Base';
                acc.AITM_Contracting_Entity__c = contractingObj.Id;
                acc.AITM_Exchange_Rate__c = 'IATA';
                acc.Credit_Days__c = '2';
                acc.AITM_Credit_Days1__c = '2';
                acc.AITM_Credit_Days__c =  0.2;
                acc.AITM_Invoice_Frequency__c = 'Daily';
            }
            insert accounts;
    
            locations = setup.createLocations(ITEMS_SIZE);
            for(AITM_Location__c location : locations){
                location.AITM_Country__c = 'Spain';
                location.AITM_IATA__c = 'DWC';
            }
            insert locations;
    
            tender = setup.createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';
            tender.AITM_Stage__c = 'Awaiting Price';
            insert tender;         
                      
            AITM_Pricing_Basis__c pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test');
            pricingBasis.AITM_Not_Represented__c = false;
            insert pricingBasis;
            
            tenderLocation = setup.createTenderLocation(tender.Id, locations[0].id); 
            tenderLocation.AITM_Round__c = 2;
            tenderLocation.AITM_Current_Round__c= 2;
            tenderLocation.AITM_Status__c = 'Not Represented';
            insert tenderLocation; 
            
            lineItem = setup.createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
            lineItem.AITM_Ad_hoc_Volume__c = true;      
            lineItem.AITM_Tender_Location__c =  tenderLocation.Id;
            lineItem.AITM_Pricing_Basis__c = pricingBasis.Id;
            insert lineItem;
            return this;
        }    
    }
        
    /**
     * @description tests to all beforeinsert and afterinsert tenderlocationlineitem
     * @param  null
     * @return void
     */
    @isTest 
    static void testvalidateonAfterandBeforeinsertTenderlocationlineitem(){ 
       AITM_TenderLocationLineItemHandlerTestSetup testSetup = new AITM_TenderLocationLineItemHandlerTestSetup().generateData();
       AITM_TestSetup setup = new AITM_TestSetup(); 
       Map<Id, AITM_Tender_Location_Line_Item__c> mapOfIdVsTenderLineitem = new Map<Id, AITM_Tender_Location_Line_Item__c>();
       mapOfIdVsTenderLineitem.put(lineItem.Id, lineItem);
    
        AITM_TenderLocationLineItemHelper helperClass = new AITM_TenderLocationLineItemHelper();
        Test.startTest();
           helperClass.getOperationalUnit();       
           helperClass.afterInsertPrePopulationFieldsFiller(new List<AITM_Tender_Location_Line_Item__c>{lineItem});
           helperClass.afterInsertDeliveryPointsCreationHandler(new List<AITM_Tender_Location_Line_Item__c>{lineItem});
           helperClass.afterInsertDefaultStraddling(new List<AITM_Tender_Location_Line_Item__c>{lineItem});
           helperClass.afterInsertInsertNewTaxesFeesRecords(new List<AITM_Tender_Location_Line_Item__c>{lineItem});
           helperClass.beforeInsertLineItemToTenderLocationRecordMapper(new List<AITM_Tender_Location_Line_Item__c>{lineItem});
           helperClass.beforeInsertOldRoundEditionBlock(new List<AITM_Tender_Location_Line_Item__c>{lineItem});
           helperClass.beforeInsertPopulateTenderHistoryLineItemHandler(new List<AITM_Tender_Location_Line_Item__c>{lineItem}, mapOfIdVsTenderLineitem);
           helperClass.beforeInsertInsertNewTaxesFeesRecords(new List<AITM_Tender_Location_Line_Item__c>{lineItem});       
           helperClass.beforeInsertPrePopulationFieldsFiller(new List<AITM_Tender_Location_Line_Item__c>{lineItem});
           helperClass.beforeInsertDeliveryPointsCreationHandler(new List<AITM_Tender_Location_Line_Item__c>{lineItem});
           helperClass.beforeInsertRequestedAndOfferedVolumeCalculations(new List<AITM_Tender_Location_Line_Item__c>{lineItem});       
        Test.stopTest();
        System.assertNotEquals((1+0)*2, lineItem.AITM_Volume__c);
    } 
    
     /**
     * @description tests to BeforeUpdateModifyVolumeAdHoc
     * @param  null
     * @return void
     */
    @isTest 
    static void testvalidateBeforeUpdateModifyVolumeAdHoc(){
       AITM_TenderLocationLineItemHandlerTestSetup testSetup = new AITM_TenderLocationLineItemHandlerTestSetup().generateData();
       AITM_TenderLocationLineItemHelper helperClass = new AITM_TenderLocationLineItemHelper();
       Map<Id, AITM_Tender_Location_Line_Item__c> mapOfIdVsTenderLineitem = new Map<Id, AITM_Tender_Location_Line_Item__c>();
       mapOfIdVsTenderLineitem.put(lineItem.Id, lineItem);
       List<AITM_Tender_Location_Line_Item__c> itemListToUpdate = new List<AITM_Tender_Location_Line_Item__c>();        
       mapOfIdVsTenderLineitem.put(lineItem.Id, lineItem); 
       Test.startTest(); 
       if(!lineItem.isClone()){                                        
        helperClass.beforeUpdatemodifyVolumeAdHoc(mapOfIdVsTenderLineitem, new List<AITM_Tender_Location_Line_Item__c>{lineItem});
       } 
       Test.stopTest(); 
       System.assertNotEquals('LT', lineItem.AITM_Unit_Of_Measure__c); 
    } 

    /**
     * @description tests to DeleteLineItemToTenderLocationRecordMapper on beforeDelete
     * @param  null
     * @return void
     */
    @isTest 
    static void testvalidateonDeleteLineItemToTenderLocationRecordMapper(){       
       AITM_TenderLocationLineItemHandlerTestSetup testSetup = new AITM_TenderLocationLineItemHandlerTestSetup().generateData();
       AITM_TestSetup setup = new AITM_TestSetup(); 
       tenderAccount = setup.createTenderAccount(tender.Id, accounts[0].Id);
       tenderAccount.AITM_Affiliates_Account__c = accounts[0].Id;
       insert tenderAccount;
       AITM_TenderLocationLineItemHelper helperClass = new AITM_TenderLocationLineItemHelper(); 
       Map<Id, AITM_Tender_Location_Line_Item__c> mapOfIdVsTenderLineitem = new Map<Id, AITM_Tender_Location_Line_Item__c>();
       mapOfIdVsTenderLineitem.put(lineItem.Id, lineItem);
       Test.startTest();
           helperClass.beforeDeleteLineItemToTenderLocationRecordMapper(new List<AITM_Tender_Location_Line_Item__c>{lineItem});
           delete lineItem; 
       Test.stopTest(); 
       System.assertNotEquals('LT', lineItem.AITM_Unit_Of_Measure__c); 
    }    
    
    /**
     * @description tests to RequestedAndOfferedVolumeCalculations on beforeInsert
     * @param  null
     * @return void
     */
    @isTest 
    static void testvalidatebeforeInsertRequestedAndOfferedVolumeCalculations(){       
      AITM_TenderLocationLineItemHandlerTestSetup testSetup = new AITM_TenderLocationLineItemHandlerTestSetup().generateData();
      AITM_TestSetup setup = new AITM_TestSetup();       
      AITM_Pricing_Basis__c pricingBasis1 = new AITM_Pricing_Basis__c(Name = 'Test');
      pricingBasis1.AITM_Not_Represented__c = true;
      insert pricingBasis1;
      
      AITM_Tender_Location__c tenderLocation1 = setup.createTenderLocation(tender.Id, locations[0].id); 
      tenderLocation1.AITM_Round__c = 2;
      tenderLocation1.AITM_Current_Round__c= 2;
      tenderLocation1.AITM_Status__c = 'Awaiting price';
      insert tenderLocation1; 
         
      AITM_Tender_Location_Line_Item__c lineItem1 = setup.createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
      lineItem1.AITM_Ad_hoc_Volume__c = true;   
      lineItem1.Recordtypeid = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();  
      lineItem1.AITM_Pricing_Basis__c = pricingBasis1.Id;
      lineItem1.AITM_Tender_Location__c =  tenderLocation1.Id;      
      lineItem1.AITM_Percentage_Volume_Offered__c = 2;
      lineItem1.AITM_Requested_Volume_USG__c = 3;
      lineItem1.AITM_Volume__c = 50;
      insert lineItem1;
        
      AITM_TenderLocationLineItemHelper helperClass = new AITM_TenderLocationLineItemHelper();     
      Map<Id, AITM_Tender_Location_Line_Item__c> mapOfIdVsTenderLineitem = new Map<Id, AITM_Tender_Location_Line_Item__c>();
      mapOfIdVsTenderLineitem.put(lineItem1.Id, lineItem1);
        
       if(!lineItem1.isClone()){  
           helperClass.beforeInsertRequestedAndOfferedVolumeCalculations(new List<AITM_Tender_Location_Line_Item__c>{lineItem1});         
           helperClass.afterInsertTenderLocationUpdateNonRepresentedAndRecalculateFlag(new List<AITM_Tender_Location_Line_Item__c>{lineItem1});         
           helperClass.beforeInsertmodifyVolumeAdHoc(new List<AITM_Tender_Location_Line_Item__c>{lineItem1});
       }
       System.assertEquals(50, lineItem1.AITM_Volume__c); 
    }
    
    /**
     * @description tests to beforeInsertmodifyVolumeAdHoc on beforeInsert
     * @param  null
     * @return void
     */
    @isTest 
    static void testvalidatebeforeInsertmodifyVolumeAdHoc(){ 
      AITM_TenderLocationLineItemHandlerTestSetup testSetup = new AITM_TenderLocationLineItemHandlerTestSetup().generateData();  
      AITM_TestSetup setup = new AITM_TestSetup();  
      AITM_Delivery_Point__c deliveryPoint = setup.createDeliveryPoint(locations[0], true, 22);  
      insert deliveryPoint;
      AITM_Delivery_Point__c deliveryPoint1 = setup.createDeliveryPoint(locations[0], true, 33);  
      insert deliveryPoint1;   
      AITM_TenderLocationLineItemHelper helperClass = new AITM_TenderLocationLineItemHelper();
      AITM_TenderLocationLineItemBPGHandler handlerClass = new AITM_TenderLocationLineItemBPGHandler();   
      AITM_Tender_Location_Line_Item__c lineItem1 = New AITM_Tender_Location_Line_Item__c();
      lineItem1.AITM_Ad_hoc_Volume__c = true; 
      lineItem1.AITM_Tender__c = tender.Id;
      lineItem1.AITM_Account__c = accounts[0].Id;
      lineItem1.AITM_Location__c =  locations[0].Id;
      lineItem1.AITM_Start_Date__c = Date.today();
      lineItem1.AITM_End_Date__c = Date.today().addYears(1);
      lineItem1.RecordTypeid = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();    
      lineItem1.AITM_Location_Delivery_Point__c = deliveryPoint.Id;  
      lineItem1.AITM_Percentage_Volume_Offered__c = 2;  
      lineItem1.AITM_Offered_Volume__c = 3;
      insert lineItem1;      
      helperClass.beforeInsertmodifyVolumeAdHoc(new List<AITM_Tender_Location_Line_Item__c>{lineItem1});
        
      Map<Id, AITM_Tender_Location_Line_Item__c> mapOfIdVsTenderLineitem = new Map<Id, AITM_Tender_Location_Line_Item__c>();
      mapOfIdVsTenderLineitem.put(lineItem1.Id, lineItem1);
      
      lineItem1.AITM_Ad_hoc_Volume__c = true;
      lineItem1.AITM_Percentage_Volume_Offered__c = 3;
      lineItem1.AITM_Offered_Volume__c = null;  
      lineItem1.AITM_Location_Delivery_Point__c = deliveryPoint1.Id;   
      update lineItem1;   
        
      Schema.SObjectType sObjectType = AITM_Tender_Location_Line_Item__c.getSObjectType();         
      List<SObject> o;Map<Id, SObject> oMap; Map<Id, SObject> nMap;List<SObject> n;String params;Boolean debug;      
      Test.startTest();
       handlerClass.beforeInsert(new List<AITM_Tender_Location_Line_Item__c>{lineItem1}, mapOfIdVsTenderLineitem, new List<AITM_Tender_Location_Line_Item__c>{lineItem1}, mapOfIdVsTenderLineitem, sObjectType, 'params', true);        
          if(!lineItem1.isClone()) {  
             helperClass.beforeUpdateRequestedAndOfferedVolumeCalculations(mapOfIdVsTenderLineitem, new List<AITM_Tender_Location_Line_Item__c>{lineItem1});
          }
      Test.stopTest();
        System.assertEquals(0, lineItem1.AITM_Offered_Volume__c);	  
    }        
}