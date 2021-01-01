/**
 * @author Chetna
 * @description AITM_NotifyOwnerChangeTest - Contains tests class for AITM_NotifyOwnerChange
 **/ 
@isTest  
public with sharing class AITM_NotifyOwnerChangeTest {


    /**
     * @description Purpose: To test sendEmailFromProcessBuilder method in AITM_NotifyOwnerChange
     */
    @testSetup 
    static void testData() {
		List<User> accountManagers = new List<User>();
		Account testAccount = new Account();
        AITM_TestSetup testSetup = new AITM_TestSetup();
        
        // create 2 users
        accountManagers = testSetup.createUsers(2, 'Air_TMAccount Manager');
        INSERT accountManagers;
        
        //create an account
        testAccount = testSetup.createAccount();
        testAccount.OwnerId = accountManagers.get(0).Id;
        INSERT testAccount;
    }
    
    /**
     * @description Purpose: To test sendEmailFromProcessBuilder method in AITM_NotifyOwnerChange
     */
    @isTest 
    static void testSendEmailFromProcessBuilder() {
        List<Account> testAccount =  new List<Account>([SELECT Name, AITM_GRN__c FROM Account LIMIT 2]);
        List<User> accountManagers = new List<User>([SELECT Email FROM User LIMIT 2]);
        AITM_NotifyOwnerChange.EmailRequest request = new AITM_NotifyOwnerChange.EmailRequest();
        request.accountName = testAccount.get(0).Name;
        request.accountGRN = testAccount.get(0).AITM_GRN__c;
        request.accountOwner = accountManagers.get(1).Id;
        request.accountOwnerEmail = accountManagers.get(1).Email;

        Integer emailLimitsBefore = Limits.getEmailInvocations();

        System.runAs(accountManagers.get(0)){
            Test.startTest();
	            AITM_NotifyOwnerChange.sendEmailFromProcessBuilder(new List<AITM_NotifyOwnerChange.EmailRequest>{request});
            Test.stopTest();
        }

        Integer emailLimitsAfter = Limits.getEmailInvocations();
        System.assertEquals(emailLimitsBefore, emailLimitsAfter);
    }
}