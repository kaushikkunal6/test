/***************************************************************************************************
 * @author           Shweta
 * @date             20/May/2020
 * @group            IBM
 * @description      Wrapper Class for County API -Mulesoft

 * history
 * 20/May/2020       Shweta        Created
 * 27/Jun/2020       Neeti         Updated- convertList and added some Validations
 * 20/Oct/2020       Saravan       Updated- to skip LABP delegates update
 * 15/Dec/2020       DenisK        Updated- added Airport Contacts and DPAC creation
 * 31/Dec/2020       srnandan      refactor the code           
 ****************************************************************************************************/
public with sharing class AITM_CountryAPIWrapperClass {
    public Integer countryID {get;set;}
    public String name {get;set;}
    public Locations locations {get;set;}
    public static Map<String, String> convertCurrencyMap = new Map<String, String>();
    
   /**
    * @description Empty Constructor
    * @param null
    * @return null
    */   
    public AITM_CountryAPIWrapperClass() {  

    }
    
    
   /**
    * @description Constructor to parse string
    * @param null
    * @return null
    */   
    public AITM_CountryAPIWrapperClass(String s) {
        List<AITM_Currency_Convert__mdt> convertCurrencyList = [SELECT AITM_Converted_Value__c, Label FROM AITM_Currency_Convert__mdt LIMIT 200];
        for(AITM_Currency_Convert__mdt cc: convertCurrencyList) {
            convertCurrencyMap.put(cc.Label,cc.AITM_Converted_Value__c);
        }
        
        JSONParser parser = JSON.createParser(s);
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'CountryID') {
                        countryID = parser.getIntegerValue();
                    } else if (text == 'Name') {
                        name = parser.getText();
                    } else if (text == 'locations') {
                        locations = new Locations(parser);
                    } else { 
                        consumeObject(parser);
                    }
                }
            }
        }            
    }
    
   /**
    * @description class to represent a group of Locations
    */   
    public with sharing class Locations{
        public List<Location> location {get;set;} 
        public Integer iCount{get;set;}   
        //Constructor to parse string
        public Locations(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'location') {
                            location = arrayOfLocation(parser);
                        } else if (text == 'count') {
                            iCount = parser.getIntegerValue();
                        }else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        } 
    }  
    
    /**
     * @description class to represent a Location
     * @param null
     * @return null
     */  
    public with sharing class Location {
        public String locationID {get;set;}
        public String countryId {get;set;}
        public String airportId {get;set;}
        public String iATA {get;set;}
        public String iCAO {get;set;}
        public String locationCountry {get;set;}
        public String locationName {get;set;}
        public String locationType {get;set;}
        public AirportHandlers airporthandlers {get;set;}
        public DeliveryPoints deliverypoints {get;set;}
        
        //Constructor to parse string
        public Location(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'LocationID') {
                            locationID = parser.getText();
                        } else if (text == 'CountryId') {
                            countryId = parser.getText();
                        } else if (text == 'AirportId') {
                            airportId = parser.getText();
                        } else if (text == 'IATA') {
                            iATA = parser.getText();
                        } else if (text == 'ICAO') {
                            iCAO = parser.getText();
                        } else if (text == 'LocationCountry') {
                            locationCountry = parser.getText();
                        } else if (text == 'LocationName') {
                            locationName = parser.getText();
                        } else if (text == 'LocationType') {
                            locationType = parser.getText();
                        } else if (text == 'airporthandlers') {
                            airporthandlers = new AirportHandlers(parser);
                        } else if (text == 'deliverypoints') {
                            deliverypoints = new DeliveryPoints(parser);
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
   /**
    * @description class to represent a group of Airporthandlers
    * @param null
    * @return null
    */     
    public with sharing class AirportHandlers {
        public List<AirportHandler> airporthandler {get;set;} 
        public Integer iCount {get;set;} 
        //Constructor to parse string
        public AirportHandlers(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'airporthandler') {
                            airporthandler = arrayOfAirporthandler(parser);
                        } else if (text == 'count') {
                            iCount = parser.getIntegerValue();  
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
   /**
    * @description class to represent a group of Airporthandler 
    */   
    public with sharing class AirportHandler {
        public Integer airportHandlerID {get;set;} 
        public Integer airportID {get;set;} 
        
       /**
        * @description Constructor to parse string 
        * @param null
        * @return null
        */   
        public AirportHandler(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'AirportHandlerID') {
                            airportHandlerID = parser.getIntegerValue();
                        } else if (text == 'AirportID') {
                            airportID = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        } 
                    }
                }
            }
        }
    }
    
    /**
     * @description class to represent a group of Deliverypoints
     */   
    public with sharing class DeliveryPoints {
        public List<DeliveryPoint> deliveryPointList {get;set;}
        public Integer iCount {get;set;}
        //Constructor to parse string
      
       /**
        * @description Constructor to parse string
        * @param null
        * @return null
        */   
        public DeliveryPoints(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'deliverypoint') {
                            deliveryPointList = arrayOfDeliverypoint(parser);
                        } else if (text == 'count') {
                            iCount = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
   /**
    * @description class to represent a Deliverypoint
    */         
    public with sharing class DeliveryPoint {
        public Integer fuelProviderID {get;set;}
        public Integer locationID {get;set;}
        public String fuelProvider {get;set;}
        public String deliveryMethod {get;set;}
        public String dealerId {get;set;}
        public String deliveryPointUid {get;set;}
        public String defaultDeliveryPoint {get;set;}
        public String cAContact {get;set;}
        public String gAContact {get;set;} 
        public String unitOfMeasure {get;set;}
        public String fuelAvailableOutofhours {get;set;} 
        public String providerServicearea {get;set;}
        public String serviceLevelProvided {get;set;}
        public String deliveryPointID {get;set;}
        public String noticeReqOutofhourFuel {get;set;}
        public String bPInternalCodeLocDB {get;set;}
        public String defaultMeasure {get;set;}
        public String deliveryPointName {get;set;}
        public String defaultProductDescription {get;set;}
        public String providerServiceareaLoc {get;set;}
        public String additionalRefuelInfo {get;set;}
        public String defaultCurrencyName {get;set;}
        public String defaultProductName {get;set;}
        public String providerServiceAreaOther {get;set;}
        public String solusLocation {get;set;}
        public String cAPriceIndex {get;set;}
        public String gAPriceIndex {get;set;}
        public String locationManager {get;set;}
        public String deliveryPointStatus {get;set;}  
        public string lMDelegate11 {get;set;}
        public string lMDelegate22 {get;set;}
        public string lMDelegate33 {get;set;}
        public string lMDelegate44 {get;set;}
        public string lMDelegate55 {get;set;}
        public string lMDelegate66 {get;set;}
        public AirContacts aircontacts {get;set;}
        public OpeningHours openinghours {get;set;}
        
       /**
        * @description Constructor to parse string
        * @param null
        * @return null
        */   
        public DeliveryPoint(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'FuelProviderID') {
                            fuelProviderID = parser.getIntegerValue();
                        } else if (text == 'LocationID') {
                            locationID = parser.getIntegerValue();
                        } else if (text == 'contacts') {
                            aircontacts = new AirContacts(parser);
                        } else if (text == 'openinghours') {
                            openinghours = new Openinghours(parser);
                        } else if (text == 'FuelProvider') {
                            fuelProvider = parser.getText();
                        } else if (text == 'DeliveryMethod') {
                            deliveryMethod = parser.getText().removeEnd(' services').replace('In-Drum', 'Drum');// Validation to update Values
                        } else if (text == 'DealerId') {
                            dealerId = parser.getText();
                        } else if (text == 'DeliveryPointUid') {
                            deliveryPointUid = parser.getText();
                        } else if (text == 'DefaultDeliveryPoint') {
                            defaultDeliveryPoint = parser.getText();
                        } else if (text == 'CAContact') {
                            cAContact = parser.getText();
                            cAContact = cAContact.substringAfterLast('- ');
                            cAContact = cAContact.deleteWhitespace();
                        } else if (text == 'GAContact') {
                            gAContact = parser.getText();
                            gAContact = gAContact.substringAfterLast('- ');
                            gAContact = gAContact.deleteWhitespace();
                        } else if (text == 'UnitOfMeasure') {
                            unitOfMeasure = parser.getText();
                        } else if (text == 'FuelAvailableOutofhours') {
                            fuelAvailableOutofhours = parser.getText();
                        } else if (text == 'ProviderServicearea') {
                            providerServicearea = parser.getText().replace('true', 'Yes').replace('false', 'No');
                        } else if (text == 'ServiceLevelProvided') {
                            serviceLevelProvided = parser.getText();
                        } else if (text == 'DeliveryPointID') {
                            deliveryPointID = parser.getText();
                        } else if (text == 'NoticeReqOutofhourFuel') {
                            noticeReqOutofhourFuel = parser.getText();
                        } else if (text == 'BPInternalCodeLocDB') {
                            bPInternalCodeLocDB = parser.getText();
                        } else if (text == 'DefaultMeasure') {
                            defaultMeasure = parser.getText();
                        } else if (text == 'DeliveryPointName') {
                            deliveryPointName = parser.getText();
                        } else if (text == 'DefaultProductDescription') {
                            defaultProductDescription = parser.getText();
                        } else if (text == 'ProviderServiceareaLoc') {
                            providerServiceareaLoc = parser.getText().replace('true', 'Yes').replace('false', 'No');
                        } else if (text == 'AdditionalRefuelInfo') {
                            additionalRefuelInfo = parser.getText();
                        } else if (text == 'DefaultCurrencyName') {
                            defaultCurrencyName = convertCurrencyMap.containsKey(parser.getText())? convertCurrencyMap.get(parser.getText()):'';             
                        } else if (text == 'DefaultProductName') {
                            defaultProductName = parser.getText();
                        } else if (text == 'ProviderServiceAreaOther') {
                            providerServiceAreaOther = parser.getText();
                        } else if (text == 'SolusLocation') {
                            solusLocation = parser.getText();
                        } else if (text == 'CAPriceIndex') {
                            cAPriceIndex = parser.getText();
                        } else if (text == 'GAPriceIndex') {
                            gAPriceIndex = parser.getText();
                        } else if (text == 'DeliveryPointStatus') {
                            deliveryPointStatus = parser.getText();
                        } else if (text == 'LocationManager') {
                            locationManager = parser.getText();
                            locationManager = locationManager.substringAfterLast('- ');
                            locationManager = locationManager.deleteWhitespace();
                        } else if (text == 'LMDelegate11') {
                            lMDelegate11 = parser.getText();
                            lMDelegate11 = lMDelegate11.substringAfterLast('- ');
                            lMDelegate11 = lMDelegate11.deleteWhitespace();
                        } else if (text == 'LMDelegate22') {
                            lMDelegate22 = parser.getText();
                            lMDelegate22 = lMDelegate22.substringAfterLast('- ');
                            lMDelegate22 = lMDelegate22.deleteWhitespace();
                        } else if (text == 'LMDelegate33') {
                            lMDelegate33 = parser.getText();
                            lMDelegate33 = lMDelegate33.substringAfterLast('- ');
                            lMDelegate33 = lMDelegate33.deleteWhitespace();
                        } else if (text == 'LM_Delegate44') {
                            lMDelegate44 = parser.getText();
                            lMDelegate44 = lMDelegate44.substringAfterLast('- ');
                            lMDelegate44 = lMDelegate44.deleteWhitespace();
                        } else if (text == 'LM_Delegate55') {
                            lMDelegate55 = parser.getText();
                            lMDelegate55 = lMDelegate55.substringAfterLast('- ');
                            lMDelegate55 = lMDelegate55.deleteWhitespace();
                        } else if (text == 'LM_Delegate66') {
                            lMDelegate66 = parser.getText();
                            lMDelegate66 = lMDelegate66.substringAfterLast('- ');
                            lMDelegate66 = lMDelegate66.deleteWhitespace();
                        } else {  
                            consumeObject(parser);
                        }
                        
                    }
                }
            }
        }
    }
    
   /**
    * @description class to represent a group of Airport Contacts
    */     
    public with sharing class AirContacts {
        public List<AirContact> aircontact {get;set;} 
        public Integer iCount {get;set;} 
        //Constructor to parse string
        public AirContacts(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'contact') {
                            aircontact = arrayOfContact(parser);
                        } else if (text == 'count') {
                            iCount = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
   /**
    * @description class to represent an Airport Contact
    */         
    public with sharing class AirContact {
        public Integer airContactID {get;set;}
        public String email {get;set;} 
        public String airconName {get;set;} 
        public String airconRole {get;set;} 
        public String delPointId {get;set;} 
        public String fax {get;set;} 
        public String mobile {get;set;} 
        public String phone1 {get;set;} 
        public String phone2 {get;set;} 
        public String preferredContactMethod {get;set;} 
        
        //Constructor to parse string
        public AirContact(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'ContactID') {
                            airContactID = parser.getIntegerValue();
                        } else if (text == 'Email') {
                            email = parser.getText();
                        } else if (text == 'Name') {
                            airconName = parser.getText();
                        } else if (text == 'Type') {
                            airconRole = parser.getText();
                        } else if (text == 'DeliveryPointID') {
                            delPointId = parser.getText();
                        } else if (text == 'Fax') {
                            fax = parser.getText();
                        } else if (text == 'Mobile') {
                            mobile = parser.getText();
                        } else if (text == 'Phone1') {
                            phone1 = parser.getText();
                        } else if (text == 'Phone2') {
                            phone2 = parser.getText();
                        } else if (text == 'PreferredContactMethod') {
                            preferredContactMethod = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
   /**
    * @description class to represent a group of Openinghours 
    */    
    public with sharing class OpeningHours {
        public List<OpeningHour> openinghour {get;set;} 
        public Integer iCount {get;set;} 
        
       /**
        * @description Constructor to parse string 
        * @param null
        * @return null
        */  
        public OpeningHours(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'openinghour') {
                            openinghour = arrayOfOpeninghour(parser);
                        } else if (text == 'count') {
                            iCount = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
   /**
    * @description class to represent a Openinghour
    */    
    public with sharing class OpeningHour {
        public Integer openingHoursID {get;set;} 
        public String openingTime {get;set;}
        public String closingTime {get;set;}
         
       /**
        * @description Constructor to parse string
        * @param null
        * @return null
        */  
        public OpeningHour(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'OpeningHoursID') {
                            openingHoursID = parser.getIntegerValue();
                        } else if (text == 'OpeningTime') {
                            openingTime = parser.getText();
                        } else if (text == 'ClosingTime') {
                            closingTime = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
   /**
    * @description method to create a list of Airport Contacts
    * @param null
    * @return null
    */   
    private static List<AirContact> arrayOfContact(System.JSONParser p) {
        List<AirContact> res = new List<AirContact>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new AirContact(p));
        }
        
        return res;
    }
    
   /**
    * @description method to create a list of openinghour
    * @param null
    * @return null
    */       
    private static List<OpeningHour> arrayOfOpeninghour(System.JSONParser p) {
        List<OpeningHour> res = new List<OpeningHour>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new OpeningHour(p));
        }
        return res;
    }
    
   /**
    * @description method to create a list of DeliveryPoint
    * @param null
    * @return null
    */   
    private static List<DeliveryPoint> arrayOfDeliverypoint(System.JSONParser p) {
        List<DeliveryPoint> res = new List<DeliveryPoint>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new DeliveryPoint(p));
        }
        return res;
    }
    
   /**
    * @description method to create a list of Airporthandler
    * @param null
    * @return null
    */   
    private static List<AirportHandler> arrayOfAirporthandler(System.JSONParser p) {
        List<AirportHandler> res = new List<AirportHandler>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new AirportHandler(p));
        }
        return res;
    }
    
   /**
    * @description method to consume Object ; parameter - String
    * @param null
    * @return null
    */ 
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;

        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                    depth++;
                } else if (curr == System.JSONToken.END_OBJECT ||
                           curr == System.JSONToken.END_ARRAY) {
                               depth--;
                           }
        } while (depth > 0 && parser.nextToken() != null);
    }
    
   /**
    * @description method to create a list of Airporthandler
    * @param null
    * @return null
    */  
    private static List<Location> arrayOfLocation(System.JSONParser p) {
        List<Location> res = new List<Location>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Location(p));
        }
        return res;
        
    }
    
   /**
    * @description FinalWrapper inner class
    */ 
    public without sharing class FinalWrapper {
        public Map<AITM_Location__c, List <AITM_Delivery_Point__c>> locdelmap {get;set;} 
        public Map <AITM_Delivery_Point__c, List <Contact>> aircondelmap {get;set;} 
        public Map <AITM_Delivery_Point__c, List <AITM_Delivery_Point_Airport_Contact__c>> dpacdpmap{get;set;} 
    }
    
   /**
    * @description validateEmail Address
    * @param email as String
    * @return Boolean
    */
    public static Boolean validateEmail(String email) {
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern myPattern = Pattern.compile(emailRegex);
        Matcher myMatcher = myPattern.matcher(email);
        if (!myMatcher.matches()) 
            res = false;
        return res; 
    }
    
    
   /**
    * @description method to return map < AITM_Location__c, List < AITM_Delivery_Point__c >> from string
    * @param null
    * @return null
    */  
    public FinalWrapper convertList(String s, Map<String,User> ntIDMap, Map<String,id> pbIDMap, String accId) {
        
        FinalWrapper finWrap = new FinalWrapper();
        Map <AITM_Location__c, List <AITM_Delivery_Point__c>> locDpMap = new Map <AITM_Location__c, List < AITM_Delivery_Point__c >> ();
        Map <AITM_Delivery_Point__c, List <Contact>> dpConMap = new Map <AITM_Delivery_Point__c, List <Contact>>();
        Map <AITM_Delivery_Point__c, List <AITM_Delivery_Point_Airport_Contact__c>> dpDpacMap = new Map <AITM_Delivery_Point__c, List <AITM_Delivery_Point_Airport_Contact__c>> ();
        Map <String, String> idRoleMap = new Map <String, String>();
        Map <String, Contact> idConMap = new Map <String, Contact>();
        Map <String, AITM_Delivery_Point_Airport_Contact__c> idDpacMap = new Map <String, AITM_Delivery_Point_Airport_Contact__c>();
        AITM_CountryAPIWrapperClass aw = new AITM_CountryAPIWrapperClass(s);
        
        for (Integer i = 0; i < aw.locations.location.size(); i++) {
            AITM_Location__c loc = new AITM_Location__c();
            List <AITM_Delivery_Point__c> listDP = new List < AITM_Delivery_Point__c> ();
            List <Contact> listAC = new List <Contact> ();
            Set <String> conMailSet = new Set <String>();
            Set <String> dpacMailSet = new Set <String>();
            List <AITM_Delivery_Point_Airport_Contact__c> listDPAC = new List <AITM_Delivery_Point_Airport_Contact__c> ();
            loc = locationSObjectValueAssignment(loc,aw.locations.location[i]);
            loc.AITM_Country__c = aw.name;
            loc.OwnerId = ntIDMap.get(System.Label.AITM_LocationOwner.toLowerCase()).id; 

            for(Integer j = 0; j < aw.locations.location[i].deliverypoints.deliveryPointList.size(); j++) {
                
                String openinghrs ='';
                String closinghrs = '';
                AITM_Delivery_Point__c dp = new AITM_Delivery_Point__c();
                
                string delegates ='';
                string delegateId ='';
                
                delegates = delegatesValueAssignment(aw.locations.location[i].deliverypoints.deliveryPointList[j], ntIDMap, delegates);
                
                //if((delegates !='' || delegates != null ) && !(loc.AITM_Country__c.contains(System.Label.AITM_Polish_check))) {
                if(!String.isBlank(delegates) && !(loc.AITM_Country__c.contains(System.Label.AITM_Polish_check))) {
                    dp.AITM_CA_Pricing_ResponsibilityDeligates1__c = delegates;
                    dp.AITM_GA_Pricing_ResponsibilityDeligates1__c = delegates ;
                }
                
                if(aw.locations.location[i].deliverypoints.deliveryPointList[j].deliveryPointID != null){
                    dp.AITM_Delivery_Point_Unique_ID__c =  aw.locations.location[i].deliverypoints.deliveryPointList[j].deliveryPointID;
                }    
                
                for(Integer k = 0;k < aw.locations.location[i].deliverypoints.deliveryPointList[j].aircontacts.aircontact.size();k++){
                    String validEmail = '';
                    String dpacId = '';
                    String conRole = '';
                    String existingConRole = '';

                    if(!string.isBlank(aw.locations.location[i].deliverypoints.deliveryPointList[j].aircontacts.aircontact[k].email)){
                        validEmail = aw.locations.location[i].deliverypoints.deliveryPointList[j].aircontacts.aircontact[k].email;
                        dpacId = aw.locations.location[i].deliverypoints.deliveryPointList[j].aircontacts.aircontact[k].delPointId + '-' + validEmail.trim().toLowerCase();
                        conRole = aw.locations.location[i].deliverypoints.deliveryPointList[j].aircontacts.aircontact[k].airconRole;
                        existingConRole = idRoleMap.get(dpacId);
                    }
                    
                    if(!string.isBlank(validEmail) && validateEmail(validEmail)) {
                        Contact con = new Contact();
                        if(!idConMap.containsKey(validEmail)) {
                            con.AITM_Unique_Id__c = validEmail.trim().toLowerCase();
                            con.Email = validEmail.trim().toLowerCase();
                            if(aw.locations.location[i].deliverypoints.deliveryPointList[j].aircontacts.aircontact[k].airconName != null) {
                                con.LastName = aw.locations.location[i].deliverypoints.deliveryPointList[j].aircontacts.aircontact[k].airconName;
                            } else {
                                con.LastName = 'Team';
                            }
                            con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('AITM_Airport_Contact').getRecordTypeId();
                            con.AccountId = accId;
                        } else {
                            con = idConMap.get(validEmail);
                        }
                        con = contactFieldValueAssignment(con, aw.locations.location[i].deliverypoints.deliveryPointList[j].aircontacts.aircontact[k]);
                        idConMap.put(validEmail, con);
                        conMailSet.add(validEmail);

                        AITM_Delivery_Point_Airport_Contact__c dpac = new AITM_Delivery_Point_Airport_Contact__c();
                        if(!idDpacMap.containsKey(dpacId)) {
                            dpac.AITM_Airport_Contact__r = con;
                            dpac.AITM_Delivery_Point__r = dp;
                            dpac.AITM_Unique_Id__c = dpacId;
                        } else {
                            dpac = idDpacMap.get(dpacId);
                        }
                        if(conRole!=null) {
                            if(idRoleMap.containsKey(dpacId) && !existingConRole.containsIgnoreCase(conRole)) {
                                dpac.AITM_Roles__c = existingConRole + conRole + ';';
                                idRoleMap.put(dpacId, dpac.AITM_Roles__c);
                            } else if(idRoleMap.containsKey(dpacId) && existingConRole.containsIgnoreCase(conRole)) {
                                dpac.AITM_Roles__c = existingConRole;
                            } else if(!idRoleMap.containsKey(dpacId)) {
                                dpac.AITM_Roles__c = conRole + ';';
                                idRoleMap.put(dpacId, dpac.AITM_Roles__c);
                            }
                            idDpacMap.put(dpacId, dpac);
                            dpacMailSet.add(dpacId);
                        }
                    }
                    
                    for(String conMail : conMailSet) {
                        listAC.add(idConMap.get(conMail));
                    }

                    Integer counter = 0;
                    for(String dpacMail : dpacMailSet) {                   
                        listDPAC.add(idDpacMap.get(dpacMail));
                        counter++;
                    }
                }

                for( Integer k=0;k<aw.locations.location[i].deliverypoints.deliveryPointList[j].openinghours.openinghour.size();k++){
                    string openinghrs1 = aw.locations.location[i].deliverypoints.deliveryPointList[j].openinghours.openinghour[k].openingTime + '-' + aw.locations.location[i].deliverypoints.deliveryPointList[j].openinghours.openinghour[k].closingTime;
                    openinghrs = openinghrs + openinghrs1.replaceAll(';', ':') + '\n';    
                }
                
                dp = deliveryPointFieldValueAssignment(dp, aw.locations.location[i].deliverypoints.deliveryPointList[j], openinghrs, ntIDMap, loc);
                dp = deliveryPointDormantNonDormant(dp, aw.locations.location[i].deliverypoints.deliveryPointList[j], pbIDMap);
                listDP.add(dp);
                if(!listAC.isEmpty())
                    dpConMap.put(dp,listAC);
                if(!listDPAC.isEmpty())
                    dpDpacMap.put(dp,listDPAC);
            }
            
            locDpMap.put(loc, listDP);
            finWrap.locdelmap = locDpMap;
            finWrap.aircondelmap = dpConMap;
            finWrap.dpacdpmap = dpDpacMap;
        }
        return finWrap;
    }

   /**
    * @description method to return Contact object field assignment
    * @param conObj as Contact
    * @param air as AITM_CountryAPIWrapperClass.AirContact
    * @return Contact
    */
    private Contact contactFieldValueAssignment(Contact conObj, AITM_CountryAPIWrapperClass.AirContact air) {
        conObj.MobilePhone = air.mobile;
        conObj.Fax = air.fax;
        conObj.Phone = air.phone1;
        conObj.AITM_Other_Phones__c = air.phone2;
        conObj.Preferred_Contact_Method__c  = air.preferredContactMethod;
        return conObj;
    }

   /**
    * @description method to return Location object field assignment
    * @param locObj as AITM_Location__c
    * @param loca as AITM_CountryAPIWrapperClass.Location
    * @return AITM_Location__c
    */
    private AITM_Location__c locationSObjectValueAssignment(AITM_Location__c locObj, AITM_CountryAPIWrapperClass.Location loca) {
        locObj.AITM_Airport_Id__c = loca.airportId;
        locObj.AITM_Location_Type__c = loca.locationType;
        locObj.AITM_SCM_Location_Unique_ID__c = loca.locationID;
        locObj.Name = loca.locationName;
        locObj.AITM_IATA__c = loca.iATA;
        locObj.AITM_ICAO__c = loca.iCAO;
        locObj.AITM_Country_Id__c = loca.countryId;    
        locObj.AITM_Locations_Filter__c = (locObj.AITM_Country__c !=null && locObj.AITM_Country__c.contains(System.Label.AITM_Polish_check))?'Polish':'NonPolish';
        return locObj;
    }

   /**
    * @description method to return Delivery Point object field assignment
    * @param locObj as AITM_Delivery_Point__c
    * @param loca as AITM_CountryAPIWrapperClass.Location
    * @return AITM_Delivery_Point__c
    */
    private AITM_Delivery_Point__c deliveryPointFieldValueAssignment(AITM_Delivery_Point__c delObj, AITM_CountryAPIWrapperClass.DeliveryPoint delWrap, String openinghours, Map<String,User> ntIDMap, AITM_Location__c loc) {
        delObj.AITM_Opening_Hours__c = (openinghours.contains('NULL'))?'':openinghours + '';
        delObj.AITM_Currency__c = delWrap.defaultCurrencyName;
        delObj.AITM_Airport_IntoPlane_Provider_BulkName__c = delWrap?.fuelProvider;//(delWrap.fuelProvider != null?delWrap.fuelProvider:null);
        delObj.AITM_Delivery_Method__c = delWrap?.deliveryMethod;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].deliveryMethod != null?aw.locations.location[i].deliverypoints.deliveryPointList[j].deliveryMethod:null); //Validation 1
        delObj.AITM_Dealer_ID__c = delWrap?.dealerId;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].dealerId !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].dealerId:null);
        delObj.AITM_Delivery_Point_Number__c = delWrap?.deliveryPointUid;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].deliveryPointUid !=null? aw.locations.location[i].deliverypoints.deliveryPointList[j].deliveryPointUid:null);
        delObj.AITM_Default_Delivery_Point__c = delWrap?.defaultDeliveryPoint;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].defaultDeliveryPoint !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].defaultDeliveryPoint:null);
        delObj.AITM_Unit_of_Measure__c = delWrap?.unitOfMeasure;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].unitOfMeasure !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].UnitOfMeasure:null);
        delObj.AITM_Fueling_Available_Out_of_Hours__c = delWrap?.fuelAvailableOutofhours;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].fuelAvailableOutofhours !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].fuelAvailableOutofhours:null);
        delObj.AITM_Fuel_Provider_Service_Area__c = delWrap?.providerServicearea;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].providerServicearea!=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].providerServicearea:null);
        delObj.AITM_Service_Level_Provided__c = delWrap?.serviceLevelProvided;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].serviceLevelProvided!=null)?((aw.locations.location[i].deliverypoints.deliveryPointList[j].serviceLevelProvided.containsIgnoreCase('None'))?System.Label.AITM_Level:(aw.locations.location[i].deliverypoints.deliveryPointList[j].serviceLevelProvided)):System.Label.AITM_Level;
        delObj.AITM_NoticeRequired_for_OutofHrs_Fueling__c = delWrap?.noticeReqOutofhourFuel;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].noticeReqOutofhourFuel !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].noticeReqOutofhourFuel:null);
        delObj.AITM_Measure__c = delWrap?.defaultMeasure;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].defaultMeasure !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].DefaultMeasure:null);
        delObj.AITM_Delivery_Point_External_Name__c = delWrap?.deliveryPointName;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].deliveryPointName!=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].deliveryPointName:null);
        delObj.AITM_Product_Specification__c = delWrap?.defaultProductDescription;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].defaultProductDescription !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].defaultProductDescription:null);
        delObj.AITM_FuelProviderServiceAreaAllLocations__c = delWrap?.providerServiceareaLoc;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].providerServiceareaLoc !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].ProviderServiceareaLoc:null);
        delObj.AITM_Internal_Code__c = delWrap?.bPInternalCodeLocDB;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].bPInternalCodeLocDB !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].bPInternalCodeLocDB:null);
        delObj.AITM_Additional_Refueling_Information__c = delWrap?.additionalRefuelInfo;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].additionalRefuelInfo !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].additionalRefuelInfo:null);
        delObj.AITM_Fuel_Provider_Service_Area_Other__c = delWrap?.providerServiceAreaOther;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].providerServiceAreaOther !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].ProviderServiceAreaOther:Null);
        delObj.AITM_Solus_Location__c = delWrap?.solusLocation;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].solusLocation !=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].SolusLocation:null);
        delObj.AITM_BPInter_Location_DeliveryPoint_Cod__c = delWrap?.bPInternalCodeLocDB + '-' + delWrap?.deliverypointUid;//(delWrap.bPInternalCodeLocDB!=null?delWrap.bPInternalCodeLocDB:null)+'-'+(delWrap.deliverypointUid !=null?delWrap.deliverypointUid:null);
        delObj = deliveryPointCAPricingResponsibility(delObj, delWrap, ntIDMap);
        delObj = deliveryPointGAPricingResponsibility(delObj, delWrap, ntIDMap);
        delObj = deliveryPointLocationManagerAndOwner(delObj, delWrap, ntIDMap, loc);
        return delObj;
    }

   /**
    * @description method to return Delivery Point object CA PricingResponsibility assignment
    * @param locObj as AITM_Delivery_Point__c
    * @param loca as AITM_CountryAPIWrapperClass.Location
    * @return AITM_Delivery_Point__c
    */
    private AITM_Delivery_Point__c deliveryPointCAPricingResponsibility(AITM_Delivery_Point__c delObj, AITM_CountryAPIWrapperClass.DeliveryPoint delWrap, Map<String,User> ntIDMap) {
        if(delWrap.cAContact != null){
            if(ntIDMap.containsKey(delWrap.cAContact.toLowerCase())){
                delObj.AITM_CA_Pricing_Responsibility1__c = ntIDMap.get(delWrap.cAContact.toLowerCase()).id;
            }
        }
        return delObj;
    }

   /**
    * @description method to return Delivery Point object CA PricingResponsibility assignment
    * @param locObj as AITM_Delivery_Point__c
    * @param loca as AITM_CountryAPIWrapperClass.Location
    * @return AITM_Delivery_Point__c
    */
    private AITM_Delivery_Point__c deliveryPointGAPricingResponsibility(AITM_Delivery_Point__c delObj, AITM_CountryAPIWrapperClass.DeliveryPoint delWrap, Map<String,User> ntIDMap) {
        if(delWrap.gAContact != null){
            if(ntIDMap.containsKey(delWrap.gAContact.toLowerCase())){
                delObj.AITM_GA_Pricing_Responsibility1__c = ntIDMap.get(delWrap.gAContact.toLowerCase()).id;
            }
        }
        return delObj;
    }

   /**
    * @description method to return Delivery Point object locationmanager and owner assignment
    * @param locObj as AITM_Delivery_Point__c
    * @param loca as AITM_CountryAPIWrapperClass.Location
    * @return AITM_Delivery_Point__c
    */
    private AITM_Delivery_Point__c deliveryPointLocationManagerAndOwner(AITM_Delivery_Point__c delObj, AITM_CountryAPIWrapperClass.DeliveryPoint delWrap, Map<String,User> ntIDMap, AITM_Location__c loc) {
        if(delWrap.locationManager!=Null){
            if(ntIDMap.containsKey(delWrap.locationManager.toLowerCase())){
                loc.OwnerId = ntIDMap.get(delWrap.locationManager.toLowerCase()).id;  
                delObj.OwnerId = ntIDMap.get(delWrap.locationManager.toLowerCase()).id;       
                delObj.AITM_Location_Manager1__c = ntIDMap.get(delWrap.locationManager.toLowerCase()).id;  
            }
        } else{ 
            delObj.OwnerId = ntIDMap.get(System.Label.AITM_LocationOwner.toLowerCase()).id;       
            delObj.AITM_Location_Manager1__c = ntIDMap.get(System.Label.AITM_LocationOwner.toLowerCase()).id;  
        }
        return delObj;
    }

   /**
    * @description method to return Delivery Point object Dormant and NonDormant
    * @param delObj as AITM_Delivery_Point__c
    * @param delWrap as AITM_CountryAPIWrapperClass.DeliveryPoint
    * @param pbIDMap as Map<String,id>
    * @return AITM_Delivery_Point__c
    */
    private AITM_Delivery_Point__c deliveryPointDormantNonDormant(AITM_Delivery_Point__c delObj, AITM_CountryAPIWrapperClass.DeliveryPoint delWrap, Map<String,id> pbIDMap) {
        if(delWrap.deliveryPointStatus =='Dormant') { 
            delObj.Name = (delWrap.deliveryPointName !=null?delWrap.deliveryPointName + ' (Do Not Use)':null);
            delObj.AITM_Is_Active__c= false;  
            delObj.AITM_Pricing_Basis_CA__c= pbIDMap.get(System.Label.AITM_Not_Represented);
            delObj.AITM_Pricing_Basis_GA__c= pbIDMap.get(System.Label.AITM_Not_Represented); 
        } else {
            delObj.Name = delWrap?.deliveryPointName;//(aw.locations.location[i].deliverypoints.deliveryPointList[j].deliveryPointName!=null?aw.locations.location[i].deliverypoints.deliveryPointList[j].deliveryPointName:null);
            delObj.AITM_Is_Active__c= true;
            if(pbIDMap.containsKey(delWrap.cAPriceIndex)){
                delObj.AITM_Pricing_Basis_CA__c = pbIDMap.get(delWrap.cAPriceIndex);
            }
            if(pbIDMap.containsKey(delWrap.gAPriceIndex)){
                delObj.AITM_Pricing_Basis_GA__c = pbIDMap.get(delWrap.gAPriceIndex);
            }
        }
        return delObj;
    }

   /**
    * @description method to return Location Manager delegates
    * @param del as AITM_CountryAPIWrapperClass.DeliveryPoint
    * @param mapNTId as Map<String,User>
    * @param delegate as string
    * @return String
    */
    private String delegatesValueAssignment(AITM_CountryAPIWrapperClass.DeliveryPoint del, Map<String,User> mapNTId, String delegate) {
        delegate = delegate +((del.lMDelegate11 == null)?'':(mapNTId.get(del.lMDelegate11.toLowerCase()) != null)?(mapNTId.get(del.lMDelegate11.toLowerCase()).email+';'):''); 
        delegate = delegate +((del.lMDelegate22 == null)?'':(mapNTId.get(del.lMDelegate22.toLowerCase()) != null)?(mapNTId.get(del.lMDelegate22.toLowerCase()).email+';'):''); 
        delegate = delegate +((del.lMDelegate33 == null)?'':(mapNTId.get(del.lMDelegate33.toLowerCase()) != null)?(mapNTId.get(del.lMDelegate33.toLowerCase()).email+';'):''); 
        delegate = delegate +((del.lMDelegate44 == null)?'':(mapNTId.get(del.lMDelegate44.toLowerCase()) !=null)?(mapNTId.get(del.lMDelegate44.toLowerCase()).email+';'):''); 
        delegate = delegate +((del.lMDelegate55 == null)?'':(mapNTId.get(del.lMDelegate55.toLowerCase()) != null)?(mapNTId.get(del.lMDelegate55.toLowerCase()).email+';'):''); 
        delegate = delegate +((del.lMDelegate66 == null)?'':(mapNTId.get(del.lMDelegate66.toLowerCase()) != null)?(mapNTId.get(del.lMDelegate66.toLowerCase()).email+';'):''); 
        return delegate;
    }

}