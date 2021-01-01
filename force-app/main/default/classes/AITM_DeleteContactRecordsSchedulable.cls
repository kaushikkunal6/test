public with sharing class AITM_DeleteContactRecordsSchedulable implements Schedulable {
    public void execute(SchedulableContext sc){
         AITM_ContactDeletionBatch deleteBatch = new  AITM_ContactDeletionBatch(); 
         database.executebatch(deleteBatch);
    }
    

}