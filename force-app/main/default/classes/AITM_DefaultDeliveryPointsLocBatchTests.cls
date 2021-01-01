/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_TenderOfferPDFController

 * history
 * 01/December/2017      George       Created
 * 04/September/2018     Anusha       Modified - added method level comments as per coding standards
 *******************************************************************/
@isTest 
private class AITM_DefaultDeliveryPointsLocBatchTests {

    /**
     * @description tests to run the batch
     * @param  null
     * @return void
     */
    @isTest  
    static void testBatchGenerationWillBeSuccessfull() {
        DefaultDeliveryPointsLocBatchTestSetup testSetup = new DefaultDeliveryPointsLocBatchTestSetup();
        testSetup.generateData();

        Test.startTest();
			testSetup.clearDeliveryPoints();
			System.assertEquals(0, [SELECT Count() FROM AITM_Delivery_Point__c WHERE AITM_Location__c = :testSetup.locations[0].Id]);
            Database.executeBatch(new AITM_DefaultDeliveryPointsLocBatch());
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM AITM_Delivery_Point__c WHERE AITM_Location__c = :testSetup.locations[0].Id]);

    }

    /**
     * @description test data AITM_TenderOfferPDFController inner class
     */
    private class DefaultDeliveryPointsLocBatchTestSetup extends AITM_TestSetup {
        public List<AITM_Location__c> locations;
        public final Integer ITEMS_COUNT = 10;

        public DefaultDeliveryPointsLocBatchTestSetup(){
        	locations = new List<AITM_Location__c>();
        }

        public void generateData() {
            locations = createLocations(ITEMS_COUNT);
            insert locations;
        }

        public void clearDeliveryPoints() {
        	List<AITM_Delivery_Point__c> deliveryPoints = [SELECT Id FROM AITM_Delivery_Point__c LIMIT 100];
        	delete deliveryPoints;
        }

    }

}