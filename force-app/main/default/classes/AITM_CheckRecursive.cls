/***********************************************************************************************
 * @author           Neeti
 * @date             18/Nov/2019
 * @group            AirBP
 * @description      Handle trigger Recussion; genric class can be use with any object to handle recursion

*/

public with sharing class AITM_CheckRecursive {
    
	public static Set<Id> setOfIDsBeforeUpdate = new Set<Id>();
	public static Set<Id> setOfIDsAfterInsert = new Set<Id>();
	public static Set<Id> setOfIDsAfterUpdate = new Set<Id>();
	
}