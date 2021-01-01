/***********************************************************************************************
 * @author           Ravi
 * @date             06/Feb/2019
 * @group            AirBP
 * @description      Populating Line Items data with related Locations and Customers and download into excel file format
 
 * history
 * 06/Feb/2019       Ravi          Created
 * 12/Feb/2019       srnandan      Added formatting of cells and appendix headers
 * 14/Feb/2019       srnandan      Added formatting options for excel worksheet
 * 14/Mar/2019       Ravi          Modified as per AR-5089 - Added null checks to requestedUom, netGross, currencyAndUnitOfMeasure, deliveryMethod
 *************************************************************************************/
public with sharing class AITM_TenderOfferExcelController {
    public XLSContent xls {get; set;}

   /**
    * @description This method is used as constructor for main class
    * @param No Parameters
    * @return No Retrun type
    */
    public AITM_TenderOfferExcelController() {
        Id tenderId = getTenderIdFromURL();
        xls = new XLSContent(tenderId);
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
    * @description Inner class stores XLSContent
    */
    public inherited sharing class XLSContent {
        public final String header {get; set;}
        public final String headerRow {get; set;}
        public final String headerContent {get; set;}
        public final String headerAppendixContent {get; set;}
        public String data {get; set;}
        public final String footer {get; set;}
        public String tenderName {get; set;}
        Set<String> locationGroup = new Set<String>();
        Map<String, Integer> groupTotalMap = new Map<String, Integer>();

       /**
        * @description This Method is used for XLS content of Pricing Row
        * @param tenderId
        * @return Returns content fo Header and footer data
        */
        public XLSContent(Id tenderId) {
            List<PricingRow> sheetValues = new PricingDataFactory(tenderId).create();
            this.header = '<?xml version="1.0"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40"><Styles><Style ss:ID="s22"><Alignment ss:Vertical="Top" ss:WrapText="1"/></Style><Style ss:ID="s24"><Font ss:Bold="1" ss:Size="10"/></Style><Style ss:ID="s23"><Alignment ss:Vertical="Bottom" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:Size="10"/><Interior ss:Color="#FFFF00" ss:Pattern="Solid"/></Style><Style ss:ID="date_dd_mm_yyyy"><NumberFormat ss:Format="dd.mm.yyyy;@"/></Style></Styles><Worksheet ss:Name="Sheet1"><Table ss:DefaultColumnWidth="65"><Column ss:AutoFitWidth="0" ss:Width="165"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="96"/><Column ss:AutoFitWidth="0" ss:Width="75"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="96"/><Column ss:AutoFitWidth="0" ss:Width="96"/><Column ss:AutoFitWidth="0" ss:Width="96"/><Column ss:AutoFitWidth="0" ss:Width="96"/><Column ss:AutoFitWidth="0" ss:Width="750"/>';
            this.data = '';
            this.tenderName = '';
            
            if(sheetValues.size() > 0) {
                this.tenderName = sheetValues[0].tenderName;
                this.headerContent = getHeaderContent();
                this.headerAppendixContent = getHeaderAppendixContent();
                this.headerRow = getHeaderRow();
                for(PricingRow rowGroup : sheetValues) {
                    if(groupTotalMap.containsKey(rowGroup.locationNameAndGroup)) {
                        Integer totalQuantity = groupTotalMap.get(rowGroup.locationNameAndGroup);
                        totalQuantity = totalQuantity + Integer.valueOf(rowGroup.quantity);
                        groupTotalMap.put(rowGroup.locationNameAndGroup, totalQuantity);
                    } else {
                        groupTotalMap.put(rowGroup.locationNameAndGroup, Integer.valueOf(rowGroup.quantity));
                    }
                }
                for (PricingRow row : sheetValues) {
                    this.data += getGroupRow(row);
                    this.data += getDataRow(row);
                }
            }
            this.footer = '</Table><WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel"><PageLayoutZoom>0</PageLayoutZoom><Selected/><FreezePanes/><FrozenNoSplit/><SplitHorizontal>1</SplitHorizontal><TopRowBottomPane>1</TopRowBottomPane><ActivePane>2</ActivePane><Panes><Pane><Number>3</Number></Pane></Panes><ProtectObjects>False</ProtectObjects><ProtectScenarios>False</ProtectScenarios></WorksheetOptions></Worksheet></Workbook>';
        }

       /**
        * @description This method is used to get Data Row of Pricing Data
        * @param Pricing Row
        * @return Returns DataRow result
        */
        private String getDataRow(PricingRow row) {
            String result = '';
            Set<String> locationGroup = new Set<String>();
            
            result += wrapXLSColumn('', 'String');
            result += wrapXLSColumn(row.customerAccount, 'String');
            result += wrapXLSColumn('', 'String');
            result += wrapXLSColumn(String.valueOf(row.quantity), 'Number');
            result += wrapXLSColumn(row.requestedUom, 'String');
            result += wrapXLSColumn(row.netGross, 'String');
            result += wrapXLSColumn('', 'String');        
            result += wrapXLSColumn(row.pricingBasisDesc, 'String');
            result += wrapXLSColumn(row.differential, 'Number');
            result += wrapXLSColumn(row.currencyAndUnitOfMeasure, 'String');
            result += wrapXLSColumn(row.invoiceFrequency, 'String');
            result += wrapXLSColumn(row.creditDays, 'String');
            result += wrapXLSColumn(row.deliveryPoint, 'String');
            result += wrapXLSColumn(row.fuelProviderServiceArea, 'String');
            result += wrapXLSColumn(row.airportIntoPlaneProviderBulkName, 'String');
            result += wrapXLSColumn(row.deliveryMethod, 'String');
            result += wrapXLSColumn(row.taxesAndFees.replaceAll('\r',''), 'String');    
            result =  wrapXLSRow(result);
            return result;            
        }

       /**
        * @description This method is used to get Data Row of Pricing Data
        * @param Pricing Row
        * @return Returns DataRow result
        */
        private String getGroupRow(PricingRow row) {
            String result = '';
            if(!locationGroup.contains(row.locationNameAndGroup)) {
                locationGroup.add(row.locationNameAndGroup);
                result += wrapXLSColumn(row.locationNameAndGroup, 'String');
                result += wrapXLSColumn('', 'String');
                result += wrapXLSColumn(row.startAndEndDate, 'String');
                result += wrapXLSColumn(String.valueOf(groupTotalMap.get(row.locationNameAndGroup)), 'String');
                result += wrapXLSColumn(row.requestedUom, 'String');
                result += wrapXLSColumn('', 'String');
                result += wrapXLSColumn(row.product, 'String');
                result += wrapXLSColumn('', 'String');
                result += wrapXLSColumn('', 'String');
                result += wrapXLSColumn('', 'String');
                result += wrapXLSColumn('', 'String');
                result += wrapXLSColumn('', 'String');
                result += wrapXLSColumn('', 'String');
                result += wrapXLSColumn('', 'String');
                result += wrapXLSColumn('', 'String');
            }
            
            result =  wrapXLSRow(result);
            return result;            
        }

       /**
        * @description This method is used to get Header Row
        * @param null
        * @return String header content
        */
        private String getHeaderContent() {
            String result = '';
            result += wrapXLSHeaderBoldColumn('Offer from Air BP Limited for ' + this.tenderName + ' ' + 'dated' + ' ' + System.today().format(), 'String');
            result = wrapXLSRow(result);
            return result;
        }
        
       /**
        * @description This method is used to get Header Appendix Content
        * @param null
        * @return String appendix content
        */
        private String getHeaderAppendixContent() {
            String result = '';
            result += wrapXLSHeaderBoldColumn('Appendix 1', 'String');
            result = wrapXLSRow(result);
            return result;
        }

       /**
        * @description This method is used to get Header Row
        * @param null
        * @return String result of header row
        */
        private String getHeaderRow() {
            String result = '';
            result += wrapXLSHeaderColumn('Location (1) and Location Group (2)', 'String');
            result += wrapXLSHeaderColumn('CUSTOMER', 'String');
            result += wrapXLSHeaderColumn('START DATE AND END DATE', 'String');
            result += wrapXLSHeaderColumn('QUANTITY', 'String');
            result += wrapXLSHeaderColumn('UNIT (3) / PERIOD', 'String');
            result += wrapXLSHeaderColumn('NET / GROSS', 'String');
            result += wrapXLSHeaderColumn('PRODUCT', 'String');
            result += wrapXLSHeaderColumn('PRICE', 'String');
            result += wrapXLSHeaderColumn('DIFFERENTIAL', 'String');
            result += wrapXLSHeaderColumn('Curr / Unit', 'String');
            result += wrapXLSHeaderColumn('INVOICE FREQUENCY', 'String');
            result += wrapXLSHeaderColumn('CREDIT DAYS', 'String');
            result += wrapXLSHeaderColumn('DELIVERY POINT EXTERNAL NAME', 'String');
            result += wrapXLSHeaderColumn('FUEL PROVIDER SERVICE AREA', 'String');
            result += wrapXLSHeaderColumn('AIRPORT INTO PLANE PROVIDER BULK NAME', 'String');
            result += wrapXLSHeaderColumn('DELIVERY METHOD', 'String');
            result += wrapXLSHeaderColumn('TAXES AND FEES', 'String');
            result =  wrapXLSRow(result);
            return result;            
        }

       /**
        * @description This method is used to return Wram XLS Column
        * @param String value and targetType
        * @return Returns column wrap XLS
        */
        private String wrapXLSColumn(String value, String targetType) {
            /*if(targetType == 'Date') {
                return '<Cell ss:StyleID="date_dd_mm_yyyy"><Data ss:Type="String">' + value + '</Data></Cell>';
            } else {*/
                return '<Cell ss:StyleID="s22"><Data ss:Type="' + targetType + '">' + value + '</Data></Cell>';
            //}
            
        }

       /**
        * @description This method is used to return Wram XLS Column
        * @param String value and targetType
        * @return Returns column wrap XLS
        */
        private String wrapXLSHeaderBoldColumn(String value, String targetType) {
            return '<Cell ss:StyleID="s24"><Data ss:Type="' + targetType +'">' + value + '</Data></Cell>';
        }

       /**
        * @description This method is used to return Wram XLS Column
        * @param String value and targetType
        * @return Returns column wrap XLS
        */
        private String wrapXLSHeaderColumn(String value, String targetType) {
            return '<Cell ss:StyleID="s23"><Data ss:Type="' + targetType + '">' + value + '</Data></Cell>';
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
    public inherited sharing class PricingDataFactory {
        private Id tenderId;
        private List<PricingRow> pricingRows;
        
       /**
        * @description This metohd is used for Pricing Data Factory
        * @param tenderId
        * @return No Return
        */
        public PricingDataFactory(Id tenderId) {
            this.tenderId = tenderId;
            this.pricingRows = new List<PricingRow>();
            this.populatePricingRows();
        }

       /**
        * @description This method is used to Populate Pricing Rows
        * @param null
        * @return null
        */
        public void populatePricingRows() {
            List<AITM_Tender_Location_Line_Item__c> lineItems = new AITM_LocationsDao().getTenderLocationLineItemsByTenderForXLS(this.tenderId);
            
            for(AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                this.pricingRows.add(new PricingRow(lineItem));
            }
        }

       /**
        * @description This method is used to create Pricing Row
        * @param null
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
        public String tenderName {get; set;}
        public String customerAccount {get; set;}
        public String locationNameAndGroup {get; set;}
        public String startAndEndDate {get; set;}
        public Decimal quantity {get; set;}
        public String totalVolume {get; set;}
        public String requestedUom {get; set;}
        public String product {get; set;}
        public String netGross {get; set;}
        public String deliveryPoint {get; private set;}
        public String fuelProviderServiceArea {get; private set;}
        public String airportIntoPlaneProviderBulkName {get; private set;}
        public String pricingBasis {get; private set;}
        public String pricingBasisDesc {get; private set;}
        public String invoiceFrequency {get; private set;}
        public String creditDays {get; private set;}
        public String deliveryMethod {get; private set;}
        public String currencyAndUnitOfMeasure {get; set;}
        public String differential {get; set;}
        public String taxesAndFees {get; set;}

       /**
        * @description This method is used for PricingRow in Tender Location Line Item
        * @param lineItem of AITM_Tender_Location_Line_Item__c
        * @return No Return type
        */
        public PricingRow(AITM_Tender_Location_Line_Item__c lineItem) {
            this.tenderName = (lineItem.AITM_Tender__c != null ? lineItem.AITM_Tender__r.Name : '');
            this.customerAccount = (lineItem.AITM_Account__c != null ? lineItem.AITM_Account__r.Name : '');
            this.locationNameAndGroup = (lineItem.AITM_Location__c != null ? lineItem.AITM_Location__r.Name : '') + ' ' +(lineItem.AITM_Location__r.AITM_Location_Group__c != null ? lineItem.AITM_Location__r.AITM_Location_Group__c : '') +  ' ' +(lineItem.AITM_Location__r.AITM_IATA_ICAO__c != null ? lineItem.AITM_Location__r.AITM_IATA_ICAO__c : '');
            this.startAndEndDate = this.format(lineItem.AITM_Start_Date__c) + '<br/> to ' + this.format(lineItem.AITM_End_Date__c);
            this.quantity = (lineItem.AITM_Yearly_Volume__c == null ? 0 : lineItem.AITM_Yearly_Volume__c);
            this.totalVolume = this.format(lineItem.AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c);
            this.requestedUom = (lineItem.AITM_Requested_Volume_UoM__c == null ? '' : lineItem.AITM_Requested_Volume_UoM__c) + ' / Year';
            this.product = AITM_BaseUtils.getProductDescription(lineItem.AITM_Product_Density_for_Pricing__c);
            this.netGross = (lineItem.AITM_Measure__c == null ? '' : lineItem.AITM_Measure__c);
            this.deliveryPoint = (lineItem.AITM_Location_Delivery_Point__c != null ? lineItem.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c : '');
            this.fuelProviderServiceArea = (lineItem.AITM_Location_Delivery_Point__c != null ? (lineItem.AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c != null ? lineItem.AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c : ''): '');
            this.airportIntoPlaneProviderBulkName = (lineItem.AITM_Location_Delivery_Point__c != null ?lineItem.AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c : '');
            this.pricingBasis = lineItem.AITM_Pricing_Basis__r.Name;
            this.pricingBasisDesc = lineItem.AITM_Pricing_Basis_Description__c;
            if(lineItem.AITM_Pricing_Basis__r.AITM_Type__c == 'C' && lineItem.AITM_Current_Value__c != null) {
                this.differential = this.format(lineItem.AITM_Current_Value__c);
                this.pricingBasisDesc += '. See the Diff. column for current Price.';
            } else {
                this.differential = this.format(lineItem.AITM_Offered_Differential__c);
            }
            this.currencyAndUnitOfMeasure = (lineItem.AITM_Currency__c == null ?'' : lineItem.AITM_Currency__c) + ' / '+ (lineItem.AITM_Unit_Of_Measure__c == null ? '' : lineItem.AITM_Unit_Of_Measure__c);
            this.invoiceFrequency = (lineItem.AITM_Invoice_Frequency__c == null ? '' : lineItem.AITM_Invoice_Frequency__c);
            this.creditDays = (lineItem.AITM_Credit_Days__c == null ? '' : lineItem.AITM_Credit_Days__c);
            this.deliveryMethod= (lineItem.AITM_Delivery_Method__c == null ? '' : lineItem.AITM_Delivery_Method__c);
            this.taxesAndFees = (lineItem.AITM_Taxes_Fees__c != null ?lineItem.AITM_Taxes_Fees__c.escapeHtml4() : '');
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