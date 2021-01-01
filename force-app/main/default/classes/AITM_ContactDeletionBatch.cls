/***************************************************************************************************
 * @author           Shweta
 * @date             05/Feb/2020
 * @group            IBM
 * @description      Batch Class for the deletion of the contacts marked as 'Is Deleted'

 * history
 * 05/Feb/2020       Shweta      Created 
                                                               
 ****************************************************************************************************/
public with sharing class AITM_ContactDeletionBatch implements Database.Batchable<SObject>{

    /**
     * @description start
     * @param  context of type Database.BatchableContext
     * @return Database.QueryLocator
     */ 
    public Database.QueryLocator Start(Database.BatchableContext context){       
        return Database.getQueryLocator([Select Id from Contact where AITM_Is_Deleted__c = true AND RecordType.DeveloperName ='General_Contact' AND lastmodifieddate < LAST_N_DAYS:7]);
    }

    /**
     * @description execute
     * @param  context of type Database.BatchableContext
     * @param  scope of type List<Contact>
     * @return null
     */
    
    public void execute(Database.BatchableContext bc, List<Contact> scope){
        if(scope.size( )> 0){
              delete scope;
        }        
    }

    /**
     * @description finish
     * @param  context of type Database.BatchableContext
     * @return null
     */   
    public void finish(Database.BatchableContext BC){
        
    }
}