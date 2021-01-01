/***************************************************************
* @author           Neeti 
* @date             01/July/2020
* @group            AirBP
* @description      Batch class for Mulesoft Airbp Location API Callout

* history
* 16/June/2020     Saravana Surendran      Created 
* 30/Sep/2020      Saravana Surendran      Modified the userdetails query to handle datamigration user 
* 31/Dec/2020      srnandan                refactor the code and removed ununsed variables
**********************************************************/
public with sharing class AITM_AirBPCountryAPIBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public List <AITM_Location__c > locList = new List <AITM_Location__c> ();
    public List <AITM_Delivery_Point__c > delList = new List <AITM_Delivery_Point__c> ();
    public List <Contact> acList = new List <Contact>();
    public List <AITM_Delivery_Point_Airport_Contact__c> dpacList = new List <AITM_Delivery_Point_Airport_Contact__c>();
    public final String AIRBP_CUSTOMER_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AirBP_Customer').getRecordTypeId();
    public Set<string> countryIdSet = new Set<string>();
    public Map<string,User> ntIDMap = new Map<string,User>();
    public Map<string,id> pbIDMap = new Map<string,id>();
    String accId = [SELECT Id FROM Account WHERE Name = 'NA - This is a Location Contact' AND AITM_GRN__c = null AND RECORDTYPEID =:AIRBP_CUSTOMER_RECORDTYPEID LIMIT 1].Id;
    
   /**
    * @description constructor
    * @param null  
    * @return null
    */  
    public AITM_AirBPCountryAPIBatch() {
        
        for(User uDetail: [SELECT Username, Name, Email, IsActive, NTID__c FROM User 
                            WHERE (UserRole.Name='AirBP' OR NTID__c  =: System.Label.AITM_LocationOwner) 
                            AND IsActive=True LIMIT  1000]) {
            string ntid = uDetail.NTID__c;
            if(ntid != null) {
                ntIDMap.put(ntid.toLowerCase() , uDetail);
            } 
        }
        
        for(AITM_Pricing_Basis__c pb: [SELECT AITM_Pricing_Basis_Code__c, Name FROM AITM_Pricing_Basis__c 
                                    WHERE name =: System.Label.AITM_Not_Represented 
                                    OR AITM_Not_Represented__c = false LIMIT 10000]) {
            pbIDMap.put(pb.name,pb.id);
        }
    }
    
    /**
     * @description start method of the batch
     * @param BatchableContext  
     * @return List collection
     */
    public Iterable<sObject> start(Database.batchableContext BC){
        List<sObject> newList = [SELECT AITM_Country_Id__c, AITM_LastModifiedDate__c, AITM_Record_Updated__c, Label 
                                FROM AITM_API_Modified_Country_List__mdt 
                                WHERE AITM_Country_Id__c NOT IN ('NonAirBPOp', 'FirstRec','') 
                                AND AITM_Record_Updated__c = FALSE LIMIT 1000];
        
        if(test.isRunningTest()) {
            newList = [SELECT AITM_Country_Id__c, AITM_LastModifiedDate__c, AITM_Record_Updated__c, Label 
                      FROM AITM_API_Modified_Country_List__mdt 
                      WHERE AITM_Country_Id__c NOT IN ('NonAirBPOp', 'FirstRec','')  LIMIT 1];
        }
        
        return newList;
    }
    
    /**
     * @description execute method of the batch
     * @param BatchableContext and List of country Id 
     * @return null
     */
    public void execute(Database.BatchableContext bc, List <AITM_API_Modified_Country_List__mdt> scope) {
        
        if (scope.size() > 0) {
            for (AITM_API_Modified_Country_List__mdt queryObject: scope) {
                
                AITM_Location_API_Callouts callObject = new AITM_Location_API_Callouts();
                HTTPResponse hResp1;

                if(queryObject.AITM_Country_Id__c != null) {
                    try {
                        String responseBody = '';
                        hResp1 = callObject.getCountryListCallout(queryObject.AITM_Country_Id__c);
                        responseBody = hResp1.getBody();
                        if(hResp1.getStatusCode() == 200 && !responseBody.contains('Invalid CountryID')) {

                            AITM_CountryAPIWrapperClass countryAPIWrapper = new AITM_CountryAPIWrapperClass();
                            AITM_CountryAPIWrapperClass.FinalWrapper finWrap = new AITM_CountryAPIWrapperClass.FinalWrapper();
                            finWrap = countryAPIWrapper.convertList(responseBody, ntIDMap, pbIDMap, accId);
                            
                            countryIdSet.add(queryObject.AITM_Country_Id__c);

                            for (AITM_Location__c loc: finWrap.locdelmap.keySet()) {
                                locList.add(loc);
                                delList.addAll(finWrap.locdelmap.get(loc));
                            }

                            Set<Contact> airPortContacts = new Set<Contact>();
                            Set<AITM_Delivery_Point_Airport_Contact__c> airPortDelPoints = new Set<AITM_Delivery_Point_Airport_Contact__c>();

                            for (AITM_Delivery_Point__c del : delList) {
                                
                                if(finWrap.aircondelmap.get(del) != null)
                                    airPortContacts.addAll(finWrap.aircondelmap.get(del));
                                if(finWrap.dpacdpmap.get(del) != null)
                                    airPortDelPoints.addAll(finWrap.dpacdpmap.get(del));
                            }                                                     
                            acList.addAll(airPortContacts);
                            dpacList.addAll(airPortDelPoints);
                            
                            finalmethodCall();
                            resetElements();
                        } else {
                            AITM_Log.createErrorMessage('validateMulesoftResponse'+'id:'+ queryObject.AITM_Country_Id__c + 'Response:' + hResp1, 'id:' + queryObject.AITM_Country_Id__c,'Response:'+ hResp1, 'getCountryListCallout','', 'Error',null);  
                        }
                    } catch(Exception e) { 
                        AITM_Log.createErrorMessage('validateMulesoftResponse'+'id:'+ queryObject.AITM_Country_Id__c + 'Response:' + hResp1, 'id:' + queryObject.AITM_Country_Id__c,'Response:'+ hResp1, 'getCountryListCallout','', 'Error',null);
                    }
                } else {
                    AITM_Log.createErrorMessage('validateMulesoft API Parameter country Id '+ queryObject.AITM_Country_Id__c , 'id' + queryObject.AITM_Country_Id__c,'Response:No', '','', 'Error',null);  
                }
            }
        }
    }
    
    /**
     * @description reset list collections
     * @return null
     */ 
    public void resetElements(){
        locList = new List <AITM_Location__c>();
        delList = new List <AITM_Delivery_Point__c>();
        acList = new List <Contact>();
        dpacList = new List <AITM_Delivery_Point_Airport_Contact__c>();
    }
    
    /**
     * @description method to upsert the location list and deliverypoint list
     * @param BatchableContext  
     * @return null
     */ 
    public void finalMethodCall() {
        Schema.SObjectField externalKeyLoc = AITM_Location__c.Fields.AITM_SCM_Location_Unique_ID__c;
        Schema.SObjectField externalKeyPb = AITM_Pricing_Basis__c.Fields.AITM_Pricing_Basis_Code__c;
        Schema.SObjectField externalKeyDp = AITM_Delivery_Point__c.Fields.AITM_Dealer_ID__c;
        Schema.SObjectField externalKeyAc = Contact.Fields.AITM_Unique_ID__c;
        Schema.SObjectField externalKeyDpac = AITM_Delivery_Point_Airport_Contact__c.Fields.AITM_Unique_ID__c;
       
        Set<Id> SuccessId = new Set<Id>();
        Set<String> locationuniqSet= new Set<String>();
        List<AITM_Log__c> logsToInsert = new List<AITM_Log__c>();               
        
        Database.UpsertResult[] locationResult = Database.upsert(locList, externalKeyLoc, false);
        Database.UpsertResult[] dpResult = Database.upsert(delList, externalKeyDp, false);
       
        if (acList.size() < Limits.getLimitDmlRows()) {
            
            Database.UpsertResult[] acResult;
            try {
                acResult = Database.upsert(acList,externalKeyAc,false);
            } catch(Exception ex) {
                logsToInsert.add(AITM_Log.draftErrorMessage('finalMethodCall upsert airport contact'+ ex.getMessage()));
            }
            
            for(Database.UpsertResult acres : acResult) {
                if(acRes.isSuccess()){
                    SuccessId.add(acRes.getId()); 
                } else {
                    // DML operation failed
                    Database.Error error = acRes.getErrors().get(0);
                    String failedDML = error.getMessage();
                }
            }
        }
        
        if (dpacList.size() < Limits.getLimitDmlRows()) {
            Database.UpsertResult[] dpacResult;
            try{ 
                Set<String> emails = new Set<String>(); 
                Set<String> deliveries = new Set<String>();  
                Map<String, Id> emailWithContactIdMap = new Map<String, Id>();
                Map<String, Id> delWithDelIdMap = new Map<String, Id>();
                List <AITM_Delivery_Point_Airport_Contact__c> dpacs = new List <AITM_Delivery_Point_Airport_Contact__c>();
                for(Contact con: acList)
                    emails.add(con.Email);
                for(AITM_Delivery_Point__c del: delList)
                    deliveries.add(del.AITM_Delivery_Point_Unique_ID__c);
                for(Contact con: [SELECT ID, Email FROM Contact WHERE Email IN: emails])
                    emailWithContactIdMap.put(con.Email, con.Id);
                for(AITM_Delivery_Point__c del: [SELECT 
                                                    ID, 
                                                    Name, 
                                                    AITM_Delivery_Point_Unique_ID__c 
                                                FROM AITM_Delivery_Point__c 
                                                WHERE AITM_Delivery_Point_Unique_ID__c IN: deliveries 
                                                AND AITM_Is_Active__c = true
                                                ])
                    delWithDelIdMap.put(del.AITM_Delivery_Point_Unique_ID__c, del.Id);
                for(AITM_Delivery_Point_Airport_Contact__c ins: dpacList) {
                    if(delWithDelIdMap.containsKey(ins.AITM_Delivery_Point__r.AITM_Delivery_Point_Unique_ID__c)) {
                        AITM_Delivery_Point_Airport_Contact__c dpacJunc = new AITM_Delivery_Point_Airport_Contact__c();
                        dpacJunc.AITM_Airport_Contact__c = emailWithContactIdMap.get(ins.AITM_Airport_Contact__r.Email);
                        dpacJunc.AITM_Delivery_Point__c = delWithDelIdMap.get(ins.AITM_Delivery_Point__r.AITM_Delivery_Point_Unique_ID__c);
                        dpacJunc.AITM_Unique_Id__c = ins.AITM_Unique_Id__c; 
                        dpacJunc.AITM_Roles__c = ins.AITM_Roles__c;   
                        dpacs.add(dpacJunc);    
                    }    
                }
                dpacResult = Database.upsert(dpacs,externalKeyDpac,false);
            } catch(Exception ex) {
                logsToInsert.add(AITM_Log.draftErrorMessage('finalMethodCall upsert delivery point airport contact'+ ex.getMessage()));
            }

            for(Database.UpsertResult dpacres : dpacResult) {
                if(dpacres.isSuccess()){                 
                    SuccessId.add(dpacres.getId());
                } else {
                    // DML operation failed
                    Database.Error error = dpacres.getErrors().get(0);
                    String failedDML = error.getMessage();
                }
            }
        }
        
        for(Integer i=0;i<dpResult.size();i++) {
            if(dpResult.get(i).isSuccess()) {                 
                SuccessId.add(dpResult.get(i).getId());                                            
            } else {
                // DML operation failed
                Database.Error error = dpResult.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                locationuniqSet.add(delList.get(i).AITM_Location__r.AITM_SCM_Location_Unique_ID__c);
                logsToInsert.add(AITM_Log.draftErrorMessage('validateMulesoftResponse-Upsert Delivery Point'+delList.get(i).AITM_Dealer_ID__c+'-'+error.getMessage()));
            }
        }
        
        for(Integer i=0;i<locationResult.size();i++) {
            if (locationResult.get(i).isSuccess()) {
                SuccessId.add(locationResult.get(i).getId());
                if(locationuniqSet.contains(locList.get(i).AITM_SCM_Location_Unique_ID__c )) {  
                    countryIdSet.remove(locList.get(i).AITM_Country_Id__c);
                }  
            } else {
                // DML operation failed
                Database.Error error = locationResult.get(i).getErrors().get(0);
                logsToInsert.add(AITM_Log.draftErrorMessage('validateMulesoftResponse-Upsert Location'+ locList.get(i).AITM_SCM_Location_Unique_ID__c+'-'+error.getMessage()));
                countryIdSet.remove(locList.get(i).AITM_Country_Id__c);
            }
        }
        
        if(logsToInsert != null) {
            insert logsToInsert;
        }     
 
    }
    
    /**
     * @description method to upsert the location list
     * @param BatchableContext  
     * @return null
     */  
    public void finish(Database.BatchableContext BC) {
        
        if(countryIdSet.size() > 0) {
            AITM_MetaDataUtility mdUtility = new AITM_MetaDataUtility();
            mdUtility.updateMetadata(countryIdSet, TRUE);
        }
    }
    
}