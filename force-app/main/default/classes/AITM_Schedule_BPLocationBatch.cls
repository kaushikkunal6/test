/***************************************************************
 * @author           Neeti 
 * @date             01/July/2020
 * @group            AirBP
 * @description      Test class for AITM_AirBPCountryAPIBatch

 * history
 * 01/July/2020     Neeti      Created 
 **********************************************************/

Global with sharing class AITM_Schedule_BPLocationBatch implements Schedulable {
    global void execute(SchedulableContext ctx) {
       AITM_AirBPCountryListAPIBatch bp = new AITM_AirBPCountryListAPIBatch();
        if(!test.isRunningTest()){Database.executeBatch(bp); }  
    }
}