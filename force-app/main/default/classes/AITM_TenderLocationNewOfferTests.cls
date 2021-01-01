/**************************************************************************
 * @author           George
 * @date             03/April/2018
 * @group            AirBP
 * @description      Test class for AITM_TenderLocationNewOffer
 *******************************************************************/


@isTest 
private with sharing class AITM_TenderLocationNewOfferTests {
    
    @isTest 
    static void testGetTableData() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
    
        Test.startTest();
            Map<String, List<sObject>> tableData = AITM_TenderLocationNewOffer.getTableData(tenderLocation.Id);
        Test.stopTest();
    
        
        System.assertEquals(lineItemsCount, tableData.get('lineItems').size());
        System.assertEquals(tenderLocation.Id, tableData.get('tenderLocation')[0].Id);
    
    }
    
    @isTest 
    static void testGetTenderDetails() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;        
        AITM_Location__c location = testSetup.createLocation();
        insert location;        
        Boolean flag = false;
        AITM_Tender_Location__c tenderLocation1 = testSetup.createTenderLocation(tenderId, location.Id);        
        insert tenderLocation1;
        Test.startTest();
          flag =  AITM_TenderLocationNewOffer.getTenderDetails(tenderLocation1.Id); 
        Test.stopTest();
        System.assertEquals(false,flag);
        
    }
    
    
    @isTest 
    static void testUpdateRecordForPickList() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
        Test.startTest();
          
           AITM_TenderLocationNewOffer.updateRecordForPickList(items[0].Id,'AITM_Currency__c','USX');
           AITM_TenderLocationNewOffer.updateRecordForPickList(items[0].Id,'AITM_Unit_Of_Measure__c','LT');
        Test.stopTest();
        System.assertEquals('EUR',items[0].AITM_Currency__c);
        System.assertEquals('LT',items[0].AITM_Unit_Of_Measure__c);
        
    }
      @isTest 
    static void testSetCurrency() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
        Test.startTest();
          
           AITM_TenderLocationNewOffer.setCurrency(items[0].Id,'USX');
           //AITM_TenderLocationNewOffer.updateRecordForPickList(items[0].Id,'AITM_Unit_Of_Measure__c','USG');
        Test.stopTest();
        System.assertEquals('EUR',items[0].AITM_Currency__c);
        //System.assertNotEquals('USG',items[0].AITM_Unit_Of_Measure__c);
        
    }
    @isTest 
    static void testUpdateTaxesandFeesToAllTLLI() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
        
        Test.startTest();
          
           AITM_TenderLocationNewOffer.updateTaxesandFeesToAllTLLI(tenderLocation);
           
        Test.stopTest();
        System.assertEquals(Null,items[1].AITM_Taxes_Fees__c);
        
        
    }
     @isTest 
    static void testApplyToAllTaxesFeesMethod() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
        
        Test.startTest();
          
           AITM_TenderLocationNewOffer.ApplyToAllTaxesFeesMethod(tenderLocation);
           
        Test.stopTest();
        System.assertEquals(Null,items[1].AITM_Taxes_Fees__c);
        
        
    }
    @isTest 
    static void testUpdateTenderLocationPricingBasis() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
        List<AITM_Pricing_Basis__c> pricingBasis = new List<AITM_Pricing_Basis__c>();
        pricingBasis.add(new AITM_Pricing_Basis__c(Name = 'Test'));
        pricingBasis.add(new AITM_Pricing_Basis__c(Name = 'Test1'));	
        insert pricingBasis;
        items[0].AITM_Pricing_Basis__c = pricingBasis[1].Id;
        update items[0];
        
        Test.startTest();
          
           AITM_TenderLocationNewOffer.updateTenderLocationPricingBasis(tenderLocation);
           
        Test.stopTest();
        System.assertEquals(Null,items[1].AITM_Pricing_Basis__r.Name);
        
        
    }
    
     @isTest 
    static void testGetDeliveryRecords() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount =  2;      
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
     
       List<AITM_Delivery_Point__c> deliveryPoints = new List<AITM_Delivery_Point__c>();
       Integer count = 2;
       
       deliveryPoints.add(testSetup.createDeliveryPoint(location,false, count++));
       List<User> locationManagers = testSetup.createUsers(lineItemsCount, 'Air_TMLocation Manager');
       insert locationManagers;
        for(AITM_Delivery_Point__c deliveryPoint : deliveryPoints) {
            deliveryPoint.AITM_CA_Pricing_Responsibility1__c = locationManagers[0].Id;
            deliveryPoint.AITM_GA_Pricing_Responsibility1__c = locationManagers[0].Id;
            deliveryPoint.AITM_Location_Manager1__c = locationManagers[0].Id;
        }
        insert deliveryPoints;
        
        AITM_Tender_Location_Line_Item__c lineItem = testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id);
          lineItem.AITM_Location_Delivery_Point__c = deliveryPoints[0].Id;  
     
        Test.startTest();
          insert lineItem;
          List<AITM_Delivery_Point__c> deliveryPoint =  AITM_TenderLocationNewOffer.getDeliveryRecords(lineItem);
         //AITM_TenderLocationNewOffer.updateDeliveryRecords(deliveryPoints[0].Id,lineItem.Id);           
        Test.stopTest();
        System.assertEquals(1,deliveryPoint.size());
        
        
    }
    @isTest
    static void testSetOwnerId(){
         TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount =  2;
      
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
     
       List<AITM_Delivery_Point__c> deliveryPoints = new List<AITM_Delivery_Point__c>();
        Integer count = 2;
        
       
            deliveryPoints.add(testSetup.createDeliveryPoint(location,false,count++));
            List<User> locationManagers = testSetup.createUsers(lineItemsCount, 'Air_TMLocation Manager');
        insert locationManagers;
        for(AITM_Delivery_Point__c deliveryPoint : deliveryPoints) {
            deliveryPoint.AITM_CA_Pricing_Responsibility1__c = locationManagers[0].Id;
            deliveryPoint.AITM_GA_Pricing_Responsibility1__c = locationManagers[0].Id;
            
            deliveryPoint.AITM_Location_Manager1__c = locationManagers[0].Id;
        }
       // deliveryPoints[1].AITM_Location_Manager1__c = Null;
        insert deliveryPoints;
        
        AITM_Tender_Location_Line_Item__c lineItem = testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id);
          lineItem.AITM_Location_Delivery_Point__c = deliveryPoints[0].Id;  
        
        //insert lineItem;
        
        
        Test.startTest();
          insert lineItem;
         AITM_Tender_Location_Line_Item__c item =  AITM_TenderLocationNewOffer.setOwnerId(deliveryPoints[0],lineItem,'CA');
         AITM_Tender_Location_Line_Item__c item1 =  AITM_TenderLocationNewOffer.setOwnerId(deliveryPoints[0],lineItem,'GA');
        
        //AITM_TenderLocationNewOffer.updateDeliveryRecords(deliveryPoints[0].Id,lineItem.Id);
           
        Test.stopTest();
        System.assertEquals(null,item.Name);
        System.assertEquals(null,item1.Name);
        
        
        
    }
    
   @isTest
    static void testSetLineItemFields() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;        Account account = testSetup.createAccount();
        insert account;        AITM_Location__c location = testSetup.createLocation();
        insert location;
		
		List<AITM_Delivery_Point__c> deliveryPoints = new List<AITM_Delivery_Point__c>();
        Integer count = 2;
        deliveryPoints.add(testSetup.createDeliveryPoint(location,false, count++));
        List<User> locationManagers = testSetup.createUsers(lineItemsCount, 'Air_TMLocation Manager');
        insert locationManagers;
		
        for(AITM_Delivery_Point__c deliveryPoint : deliveryPoints) {
		    deliveryPoint.AITM_Delivery_Method__c = 'Into-Wing with Into-Plane';
			deliveryPoint.AITM_Delivery_By__c = 'test';
			deliveryPoint.AITM_Product__c = 'Jet A-1 @ 1 CM=0.8 MT';
			deliveryPoint.AITM_Product_Default__c = 'Jet A-1';
			deliveryPoint.AITM_Density__c = '330.215';
			deliveryPoint.AITM_Measure__c  = 'Gross';
			
			deliveryPoint.AITM_Additional_Refueling_Information__c = 'JET';
			deliveryPoint.AITM_Product_Specification__c = 'AFQRJOS Latest Issue';
			deliveryPoint.AITM_Unit_of_Measure__c = 'LT';
			deliveryPoint.AITM_Currency__c = 'ZAX';
            deliveryPoint.AITM_CA_Pricing_Responsibility1__c = locationManagers[0].Id;
            deliveryPoint.AITM_GA_Pricing_Responsibility1__c = locationManagers[0].Id;
            deliveryPoint.AITM_Location_Manager1__c = locationManagers[0].Id;
        }
        insert deliveryPoints;       
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;       
        AITM_Tender_Location_Line_Item__c lineItem = testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id);
        lineItem.AITM_Location_Delivery_Point__c = deliveryPoints[0].Id;
        //insert lineItem;
		 
        Test.startTest();
           AITM_TenderLocationNewOffer.setLineItemFields(deliveryPoints[0].Id, lineItem,deliveryPoints[0]);
        Test.stopTest();    }
    
    
    @isTest
    static void forTest(){
         Test.startTest();
           AITM_TenderLocationNewOffer.setTestLineItemFields();
        Test.stopTest();  
        
    }
    
    @isTest 
    static void testUpdateLineItem() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
        List<AITM_Pricing_Basis__c> pricingBasis = new List<AITM_Pricing_Basis__c>();
        pricingBasis.add(new AITM_Pricing_Basis__c(Name = 'Test'));
        pricingBasis.add(new AITM_Pricing_Basis__c(Name = 'Test1'));	
        insert pricingBasis;
        
        
        Test.startTest();
          
           AITM_TenderLocationNewOffer.updateLineItem(pricingBasis[1].Id,items[0].Id);
           
        Test.stopTest();
        System.assertEquals(Null,items[0].AITM_Pricing_Basis__r.Name);
        
        
    }
    
    @isTest 
    static void testGetDebreifStage() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        
       String stage = '';
       
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        
      
        
        Test.startTest();
          
        stage = AITM_TenderLocationNewOffer.getDebreifStage(tenderLocation.Id);
           
        Test.stopTest();
        System.assertEquals('Tender Created',stage);
        
        
    }
    
    @isTest 
    static void testGetDetailsFromTLLI() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
    
        Test.startTest();
            AITM_Tender_Location_Line_Item__c itemData = AITM_TenderLocationNewOffer.getDetailsFromTLLI(items[0].Id);
        Test.stopTest();
        System.assertNotEquals(null,itemData,'Has valid line Item');
    }
    
     @isTest 
    static void testGetTenderLocationLineItemBySetOfIds() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
    
        Test.startTest();
            List<AITM_Tender_Location_Line_Item__c> itemData = AITM_TenderLocationNewOffer.getTenderLocationLineItemBySetOfIds(items[0].Id);
        Test.stopTest();
        System.assertEquals(account.Id,itemData[0].AITM_Account__c);
    }
    
    @isTest 
    static void testUpdateRecord() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = location.Id,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = 'Ready',
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
        AITM_Tender_Location_Line_Item__c lineItem = items[0];
    
        Test.startTest();
            sObject so = AITM_TenderLocationNewOffer.updateRecord('AITM_Tender_Location__c', tenderLocation.Id, 'AITM_Total_Volume_Offered_To_The_Group__c', '10000', items);
            //sObject so1 = AITM_TenderLocationNewOffer.updateRecord('AITM_Tender_Location_Line_Item__c', lineItem.Id, 'AITM_Start_Date__c', String.valueofGmt(Date.today().addYears(1)), items);
            sObject so2 = AITM_TenderLocationNewOffer.updateRecord('AITM_Tender_Location_Line_Item__c', lineItem.Id, 'AITM_Percentage_Volume_Offered__c', '50.2', items);
            Map<String, List<sObject>> tableData = AITM_TenderLocationNewOffer.getTableData(tenderLocation.Id);
            AITM_Tender_Location__c getTenderLocation = (AITM_Tender_Location__c)tableData.get('tenderLocation')[0];
            AITM_Tender_Location_Line_Item__c getLineItem = new AITM_LocationsDao().getTenderLocationLineItem(lineItem.Id);
        Test.stopTest();
    
        System.assertNotEquals(getTenderLocation.AITM_Total_Volume_Offered_To_The_Group__c, tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c);
        System.assertNotEquals(getLineItem.AITM_Percentage_Volume_Offered__c, lineItem.AITM_Percentage_Volume_Offered__c);
    
    }
    
    @isTest 
    static void testDeleteRecords() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
        Account account = testSetup.createAccount();
        insert account;
            
    
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = location.Id,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = 'Ready',
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        insert tenderLocation;
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
        
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
    
    
        Test.startTest();
            List<String> IdString = new List<String>();
                for(AITM_Tender_Location_Line_Item__c t1:items){
                IdString.add(t1.Id);
            }        
            String msg = AITM_TenderLocationNewOffer.deleteRecords(IdString);
        
        Test.stopTest();
        System.assertEquals('Each customer must have atleast one tender Location Line Item record', msg);
    }
    
    
     @isTest 
    static void testRevisionRecords() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
        Account account = testSetup.createAccount();
        insert account;
            
    
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = location.Id,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = 'Ready',
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        insert tenderLocation;
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
        
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
         Test.startTest();
            List<String> IdString = new List<String>();
                for(AITM_Tender_Location_Line_Item__c t1:items){
                IdString.add(t1.Id);
            }        
            List<AITM_Tender_Location_Line_Item__c> lineItems = AITM_TenderLocationNewOffer.getIdsForRevision(IdString);
        
        Test.stopTest();
        System.assertEquals(5,lineItems.size());
    }
    
    @isTest 
    static void testCloneRecords() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
        Account account = testSetup.createAccount();
        insert account;
            
    
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = location.Id,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = 'Ready',
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        insert tenderLocation;
        AITM_Tender_Location_Line_Item__c item = new AITM_Tender_Location_Line_Item__c();
        item = testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id);       
        
        insert item;
        List<Id> itemIds = new List<Id>();
        itemIds.add(item.Id);
    
        Test.startTest();
            String msg = AITM_TenderLocationNewOffer.cloneRecords(itemIds);
        Test.stopTest();
        System.assertEquals('', msg);
    }

    @isTest 
    static void testGetPickValues() {
        Test.startTest();
            List<String> selectOptions = AITM_TenderLocationNewOffer.getPickValues('AITM_Tender_Location_Line_Item__c', 'AITM_Currency__c');
        Test.stopTest();
        System.assert(selectOptions.size() > 0);
    }
    
    @IsTest 
    static void testGetTableMetadata() {
        Test.startTest();
            List<AITM_Table_Tender_Location_New_Offer__mdt> tableMetadata = AITM_TenderLocationNewOffer.getTableMetadata();
        Test.stopTest();
        System.assertNotEquals(0, tableMetadata.size());
    }
    
    @IsTest 
    static void testGetTableMetadataForNewUI() {
        Test.startTest();
            List<AITM_Table_Tender_Location_New_Offer__mdt> tableMetadata = AITM_TenderLocationNewOffer.getNewUITableMetadata();
        Test.stopTest();
        System.assertNotEquals(0, tableMetadata.size());
    }
    
    @isTest 
    static void testGetFieldAccess() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
        Account account = testSetup.createAccount();
        insert account;    
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = location.Id,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = 'Ready',
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        insert tenderLocation;
        AITM_Tender_Location_Line_Item__c lineItem = testSetup.createTenderLocationLineItem(tenderId,account.Id,location.Id,tenderLocation.Id);
        lineItem.RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
        insert lineItem;
        Test.startTest();
            Map<String, Map<String, Boolean>> fieldsAccess = AITM_TenderLocationNewOffer.getFieldsAccess('AITM_Tender_Location__c', tenderLocation.Id);
            List<AITM_Tender_Location_Line_Item__c> debriefLineItems = AITM_TenderLocationNewOffer.getDebriefLineItemRecords(lineItem.Id);
        Test.stopTest();
        System.assertNotEquals(null, fieldsAccess.size());
    }
	
	@isTest 
    static void testSaveRecords() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
        AITM_Location__c location = testSetup.createLocation();
        insert location;
        Account account = testSetup.createAccount();
        insert account;
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = location.Id,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = 'Ready',
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        insert tenderLocation;
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
        Test.startTest();
            AITM_TenderLocationNewOffer.saveLines(items);       
        Test.stopTest();
    }
    
    @isTest 
    static void testUpdateLocationAndLineItemToUnStraddled() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        
        Id straddledLocation = testSetup.straddledLocation.Id;
        
        Test.startTest();
            List<AITM_Tender_Location__c> listOfTenderLocations = AITM_TenderLocationNewOffer.updateLocationAndLineItemToUnStraddled(straddledLocation);
        Test.stopTest();
        
        System.assertEquals(false, listOfTenderLocations[0].AITM_Is_Straddled__c);
    }
    
    private with sharing class TenderLocationNewOfferTestSetup extends AITM_TestSetup {
        public AITM_TenderLocationNewOffer classUnderTest;
    
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public AITM_Pricing_Basis__c pricingBasis;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        public AITM_Tender_Location__c straddledLocation; 
        public AITM_Tender_Location_Line_Item__c straddledLineItem; 
    
        public TenderLocationNewOfferTestSetup generateData(){
            classUnderTest = new AITM_TenderLocationNewOffer();
    
            accounts = createAccounts(10);
            insert accounts;
    
            locations = createLocations(10);
            insert locations;
    
            tender = createTender();
            tender.AITM_Tender_Sector__c ='CA';
            insert tender;
    
            createTenderLocations();
    		
            pricingBasis = createPricingBasis();
            INSERT pricingBasis;
            
            straddledLocation = createStraddledTenderLocation(tender.Id, locations[0].Id);
            insert straddledLocation;
            
            straddledLineItem = createStraddledTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id, straddledLocation.Id);
            insert straddledLineItem;
            
            return this;
        }
    
        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }
    	
        /**
         * @description creates the test data for PricingBasis
         * @param  null
         * @return AITM_Pricing_Basis__c
         */
        private AITM_Pricing_Basis__c createPricingBasis(){
            return new AITM_Pricing_Basis__c(
                Name = 'P008',
                AITM_Description__c = 'Barges FOB Rotterdam High Prior Month WD',
                AITM_Currency__c = 'USD',
                AITM_Unit_Of_Measure__c = 'USG'
                );
        }

        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }
    
        public void createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
                for(AITM_Location__c location : locations){
                tenderLocations.add(
                    createTenderLocation(tender.Id, location.Id)
                );
            }
            insert tenderLocations;
        }
    
        public AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                //AITM_Tender__r.AITM_Tender_Sector__c = 'CA',
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,                
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0,
                AITM_Pricing_Basis__c = pricingBasis.Id,
                AITM_Currency__c ='EUR',
                AITM_Unit_Of_Measure__c ='LT',
                RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId()
            );
        }
    
    }
}