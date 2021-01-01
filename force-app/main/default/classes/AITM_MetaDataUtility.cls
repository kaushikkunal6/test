/***************************************************************
 * @author           Saravan
 * @date             21/Aug/2020
 * @group            AirBP
 * @description      Class for Metadata updates during Location API Callout

 * history
 * 21/Aug/2020  	 Saravan      Created 
 **********************************************************/
public with sharing class AITM_MetaDataUtility {

    /**
* @description method to upsertMetadata
* @param Set,Set,Boolean
* @return null
*/  
    
    public void upsertMetadata(Set<String> allAddCountryList,Set<String> allUpdateCountryIdList,Boolean updateFlag) {	
         
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        
        String nameSpacePrefix =''; // if the metadata belongs to any package than include the namespace.
       
        if(allAddCountryList.size() > 0){
            for(String countryId:allAddCountryList){                
                //First Record
                if(countryId.length()>0){               
                Metadata.CustomMetadata firstMetadataRec =  new Metadata.CustomMetadata();
                firstMetadataRec.fullName = nameSpacePrefix + 'AITM_API_Modified_Country_List__mdt.'+'CountryId'+countryId;
                firstMetadataRec.label = 'CountryId'+countryId;
                //adding values to fields
                Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
                customField1.field = 'AITM_Country_Id__c';                
                customField1.value = countryId;
                firstMetadataRec.values.add(customField1);
                Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();
                customField2.field = 'AITM_Record_Updated__c';
                customField2.value = FALSE;
                firstMetadataRec.values.add(customField2);
                Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
                customField3.field = 'AITM_LastModifiedDate__c';
                customField3.value = System.now();
                firstMetadataRec.values.add(customField3);
                mdContainer.addMetadata(firstMetadataRec);  //adding record container that will be used to deploy the records in custom metadata.
                }          
            }
        }
        //Update Records
        if(allUpdateCountryIdList.size() > 0){
            for(AITM_API_Modified_Country_List__mdt objMetadata :[SELECT MasterLabel,DeveloperName,AITM_Country_Id__c,AITM_LastModifiedDate__c,AITM_Record_Updated__c FROM AITM_API_Modified_Country_List__mdt where AITM_Country_Id__c in :allUpdateCountryIdList LIMIT 1000]){
                Metadata.CustomMetadata metadataRec =  new Metadata.CustomMetadata();                
                metadataRec.fullName = 'AITM_API_Modified_Country_List__mdt.'+objMetadata.DeveloperName;
                metadataRec.label = objMetadata.MasterLabel;
                Metadata.CustomMetadataValue customFieldtoUpdate = new Metadata.CustomMetadataValue();
                customFieldtoUpdate.field = 'AITM_Record_Updated__c';
                customFieldtoUpdate.value = updateFlag;
                
                metadataRec.values.add(customFieldtoUpdate);
                mdContainer.addMetadata(metadataRec);
            }
        }
        
        // Enqueue custom metadata deployment
        // jobId is the deployment ID
        
        if(!Test.isRunningTest()){ 
            AITM_CustomMetadataCallback callback = new AITM_CustomMetadataCallback();                       
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);            
            
        }
    }
    
    /**
* @description method to createMetadata
* @param Set
* @return null
*/  
    
    public void createMetadata(Set<String> allAddCountryList) {	
         
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        
        String nameSpacePrefix =''; // if the metadata belongs to any package than include the namespace.
        
        if(allAddCountryList.size() > 0){
            for(String countryId:allAddCountryList){                
                //First Record
                
                Metadata.CustomMetadata firstMetadataRec =  new Metadata.CustomMetadata();
                firstMetadataRec.fullName = nameSpacePrefix + 'AITM_API_Modified_Country_List__mdt.'+'CountryId'+countryId;
                firstMetadataRec.label = 'CountryId'+countryId;
                //adding values to fields
                Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
                customField1.field = 'AITM_Country_Id__c';               
                customField1.value = countryId;
                firstMetadataRec.values.add(customField1);
                Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();
                customField2.field = 'AITM_Record_Updated__c';
                customField2.value = FALSE;
                firstMetadataRec.values.add(customField2);
                Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
                customField3.field = 'AITM_LastModifiedDate__c';
                customField3.value = System.now();
                firstMetadataRec.values.add(customField3);
                mdContainer.addMetadata(firstMetadataRec);  //adding record container that will be used to deploy the records in custom metadata.
                
                
            }
        }
                
        // Enqueue custom metadata deployment
        // jobId is the deployment ID
        
        if(!Test.isRunningTest()){ 
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);            
        }
          
    }
    
       /**
* @description method to updateMetadata
* @param null
* @return null
*/  
        
    public void updateMetadata() {
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        for(AITM_API_Modified_Country_List__mdt objMetadata :[SELECT MasterLabel,DeveloperName,AITM_Country_Id__c,AITM_LastModifiedDate__c,AITM_Record_Updated__c FROM AITM_API_Modified_Country_List__mdt LIMIT 1000]){
            Metadata.CustomMetadata metadataRec =  new Metadata.CustomMetadata();            
            metadataRec.fullName = 'AITM_API_Modified_Country_List__mdt.'+objMetadata.DeveloperName;
            metadataRec.label = objMetadata.MasterLabel;
            Metadata.CustomMetadataValue customFieldtoUpdate = new Metadata.CustomMetadataValue();
            customFieldtoUpdate.field = 'AITM_Record_Updated__c';
            customFieldtoUpdate.value = FALSE;
            customFieldtoUpdate.field = 'AITM_LastModifiedDate__c';
            customFieldtoUpdate.value = System.now();
            metadataRec.values.add(customFieldtoUpdate);
            mdContainer.addMetadata(metadataRec);
        }
        if(!Test.isRunningTest()){         
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);          
        }
       
        
    }
    
       /**
* @description method to updateMetadata
* @param String, Boolean
* @return null
*/  
    
    public void updateMetadata(String actCountryId,Boolean isSuccess) {
		      
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        for(AITM_API_Modified_Country_List__mdt objMetadata :[SELECT MasterLabel,DeveloperName,AITM_Country_Id__c,AITM_LastModifiedDate__c,AITM_Record_Updated__c FROM AITM_API_Modified_Country_List__mdt WHERE AITM_Country_Id__c = :actCountryId LIMIT 1000]){
            Metadata.CustomMetadata metadataRec =  new Metadata.CustomMetadata();            
            metadataRec.fullName = 'AITM_API_Modified_Country_List__mdt.'+objMetadata.DeveloperName;
            metadataRec.label = objMetadata.MasterLabel;
            Metadata.CustomMetadataValue customFieldtoUpdate1 = new Metadata.CustomMetadataValue();
            Metadata.CustomMetadataValue customFieldtoUpdate2 = new Metadata.CustomMetadataValue();
          
            if(isSuccess){               
            customFieldtoUpdate1.field = 'AITM_Record_Updated__c';
            customFieldtoUpdate1.value = isSuccess;
            metadataRec.values.add(customFieldtoUpdate1);
            customFieldtoUpdate2.field = 'AITM_LastModifiedDate__c';
            customFieldtoUpdate2.value = System.now();
            metadataRec.values.add(customFieldtoUpdate2);
            } 
            else{                
            customFieldtoUpdate1.field = 'AITM_Record_Updated__c';
            customFieldtoUpdate1.value = isSuccess;
            metadataRec.values.add(customFieldtoUpdate1);
            }
            
            mdContainer.addMetadata(metadataRec);
        }
        if(!Test.isRunningTest()){              
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);        
        }
       
        
    }
    
       /**
* @description method to updateMetadata
* @param Set,Boolean
* @return null
*/  
    
    public void updateMetadata(Set<string> CountrySet,Boolean updateTag) {       
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        for(AITM_API_Modified_Country_List__mdt objMetadata :[SELECT MasterLabel,DeveloperName,AITM_Country_Id__c,AITM_LastModifiedDate__c,AITM_Record_Updated__c FROM AITM_API_Modified_Country_List__mdt where AITM_Country_Id__c in :CountrySet LIMIT 1000]){
            Metadata.CustomMetadata metadataRec =  new Metadata.CustomMetadata();            
            metadataRec.fullName = 'AITM_API_Modified_Country_List__mdt.'+objMetadata.DeveloperName;
            metadataRec.label = objMetadata.MasterLabel;
            Metadata.CustomMetadataValue customFieldtoUpdate = new Metadata.CustomMetadataValue();
            Metadata.CustomMetadataValue customFieldtoUpdate1 = new Metadata.CustomMetadataValue();
            customFieldtoUpdate.field = 'AITM_Record_Updated__c';
            customFieldtoUpdate.value = updateTag;
            metadataRec.values.add(customFieldtoUpdate);
            customFieldtoUpdate1.field = 'AITM_LastModifiedDate__c';
            customFieldtoUpdate1.value = System.now();            
            metadataRec.values.add(customFieldtoUpdate1);
            mdContainer.addMetadata(metadataRec);
        }
        if(!Test.isRunningTest()){ 
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
            
        }
       
        
    }
    
       /**
* @description method to callback
* @param null
* @return null
*/  
    
    public with sharing class AITM_CustomMetadataCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result,
                                 Metadata.DeployCallbackContext context) {
                                     
                                     if (result.status == Metadata.DeployStatus.Succeeded) {                                         
                                         AITM_AirBPCountryAPIBatch cab = new AITM_AirBPCountryAPIBatch();
                                         if(!test.isRunningTest()){      	
                                             Database.executeBatch(cab, 1);       
                                         }
                                         
                                     } else {
                                         // Deployment was not successful
                                         System.debug('Metadata Creation Fail: '+ result);
                                     }
                                     
                                 }
    }
    
}