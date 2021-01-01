@isTest 
public class AITM_RelatedTenderLocationsHldrCtrTests {
    @isTest 
    static void getBidsInByTestWithFilledField() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        testSetup.tender.AITM_Bids_In_By__c = Date.newInstance(2001, 4, 12);
        update testSetup.tender;
        String mydate = testSetup.tender.AITM_Bids_In_By__c.format();
        String result = AITM_RelatedTenderLocationsHolderCntrl.getBidsInBy(testSetup.tender.Id);                
        System.assertEquals(mydate,result,'The result value is 12/04/2001');
    }
    
    @isTest 
    static void getDeleteRounds() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();    
        AITM_RelatedTenderLocationsHolderCntrl.deleteRounds(testSetup.tender.Id, 2.0);         
    }
    
    @isTest 
    static void getDisplaySummaryByCountry() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        AITM_RelatedTenderLocationsHolderCntrl.getDisplaySummaryByCountry();           
    }
    
    @isTest 
    static void getFilterOptionsForConga() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        AITM_RelatedTenderLocationsHolderCntrl.getFilterOptionsForConga(testSetup.tender.Id);                
    }

    @isTest 
    static void getBidsInByTestWithoutDateField() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        String result = AITM_RelatedTenderLocationsHolderCntrl.getBidsInBy(testSetup.tender.Id);
        System.assertEquals(Date.today().addYears(1).format(), result,'The result value is today');
    }

    @isTest 
    static void getRoundsOptionsTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        Test.startTest();
        AITM_RelatedRecordsHolderController.FilterOption result = AITM_RelatedTenderLocationsHolderCntrl.getRoundsOptions(testSetup.tender.Id)[0];
        Test.stopTest();
        System.assertEquals(false, result.disabled,'The round is not disabled');
        System.assertEquals('Round 1', result.name,'The name of the round is Round1');
    }

    @isTest 
    static void isSelectiveFilterLocationsRevisedOfferTest() {
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsRevisedOffer('testName', false).isSelectiveFilter();
        System.assertEquals(false, result,'Revised offer is false');
    }

    @isTest 
    static void isPassedFilterLocationsRevisedOfferTestFalseResult() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        testSetup.createTenderLocation();
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsRevisedOffer('testName', false).isPassedFilter(testSetup.tenderLocation);
        Test.stopTest();
        System.assertEquals(false, result,'The revised offer is false');
    }

    @isTest 
    static void isPassedFilterLocationsRevisedOfferTestTrueResult() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsRevisedOffer('testName', false).isPassedFilter(testSetup.getTenderLocationWithIncludeInRevisedOffer());
        Test.stopTest();
        System.assertEquals(true, result,'The revised offer is true');
    }

    @isTest 
    static void isSelectiveFilterLocationsWithSpecificVolumesTest() {
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsWithSpecificVolumes('testName', false).isSelectiveFilter();
        System.assertEquals(false, result,'The location with specific volume is not selected');
    }
    
    @isTest 
    static void fetchCurrentUserDetails() {
        AITM_RelatedTenderLocationsHolderCntrl.fetchCurrentUserDetails();
    }

    @isTest 
    static void isPassedFilterLocationsWithSpecificVolumesTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        testSetup.createTenderLocation();
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsWithSpecificVolumes('testName', false).isPassedFilter(testSetup.tenderLocation);
        Test.stopTest();
        System.assertEquals(true, result,'The location with specific volume is selected');
    }

    @isTest 
    static void isSelectiveFilterLocationsWithoutQuotesOptionTest() {
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsWithoutQuotesOption('testName', false).isSelectiveFilter();
        System.assertEquals(false, result,'The location without Quote is not selective');
    }

    @isTest 
    static void isPassedFilterLocationsWithQuotesOptionTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        testSetup.createTenderLocation();
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsWithoutQuotesOption('testName', false).isPassedFilter(testSetup.tenderLocation);
        Test.stopTest();
        System.assertEquals(true, result,'The location with Quote is passed');
    }

    @isTest 
    static void isPassedFilterLocationsWithoutQuotesOptionTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        Test.startTest();
         Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsWithoutQuotesOption('testName', false).isPassedFilter(testSetup.getTenderLocationWithoutOfferedDifferential());
        Test.stopTest();
        System.assertEquals(true, result,'The location without Quote is passed');
    }

    @isTest 
    static void getCriteriaLocationManagerFilterOptionTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        User locationManager = new AITM_UsersDao().getLocationManagers()[0];
        Test.startTest();
        String result = new AITM_RelatedTenderLocationsHolderCntrl.LocationManagerFilterOption(locationManager.Name, locationManager.Id).getCriteria()[0];
        Test.stopTest();
        result = result.substring(0, result.indexOf('='));
        System.assertEquals('AITM_Location_Manager__c ', result,'The criteria is with Location Manager');
    }

    @isTest 
    static void isSelectiveFilterLocationManagerFilterOptionTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        User locationManager = new AITM_UsersDao().getLocationManagers()[0];
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationManagerFilterOption(locationManager.Name, locationManager.Id).isSelectiveFilter();
        Test.stopTest();
        System.assertEquals(true, result, result);
    }

    @isTest 
    static void isPassedFilterLocationsVolumeMismatchOptionExpectedFalseTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        testSetup.createTenderLocation();
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsVolumeMismatchOption('testName', false).isPassedFilter(testSetup.tenderLocation);
        Test.stopTest();
        System.assertEquals(false, result, result);
    }

    @isTest 
    static void isSelectiveFilterLocationsVolumeMismatchOptionTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        Test.startTest();
         Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsVolumeMismatchOption('testName', false).isSelectiveFilter();
        Test.stopTest();
        System.assertEquals(false, result, result);
    }

    @isTest 
    static void isSelectiveLocationsWithQuotesOptionTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsWithQuotesOption('testName', false).isSelectiveFilter();
        Test.stopTest();
        System.assertEquals(false, result, result);
    }

    @isTest 
    static void isPassedFilterLocationsWithQuotesOptionFalseTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        testSetup.createTenderLocation();
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsWithQuotesOption ('testName', false).isPassedFilter(testSetup.tenderLocation);
        Test.stopTest();
        System.assertEquals(true, result, result);
    }

    @isTest 
    static void isPassedFilterLocationsWithQuotesOptionTrueTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        testSetup.createTenderLocation();
        testSetup.tenderLocation.AITM_Offered_Differential__c = 0;
        update testSetup.tenderLocation;
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.LocationsWithQuotesOption ('testName', false).isPassedFilter(testSetup.tenderLocation);
        Test.stopTest();
        System.assertEquals(true, result, result);
    }    

    @isTest 
    static void isPassedFilterRepresentedTenderLocationsTrueTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        testSetup.createTenderLocation();
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.RepresentedTenderLocations ('testName', false).isPassedFilter(testSetup.tenderLocation);
        Test.stopTest();
        System.assertEquals(true, result, result);
    }    

    @isTest 
    static void isPassedFilterRepresentedTenderLocationsFalseTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        testSetup.getNonRepresentedTenderLocation();
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.RepresentedTenderLocations ('testName', false).isPassedFilter(testSetup.tenderLocation);
        Test.stopTest();
        System.assertEquals(false, result, result);
    } 

    @isTest 
    static void isPassedFilterNonRepresentedTenderLocationsTrueTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        testSetup.getNonRepresentedTenderLocation();
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.NotRepresentedTenderLocations ('testName', false).isPassedFilter(testSetup.tenderLocation);
        Test.stopTest();
        System.assertEquals(true, result, result);
    }    

    @isTest 
    static void isPassedFilterNonRepresentedTenderLocationsFalseTest() {
        AITM_RelatedTenderLocationsHldrCtrTestSetup testSetup = new AITM_RelatedTenderLocationsHldrCtrTestSetup().generateData();
        testSetup.createTenderLocation();
        Test.startTest();
        Boolean result = new AITM_RelatedTenderLocationsHolderCntrl.NotRepresentedTenderLocations ('testName', false).isPassedFilter(testSetup.tenderLocation);
        Test.stopTest();
        System.assertEquals(false, result, result);
    }   

    public class AITM_RelatedTenderLocationsHldrCtrTestSetup extends AITM_TestSetup{
        public AITM_Tender__c tender;
        public AITM_Tender_Location__c tenderLocation;
        private final String STATUS_NOT_REPRESENTED = 'Not Represented';

        public AITM_RelatedTenderLocationsHldrCtrTestSetup generateData() {
            AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
            settings.AITM_IsActive__c = true;
            upsert settings AITM_DeactivateTriggerSetting__c.Id;
            tender = createTender();
            insert tender;
            return this;
        }

        public void createTenderLocation() {
            AITM_Location__c parentLocation = super.createLocation();
            insert parentLocation;
            tenderLocation = super.createTenderLocation(tender.Id, parentLocation.Id);
            insert tenderLocation;
        }

        public AITM_Tender_Location__c getTenderLocationWithoutOfferedDifferential() {
            AITM_Location__c parentLocation = super.createLocation();
            insert parentLocation;
            tenderLocation = super.createTenderLocation(tender.Id, parentLocation.Id);
            tenderLocation.AITM_Offered_Differential__c = null;
            insert tenderLocation;
            return tenderLocation;
        }

        public AITM_Tender_Location__c getTenderLocationWithIncludeInRevisedOffer() {
            AITM_Location__c parentLocation = super.createLocation();
            insert parentLocation;
            tenderLocation = super.createTenderLocation(tender.Id, parentLocation.Id);
            tenderLocation.AITM_Include_In_Revised_Offer__c = true;
            insert tenderLocation;
            return tenderLocation;
        }

        public AITM_Tender_Location__c getNonRepresentedTenderLocation() {
            AITM_Location__c parentLocation = super.createLocation();
            insert parentLocation;
            tenderLocation = super.createTenderLocation(tender.Id, parentLocation.Id);
            tenderLocation.AITM_Status__c = STATUS_NOT_REPRESENTED;
            insert tenderLocation;
            return tenderLocation;
        }
    }
}