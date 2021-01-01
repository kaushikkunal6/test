/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_TenderLocationPricingService

 * history
 * 01/December/2017  George       Created
 * 30/April/2018     srnandan     added comments and sonar cube fixes 
 *************************************************************************************/
@isTest  
private class AITM_TenderLocationPricingServiceTests {
    
    /**
     * @description tests pricing information for success call
     * @param null
     * @return void
     */	
    @isTest  
	private static void testTargetPriceWillFillTargetPriceAndResultFieldsOnTenderLocationLineItem() {
		AITM_TenderLocationPricingServiceTestSetup setup = new AITM_TenderLocationPricingServiceTestSetup();
		setup.setPricingService('SUCCESS');

		Test.startTest();
		    AITM_TenderLocationPricingService.getInstance().retrievePricingInformation(setup.lineItemsIds, 'Target Price');
            List<AITM_Tender_Location_Line_Item__c> lineItems = [SELECT AITM_Pricing_Service_Call_Status__c, AITM_Target_Price__c FROM AITM_Tender_Location_Line_Item__c WHERE ID IN :setup.lineItemsIds];
        Test.stopTest();

        for (AITM_Tender_Location_Line_Item__c result : lineItems) {
		    System.assertEquals(22.7, result.AITM_Target_Price__c,'The target price is 22.7');
            System.assertEquals('OK', result.AITM_Pricing_Service_Call_Status__c, 'The pricing call status is OK');
        }
	}

    /**
     * @description tests pricing information for failure call
     * @param null
     * @return void
     */
    @isTest  
	private static void testTargetPriceWontFillTargetPriceInCaseOfAnError() {
		AITM_TenderLocationPricingServiceTestSetup setup = new AITM_TenderLocationPricingServiceTestSetup();
		setup.setPricingService('ERROR');

		Test.startTest();
		    AITM_TenderLocationPricingService.getInstance().retrievePricingInformation(setup.lineItemsIds, 'Target Price');
            List<AITM_Tender_Location_Line_Item__c> lineItems = [SELECT AITM_Pricing_Service_Call_Status__c, AITM_Target_Price__c, AITM_Last_Call_To_Pricing_System__c FROM AITM_Tender_Location_Line_Item__c WHERE ID IN :setup.lineItemsIds];
        Test.stopTest();

        for (AITM_Tender_Location_Line_Item__c result : lineItems) {
		    System.assertEquals(null, result.AITM_Target_Price__c, 'The target price is null');
            System.assert(result.AITM_Last_Call_To_Pricing_System__c >= System.now().addHours(-1),'The pricing service last call dateandtime');
            System.assertEquals('Referred element Target Price failed to evaluate.', result.AITM_Pricing_Service_Call_Status__c, 'Referred element Target Price failed to evaluate.');
        }
	}

    /**
     * @description tests pricing information for targetprice and call status
     * @param null
     * @return void
     */
    /* @isTest  
    private static void testPricingInformationWillFillSomeFieldsAndResultFieldsOnTenderLocationLineItem() {
		AITM_TenderLocationPricingServiceTestSetup setup = new AITM_TenderLocationPricingServiceTestSetup();
		setup.setPricingService('SUCCESS');

        Set<Id> firstTwoLineItems = new Set<Id>{setup.lineItems[0].Id, setup.lineItems[1].Id};

		Test.startTest();
            System.enqueueJob(new AITM_TenderLocationPricingService(firstTwoLineItems, 'Pricing Information'));
        Test.stopTest();

        List<AITM_Tender_Location_Line_Item__c> lineItems = [SELECT AITM_Pricing_Service_Call_Status__c, AITM_Target_Price__c, AITM_JV_Profit_Dividend__c, AITM_Mark_Up_Location_Strategy__c FROM AITM_Tender_Location_Line_Item__c WHERE ID IN :firstTwoLineItems];
        for (AITM_Tender_Location_Line_Item__c result : lineItems) {
		    System.assertEquals(22.7, result.AITM_Target_Price__c,'The target price is equal to 22.7');
            System.assertEquals(0.25, result.AITM_Mark_Up_Location_Strategy__c,'The location strategy value is equal to 0.25');
            System.assertEquals('OK', result.AITM_Pricing_Service_Call_Status__c,'The pricing call status is equal to OK');
        }
	} */
	
