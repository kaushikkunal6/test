/***************************************************************
 * @author           Kunal
 * @date             08/July/2020
 * @group            AirBP
 * @description      Controller class to handle refresh taxes and fees component: AITM_RefreshTaxes

 * history
 * 08/July/2020  	 Kunal       Created 
 **********************************************************/
public without sharing class AITM_RefreshTaxes {
    
    private @testVisible static String ALL_Locations = 'All Locations';
    private @testVisible static String LOCATION = 'Location(s)';
    private @testVisible static String LOCATION_MANAGERS = 'Location Manager(s)';
    private @testVisible static String COUNTRIES = 'Countries';
    public static String DEFAULT_RECORD_TYPE = 'Default';

    /**
     * @description returns list of filter options
     * @param  null
     * @return List of type String
     */
    public static @AuraEnabled List<String> getFilterOptions() {
        List<String> listOfFilterOptions = new List<String>{ALL_Locations, LOCATION_MANAGERS, COUNTRIES, LOCATION};
        return listOfFilterOptions;
    }

    /**
    * @description gets MultiSelect data
    * @param tenderId of type Id
    * @return Map<String, List<String>>
    */
    @AuraEnabled
    public static Map<String, List<String>> getMultiSelectData(Id tenderId) {
        Set<String> setOfLocationNames = new Set<String>();
        Set<String> setOfLocationManager = new Set<String>();
        List<String> listOfLocationManager = new List<String>();
        Set<String> setOfLocationCountry = new Set<String>();
        List<String> listOfCountries = new List<String>();
        for (AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderId)) {
            setOfLocationNames.add(tenderLocation.AITM_Location__r.Name);
            setOfLocationManager.add(tenderLocation.AITM_Location_Manager__r.Name); 
            setOfLocationCountry.add(tenderLocation.AITM_Country__c); 
        }
        listOfLocationManager = new List<String>(setOfLocationManager);
        listOfLocationManager.sort();
        listOfCountries = new List<String>(setOfLocationCountry);
        listOfCountries.sort();
        Map<String, List<String>> selectData = new Map<String, List<String>>();
        selectData.put('locationNames', new List<String>(setOfLocationNames));
        selectData.put('managerNames', listOfLocationManager);
        selectData.put('countryNames', listOfCountries);
        return selectData;
    }
    
    /**
     * @description Processing the Refresh Batchh
     * @param tenderId of type Id
     * @param OperationSelection of type String
     * @param selectedOption of type String
     * @param selectedValues of type List
     * @param ignoreManualAdjusted of type Boolean
     * @return job Id
     */
    @AuraEnabled
    public static Id processingRefresh(Id tenderId, String OperationSelection, String selectedOption, List<String> selectedValues, Boolean ignoreManualAdjusted){
        Id batchJobId;
        
        AITM_Tender__c tender = getTenderInfo(tenderId);
        tender.AITM_Refresh_Batch_Running__c = true;
        Database.update(new List<AITM_Tender__c>{tender}, false);
        
        if(batchJobId == null){
            AITM_RefreshTaxFeeRecordsBatch.BatchState batchState = new AITM_RefreshTaxFeeRecordsBatch.BatchState(tenderId, OperationSelection, selectedOption, selectedValues, DEFAULT_RECORD_TYPE, ignoreManualAdjusted);
            if(!Test.isRunningTest())
            batchJobId = Database.executeBatch(new AITM_RefreshTaxFeeRecordsBatch(batchState));
        }
        
        return batchJobId;
    }
    
    /**
     * @description returns list of Aysnchrounus jobs
     * @param jobID of type Id
     * @return jobsInfo of type AsyncApexJob
     */
    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, CreatedDate, CompletedDate, CreatedBy.Name, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
        return jobInfo;
    }
    
    /**
     * @description returns TenderInfo
     * @param  tenderId of type id
     * @return tender of type AITM_Tender__c
     */
    @AuraEnabled
    public static AITM_Tender__c getTenderInfo(Id tenderId) {
        AITM_Tender__c tender = [SELECT Id, AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Taxes_Fees_Load_Details_On_Info_Bar__c, AITM_Refresh_Batch_Running__c FROM AITM_Tender__c WHERE Id =:tenderId Limit 1];
        return tender;
    }
}