@isTest 
private class AITM_TenderLocDeliveryPointsHandlerTests {

    private class TenderLocDeliveryPointsHandlerTestSetup extends AITM_TestSetup {
        public List<AITM_Location__c> locations;
        public List<Account> accounts;
        public List<AITM_Delivery_Point__c> deliveryPoints;
        public AITM_Tender_Location_Line_Item__c lineItem;
        public AITM_Tender__c tender;
        public final Integer ITEMS_COUNT = 10;

        public TenderLocDeliveryPointsHandlerTestSetup(){
        	locations = new List<AITM_Location__c>();
        }

        public void generateData() {
        	accounts = createAccounts(ITEMS_COUNT);
			insert accounts;
            locations = createLocations(ITEMS_COUNT);
            insert locations;
            tender = createTender();
            insert tender;
            deliveryPoints = createDeliveryPoints(ITEMS_COUNT);
            insert deliveryPoints;
            lineItem = createTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id);
        }

        public List<AITM_Delivery_Point__c> createDeliveryPoints(Integer size) {
	        List<AITM_Delivery_Point__c> result = new List<AITM_Delivery_Point__c>();
	        for (Integer index = 0; index < size; index++) {
	            AITM_Delivery_Point__c iterationDeliveryPoint = createDeliveryPoint(locations[0], false, index);
	            result.add(iterationDeliveryPoint);
	        }
	        return result;
	    }
	    
    }
}