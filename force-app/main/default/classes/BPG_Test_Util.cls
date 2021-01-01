/************************************************************************************************************
 * Date:        24May2018
 * Author:      Revan Chavan
 * Comments:    Test utility to create test data for User, Public Group, Permission Sets etc.
 * *******************************************************************************************************/
@isTest
public class BPG_Test_Util {
    
    //Create User
    public static String createTestUser(Id profID, String firstName, String lastName)
    {
        try {            
            String orgId = UserInfo.getOrganizationId();
            String dateStr = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateStr + randomInt;
            User tuser = new User(  firstname = firstName,
                                    lastName = lastName,
                                    email = uniqueName + '@test' + orgId + '.com',
                                    Username = uniqueName + '@test' + '.com.'+ orgId,
                                    EmailEncodingKey = 'ISO-8859-1',
                                    Alias = uniqueName.substring(18, 23),
                                    TimeZoneSidKey = 'Europe/London',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    ProfileId = profId);
            insert tuser;
            String userId = tuser.Id;
            return userId;
        }
        catch (Exception e) {
            return('Error: '+e);
        }
    }
    
    //(L.B.Singh this method creates a user and returns it)Creates and Returns User
    public static User createsTestUser(Id profID, String firstName, String lastName)
    {         
            String orgId = UserInfo.getOrganizationId();
            String dateStr = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateStr + randomInt;
            User tuser = new User(  firstname = firstName,
                                    lastName = lastName,
                                    email = uniqueName + '@test' + orgId + '.com',
                                    Username = uniqueName + '@test' + '.com.'+ orgId,
                                    EmailEncodingKey = 'ISO-8859-1',
                                    Alias = uniqueName.substring(18, 23),
                                    TimeZoneSidKey = 'Europe/London',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    BPG_Assigned_Permission_Set__c = 'Test C',
                                    ProfileId = profId);
            insert tuser;
            return tuser;
    }
    
    
    
    
    //Add user in Public Groups
    public static String addPublicGroup(String sfUserId, List<Group> publicGroupList)
    {
        try {
            List<GroupMember>lstGrpMember =new List<GroupMember>(); 
            for (Group grp : publicGroupList) {
                GroupMember gm= new GroupMember(); 
                gm.GroupId=grp.id;
                gm.UserOrGroupId = sfUserId;
                lstGrpMember.add(gm);   
            } 
            insert lstGrpMember;
            return('User added to groups successfully');
        }
        catch (Exception e){
            return('Error: '+e);
        }
    }
    
    //Assign Permission Sets
    public static String addPermissionSets(Id sfUser, List<PermissionSet> permissionlist)
    {
        try{
            List<PermissionSetAssignment>lstPermissionSet =new List<PermissionSetAssignment>(); 
            for (PermissionSet prms : permissionlist) {
                PermissionSetAssignment ps= new PermissionSetAssignment(); 
                ps.PermissionSetId=prms.id;
                ps.AssigneeId = sfUser;
                lstPermissionSet.add(ps);   
            } 
            insert lstPermissionSet;
            return('Permission Sets assigned to user');
        }
        catch (Exception e){
            return('Error: '+e);
        }
    }

    //Add user in Public Groups
    public static Id getBPGRecordTypeId(String rtDeveloperName,String rtObject)
    {
        try {
            Id recTypeId = [SELECT Id 
                                           FROM RecordType 
                                           WHERE DeveloperName = :rtDeveloperName
                                           AND SobjectType = :rtObject
                                           AND IsActive = true LIMIT 1][0].Id;
            return(recTypeId);
        }
        catch (Exception e){
            return('Error: '+e);
        }
    }
}