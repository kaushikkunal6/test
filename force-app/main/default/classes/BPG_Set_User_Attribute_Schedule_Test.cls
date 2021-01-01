/****************************************************************************************************
 *  Date          : 26-DEC-2019
 *  Author        : Sunny Yap
 *  Description   : Test class for BPG_Set_User_Attribute_Schedule
 * Modifications  : 26-DEC-2019 SYAP - Initial
 ****************************************************************************************************/
@isTest
private class BPG_Set_User_Attribute_Schedule_Test {
/****************************************************************************************************
 * Simulate Scheduler
 ****************************************************************************************************/
  static testmethod void schedulerTest() {
    Test.startTest();   
    BPG_Set_User_Attribute_Schedule job = new BPG_Set_User_Attribute_Schedule();
    String schedule = '0 0 23 * * ?';
    system.schedule('Test Scheduleable Class', schedule, job);
    Test.stopTest();
    List<User> thisUser = [select Sales_Organisation__c from User where Id = :UserInfo.getUserId()];
    System.assert(thisUser.size() > 0, 'User Found');
  }
}