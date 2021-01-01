/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    controller class when Generate Offer button was clicked. It attaches Tender Offer GT&C 
 *                 and MSDS PDF files(email attachments).

 * history
 * 01/December/2017  George       Created
 * 01/March/2018     srnandan     Modified - AR-2591 Added map variable 'MAP_NEWOFFER_MSDS_FILE_STATIC_RESOURCE' 
 *                                and method 'getMSDSLegalDocumentResource' to get static resource content details of MSDS files,
 *                                modified method 'createOfferLegalDocument' to create content version msds files and post to chatter 
 *                                for send offer functionality 
 * 05/March/2018     Anusha       Modified - AR-2542 updated Contracting bank details to Bank Account object details                                
 * 08/March/2018     srnandan     added with sharing to outer class as per coding standard and also code comments
 * 19/Aprii/2018     srnandan     Modified - AR-2979 - SOQL 101 query method createOfferLegalDocument
 * 10/May/2018       Ravi         Added Offer Valid Until Date to the Offer PDF Document.
 * 18/May/2018       Martin       Modified - AR-3099 - change signatory reference fields
 * 17/May/2018       srnandan     Modified - AR-3169 - Changed the mapping field Creditdays  
 * 28/May/2018       Ravi         Modified - AR-3162 - Added variable netGross in LocationWrapper
 * 30/May/2018       Ravi         Modified - AR-3240 - Updated currency field from Tender to Tender Account AITM_Payment_Currency__c
 * 08/June/2018      srnandan     Modified - AR-3504 - Changed the mapping of credit terms field AITM_Credit_Terms__c to AITM_Security_Text_on_Offer__c
 * 15/June/2018      srnandan     Modified - AR-3522 - Conditional display of currency "USX" to "USC"
 * 15/June/2018      srnandan     Modified - AR-3363 - Modified differential datatype to decimal and setscale to 2 
 * 18/June/2018      Ravi         Modified - AR-3362 - Modified method LocationsLineItemWrapper to add currency and UoM
 * 28/June/2018      srnandan     Modified - AR-3522 - Conditional display of currency "USX" to "USC"
 * 13/July/2018      Anusha       Modified - AR-3705 - Condition to display See the differential value on Current Price
 * 26/July/2018      Anusha       Modified - AR-3892 - Modified the method getvolume to return offered Volume converted to Requested UOM
 * 07/Aug/2018       Shweta       Modified - AR-4014 - Mofified the Location Wrapper Constructor to put the Null Check on the offered volume.
 * 20/August/2018    srnandan     Modified - AR-XXXX - product assignment is done based on product density mapping
 * 28/Sep/2018       srnandan     Modified - AR-     - added jvTerms property in offerwrapper class
 * 11/Dec/2018       Ravi         Modified - AR-4626 - added Delivery Point related to TLLI to show Location Delivery Point fields in Offer PDF Table
 * 12/December/2018  srnandan     Modified - AR-4791 - show legal entity address if legal entity present else accounting details address
 * 26/December/2018  Anusha       Modified - AR-2745 - Reseller paragraph will be shown if Account classification consists of CA and GA REseller
 * 02/Jan/2019       Ravi         Modified - AR-4626 - updated Delivery Point related Locations to display in Offer PDF
 * 18/Jan/2019       Anusha       Modified - AR-4913 - updated TLLI wrapper to get taxes and fees from TLLI
 * 21/January/2019   srnandan     Modified - AR-4919 - Added constant static resource and method getResellerLegalDocumentResource for content attachments
 * 23/January/2019   srnandan     Modified - AR-4913 - Added netGross, taxesandfees, additionalnotes to pick up from TLLI
 * 17/February/2019  srnandan     Modified - AR-2745 - Added methods getResellerPageReference and modified generateOfferPDF
 * 27/March/2019     Ravi         Modified - AR-5111 updated MT conversion 
 * 12/May/2019       srnandan     Modified - AR-5190 Corrected the postalcode mapping and added getAffiliates method
 * 24/May/2019       srnandan     Modified - AR-5029 Changed product description mapping tender location to lineitem
 * 15/Nov/2019       srnandan     Modified - added logic to by pass taxes and fees records gathering for old tender taxes and fees
 *************************************************************************/