    /**
     * @description wrapper class for pricing service setup test data
     */
	private class AITM_TenderLocationPricingServiceTestSetup extends AITM_TestSetup {
        public final Integer ITEMS_SIZE = 10;
        public List<Account> accounts;
        public List<AITM_Tender_Account__c> tenderAccounts;
		public List<AITM_Location__c> locations;
		public List<AITM_Tender_Location__c> tenderLocations;
		public AITM_Tender__c tender;
		public List<AITM_Tender_Location_Line_Item__c> lineItems;

        public Set<Id> lineItemsIds;
        
        /**
         * @description default constructor
         * @param null
         */
        public AITM_TenderLocationPricingServiceTestSetup() {
            accounts = createAccounts(ITEMS_SIZE);
			insert accounts;

			locations = createLocations(ITEMS_SIZE);
			for(AITM_Location__c location : locations){
				location.AITM_Country__c = 'Spain';
			}
			insert locations;

			tender = createTender();
			tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
			tender.AITM_Density__c = '331';
			tender.AITM_Stage__c = 'Awaiting Price';
            tender.AITM_Unit_Of_Measure__c = 'LT'; 
			insert tender;

			tenderAccounts = createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
            insert tenderAccounts;

            AITM_Pricing_Basis__c pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test');
            insert pricingBasis;

            lineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
            for (AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
               lineItem.AITM_Pricing_Basis__c = pricingBasis.Id;
               lineItem.AITM_Delivery_Point__c = '1';
               lineItem.AITM_Currency__c = 'USD';
               lineItem.AITM_Unit_Of_Measure__c = 'LT'; 
               lineItem.AITM_Offered_Differential__c = 1.0;
            }
            insert lineItems;

            lineItemsIds = new Map<Id, SObject>(lineItems).keySet();
            insert this.createPricingServiceSettings();
        }

        /**
         * @description sets pricing service 
         * @param serviceName of type String
         * @return void
         */
        public void setPricingService(String serviceName) {
            if (serviceName == 'SUCCESS') {
                Test.setMock(HttpCalloutMock.class, new PricingServiceSuccessResponseMock());
            } else if (serviceName == 'ERROR') {
                Test.setMock(HttpCalloutMock.class, new PricingServiceErrorResponseMock());
            }
        }
	}

