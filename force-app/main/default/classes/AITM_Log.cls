/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Trigger handler class for TenderLocationsStaging
 
 * history
 * 01/December/2017  George       Created
 * 23/Aug/2018       Shweta       Modified-Added with sharing keyword and cooments for each method
 **********************************************************************************************/

public with sharing class AITM_Log {

   /**
    * @description createerror message in logs
    * @param errorMessage of type String
    * @return void
    */	

	public static void createErrorMessage(String errorMessage) {
		AITM_Log__c log = new AITM_Log__c(
			AITM_Description__c = errorMessage
		);
		insert log;
	}
    
    /**
    * @description createerror message in logs
    * @param errorMessage of type String
    * @param methodName of type String
    * @param sourceRecordId of type String  
    * @param errorType of type String   
    * @return void
    */ 
    public static String createErrorMessage(String errorMessage, String requestBody, String responseBody, String methodName, String sourceRecordId, String errorType, String logID) {
        String recordId;
        AITM_Log__c Insertlog = new AITM_Log__c(
            AITM_Description__c = errorMessage,
            AITM_Method_Name__c = methodName,
            AITM_SourceRecordID__c = sourceRecordId,
            AITM_Error_Type__c = errorType,
            AITM_Request_Body__c = requestBody                      
        );
        if(logID == null){
           insert Insertlog;
           recordId = Insertlog.Id;
        }else{
         AITM_Log__c Updatelog = new AITM_Log__c(Id = Id.valueOf(logID), AITM_Response__c = responseBody);   
         update Updatelog;
        }                
        return recordId;
    }

    /**
    * @description createerror message in logs
    * @param errorMessage of type String       
    * @return AITM_Log
    */ 
    
    public static AITM_Log__c draftErrorMessage(String errorMessage) {
        AITM_Log__c log = new AITM_Log__c(
            AITM_Description__c = errorMessage
        );
                   
        return log;
    }

}