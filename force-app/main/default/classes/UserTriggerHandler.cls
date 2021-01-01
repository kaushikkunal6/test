/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 02/2018
 * 
 */
public class UserTriggerHandler {
    // used for testing triggers when the
    // setup DML would interfere with the tests
    @testVisible static Boolean bypassTrigger = false;
    final Set<Id> newIds;
    final List<User> newRecords;
    final Map<Id, User> oldRecords;
    
    public UserTriggerHandler(List<User> newRecords, Map<Id, User> newMap, Map<Id, User> oldRecords) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        if(newMap != null)
	        this.newIds = newMap.keySet();
    }
    
    public void before() {
        if(bypassTrigger){return;}
        
        //Automatically capitalizes First Name and Last Name
        REIDP_UserServices.capitilizeName(newRecords);
    }
    
    public void beforeInsert() {
        if(bypassTrigger){return;}
        
        //Sets default fields for User, such as Default Community
        REIDP_UserServices.setDefaultFields(newRecords);
        
        //Set language
        CAIDP_UserTriggerHandler.handleBeforeUpdate(newRecords, new Map<Id, User>());
    }
    
    public void beforeUpdate() {
        if(bypassTrigger){return;}
        
        //Check if email field was changed and trigger Email Verification
        REIDP_UserServices.checkEmailChangeForVerification(newRecords, oldRecords);
        
        //Change language
        CAIDP_UserTriggerHandler.handleBeforeUpdate(newRecords, oldRecords);
    }
    
    public void after() {
        if(bypassTrigger){return;}
    }
    
    public void afterInsert() {
        if(bypassTrigger){return;}

        //Set password to users who registered with mobile number
        REIDP_UserServices.setPasswordAndSendSMSToMobileUser(newRecords);
        
        //Links back Contact to User record
        REIDP_UserServices.setUserOnContact(newIds);
        
		//Add Professional League community user to unlisted groups corresponding to a language of a user
        CAPL_UserTriggerHandler.addUsersToForumGroups(Trigger.new);
		
        //setPointsForRegistration
        CAPL_UserTriggerHandler.setPointsForRegistration(Trigger.new);

        //Update consents based on changes of user
        REIDP_UserConsentHelper.syncConsentFromUser(newRecords, oldRecords);

        // Assign users to their territories based on their Role
        GECOT_UserServices.assignTerritory(newRecords);

        //Updates the ManagerId of User if Manager's NTID is populated before insert
        BPG_UserUtility.updateManagerWithNTID(newRecords);
    }
    
    public void afterUpdate() {
        if(bypassTrigger){return;}
        
        //Check if profile was changed during the update and Assignes default Permission Sets to User, using REIDP_Auto_Assigned_Permission_Set__mdt Custom Metadata object
        REIDP_UserServices.assignDefaultPermissionSetsOnProfileChange(newRecords, oldRecords);
        
        //Send email change verification Emails
        REIDP_UserServices.sendEmailVerificationEmail();

        //Update email, first name and last name on Contact Object
        REIDP_UserServices.checkUserDetailUpdate(newRecords, oldRecords);
        
        //Update consents based on changes of user
        REIDP_UserConsentHelper.syncConsentFromUser(newRecords, oldRecords);

        //Send User deactivated email, if user was deactivated
        CAIDP_UserTriggerHandler.handleAfterUpdate(newRecords, oldRecords);
        
        //Add points if if certain user details are filled in
        CAPL_UserTriggerHandler.setPointsForProfile(newRecords, oldRecords);

        //Updates the ManagerId of User if Manager's NTID is populated before update
        BPG_UserUtility.updateManagerWithNTID(newRecords, oldRecords);
        
        // Creates Platform Events for User Obj 
        REIDP_UserServices.generateUserEventsOnUpdate(newIds, oldRecords);
        
    }
    
}