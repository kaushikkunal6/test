/***********************************************************************************************
 * @author           Ravi
 * @date             07/May/2019
 * @group            AirBP
 * @description      Populating Line Items data with related Locations and Customers and attach into excel file format
 
 * history
 * 07/May/2019       Ravi          Created
 *************************************************************************************/
public with sharing class AITM_InvitationGenerateXLS {
    public XLSContent xls {get; set;}

   /**
    * @description This method is used as constructor for main class
    * @param No Parameters
    * @return No Retrun type
    */
    public AITM_InvitationGenerateXLS() {
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
    public with sharing class XLSContent {
        public final String header {get; set;}
        public final String headerRow {get; set;}
        public final String headerContent {get; set;}
        public final String headerContent1 {get; set;}
        public final String headerContentEmptyRow {get; set;}
        public final String headerContentEmptyRow1 {get; set;}
        public final String headerContentEmptyRow2 {get; set;}
        public final String headerResultContent {get; set;}
        public String data {get; set;}
        public final String footer {get; set;}
        public String tenderName {get; set;}
        public String headerStartAndEndDate {get; set;}
        public final String headerNumberOfLocations {get; set;}
        Set<String> locationGroup = new Set<String>();
        Map<String, Integer> groupTotalMap = new Map<String, Integer>();

       /**
        * @description This Method is used for XLS content of Pricing Row
        * @param tenderId
        * @return Returns content fo Header and footer data
        */
        public XLSContent(Id tenderId, String locationType) {
            PricingDataFactory priceFactory = new PricingDataFactory(tenderId, locationType); 
            List<PricingRow> sheetValues = priceFactory.create();
            Integer numberOfLocationsCount = priceFactory.getNumberOfLocations();
            this.header = '<?xml version="1.0"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40"><Styles><Style ss:ID="date_dd_mmm_yyyy"><NumberFormat ss:Format="dd.mmm.yyyy;@"/><Alignment ss:Vertical="Top" ss:WrapText="1"/></Style><Style ss:ID="s22"><Alignment ss:Vertical="Top" ss:WrapText="1"/></Style><Style ss:ID="s28"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#ff0000" /></Style><Style ss:ID="s27"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#0000FF" /></Style><Style ss:ID="s26"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#008000" /></Style><Style ss:ID="s25"><Font ss:Bold="1" ss:Size="22"/></Style><Style ss:ID="s24"><Font ss:Bold="1" ss:Size="20"/></Style><Style ss:ID="s29"><Alignment ss:Vertical="Bottom" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:Size="10"/><Interior ss:Color="#008000" ss:Pattern="Solid"/></Style><Style ss:ID="s23"><Alignment ss:Vertical="Bottom" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:Size="10"/><Interior ss:Color="#86D126" ss:Pattern="Solid"/></Style><Style ss:ID="date_dd_mm_yyyy"><NumberFormat ss:Format="dd.mm.yyyy;@"/></Style></Styles><Worksheet ss:Name="Sheet1"><Table ss:DefaultColumnWidth="65"><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="95"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="85"/><Column ss:AutoFitWidth="0" ss:Width="105"/><Column ss:AutoFitWidth="0" ss:Width="105"/><Column ss:AutoFitWidth="0" ss:Width="350"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="250"/><Column ss:AutoFitWidth="0" ss:Width="180"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="250"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/>';
            this.data = '';
            this.tenderName = '';
            this.headerStartAndEndDate = '';
            
            if(sheetValues.size() > 0) {
                this.tenderName = sheetValues[0].tenderName;
                this.headerStartAndEndDate = sheetValues[0].startAndEndDate;
                this.headerContent1 = getHeaderContent1();
                this.headerContent = getHeaderContent();
                this.headerContentEmptyRow = getHeaderContentEmptyRow();
                this.headerContentEmptyRow1 = getHeaderContentEmptyRow1();
                this.headerContentEmptyRow2 = getHeaderContentEmptyRow2();
                this.headerResultContent = getHeaderResultContent();
                this.headerNumberOfLocations = getHeaderNumberOfLocations(numberOfLocationsCount);
                this.headerRow = getHeaderRow();

                for (PricingRow row : sheetValues) {
                    this.data += getDataRow(row);
                }
            }
            this.footer = '</Table><WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel"><PageLayoutZoom>0</PageLayoutZoom><Selected/><FreezePanes/><FrozenNoSplit/><SplitHorizontal>1</SplitHorizontal><TopRowBottomPane>1</TopRowBottomPane><ActivePane>2</ActivePane><Panes><Pane><Number>3</Number></Pane></Panes><ProtectObjects>False</ProtectObjects><ProtectScenarios>False</ProtectScenarios></WorksheetOptions></Worksheet></Workbook>';
        } 
       /**
        * @description This Method is used for XLS content of Pricing Row
        * @param tenderId
        * @return Returns content fo Header and footer data
        */
        public XLSContent(Id tenderId) {
            PricingDataFactory priceFactory = new PricingDataFactory(tenderId); 
            List<PricingRow> sheetValues = priceFactory.create();
            Integer numberOfLocationsCount = priceFactory.getNumberOfLocations();
            this.header = '<?xml version="1.0"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40"><Styles><Style ss:ID="date_dd_mmm_yyyy"><NumberFormat ss:Format="dd.mmm.yyyy;@"/><Alignment ss:Vertical="Top" ss:WrapText="1"/></Style><Style ss:ID="s22"><Alignment ss:Vertical="Top" ss:WrapText="1"/></Style><Style ss:ID="s28"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#ff0000" /></Style><Style ss:ID="s27"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#0000FF" /></Style><Style ss:ID="s26"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#008000" /></Style><Style ss:ID="s25"><Font ss:Bold="1" ss:Size="22"/></Style><Style ss:ID="s24"><Font ss:Bold="1" ss:Size="20"/></Style><Style ss:ID="s29"><Alignment ss:Vertical="Bottom" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:Size="10"/><Interior ss:Color="#008000" ss:Pattern="Solid"/></Style><Style ss:ID="s23"><Alignment ss:Vertical="Bottom" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:Size="10"/><Interior ss:Color="#86D126" ss:Pattern="Solid"/></Style><Style ss:ID="date_dd_mm_yyyy"><NumberFormat ss:Format="dd.mm.yyyy;@"/></Style></Styles><Worksheet ss:Name="Sheet1"><Table ss:DefaultColumnWidth="65"><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="95"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="85"/><Column ss:AutoFitWidth="0" ss:Width="105"/><Column ss:AutoFitWidth="0" ss:Width="105"/><Column ss:AutoFitWidth="0" ss:Width="350"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="250"/><Column ss:AutoFitWidth="0" ss:Width="180"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="250"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/>';
            this.data = '';
            this.tenderName = '';
            this.headerStartAndEndDate = '';
            
            if(sheetValues.size() > 0) {
                this.tenderName = sheetValues[0].tenderName;
                this.headerStartAndEndDate = sheetValues[0].startAndEndDate;
                this.headerContent1 = getHeaderContent1();
                this.headerContent = getHeaderContent();
                this.headerContentEmptyRow = getHeaderContentEmptyRow();
                this.headerContentEmptyRow1 = getHeaderContentEmptyRow1();
                this.headerContentEmptyRow2 = getHeaderContentEmptyRow2();
                this.headerResultContent = getHeaderResultContent();
                this.headerNumberOfLocations = getHeaderNumberOfLocations(numberOfLocationsCount);
                this.headerRow = getHeaderRow();

                for (PricingRow row : sheetValues) {
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
            
            result += wrapXLSColumn(row.iataIcao, 'String');
            result += wrapXLSColumn(row.country, 'String');
            result += wrapXLSColumn(row.airportName, 'String');
            result += wrapXLSColumn(row.deliveryPoint, 'String');
            result += wrapXLSColumn(row.pricingResponsibility, 'String');
            result += wrapXLSColumn(row.customerAccount, 'String');
            result += wrapXLSColumn(row.grn, 'String');
            result += wrapXLSColumn(String.valueOf(row.requestedVolume), 'Number');
            result += wrapXLSColumn(String.valueOf(row.volumeOffered), 'Number');
            result += wrapXLSColumn(row.startDate, 'Date');
            result += wrapXLSColumn(row.endDate, 'Date');
            result += wrapXLSColumn(row.accountManagerNotesInstructions, 'String');
            result += wrapXLSColumn(row.historyLastTenderResult, 'String');
            result += wrapXLSColumn(row.historyVolume, 'String');
            result += wrapXLSColumn(row.historyPricingBasis, 'String');
            result += wrapXLSColumn(row.historyPricingBasisDesc, 'String');
            result += wrapXLSColumn(row.historyDeliveryPoint, 'String');
            result += wrapXLSColumn(row.historyDifferential, 'String');
            result += wrapXLSColumn(row.historyGP, 'String');
            result += wrapXLSColumn(row.tenderLink, 'href');
            result =  wrapXLSRow(result);
            return result;            
        }

       /**
        * @description This method is used to get Header Row
        * @param null
        * @return String header content
        */
        private String getHeaderContent1() {
            String result = '';
            result += wrapXLSHeaderBoldColumn('Invitation to price for your tender location(s)' , 'String');
            result = wrapXLSRow(result);
            return result;
        }

       /**
        * @description This method is used to get Header Row
        * @param null
        * @return String header content
        */
        private String getHeaderContent() {
            String result = '';
            result += wrapXLSHeaderValueBoldColumn(this.tenderName + ' - ' +  this.headerStartAndEndDate, 'String');
            result = wrapXLSRow(result);
            return result;
        }

       /**
        * @description This method is used to get Header Row
        * @param null
        * @return String header content
        */
        private String getHeaderContentEmptyRow() {
            String result = '';
            result += wrapXLSHeaderBoldColumn(' ' , 'String');
            result = wrapXLSRow(result);
            return result;
        }

       /**
        * @description This method is used to get Header Row
        * @param null
        * @return String header content
        */
        private String getHeaderContentEmptyRow1() {
            String result = '';
            result += wrapXLSHeaderBoldColumn(' ' , 'String');
            result = wrapXLSRow(result);
            return result;
        }

       /**
        * @description This method is used to get Header Row
        * @param null
        * @return String header content
        */
        private String getHeaderContentEmptyRow2() {
            String result = '';
            result += wrapXLSHeaderBoldColumn(' ' , 'String');
            result = wrapXLSRow(result);
            return result;
        }
        
       /**
        * @description This method is used to get Header Result Content
        * @param null
        * @return String result content
        */
        private String getHeaderResultContent() {
            String result = '';
            result += wrapXLSHeaderResultsColumn('Location Tender Request', 'String');
            result = wrapXLSRow(result);
            return result;
        }

       /**
        * @description This method is used to get Header Number of Locations Content
        * @param List<PricingRow> list collection
        * @return String result content
        */
        private String getHeaderNumberOfLocations(Integer rowsCount) {
            String result = '';
            result += wrapXLSColumn('Number Of Locations(s)', 'String');
            result += wrapXLSColumn(string.valueOf(rowsCount), 'Number');
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
            result += wrapXLSHeaderColumn('IATA/ICAO', 'String');
            result += wrapXLSHeaderColumn('COUNTRY', 'String');
            result += wrapXLSHeaderColumn('AIRPORT NAME', 'String');
            result += wrapXLSHeaderColumn('DELIVERY POINT', 'String');
            result += wrapXLSHeaderColumn('PRICING RESPONSIBILITY', 'String');
            result += wrapXLSHeaderColumn('CUSTOMER NAME', 'String');
            result += wrapXLSHeaderColumn('GRN', 'String');
            result += wrapXLSHeaderColumn('VOLUME (TENDERED)', 'String');
            result += wrapXLSHeaderColumn('VOLUME (USG)', 'String');
            result += wrapXLSHeaderColumn('START DATE (DD/MM/YYYY)', 'String');
            result += wrapXLSHeaderColumn('END DATE (DD/MM/YYYY)', 'String');
            result += wrapXLSHeaderColumn('ACCOUNT MANAGER NOTES/INSTRUCTIONS', 'String');
            result += wrapXLSHeaderColumn('HISTORY - LAST TENDER RESULT', 'String');
            result += wrapXLSHeaderColumn('HISTORY - VOLUME (TENDERED)', 'String');
            result += wrapXLSHeaderColumn('HISTORY - PRICING BASIS', 'String');
            result += wrapXLSHeaderColumn('HISTORY - PRICING BASIS DESCRIPTION', 'String');
            result += wrapXLSHeaderColumn('HISTORY - DELIVERY POINT', 'String');
            result += wrapXLSHeaderColumn('HISTORY - DIFFERENTIAL', 'String');
            result += wrapXLSHeaderColumn('HISTORY - GP', 'String');
            result += wrapXLSHeaderColumn('HISTORY - TENDER LINK', 'String');
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
                return '<Cell ss:StyleID="date_dd_mmm_yyyy"><Data ss:Type="String">' + value + '</Data></Cell>';
            } else if(targetType == 'href') {
                if(value == '') {
                    return '<Cell ss:StyleID="s22"><Data ss:Type="String">' + value + '</Data></Cell>';    
                } else {
                    return '<Cell ss:StyleID="s22" ss:HRef="'+ value +'"><Data ss:Type="String">' + value + '</Data></Cell>';
                }
            } else {
                return '<Cell ss:StyleID="s22"><Data ss:Type="' + targetType + '">' + value + '</Data></Cell>';
            }
        }

       /**
        * @description This method is used to return Wram XLS Column
        * @param String value and targetType
        * @return Returns column wrap XLS
        */
        private String wrapXLSHeaderBoldColumn(String value, String targetType) {
            return '<Cell ss:StyleID="s25"><Data ss:Type="' + targetType +'">' + value + '</Data></Cell>';
        }

       /**
        * @description This method is used to return Wram XLS Header Value Column
        * @param String value and targetType
        * @return Returns column wrap XLS
        */
        private String wrapXLSHeaderValueBoldColumn(String value, String targetType) {
            return '<Cell ss:StyleID="s24"><Data ss:Type="' + targetType +'">' + value + '</Data></Cell>';
        } 
       
       /**
        * @description This method is used to return Wram XLS Column
        * @param String value and targetType
        * @return Returns column wrap XLS
        */
        private String wrapXLSHeaderColumn(String value, String targetType) {
            return '<Cell ss:StyleID="s23"><Data ss:Type="' + targetType + '" >' + value + '</Data></Cell>';
        }
       
       /**
        * @description This method is used to return Wram XLS Column
        * @param String value and targetType
        * @return Returns column wrap XLS
        */
        private String wrapXLSHeaderResultsColumn(String value, String targetType) {
            return '<Cell ss:StyleID="s29"><Data ss:Type="' + targetType + '" >' + value + '</Data></Cell>';
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
    public with sharing class PricingDataFactory {
        private Id tenderId;
        private String locationType;
        private final ID TLLI_ID_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
        private List<PricingRow> pricingRows;

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
            List<AITM_Tender_Location_Line_Item__c> lineItems = new AITM_LocationsDao().getTenderLocationLineItemsByTenderForInvitationXLS(this.tenderId, this.locationType);
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

       /**
        * @description This method is used to create Pricing Row
        * @param null
        * @return Returns List of PricingRows
        */
        public Integer getNumberOfLocations() {
            Integer representedLocations = new AITM_LocationsDao().getCurrentRoundCountTenderLocations(this.tenderId, this.locationType);
            return representedLocations;
        }
    }

   /**
    * @description This class is used to get and set Pricing Rows
    * @param No Parameters
    * @return No Return type
    */
    public with sharing class PricingRow {
        public String tenderName {get; set;}
        public String iataIcao {get; set;}
        public String country {get; set;}
        public String airportName {get; set;}
        public String deliveryPoint {get; set;}
        public String pricingResponsibility {get; set;}
        public String customerAccount {get; set;}
        public String grn {get; set;}
        public Decimal requestedVolume {get; set;}
        public Decimal volumeOffered {get; set;}
        public String startDate {get; set;}
        public String endDate {get; set;}
        public String accountManagerNotesInstructions {get; set;}
        public String historyLastTenderResult {get; set;}
        public String historyVolume {get; set;}
        public String historyPricingBasis {get; set;}
        public String historyPricingBasisDesc {get; set;}
        public String historyDeliveryPoint {get; set;}
        public String historyDifferential {get; set;}
        public String historyGP {get; set;}
        public String tenderLinkId {get; set;}
        public String tenderlink {get; set;}
        public String startAndEndDate {get; set;}
        public Decimal currentRound {get; set;}

       /**
        * @description This method is used for PricingRow in Tender Location Line Item
        * @param lineItem of AITM_Tender_Location_Line_Item__c
        * @return No Return type
        */
        public PricingRow(AITM_Tender_Location_Line_Item__c lineItem) {
            String tenderurl = URL.getSalesforceBaseUrl().toExternalForm();
            this.tenderName = (lineItem.AITM_Tender__c != null ? lineItem.AITM_Tender__r.AITM_Tender_Sector__c + ' -' + lineItem.AITM_Tender__r.Name : '');
            this.iataIcao = (lineItem.AITM_Location__c != null ? lineItem.AITM_Location__r.AITM_IATA_ICAO__c : '');
            this.country = (lineItem.AITM_Location__c != null ? lineItem.AITM_Location__r.AITM_Country__c : '');
            this.airportName = (lineItem.AITM_Location__c != null ? lineItem.AITM_Location__r.Name : '');
            this.deliveryPoint = (lineItem.AITM_Location_Delivery_Point__c != null ? (lineItem.AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c != null ? lineItem.AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c : ''): '');
            this.pricingResponsibility = (lineItem.Owner.Name == null ? '' : lineItem.Owner.Name);
            this.customerAccount = (lineItem.AITM_Account__c != null ? lineItem.AITM_Account__r.Name : '');
            this.grn = (lineItem.AITM_Account__c != null ? lineItem.AITM_Account__r.AITM_GRN__c : '');
            this.requestedVolume = lineItem.AITM_Requested_Volume_USG__c == null ? 0 : lineItem.AITM_Requested_Volume_USG__c;
            this.volumeOffered = lineItem.AITM_Offered_Volume__c == null ? 0 : lineItem.AITM_Offered_Volume__c;
            this.startDate = this.format(lineItem.AITM_Start_Date__c);
            this.endDate = this.format(lineItem.AITM_End_Date__c);
            this.accountManagerNotesInstructions = (lineItem.AITM_Account_Manager_Notes_Instructions__c != null ? lineItem.AITM_Account_Manager_Notes_Instructions__c : '');
            this.historyLastTenderResult = (lineItem.AITM_History_Line_Item__c != null && lineItem.AITM_History_Line_Item__r.AITM_Tender_Result__c != null ? lineItem.AITM_History_Line_Item__r.AITM_Tender_Result__c : '');
            this.historyVolume = (lineItem.AITM_History_Line_Item__c != null && lineItem.AITM_History_Line_Item__r.AITM_Volume__c != null ? String.valueOf(lineItem.AITM_History_Line_Item__r.AITM_Volume__c.format()) : '');
            this.historyPricingBasis = (lineItem.AITM_History_Line_Item__c != null && lineItem.AITM_History_Line_Item__r.AITM_Pricing_Basis__c != null ? lineItem.AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name : '');
            this.historyPricingBasisDesc = (lineItem.AITM_History_Line_Item__c != null ? lineItem.AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c + '' : '');
            this.historyDeliveryPoint = (lineItem.AITM_History_Line_Item__c != null && lineItem.AITM_History_Line_Item__r.AITM_Location_Delivery_Point__c != null && lineItem.AITM_History_Line_Item__r.AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c != null ? lineItem.AITM_History_Line_Item__r.AITM_Location_Delivery_Point__r.AITM_BPInter_Location_DeliveryPoint_Cod__c : '');
            this.historyDifferential = (lineItem.AITM_History_Line_Item__c != null && lineItem.AITM_History_Line_Item__r.AITM_Offered_Differential__c != null ? String.valueOf(lineItem.AITM_History_Line_Item__r.AITM_Offered_Differential__c) + ' ' + lineItem.AITM_History_Line_Item__r.AITM_Currency__c + '/' + lineItem.AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c : '');
            this.historyGP = (lineItem.AITM_History_Line_Item__c != null && lineItem.AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c != null ? lineItem.AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c : '');
            this.tenderLinkId = lineItem.AITM_History_Line_Item__c;
            this.tenderLink = (lineItem.AITM_History_Line_Item__c == null ? '' : tenderurl + '/' + lineItem.AITM_History_Line_Item__r.Id);
            this.startAndEndDate = this.format(lineItem.AITM_Start_Date__c) + ' - ' + this.format(lineItem.AITM_End_Date__c);
            this.currentRound = lineItem.AITM_Current_Round__c;
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