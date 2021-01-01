/***************************************************************
 * @author           Shweta
 * @date             22/Jan/2020
 * @group            AirBP
 * @description      Test class for the flow coverage of the flow AITM_Updated_Roles_On_Contact

 * history
 * 22/Jan/2020  	 Shweta        Created 
 **********************************************************/

@isTest 
private inherited sharing class AITM_Updated_Roles_On_ContactTest{ 
 /**
      * @description tests to insert Account and Contact and update the role on accountcontact relationship
      * @param  null
      * @return void
      */   
    
@isTest
    static void CheckForUpdatedRoles(){
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        insert testAccount;
        // Create Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Test1';
        testContact.Email = 'sahh@gmail.com'; 
        testContact.AccountId = testAccount.Id;
        insert testContact;
        Test.startTest();
        AccountContactRelation testAccountContactRelation = new AccountContactRelation();        
        testAccountContactRelation = [Select Id,AITM_Roles__c from AccountContactRelation where AccountId =:testAccount.Id];
        Test.stopTest();
        System.assertEquals('Card',testAccountContactRelation.AITM_Roles__c);
        
        testAccountContactRelation.AITM_Roles__c = 'Card;Operations';
        update testAccountContactRelation;
        System.assertEquals('Card;Operations',testAccountContactRelation.AITM_Roles__c);
        
        
    }
    
   
    
}