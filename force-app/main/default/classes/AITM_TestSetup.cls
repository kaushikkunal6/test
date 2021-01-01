/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    virtual class holds methods creation of test data

 * history
 * 06/December/2017  George       Created 
 * 02/March/2018     srnandan     Modified - added code comments as per coding standards 
 *                                for class and methods
 * 13/June/2018      srnandan     Modified - change the field assignment AITM_Credit_Days__c to AITM_Credit_Days1__c
 * 02/Oct/2018       srnandan     Added methods CreateGroupAccount and CreateGroupAccounts
 * 23/December/2018  srnandan     Modified method CreateDeliveryPoint
 *************************************************************************/
public with sharing virtual class AITM_TestSetup {
    
    private static final Id CUSTOMER_ACCOUNTING_DETAILS_RECORDTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AITM_Accounting_Details').getRecordTypeId();
    
    /**
     * @description create account record
     * @param null
     * @return Account object
     */
    public Account createAccount() {
        return new Account(
            Name = 'Test Account',
            AITM_GRN__c = '1000000',
            AITM_Credit_Days1__c = '1',
            AITM_Invoice_Frequency__c = 'Daily',
            RecordTypeId = CUSTOMER_ACCOUNTING_DETAILS_RECORDTYPE,
            BillingCountry = 'Spain'    
        );
    }
    
    /**
     * @description create account record
     * @param null
     * @return Account object
     */
    public Account createGroupAccount() {
        return new Account(
            Name = 'Test Group Account',
            RecordTypeId = CUSTOMER_ACCOUNTING_DETAILS_RECORDTYPE
        );
    }
    
    /**
     * @description creates account record
     * @param size of type integer
     * @return List collection of account
     */
    public List<Account> createAccounts(Integer size) {
        List<Account> result = new List<Account>();
        //iteration to create account record and add to list collection 
        for (Integer index = 0; index < size; index++) {
            Account iterationAccount = createAccount();
            iterationAccount.Name += String.valueOf(index);
            iterationAccount.AITM_GRN__c = String.valueOf(1000000 + index);
            iterationAccount.RecordTypeId = CUSTOMER_ACCOUNTING_DETAILS_RECORDTYPE;
            result.add(iterationAccount);
        }
        return result;
    }
    
    /**
     * @description creates group account record
     * @param size of type integer
     * @return List collection of account
     */
    public List<Account> createGroupAccounts(Integer size) {
        List<Account> result = new List<Account>();
        //iteration to create account record and add to list collection 
        for (Integer index = 0; index < size; index++) {
            Account iterationAccount = createGroupAccount();
            iterationAccount.Name += String.valueOf(index);
            iterationAccount.RecordTypeId = CUSTOMER_ACCOUNTING_DETAILS_RECORDTYPE;
            result.add(iterationAccount);
        }
        return result;
    }
    
    /**
     * @description create tender record
     * @param null
     * @return AITM_Tender__c 
     */
    public AITM_Tender__c createTender() {
        return new AITM_Tender__c(
            Name = 'Test Tender',
            AITM_Tender_Sector__c = 'CA',
            AITM_Start_Date__c = Date.today(),
            AITM_End_Date__c = Date.today().addYears(1),
            AITM_Currency__c = 'USD',
            AITM_Unit_Of_Measure__c = 'USG',
            AITM_Bids_In_By__c = Date.today().addYears(1)
        );
    }

    /**
     * @description create tenders record
     * @param size of type Integer
     * @return List collection of AITM_Tender__c 
     */
    public List<AITM_Tender__c> createTenders(Integer size) {
        List<AITM_Tender__c> result = new List<AITM_Tender__c>();
        for (Integer index = 0; index < size; index++) {
            AITM_Tender__c iterationLocation = createTender();
            iterationLocation.Name += String.valueOf(index);
            result.add(iterationLocation);
        }
        return result;
    }

    /**
     * @description create location record
     * @param null
     * @return AITM_Location__c
     */
    public AITM_Location__c createLocation() {
        return new AITM_Location__c(
            Name = 'Test Location',
            AITM_ICAO__c = 'CY',
            AITM_IATA__c = 'Y',
            AITM_Currency__c = 'USD',
            AITM_Unit_Of_Measure__c = 'LT'
        );
    }

    /**
     * @description create locations record
     * @param size of type integer
     * @return List collection of AITM_Location__c
     */
    public List<AITM_Location__c> createLocations(Integer size) {
        List<AITM_Location__c> result = new List<AITM_Location__c>();
        for (Integer index = 0; index < size; index++) {
            AITM_Location__c iterationLocation = createLocation();
            iterationLocation.Name += String.valueOf(index);
            iterationLocation.AITM_IATA__c += String.valueOf(index);
            iterationLocation.AITM_ICAO__c += String.valueOf(index);
            result.add(iterationLocation);
        }
        return result;
    }

    /**
     * @description create tender account record
     * @param tenderId of type Id
     * @param accountId of type Id
     * @return AITM_Tender_Account__c
     */
    public AITM_Tender_Account__c createTenderAccount(Id tenderId, Id accountId) {
        return new AITM_Tender_Account__c(
            AITM_Tender__c = tenderId,
            AITM_Account__c = accountId
        );
    }

    /**
     * @description create tender account record
     * @param tenders of type List collection AITM_Tender__c
     * @param accounts of type List collection Account
     * @return List collection of AITM_Tender_Account__c
     */
    public List<AITM_Tender_Account__c> createTenderAccounts(List<AITM_Tender__c> tenders, List<Account> accounts) {
        List<AITM_Tender_Account__c> result = new List<AITM_Tender_Account__c>();
        for (AITM_Tender__c tender : tenders) {
            for (Account acc : accounts) {
                result.add(createTenderAccount(tender.Id, acc.Id));
            }
        }
        return result;
    }
    /**
     * @description create contact record
     * @param acc of type Account     
     * @return Contact
     */
     public Contact createContact(Account acc) {       
        Contact result = new Contact();
        result.FirstName = 'Test';
        result.LastName = 'New';
        result.AccountId = acc.Id;
        result.Email = 'test@gmail.com';        
        return result;
    }    

    /**
     * @description create tender location record
     * @param tenderId of type Id
     * @param locationId of type Id
     * @return AITM_Tender_Location__c
     */
    public AITM_Tender_Location__c createTenderLocation(Id tenderId, Id locationId) {
        return new AITM_Tender_Location__c(
            AITM_Tender__c = tenderId,
            AITM_Location__c = locationId,
            AITM_Volume__c = 1.0,
            AITM_Ad_hoc_Volume__c = false,
            AITM_Status__c = 'Ready'
        );
    }
    
    /**
     * @description create Straddled tender location record
     * @param tenderId of type Id
     * @param locationId of type Id
     * @return AITM_Tender_Location__c
     */
    public AITM_Tender_Location__c createStraddledTenderLocation(Id tenderId, Id locationId) {
        return new AITM_Tender_Location__c(
            AITM_Tender__c = tenderId,
            AITM_Location__c = locationId,
            AITM_Volume__c = 1.0,
            AITM_Ad_hoc_Volume__c = false,
            AITM_Is_Straddled__c = true,
            AITM_Status__c = 'Ready'
        );
    }
    
    /**
     * @description create Straddled tender location line item record
     * @param tenderId of type Id
     * @param accountId of type Id
     * @param locationId of type Id
     * @return AITM_Tender_Location_Line_Item__c
     */
    public AITM_Tender_Location_Line_Item__c createStraddledTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
        return new AITM_Tender_Location_Line_Item__c(
            AITM_Tender__c = tenderId,
            AITM_Account__c = accountId,
            AITM_Location__c = locationId,
            AITM_Start_Date__c = Date.today(),
            AITM_End_Date__c = Date.today().addYears(1),
            AITM_Location_Delivery_Point__c = null,
            AITM_Is_Straddled__c = true,
            AITM_Tender_Location__c = tenderLocationId,
            AITM_Straddled_Taxes_Fees__c = 'test',
            AITM_Straddled_Additional_Taxes_Fees__c = 'testing',
            AITM_Volume__c = 1.0,
            AITM_Is_Eligible_Line_for_All_Tax_Fee__c = false
        );
    }

    /**
     * @description create tender location record
     * @param tenders of type List collection AITM_Tender__c
     * @param locations of type List collection AITM_Location__c
     * @return List collection of AITM_Tender_Location__c
     */
    public List<AITM_Tender_Location__c> createTenderLocations(List<AITM_Tender__c> tenders, List<AITM_Location__c> locations) {
        List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
        for (AITM_Tender__c tender : tenders) {
            for (AITM_Location__c location : locations) {
                result.add(createTenderLocation(tender.Id, location.Id));
            }
        }
        return result;
    }

    /**
     * @description create tender location line item record
     * @param tenderId of type Id
     * @param accountId of type Id
     * @param locationId of type Id
     * @return AITM_Tender_Location_Line_Item__c
     */
    public AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId) {
        return new AITM_Tender_Location_Line_Item__c(
            AITM_Tender__c = tenderId,
            AITM_Account__c = accountId,
            AITM_Location__c = locationId,
            AITM_Start_Date__c = Date.today(),
            AITM_End_Date__c = Date.today().addYears(1),
            AITM_Location_Delivery_Point__c = null,
            AITM_Volume__c = 1.0
        );
    }

    /**
     * @description create tender location line item record
     * @param tenders of type List collection AITM_Tender__c
     * @param accounts of type List collection Account
     * @param locations of type List collection AITM_Location__c
     * @return List collection of AITM_Tender_Location_Line_Item__c
     */
    public List<AITM_Tender_Location_Line_Item__c> createTenderLocationLineItems(List<AITM_Tender__c> tenders, List<Account> accounts, List<AITM_Location__c> locations) {
        List<AITM_Tender_Location_Line_Item__c> result = new List<AITM_Tender_Location_Line_Item__c>();
        for (AITM_Tender__c tender : tenders) {
            for (Account acc : accounts) {
                for (AITM_Location__c location : locations) {
                    result.add(createTenderLocationLineItem(tender.Id, acc.Id, location.Id));
                }
            }
        }
        return result;
    }

    /**
     * @description create tender location staging record
     * @param tenderId of type Id
     * @param accountId of type Id
     * @param locationId of type Id
     * @return AITM_Tender_Location_Staging__c
     */
    public AITM_Tender_Location_Staging__c createTenderLocationStaging(Id tenderId, Id accountId, Id locationId) {
        return new AITM_Tender_Location_Staging__c(
            AITM_Tender__c = tenderId,
            AITM_Account__c = accountId,
            AITM_Location__c = locationId,
            AITM_Start_Date__c = Date.today(),
            AITM_End_Date__c = Date.today().addYears(1),
            AITM_Volume__c = 1.0
        );
    }

    /**
     * @description create tender locations stagings record
     * @param tenders of type List collection AITM_Tender__c
     * @param accounts of type List collection Account
     * @param locations of type List collection AITM_Location__c
     * @return List collection of AITM_Tender_Location_Staging__c
     */
    public List<AITM_Tender_Location_Staging__c> createTenderLocationStagings(List<AITM_Tender__c> tenders, List<Account> accounts, List<AITM_Location__c> locations) {
        List<AITM_Tender_Location_Staging__c> result = new List<AITM_Tender_Location_Staging__c>();
        for (AITM_Tender__c tender : tenders) {
            for (Account acc : accounts) {
                for (AITM_Location__c location : locations) {
                    result.add(createTenderLocationStaging(tender.Id, acc.Id, location.Id));
                }
            }
        }
        return result;
    }

    /**
     * @description create tender location line item record
     * @param size of type Integer
     * @param profileName of type string
     * @return List collection of User
     */
    public List<User> createUsers(Integer size, String profileName) {
        List<User> result = new List<User>();

        Profile p = [SELECT Id, Name FROM Profile WHERE Name = :profileName];

        for (Integer index = 0; index < size; index++) {
            String uName = 'airbp_test_usr_' + index;
            User u = new User(
                    Alias = 'un_' + index,
                    Email = uName + '@testorg.com',
                    EmailEncodingKey ='UTF-8',
                    LastName ='Testing',
                    LanguageLocaleKey ='en_US',
                    LocaleSidKey ='en_US',
                    ProfileId = p.Id,
                    TimeZoneSidKey ='America/Los_Angeles',
                    UserName = uName + '@testorg.com'
            );
            result.add(u);
        }

        return result;
        
    }

    /**
     * @description create pricingservice settings
     * @param null
     * @return AITM_PricingServiceSettings__c custom settings
     */
    public AITM_PricingServiceSettings__c createPricingServiceSettings() {
        return new AITM_PricingServiceSettings__c(
            AITM_Endpoint__c = 'http://dssdsdsdsdsdasdadvxcxzcz.com/sdasdqwdwqds',
            AITM_Class__c = 'AITM_PricingServiceRepository.PROSService',
            AITM_Username__c = 'Test User',
            AITM_Password__c = 'Test Password',
            AITM_Auth_Endpoint__c = 'http://authtokenauthauth.token/auth/token'
        );
    }

    /**
     * @description create delivery point
     * @param location of type AITM_Location__c
     * @param isDefault of type boolean
     * @param countNumber of type Integer
     * @return AITM_Delivery_Point__c
     */
    public AITM_Delivery_Point__c createDeliveryPoint(AITM_Location__c location, Boolean isDefault, Integer countNumber) {
        return new AITM_Delivery_Point__c(
            Name = 'TESTNAME-'+countNumber,
            AITM_Location__c = location.Id,
            AITM_Delivery_Point_Number__c = '0' + countNumber,
            AITM_Delivery_Point_External_Name__c = 'DEL-' + countNumber,
            AITM_Delivery_Point_Unique_ID__c = 'DEL-' + countNumber,
            AITM_Default_Delivery_Point__c = 'BOTH',
            AITM_BPInter_Location_DeliveryPoint_Cod__c = 'DEL-' + countNumber,
            AITM_Default__c = (isDefault) ? isDefault : false
        );
    }
    
    /**
     * @description create master Taxes and Fees record
     * @param null
     * @return AITM_Taxes_Fees__c object
     */
    public AITM_Taxes_Fees__c createMasterDataTaxesAndFees() {
        return new AITM_Taxes_Fees__c(
            Name = 'Master T&F'
        );
    }
    
    /**
     * @description create Tender Location Taxes and Fees record
     * @param null
     * @return AITM_Tender_Location_Taxes_and_Fees__c	 object
     */
    public AITM_Tender_Location_Taxes_and_Fees__c createTenderLocationTaxesAndFee(Id lineItemId) {
        return new AITM_Tender_Location_Taxes_and_Fees__c(
            Name = 'test',
            Tender_Location_Line_Item_Id__c = lineItemId,
            Is_Recently_Modified_Loc_Tax_Fee__c = true,
            AITM_Compulsory_Conditional__c = 'Conditional',
            AITM_Value__c = 10
        );
    }
}