/***************************************************************************************************
* @author           Saravan
* @date             17/May/2020
* @group            IBM
* @description      Batch Class for the Mulesoft Airbp Location API Callout

* history
* 17/May/2020       Saravan      Created


****************************************************************************************************/
public with Sharing class  AITM_AirBPCountryListAPIBatch implements Database.Batchable<string>,Database.Stateful, Database.AllowsCallouts{
    
    public List <AITM_API_Modified_Country_List__mdt> newList = new List <AITM_API_Modified_Country_List__mdt> ();
    
    /**
* @description start method of the batch
* @param BatchableContext  
* @return List collection
*/
    
    public Iterable<string> Start(Database.BatchableContext context){ 
        
        return new List<String> { 'start Batch' };
            
            }    
    
    /**
* @description execute method of the batch
* @param BatchableContext and List of country Id 
* @return null
*/
    
    public void execute(Database.BatchableContext bc, List <string> scope){
        
        newList = ([SELECT Id, AITM_Country_Id__c, AITM_LastModifiedDate__c, AITM_Record_Updated__c FROM AITM_API_Modified_Country_List__mdt WHERE AITM_Country_Id__c != 'NonAirBPOp' AND AITM_Record_Updated__c = True ORDER BY AITM_LastModifiedDate__c DESC LIMIT 1]);
        if(newList.size( )> 0 && newList.get(0).get('AITM_LastModifiedDate__c')!= NULL){
            List<String> allCountryIdList = new List<String>();
            List<String> allOldRunCountryIdList = new List<String>();
            Set<String> allOldRunFailedCountryIdList = new Set<String>();
            Set<String> allOldRunSuccessCountryIdList = new Set<String>();
            List<AITM_API_Modified_Country_List__mdt> allOldRunModifiedCountryList = new List<AITM_API_Modified_Country_List__mdt>(); 
            List<AITM_API_Modified_Country_List__mdt> allNewModifiedCountryList = new List<AITM_API_Modified_Country_List__mdt>();
            AITM_API_Modified_Country_List__mdt newCountry;
            String modifiedTime='';           
                       
            
            DateTime lastModified = (DateTime) newList.get(0).get('AITM_LastModifiedDate__c');
            String lastModifiedString = lastModified.format('yyyy-MM-dd HH:mm:ss');
            lastModifiedString = lastModifiedString.replace(' ', '%20');            
            String modifiedParam = '?ModifiedDate='+lastModifiedString;
            
            AITM_Location_API_Callouts lt = new AITM_Location_API_Callouts();         
            
            
            try{                  
                HTTPResponse hResp1 = lt.getCountryModifiedCallout(modifiedParam);
                if(hResp1.getStatusCode() == 200) {
                    String str = hResp1.getBody();
                    str=str.replace('[', '');
                    str=str.replace(']','');
                   
                    allCountryIdList = str.split(',');                   
                    if(allCountryIdList.size() > 0){
                        allOldRunModifiedCountryList = [SELECT Id, AITM_Country_Id__c, AITM_Record_Updated__c from AITM_API_Modified_Country_List__mdt WHERE AITM_Country_Id__c NOT IN ('NonAirBPOp', 'FirstRec','')];
                        //convert list of sObject to list of String
                        for(AITM_API_Modified_Country_List__mdt cntIdRec: allOldRunModifiedCountryList){
                            if(!cntIdRec.AITM_Record_Updated__c) {
                                allOldRunFailedCountryIdList.add(cntIdRec.AITM_Country_Id__c);
                                allOldRunCountryIdList.add(cntIdRec.AITM_Country_Id__c);
                            }                           
                            for(String cntId: allCountryIdList){
                                if(cntIdRec.AITM_Record_Updated__c && cntIdRec.AITM_Country_Id__c == cntId) {
                                    allOldRunSuccessCountryIdList.add(cntIdRec.AITM_Country_Id__c);
                                    allOldRunCountryIdList.add(cntIdRec.AITM_Country_Id__c);
                                } 
                            }
                            
                            
                        }
                        
                        
                        Set<String> allNewCountryId = new Set<String>(allCountryIdList);                        
                        allNewCountryId.removeAll(allOldRunCountryIdList);    //list of country id not exist in API Modified Country List metadata
                        allOldRunFailedCountryIdList.addAll(allOldRunSuccessCountryIdList);
						AITM_MetaDataUtility mdUtility = new AITM_MetaDataUtility();
                        mdUtility.upsertMetadata(allNewCountryId,allOldRunFailedCountryIdList,FALSE);
                        
                    }    
                }
                else{
                    AITM_Log.createErrorMessage('validateMulesoftResponse - AITM_AirBPCoutryListAPIBatch - Response:'+ hResp1,'' ,'', 'getCountryModifiedCallout','', 'Error',null);  
                }
            }Catch(Exception e){                 
                AITM_Log.createErrorMessage('AITM_AirBPCoutryListAPIBatch'+e.getMessage()+', LineNumber:'+e.getLineNumber());             
            }
        }
        
        
    }
    
    /**
* @description finish method of the batch
* @param BatchableContext  
* @return null
*/
    
    public void finish(Database.BatchableContext BC){
        
        
    }
}