    private class PricingServiceSuccessResponseMock implements HttpCalloutMock {
        /**
         * @description mock response for httprequest success
         * @param request of type HTTPRequest
         * @return void
         */
        public HTTPResponse respond(HTTPRequest request) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(200);
            response.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header /><soapenv:Body><ns:getPriceResponse xmlns:ns="http://webservice.pm.pricing.prosrm.com/xsd"><ns:return><Response uniqueId="6667b048-4f13-d505-cc77"><Defaults currencyCode="USD" uomCode="USG" perQuantity="1" orderVolume="1.0" date="20171113" getElements="true" getScales="false"></Defaults><EvaluationResult evaluationMethod="Target Price" value="22.7000"><Dimension name="LOCATION" value="EGLL"></Dimension><Dimension name="CUSTOMER" value="5111300"></Dimension><Element value="0.0" name="On Airfield Costs Variable"></Element><Element value="3.4E-6" name="TV/LV Ratio"></Element><Element value="0.25" name="Location Strategy Markup"></Element><Element value="0.0" name="Premium"></Element><Element value="12.0" name="MonthEnd"></Element><Element value="22.7" name="Target Price"></Element><Element value="0.0" name="Customer Specific Into-Plane Costs"></Element><Element value="3.5" name="Credit Days Adjustment"></Element><Element value="10.0" name="Stock Days"></Element><Element value="0.03" name="WC Impact for Rate C"></Element><Element value="1.74" name="DCD"></Element><Element value="1.5724118992200002" name="ForwardCurveStart"></Element><Element value="1.0" name="USD/USG"></Element><Element value="0.0" name="Average Loss"></Element><Element value="1.0E7" name="Location Volume"></Element><Element value="2017.0" name="YearStart"></Element><Element value="1.7" name="Buying Power Markup"></Element><Element value="0.25" name="JV Profit Dividend"><Element value="20171113" name="CopyPriceStartDate"></Element><Element value="5111300" name="Customer_Val"></Element><Element value="Low" name="Buying Power Value"></Element><Element value="PP" name="Credit Days Str"></Element><EvaluationMethodElement name="Customer Segment Value" value="Core"></EvaluationMethodElement><EvaluationMethodElement name="Tender Volume" value="34"></EvaluationMethodElement><EvaluationMethodElement name="Invoice Frequency" value="Weekly"></EvaluationMethodElement><EvaluationMethodElement name="Sales Pricing Basis" value="CW"></EvaluationMethodElement><EvaluationMethodElement name="Credit Days" value="23"></EvaluationMethodElement><EvaluationMethodElement name="Offer Differential" value="2.00"></EvaluationMethodElement><EvaluationMethodElement name="Rebate" value="2.00"></EvaluationMethodElement><EvaluationMethodElement name="Volume Differential" value="34"></EvaluationMethodElement></EvaluationResult></Response></ns:return></ns:getPriceResponse></soapenv:Body></soapenv:Envelope>');
            return response;
        }
    }
    
    private class PricingServiceErrorResponseMock implements HttpCalloutMock {
        /**
         * @description mock response for httprequest for error
         * @param request of type String
         * @return void
         */
        public HTTPResponse respond(HTTPRequest request) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(200);
            response.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header /><soapenv:Body><ns:getPriceResponse xmlns:ns="http://webservice.pm.pricing.prosrm.com/xsd"><ns:return><Response uniqueId="f889fc20-be0a-ac8b-72c2"><Defaults currencyCode="USD" uomCode="CM" perQuantity="1" orderVolume="1.0" date="20171117" getElements="true" getScales="false"></Defaults><EvaluationError evaluationMethod="Target Price" message="Referred element Target Price failed to evaluate."><Dimension name="LOCATION" value="SAP"></Dimension><Dimension name="CUSTOMER" value="5111300"></Dimension><Dimension name="INSTRUMENT" value="GO Swaps"></Dimension><Element value="0.0" name="On Airfield Costs Variable"></Element><Element value="500.0" name="TV/LV Ratio"></Element><Element value="0.0" name="Cost of Product"></Element><Element value="0.0" name="Premium"></Element><Element value="11.0" name="MonthEnd"></Element><Element value="31.0" name="Additional Margin from Line Items"></Element><Element value="0.0" name="Customer Specific Into-Plane Costs"></Element><Element value="3.5" name="Credit Days Adjustment"></Element><Element value="0.0" name="Stock Days"></Element><Element value="0.03" name="WC Impact for Rate C"></Element><Element value="0.0" name="DCD"></Element><Element value="419.70747718741177" name="ForwardCurveStart"></Element><Element value="264.172176857989" name="USD/USG"></Element><Element value="0.0" name="Average Loss"></Element><Element value="2.0" name="Location Volume"></Element><Element value="2017.0" name="YearStart"></Element><Element value="0.9" name="Buying Power Markup"></Element><Element value="0.0" name="On Airfield Costs Fixed"></Element><Element value="0.0" name="Platts"></Element><Element value="53.8660669401289" name="Adjusted Differential"></Element><Element value="0.0" name="Supplier Credit Days"></Element><Element value="1.75" name="Credit rating cost of risk"></Element><Element value="-9.937606563093595" name="Increase in Platts over contract period"></Element><Element value="409.7698706243182" name="ForwardCurveEnd"></Element><Element value="0.0" name="Other Income Fixed"></Element><Element value="0.0" name="Loc Neutral WC Payment Days"></Element><Element value="0.0" name="Pre Airfield Costs Fixed"></Element><Element value="0.0" name="Temperature Adjustment Location"></Element><Element value="1000.0" name="Tender Volume"></Element><Element value="0.2" name="Customer Segment Markup"></Element><Element value="-1.452" name="Credit Term Adjustment"></Element><Element value="2019.0" name="YearEnd"></Element><Element value="-1.0" name="Adjsutment due to basis diff"></Element><Element value="0.0" name="CSO Costs"></Element><Element value="0.0" name="Pre Airfield Costs Variable"></Element><Element value="77.0" name="Credit Days"></Element><Element value="1000.0" name="Volume Differential"></Element><Element value="0.02" name="WC Impact for Rate B"></Element><Element value="0.0" name="JV Profit Dividend"></Element><Element value="0.012" name="WC Impact for Rate A"></Element><Element value="0.0" name="CopyOfOn Airfield Costs Variable"></Element><Element value="-1.0" name="CopyOfAdjsutment due to basis diff"></Element><Element value="0.0" name="Other Income Variable"></Element><Element value="-5.5" name="Overall Credit Days"></Element><Element value="2.017111E7" name="PriceStartDate"></Element><Element value="33.0" name="Rebate"></Element><Element value="41.0" name="Credit Rating of Customer Num"></Element><Element value="0.41406694012889983" name="Market Structure Cost"></Element><Element value="0.0" name="Cust and Loc Revenue"></Element><Element value="2.0191126E7" name="PriceEndDate"></Element><Element value="11.0" name="MonthStart"></Element><Element value="-1.0" name="Density Adjustment"></Element><Element value="0.0" name="Rebate Duration"></Element><Element value="22.0" name="Offer Differential"></Element><Element value="24.0" name="Contract Length"></Element><Element value="0.0" name="Return on Working Capital"></Element><Element value="5.812" name="Unit GP"></Element><Element value="-87441.0" name="Working Capital in USD"></Element><Element value="-331.0" name="Working Capital"></Element><Element value="5812.0" name="Gross Profit in USD"></Element><Element value="22.0" name="Gross Profit"></Element><Element value="Weekly" name="Invoice Frequency"></Element><Element value="GO Swaps" name="Instrument_Val"></Element><Element value="M-1" name="Supply Pricing Basis"></Element><Element value="Yes" name="Density linked to offer"></Element><Element value="6" name="Credit Rating of Customer"></Element><Element value="20171110" name="StartPriceStartDate"></Element><Element value="Core" name="Customer Segment Value"></Element><Element value="CW" name="Sales Pricing Basis"></Element><Element value="20171117" name="CopyPriceStartDate"></Element><Element value="5111300" name="Customer_Val"></Element><Element value="High" name="Buying Power Value"></Element><Element value="PP" name="Credit Days Str"></Element><ElementError name="CopyOfPlatts" message="DataSet/Cube :PLATTS_DCD_DS does not inculde any of the pricing dimensions for price item PLATTS_DCD_DS"></ElementError><ElementError name="Location Strategy Markup" message="The symbol &amp;quot;Location Strategy Value&amp;quot; at position (1, 82) with type &amp;quot;String&amp;quot; has no value."></ElementError><ElementError name="Floor Price" message="No lookup value found for lookup name: Location Data, and date: 20171110 00:00:00"></ElementError><ElementError name="CopyOfAdditional Margin from Line Items" message="The Lookup Column requested Additional Line Margin is not part of the Lookup specified: Customer Data."></ElementError><ElementError name="PPI" message="Referred element Target Price failed to evaluate."></ElementError><ElementError name="Target Price" message="Referred element Location Strategy Markup failed to evaluate."></ElementError><ElementError name="Location Strategy Value" message="No lookup value found for lookup name: Location Data Test, and date: 20171110 00:00:00"></ElementError><EvaluationMethodElement name="Tender Volume" value="1000"></EvaluationMethodElement><EvaluationMethodElement name="Invoice Frequency" value="Weekly"></EvaluationMethodElement><EvaluationMethodElement name="PriceStartDate" value="20171110"></EvaluationMethodElement><EvaluationMethodElement name="Rebate" value="33.00"></EvaluationMethodElement><EvaluationMethodElement name="Location Volume" value="2"></EvaluationMethodElement><EvaluationMethodElement name="Credit Rating of Customer Num" value="41"></EvaluationMethodElement><EvaluationMethodElement name="PriceEndDate" value="20191126"></EvaluationMethodElement><EvaluationMethodElement name="Customer Segment Value" value="Core"></EvaluationMethodElement><EvaluationMethodElement name="Additional Margin from Line Items" value="31.00"></EvaluationMethodElement><EvaluationMethodElement name="Customer Specific Into-Plane Costs" value="0.00"></EvaluationMethodElement><EvaluationMethodElement name="Sales Pricing Basis" value="CW"></EvaluationMethodElement><EvaluationMethodElement name="Credit Days" value="77"></EvaluationMethodElement><EvaluationMethodElement name="Offer Differential" value="22.00"></EvaluationMethodElement><EvaluationMethodElement name="Volume Differential" value="1000"></EvaluationMethodElement></EvaluationError></Response></ns:return></ns:getPriceResponse></soapenv:Body></soapenv:Envelope>');
            return response;
        }
    } 
}