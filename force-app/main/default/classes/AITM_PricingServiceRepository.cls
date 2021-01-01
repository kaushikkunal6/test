/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    To get pricing/targetprice information by making a SOAP callout to PROS API (external system).

 * history
 * 06/December/2017  George       Created 
 * 02/March/2018     srnandan     Modified - Changed customsettings to NamedCredentials (callout:ProsAPI)
 * 09/March/2018     srnandan     Modified - added with sharing attribute to class as per best practice and code comments
 * 12/March/2018     srnandan     Modified - corrected the indentation of comments
 * 15/March/2018     Ravi         Modified - Updated Credit Rating of Customer to Credit Rating formula field.
 * 17/May/2018       srnandan     Modified - AR-3169 - Changed the mapping field Creditdays
 * 17/May/2018       srnandan     Modified - AR-3168 - Changed the mapping field Rebate
 * 29/May/2018       srnandan     Modified - AR-3230 - Modified method getPricingInformationEvaluation 
 *                                replacing Density Adjustment to Density
 * 15/June/2018      srnandan     Modified - AR-3346 - Modified element tag "Credit Rating Of Customer Num" to "Credit Rating Of Customer"
 * 25/July/2018      saravana     Modified - AR -3879 - Modified the method getPricingInformationEvaluation. Added new element ''JV Profit Dividend' and renamed element 'Rebate' with 'Unit Rebate'  
 * 09/Aug/2018       saravana     Modified - AR -4013 - Modified the method getFormattedDate to change the format from "YYYYMMdd" to "yyyyMMdd" to take the week of the year and in fromResponse method replaced &gt with > in response body
 * 10/May/2019       saravan      Modified - AR-5004 - Modified not to send instrument in request when instrument is null
 * 30/July/2019      srnandan     Modified - AR-XXXX changed the field mapping aitm_product to aitm_product_default and aitm_density from tender to lineitem
 *************************************************************************/
