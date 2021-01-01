/***************************************************************
 * @author           Saravan 
 * @date             01/July/2020
 * @group            AirBP
 * @description      Test class for AITM_AirBPCountryAPIBatch

 * history
 * 01/July/2020     Saravan      Created 
 **********************************************************/

Global with sharing class AITM_Schedule_NonBPLocationBatch implements Schedulable {
    global void execute(SchedulableContext ctx) {
       AITM_AirBPNonOperatedAPIBatch bp = new AITM_AirBPNonOperatedAPIBatch();
        if(!test.isRunningTest()){ Database.executeBatch(bp);}   
    }
}