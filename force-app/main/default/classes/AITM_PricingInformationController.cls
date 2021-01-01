/***********************************************************************************************
 * @author           George
 * @date             10/Nov/2017
 * @group            AirBP
 * @description      Populating Pricing fields in Tender Location Line Item after few calculations in same object for PROS Integration
 
 * history
 * 20/Nov/2017       George          Created
 * 07/March/2018     Ravi Pamidi     Modified - AR-2523 Removed  field as that was converted as formula field.
 * 30/April/2018     srnandan        Modified - AR-2997 - added delivery point number and name 
 *                                   assignments for pricing header and datarows
 * 04/May/2018       srnandan        Modified - AR-2997 - modified the order of columns 
 *                                   and added null check for duration
 * 30/May/2018       srnandan        Modified - AR-3118 - Include TMS Product Desc, SF Product and Density in Pricing Excel
 * 31/May/2018       srnandan        Modified - AR- 3172 - Included Delivery method in excel sheet
 * 12/June/2018      srnandan        Modified - AR-3512 - Changed the header value DELD to DELPD and sharing keyword applied to class
 * 13/June/2018      srnandan        Modified - AR-3541 - Remove column header and values for 
 *                                   ProductSF, Density and Delivery method in Pricing Excel
 * 14/June/2018      srnandan        Modified - AR-3542 Modified method getProductDescription to pass product and soql query
 * 03/December/2018  srnandan        Modified - AR-4726 Added condition to check internal code and assign interncal code if present to iata for display 
 * 11/December/2018  srnandan        Modified - AR-4624 changed the delivery point assignment with new field AITM_Delivery_Point_External_Name__c and AITM_Internal_Code__c
 * 04/February/2019  srnandan        Modified - AR-XXXX market line items to include only won (BR and BG)
 * 25/May/2019       srnandan        Modified - AR-5029 passing Product and Density from lineitem instead of tenderlocation
 *************************************************************************************/
