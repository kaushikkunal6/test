@isTest 
private class AITM_LocationHandlerTests {
    @isTest 
    static void testDefaultDeliveryPointAssigned() {
        LocationHandlerTestSetup testSetup = new LocationHandlerTestSetup();

        Test.startTest();
        	testSetup.generateData();
        Test.stopTest();

        List<AITM_Delivery_Point__c> locationDeliveryPoints = [SELECT Id FROM AITM_Delivery_Point__c WHERE AITM_Location__c = :testSetup.location.Id];
    	System.assertNotEquals(null, locationDeliveryPoints.size() > 0);
    }

    @isTest 
    static void testUpdateLocationIATAupdatesDeliveryPointsIata() {
        LocationHandlerTestSetup testSetup = new LocationHandlerTestSetup();
		testSetup.generateData();
		String iata = 'TTTT';
        Test.startTest();
        	AITM_Location__c location = testSetup.location;
        	location.AITM_IATA__c = iata;
        	update location;
        Test.stopTest();

        List<AITM_Delivery_Point__c> locationDeliveryPoints = [SELECT Id, AITM_IATA__c FROM AITM_Delivery_Point__c WHERE AITM_Location__c = :testSetup.location.Id];
    	for(AITM_Delivery_Point__c deliveryPoint : locationDeliveryPoints){
    		System.assertEquals(iata, deliveryPoint.AITM_IATA__c);
    	}
    	
    }

    private class LocationHandlerTestSetup extends AITM_TestSetup {
        public AITM_Location__c location;
        public AITM_Tender__c tender;

        public LocationHandlerTestSetup(){
        	location = createLocation();
        	tender = createTender();
        }

        public void generateData() {
            insert tender;
            insert location;
        }

    }
}