/*****************************************************************************************
*   Date:           22AUG19
*   Author:         Nilang Pandey – TCS (Tata Consultancy Services Ltd.)
*   Description:    Test the trigger code to update MangerId of User based on value in field BPG_Manager_NTID__c
*   Modifications:  
****************************************************************************************/
@isTest
public class BPG_UserUtilityTest {
    
    @isTest static void testInsertUserNTID() {
        User userManager = createStdUser('standarduserManager@testorg.com', 'man84g', '');
        User userSub = createStdUser('standarduser2108@testorg.com', 'sub73t', 'man84g');
        List<User> usersToInsert = new List<User>{userManager, userSub};
        
        Test.startTest();
        
        insert usersToInsert;
        User uNow = [SELECT Id, Name, ManagerId FROM User WHERE Id = :userSub.Id];
        System.assertEquals(userManager.Id, uNow.ManagerId, 'By Manager NTID, Manager is set in a user');    
        
        userSub.BPG_Manager_NTID__c = '';
        update userSub;
        System.assertEquals(NULL, userSub.ManagerId, 'Reset ManagerId if Manager_NTID is blank');
        
        Test.stopTest();
    }
    
    public static User createStdUser(String userNameNow, String ntId, String managerNTID) {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User userNow =  new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=userNameNow,
            NTID__c=ntId, BPG_Manager_NTID__c=managerNTID, IsActive=true);
        
        return userNow;
    }
}