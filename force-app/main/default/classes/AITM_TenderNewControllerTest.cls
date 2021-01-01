/*
 * Created by :Neeti
 * Purpose: Test class for AITM_TenderNewController 
*/
@isTest
public class AITM_TenderNewControllerTest {

     @isTest
    static void TestDate() {
        Date today = System.Date.today();
        Test.startTest();
         Date EndDate = AITM_TenderNewController.getEndDate(today);
         System.assert(EndDate != null, 'Date Found');
        Test.stopTest();
    }
      @isTest
    static void TestfetchUser() {
         User newUser1 = new User();
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and isactive = true Limit 1];
        
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        System.runAs(adminUser){
          Account acc1 = new Account (
        Name = 'newAcc1'
        );  
        insert acc1;
        Contact conCase = new Contact (
        AccountId = acc1.id,
        LastName = 'portalTestUserv1'
        );
        insert conCase;
        //Create user

        Profile prfile = [select Id,name from Profile where name  like '%labp%' limit 1];

        newUser1 = new User(
        profileId = prfile.id,
        username = 'newUser@yahoo.com',
        email = 'pb@f.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname',
        contactId = conCase.id
        );
        insert newUser1; 
        }
         Test.startTest();
        System.runAs ( newUser1 ) {
          System.assert(newUser1 != null, 'user Found');
         User userFetch = AITM_TenderNewController.fetchUser();
        }
         Test.stopTest();
    }
    
   
}