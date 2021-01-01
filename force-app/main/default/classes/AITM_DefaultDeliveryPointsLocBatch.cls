/***************************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            IBM
 * @description      Batch Class for the creation of the default delivery points of the locations

 * history
 * 01/December/2017  George       Created
 * 23/Aug/2018       Shweta       Modified-Added with sharing keyword,Limit set to 100 in the start method and comments for each method
                                                               
 ****************************************************************************************************/


global with sharing class AITM_DefaultDeliveryPointsLocBatch implements Database.Batchable<sObject> {
   public String query;

   /**
     * @description start method of the batch class querying first 100 rows
     * @param BC of the type interface Database.BatchableContext     
     * @return record set returned by Database.getQueryLocator
     */

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator([SELECT Id, AITM_IATA__c, AITM_ICAO__c FROM AITM_Location__c LIMIT 100]);
   }
   
   /**
     * @description execute method of the batch class to insert each batch of the records
     * @param BC of the type interface BatchableContext     
     * @return void
     */


   global void execute(Database.BatchableContext BC, List<AITM_Location__c> scope){
       List<AITM_Delivery_Point__c> deliveryPoints = new List<AITM_Delivery_Point__c>();
       for(AITM_Location__c location : scope){
           deliveryPoints.add(
               new AITM_Delivery_Point__c(
                   Name = 'DEFAULT', 
                   AITM_Location__c = location.Id, 
                   AITM_Delivery_Point_Number__c = '01', 
                   AITM_Default__c = true
               )
           );
       }
       insert deliveryPoints;
   }

   /**
     * @description finish method of the batch class to execute post processing operations
     * @param BC of the type interface BatchableContext     
     * @return void
     */

   global void finish(Database.BatchableContext BC){
   }
}