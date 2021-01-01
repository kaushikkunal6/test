/****************************************************************************************************
 *  Date          : 26-DEC-2019
 *  Author        : Sunny Yap
 *  Description   : Test class for BPG_Set_User_Attribute
 * Modifications  : 26-DEC-2019 SYAP - Initial
 ****************************************************************************************************/
@isTest
public with sharing class BPG_Set_User_Attribute_Test
{
/****************************************************************************************************
 * Simulate User Attribute Assignment
 ****************************************************************************************************/
  @isTest static void doAssignment() {
    // Get Current User Id
    Id userId = UserInfo.getUserId();
    
    // Get Group Id
    List<Group> groups = [select Id from Group where DeveloperName = 'GCM_Fuels_Cards_UK01' and Type = 'Regular'];
    Id groupId = null;
    for (Group thisGroup : groups) {
      groupId = thisGroup.Id;
    }
    System.assert(groupId != null, 'Group Test Data Found');
    
    // Create Group Member If Missing
    List<GroupMember> members = [select Id from GroupMember where GroupId = :groupId and UserOrGroupId = :userId];
    if (members.size() == 0) {
      GroupMember member = new GroupMember();
      member.GroupId = groupId;
      member.UserOrGroupId = userId;
      insert member;
    }
    
    // Call Assignment Method
    List<User> users = [select Id from User where Id = :userId];
    BPG_Set_User_Attribute attribute = new BPG_Set_User_Attribute(); 
    attribute.doAssignment(users);
    
    // Check Results
    List<User> updatedUsers = [select Id from User where Id = :userId and Sales_Organisation__c = 'UK01'];
    System.assert(updatedUsers.size() > 0, 'User Updated');
  }
}