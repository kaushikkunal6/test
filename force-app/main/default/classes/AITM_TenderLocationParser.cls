/************************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Used forfor loading upload file records to locations and staging
 *                   
 * history
 * 01/December/2017  George          Created
 * 28/January/2019   srnandan        Modified-AR-4824 added with sharing keyword to class
 * 28/February/2019  srnandan        Modified AR-5006 Upload File UOM Conversion method createTenderLocationLineItem
 *                                   assigns the field AITM_Requested_Volume_UoM__c the measure passed in file
 ****************************************************************************************************************/
public with sharing class AITM_TenderLocationParser {

    private static final Set<String> STRINGS_TO_IGNORE = new Set<String>{
        'GLOBALREF',
        'TMSDIFF'
    };
    private static final Integer MINIMUM_ROW_SPLITTED_SIZE = 3;
    private static final String VOLUME_TO_SKIP = '-';
    private static final String NEW_LINES_REGEXP = '\\r?\\n';
    private static final String SPACING_REGEXP = '\\s+';
    private static final String LOCATIONS_NOT_REQUIRED = 'X';
    public static final String LOCATION_CODE_DATES_SEPARATOR = ':';

    public Id tenderScope;
    public Set<Id> locationsScope;

    public AITM_TenderLocationParser() {}

    public List<String> getGRNCodes(String firstLine) {
        Set<String> firstLineContent = new Set<String>(firstLine.split(SPACING_REGEXP));
        firstLineContent.removeAll(STRINGS_TO_IGNORE);
        List<String> result = new List<String>();
        for (String possibleGrn : firstLineContent) {
            possibleGrn = possibleGrn.trim();
            if (String.isNotBlank(possibleGrn)) {
                result.add(possibleGrn);
            }
        }
        return result;
    }

    public List<TenderLocationAdapter> parse(Id tenderId, String recordsRaw) {
        List<TenderLocationAdapter> result = new List<TenderLocationAdapter>();
    
        List<String> rawLines = recordsRaw.split(NEW_LINES_REGEXP);
        for (String rawLine : rawLines) {
            rawLine = rawLine.replaceAll('"', '');
            List<String> splittedValue = rawLine.split(SPACING_REGEXP);
            if (splittedValue.size() > MINIMUM_ROW_SPLITTED_SIZE) {
                result.add(new TenderLocationAdapter(tenderId, splittedValue));
            }
        }
        return result;
    }

    public List<AITM_Tender_Location_Line_Item__c> getTenderLocations(String recordsJSON, List<String> grns) {
        List<TenderLocationAdapter> parsedTenderLocationAdapters = (List<TenderLocationAdapter>) JSON.deserialize(recordsJSON, List<TenderLocationAdapter>.class);
        List<AITM_Tender_Location_Line_Item__c> result = new List<AITM_Tender_Location_Line_Item__c>();
        if (parsedTenderLocationAdapters.size() > 0) {
            AITM_Tender__c tenderInScope = new AITM_TenderDao().getTender(parsedTenderLocationAdapters[0].tenderId);
            Map<String, Id> accountsByGRN = new AITM_AccountDao().getAccountsGroupedByGRN(new Set<String>(grns));
            Set<String> locationCodes = getAllLocationCodes(parsedTenderLocationAdapters);
            Map<String, Id> locationsByCodes = new AITM_LocationsDao().getLocationsGroupedByCodes(locationCodes);

            for (TenderLocationAdapter tenderLocationAdapter : parsedTenderLocationAdapters) {
                result.addAll(this.getAvailableTenderLocationLineItems(
                        tenderLocationAdapter,
                        tenderInScope,
                        accountsByGRN,
                        grns,
                        locationsByCodes.get(tenderLocationAdapter.locationCode)
                ));
            }

            tenderScope = tenderInScope.Id;
            locationsScope = new Set<Id>(locationsByCodes.values());
        }
        return result;
    }

    private Set<String> getAllLocationCodes(List<TenderLocationAdapter> parsedTenderLocationAdapters) {
        Set<String> result = new Set<String>();
        for (TenderLocationAdapter tenderLocationAdapter : parsedTenderLocationAdapters) {
            result.add(tenderLocationAdapter.locationCode);
        }
        return result;
    }

    private List<AITM_Tender_Location_Line_Item__c> getAvailableTenderLocationLineItems(TenderLocationAdapter tenderLocationAdapter, AITM_Tender__c tenderInScope, Map<String, Id> accountsByGRN, List<String> grns, Id locationId) {
        List<AITM_Tender_Location_Line_Item__c> result = new List<AITM_Tender_Location_Line_Item__c>();
        for (Integer index = 0; index < grns.size(); index++) {
            Id accountId = accountsByGRN.get(grns[index]);
            String volume = '';

            if (tenderLocationAdapter.volumes.size() > index) {
                volume = tenderLocationAdapter.volumes[index];
            }

            if (this.isTenderLocationRecordAvailable(volume, accountId, locationId)) {
                if (String.isNotBlank(volume) && !volume.equalsIgnoreCase(LOCATIONS_NOT_REQUIRED)) {
                    Decimal decimalValueOfVolume = Decimal.valueOf(volume);
                    result.add(createTenderLocationLineItem(accountId, tenderInScope, locationId, tenderLocationAdapter, decimalValueOfVolume));
                }
            }
        }
        return result;
    }

    private AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id accountId, AITM_Tender__c tenderInScope, Id locationId, TenderLocationAdapter adapter, Decimal volume) {
        Date startDate = adapter.startDate == null ? tenderInScope.AITM_Start_Date__c : adapter.startDate < tenderInScope.AITM_Start_Date__c ? tenderInScope.AITM_Start_Date__c : adapter.startDate;
        Date endDate = adapter.endDate == null ? tenderInScope.AITM_End_Date__c : adapter.endDate > tenderInScope.AITM_End_Date__c ? tenderInScope.AITM_End_Date__c : adapter.endDate;

        AITM_Tender_Location_Line_Item__c result = new AITM_Tender_Location_Line_Item__c(
            AITM_Account__c = accountId,
            AITM_Tender__c = tenderInScope.Id,
            AITM_Location__c = locationId,
            AITM_Start_Date__c = startDate,
            AITM_End_Date__c = endDate,
            AITM_Unit_Of_Measure__c = adapter.unitsOfMeasure,
            AITM_Requested_Volume_UoM__c = adapter.unitsOfMeasure,
            AITM_Record_Type_Name__c = 'Default'           
        );

        if (volume != 0) {
            result.AITM_Volume__c = volume;
        } else {
            result.AITM_Ad_hoc_Volume__c = true;
        }
        return result;
    }

    private Boolean isTenderLocationRecordAvailable(String volume, Id accountId, Id locationId) {
        return String.isNotBlank(volume) 
               && !volume.contains(VOLUME_TO_SKIP) 
               && accountId != null
               && locationId != null;
    }
    
    /**
     * @description adapter class for tenderlocation
     */
    public inherited sharing class TenderLocationAdapter {
        public String locationCode;
        public String unitsOfMeasure;
        public Id tenderId;
        public List<String> volumes;
        public Date startDate;
        public Date endDate;

        public TenderLocationAdapter(Id tenderId, List<String> splittedValue) {
            this.tenderId = tenderId;
            if (!splittedValue[0].contains(AITM_TenderLocationParser.LOCATION_CODE_DATES_SEPARATOR)) {
                this.locationCode = splittedValue[0];
            } else {
                List<String> iataAndDates = splittedValue[0].split(AITM_TenderLocationParser.LOCATION_CODE_DATES_SEPARATOR);

                this.locationCode = iataAndDates[0];
                this.startDate = this.parseDate(iataAndDates[2]);
                this.endDate = this.parseDate(iataAndDates[3]);
            }
            this.unitsOfMeasure = splittedValue[2];

            this.volumes = new List<String>();
            for (Integer index = 3; index < splittedValue.size(); index++) {
                this.volumes.add(splittedValue[index].replaceAll(',', ''));
            }
        }

        public Date parseDate(String dateString) {
            //Assuming a format to be yyyymmdd - not supported by Date.parse & Date.valueOf
            return Date.newInstance(Integer.valueOf(dateString.substring(0, 4)), Integer.valueOf(dateString.substring(4, 6)), Integer.valueOf(dateString.substring(6, 8)));
        }
    }
}