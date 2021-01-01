@isTest
public inherited sharing class AITM_DeleteContactRecordsSchedulableTest {
    @isTest    
    public static void first(){
        Test.startTest();
        AITM_DeleteContactRecordsSchedulable obj = new AITM_DeleteContactRecordsSchedulable();         
        String sch = '0 0 2 * * ?';
        system.schedule('Test Delete Contact',sch,obj);
        Test.stopTest();
        List<Contact> con = [Select Id from Contact where AITM_Is_Deleted__c = true AND RecordType.DeveloperName ='General Contact'];
        System.assertEquals(0,con.size(),'The size of the records is 0');     
        
        
    }
    
    

}