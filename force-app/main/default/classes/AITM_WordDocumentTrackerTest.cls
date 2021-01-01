/**************************************************************************
 * @author           Shweta
 * @date             08/Sept/2020
 * @group            AirBP
 * @description      Test class for AITM_WordDocumentTracker class

 * history
 * 08/Sept/2020  Shweta      Work Item 190772
 *******************************************************************/
@isTest
private class AITM_WordDocumentTrackerTest {
     /**
     * @description tests to check if the word documents are there or not
     * @param  null
     * @return null
     */ 

     @isTest
     static void testCreateContentVersionWillCreate(){
          Date ss = date.today();
          String s = String.valueOf(ss);
          Test.startTest();
         	List<AITM_WordDocumentTracker.DocumentWrapper> rr = AITM_WordDocumentTracker.fetchDoc(s,s);
          Test.stopTest();
          System.assertEquals(0,rr.size(),'One Document is not  generated');
    }        
        
    
     private inherited sharing class Test_AITMControllerSetUpTest extends AITM_TestSetup {        
        private AITM_Tender__c tender; 
        private Account acc;
        private AITM_Tender_Account__c tenderAccount;
         
          private Test_AITMControllerSetUpTest() {
               tender = createTender();
               insert tender;
               acc = createAccount();
               insert acc;
               tenderAccount = createTenderAccount(tender.Id,acc.Id);
               ContentVersion contractFile = new ContentVersion(
                 VersionData = Blob.valueOf('Test Content'),
                 Origin = 'H',
                 Title = 'Test Document',
                 PathOnClient = 'TestDocument.docx'
              );            
    
               insert contractFile;
              
              ContentDocumentLink contentlink=new ContentDocumentLink();
                 contentlink.LinkedEntityId=tender.id;
                 contentlink.ShareType= 'C';        
                 contentlink.ContentDocumentId=contractFile.ContentDocumentId;
                 contentlink.Visibility = 'AllUsers';        
              
               insert contentlink;
       
          }  
     }     


}