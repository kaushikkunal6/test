/***************************************************************************************************
* @author           Saravan
* @date             17/May/2020
* @group            IBM
* @description      Batch Class for the Mulesoft NonBP Operated Location API Callout

* history
* 17/May/2020       Saravan      Created


****************************************************************************************************/

public class AITM_AirBPNonOperatedAPIBatch implements Database.Batchable<string>,Database.Stateful, Database.AllowsCallouts{
    public List < AITM_Location__c > listLocs = new List < AITM_Location__c > ();
    public List <AITM_API_Modified_Country_List__mdt> newList = new List <AITM_API_Modified_Country_List__mdt> ();   
    Boolean isSuccess = TRUE;
    
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
    
    public void execute(Database.BatchableContext bc, List<String> scope){
        try{
            newList = ([SELECT Id, AITM_LastModifiedDate__c, DeveloperName, AITM_Country_Id__c from AITM_API_Modified_Country_List__mdt WHERE AITM_Country_Id__c = 'NonAirBPOp' ORDER BY AITM_LastModifiedDate__c DESC LIMIT 1]);
            
            if(newList.size( )> 0 ){
                String modifiedTime='';
                DateTime lastModified = (DateTime) newList.get(0).get('AITM_LastModifiedDate__c');            
                String lastModifiedString = lastModified.format('yyyy-MM-dd HH:mm:ss');
                lastModifiedString = lastModifiedString.replace(' ', '%20');
                
                AITM_Location_API_Callouts lt = new AITM_Location_API_Callouts();            
                
                
                HTTPResponse hResp1 = lt.getNonBPOperatedLocationCallout('?ModifiedDate='+lastModifiedString); 
                
                if(hResp1.getStatusCode() == 200){
                    List<AITM_NonBPOperatedAPIWrapperClass> listLocation = new List<AITM_NonBPOperatedAPIWrapperClass>();
                    listLocation = AITM_NonBPOperatedAPIWrapperClass.parse(hResp1.getBody());  
                    System.debug('listLoactionSize='+listLocation.size());
                    for (Integer i = 0; i < listLocation.size(); i++) {                        
                        AITM_Location__c loc = new AITM_Location__c();   
                        loc.AITM_Location_Type__c = listLocation[i].location_type;
                        if(listLocation[i].location_id != NULL){
                            loc.AITM_SCM_Location_Unique_ID__c = listLocation[i].location_id;
                        }
                        
                        loc.Name = listLocation[i].location_name;
                        loc.AITM_IATA__c = listLocation[i].iata;
                        loc.AITM_ICAO__c = listLocation[i].icao;
                        loc.AITM_Country__c = listLocation[i].location_country;
                        loc.AITM_Country_Id__c = listLocation[i].country_id;
                        if(listLocation[i].source_id != NULL){
                            loc.AITM_Location_Unique_ID__c = listLocation[i].source_id;
                            listLocs.add(loc);  
                        }
                    }  
                    
                    finalmethodCall();
                }
                else{
                    isSuccess = FALSE;                    
                    AITM_Log.createErrorMessage('validateMulesoftResponse - AITM_AirBPNonOperatedAPIBatch - Response:'+ hResp1,'' ,'', 'getNonBPOperatedLocationCallout','', 'Error',null);  
                }
            }
            
        }Catch(Exception e){
            isSuccess = FALSE;
            AITM_Log.createErrorMessage('AITM_AirBPNonOperatedAPIBatch'+e.getMessage()+', LineNumber'+e.getLineNumber());        
            
            
        }
        
    }
    
    /**
* @description method to upsert the location list
* @param BatchableContext  
* @return null
*/
    
    public void finalMethodCall(){         
        Schema.SObjectField externalKeyLoc = AITM_Location__c.Fields.AITM_Location_Unique_ID__c;
        set<id> successId = new set<id>();        
        List<AITM_Log__c> logsToInsert = new List<AITM_Log__c>();
        
        Database.UpsertResult[] locationResult =Database.upsert(listLocs,externalKeyLoc,false);
        
        for(Integer i=0;i<locationResult.size();i++){            
            if (locationResult.get(i).isSuccess()){                
                successId.add(locationResult.get(i).getId());               
                
            }else if (!locationResult.get(i).isSuccess()){  
                
                isSuccess = FALSE;
                Database.Error error = locationResult.get(i).getErrors().get(0);
                String failedDML = error.getMessage(); 
                logsToInsert.add(AITM_Log.draftErrorMessage('validateMulesoftResponse-Upsert AirBPNonOperatedLocation'+listLocs.get(i).AITM_Location_Unique_ID__c+'-'+listLocs.get(i).Name+'-'+error.getMessage()));
                
            }           
            
        } 
        
        if(logsToInsert.size() > 0){
            insert logsToInsert;  
        }
               
    }
    
    /**
* @description finish method of the batch
* @param BatchableContext  
* @return null
*/
    
    public void finish(Database.BatchableContext BC){   
        if (isSuccess){             
            AITM_MetaDataUtility mdUtility = new AITM_MetaDataUtility();
            mdUtility.updateMetadata('NonAirBPOp',isSuccess);  
        }        
        
    }
    
}