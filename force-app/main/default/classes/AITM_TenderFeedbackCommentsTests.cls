/**************************************************************************
* @author           Usha Ravi
* @date             18/December/2020
* @group            AirBP
* @description      Test class for AITM_TenderFeedbackComments
*******************************************************************/
@isTest 
public with sharing class AITM_TenderFeedbackCommentsTests {
    
    @isTest
    public static void testTenderLocationDetails() {
        AITM_Tender__c tender;
        List<AITM_Location__c> locations;
        Set<Id> tenderLocationId = new Set<Id>();
        tender = createTender();
        tender.AITM_Tender_Sector__c ='CA';
        insert tender;
        Id tenderId = tender.Id; 
        Integer lineItemsCount = 5;
        String Roundnumber = '1';
        
        locations = createLocations(10);
        insert locations;
        
        List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
        for(AITM_Location__c location : locations){
            tenderLocations.add(
                createTenderLocation(tender.Id, location.Id)
            );
        }
        insert tenderLocations;
        String str = '[{"AMFeedback":"hello","Bidders":3,"currencylist":"EUR","CurrentDiff":7,"DistleadingBid":4,"EstimatedleadingBid":"2","LevelOfInterest":"Max","LMFeedback":"High interest in this volume","locationName":"Perth International","Position":4,"PricingBasis":"P205","pricingResponsibility":"Nick Killen","tenderlocId":"' +tenderLocations[0].Id + '","UOM":"LT","AITM_Leading_Bid__c":"2","Id":"' +tenderLocations[0].Id + '","AITM_Is_Current_Round__c":"true"},{"Bidders":2,"currencylist":"USD","EstimatedleadingBid":1,"LevelOfInterest":"High","LMFeedback":"High interest in this volume","locationName":"Melbourne/Tullamarine","Position":1,"PricingBasis":"P047","pricingResponsibility":"Saravanakumar Surendran,Nick Killen","tenderlocId":"' +tenderLocations[1].Id + '","UOM":"USG"},{"currencylist":"USD","LevelOfInterest":"High","locationName":"Stockholm City/Bromma","PricingBasis":"P209","pricingResponsibility":"Saravanakumar Surendran","tenderlocId":"' +tenderLocations[2].Id + '","UOM":"USG"}]';
		Test.startTest();
        AITM_TenderFeedbackComments.getTenderLocationDetails(tenderId,Roundnumber);
        AITM_TenderFeedbackComments.getPickValues('AITM_Tender__c','AITM_Last_Look_To_Incumbent__c');
        AITM_TenderFeedbackComments.saveTenderFeedbackComments(str);
         Test.stopTest();
    }
    
    public static AITM_Tender_Location__c createTenderLocation(Id tenderId, Id locationId) {
        return new AITM_Tender_Location__c(
            AITM_Tender__c = tenderId,
            AITM_Location__c = locationId,
            AITM_Volume__c = 1.0,
            AITM_Ad_hoc_Volume__c = false,
            AITM_Status__c = 'Ready'
        );
    }  
     
    public static List<AITM_Location__c> createLocations(Integer size) {
        List<AITM_Location__c> result = new List<AITM_Location__c>();
        for (Integer index = 0; index < size; index++) {
            AITM_Location__c iterationLocation = createLocation();
            iterationLocation.Name += String.valueOf(index);
            iterationLocation.AITM_IATA__c += String.valueOf(index);
            iterationLocation.AITM_ICAO__c += String.valueOf(index);
            result.add(iterationLocation);
        }
        return result;
    }
    
    public static AITM_Tender__c createTender() {
        return new AITM_Tender__c(
            Name = 'Test Tender',
            AITM_Tender_Sector__c = 'CA',
            AITM_Start_Date__c = Date.today(),
            AITM_End_Date__c = Date.today().addYears(1),
            AITM_Currency__c = 'USD',
            AITM_Unit_Of_Measure__c = 'USG',
            AITM_Bids_In_By__c = Date.today().addYears(1)
        );
    }
    
    public static AITM_Location__c createLocation() {
        return new AITM_Location__c(
            Name = 'Test Location',
            AITM_ICAO__c = 'CY',
            AITM_IATA__c = 'Y',
            AITM_Currency__c = 'USD',
            AITM_Unit_Of_Measure__c = 'LT'
        );
    }
   
    
}