/**
 * @author George Arshakian
 * @description AITM_LocationManagerHandlerTests - Contains tests for various processes described in Location Manager trigger handler class
 **/ 
@isTest  
private class AITM_LocationManagerHandlerTests {
    
    /**
    * @description Purpose: To test, that insert DML operation won't cause any issues
    */
    @isTest 
    static void testInsertionOfTheLocationManagerWillNotCauseErrors() {
        AITM_LocationManagerHandlerTestSetup testSetup = new AITM_LocationManagerHandlerTestSetup().generateData();
        AITM_Location_Manager__c locationManager = testSetup.createLocationManager(testSetup.SECTORS.get('CA'), 0);
        
        Test.startTest();
            insert locationManager;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM AITM_Location_Manager__c WHERE Id = :locationManager.Id LIMIT 1]);
    }

    /**
    * @description Purpose: To test, that update DML operation won't cause any issues
    */
    @isTest 
    static void testUpdateOfTheLocationManagerWillNotCauseErrors() {
        AITM_LocationManagerHandlerTestSetup testSetup = new AITM_LocationManagerHandlerTestSetup().generateData();
        AITM_Location_Manager__c locationManager = testSetup.createLocationManager(testSetup.SECTORS.get('CA'), 0);
        insert locationManager;
        
        Test.startTest();
            locationManager.AITM_Sector__c = testSetup.SECTORS.get('GA');
            update locationManager;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM AITM_Location_Manager__c WHERE Id = :locationManager.Id AND AITM_Sector__c = :testSetup.SECTORS.get('GA') LIMIT 1]);
    }

    /**
    * @description Purpose: To test, that delete DML operation won't cause any issues
    */
    @isTest 
    static void testDeleteOfTheLocationManagerWillNotCauseErrors() {
        AITM_LocationManagerHandlerTestSetup testSetup = new AITM_LocationManagerHandlerTestSetup().generateData();
        AITM_Location_Manager__c locationManager = testSetup.createLocationManager(testSetup.SECTORS.get('CA'), 0);
        insert locationManager;
        
        Test.startTest();
            delete locationManager;
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM AITM_Location_Manager__c WHERE Id = :locationManager.Id LIMIT 1]);
    }

    /**
    * @description Purpose: To test, if the duplication check will work for duplicate sectors per location
    */
    @isTest 
    static void testDuplicationCheckWillWorkIfDuplicateWillBeInserted() {
        AITM_LocationManagerHandlerTestSetup testSetup = new AITM_LocationManagerHandlerTestSetup().generateData();
        AITM_Location_Manager__c locationManagerCA = testSetup.createLocationManager(testSetup.SECTORS.get('CA'), 0);
        insert locationManagerCA;

        AITM_Location_Manager__c locationManagerCADuplicate = testSetup.createLocationManager(testSetup.SECTORS.get('CA'), 0);
        
        Test.startTest();
            Database.insert(locationManagerCADuplicate, false); //insert with false, because it's throwing an error
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM AITM_Location_Manager__c WHERE AITM_Sector__c = :testSetup.SECTORS.get('CA') LIMIT 1]);
    }
    
    /**
    * @description Purpose: To test, that on insert OwnerId will be set to AITM_Location_Manager__c
    */
    @isTest 
    static void testOnInsertOwnerIdWillBePrePopulated() {
        AITM_LocationManagerHandlerTestSetup testSetup = new AITM_LocationManagerHandlerTestSetup().generateData();
        AITM_Location_Manager__c locationManager = testSetup.createLocationManager(testSetup.SECTORS.get('CA'), 0);
        
        Test.startTest();
            insert locationManager;
        Test.stopTest();

        System.assertEquals(locationManager.AITM_Location_Manager__c, [SELECT OwnerId FROM AITM_Location_Manager__c WHERE Id = :locationManager.Id LIMIT 1][0].OwnerId);
    }

    private class AITM_LocationManagerHandlerTestSetup extends AITM_TestSetup {
        public List<AITM_Location__c> locations;
        public final Map<String, String> SECTORS = new Map<String, String>{
            'CA' => 'CA',
            'GA' => 'GA',
            'Military' => 'Military'
        };

        public AITM_LocationManagerHandlerTestSetup generateData() {
            locations = createLocations(10);
            insert locations;

            return this;
        }

        public AITM_Location_Manager__c createLocationManager(String sector, Integer index) {
            return new AITM_Location_Manager__c(
                AITM_Sector__c = sector,
                AITM_Location__c = locations[index].Id,
                AITM_Location_Manager__c = UserInfo.getUserId()
            );
        }
    }
}