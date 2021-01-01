/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    To generate Tender Contract PDF (attachments).

 * history
 * 01/December/2017  George       Created 
 * 05/March/2018   Anusha     AR-2542 Updated the Bank account details instead of contracting entity Bank details
 * 07/March/2018   srnandan   Added comments for each method as per coding standards
 * 17/May/2018     Anusha     Modified - AR-3169 - Modified the methods populateAccountFields,
 *                            populateTenderAccountFields replacing field AITM_Days__c to AITM_Credit_Days__c
 * 28/May/2018     srnandan   Modified - AR- 3179 - Modified the method LocationsWrapper added the 
 *                            field AITM_Delivery_Method__c and assigned to variable deliveryMethod
 * 29/May/2018     srnandan   Modified - AR-3245 - added conditional formatting for currentvalue 
 *                            and offereddifferential assignments
 * 29/May/2018     srnandan   Modified - AR-3161 - Included AITM_Ad_Hoc_Volume__c in soql for the methods
 *                            getTenderLocationsWithChilds and getFilteredTenderLocationLineItems
 * 30/May/2018     Ravi       Modified - AR-3240 - Updated currency field from Tender to Tender Account AITM_Payment_Currency__c
 * 15/June/2018    srnandan   Modified - AR-3522 - Condition check to display currency USX to USC
 * 15/June/2018    srnandan   Modified - AR-3363 - Changed the datatype of differential to decimal and setscale to 2
 * 13/July/2018    Anusha     Modified - AR-3705 - Condition to display See the differential value on Current Price
 * 23/July/2018    Shweta     Modified - AR-3783 - Modified the method getvolume to return only offered volume.Removed the statement
 * 27/July/2018    Anusha     Modified - AR-3892 - Modified the method getvolume to return offered Volume converted to Requested UOM
 * 23/August/2018  Ravi       Modified - AR-4139 - Updated methods LocationsWrapper to add null check and 
 *                            updated Product in same method with getProductDescription
 * 04/October/2018 Ravi       Modified - AR-4355 - Modified getContractPageReference method for Bespoke Contract generation
 * 11/Dec/2018     Ravi       Modified - AR-4626 - added Delivery Point related to TLLI to show Location Delivery Point fields in Offer PDF Table
 * 12/December/2018  srnandan Modified - AR-4791 - show legal entity address if legal entity present else accounting details address
 * 26/December/2018  Anusha   Modified - AR-2745 - Reseller paragraph will be shown if Account classification consists of CA and GA REseller
 * 02/Jan/2019       Ravi     Modified - AR-4626 - updated Delivery Point related Locations to display in Contract PDF
 * 23/January/2019   srnandan Modified - AR-4913 - updated TLLI wrapper to get taxes and fees from TLLI
 * 18/February/2019  srnandan Modified - AR-2745 - added new methods getResellerPageReference, createResellerAppendix and modified
 *                            method generatePDF for reseller appendix4 generation  
 * 27/March/2019     Ravi     Modified - AR-5111 updated MT conversion
 * 01/April/2019     Ravi     Modified - AR-5115 to update getBaseTenderLocations method populating Affiliates Account related locations in Contract generation
 * 24/April/2019     srnandan Modified - AR-XXXX removed comments from tenderlocation to display setting as blank as per request from sean and chris
 * 12/May/2019       srnandan Modified - AR-5190 Corrected the postalcode mapping and added getAffiliates method
 * 15/May/2019       srnandan Modified - AR-5190 modified the method getBaseTenderLocations for affiliates logic
 * 25/May/2019       srnandan Modified - AR-5029 Changed product mapping from tender location to line item
 * 13/June/2019      srnandan Modified - AR-xxxx Affiliates prod issue fix
 * 15/Nov/2019       srnandan     Modified - added logic to by pass taxes and fees records gathering for old tender taxes and fees
 ****************************************************************************/
