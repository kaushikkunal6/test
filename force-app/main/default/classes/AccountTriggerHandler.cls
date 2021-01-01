/**
* @author           Jan Majling
* @date         03/10/2018
* @description      handles trigger events on Account object
*
* history
* 03/10/2018    Jan Majling         Created 
* 15/04/2019   Maros Zilka         Added before Insert/Update handlers
* 07/05/2019   OLCM  
* 15/08/2020   ESA         
*/
public with sharing class AccountTriggerHandler {
    
    private final  List<Account> newRecords;
    private final List<Account> oldRecords;
    private final Map<Id, Account> newMap;
    private final Map<Id, Account> oldMap; 
    /**
    * @description constructor
    * @param newRecords of type List<Account>
    * @param oldRecords of type List<Account>
    * @param newMap of type Map<Id,Account>
    * @param oldMap of type Map<Id,Account>
   */   
    
    public AccountTriggerHandler(List<Account> newRecords, List<Account>
                                 oldRecords, Map<Id, Account> newMap, Map<Id,Account> oldMap){
                                     this.newRecords = newRecords;
                                     this.oldRecords = oldRecords;
                                     this.newMap = newMap;
                                     this.oldMap = oldMap;
                                 }
    
    
    /**
    * @description handles before insert trigger event
    */
    public void handleBeforeInsert() {
    }
    
    /**
   * @description handles before update trigger event
   */
    public void handleBeforeUpdate() {
        OLCM_AccountTriggerHandler.sharingAccountpubgroupdel(newRecords);
    }
    
   /**
    * @description handles beforeInsertUpdate trigger event
      -below method needs to execute based on ESA Sales area value and OLCM user,Mapped required fields based on criteria for both the application.
      -If there is no ESA sales area value then It will work as per the existing logic for OLCM.        
   */
    public void beforeInsertUpdate() {
    system.debug('beforeInsertUpdate***');
        List<Account> OLCM_AccountRecordList =new List<Account>();   
        List<Account> ESA_AccountRecordList =new List<Account>(); 
        for(Account a : newRecords){        
           //system.debug('Record**'+ESA_AccountTriggerHandler.getESABussSalesarea().contains(a.OLCM_Sales_Organisation_Description__c+'/'+a.OLCM_Distribution_Channel_Description__c+'/'+a.OLCM_Sales_Division_Description__c));
            if(String.isnotblank(a.ESA_Sales_Organisation__c) || ESA_AccountTriggerHandler.getESABussSalesarea().contains(a.OLCM_Sales_Organisation_Description__c+'/'+a.OLCM_Distribution_Channel_Description__c+'/'+a.OLCM_Sales_Division_Description__c)){                
             //system.debug('**ESA record**');
             ESA_AccountRecordList.add(a);
            }else{
             //system.debug('**OLCM record**');
             OLCM_AccountRecordList.add(a);
            }
        }
        
        if(ESA_AccountRecordList.size()>0){
         ESA_AccountTriggerHandler.handlerBeforeInsert(newRecords);             
        }
        
        if(OLCM_AccountRecordList.size()>0){
        //system.debug('OLCM_AccountRecordList**'+OLCM_AccountRecordList);
              OLCM_AccountTriggerHandler.checkValidate(OLCM_AccountRecordList); 
        }   
    }
    /**
   * @description handles beforeInsertUpdate sfrecord Id trigger event
   */
    public void beforeInsertUpdatesf() {
        OLCM_AccountTriggerHandler.updateSalesforceID(newRecords);
    }
    
    /**
    * @description handles after update trigger event
    */
    public void handleAfterUpdate() {
        new CAJBP_AccountTriggerHandler(this.newRecords, this.oldMap).handleAfterUpdate();
        OLCM_AccountTriggerHandler.sharingAccountpubgroup(oldRecords);
    }  
    /**
    * @description handles after Insert trigger event
    */
    public void handleAfterInsert() {
         OLCM_AccountTriggerHandler.sendrequest(newRecords);    
        OLCM_AccountTriggerHandler.sharingAccountpubgroup(newRecords);
    } 
}