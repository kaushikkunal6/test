global without sharing class AITM_LABPLightningLoginFormController {
	public static final String PASSWORD_STATUS_LOCKOUT = 'Password Lockout';
    public static final String PASSWORD_STATUS_INCORRECT = 'Invalid Password';
    public static final String LOCKOUT_EMAIL_TYPE = 'Lockout';
    public static final String PASSWORD_POLICY = 'BPPasswordPolicy';
    
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        if (String.isEmpty(username) && String.isEmpty(password)) {
            return Label.LABP_User_Password_Error;
        } else if (String.isEmpty(password)) {
            return Label.LABP_Enter_Password;
        } else if(String.isEmpty(username)) {
            return Label.LABP_Enter_Username;
        }else if(String.isEmpty(startUrl)){
            return Label.LABP_Login_Error;
        }
        
        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            
            List<User> user = [SELECT Id, Email, IsActive FROM User WHERE Username =:username];
            
            if (!user.isEmpty()) {
                LABP_Password_Policy__mdt passwordPolicy = [SELECT Lockout_Effective_Period__c, Maximum_Invalid_Login_Attempts__c 
                                                             FROM LABP_Password_Policy__mdt 
                                                             WHERE DeveloperName =:PASSWORD_POLICY];
                List<UserLogin> loginInfo = [SELECT IsPasswordLocked, isFrozen, LastModifiedDate FROM UserLogin WHERE UserId =:user[0].Id LIMIT 1];
                Integer maxLoginAttempts = Integer.valueOf(passwordPolicy.Maximum_Invalid_Login_Attempts__c);
                List<LoginHistory> lhlist = [SELECT UserId, Status, LoginTime FROM LoginHistory
                                             WHERE UserId =:user[0].Id
                                             ORDER BY LoginTime DESC LIMIT :(maxLoginAttempts * 2)];
                
                String loginError = getLoginError(user[0], loginInfo, lhlist, passwordPolicy);
                if (loginError != null) {
                    return loginError;
                }
                else if (!user[0].IsActive) {
                    return Label.LABP_Login_Error;
                }
            }
            return Label.LABP_Login_Error;
        }
    }
    
    public static String getLoginError(User u, List<UserLogin> loginInfo, List<LoginHistory> lhlist, LABP_Password_Policy__mdt passwordPolicy) {
        
        if (loginInfo != null && !loginInfo.isEmpty() && loginInfo[0].IsPasswordLocked) {
            if (lhlist[0].Status == PASSWORD_STATUS_INCORRECT) {
                
            }
            return Label.LABP_Login_Error;
        } else if (lhlist != null && !lhlist.isEmpty() && lhlist[0].Status == PASSWORD_STATUS_INCORRECT) {
            
            // get the number of incorrect passwords in a row
            Integer totalNumOfFailedLogins = 0;
            for(LoginHistory lh : lhlist) {
                if(lh.Status != PASSWORD_STATUS_INCORRECT)
                    break;
                totalNumOfFailedLogins++;
            }
            
            Integer numOfFailedLogins = Math.mod(totalNumOfFailedLogins, Integer.valueOf(passwordPolicy.Maximum_Invalid_Login_Attempts__c));
            return Label.LABP_Login_Error;
        }
        return null;
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }
    
    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig() {
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }
}