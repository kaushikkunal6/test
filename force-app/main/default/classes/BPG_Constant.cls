/* @author            Pooja Deokar
*  @date              July 20, 2020
*  @description       provides helper methods for opportunity record types Id .
*/
public without sharing class BPG_Constant
{
    /*
    * Returns opportunity recordtype ids.
    */
    public static Set<Id> VALID_RECORD_TYPES {
        get {
            if (VALID_RECORD_TYPES == null) {
                Map<String,RecordTypeInfo> recordTypeInfosByDeveloperName = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

                VALID_RECORD_TYPES = new Set<Id>{
                    recordTypeInfosByDeveloperName.get('PCRM_PetChems_Acetyls').getRecordTypeId()
                };
            }

            return VALID_RECORD_TYPES;
        }
        private set;
    }
}