public without sharing class AITM_TenderContractPDFController  {

    private final static String RECURSION_PARAM_NAME = 'recparam';

    public static ContractWrapper contractInstance {get; set;}
    public static List<LocationsWrapper> locations {get; set;}
    public static Transient Map<Id, List<AITM_Tender_Location_Taxes_and_Fees__c>> locationTaxesFeesMap = New Map<Id, List<AITM_Tender_Location_Taxes_and_Fees__c>>();
    public static Id tenderId;
    public static AITM_Tender__c tenderRecord;
    /**
     * @description default constructor
     */
    public AITM_TenderContractPDFController() {}

    /**
     * @description overloaded constructor
     * @param controller of type ApexPages.StandardController
     */
    public AITM_TenderContractPDFController(ApexPages.StandardController controller) {
        GenerationDTO generationDataTrasferObject = buildGenerationDTO();
        tenderRecord = (AITM_Tender__c)controller.getRecord();
        tenderId = tenderRecord.Id;
        if (generationDataTrasferObject.consistent()) {
            locationTaxesFeesMap = getLocationTaxesAndFees();
            contractInstance = new ContractBuilder(generationDataTrasferObject).build();
            locations = new LocationsBuilder(generationDataTrasferObject).build();
        }
    }

     /**
         * @description gets location taxes and fees based on line item 
         * @param no parameter
         * @return Map of line item id and list of Location taxes and fees
        */
       public Map<Id, List<AITM_Tender_Location_Taxes_and_Fees__c>> getLocationTaxesAndFees() {
            Transient List<AITM_Tender_Location_Taxes_and_Fees__c> taxesFeesList = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
            Transient List<AITM_Tender_Location_Taxes_and_Fees__c> taxesFeesListold = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
            //taxesFeesListold =getTenderTaxesAndFees(tenderId);
            
            for(AITM_Tender_Location_Taxes_and_Fees__c taxFee: [select name,AITM_Value__c,AITM_Display_Currency__c,AITM_Unit_of_measure__c,Tender_Location_Line_Item_Id__c,AITM_Compulsory_Conditional__c from AITM_Tender_Location_Taxes_and_Fees__c where AITM_Select_to_Apply_in_Contract__c = TRUE AND Tender_Location_Line_Item_Id__r.AITM_Tender__c =: tenderId]){
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
     * @description adds attachment
     * @param null
     * @return null
     */
    public static void addAttachment() {
        if (recursionParameterNotCalled()) {
            GenerationDTO generationDataTrasferObject = buildGenerationDTO();
            if (generationDataTrasferObject.consistent()) {
                AITM_TenderContractPDFController.generateContract(generationDataTrasferObject);
            }
        }
    }

    /**
     * @description gets additional service available
     * @param null
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
     * @description gets additional service available
     * @param null
     * @return boolean
     */
    public static void generateContract(GenerationDTO generationDataTrasferObject) {
        PDFGenerator generator = new PDFGenerator(generationDataTrasferObject);
        generator.generatePDF();
    }

    /**
     * @description gets additional service available
     * @param null
     * @return boolean
     */
    private static GenerationDTO buildGenerationDTO() {
        GenerationDTO generationDataTrasferObject = new GenerationDTO();
        if (allGenerationParamsAreSet()) {
            generationDataTrasferObject.tenderId = Id.valueOf(getPageParameter('id'));
            generationDataTrasferObject.customerId = Id.valueOf(getPageParameter('customerId'));
            generationDataTrasferObject.bespoke = AITM_TenderContractContainerController.getBeSpokeTemplate(generationDataTrasferObject.customerId);
        }
        return generationDataTrasferObject;
    }

    /**
     * @description gets additional service available
     * @param null
     * @return boolean
     */
    private static Boolean allGenerationParamsAreSet() {
        return getPageParameter('id') != null && getPageParameter('customerId') != null;
    }

    /**
     * @description gets additional service available
     * @param null
     * @return boolean
     */
    private static String getPageParameter(String parameterName) {
        return ApexPages.currentPage().getparameters().get(parameterName);
    }

    /**
     * @description gets additional service available
     * @param null
     * @return boolean
     */
    private static Boolean recursionParameterNotCalled() {
        return !ApexPages.currentPage().getparameters().containsKey(RECURSION_PARAM_NAME);
    }

    /**
     * @description inner wrapper class GenerationDTO
     */
    public class GenerationDTO {
        public Id tenderId;
        public Id customerId;
        public String bespoke;

        /**
         * @description returns true if both tenderid and customerid not null
         * @param null
         * @return boolean
         */
        public Boolean consistent() {
            return this.tenderId != null && this.customerId != null;
        }
    }

    /**
     * @description inner wrapper class PDFGenerator
     */
    public class PDFGenerator {
        private GenerationDTO generationDataTrasferObject;

        /**
         * @description overloaded constructor
         * @param generationDataTrasferObject of type GenerationDTO
         */
        public PDFGenerator(GenerationDTO generationDataTrasferObject) {
            this.generationDataTrasferObject = generationDataTrasferObject;
        }

        /**
         * @description checks is legal document
         * @param null
         * @return boolean
         */
        public Boolean isLegalDocument() {
            return !generationDataTrasferObject.consistent();
        }

        /**
         * @description generates pdf
         * @param null
         * @return null
         */
        public void generatePDF() {
            if (generationDataTrasferObject.consistent()) {
                PageReference contractPage = this.getContractPageReference();
                this.createContract(contractPage);
                PageReference resellerPage = this.getResellerPageReference();
                this.createResellerAppendix(resellerPage);
            }
        }
        
        /**
         * @description returns page reference of AITM_TenderOfferPDF page
         * @param  null
         * @return PageReference of AITM_TenderOfferPDF page
         */
        private PageReference getResellerPageReference() {
            PageReference resellerPDFPage = Page.AITM_ContractGAAppendix4;
            resellerPDFPage.getParameters().put('id', this.generationDataTrasferObject.tenderId);
            resellerPDFPage.getParameters().put('customerId', this.generationDataTrasferObject.customerId);
            resellerPDFPage.getParameters().put(RECURSION_PARAM_NAME, 'true');
            return resellerPDFPage;
        }
        
        /**
         * @description gets contract page reference
         * @param null
         * @return PageReference
         */
        private PageReference getContractPageReference() {
            PageReference contractPDFPage;
            
            switch on this.generationDataTrasferObject.bespoke {
                when 'AITM_Contract2015PDF' {
                    contractPDFPage = Page.AITM_Contract2015PDF;
                }
                when 'AITM_ContractAirSerbia' {
                    contractPDFPage = Page.AITM_ContractAirSerbia;
                }
                when 'AITM_ContractBLX' {
                    contractPDFPage = Page.AITM_ContractBLX;
                }
                when 'AITM_ContractChinaEast' {
                    contractPDFPage = Page.AITM_ContractChinaEast;
                }
                when 'AITM_ContractEAT' {
                    contractPDFPage = Page.AITM_ContractEAT;
                }
                when 'AITM_ContractEtihad' {
                    contractPDFPage = Page.AITM_ContractEtihad;
                }
                when 'AITM_ContractGAMA' {
                    contractPDFPage = Page.AITM_ContractGAMA;
                }
                when 'AITM_ContractGASORT' {
                    contractPDFPage = Page.AITM_ContractGASORT;
                }
                when 'AITM_ContractGMI' {
                    contractPDFPage = Page.AITM_ContractGMI;
                }
                when 'AITM_ContractJetSys' {
                    contractPDFPage = Page.AITM_ContractJetSys;
                }
                when 'AITM_ContractL' {
                    contractPDFPage = Page.AITM_ContractL;
                }
                when 'AITM_ContractLH' {
                    contractPDFPage = Page.AITM_ContractLH;
                }
                when 'AITM_ContractLH16' {
                    contractPDFPage = Page.AITM_ContractLH16;
                }
                when 'AITM_ContractLOT' {
                    contractPDFPage = Page.AITM_ContractLOT;
                }
                when 'AITM_ContractMY' {
                    contractPDFPage = Page.AITM_ContractMY;
                }
                when 'AITM_ContractNAU' {
                    contractPDFPage = Page.AITM_ContractNAU;
                }
                when 'AITM_ContractSORT' {
                    contractPDFPage = Page.AITM_ContractSORT;
                }
                when 'AITM_ContractTC' {
                    contractPDFPage = Page.AITM_ContractTC;
                }
                when 'AITM_ContractVA' {
                    contractPDFPage = Page.AITM_ContractVA;
                }
                when 'AITM_ContractQatar' {
                    contractPDFPage = Page.AITM_ContractQatar;
                }
                when else {
                    contractPDFPage = Page.AITM_TenderContractPDF;
                }
            }

            contractPDFPage.getParameters().put('id', this.generationDataTrasferObject.tenderId);
            contractPDFPage.getParameters().put('customerId', this.generationDataTrasferObject.customerId);
            contractPDFPage.getParameters().put(RECURSION_PARAM_NAME, 'true');
            return contractPDFPage;
        }

        /**
         * @description creates contract
         * @param pdfPage of type PageReference
         * @return null
         */
        private void createContract(PageReference pdfPage) {
            AITM_Tender__c tenderRecord = new AITM_TenderDao().getTender(this.generationDataTrasferObject.tenderId);
            AITM_Tender_Account__c tenderAccount = new AITM_AccountDao.TenderAccountDao().getTenderAccountWithOfferInformation(this.generationDataTrasferObject.customerId);

            Blob fileBody;
            if (!Test.isRunningTest()) {
                fileBody = pdfPage.getContent();
            } else {
                fileBody = Blob.valueOf('Test Document');
            }
            ContentVersion contractFile = AITM_BaseUtils.createContentVersion(fileBody, Label.AITM_NewContractPDFContractPrefix + Date.today().format() + ':' + tenderRecord.Name + ':' + tenderAccount.AITM_Account__r.Name + '.pdf');
            AITM_BaseUtils.createChatterPostToRelate(Label.AITM_NewContractPDFContractChatterText, this.generationDataTrasferObject.tenderId, contractFile.Id);
        }
        
        /**
         * @description creates reseller appendix4 pdf
         * @param pdfPage of type PageReference
         * @return null
         */
        private void createResellerAppendix(PageReference pdfPage) {
            AITM_Tender__c tenderRecord = new AITM_TenderDao().getTender(this.generationDataTrasferObject.tenderId);
            AITM_Tender_Account__c tenderAccount = new AITM_AccountDao.TenderAccountDao().getTenderAccountWithOfferInformation(this.generationDataTrasferObject.customerId);
            if(tenderAccount.AITM_Account_Classification__c == 'CA Reseller' || tenderAccount.AITM_Account_Classification__c == 'GA Reseller') {
                Blob fileBody;
                if (!Test.isRunningTest()) {
                    fileBody = pdfPage.getContent();
                } else {
                    fileBody = Blob.valueOf('Test Document');
                }
                ContentVersion contractFile = AITM_BaseUtils.createContentVersion(fileBody, Label.AITM_NewContractPDFAppendix4Prefix + Date.today().format() + ':' + tenderRecord.Name + ':' + tenderAccount.AITM_Account__r.Name + '.pdf');
                AITM_BaseUtils.createChatterPostToRelate(Label.AITM_NewContractPDFAppendix4ChatterText, this.generationDataTrasferObject.tenderId, contractFile.Id);
            }
        }
    }

    /**
     * @description inner wrapper class contract builder object
     */
    public class ContractBuilder {
        private GenerationDTO generationDataTrasferObject;

        /**
         * @description overloaded constructor
         * @param generationDataTrasferObject of type GenerationDTO
         */
        public ContractBuilder(GenerationDTO generationDataTrasferObject) {
            this.generationDataTrasferObject = generationDataTrasferObject;
        }

        /**
         * @description builds contract wrapper
         * @param null
         * @return ContractWrapper
         */
        public ContractWrapper build() {
            AITM_Tender_Account__c tenderAccount = new AITM_AccountDao.TenderAccountDao().getTenderAccountWithOfferInformation(this.generationDataTrasferObject.customerId);
            return new ContractWrapper(tenderAccount);
        }
    }

    /**
     * @description inner wrapper class LocationBuilder object
     */
    public class LocationsBuilder {
        private GenerationDTO generationDataTrasferObject;

        /**
         * @description overloaded constructor
         * @param generationDataTrasferObject of type GenerationDTO
         */
        public LocationsBuilder(GenerationDTO generationDataTrasferObject) {
            this.generationDataTrasferObject = generationDataTrasferObject;
           
        }

        /**
         * @description build location wrapper
         * @param null
         * @return List<LocationsWrapper>
         */
        public List<LocationsWrapper> build() {
            List<LocationsWrapper> locations = new List<LocationsWrapper>();
            Id parentAccountId = new AITM_AccountDao.TenderAccountDao().getTenderAccountWithOfferInformation(this.generationDataTrasferObject.customerId).AITM_Account__c;
            locations = this.getBaseTenderLocations(this.generationDataTrasferObject.tenderId, parentAccountId);
            return locations;
        }

        /**
         * @description gets base tender locations
         * @param tenderId of type Id
         * @param accountId of type Id
         * @return List<LocationsWrapper>
         */
        private List<LocationsWrapper> getBaseTenderLocations(Id tenderId, Id accountId) {
            List<LocationsWrapper> locations = new List<LocationsWrapper>();
            Map<Id,String> affiliates =  new AITM_AccountDao.TenderAccountDao().getAffiliatesMap(accountId, tenderId);
            if(!affiliates.isEmpty()){
                Set<Id> accountIds = new Set<Id>();
                accountIds.addAll(affiliates.keySet());
                accountIds.add(accountId);
                for(AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getPricedTenderLocationsForAContract(tenderId, accountIds)) {
                    locations.add(new LocationsWrapper(tenderLocation));
                }
            } else{
                  for(AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getPricedTenderLocationsForAContract(tenderId, accountId)) {
                    locations.add(new LocationsWrapper(tenderLocation));
                }
            }
            return locations;
        }
    }

    /**
     * @description inner wrapper class to store Contract details
     */
    public class ContractWrapper {
        public Date contractDate {get; private set;}
        public String legalName {get; private set;}
        public String legalCountry {get; private set;}
        public String legalAddress {get; private set;}
        public String customerName {get; private set;}
        public String customerCountry {get; private set;}
        public String customerAddress {get; private set;}
        public String contractInstanceCurrency {get; private set;}
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
         * @description overloaded constructor
         * @param tenderAccount of type AITM_Tender_Account__c
         */
        public ContractWrapper(AITM_Tender_Account__c tenderAccount) {
            this.contractDate = Date.today();
            this.legalName = tenderAccount.AITM_Contracting_Entity__r.Name;
            this.legalCountry = tenderAccount.AITM_Contracting_Entity__r.AITM_Country__c;
            this.legalAddress = tenderAccount.AITM_Contracting_Entity__r.AITM_Address__c;
            this.customerName = tenderAccount.AITM_Account__r.Name;
            this.customerCountry = tenderAccount.AITM_Account__r.BillingCountry;
            this.customerAddress = buildCustomerAddress(tenderAccount);
            this.contractInstanceCurrency = (tenderAccount.AITM_Payment_Currency__c == 'USX' ? 'USC' : tenderAccount.AITM_Payment_Currency__c);
            this.bankNumber = tenderAccount.AITM_Bank_Account__r.AITM_Bank_Account_Number__c;
            this.bankIBAN = tenderAccount.AITM_Bank_Account__r.AITM_Bank_IBAN_Number__c;
            this.bankName = tenderAccount.AITM_Bank_Account__r.Name;
            this.bankAddress = tenderAccount.AITM_Bank_Account__r.AITM_Bank_Address__c;
            this.bankCity = tenderAccount.AITM_Bank_Account__r.AITM_Bank_City__c;
            this.creditTerms = tenderAccount.AITM_Security_Text_on_Offer__c;
            //this.affiliates = tenderAccount.AITM_Affiliates_Account__r.Name;
            this.affiliates = new AITM_AccountDao.TenderAccountDao().getAffiliates(tenderAccount.AITM_Account__c, tenderAccount.AITM_Tender__c);//tenderAccount.AITM_Affiliates_Account__r.Name;
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
         * @description builds customer address
         * @param tenderAccount of type AITM_Tender_Account__c
         * @return string
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
     * @description inner wrapper class LocationsWrapper to store location details
     */
    public class LocationsWrapper {
        public String IATA {get; private set;}
        public String locationName {get; private set;}
        public String locationGroup {get; private set;}
        public String product {get; private set;}
        public String comments {get; private set;}

        public map<id, List<LocationsLineItemWrapper>> lineItemsMap {get; private set;}
        public map<id, AITM_Delivery_Point__c> mdDlPoint {get;set;}

        public String deliveryServices {get; private set;}
        //public String netGross {get; private set;}
        public String aircraftType {get; private set;}
        public String duration {get; private set;}
        //public String taxesAndFees {get; private set;}
        //public String additionalNotes {get; private set;}
        //public String deliveryMethod {get; private set;}
        //public Boolean includeTaxesFees {get; private set;}
        //public Boolean includeAdditionalNotes {get; private set;}
        private final Map<String, Double> UNIT_OF_MEASURE_TO_USG_FACTORS = new Map<String, Double>{
            'USG' => 1,
            'LT' => 0.264172,
            'MT' => 330.215,
            'CM' => 264.1721,
            'KG' => 0.33
        };

        public List<LocationsLineItemWrapper> lineItems {get; private set;}
        private final Set<String> ADDITIONAL_SERVICES_LEVELS = new Set<String>{'Level II', 'Level III'};

        /**
         * @description overloaded constructor
         * @param tenderLocation of type AITM_Tender_Location__c
         */
        public LocationsWrapper(AITM_Tender_Location__c tenderLocation) {
            this.IATA = tenderLocation.AITM_IATA_ICAO__c;
            this.locationName = tenderLocation.AITM_Location__r.Name;
            this.locationGroup = tenderLocation.AITM_Location__r.AITM_Location_Group__c;

            this.lineItemsMap = new map<Id, List<LocationsLineItemWrapper>>();
            this.mdDlPoint = new map<id, AITM_Delivery_Point__c>();
            
            this.lineItems = new List<LocationsLineItemWrapper>();
            
            for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocation.AITM_Tender_Location__r) {
               if(lineItem.AITM_Offered_Volume__c != null) {
                  lineItem.AITM_Offered_Volume__c = (lineItem.AITM_Offered_Volume__c / UNIT_OF_MEASURE_TO_USG_FACTORS.get(lineItem.AITM_Requested_Volume_UoM__c)).round(system.roundingMode.HALF_UP);
               }
               this.lineItems.add(new LocationsLineItemWrapper(lineItem));
                if(lineItem.AITM_Location_Delivery_Point__c != null) {
                if(!lineItemsMap.isEmpty() && lineItemsMap.containsKey(lineItem.AITM_Location_Delivery_Point__c)){
                    lineItemsMap.get(lineItem.AITM_Location_Delivery_Point__c).add(new LocationsLineItemWrapper(lineItem));
                } else {
                    lineItemsMap.put(lineItem.AITM_Location_Delivery_Point__c,new LocationsLineItemWrapper[]{new LocationsLineItemWrapper(lineItem)});
                }
                mdDlPoint.put(lineItem.AITM_Location_Delivery_Point__c, lineItem.AITM_Location_Delivery_Point__r);
              }
            }

            this.comments = '';//tenderLocation.AITM_Comments__c;
            this.deliveryServices = tenderLocation.AITM_Service_Level__c;
            //this.netGross = tenderLocation.AITM_Measure__c;
            this.aircraftType = tenderLocation.AITM_Aircraft_Type__c;
            this.duration = setDuration(tenderLocation.AITM_Tender__r.AITM_Start_Date__c, tenderLocation.AITM_Tender__r.AITM_End_Date__c);
            //this.taxesAndFees = tenderLocation.AITM_Taxes_Fees__c;
            //this.additionalNotes = tenderLocation.AITM_Additional_Notes__c;
            //this.includeTaxesFees = tenderLocation.AITM_Include_Taxes_Fees_in_Contract__c;
            //this.includeAdditionalNotes = tenderLocation.AITM_Include_Notes_in_Contract__c;
            //this.deliveryMethod = (tenderLocation.AITM_Delivery_Method__c == null ? '' : tenderLocation.AITM_Delivery_Method__c);
        }

        /**
         * @description gets additional services available
         * @param null
         * @return boolean
         */
        public Boolean getAdditionalServicesAvailable() {
            return ADDITIONAL_SERVICES_LEVELS.contains(this.deliveryServices);
        }

        /**
         * @description sets duration
         * @param startDate of type date
         * @param endDate of type date
         * @return string
         */
        private String setDuration(Date startDate, Date endDate) {
            String result = '';
            if (startDate != null && endDate != null) {
                result = startDate.format() + ' to ' + endDate.format();
            }
            return result;
        }
    }

    /**
     * @description inner wrapper class to store LocationLineItem details
     */
    public class LocationsLineItemWrapper {
        public String customerName {get; private set;}
        public String deliveryPoint {get; private set;}
        public String fuelProviderServiceArea {get; private set;}
        public String airportIntoPlaneProviderBulkName {get; private set;}
        public String volume {get; private set;}
        public String product {get; private set;}
        public String startDate {get; private set;}
        public String endDate {get; private set;}
        public String invoiceFrequency {get; private set;}
        public String netGross {get; private set;}
        public String taxesAndFees { get; private set;}
        public String additionalNotes {get; private set;}
        public Boolean selectToApplyOldTaxFees {get; private set;}
        public Boolean includeTaxesFees {get; private set;}
        //public String delivery {get; private set;}
        public String deliveryMethod {get; private set;}
        public String creditDays {get; private set;}
        public Decimal differential {get; private set;}
        public Boolean adHocVolume {get; private set;}
        public String unitPeriod {get; private set;}
        public String price {get; private set;}
        public String currencyUnit {get; private set;}
        private AITM_Tender_Location_Line_Item__c lineItem;
        public List<AITM_Tender_Location_Taxes_and_Fees__c> tendLocTaxFees {get; private set;}
        public List<AITM_Tender_Location_Taxes_and_Fees__c> tendLocTaxFeesOptional {get; private set;}
        
        /** Added By Thanuja for New T&F
         * @description overloaded constructor
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         */
        public LocationsLineItemWrapper(AITM_Tender_Location_Line_Item__c lineItem) {
            tendLocTaxFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
            tendLocTaxFeesOptional = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
            this.lineItem = lineItem;

            if(!lineitem.AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c) {
               
                   if(locationTaxesFeesMap.containsKey(lineitem.Id)){
                      for(AITM_Tender_Location_Taxes_and_Fees__c comp: locationTaxesFeesMap.get(lineitem.Id)){
                        if(comp.AITM_Compulsory_Conditional__c == 'Mandatory' || comp.AITM_Compulsory_Conditional__c =='Compulsory'){
                            tendLocTaxFees.add(comp);
                        }
                        else
                            tendLocTaxFeesOptional.add(comp);
                        }
                     }   
                
            }
            this.customerName = lineItem.AITM_Account__r.Name;
            this.deliveryPoint = lineItem.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c;
            this.fuelProviderServiceArea = lineItem.AITM_Location_Delivery_Point__r.AITM_Fuel_Provider_Service_Area__c;
            this.airportIntoPlaneProviderBulkName = lineItem.AITM_Location_Delivery_Point__r.AITM_Airport_IntoPlane_Provider_BulkName__c;
            this.volume = this.getVolume(lineItem);
            this.startDate = lineItem.AITM_Start_Date__c == null ? '' : lineItem.AITM_Start_Date__c.format();
            this.endDate = lineItem.AITM_End_Date__c == null ? '' : lineItem.AITM_End_Date__c.format();
            //this.product = AITM_BaseUtils.getProductDescription(lineItem.AITM_Tender_Location__r.AITM_Product__c);
            this.product = lineItem.AITM_Product_Default__c;//AITM_BaseUtils.getProductDescription(lineItem.AITM_Product_Density_for_Pricing__c);
            this.invoiceFrequency = lineItem.AITM_Invoice_Frequency__c;
            this.creditDays = (lineItem.AITM_Credit_Days__c == null ? '' : lineItem.AITM_Credit_Days__c);
            this.taxesAndFees = formatTaxesAndFees(lineItem.AITM_Taxes_Fees__c);
            this.adHocVolume = lineItem.AITM_Ad_hoc_Volume__c;
            this.unitPeriod = lineItem.AITM_Unit_Of_Measure__c == null || this.volume == 'ADHOC' ? '' : lineItem.AITM_Requested_Volume_UoM__c + ' / Year';
            this.price = lineItem.AITM_Pricing_Basis_Description__c;
            this.currencyUnit = (lineItem.AITM_Currency__c == 'USX' ? 'USC' : lineItem.AITM_Currency__c) + ' / ' + lineItem.AITM_Unit_Of_Measure__c;
            if (lineItem.AITM_Pricing_Basis__r.AITM_Type__c == 'C' && lineItem.AITM_Current_Value__c != null) {
                this.differential = lineItem.AITM_Current_Value__c.setScale(2);
                this.price += '. See the Diff. column for current Price.';
            } else if (lineItem.AITM_Offered_Differential__c != null){
                this.differential = lineItem.AITM_Offered_Differential__c.setScale(2);
            }
            this.additionalNotes = lineItem.AITM_Additional_Notes_Taxes_and_Fees__c;
            this.includeTaxesFees = lineItem.AITM_Include_Taxes_and_Fees_in_Contract__c;
            this.selectToApplyOldTaxFees = lineitem.AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c;
            this.netGross = lineItem.AITM_Measure__c;
            this.deliveryMethod= (lineItem.AITM_Delivery_Method__c == null ? '' : lineItem.AITM_Delivery_Method__c);
        }
        
        public String formatTaxesAndFees(String taxesAndFees) {
           if(taxesAndFees != null) {
               taxesAndFees = taxesAndFees.replaceAll('\r','');
           } else {
               taxesAndFees = '';
           }
           return taxesAndFees;
       }
        
        /* Added by Thanuja for New T&F to display in Contract document */
        public List<AITM_Tender_Location_Taxes_and_Fees__c> getTenderTaxesAndFees() {
           return [select name,AITM_Value__c,AITM_Display_Currency__c,AITM_Unit_of_measure__c,AITM_Compulsory_Conditional__c,Tender_Location_Line_Item_Id__r.AITM_Tender__c,
                                    Tender_Location_Line_Item_Id__r.AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c,Tender_Location_Line_Item_Id__r.AITM_Location__c
                                   from AITM_Tender_Location_Taxes_and_Fees__c 
                                 where AITM_Select_to_Apply_in_Contract__c = TRUE 
                                 AND AITM_Record_Type_Name__c = 'De-brief'                               
                                 AND Tender_Location_Line_Item_Id__r.recordType.name = 'De-brief'
                                 AND Tender_Location_Line_Item_Id__r.AITM_Location__c=: lineItem.AITM_Location__c
                                 AND Tender_Location_Line_Item_Id__r.AITM_Account__r.Name=: lineItem.AITM_Account__r.Name
                                 
                                 AND Tender_Location_Line_Item_Id__r.AITM_Tender__c =: Id.valueOf(getPageParameter('id'))];
                                //   AND Tender_Location_Line_Item_Id__c =:lineItem.id];
                                
                                
           
       } 
        
        /* End Thanuja Changes */
        /**
         * @description gets volume details
         * @param lineItem of type AITM_Tender_Location_Line_Item__c
         * @return string
         */
        private String getVolume(AITM_Tender_Location_Line_Item__c lineItem) {
            String returnString = '';                
            returnString = (lineItem.AITM_Offered_Volume__c != null) ? lineItem.AITM_Offered_Volume__c.format() : 'ADHOC';
            return returnString;
        }
        
    }
}