public with sharing class AITM_PricingInformationController  {
    public XLSContent xls {get; set;}

   /**
    * @description This method is used as constructor for main class
    * @param No Parameters
    * @return No Retrun type
    */
    public AITM_PricingInformationController() {
        Id tenderId = getTenderIdFromURL();
        String locationType = getLocationTypeFromURL();
        xls = new XLSContent(tenderId, locationType);
    }

   /**
    * @description This method is used to get Tender Id From URL
    * @param No Parameters
    * @return Returns Id from URL
    */
    private Id getTenderIdFromURL() {
        return Id.valueOf(ApexPages.currentPage().getParameters().get('Id'));
    }

   /**
    * @description This method is used to get Location Type From URL
    * @param No Parameters
    * @return string
    */
    private string getLocationTypeFromURL() {
        return ApexPages.currentPage().getParameters().get('locationType');
    }

   /**
    * @description Inner class stores XLSContent
    */
    public class XLSContent {
        public final String header {get; set;}
        public final String headerRow {get; set;}
        public String data {get; set;}
        public final String footer {get; set;}

       /**
        * @description This Method is used for XLS content of Pricing Row
        * @param tenderId
        * @return Returns content fo Header and footer data
        */
        public XLSContent(Id tenderId, String locationType) {
            List<PricingRow> sheetValues = new PricingDataFactory(tenderId, locationType).create();
            this.header = '<?xml version="1.0"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40"><Styles><Style ss:ID="date_dd_mm_yyyy"><NumberFormat ss:Format="dd.mm.yyyy;@"/></Style></Styles><Worksheet ss:Name="Sheet1"><Table>';
            this.data = '';
            if(sheetValues.size() > 0) {
                this.headerRow = getHeaderRow();
                for (PricingRow row : sheetValues) {
                    this.data += getDataRow(row);
                }
            }
            this.footer = '</Table></Worksheet></Workbook>';
        }

       /**
        * @description This method is used to get Data Row of Pricing Data
        * @param Pricing Row
        * @return Returns DataRow result
        */
        private String getDataRow(PricingRow row) {
            String result = '';
            result += wrapXLSColumn(row.grn, 'String');
            result += wrapXLSColumn(row.customerAccount, 'String');
            result += wrapXLSColumn(row.iata, 'String');
            result += wrapXLSColumn(row.locationName, 'String');
            result += wrapXLSColumn(row.country, 'String');
            result += wrapXLSColumn(row.startDate, 'Date');
            result += wrapXLSColumn(row.endDate, 'Date');
            result += wrapXLSColumn(row.pricingBasisName, 'String');
            result += wrapXLSColumn(row.exchange, 'String');
            result += wrapXLSColumn(row.differential, 'Number');
            result += wrapXLSColumn(row.differentialCurrency, 'String');
            result += wrapXLSColumn(row.differentialUnitsOfMeasure, 'String');
            result += wrapXLSColumn(row.rebate, 'Number');
            result += wrapXLSColumn(row.rebateCurrency, 'String');
            result += wrapXLSColumn(row.rebateUnitsOfMeasure, 'String');
            result += wrapXLSColumn(row.rebateDuration, 'String');
            result += wrapXLSColumn(row.quantity, 'Number');
            result += wrapXLSColumn(row.result, 'String');
            result += wrapXLSColumn(row.product, 'String');
            result += wrapXLSColumn(row.deliveryPointNumber, 'String');
            result += wrapXLSColumn(row.deliveryPointName, 'String');
            result =  wrapXLSRow(result);
            return result;            
        }

       /**
        * @description This method is used to get Header Row
        * @param No Parameters
        * @return Returns string result of header row
        */
        private String getHeaderRow() {
            String result = '';
            result += wrapXLSColumn('GRN', 'String');
            result += wrapXLSColumn('CUST_ACCT_NAME', 'String');
            result += wrapXLSColumn('IATA', 'String');
            result += wrapXLSColumn('LOCATION', 'String');
            result += wrapXLSColumn('COUNTRY', 'String');
            result += wrapXLSColumn('START', 'String');
            result += wrapXLSColumn('END', 'String');
            result += wrapXLSColumn('PINDEX', 'String');
            result += wrapXLSColumn('FX', 'String');
            result += wrapXLSColumn('DIFF', 'String');
            result += wrapXLSColumn('DIFF_CURR', 'String');
            result += wrapXLSColumn('DIFF_UNIT', 'String');
            result += wrapXLSColumn('TVA', 'String');
            result += wrapXLSColumn('TVA_CURR', 'String');
            result += wrapXLSColumn('TVA_UNIT', 'String');
            result += wrapXLSColumn('TVA_DUR', 'String');
            result += wrapXLSColumn('TVA_PER', 'String');
            result += wrapXLSColumn('RESULT', 'String');
            result += wrapXLSColumn('PRODUCT', 'String');
            result += wrapXLSColumn('DELP', 'String');
            result += wrapXLSColumn('DELPD', 'String');
            result =  wrapXLSRow(result);
            return result;            
        }

       /**
        * @description This method is used to return Wram XLS Column
        * @param String value and targetType
        * @return Returns column wrap XLS
        */
        private String wrapXLSColumn(String value, String targetType) {
            if(targetType == 'Date') {
                return '<Cell ss:StyleID="date_dd_mm_yyyy"><Data ss:Type="String">' + value + '</Data></Cell>';
            } else {
                return '<Cell><Data ss:Type="' + targetType + '">' + value + '</Data></Cell>';
            }
            
        }

       /**
        * @description This method is used to return wrapXLS Row
        * @param sting target
        * @return Returns string wrap Row
        */
        private String wrapXLSRow(String target) {
            return '<Row>' + target + '</Row>';
        }
    }

    
   /**
    * @description This class is used as Pricing Data Factory
    * @param No Parameters
    * @return No Return type
    */
    public class PricingDataFactory {
        private Id tenderId;
        private final ID TLLI_ID_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
        private List<PricingRow> pricingRows;
        //private final List<String> MARKET_LINE_ITEMS = new List<String>{'MI','MIX','LB'};
        private final List<String> MARKET_LINE_ITEMS = new List<String>{'BG','BR'};
        private String locationType;

       /**
        * @description This metohd is used for Pricing Data Factory
        * @param tenderId
        * @return No Return
        */
        public PricingDataFactory(Id tenderId, String locationType) {
            this.tenderId = tenderId;
            this.locationType = locationType;
            this.pricingRows = new List<PricingRow>();
            this.populatePricingRows();
        }

       /**
        * @description This method is used to Populate Pricing Rows
        * @param No Parameters
        * @return No return
        */
        public void populatePricingRows() {
            List<AITM_Tender_Location_Line_Item__c> lineItems = new AITM_LocationsDao().getTenderLocationMarketLineItems(this.tenderId, MARKET_LINE_ITEMS, TLLI_ID_RECORD_TYPE_DEBRIEF, this.locationType);
            for(AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                this.pricingRows.add(new PricingRow(lineItem));
            }
        }

       /**
        * @description This method is used to create Pricing Row
        * @param No Parameter
        * @return Returns List of PricingRows
        */
        public List<PricingRow> create() {
            return pricingRows;
        }
    }

   /**
    * @description This class is used to get and set Pricing Rows
    * @param No Parameters
    * @return No Return type
    */
    public class PricingRow {
        public String grn {get; set;}
        public String customerAccount {get; set;}
        public String iata {get; set;}
        public String locationName {get; set;}
        public String country {get; set;}
        public String startDate {get; set;}
        public String endDate {get; set;}
        public String pricingBasisName {get; set;}
        public String exchange {get; set;}
        public String differential {get; set;}
        public String differentialCurrency {get; set;}
        public String differentialUnitsOfMeasure {get; set;}
        public String rebate {get; set;}
        public String rebateCurrency {get; set;}
        public String rebateUnitsOfMeasure {get; set;}
        public String rebateDuration {get; set;}
        public String quantity {get; set;}
        public String result {get; set;}
        public String product {get; set;}
        public String deliveryPointNumber {get; set;}
        public String deliveryPointName {get; set;}

       /**
        * @description This method is used for PricingRow in Tender Location Line Item
        * @param lineItem of AITM_Tender_Location_Line_Item__c
        * @return No Return type
        */
        public PricingRow(AITM_Tender_Location_Line_Item__c lineItem) {
            this.grn = (lineItem.AITM_Account__c != null ? lineItem.AITM_Account__r.AITM_GRN__c : '');
            this.customerAccount = (lineItem.AITM_Account__c != null ? lineItem.AITM_Account__r.Name : '');
            this.iata = (lineItem.AITM_Location_Delivery_Point__c == null ? '' : lineItem.AITM_Location_Delivery_Point__r.AITM_Internal_Code__c != null ? lineItem.AITM_Location_Delivery_Point__r.AITM_Internal_Code__c : lineItem.AITM_Location_Delivery_Point__r.AITM_IATA__c);
            this.locationName = (lineItem.AITM_Location__c != null ? lineItem.AITM_Location__r.Name : '');
            this.country = (lineItem.AITM_Location__c != null ? lineItem.AITM_Location__r.AITM_Country__c : '');
            this.startDate = this.format(lineItem.AITM_Start_Date__c);
            this.endDate = this.format(lineItem.AITM_End_Date__c);
            this.pricingBasisName = (lineItem.AITM_Pricing_Basis__c != null ? lineItem.AITM_Pricing_Basis__r.Name : '');
            this.exchange = lineItem.AITM_Exchange__c;
            this.differential = this.format(lineItem.AITM_Offered_Differential__c);
            this.differentialCurrency = lineItem.AITM_Currency__c;
            this.differentialUnitsOfMeasure = lineItem.AITM_Unit_Of_Measure__c;
            this.rebate = this.format(lineItem.AITM_Rebate__c);
            this.rebateCurrency = lineItem.AITM_Currency_Rebate1__c;
            this.rebateUnitsOfMeasure = lineItem.AITM_Unit_Of_Measure_Rebate1__c;
            this.rebateDuration = (lineItem.AITM_Duration__c == null ? '' : lineItem.AITM_Duration__c);
            this.quantity = this.format(lineItem.AITM_Quantity__c);
            this.result = lineItem.AITM_Tender_Result__c;
            //this.product = this.getProductDescription(lineItem.AITM_Tender_Location__r.AITM_Product__c);
            this.product = this.getProductDescription(lineItem.AITM_Product_Density_for_Pricing__c);
            this.deliveryPointNumber = (lineItem.AITM_Location_Delivery_Point__c != null && lineItem.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_Number__c == null ? '' : lineItem.AITM_Location_Delivery_Point__c == null ? '' : lineItem.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_Number__c);
            this.deliveryPointName = (lineItem.AITM_Location_Delivery_Point__c != null && lineItem.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c == null ? '' : lineItem.AITM_Location_Delivery_Point__c == null ? '' : lineItem.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c);
        }

       /**
        * @description This method is used to returns TMS Product Description mapping value
        * @param product of type string
        * @return String 
        */
        public String getProductDescription(String product) {
            try {
                return [SELECT AITM_Description__c FROM AITM_Product_Density_Mapping__mdt WHERE AITM_TMS_Product_Density__c =: product LIMIT 1].AITM_Description__c;
            }
            catch(Exception ex) {
                return '';
            }
        }

       /**
        * @description This method is used to returns Decimal value format
        * @param value of type decimal
        * @return Returns Decimal value format
        */
        public String format(Decimal value) {
            return (value != null) ? value.format() : '';
        }

       /**
        * @description This method is used to return Date Format
        * @param value of type Date
        * @return Returns String value as Date format
        */
        public String format(Date value) {
            return (value != null) ? value.format() : '';
        }
    }
}