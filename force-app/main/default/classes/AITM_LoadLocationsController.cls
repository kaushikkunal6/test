/************************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Used forfor loading upload file records to locations and staging
 *                   
 * history
 * 01/December/2017  George          Created
 * 31/December/2018  srnandan        Added retry logic from staging records method loadFromStaging
 * 28/January/2019   srnandan        Modified-AR-4824 added methods parseBatch
 ****************************************************************************************************************/
public with sharing class AITM_LoadLocationsController {

    private @testVisible static final String RUNNING_STATE = 'INPROGRESS';
    private @testVisible static final String DONE_STATE = 'DONE';
    private static final Set<String> RUNNING_JOB_STATUSES = new Set<String>{'Queued', 'Preparing', 'Processing'};

    public @AuraEnabled static String validateGRNCodes(Id tenderId, String firstLine) {
        List<String> grnCodes = new AITM_TenderLocationParser().getGRNCodes(firstLine);
        
        String result = '';
        List<AITM_Tender_Account__c> customers  = new AITM_LocationsDao().getTenderAccountsByTenderId(tenderId);
        Set<String> existingGRNCodes = new Set<String>();

        for (AITM_Tender_Account__c customer : customers) {
            existingGRNCodes.add(customer.AITM_Account__r.AITM_GRN__c);
        }
        for (String grn : grnCodes) {
            if (!existingGRNCodes.contains(grn)) {
                result = AITM_LoadLocationsController.getGRNErrorString(result, grn);
            }
        }

        if (String.isNotBlank(result)) {
            grnCodes.clear();
        }
        return result;  
    }

    public @AuraEnabled static Integer loadFromStaging(Id tenderId) {
        Map<Id, AITM_Tender_Location_Line_Item__c> tenderLocations = new AITM_LocationsDao().getTenderLocationLineItemsFromStaging(tenderId);
        List<AITM_Tender_Location_Line_Item__c> failedLocations = new List<AITM_Tender_Location_Line_Item__c>();
        List<AITM_Tender_Location_Staging__c> stagingObjects = new List<AITM_Tender_Location_Staging__c>();
        Integer failedRecords = 0;
        Integer successRecords = 0;
        if (!tenderLocations.isEmpty()) {
            Database.SaveResult[] results = Database.insert(tenderLocations.values(), false);
            for(Database.SaveResult result : results) {
                if(!result.isSuccess()) {
                    failedRecords = failedRecords + 1;
                } else {
                    successRecords = successRecords + 1;
                }
            }
        }
        Database.delete([SELECT Id FROM AITM_Tender_Location_Staging__c WHERE Id IN :tenderLocations.keySet()], false);
        return (tenderLocations.isEmpty() ? 0 : failedRecords);
    }

    public @AuraEnabled static String validateLocationCodes(List<String> codes) {
        Map<String, Id> existingCodes = new AITM_LocationsDao().getLocationsGroupedByCodes(new Set<String>(codes));

        String result = '';
        for (String code : codes) {
            if (!existingCodes.containsKey(code) && String.isNotBlank(code)) {
                result = AITM_LoadLocationsController.getLocationsErrorString(result, code);
            }
        }

        return result;
    }

    public @AuraEnabled static void parse(Id tenderId, String recordsRaw, String firstLine) {
        AITM_TenderLocationParser parser = new AITM_TenderLocationParser();
        List<AITM_TenderLocationParser.TenderLocationAdapter> parsedLines = parser.parse(tenderId, recordsRaw);
        List<String> grnCodes = parser.getGRNCodes(firstLine);
        AITM_LoadLocationsController.load(JSON.serialize(parsedLines), grnCodes);
    }

    public @AuraEnabled static void parseBatch(Id tenderId, String recordsRaw, String firstLine) {
        AITM_TenderLocationParser parser = new AITM_TenderLocationParser();        
        List<AITM_TenderLocationParser.TenderLocationAdapter> parsedLines = parser.parse(tenderId, recordsRaw);
        if(AITM_BaseUtils.checkSharePermission(tenderId)) {
        	List<String> grnCodes = parser.getGRNCodes(firstLine);
        	AITM_LoadLocationsController.loadBatch(JSON.serialize(parsedLines), grnCodes);
        } else {
           throw new AuraHandledException(Label.AITM_LackingPermissions);
        }   
    }

    public static void loadBatch(String recordsJSON, List<String> grns) {
        AITM_TenderLocationParser parser = new AITM_TenderLocationParser();
        List<AITM_Tender_Location_Line_Item__c> tenderLocations = parser.getTenderLocations(recordsJSON, grns);
        if (!tenderLocations.isEmpty()) {
            new AITM_TenderLocationDuplicatesHandler().checkForDuplicatesAndSaveBatch(tenderLocations);
        }     
    }

    public @AuraEnabled static String check() {
        List<AsyncApexJob> futures = [SELECT Id FROM AsyncApexJob WHERE JobType = 'Future' AND MethodName = 'load' AND Status IN :RUNNING_JOB_STATUSES];

        if (futures.size() > 0) {
            return RUNNING_STATE;
        } else {
            return DONE_STATE;
        }
    }

    public @AuraEnabled static String checkBatch() {
        AITM_UploadLocationsBatch.BatchFactory factory = new AITM_UploadLocationsBatch.BatchFactory();
        return factory.check();
    }
        
    public @future static void load(String recordsJSON, List<String> grns) {
        AITM_TenderLocationParser parser = new AITM_TenderLocationParser();
        List<AITM_Tender_Location_Line_Item__c> tenderLocations = parser.getTenderLocations(recordsJSON, grns);
        if (!tenderLocations.isEmpty()) {
            new AITM_TenderLocationDuplicatesHandler().checkForDuplicatesAndSave(tenderLocations);
        }
    }

    private static String getGRNErrorString(String result, String customerGRN) {
        if (String.isEmpty(result)) {
            result = Label.AITM_UploadLocationGRNErrorMessage + customerGRN;
        }
        else {
            result += ', ' + customerGRN;
        }

        return result;
    }

    private static String getLocationsErrorString(String result, String code) {
        if (String.isEmpty(result)) {
            result = Label.AITM_UploadLocationLocationsCodesErrorMessage + code;
        }
        else {
            result += ', ' + code;
        }

        return result;
    }
}