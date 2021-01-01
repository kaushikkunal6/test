/****************************************************************************************************
 *  Date          : 26-DEC-2019
 *  Author        : Sunny Yap
 *  Description   : Schedulable class for BPG_Set_User_Attribute
 * Modifications  : 26-DEC-2019 SYAP - Initial
 ****************************************************************************************************/
global class BPG_Set_User_Attribute_Schedule implements Schedulable {
/****************************************************************************************************
 * Standard Method In Schedulable Class
 ****************************************************************************************************/
   global void execute(System.SchedulableContext sc) {
      BPG_Set_User_Attribute userAttribute = new BPG_Set_User_Attribute();
      database.executeBatch(userAttribute);
    }   
}