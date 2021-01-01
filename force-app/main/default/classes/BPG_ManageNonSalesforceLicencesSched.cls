/************************************************************************************************************
 * Date:        26JUNE18
 * Author:      Lalit Singh
 * Comments:    Scehduler class for Managing Non-Salesforce Licenses.
 *              Methods:
 *              -Execute
 * *******************************************************************************************************/
global class BPG_ManageNonSalesforceLicencesSched implements Schedulable {

   global void execute(System.SchedulableContext SC) {
      BPG_ManageNonSalesforceLicences nonSFLic = new BPG_ManageNonSalesforceLicences();
      database.executeBatch(nonSFLic);
    }   
}