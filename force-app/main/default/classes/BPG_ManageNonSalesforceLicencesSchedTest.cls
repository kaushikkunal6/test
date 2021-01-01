/************************************************************************************************************
 * Date:        26JUNE18
 * Author:      Lalit Singh
 * Comments:    Test Scehduler class for Managing Non-Salesforce Licenses.
 *              Methods:
 *              -schedulerTest
 * *******************************************************************************************************/
@isTest
private class BPG_ManageNonSalesforceLicencesSchedTest{
    
    static testmethod void schedulerTest() {
    Test.startTest();   
    BPG_ManageNonSalesforceLicencesSched uplObj = new BPG_ManageNonSalesforceLicencesSched();
    String sch = '0 0 23 * * ?';
    system.schedule('Test userlicense package Check', sch, uplObj);
    Test.stopTest();    
    }
}