public without sharing class AITM_TenderOfferPDFController {

    private final static String RECURSION_PARAM_NAME = 'recparam';
    public static final ID TLLI_ID_RECORD_TYPE_DEFAULT = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
    public static OfferWrapper offer {get; set;}
    public static List<LocationsWrapper> locations {get; set;}
    public static Map<Id, List<AITM_Tender_Location_Taxes_and_Fees__c>> locationTaxesFeesMap = New Map<Id,List<AITM_Tender_Location_Taxes_and_Fees__c>>();	
    public static Id tenderId;	
    public static AITM_Tender__c tenderRecord;
    /**
     * @description default constructor
     */ 
    public AITM_TenderOfferPDFController() {}

    /**
     * @description overloaded constructor
     */ 
    public AITM_TenderOfferPDFController(ApexPages.StandardController controller) {
        GenerationDTO generationDataTrasferObject = buildGenerationDTO();
		tenderRecord = (AITM_Tender__c)controller.getRecord();	
        tenderId = tenderRecord.Id;
        if (generationDataTrasferObject.consistent()) {
		    locationTaxesFeesMap = getLocationTaxesAndFees();
            offer = new OfferBuilder(generationDataTrasferObject).build();
            locations = new LocationsBuilder(generationDataTrasferObject).build();
        }
    }
    
	 /**
         * @description gets location taxes and fees based on line item 
         * @param no parameter
         * @return Map of line item id and list of Location taxes and fees
        */
       public Map<Id, List<AITM_Tender_Location_Taxes_and_Fees__c>> getLocationTaxesAndFees() {
            List<AITM_Tender_Location_Taxes_and_Fees__c> taxesFeesList = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
                       
            for(AITM_Tender_Location_Taxes_and_Fees__c taxFee: [select name,AITM_Value__c,AITM_Display_Currency__c,AITM_Unit_of_measure__c,Tender_Location_Line_Item_Id__c,AITM_Compulsory_Conditional__c from AITM_Tender_Location_Taxes_and_Fees__c  where AITM_Select_to_Apply_in_Contract__c = TRUE AND Tender_Location_Line_Item_Id__r.AITM_Tender__c =: tenderId]){
               taxesFeesList = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
                if(locationTaxesFeesMap.ContainsKey(taxFee.Tender_Location_Line_Item_Id__c)) {
                    taxesFeesList = locationTaxesFeesMap.get(taxFee.Tender_Location_Line_Item_Id__c);
                    taxesFeesList.add(taxFee);
                    locationTaxesFeesMap.put(taxFee.Tender_Location_Line_Item_Id__c, taxesFeesList);
                } 
                else{
                    taxesFeesList.add(taxFee);
                    locationTaxesFeesMap.put(taxFee.Tender_Location_Line_Item_Id__c, taxesFeesList);
                 }
               }
            
            return locationTaxesFeesMap;
       }    
       
      
	   
    /**
     * @description adds attachment for tender offer
     * @param  null
     * @return void
     */
    public static void addAttachment() {
        if (recursionParameterNotCalled()) {
            GenerationDTO generationDataTrasferObject = buildGenerationDTO();
            if (generationDataTrasferObject.consistent()) {
                AITM_TenderOfferPDFController.generateOffer(generationDataTrasferObject);
            }
        }
    }

    /**
     * @description generate pdf attachment for tender offer
     * @param  generationDataTrasferObject of type GenerationDTO
     * @return void
     */
    public static void generateOffer(GenerationDTO generationDataTrasferObject) {
        PDFGenerator generator = new PDFGenerator(generationDataTrasferObject);
        generator.generatePDF();
    }

    /**
     * @description returns true if additionalservices available for location
     * @param  null
     * @return boolean
     */
    public Boolean getAdditionalServicesAvailable() {
        Boolean result = false;
        for (LocationsWrapper locationAdapter : locations) {
            result = result || locationAdapter.getAdditionalServicesAvailable();
        }
        return result;
    }

    /**
     * @description builds GenerationDTO object
     * @param  null
     * @return GenerationDTO class object
     */
    private static GenerationDTO buildGenerationDTO() {
        GenerationDTO generationDataTrasferObject = new GenerationDTO();
        if (allGenerationParamsAreSet()) {
            generationDataTrasferObject.tenderId = Id.valueOf(getPageParameter('id'));
            generationDataTrasferObject.customerId = Id.valueOf(getPageParameter('customerId'));
            generationDataTrasferObject.selectedFilter = getPageParameter('filter');
            generationDataTrasferObject.bespoke = generationDataTrasferObject.getBeSpokeTemplate(generationDataTrasferObject.customerId);
        }
        return generationDataTrasferObject;
    }

    /**
     * @description returns true if the page contains both id and customerid query string params else false
     * @param  null
     * @return boolean 
     */
    private static Boolean allGenerationParamsAreSet() {
        return getPageParameter('id') != null && getPageParameter('customerId') != null;
    }
    
    /**
     * @description returns parameter value based on query string parameterName passed
     * @param  parameterName of type string
     * @return string parametervalue
     */
    private static String getPageParameter(String parameterName) {
        return ApexPages.currentPage().getparameters().get(parameterName);
    }

    /**
     * @description returns true if it doesn't contain recursionparamname
     * @param  null
     * @return boolean
     */
    private static Boolean recursionParameterNotCalled() {
        return !ApexPages.currentPage().getparameters().containsKey(RECURSION_PARAM_NAME);
    }

    /**
     * @description generation data transfer object inner class
     */
    public class GenerationDTO {
        public Id tenderId;
        public Id customerId;
        public String selectedFilter;
        public String bespoke;
        
        /**
         * @description returns true if both tenderId and customerId is not null else false
         * @param  null
         * @return boolean 
         */
        public Boolean consistent() {
            return this.tenderId != null && this.customerId != null;
        }
        
        /**
         * @description gets the bespoke offer template VF Page
         * @param accountId of type Id
         * @return String
         */ 
        public String getBeSpokeTemplate(Id accountId) {
            String templateName = '';
            List<AITM_Tender_Account__c> accList = [Select AITM_Account__r.AITM_Bespoke_Offer_Template__c FROM AITM_Tender_Account__c WHERE Id =: accountId];
            if(!accList.isEmpty()) {
             if(accList[0].AITM_Account__r.AITM_Bespoke_Offer_Template__c != null) {
                 templateName = accList[0].AITM_Account__r.AITM_Bespoke_Offer_Template__c;
                }
            }
            return templateName;
        }
    }

    /**
     * @description inner class PDFGenerator
     */
    public class PDFGenerator {
        private final String CONTRACT_DOCUMENT_STATIC_RESOURCE = 'AITM_NewOfferContractTerms';
        private final Map<String,String> MAP_NEWOFFER_MSDS_FILE_STATIC_RESOURCE = new Map<String,String>{'AITM_NewOfferMSDS2101ContractTerms'=>Label.AITM_NewOfferPDFMSDS2101FilePrefix,'AITM_NewOfferMSDS2102ContractTerms'=>Label.AITM_NewOfferPDFMSDS2102FilePrefix,'AITM_NewOfferMSDS2105ContractTerms'=>Label.AITM_NewOfferPDFMSDS2105FilePrefix};
        private GenerationDTO generationDataTrasferObject;

        /**
         * @description overloaded constructor
         * @param generationDataTrasferObject of type GenerationDTO
         */
        public PDFGenerator(GenerationDTO generationDataTrasferObject) {
            this.generationDataTrasferObject = generationDataTrasferObject;
        }

        /**
         * @description returns true if both tenderId and customerId is not null else false
         * @param  null
         * @return boolean 
         */
        public Boolean isLegalDocument() {
            return !generationDataTrasferObject.consistent();
        }

        /**
         * @description generates legal document pdf page
         * @param  null
         * @return void 
         */
        public void generatePDF() {
            if (!generationDataTrasferObject.consistent()) {
                this.createOfferLegalDocument();
            } else {
                PageReference offerPage = this.getOfferPageReference();
                this.createOffer(offerPage);
                PageReference resellerPage = this.getResellerPageReference();
                this.createReseller(resellerPage);
            }
        }
        
        /**
         * @description returns page reference of PageReference of AITM_GAApendix4 page
         * @param  null
         * @return PageReference of PageReference of AITM_GAApendix4 page
         */
        private PageReference getResellerPageReference() {
            PageReference resellerPDFPage = Page.AITM_GAApendix4;
            resellerPDFPage.getParameters().put('id', this.generationDataTrasferObject.tenderId);
            resellerPDFPage.getParameters().put('customerId', this.generationDataTrasferObject.customerId);
            resellerPDFPage.getParameters().put('filter', this.generationDataTrasferObject.selectedFilter);
            resellerPDFPage.getParameters().put(RECURSION_PARAM_NAME, 'true');
            return resellerPDFPage;
        }
        
        /**
         * @description returns page reference of AITM_TenderOfferPDF page
         * @param  null
         * @return PageReference of AITM_TenderOfferPDF page
         */
        private PageReference getOfferPageReference() {
            PageReference contractPDFPage;
            this.generationDataTrasferObject.bespoke = this.generationDataTrasferObject.getBeSpokeTemplate(this.generationDataTrasferObject.customerId);

            switch on this.generationDataTrasferObject.bespoke {
                when 'AITM_Offer2015PDF' {
                    contractPDFPage = Page.AITM_Offer2015PDF;
                }
                when 'AITM_OfferAirSerbia' {
                    contractPDFPage = Page.AITM_OfferAirSerbia;
                }
                when 'AITM_OfferBLX' {
                    contractPDFPage = Page.AITM_OfferBLX;
                }
                when 'AITM_OfferChinaEast' {
                    contractPDFPage = Page.AITM_OfferChinaEast;
                }
                when 'AITM_OfferEAT' {
                    contractPDFPage = Page.AITM_OfferEAT;
                }
                when 'AITM_OfferEtihad' {
                    contractPDFPage = Page.AITM_OfferEtihad;
                }
                when 'AITM_OfferGAMA' {
                    contractPDFPage = Page.AITM_OfferGAMA;
                }
                when 'AITM_OfferGASORT' {
                    contractPDFPage = Page.AITM_OfferGASORT;
                }
                when 'AITM_OfferGMI' {
                    contractPDFPage = Page.AITM_OfferGMI;
                }
                when 'AITM_OfferJetSys' {
                    contractPDFPage = Page.AITM_OfferJetSys;
                }
                when 'AITM_OfferL' {
                    contractPDFPage = Page.AITM_OfferL;
                }
                when 'AITM_OfferLH' {
                    contractPDFPage = Page.AITM_OfferLH;
                }
                when 'AITM_OfferLH16' {
                    contractPDFPage = Page.AITM_OfferLH16;
                }
                when 'AITM_OfferLOT' {
                    contractPDFPage = Page.AITM_OfferLOT;
                }
                when 'AITM_OfferMY' {
                    contractPDFPage = Page.AITM_OfferMY;
                }
                when 'AITM_OfferNAU' {
                    contractPDFPage = Page.AITM_OfferNAU;
                }
                when 'AITM_OfferSORT' {
                    contractPDFPage = Page.AITM_OfferSORT;
                }
                when 'AITM_OfferTC' {
                    contractPDFPage = Page.AITM_OfferTC;
                }
                when 'AITM_OfferVA' {
                    contractPDFPage = Page.AITM_OfferVA;
                }
                when 'AITM_OfferQatar' {
                    contractPDFPage = Page.AITM_OfferQatar;
                }                
                when else {
                    contractPDFPage = Page.AITM_TenderOfferPDF;
                }
            }
            contractPDFPage.getParameters().put('id', this.generationDataTrasferObject.tenderId);
            contractPDFPage.getParameters().put('customerId', this.generationDataTrasferObject.customerId);
            contractPDFPage.getParameters().put('filter', this.generationDataTrasferObject.selectedFilter);
            contractPDFPage.getParameters().put(RECURSION_PARAM_NAME, 'true');
            return contractPDFPage;
        }

        /**
         * @description creates tender offer and posts to the chatter with file link 
         * @param  pdfPage of type apex PageReference
         * @return void
         */
        private void createOffer(PageReference pdfPage) {
            AITM_Tender__c tenderRecord = new AITM_TenderDao().getTender(this.generationDataTrasferObject.tenderId);
            AITM_Tender_Account__c tenderAccount = new AITM_AccountDao.TenderAccountDao().getTenderAccountWithOfferInformation(this.generationDataTrasferObject.customerId);
   
            Blob fileBody;
            if (!Test.isRunningTest()) {
                fileBody = pdfPage.getContent();
            } else {
                fileBody = Blob.valueOf('Test Document');
            }
            ContentVersion contractFile = AITM_BaseUtils.createContentVersion(fileBody, Label.AITM_NewOfferPDFOfferPrefix + Date.today().format() + ':' + tenderRecord.Name + ':' + tenderAccount.AITM_Account__r.Name + '.pdf');
            AITM_BaseUtils.createChatterPostToRelate(Label.AITM_NewOfferPDFOfferChatterText, this.generationDataTrasferObject.tenderId, contractFile.Id);
        }
        
        /**
         * @description creates tender reseller and posts to the chatter with file link 
         * @param  pdfPage of type apex PageReference
         * @return void
         */
        private void createReseller(PageReference pdfPage) {
            AITM_Tender__c tenderRecord = new AITM_TenderDao().getTender(this.generationDataTrasferObject.tenderId);
            AITM_Tender_Account__c tenderAccount = new AITM_AccountDao.TenderAccountDao().getTenderAccountWithOfferInformation(this.generationDataTrasferObject.customerId);
            
			if((tenderAccount.AITM_Account_Classification__c != Null)&&(tenderAccount.AITM_Account_Classification__c == 'CA Reseller' || tenderAccount.AITM_Account_Classification__c == 'GA Reseller')) {
                Blob fileBody;
                if (!Test.isRunningTest()) {
                    fileBody = pdfPage.getContent();
                } else {
                    fileBody = Blob.valueOf('Test Document');
                }
                ContentVersion contractFile = AITM_BaseUtils.createContentVersion(fileBody, Label.AITM_NewOfferPDFAppendix4Prefix + Date.today().format() + ':' + tenderRecord.Name + ':' + tenderAccount.AITM_Account__r.Name + '.pdf');
                AITM_BaseUtils.createChatterPostToRelate(Label.AITM_NewOfferPDFAppendix4ChatterText, this.generationDataTrasferObject.tenderId, contractFile.Id);
           }
		   
        }
        
        /**
         * @description creates legal offer document
         * @param  null
         * @return void
         */
        private void createOfferLegalDocument() {
            if (legalDocumentNotGenerated()) {
                StaticResource genericLegalDocumentResource = getGenericLegalDocumentResource();
                ContentVersion legalOffer = AITM_BaseUtils.createContentVersion(genericLegalDocumentResource.Body, Label.AITM_NewOfferPDFLegalFilePrefix + '.pdf');
                AITM_BaseUtils.createChatterPostToRelate(Label.AITM_NewOfferPDFLegalChatterText, this.generationDataTrasferObject.tenderId, legalOffer.Id);
                List<StaticResource> msdsLegalDocumentResource = getMSDSLegalDocumentResource();
                List<ContentVersion> msdsLegalOfferList = AITM_BaseUtils.createContentVersion(msdsLegalDocumentResource, MAP_NEWOFFER_MSDS_FILE_STATIC_RESOURCE);
                AITM_BaseUtils.createChatterPostToRelate(Label.AITM_NewOfferPDFLegalChatterText, this.generationDataTrasferObject.tenderId, msdsLegalOfferList);
            }
        }

        /**
         * @description returns true if legaldocument not generated else false
         * @param  null
         * @return boolean
         */
        private Boolean legalDocumentNotGenerated() {
            Boolean result = true;
            for (FeedItem item : [SELECT Id, RelatedRecordId FROM FeedItem WHERE Type = 'ContentPost' AND ParentId =: this.generationDataTrasferObject.tenderId]) {
                if (item.RelatedRecordId != null) {
                    result = false;
                }
            }
            return result;
        }

        /**
         * @description returns StaticResource for generic legal document GT&C
         * @param  null
         * @return StaticResource object
         */
        private StaticResource getGenericLegalDocumentResource() {
            return [SELECT Body FROM StaticResource WHERE Name = :CONTRACT_DOCUMENT_STATIC_RESOURCE LIMIT 1][0];
        }

        /**
         * @description returns list of static resource where name related to msds files
         * @param  null
         * @return List of type StaticResource
         */
        private List<StaticResource> getMSDSLegalDocumentResource() {
            return [SELECT Name,Body FROM StaticResource WHERE Name in :MAP_NEWOFFER_MSDS_FILE_STATIC_RESOURCE.keySet() LIMIT 5];
        }
    }

    /**
     * @description offerbuilder inner class
     */
    public class OfferBuilder {
        private GenerationDTO generationDataTrasferObject;

        /**
         * @description offerbuilder overloaded constructor
         */
        public OfferBuilder(GenerationDTO generationDataTrasferObject) {
            this.generationDataTrasferObject = generationDataTrasferObject;
        }

        /**
         * @description returns offerwrapper object for the given tendercustomeraccount
         * @param  null
         * @return OfferWrapper object
         */
        public OfferWrapper build() {
            AITM_Tender_Account__c tenderAccount = new AITM_AccountDao.TenderAccountDao().getTenderAccountWithOfferInformation(this.generationDataTrasferObject.customerId);
            return new OfferWrapper(tenderAccount);
        }
    }

    /**
     * @description locationsbuilder inner class
     */
    public class LocationsBuilder {
        private GenerationDTO generationDataTrasferObject;

        /**
         * @description locationsbuilder overloaded constructor
         */
        public LocationsBuilder(GenerationDTO generationDataTrasferObject) {
            this.generationDataTrasferObject = generationDataTrasferObject;
        }

        /**
         * @description returns list of locationswrapper object 
         * @param  null
         * @return List of LocationsWrapper object
         */
        public List<LocationsWrapper> build() {
            List<LocationsWrapper> locations = new List<LocationsWrapper>();
            AITM_RelatedRecordsHolderController.FilterOption filter = this.getFilterOption(this.generationDataTrasferObject.selectedFilter, this.generationDataTrasferObject.tenderId);
            if (filter == null) {
                locations = this.getBaseTenderLocations(this.generationDataTrasferObject.tenderId);
            } else {
                if (filter.isSelectiveFilter()) {
                    locations = this.getFilteredTenderLocations(this.generationDataTrasferObject.tenderId, filter);
                } else {
                    locations = this.getFilteredTenderLocations(this.generationDataTrasferObject.tenderId, filter, true);
                }
            }

            return locations;
        }

        /**
         * @description returns list of locationswrapper object 
         * @param  parameterName of type string
         * @param  tenderId of type Id
         * @return AITM_RelatedRecordsHolderController.FilterOption object
         */
        private AITM_RelatedRecordsHolderController.FilterOption getFilterOption(String parameterName, Id tenderId) {
            return AITM_RelatedTenderLocationsHolderCntrl.getFilter(parameterName, tenderId);
        }

        /**
         * @description returns list of tenderlocations 
         * @param  tenderId of type Id
         * @return List of LocationsWrapper object
         */
        private List<LocationsWrapper> getBaseTenderLocations(Id tenderId) {
            List<LocationsWrapper> locations = new List<LocationsWrapper>();
            for(AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getPricedTenderLocationsWithLineItems(tenderId, null, null)) {
                //if(tenderLocation.AITM_Country__c != AITM_LocationsDao.POLISH_COUNTRY) {
                    locations.add(new LocationsWrapper(tenderLocation));
                //}
            }
            return locations;
        }

        /**
         * @description returns list of filtered tenderlocations 
         * @param  tenderId of type Id
         * @param  parsedFilter of type AITM_RelatedRecordsHolderController.FilterOption
         * @return List of LocationsWrapper object
         */
        private List<LocationsWrapper> getFilteredTenderLocations(Id tenderId, AITM_RelatedRecordsHolderController.FilterOption parsedFilter) {
            List<LocationsWrapper> locations = new List<LocationsWrapper>();
            for(AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getPricedTenderLocationsWithLineItems(tenderId, parsedFilter.getCriteria(), parsedFilter.name)) {
                //if(tenderLocation.AITM_Country__c != AITM_LocationsDao.POLISH_COUNTRY) {
                    locations.add(new LocationsWrapper(tenderLocation));
                //}
            }
            return locations;
        }

        /**
         * @description returns list of filtered tenderlocations based on filtername
         * @param  tenderId of type Id
         * @param  parsedFilter of type AITM_RelatedRecordsHolderController.FilterOption
         * @param  selectivityFlag of type Boolean
         * @return List of LocationsWrapper object
         */
        private List<LocationsWrapper> getFilteredTenderLocations(Id tenderId, AITM_RelatedRecordsHolderController.FilterOption parsedFilter, Boolean selectivityFlag) {
            List<LocationsWrapper> locations = new List<LocationsWrapper>();
            for(AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getPricedTenderLocationsWithLineItems(tenderId, null, parsedFilter.name)) {
                if (parsedFilter.isPassedFilter(tenderLocation)) {
                    //if(tenderLocation.AITM_Country__c != AITM_LocationsDao.POLISH_COUNTRY) {
                        locations.add(new LocationsWrapper(tenderLocation));
                    //}
                }
            }
            return locations;
        }
    }

    /**
      * @description offerwrapper inner class
    */
    public class OfferWrapper {
        public Date contractDate {get; private set;}
        public String offerValidUntil {get; private set;}
        public String legalName {get; private set;}
        public String legalCountry {get; private set;}
        public String legalAddress {get; private set;}
        public String customerName {get; private set;}
        public String customerCountry {get; private set;}
        public String customerAddress {get; private set;}
        public String offerCurrency {get; private set;}
        public String bankNumber {get; private set;}
        public String bankIBAN {get; private set;}
        public String bankName {get; private set;}
        public String bankAddress {get; private set;}
        public String bankCity {get; private set;}
        public String creditTerms {get; private set;}
        //public String affiliates {get; private set;}
        public List<String> affiliates {get; private set;}
        public Boolean isAffiliates {get; private set;}
        public String legalEmail {get; private set;}
        public String customerEmail {get; private set;}
        public String tenderGovenror {get; private set;}
        public String tenderArbitration {get; private set;}
        public String resellers {get; private set;}
        public String accountClassification {get; private set;}
        public String signersName {get; private set;}
        public String signersDesignation {get; private set;}
        public String signingDate {get; private set;}
        public String jvTerms {get; private set;}
        public Boolean selectToApplyOldTaxFees {get; private set;} 

        /**
         * @description offerwrapper overloaded constructor
        */
        public OfferWrapper(AITM_Tender_Account__c tenderAccount) {
            this.contractDate = Date.today();
            this.offerValidUntil = (tenderAccount.AITM_Tender__r.AITM_Offer_Valid_Until__c != null ? tenderAccount.AITM_Tender__r.AITM_Offer_Valid_Until__c.format() : null);
            this.legalName = tenderAccount.AITM_Contracting_Entity__r.Name;
            this.legalCountry = tenderAccount.AITM_Contracting_Entity__r.AITM_Country__c;
            this.legalAddress = tenderAccount.AITM_Contracting_Entity__r.AITM_Address__c;
            this.customerName = tenderAccount.AITM_Account__r.Name;
            this.customerCountry = tenderAccount.AITM_Account__r.BillingCountry;
            this.customerAddress = buildCustomerAddress(tenderAccount);
            this.offerCurrency = (tenderAccount.AITM_Payment_Currency__c == 'USX' ? 'USC' : tenderAccount.AITM_Payment_Currency__c);
            this.bankNumber = tenderAccount.AITM_Bank_Account__r.AITM_Bank_Account_Number__c;
            this.bankIBAN = tenderAccount.AITM_Bank_Account__r.AITM_Bank_IBAN_Number__c;
            this.bankName = tenderAccount.AITM_Bank_Account__r.Name;
            this.bankAddress = tenderAccount.AITM_Bank_Account__r.AITM_Bank_Address__c;
            this.bankCity = tenderAccount.AITM_Bank_Account__r.AITM_Bank_City__c;
            this.creditTerms = tenderAccount.AITM_Security_Text_on_Offer__c;
            this.affiliates = new AITM_AccountDao.TenderAccountDao().getAffiliates(tenderAccount.AITM_Account__c, tenderAccount.AITM_Tender__c);//tenderAccount.AITM_Affiliates_Account__r.Name;
            this.isAffiliates = (this.affiliates.isEmpty() ? true : false);
            this.legalEmail = tenderAccount.AITM_Contracting_Entity__r.AITM_Email__c;
            this.customerEmail = tenderAccount.AITM_Email__c;
            this.tenderGovenror = tenderAccount.AITM_Contracting_Entity__r.AITM_Governing_Law__c;
            this.tenderArbitration = tenderAccount.AITM_Contracting_Entity__r.AITM_Arbritation__c;
            this.resellers = tenderAccount.AITM_Resellers__c;
            this.accountClassification = (tenderAccount.AITM_Account_Classification__c == 'CA Reseller' || tenderAccount.AITM_Account_Classification__c == 'GA Reseller' )? string.valueOf(tenderAccount.AITM_Account_Classification__c) : null;
            this.signersName = tenderAccount.AITM_Contracting_Entity_Signatory__c;
            this.signersDesignation = tenderAccount.AITM_Contracting_Entity_Title__c;
            this.signingDate = Date.today().format();
            this.jvTerms = tenderAccount.JV_terms__c;
            this.selectToApplyOldTaxFees = tenderAccount.AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c;
        }

        /**
         * @description returns string format of customeraddress for the tenderAccount
         * @param  tenderAccount of type AITM_Tender_Account__c (SObject)
         * @return String
        */
        private String buildCustomerAddress(AITM_Tender_Account__c tenderAccount) {
           
            String customerAddress = '';
            if(tenderAccount.AITM_Legal_Entity__c != null) {
                customerAddress += (tenderAccount.AITM_Legal_Entity__r.BillingStreet != null ? tenderAccount.AITM_Legal_Entity__r.BillingStreet + ' ':'');
                customerAddress += (tenderAccount.AITM_Legal_Entity__r.BillingCity != null ? tenderAccount.AITM_Legal_Entity__r.BillingCity + ' ':'');
                customerAddress += (tenderAccount.AITM_Legal_Entity__r.BillingState != null ? tenderAccount.AITM_Legal_Entity__r.BillingState + ' ':'');
                customerAddress += (tenderAccount.AITM_Legal_Entity__r.BillingCountry != null ? tenderAccount.AITM_Legal_Entity__r.BillingCountry + ' ':'');
                customerAddress += (tenderAccount.AITM_Legal_Entity__r.BillingPostalCode != null ? tenderAccount.AITM_Legal_Entity__r.BillingPostalCode : '');
            } else {
                customerAddress += (tenderAccount.AITM_Account__r.BillingStreet != null ? tenderAccount.AITM_Account__r.BillingStreet + ' ':'');
                customerAddress += (tenderAccount.AITM_Account__r.BillingCity != null ? tenderAccount.AITM_Account__r.BillingCity + ' ':'');
                customerAddress += (tenderAccount.AITM_Account__r.BillingState != null ? tenderAccount.AITM_Account__r.BillingState + ' ':'');
                customerAddress += (tenderAccount.AITM_Account__r.BillingCountry != null ? tenderAccount.AITM_Account__r.BillingCountry + ' ':'');
                customerAddress += (tenderAccount.AITM_Account__r.BillingPostalCode != null ? tenderAccount.AITM_Account__r.BillingPostalCode : '');
            }
            
            return  customerAddress;          
        }
    }

    /**
      * @description locationswrapper inner class
    */
    public class LocationsWrapper {
        public String IATA {get; private set;}
        public String locationName {get; private set;}
        public String locationGroup {get; private set;}
        public String duration {get; private set;}
        public String product {get; private set;}
        public decimal totalVolume {get; private set;}
        public String tenderUom {get; private set;}
        //public String netGross {get; private set;}  
        public String country {get; private set;}
        
        public map<id, List<LocationsLineItemWrapper>> lineItemsMap {get; private set;}
        public map<id, AITM_Delivery_Point__c> mdDlPoint {get;set;}

        public List<LocationsLineItemWrapper> lineItems {get; private set;}
        //public String taxesAndFees {get; private set;}
        //public String additionalNotes {get; private set;}
        public Boolean includeInRevisedOffer {get; private set;}

        public String deliveryServices {get; private set;}
        public String aircraftType {get; private set;}
        public String locationDuration {get; private set;}
        private final Set<String> ADDITIONAL_SERVICES_LEVELS = new Set<String>{'Level II', 'Level III'};
        public String deliveryMethod {get; private set;}
        public String serviceLevel {get; private set;}
        private AITM_Tender_Location__c tenderLocation;
        private final Map<String, Double> UNIT_OF_MEASURE_TO_USG_FACTORS = new Map<String, Double>{
            'USG' => 1,
            'LT' => 0.264172,
            'MT' => 330.215,
            'CM' => 264.1721,
            'KG' => 0.33
        };

        /**
         * @description locationswrapper overloaded constructor
        */
        public LocationsWrapper(AITM_Tender_Location__c tenderLocation) {
            this.tenderLocation = tenderLocation;
            this.country = tenderLocation.AITM_Country__c;
            this.IATA = tenderLocation.AITM_IATA_ICAO__c;
            this.locationName = tenderLocation.AITM_Location__r.Name;
            this.locationGroup = tenderLocation.AITM_Location__r.AITM_Location_Group__c;
            //this.netGross = tenderLocation.AITM_Measure__c; 
            this.duration = getDuration(tenderLocation.AITM_Tender__r.AITM_Start_Date__c, tenderLocation.AITM_Tender__r.AITM_End_Date__c);
            //this.product = AITM_BaseUtils.getProductDescription(tenderLocation.AITM_Product__c);
            this.tenderUom = tenderLocation.AITM_Tender__r.AITM_Unit_Of_Measure__c;
            if (tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c != null) {
                this.totalVolume = (tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c  / UNIT_OF_MEASURE_TO_USG_FACTORS.get(tenderUom)).round(system.roundingMode.HALF_UP);
            }

            this.lineItems = new List<LocationsLineItemWrapper>();           
            this.lineItemsMap = new map<Id, List<LocationsLineItemWrapper>>();
            this.mdDlPoint = new map<id, AITM_Delivery_Point__c>();
            for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocation.AITM_Tender_Location__r) {
                lineItem.AITM_Offered_Volume__c = (lineItem.AITM_Offered_Volume__c!= null?(lineItem.AITM_Offered_Volume__c / UNIT_OF_MEASURE_TO_USG_FACTORS.get(lineItem.AITM_Requested_Volume_UoM__c)).round(system.roundingMode.HALF_UP):null);
                this.lineItems.add(new LocationsLineItemWrapper(lineItem));
                
                if(lineItem.AITM_Location_Delivery_Point__c != null) {
                   if(lineItemsMap.containsKey(lineItem.AITM_Location_Delivery_Point__c)) {
                       lineItemsMap.get(lineItem.AITM_Location_Delivery_Point__c).add(new LocationsLineItemWrapper(lineItem));
                   } else {
                       lineItemsMap.put(lineItem.AITM_Location_Delivery_Point__c,new LocationsLineItemWrapper[]{new LocationsLineItemWrapper(lineItem)});
                   }

                   mdDlPoint.put(lineItem.AITM_Location_Delivery_Point__c, lineItem.AITM_Location_Delivery_Point__r);
               }
            }

            //this.taxesAndFees = tenderLocation.AITM_Taxes_Fees__c;
            //this.additionalNotes = tenderLocation.AITM_Additional_Notes__c;
            this.includeInRevisedOffer = tenderLocation.AITM_Include_In_Revised_Offer__c;
            
            this.deliveryServices = tenderLocation.AITM_Service_Level__c;
            this.aircraftType = tenderLocation.AITM_Aircraft_Type__c;
            this.locationDuration = setLocationDuration(tenderLocation.AITM_Tender__r.AITM_Start_Date__c, tenderLocation.AITM_Tender__r.AITM_End_Date__c);
            this.deliveryMethod = tenderLocation.AITM_Delivery_Method__c;
            this.serviceLevel = tenderLocation.AITM_Service_Level__c;

            this.clearValuesIfPricingBasisIsNotRepresented();
        }

        /**
         * @description returns true if it contains additionalservices
         * @param  null
         * @return boolean
        */
        public Boolean getAdditionalServicesAvailable() {
            return ADDITIONAL_SERVICES_LEVELS.contains(this.deliveryServices);
        }

        /**
         * @description returns number of days duration between two dates
         * @param  start of type date
         * @param  dateOver of type date
         * @return string the number of days between start and dateover
        */
        private String getDuration(Date start, Date dateOver) {
            return String.valueOf(start.daysBetween(dateOver) + 1) + ' days duration';
        }

        /**
         * @description returns string format location duration i.e. startDate and endDate
         * @param  startDate of type date
         * @param  endDate of type date
         * @return string format of locationDuration
        */
        private String setLocationDuration(Date startDate, Date endDate) {
            String result = '';
            if (startDate != null && endDate != null) {
                result = startDate.format() + ' to ' + endDate.format();
            }
            return result;
        }

        /**
         * @description returns true if status is equal to 'Not Represented' else false
         * @param  tenderLocation of type AITM_Tender_Location__c
         * @return boolean if status is equal to 'Not Represented' with value true else false
        */
        public Boolean isNotRepresented(AITM_Tender_Location__c tenderLocation) {
            return tenderLocation.AITM_Status__c == 'Not Represented';
        }

        /**
         * @description resets the value of variables if status of tenderlocation is 'Not Represented'
         * @param  null
         * @return void
        */
        private void clearValuesIfPricingBasisIsNotRepresented() {
            if(this.isNotRepresented(this.tenderLocation)){
                this.duration = '';
                //this.product = '';
                this.totalVolume = 0;
                this.tenderUom = '';
                //this.taxesAndFees = '';
                //this.additionalNotes = '';
                this.deliveryServices = '';
                this.aircraftType = '';
                this.locationDuration = '';
                this.deliveryMethod = '';
                this.serviceLevel = '';
            }
        }
    }

    /**
      * @description LocationsLineItemWrapper inner class
    */
    public class LocationsLineItemWrapper {
        public String customerName {get; private set;}
        public String volume {get; private set;}
        public String locationType {get; private set;}
        public Boolean adHocVolume {get; private set;}
        public String product {get; private set;}
        public String deliveryPoint {get; private set;}
        public String fuelProviderServiceArea {get; private set;}
        public String airportIntoPlaneProviderBulkName {get; private set;}
        public String pricingBasis {get; private set;}
        public String pricingBasisDesc {get; private set;}
        public String startDate {get; private set;}
        public String endDate {get; private set;}
        public String invoiceFrequency {get; private set;}
        public String lineItemCurrency {get; private set;}
        public String unitOfMeasure {get; private set;}
        public String requestedUom {get; private set;}
        public String taxesAndFees {get; private set;}
		public Boolean isNonRepresentedLocation {get; private set;}
        public Boolean selectToApplyOldTaxFees {get; private set;}
        public String additionalNotes{get; private set;}
        public String netGross { get; private set;}
        public String deliveryMethod {get; private set;}
        //public String delivery {get; private set;}
        public String creditDays {get; private set;}
        public Decimal differential {get; private set;}
        public String duration {get; private set;}
        private AITM_Tender_Location_Line_Item__c lineItem;
        public List<AITM_Tender_Location_Taxes_and_Fees__c> tendLocTaxFees {get; private set;}
        public List<AITM_Tender_Location_Taxes_and_Fees__c> tendLocTaxFeesOptional {get; private set;}
        
        /**
         * @description LocationsLineItemWrapper overloaded constructor
        */
        public LocationsLineItemWrapper(AITM_Tender_Location_Line_Item__c lineItem) {
            tendLocTaxFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
            tendLocTaxFeesOptional = new List<AITM_Tender_Location_Taxes_and_Fees__c>(); 
            this.lineItem = lineItem;
            this.customerName = lineItem.AITM_Account__r.Name;
            if (lineItem.AITM_Offered_Volume__c != null) {
                this.volume = this.getVolume(lineItem);
                this.locationType = lineItem.AITM_Offered_Volume__c.format() + '/'  + lineItem.AITM_Duration__c;
            }
            if(!lineitem.AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c) {
                /* Added by Thanuja for New T&F to Differentiate Compulsory & Conditional in Offer Document */
                if(locationTaxesFeesMap.containsKey(lineitem.Id)){
                    for(AITM_Tender_Location_Taxes_and_Fees__c comp: locationTaxesFeesMap.get(lineitem.Id)){
                        if(comp.AITM_Compulsory_Conditional__c == 'Mandatory' || comp.AITM_Compulsory_Conditional__c =='Compulsory'){
                            tendLocTaxFees.add(comp);
                        }
                        else
                            tendLocTaxFeesOptional.add(comp);
                    }
                 } 
               				 
                 /* End Thanuja Changes */
            }
            
            
            this.startDate = (lineItem.AITM_Start_Date__c != null) ? lineItem.AITM_Start_Date__c.format() : '';
            this.endDate = (lineItem.AITM_End_Date__c != null) ? lineItem.AITM_End_Date__c.format() : '';
            //this.product = AITM_BaseUtils.getProductDescription(lineItem.AITM_Tender_Location__r.AITM_Product__c);
            this.product = lineItem.AITM_Product_Default__c;//AITM_BaseUtils.getProductDescription(lineItem.AITM_Product_Density_for_Pricing__c);
            this.adHocVolume = lineItem.AITM_Ad_hoc_Volume__c;
            this.deliveryPoint = lineItem.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c;
            this.fuelProviderServiceArea = lineItem.AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c;
            this.airportIntoPlaneProviderBulkName = lineItem.AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c;
            this.pricingBasis = lineItem.AITM_Pricing_Basis__r.Name;
            this.pricingBasisDesc = lineItem.AITM_Pricing_Basis_Description__c;
            this.invoiceFrequency = lineItem.AITM_Invoice_Frequency__c;
            this.lineItemCurrency = (lineItem.AITM_Currency__c == 'USX' ? 'USC' : lineItem.AITM_Currency__c);
            this.unitOfMeasure = lineItem.AITM_Unit_Of_Measure__c;
            this.requestedUom = lineItem.AITM_Requested_Volume_UoM__c;
            this.creditDays = (lineItem.AITM_Credit_Days__c == null ? '' : lineItem.AITM_Credit_Days__c);
            this.taxesAndFees = formatTaxesAndFees(lineItem.AITM_Taxes_Fees__c);
			this.isNonRepresentedLocation = isPricingBasisNotRepresented(lineItem);
            this.deliveryMethod = lineItem.AITM_Delivery_Method__c;
            this.additionalNotes = lineItem.AITM_Additional_Notes_Taxes_and_Fees__c;
            this.selectToApplyOldTaxFees = lineitem.AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c;
            this.netGross = lineItem.AITM_Measure__c;
            this.duration = getDuration(lineItem.AITM_Start_Date__c, lineItem.AITM_End_Date__c);
            if (lineItem.AITM_Pricing_Basis__r.AITM_Type__c == 'C' && lineItem.AITM_Current_Value__c != null) {
                this.differential = lineItem.AITM_Current_Value__c.setScale(2);
                this.pricingBasisDesc += '. See the Diff. column for current Price.';
            } else if (lineItem.AITM_Offered_Differential__c != null){
                this.differential = lineItem.AITM_Offered_Differential__c.setScale(2);
            } 

            this.clearValuesIfPricingBasisIsNotRepresented();
        }
        
        public String formatTaxesAndFees(String taxesAndFees) {
           if(taxesAndFees != null) {
               taxesAndFees = taxesAndFees.replaceAll('\r','');
           } else {
               taxesAndFees = '';
           }
           return taxesAndFees;
       }
        
       /* Added getTenderTaxesAndFees by Thanuja for New T&F */ 
       public List<AITM_Tender_Location_Taxes_and_Fees__c> getTenderTaxesAndFees(AITM_Tender_Location_Line_Item__c lineItem) {
           return [select name,AITM_Value__c,AITM_Display_Currency__c,AITM_Unit_of_measure__c,AITM_Compulsory_Conditional__c
                                   from AITM_Tender_Location_Taxes_and_Fees__c 
                                   where AITM_Select_to_Apply_in_Contract__c = TRUE AND AITM_Record_Type_Name__c = 'Default' 
                                   AND Tender_Location_Line_Item_Id__c =: lineItem.Id];
       } 
        

        /**
         * @description returns true if tenderlocationlineitem pricingbasisnotrepresented value is true 
         * and recordtype matches with TLLI_ID_RECORD_TYPE_DEFAULT
         * @param  lineItem of type AITM_Tender_Location_Line_Item__c
         * @return boolean
        */
        public Boolean isPricingBasisNotRepresented(AITM_Tender_Location_Line_Item__c lineItem) {
            return lineItem.RecordTypeId == TLLI_ID_RECORD_TYPE_DEFAULT && lineItem.AITM_Is_Pricing_Basis_Not_Represented__c;
        }

        /**
         * @description resets the value of variables if status of tenderlocation is 'Not Represented'
         * @param  null
         * @return void
        */
        private void clearValuesIfPricingBasisIsNotRepresented() {
            if(this.isPricingBasisNotRepresented(this.lineItem)){
                this.volume = '';
                this.locationType = '';
                this.startDate = '';
                this.endDate = '';
                this.product = '';
                this.pricingBasis = '';
                this.invoiceFrequency = '';
                this.deliveryPoint = '';
                this.creditDays = '';
                this.duration = '';
                this.differential = null;
                this.netGross = '';
                this.taxesAndFees = '';
                this.additionalNotes = '';
                this.deliveryMethod = '';
            }
        }

        /**
         * @description returns number of days duration between two dates
         * @param  start of type date
         * @param  dateOver of type date
         * @return string the number of days between start and dateover
        */
        private String getDuration(Date start, Date dateOver) {
            return (start != null && dateOver != null) ? String.valueOf(start.daysBetween(dateOver) + 1) + ' days duration' : '';
        }

        /**
         * @description returns the volume of tenderlocationlineitem
         * @param  lineItem of type AITM_Tender_Location_Line_Item__c
         * @return string format of tenderlocationlineitem volume
        */
        private String getVolume(AITM_Tender_Location_Line_Item__c lineItem) {
            String returnString = '';
            if (lineItem.AITM_Percentage_Volume_Offered__c < 100) {
                returnString = Label.AITM_Flag_Requested_Volume;
                returnString = returnString.replace('[[OFFERED VOLUME]]', lineItem.AITM_Offered_Volume__c.format());
                returnString = returnString.replace('[[REQUESTED VOLUME]]', lineItem.AITM_Volume__c.format());
                returnString = returnString.replace('[[UNIT]]', lineItem.AITM_Requested_Volume_UoM__c);
            } else {
                returnString = lineItem.AITM_Offered_Volume__c.format();
            }
            return returnString;
        }
    }
}