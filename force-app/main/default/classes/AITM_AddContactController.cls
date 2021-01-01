/***********************************************************************************************
 * @author           srnandan
 * @date             20/September/2019
 * @group            AirBP
 * @description      controller class used in aura component to get recordtypeid

 * history
 * 20/September/2019  srnandan      Created 
 ************************************************************************************************/
public with sharing class AITM_AddContactController {
    /**
     * @description returns record type id based on recordtype name
     * @param  objectName of type String
     * @param  strRecordTypeName of type String
     * @return Id
     */
	@AuraEnabled 
    public static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName) {
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
}