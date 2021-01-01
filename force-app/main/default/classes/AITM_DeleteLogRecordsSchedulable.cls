global with sharing class AITM_DeleteLogRecordsSchedulable implements Schedulable{

    global void execute(SchedulableContext SC) {
 		clearLogs();
    }

    public static void clearLogs(){
    	List<AITM_Log__c> logs = [SELECT Id FROM AITM_Log__c WHERE CreatedDate < LAST_N_DAYS:30];
        if(!logs.isEmpty()){
        	 delete logs;
        }   
    }

}