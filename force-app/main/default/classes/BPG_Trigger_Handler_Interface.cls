/******************************************************************************************
 *	Date: 			27NOV18
 * 	Author:			Jon Marson
 * 	Description:	Projects are not permitted to add triggers to standard objects; instead
 * 					they must write a class which implements the below methods and register
 * 					it with the standard trigger handler framework (see Custom Metadata Type
 * 					'BPG_Trigger_Registration'). In addition, projects are not permitted to
 * 					build alternative trigger handler frameworks for custom objects; if a 
 * 					trigger handler framework is needed for custom objects then this standard
 * 					one must be used.
 * 
 *					Note: If your apex class only needs to implement 1 or 2 of the methods 
 *					below, consider extending 'BPG_Trigger_Handler_Utilities' which provides
 *					mock implementations of the below methods which you can overload as 
  *          needed.
 *  
 *  Date:           05JUN20
 *  Author:         Steven Edwards
 *  Description:    Added final method to allow delegate classes to instantiate asycnhronous processes reliably
 * ***************************************************************************************/
public interface BPG_Trigger_Handler_Interface 
{
	void beforeInsert(List<SObject> o, Map<Id, SObject> oldMap, List<SObject> n, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug);
    void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params,Boolean debug);
    void beforeDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params,Boolean debug);
    void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params,Boolean debug);
    void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params,Boolean debug);
    void afterDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params,Boolean debug);
    void afterUndelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params,Boolean debug);   
    void finish(); 
}