public with sharing class AITM_PricingServiceRepository {

    /**
     * @description gets the instance of AITM_PricingServiceRepository
     * @param null
     * @return AITM_PricingServiceRepository class object
     */
    public static AITM_PricingServiceRepository getInstance() {
        if (instance == null) {
            instance = new AITM_PricingServiceRepository();
        }
        return instance;
    }
    public static String GENERATED_AUTH_TOKEN;
    private static AITM_PricingServiceRepository instance;
    private static Map<String, List<AITM_Pricing_Service_Mapping__mdt>> mappingCache;

    /**
     * @description default constructor
     */
    private AITM_PricingServiceRepository(){}

    /**
     * @description gets the instance of PricingService
     * @param null
     * @return PricingService class object
     */
    public PricingService getPricingService() {
        AITM_PricingServiceSettings__c settings = getSettingsForService();
        PricingService result = (PricingService) Type.forName(settings.AITM_Class__c).newInstance();
        result.initialize(settings);
        return result;
    }

    /**
     * @description gets the instance of PricingService
     * @param null
     * @return PricingService class object
     */
    public List<AITM_Pricing_Service_Mapping__mdt> getPricingServiceMappings(String serviceName, Boolean isTargetPrice) {
        if (mappingCache == null) {
            mappingCache = new Map<String, List<AITM_Pricing_Service_Mapping__mdt>>();
        }
        if (!mappingCache.containsKey(serviceName)) {
            if (isTargetPrice) {
                mappingCache.put(serviceName, [SELECT Id, AITM_Field_Name__c, AITM_Response_Field__c, AITM_Type__c FROM AITM_Pricing_Service_Mapping__mdt WHERE AITM_Service_Name__c = :serviceName AND AITM_Required_For_A_Target_Price_Call__c = true]);
            } else {
                mappingCache.put(serviceName, [SELECT Id, AITM_Field_Name__c, AITM_Response_Field__c, AITM_Type__c FROM AITM_Pricing_Service_Mapping__mdt WHERE AITM_Service_Name__c = :serviceName]);
            }
        }
        return mappingCache.get(serviceName);
    }

    /**
     * @description gets the instance of org defaults
     * @param null
     * @return AITM_PricingServiceSettings__c custom settings
     */
    private AITM_PricingServiceSettings__c getSettingsForService() {
        return AITM_PricingServiceSettings__c.getOrgDefaults();
    }

    /**
     * @description PricingService interface
     */
    public interface PricingService  {
        void initialize(SObject settings);
        SObject retrieveTargetPrice(SObject source);
        SObject retrievePricingInformation(SObject source);
    }

    /**
     * @description PROSService class implementing PricingService interface
     */
    public class PROSService implements PricingService {
        private AITM_PricingServiceSettings__c serviceSettings;
        private final PROSServiceXMLParser parser;

        /**
         * @description default constructor
         */
        public PROSService() {
            parser = new PROSServiceXMLParser();
        }

        /**
         * @description gets the instance of PricingService
         * @param settings of type SObject
         * @return void
         */
        public void initialize(SObject settings) {
            serviceSettings = (AITM_PricingServiceSettings__c) settings;
            parser.setAuthToken(this.getAuthToken());
        }

        /**
         * @description retrieves TargetPrice from PROS API call response
         * @param source of type SObject
         * @return SObject
         */
        public SObject retrieveTargetPrice(SObject source) {
            String requestBody = parser.getRequest(source, 'Target Price');            
            String responseBody = this.send(requestBody, 'callout:ProsAPI' + serviceSettings.AITM_Endpoint__c);   
            
            return parser.fromResponse(responseBody, 'Target Price');
        }

        /**
         * @description retrieves TargetPrice from PROS API call response
         * @param source of type SObject
         * @return SObject
         */
        public SObject retrievePricingInformation(SObject source) {
            String requestBody = parser.getRequest(source, 'Pricing Information');
            String responseBody = this.send(requestBody, 'callout:ProsAPI'+ serviceSettings.AITM_Endpoint__c); 
            return parser.fromResponse(responseBody, 'Pricing Information');
        }
        
        /**
         * @description sends http soap request and returns soap response body
         * @param requestBody of type string
         * @param endpoint of type string
         * @return string
         */
        private String send(String requestBody, String endpoint) {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();

            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setBody(requestBody);
            request.setTimeout(100000);
            request.setHeader('Content-Type', 'text/xml; charset=UTF-8');
            request.setHeader('SOAPAction', 'blank');

            response = http.send(request);
            return response.getBody();
        }

        /**
         * @description gets authorization token calling pros api system service end point
         * @param null
         * @return string
         */
        private String getAuthToken() {
            if (String.isBlank(AITM_PricingServiceRepository.GENERATED_AUTH_TOKEN)) {
                String requestBody = parser.getAuthRequest('{!HTMLENCODE($Credential.UserName)}', '{!HTMLENCODE($Credential.Password)}');
                if (!Test.isRunningTest()) {
                    String responseBody = this.send(requestBody, 'callout:ProsAPI'+ serviceSettings.AITM_Auth_Endpoint__c);
                    AITM_PricingServiceRepository.GENERATED_AUTH_TOKEN = parser.fromAuthResponse(responseBody);
                } else {
                    AITM_PricingServiceRepository.GENERATED_AUTH_TOKEN = '<authToken>TOKEN</authToken>';
                }
            }
            return AITM_PricingServiceRepository.GENERATED_AUTH_TOKEN;
        }
    }

    /**
     * @description class used for XML Parser for PROS API
     */
    public class PROSServiceXMLParser {
        private String authToken;
        private Id sourceRecordId;
        private final String SOAP_HEADER = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://webservice.pm.pricing.prosrm.com/xsd">'
                                           + '<soapenv:Header/>' + '<soapenv:Body>' + '<xsd:getPrice>' + '<xsd:xmlRequest>' + '<![CDATA[';
        private final String SOAP_FOOTER = ']]>' + '</xsd:xmlRequest>' + '</xsd:getPrice>' + '</soapenv:Body>' + '</soapenv:Envelope>';
        private final String AUTH_HEADER = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://webservice.system.prosrm.com/xsd">' + '<soapenv:Header/>'
                                           + '<soapenv:Body>' + '<xsd:generateAuthToken>' + '<xsd:authInfo>';
        private final String AUTH_FOOTER = '</xsd:authInfo>' + '</xsd:generateAuthToken>' + '</soapenv:Body>' + '</soapenv:Envelope>';
        private final String REQUEST_STAB = '<Request uniqueId = "[[UNIQUE ID]]">' + '[[STUB]]' + '</Request>';
        private final String DEFAULTS_STAB = '<Defaults getElements="true" uomCode="[[UOM]]" date="[[DATE]]" perQuantity="1" currencyCode="[[CUR]]" orderVolume="1.0" getScales="false"/>';
        private final String PRICING_EVALUATION_STAB = '<PriceEvaluation evaluationMethod="Target Price" getElements="true" uomCode="[[UOM]]" date="[[DATE]]" perQuantity="1" currencyCode="[[CUR]]" orderVolume="1.0">'; // externalId="[[PRODUCT]]"
        private final String EMPTY_RESPONSE_MESSAGE = 'No response from pricing service';
        private final String SUCCESS_RESPONSE_MESSAGE = 'OK';
        private final String EVALUATION_ERROR_RESPONSE_INDICATOR = 'EvaluationError';
        private final String ELEMENT_ERROR_RESPONSE_INDICATOR = 'ElementError';
        private final String ERROR_INDICATOR = 'Error';
        private final String ELEMENT_TOKEN = 'Element';
        private final String TARGET_PRICE_ELEMENT = 'Target Price';
        private final String TARGET_PRICE_FIELD_NAME = 'AITM_Target_Price__c';

        /**
         * @description sets the variable authorization token calling pros api system service end point
         * @param token of type string
         * @return void
         */
        public void setAuthToken(String token) {
            this.authToken = token;
        }

        /**
         * @description gets string soap request
         * @param source of type SObject
         * @param requestName of type string
         * @return string
         */
        public String getRequest(SObject source, String requestName) {
            String result = '';
            result += this.SOAP_HEADER;
            result += getRequestBorderTag();
            result = result.replace('[[STUB]]', this.authToken + this.getDefaults(source) + this.getPricingEvaluation(source, requestName));
            result += this.SOAP_FOOTER;

            sourceRecordId = (Id) source.get('Id');
            return result;
        }

        /**
         * @description returns string response based on response message
         * @param responseBody of type string
         * @param responseName of type string
         * @return AITM_Tender_Location_Line_Item__c
         */
        public AITM_Tender_Location_Line_Item__c fromResponse(String responseBody, String responseName) {
            String response = responseBody.replaceAll('&gt;', '>').substringBetween('<ns:return>', '</ns:return>');
            AITM_Tender_Location_Line_Item__c result = new AITM_Tender_Location_Line_Item__c(Id = sourceRecordId, AITM_Last_Call_To_Pricing_System__c = System.now(), AITM_Data_Pricing_Calculation_Provided__c = false);
            if (String.isEmpty(response)) {
                result.AITM_Pricing_Service_Call_Status__c = this.EMPTY_RESPONSE_MESSAGE;
            } else if (response.contains(this.EVALUATION_ERROR_RESPONSE_INDICATOR)) {
                String errorDetails = responseBody.substringBetween(this.EVALUATION_ERROR_RESPONSE_INDICATOR, '>');
                result.AITM_Pricing_Service_Call_Status__c = errorDetails.substringBetween('message="', '"');   
            } else if (response.contains(this.ELEMENT_ERROR_RESPONSE_INDICATOR)) {
                String errorDetails = responseBody.substringBetween(this.ELEMENT_ERROR_RESPONSE_INDICATOR, '>');
                result.AITM_Pricing_Service_Call_Status__c = errorDetails.substringBetween('message="', '"');               
            } else {
                result.AITM_Pricing_Service_Call_Status__c = this.SUCCESS_RESPONSE_MESSAGE;
                result = this.fillResultsData(result, response, responseName);
            }
            
            return result;
        }

        /**
         * @description returns Authorization soap request for username and password
         * @param username of type string
         * @param userPassword of type string
         * @return string
         */
        public String getAuthRequest(String username, String userPassword) {
            String result = '';
            result += this.AUTH_HEADER;
            result += '<xsd:UserName>' + username + '</xsd:UserName>';
            result += '<xsd:Password>' + userPassword + '</xsd:Password>';
            result += this.AUTH_FOOTER;
            return result;
        }

        /**
         * @description replaces "&lt;" with "<" of authorization response pros api
         * @param responseBody of type string
         * @return string
         */
        public String fromAuthResponse(String responseBody) {
            return responseBody.replaceAll('&lt;', '<').substringBetween('<Response>', '</Response>');
        }

        /**
         * @description returns the tender location line item SObject
         * @param result of type AITM_Tender_Location_Line_Item__c
         * @param response of type string
         * @param responseName of type string
         * @return AITM_Tender_Location_Line_Item__c
         */
        private AITM_Tender_Location_Line_Item__c fillResultsData(AITM_Tender_Location_Line_Item__c result, String response, String responseName) {
            Boolean targetPriceCall = responseName == 'Target Price';
            List<String> parsedResponse = response.split(this.ELEMENT_TOKEN);
            for (AITM_Pricing_Service_Mapping__mdt pricingMappings : AITM_PricingServiceRepository.getInstance().getPricingServiceMappings('PROS', targetPriceCall)) {
                for (String element : parsedResponse) {
                    String elementName = element.substringBetween('name="', '">');
                    if (String.isNotBlank(elementName) && elementName.equalsIgnoreCase(pricingMappings.AITM_Response_Field__c) && !element.contains(this.ERROR_INDICATOR)) {
                        String elementValue = element.substringBetween('value="', '" name="'+pricingMappings.AITM_Response_Field__c);
                        if (pricingMappings.AITM_Type__c == 'Number' && String.isNotBlank(elementValue)) {
                            result.put(pricingMappings.AITM_Field_Name__c, Decimal.valueOf(elementValue));
                        } else {
                            result.put(pricingMappings.AITM_Field_Name__c, elementValue);
                        }
                    }
                }
            }
            return result;
        }

        /**
         * @description gets request border tag with unique id
         * @param null
         * @return string
         */
        private String getRequestBorderTag() {
            String result = this.REQUEST_STAB.replace('[[UNIQUE ID]]', this.generateUniqueId());
            return result;
        }

        /**
         * @description gets defaults value from source sobject
         * @param source of type SObject
         * @return string
         */
        private String getDefaults(SObject source) {
            String result = this.DEFAULTS_STAB.replace('[[UOM]]', this.getSafeValue(source, 'AITM_Unit_Of_Measure__c'));
            result = result.replace('[[DATE]]', this.getFormattedDate(Date.today()));
            result = result.replace('[[CUR]]', this.getSafeValue(source, 'AITM_Currency__c'));
            return result;
        }

        /**
         * @description gets pricing evaluation
         * @param source of type SObject
         * @param requestName of type string
         * @return string
         */
        private String getPricingEvaluation(SObject source, String requestName) {
            AITM_Tender_Location_Line_Item__c sourceLineItem = (AITM_Tender_Location_Line_Item__c) source;

            String result = this.PRICING_EVALUATION_STAB.replace('[[UOM]]', this.getSafeValue(sourceLineItem, 'AITM_Unit_Of_Measure__c'));
            result = result.replace('[[DATE]]', this.getFormattedDate(Date.today()));
            result = result.replace('[[CUR]]', this.getSafeValue(sourceLineItem, 'AITM_Currency__c'));
            result = result.replace('[[PRODUCT]]', sourceLineItem.AITM_Product_Default__c == null? '' : sourceLineItem.AITM_Product_Default__c);

            result += this.getDimension('LOCATION', sourceLineItem.AITM_Location__r.AITM_IATA__c);
            result += this.getDimension('CUSTOMER', sourceLineItem.AITM_GRN__c);

            if (requestName == this.TARGET_PRICE_ELEMENT) {
                result += getTargetPriceEvaluation(sourceLineItem);
            } else {
                result += getPricingInformationEvaluation(sourceLineItem);
            }
            result += '</PriceEvaluation>';
            return result;
        }

        /**
         * @description gets targetprice evaluation
         * @param sourceLineItem of type AITM_Tender_Location_Line_Item__c
         * @return string
         */
        private String getTargetPriceEvaluation(AITM_Tender_Location_Line_Item__c sourceLineItem) {
            String result = this.getEvaluationMethodElement('Customer Segment Value', sourceLineItem.AITM_Account__r.AITM_Customer_Segment__c);
            result += this.getEvaluationMethodElement('Location Volume', sourceLineItem.AITM_Location_Size__c);
            result += this.getEvaluationMethodElement('Location Strategy Value', sourceLineItem.AITM_Location_Strategy__c);
            result += this.getEvaluationMethodElement('Tender Volume', sourceLineItem.AITM_Volume__c);
            result += this.getEvaluationMethodElement('PriceStartDate', this.getFormattedDate(sourceLineItem.AITM_Start_Date__c));
            result += this.getEvaluationMethodElement('PriceEndDate', this.getFormattedDate(sourceLineItem.AITM_End_Date__c));
            return result;
        }

        /**
         * @description returns the PricingInformationEvaluation method element values of TenderLocationLineItem
         * @param sourceLineItem of type AITM_Tender_Location_Line_Item__c
         * @return string
         */
        private String getPricingInformationEvaluation(AITM_Tender_Location_Line_Item__c sourceLineItem) {
            String result = '';
            if(sourceLineItem.AITM_Instrument__c != null){
            result = this.getDimension('INSTRUMENT', sourceLineItem.AITM_Instrument__c);
  			}
            result += this.getEvaluationMethodElement('Customer Segment Value', sourceLineItem.AITM_Account__r.AITM_Customer_Segment__c);
            result += this.getEvaluationMethodElement('Tender Volume', sourceLineItem.AITM_Volume__c);
            result += this.getEvaluationMethodElement('Location Volume', sourceLineItem.AITM_Location_Size__c);
            result += this.getEvaluationMethodElement('Location Strategy Value', sourceLineItem.AITM_Location_Strategy__c);
            result += this.getEvaluationMethodElement('Offer Differential', sourceLineItem.AITM_Offered_Differential__c);
            result += this.getEvaluationMethodElement('Volume Differential', sourceLineItem.AITM_Offered_Volume__c);
            result += this.getEvaluationMethodElement('Credit Days', (sourceLineItem.AITM_Credit_Days__c == 'PP' ? '-2' : sourceLineItem.AITM_Credit_Days__c));
            result += this.getEvaluationMethodElement('Sales Pricing Basis', sourceLineItem.AITM_Sales_Pricing_Period__c);
            result += this.getEvaluationMethodElement('Supply Pricing Basis', sourceLineItem.AITM_Replenishment_Pricing_Period__c);
            result += this.getEvaluationMethodElement('Invoice Frequency', sourceLineItem.AITM_Invoice_Frequency__c);
            result += this.getEvaluationMethodElement('Unit Rebate', (sourceLineItem.AITM_Rebate__c == null ? 0 : sourceLineItem.AITM_Rebate__c));
            result += this.getEvaluationMethodElement('Density', sourceLineItem.AITM_Density__c);
            result += this.getEvaluationMethodElement('Customer Specific Into-Plane Costs', sourceLineItem.AITM_Customer_Specific_Into_Plane_Costs__c);
            result += this.getEvaluationMethodElement('Credit Rating of Customer', sourceLineItem.AITM_Credit_Rating__c);
            result += this.getEvaluationMethodElement('Additional Margin from Line Items', sourceLineItem.AITM_Additional_Margin_From_Line_Items__c);
            result += this.getEvaluationMethodElement('PriceStartDate', this.getFormattedDate(sourceLineItem.AITM_Start_Date__c));
            result += this.getEvaluationMethodElement('PriceEndDate', this.getFormattedDate(sourceLineItem.AITM_End_Date__c));
            result += this.getEvaluationMethodElement('JV Profit Dividend', sourceLineItem.AITM_JV_Profit_Dividend__c);
            return result;
        }

        /**
         * @description gets dimension xml element tag with name-value set passed to method
         * @param dimensionName of type string
         * @param value of type object
         * @return string
         */
        private String getDimension(String dimensionName, Object value) {
            return '<Dimension name="' + dimensionName + '" value="' + objectToString(value) + '" />';
        }

        /**
         * @description gets string format of xml element tag "EvaluationMethodElement" from pros soap response
         * @param evaluationName of type string
         * @param value of type object
         * @return string
         */
        private String getEvaluationMethodElement(String evaluationName, Object value) {
            if (value == null) {
                return '';
            } else {
                return '<EvaluationMethodElement name="' + evaluationName + '" value="' + objectToString(value) + '" />';
            }
        }

        /**
         * @description converts object to string
         * @param value of type Object
         * @return string
         */
        private String objectToString(Object value) {
            return value == null ? '' : String.valueOf(value); 
        }
        
        /**
         * @description generates uniqueId 
         * @param null
         * @return string
         */
        private String generateUniqueId() {
            String hex = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
            String guid = hex.SubString(0,8)+ '-' + hex.SubString(8,12) + '-' + hex.SubString(12,16) + '-' + hex.SubString(16,20);
            return guid;
        }

        /**
         * @description gets string formatted source date 
         * @param source of type date
         * @return string
         */
        private String getFormattedDate(Date source) {
            Date sourceDate = source == null ? Date.today() : source;
            return Datetime.newInstance(sourceDate.year(), sourceDate.month(), sourceDate.day()).format('yyyyMMdd');
        }

        /**
         * @description gets safe value of field mapping with SObject instance
         * @param objectInstance of type SObject
         * @param fieldName of type string
         * @return string
         */
        private String getSafeValue(SObject objectInstance, String fieldName) {
            String result = '';
            if (objectInstance.get(fieldName) != null) {
                result = String.valueOf(objectInstance.get(fieldName));
            }
            return result;
        }
    }
}