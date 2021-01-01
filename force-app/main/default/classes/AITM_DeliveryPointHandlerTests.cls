/***************************************************************
 * @author           Kunal
 * @date             22/Jan/2020
 * @group            AirBP
 * @description      Test class for AITM_DeliveryPointHandler

 * history
 * 22/Jan/2020   	 Kunal      Created
 **********************************************************/
@isTest 
private inherited sharing class AITM_DeliveryPointHandlerTests {
    /**
	 * @description test Default values after Inserting Delivery point
	 * @param null
	 * @return void
	 */
	@isTest 
    static void testDefaultValueChangesAfterNewDefaultAssigned() {
        DeliveryPointHandlerTestSetup testSetup = new DeliveryPointHandlerTestSetup();
		testSetup.generateData();
		
		Integer newDefault = 2;

        Test.startTest();
			AITM_Delivery_Point__c deliveryPointNewDefault = testSetup.deliveryPoints[newDefault];
			deliveryPointNewDefault.AITM_Default__c = true;
			update deliveryPointNewDefault;
        Test.stopTest();

        List<AITM_Delivery_Point__c> deliveryPointsUpdated = [SELECT Name, Id, AITM_Default__c FROM AITM_Delivery_Point__c WHERE AITM_Location__c = :testSetup.locations[0].Id ORDER BY Name ASC];
    	
    	Integer index = 0;
    	for(AITM_Delivery_Point__c deliveryPoint : deliveryPointsUpdated) {
    		if(deliveryPoint.Name == 'TESTNAME-' + newDefault){
    			System.assertEquals(true, deliveryPointsUpdated[index].AITM_Default__c);
    		}else {
    			System.assertEquals(false, deliveryPointsUpdated[index].AITM_Default__c);
    		}
    		index++;
    	}
    }
	
	/**
	 * @description test Delivery Point Values when inserted
	 * @param null
	 * @return void
	 */
	@isTest 
	static void testDeliveryPointValuesAsCreatedNew() {
		DeliveryPointHandlerTestSetup testSetup = new DeliveryPointHandlerTestSetup();
		testSetup.generateData();

		Integer newDefault = 2;

		Test.startTest();
			AITM_Delivery_Point__c deliveryPointNewDefault = testSetup.deliveryPoints[newDefault];
			deliveryPointNewDefault.AITM_IATA__c = null;
			update deliveryPointNewDefault;
		Test.stopTest();

		List<AITM_Delivery_Point__c> deliveryPointsUpdated = [SELECT Name, Id, AITM_IATA__c FROM AITM_Delivery_Point__c 
		                                                      WHERE AITM_Location__c = :testSetup.locations[0].Id ORDER BY Name ASC];
													  
		System.assertNotEquals(null, deliveryPointsUpdated[0].AITM_IATA__c);
	}

	/**
	* @description class holds test data preparation
	*/
    private inherited sharing class DeliveryPointHandlerTestSetup extends AITM_TestSetup {
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Delivery_Point__c> deliveryPoints;
        public final Integer ITEMS_COUNT = 10;

		/**
		* @description Intialise the vaiables
		* @param  null
		* @return void
		*/
        public DeliveryPointHandlerTestSetup(){
        	locations = new List<AITM_Location__c>();
        }
		
		/**
		* @description generates test data
		* @param  null
		* @return void
		*/
        public void generateData() {
            locations = createLocations(ITEMS_COUNT);
            insert locations;
            tender = createTender();
            insert tender;
            deliveryPoints = createDeliveryPoints(ITEMS_COUNT);
            System.debug(deliveryPoints);
            insert deliveryPoints;
        }
        
		/**
		* @description creates delivery Points
		* @param  size of type Integer
		* @return List<AITM_Delivery_Point__c>
		*/
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