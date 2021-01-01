/***********************************************************************************************
 * @author           Neeti
 * @date             01/December/2019
 * @group            AirBP
 * @description      Test class of AITM_MassEditRLCtrlTest

 * history
 * 01/December/2019  Neeti         Created
 * 19/Aug/2019       Kunal         update myTestMethod by adding taxes parameter
 *************************************************************************************/
@isTest
public with sharing class AITM_MassEditRLCtrlTest {
        
           /**
            * @description method to call insert, update , api call on the object records
            * @param null
            * @return void
            */
           static testMethod void myTestMethod() {
      //      AITM_MassEditRLCtrl.fetchOrgInfo();
            
            Account acc = new Account(Name='New Account');
            insert acc;
            AITM_MassEditRLCtrl.getRecObjectAndName(acc.id);
            Contact con = new Contact(FirstName='test',LastName='test',AccountId=acc.id);
            insert con;
            Event ev = new Event(SUBJECT='test',ActivityDateTime=Date.today(),DurationInMinutes=10);
            insert ev;
            Task t = new Task(SUBJECT='test',STATUS='not started');
            String sessionID=UserInfo.getSessionId();
            
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('AITM_MassEditAnythingJsonMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            AITM_MassEditRLCtrl.MassEditLayout mel = AITM_MassEditRLCtrl.getLayout(acc.id,'Account',sessionID);
            AITM_MassEditRLCtrl.MassEditLayout mel1 = AITM_MassEditRLCtrl.getLayout(acc.id,'AITM_Tender_Location_Taxes_and_Fees__c',sessionID);
            List<string> allfields = new List<string>();
            allfields.add('name');
            System.assertEquals('', mel.layoutId);
            AITM_MassEditRLCtrl.RList rl = new AITM_MassEditRLCtrl.RList();
            rl.columns = new list<AITM_MassEditRLCtrl.Column>();
            rl.allFields =new List<string>(allfields);
            rl.objectname = 'AITM_Tender_Location_Taxes_and_Fees__c';
            rl.field = 'id';   
            for (AITM_MassEditRLCtrl.RList aRL : mel.relatedLists){
                 String rlJSON = JSON.serialize(aRL);
                 //AITM_MassEditRLCtrl.getRecords(acc.id,'Account',rlJSON,'30'); 
            }
            String rlJSON = JSON.serialize(mel.relatedLists[0]);
           // AITM_MassEditRLCtrl.getRecords(acc.id,'Account',rlJSON,'30'); 
            
            AITM_MassEditRLCtrl.HtmlInputType HIT = new AITM_MassEditRLCtrl.HtmlInputType('TEXTAREA');
            HIT = new AITM_MassEditRLCtrl.HtmlInputType('CURRENCY');
            HIT = new AITM_MassEditRLCtrl.HtmlInputType('DATE');
            HIT = new AITM_MassEditRLCtrl.HtmlInputType('BOOLEAN');
            HIT = new AITM_MassEditRLCtrl.HtmlInputType('CALCULATED');
            HIT = new AITM_MassEditRLCtrl.HtmlInputType('PICKLIST');
            HIT = new AITM_MassEditRLCtrl.HtmlInputType('EMAIL');
            HIT = new AITM_MassEditRLCtrl.HtmlInputType('PHONE');
            HIT = new AITM_MassEditRLCtrl.HtmlInputType('URL');
            
            Contact A = new Contact(LastName='Smith'); //TO INSERT
            Contact B = new Contact(LastName='Smith'); //TO UPDATE
            Contact C = new Contact(LastName='Smith'); //TO DELETE
            Contact[] LA = new list<Contact>(); LA.add(A);
            Contact[] LB = new list<Contact>(); LB.add(B);
            Contact[] LC = new list<Contact>(); LC.add(C);
            List<AITM_Tender_Location_Taxes_and_Fees__c> listoftaxes = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
            insert LB; insert LC;
            AITM_MassEditRLCtrl.saveRecords('Contact',LA,LB,LC,listoftaxes);
            
            AITM_MassEditRLCtrl.RList rl2 = AITM_MassEditRLCtrl.extractRelatedList(rl,'Account',new AITM_MassEditRLCtrl.sortProperties('Name',true));
          // AITM_MassEditRLCtrl.RList rl3 = AITM_MassEditRLCtrl.extractRelatedList(rl,'OpportunityTeamMember',new AITM_MassEditRLCtrl.sortProperties('Name',true));
               List<String> getcur=AITM_MassEditRLCtrl.getListOfCurrency(); 
               AITM_MassEditRLCtrl.saveTaxRecords(listoftaxes);
               list<sobject> recList = AITM_MassEditRLCtrl.getRecords(LB[0].id,'contact',JSON.serialize(rl), '10');
              
               Test.stopTest();
           }
}