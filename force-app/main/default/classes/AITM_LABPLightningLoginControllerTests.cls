/************************************************************************************************
 * @author           srnandan
 * @date             21/November/2018
 * @group            AirBP
 * @description      Test class for AITM_LABPLoginFormController LABP Community site
 *                   
 * history
 * 21/November/2018  srnandan          Created
 **********************************************************************/ 
@IsTest(SeeAllData = true)
public with sharing class AITM_LABPLightningLoginControllerTests {

    public static final String PASSWORD_STATUS_CORRECT = 'Success';
    /**
     * @description Verifies the login with invalid credentials
     * @param  null
     * @return void
     */
    @IsTest
    static void testLoginWithInvalidCredentials() {
        System.assertEquals(Label.LABP_Login_Error, AITM_LABPLightningLoginFormController.login('testUser', 'fakepwd', null));
    }
    
    /**
     * @description Verifies the login form controller instantiation
     * @param  null
     * @return void
     */
    @IsTest
    static void AITM_LABPLightningLoginFormControllerInstantiation() {
        AITM_LABPLightningLoginFormController controller = new AITM_LABPLightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    
    /**
     * @description Verifies the auth config
     * @param  null
     * @return void
     */
    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = AITM_LABPLightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
    
    /**
     * @description Verifies that login with invalid password
     * @param  null
     * @return void
     */
    @IsTest
    static void testLoginWithInvalidPassword() {
        Test.startTest();
        String communityUserEmail = 'testEmail@BPuser.com';
        String communityUserPassword = 'passPASS1234!@';
        User communityUser = createCommunityUser(communityUserEmail);
        String communityUserId = communityUser.Id;
        System.setPassword(communityUserId, communityUserPassword);
        
        List<LoginHistoryWrapper> lhws = new List<LoginHistoryWrapper>();
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-60), AITM_LABPLightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-155), AITM_LABPLightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-220), AITM_LABPLightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-240), PASSWORD_STATUS_CORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-450), PASSWORD_STATUS_CORRECT));
        
        List<LoginHistory> lhlist = (List<LoginHistory>)JSON.deserialize(JSON.serialize(lhws), List<LoginHistory>.class);
        
        List<UserLoginWrapper> ulw = new List<UserLoginWrapper>{new UserLoginWrapper(communityUserId, false)};
        
        List<UserLogin> loginInfo = (List<UserLogin>)JSON.deserialize(JSON.serialize(ulw), List<UserLogin>.class);

        String response = AITM_LABPLightningLoginFormController.getLoginError(communityUser, loginInfo, lhlist, getPasswordPolicy());
        String amntAvailable = String.valueOf(Integer.valueOf(getPasswordPolicy().Maximum_Invalid_Login_Attempts__c - 3));
        System.assertEquals(String.format(Label.LABP_Login_Error, new String[]{amntAvailable}), response);  
        Test.stopTest();
    }
    
    /**
     * @description Verifies that ForgotPasswordController handles invalid usernames appropriately
     * @param  null
     * @return void
     */
    @IsTest
    static void testGetIsUsernamePasswordEnabled() {
        System.assertEquals(true, AITM_LABPLightningLoginFormController.getIsUsernamePasswordEnabled(),'The userpassword is enabled');
    }
    
    /**
     * @description Verifies that Login with password lock out
     * @param  null
     * @return void
     */
    @IsTest
    static void testLoginWithPasswordLockout() {
        Test.startTest();
        String communityUserEmail = 'testEmail@BPuser.com';
        String communityUserPassword = 'passPASS1234!@';
        User communityUser = createCommunityUser(communityUserEmail);
        String communityUserId = communityUser.Id;
        System.setPassword(communityUserId, communityUserPassword);
        
        List<LoginHistoryWrapper> lhws = new List<LoginHistoryWrapper>();
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-60), AITM_LABPLightningLoginFormController.PASSWORD_STATUS_LOCKOUT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-155), AITM_LABPLightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-220), AITM_LABPLightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-240), AITM_LABPLightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-450), AITM_LABPLightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        
        List<LoginHistory> lhlist = (List<LoginHistory>)JSON.deserialize(JSON.serialize(lhws), List<LoginHistory>.class);

        List<UserLoginWrapper> ulw = new List<UserLoginWrapper>{new UserLoginWrapper(communityUserId, true)};
        
        List<UserLogin> loginInfo = (List<UserLogin>)JSON.deserialize(JSON.serialize(ulw), List<UserLogin>.class);

        String response = AITM_LABPLightningLoginFormController.getLoginError(communityUser, loginInfo, lhlist, getPasswordPolicy());
        String unlockTime = String.valueOf(Integer.valueOf(getPasswordPolicy().Lockout_Effective_Period__c));
        System.assertEquals(String.format(Label.LABP_Login_Error, new String[]{unlockTime,unlockTime}), response); 
        Test.stopTest();
    }
    
    /**
     * @description Verifies the login of the user
     * @param  null
     * @return void
     */
    @IsTest
    static void testLogin() {
        Test.startTest();
        String communityUserEmail = 'testEmail@BPuser.com';
        String communityUserPassword = 'passPASS1234!@';
        User communityUser = createCommunityUser(communityUserEmail);
        String communityUserId = communityUser.Id;
        System.setPassword(communityUserId, communityUserPassword);
        
        String response = AITM_LABPLightningLoginFormController.login(communityUserEmail, communityUserPassword, '');        
        System.assertEquals(Label.LABP_Login_Error, response);
        Test.stopTest();
    }
    
    public Class LoginHistoryWrapper {
        public String Status;
        public Datetime LoginTime;
        public String UserId;
        
        public LoginHistoryWrapper(String userId, Datetime loginTime, String status) {
            this.Status = status;
            this.LoginTime = loginTime;
            this.UserId = userId;
        }
    }
    
    public Class UserLoginWrapper {
        
        public String UserId;
        public Boolean IsPasswordLocked;
        
        public UserLoginWrapper(String userId, Boolean isPasswordLocked) {
            this.UserId = userId;
            this.IsPasswordLocked = isPasswordLocked;
        }
    }
    
    public static User createCommunityUser(String email) {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = pf.Id, 
                                     timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com.airdeploy');
        Account a;
        System.runAs(userWithRole){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RE IDP Person Account').getRecordTypeId();
            a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccount', PersonEmail = email);
            insert a;
        }
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        Profile p = [SELECT Id FROM Profile WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1];
        User u = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = email,
            Username = email,
            Alias = 'TestBP', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = acc.PersonContactId);
        insert u;
        return u;
    }
    
    private static LABP_Password_Policy__mdt getPasswordPolicy() {
        return [SELECT Lockout_Effective_Period__c, Maximum_Invalid_Login_Attempts__c 
                FROM LABP_Password_Policy__mdt 
                WHERE DeveloperName =:AITM_LABPLightningLoginFormController.PASSWORD_POLICY];
    }
    
}