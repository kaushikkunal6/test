/***************************************************************************************************
 * @author           Shweta
 * @date             05/Feb/2020
 * @group            IBM
 * @description      Test Batch Class for the deletion of the contacts marked as 'Is Deleted'

 * history
 * 05/Feb/2020       Shweta      Created
 
                                                               
******************************************************************************************************/

@isTest
public with sharing class AITM_ContactDeletionBatchTest {

    /**
     * @description test should delete the contact records with Is Deleted flag as checked 
     * @param null
     * @return void
     */
   
    @isTest
    static void TestDeleteContacts(){ 

       Test.startTest();
       AITM_ContactDeletionBatch obj = new AITM_ContactDeletionBatch();
       Database.executeBatch(obj);
       Test.stopTest();

       
       List<Contact> con = [Select Id from Contact where AITM_Is_Deleted__c = true AND RecordType.DeveloperName ='General_Contact'];
       System.assertEquals(0,con.size(),'The size of the records is 0');     
   }      

}