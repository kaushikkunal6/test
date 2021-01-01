/***********************************************************************************************
 * @author           Ravi
 * @date             29/Apr/2019
 * @group            AirBP
 * @description      Populating Line Items data with related Locations and Customers and attach into excel file format
 
 * history
 * 29/Apr/2019       Ravi          Created
 *************************************************************************************/
public with sharing class AITM_FeedbackGenerateXLS {
    public XLSContent xls {get; set;}

   /**
    * @description This method is used as constructor for main class
    * @param No Parameters
    * @return No Retrun type
    */
    public AITM_FeedbackGenerateXLS() {
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
        public final String headerCurrentRound1 {get; set;}
        public final String headerResultContent {get; set;}
        public String data {get; set;}
        public final String footer {get; set;}
        public String tenderName {get; set;}
        public String headerStartAndEndDate {get; set;}
        public Decimal headerCurrentRound {get; set;}
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
            this.header = '<?xml version="1.0"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40"><Styles><Style ss:ID="date_dd_mmm_yyyy"><NumberFormat ss:Format="dd.mmm.yyyy;@"/><Alignment ss:Vertical="Top" ss:WrapText="1"/></Style><Style ss:ID="s22"><Alignment ss:Vertical="Top" ss:WrapText="1"/></Style><Style ss:ID="s28"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#ff0000" /></Style><Style ss:ID="s27"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#0000FF" /></Style><Style ss:ID="s26"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#008000" /></Style><Style ss:ID="s25"><Font ss:Bold="1" ss:Size="22"/></Style><Style ss:ID="s24"><Font ss:Bold="1" ss:Size="20"/></Style><Style ss:ID="s29"><Alignment ss:Vertical="Bottom" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:Size="10"/><Interior ss:Color="#008000" ss:Pattern="Solid"/></Style><Style ss:ID="s23"><Alignment ss:Vertical="Bottom" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:Size="10"/><Interior ss:Color="#86D126" ss:Pattern="Solid"/></Style><Style ss:ID="date_dd_mm_yyyy"><NumberFormat ss:Format="dd.mm.yyyy;@"/></Style></Styles><Worksheet ss:Name="Sheet1"><Table ss:DefaultColumnWidth="65"><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="95"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="85"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="350"/><Column ss:AutoFitWidth="0" ss:Width="350"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="250"/><Column ss:AutoFitWidth="0" ss:Width="180"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/>';
            this.data = '';
            this.tenderName = '';
            this.headerStartAndEndDate = '';
            this.headerCurrentRound = 0;
            
            if(sheetValues.size() > 0) {
                this.tenderName = sheetValues[0].tenderName;
                this.headerStartAndEndDate = sheetValues[0].startAndEndDate;
                this.headerCurrentRound = sheetValues[0].currentRound;
                this.headerContent1 = getHeaderContent1();
                this.headerContent = getHeaderContent();
                this.headerContentEmptyRow = getHeaderContentEmptyRow();
                this.headerContentEmptyRow1 = getHeaderContentEmptyRow1();
                this.headerContentEmptyRow2 = getHeaderContentEmptyRow2();
                this.headerCurrentRound1 = getHeaderCurrentRound1();
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
            this.header = '<?xml version="1.0"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40"><Styles><Style ss:ID="date_dd_mmm_yyyy"><NumberFormat ss:Format="dd.mmm.yyyy;@"/><Alignment ss:Vertical="Top" ss:WrapText="1"/></Style><Style ss:ID="s22"><Alignment ss:Vertical="Top" ss:WrapText="1"/></Style><Style ss:ID="s28"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#ff0000" /></Style><Style ss:ID="s27"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#0000FF" /></Style><Style ss:ID="s26"><Alignment ss:Vertical="Top" ss:WrapText="1"/><Font ss:Color="#008000" /></Style><Style ss:ID="s25"><Font ss:Bold="1" ss:Size="22"/></Style><Style ss:ID="s24"><Font ss:Bold="1" ss:Size="20"/></Style><Style ss:ID="s29"><Alignment ss:Vertical="Bottom" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:Size="10"/><Interior ss:Color="#008000" ss:Pattern="Solid"/></Style><Style ss:ID="s23"><Alignment ss:Vertical="Bottom" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:Size="10"/><Interior ss:Color="#86D126" ss:Pattern="Solid"/></Style><Style ss:ID="date_dd_mm_yyyy"><NumberFormat ss:Format="dd.mm.yyyy;@"/></Style></Styles><Worksheet ss:Name="Sheet1"><Table ss:DefaultColumnWidth="65"><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="95"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="85"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="65"/><Column ss:AutoFitWidth="0" ss:Width="350"/><Column ss:AutoFitWidth="0" ss:Width="350"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="250"/><Column ss:AutoFitWidth="0" ss:Width="180"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="140"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/><Column ss:AutoFitWidth="0" ss:Width="124"/>';
            this.data = '';
            this.tenderName = '';
            this.headerStartAndEndDate = '';
            this.headerCurrentRound = 0;
            
            if(sheetValues.size() > 0) {
                this.tenderName = sheetValues[0].tenderName;
                this.headerStartAndEndDate = sheetValues[0].startAndEndDate;
                this.headerCurrentRound = sheetValues[0].currentRound;
                this.headerContent1 = getHeaderContent1();
                this.headerContent = getHeaderContent();
                this.headerContentEmptyRow = getHeaderContentEmptyRow();
                this.headerContentEmptyRow1 = getHeaderContentEmptyRow1();
                this.headerContentEmptyRow2 = getHeaderContentEmptyRow2();
                this.headerCurrentRound1 = getHeaderCurrentRound1();
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
            result += wrapXLSColumn(row.pricingResponsibility, 'String');
            result += wrapXLSColumn(row.customerAccount, 'String');
            result += wrapXLSColumn(row.grn, 'String');
            result += wrapXLSColumn(String.valueOf(row.requestedVolume), 'Number');
            result += wrapXLSColumn(String.valueOf(row.volumeOffered), 'Number');
            result += wrapXLSColumn(row.pricingBasis, 'String');
            result += wrapXLSColumn(row.differentialPrice, 'String');
            result += wrapXLSColumn(String.valueOf(row.rebate), 'String');
            result += wrapXLSColumn(String.valueOf(row.position), 'String');
            result += wrapXLSColumn(row.addFeedbackComments, 'String');
            result += wrapXLSColumn(row.accountManagerNotesInstructions, 'String');
            result += wrapXLSColumn(row.locationManagerLevelOfInterest, 'String');
            result += wrapXLSColumn(row.lMContextStrategy, 'String');
            result += wrapXLSColumn(row.qualityOfFeedback, 'String');
            result += wrapXLSColumn(row.lastLookToIncumbent, 'String');
            result += wrapXLSColumn(String.valueOf(row.numberOfRounds), 'String');
            result += wrapXLSColumn(String.valueOf(row.numberOfBidders), 'String');
            result += wrapXLSColumn(String.valueOf(row.offeredDifferential), 'String');
            result += wrapXLSColumn(row.offeredDifferentialCurrency, 'String');
            result += wrapXLSColumn(row.offeredDifferentialUOM, 'String');
            result += wrapXLSColumn(String.valueOf(row.leadingBid), 'String');
            result += wrapXLSColumn(row.leadingBidCurrency, 'String');
            result += wrapXLSColumn(row.leadingBidUOM, 'String');
            result += wrapXLSColumn(String.valueOf(row.distanceFromLeadingBid), 'String');
            result += wrapXLSColumn(row.competitorInfo, 'String');
            result += wrapXLSColumn(row.historyLastTenderResult, 'String');
            result += wrapXLSColumn(row.historyPricingBasis, 'String');
            result += wrapXLSColumn(row.historyDifferential, 'String');
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
            result += wrapXLSHeaderBoldColumn('Feedback on tender location(s)' , 'String');
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
            result += wrapXLSHeaderValueBoldColumn(this.tenderName + ' - ' +  this.headerStartAndEndDate + ' - Round ' + this.headerCurrentRound, 'String');
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
        * @description This method is used to get Header Row
        * @param null
        * @return String header content
        */
        private String getHeaderCurrentRound1() {
            String result = '';
            result += wrapXLSColumn('Current Round' , 'String');
            result += wrapXLSColumn(string.valueOf(headerCurrentRound), 'Number');
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
            result += wrapXLSHeaderResultsColumn('Location List', 'String');
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
            result += wrapXLSColumn('Number Of Locations', 'String');
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
            result += wrapXLSHeaderColumn('PRICING RESPONSIBILITY', 'String');
            result += wrapXLSHeaderColumn('CUSTOMER NAME', 'String');
            result += wrapXLSHeaderColumn('GRN', 'String');
            result += wrapXLSHeaderColumn('VOLUME (TENDERED)', 'String');
            result += wrapXLSHeaderColumn('VOLUME (OFFERED)', 'String');
            result += wrapXLSHeaderColumn('PRICING BASIS', 'String');
            result += wrapXLSHeaderColumn('DIFF/PRICE', 'String');
            result += wrapXLSHeaderColumn('REBATE', 'String');
            result += wrapXLSHeaderColumn('POSITION', 'String');
            result += wrapXLSHeaderColumn('FEEDBACK (BUYERS COMMENTS)', 'String');
            result += wrapXLSHeaderColumn('ACCOUNT MANAGER NOTES/INSTRUCTIONS', 'String');
            result += wrapXLSHeaderColumn('LOCATION MANAGER LEVEL OF INTEREST', 'String');
            result += wrapXLSHeaderColumn('LM CONTEXT, STRAGETIC RATIONALE & INFO', 'String');
            result += wrapXLSHeaderColumn('QUALITY OF FEEDBACK', 'String');
            result += wrapXLSHeaderColumn('LAST LOOK TO INCUMBENT', 'String');
            result += wrapXLSHeaderColumn('NUMBER OF ROUNDS', 'String');
            result += wrapXLSHeaderColumn('NUMBER OF BIDDERS', 'String');
            result += wrapXLSHeaderColumn('OFFERED DIFFERENTIAL', 'String');
            result += wrapXLSHeaderColumn('OFFERED DIFFERENTIAL CURRENCY', 'String');
            result += wrapXLSHeaderColumn('OFFERED DIFFERENTIAL UOM', 'String');
            result += wrapXLSHeaderColumn('ESTIMATED LEADING BID', 'String');
            result += wrapXLSHeaderColumn('LEADING BID CURRENCY', 'String');
            result += wrapXLSHeaderColumn('LEADING BID UOM', 'String');
            result += wrapXLSHeaderColumn('DISTANCE FROM LEADING BID', 'String');
            result += wrapXLSHeaderColumn('BP ESTIMATED COMPETITOR INFO', 'String');
            result += wrapXLSHeaderColumn('HISTORY - LAST TENDER RESULT', 'String');
            result += wrapXLSHeaderColumn('HISTORY - PRICING BASIS', 'String');
            result += wrapXLSHeaderColumn('HISTORY - DIFFERENTIAL', 'String');
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
            List<AITM_Tender_Location_Line_Item__c> lineItems = new AITM_LocationsDao().getTenderLocationLineItemsByTenderForFeedbackXLS(this.tenderId, this.locationType);
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
        public String pricingResponsibility {get; set;}
        public String airportName {get; set;}
        public String customerAccount {get; set;}
        public String grn {get; set;}
        public Decimal requestedVolume {get; set;}
        public Decimal volumeOffered {get; set;}
        public String pricingBasis {get; set;}
        public String differentialPrice {get; set;}
        public String rebate {get; set;}
        public Decimal position {get; set;}
        public String addFeedbackComments {get; set;}
        public String accountManagerNotesInstructions {get; set;}
        public String locationManagerLevelOfInterest {get; set;}
        public String lMContextStrategy {get; set;}
        public String qualityOfFeedback {get; set;}
        public String lastLookToIncumbent {get; set;}
        public Decimal numberOfRounds {get; set;}
        public Decimal numberOfBidders {get; set;}
        public Decimal offeredDifferential {get; set;}
        public String offeredDifferentialCurrency {get; set;}
        public String offeredDifferentialUOM {get; set;}
        public Decimal leadingBid {get; set;}
        public String leadingBidCurrency {get; set;}
        public String leadingBidUOM {get; set;}
        public Decimal distanceFromLeadingBid {get; set;}
        public String competitorInfo {get; set;}
        public String historyLastTenderResult {get; set;}
        public String historyPricingBasis {get; set;}
        public String historyDifferential {get; set;}
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
            this.pricingResponsibility = (lineItem.Owner.Name == null ? '' : lineItem.Owner.Name);
            this.airportName = (lineItem.AITM_Location__c != null ? lineItem.AITM_Location__r.Name : '');
            this.customerAccount = (lineItem.AITM_Account__c != null ? lineItem.AITM_Account__r.Name : '');
            this.grn = (lineItem.AITM_Account__c != null ? lineItem.AITM_Account__r.AITM_GRN__c : '');
            this.requestedVolume = lineItem.AITM_Requested_Volume_USG__c == null ? 0 : lineItem.AITM_Requested_Volume_USG__c;
            this.volumeOffered = lineItem.AITM_Offered_Volume__c == null ? 0 : lineItem.AITM_Offered_Volume__c;
            this.pricingBasis = lineItem.AITM_Pricing_Basis__r.Name;
            this.differentialPrice = (lineItem.AITM_Pricing_Basis__r.AITM_Type__c == 'C' ? string.valueOf(lineItem.AITM_Current_Value__c):(lineItem.AITM_Offered_Differential__c == null ? '' : string.valueOf(lineItem.AITM_Offered_Differential__c.format()))) + ' ' + lineItem.AITM_Currency__c + '/' + lineItem.AITM_Unit_Of_Measure__c;
            this.rebate = (lineItem.AITM_Rebate__c == null ? '0' : lineItem.AITM_Rebate__c + ' ' + lineItem.AITM_Currency_Rebate1__c + '/' + lineItem.AITM_Unit_Of_Measure_Rebate1__c);
            this.position = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Position__c == null ? 0 : lineItem.AITM_Tender_Location__r.AITM_Position__c);
            this.addFeedbackComments = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Comments__c != null ? lineItem.AITM_Tender_Location__r.AITM_Comments__c : '');
            this.accountManagerNotesInstructions = (lineItem.AITM_Account_Manager_Notes_Instructions__c != null ? lineItem.AITM_Account_Manager_Notes_Instructions__c : '');
            this.locationManagerLevelOfInterest = (lineItem.AITM_Location_Manager_Level_of_Interest__c != null ? lineItem.AITM_Location_Manager_Level_of_Interest__c : '');
            this.lMContextStrategy = (lineItem.AITM_LM_Context_Strategic_Rationale_Info__c != null ? lineItem.AITM_LM_Context_Strategic_Rationale_Info__c : '' );
            this.qualityOfFeedback = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Quality_Of_Feedback__c != null ? lineItem.AITM_Tender_Location__r.AITM_Quality_Of_Feedback__c : '');
            this.lastLookToIncumbent = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Last_Look_To_Incumbent__c != null ? lineItem.AITM_Tender_Location__r.AITM_Last_Look_To_Incumbent__c : '');
            this.numberOfRounds = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Number_Of_Rounds__c == null ? 0 : lineItem.AITM_Tender_Location__r.AITM_Number_Of_Rounds__c);
            this.numberOfBidders = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Number_Of_Bidders__c == null ? 0 : lineItem.AITM_Tender_Location__r.AITM_Number_Of_Bidders__c);
            this.offeredDifferential = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Offered_Differential__c == null ? 0 : lineItem.AITM_Tender_Location__r.AITM_Offered_Differential__c);
            this.offeredDifferentialCurrency = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Offered_Differential_Currency__c != null ? lineItem.AITM_Tender_Location__r.AITM_Offered_Differential_Currency__c : '');
            this.offeredDifferentialUOM = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Offered_Differential_UoM__c != null ? lineItem.AITM_Tender_Location__r.AITM_Offered_Differential_UoM__c : '');
            this.leadingBid = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Leading_Bid__c == null ? 0 : lineItem.AITM_Tender_Location__r.AITM_Leading_Bid__c);
            this.leadingBidCurrency = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Leading_Bid_Currency__c != null ? lineItem.AITM_Tender_Location__r.AITM_Leading_Bid_Currency__c : '');
            this.leadingBidUOM = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Leading_Bid_UoM__c != null ? lineItem.AITM_Tender_Location__r.AITM_Leading_Bid_UoM__c : '');
            this.distanceFromLeadingBid = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Distance_from_Leading_Bid1__c == null ? 0 : lineItem.AITM_Tender_Location__r.AITM_Distance_from_Leading_Bid1__c);
            this.competitorInfo = (lineItem.AITM_Tender_Location__c != null && lineItem.AITM_Tender_Location__r.AITM_Competitor_info__c != null ? lineItem.AITM_Tender_Location__r.AITM_Competitor_info__c : '');
            this.historyLastTenderResult = (lineItem.AITM_History_Line_Item__c != null && lineItem.AITM_History_Line_Item__r.AITM_Tender_Result__c != null ? lineItem.AITM_History_Line_Item__r.AITM_Tender_Result__c : '');
            this.historyPricingBasis = (lineItem.AITM_History_Line_Item__c != null && lineItem.AITM_History_Line_Item__r.AITM_Pricing_Basis__c != null ? lineItem.AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name : '');
            this.historyDifferential = (lineItem.AITM_History_Line_Item__c != null && lineItem.AITM_History_Line_Item__r.AITM_Offered_Differential__c != null ? String.valueOf(lineItem.AITM_History_Line_Item__r.AITM_Offered_Differential__c) + ' ' + lineItem.AITM_History_Line_Item__r.AITM_Currency__c + '/' + lineItem.AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c : '');
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