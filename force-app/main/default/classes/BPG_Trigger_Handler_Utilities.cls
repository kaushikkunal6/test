/*********************************************************************************************************************
 *  Date:           27NOV18
 *  Author:         Jon Marson
 *  Description:    Implementation of the BP Trigger Handler framework which determines dependencies at runtime (based
 *                  on a custom metadata type) rather than at compile time.  All triggers should be implemented using the
 *                  following single line of code (replace 'Account' with relevant object name)
 * 
 *                  trigger BPG_Account_Trigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
 *                  {
 *                      BPG_Trigger_Handler_Utilities.handleEvent('Account', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap); 
 *                  }
 *
 *                  Projects should then write an Apex class which either implements 'BPG_Trigger_Handler_Interface' or
 *                  extends 'BPG_Trigger_Handler_Utilities'.  They should then register this class against the relevant
 *                  object and events via the 'Trigger Registrations' custom metadata type.
 *
 *                  When the trigger fires, it will call the 'handleEvent' method of this class, which will look at the
 *                  'Trigger Registrations' customer metadata type in order to determine which classes have registered
 *                  for the relevant event and call each of these classes individually.  
 *                  
 *********************************************************************************************************************/
public virtual class BPG_Trigger_Handler_Utilities implements BPG_Trigger_Handler_Interface
{
    private static Set<System.TriggerOperation> recursionCheckSet = new Set<System.TriggerOperation>();
    
    //Make this testVisible to allow us to mock the Custom Metadata Type data during testing
    @TestVisible
    private static List<BPG_Trigger_Registration__mdt> mdtList;
    @TestVisible
    private static String objName;
    
    //Method to allow us to reset the recursion check within test classes
    public static void resetRecursionCheckSet()
    {
        if (!Test.isRunningTest())
            throw new TriggerHandlerException('resetRecursionCheckSet is only to be used within test methods');
        recursionCheckSet = new Set<System.TriggerOperation>();
    }
    
    public static void handleEvent(String objAPIName, System.TriggerOperation operationType, Integer size, List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap)
    { 
        if(!FeatureManagement.checkPermission('BPG_DisableAll'))    
        {                
            //getGlobalDescribe() is VERY CPU intensive, so we want to make sure that we only call it once per transaction and pass 
            //it into each subscribed handler class - rather than each subscribed class potentially having to call it separately.
            Map<String, Schema.SObjectType> sotMap = Schema.getGlobalDescribe();
            Schema.SObjectType sot = sotMap.get(objAPIName);
            Map<Id, Schema.RecordTypeInfo> rtiMap = sot.getDescribe().getRecordTypeInfosById();
            
            Type t;
            Id rtId;
            String rtName;
            List<sObject> oFiltered; 
            List<sObject> nFiltered; 
            Boolean found;      
            
            if (mdtList == null || objAPIName != objName)
            {
                mdtList = Database.query('SELECT BPG_Object_API_Name__c, BPG_Class_Name__c, BPG_Record_Type_Filter__c, BPG_Allow_Recursive_Calls__c, BPG_Parameters__c, BPG_Debug__c, BPG_Before_Insert__c, BPG_Before_Update__c, BPG_Before_Delete__c, BPG_After_Insert__c, BPG_After_Update__c, BPG_After_Delete__c, BPG_After_Undelete__c FROM BPG_Trigger_Registration__mdt WHERE BPG_Active__c=true AND BPG_Object_API_Name__c=\'' +objAPIName +'\' ORDER BY BPG_Sequence__c ASC');
                objName = objAPIName;
            }
            //Loop thru each subscribed class
            for (BPG_Trigger_Registration__mdt tr : mdtList)
            {
                if (operationType == System.TriggerOperation.BEFORE_INSERT && !tr.BPG_Before_Insert__c ||
                    operationType == System.TriggerOperation.BEFORE_UPDATE && !tr.BPG_Before_Update__c ||
                    operationType == System.TriggerOperation.BEFORE_DELETE && !tr.BPG_Before_Delete__c ||
                    operationType == System.TriggerOperation.AFTER_INSERT && !tr.BPG_After_Insert__c ||
                    operationType == System.TriggerOperation.AFTER_UPDATE && !tr.BPG_After_Update__c ||
                    operationType == System.TriggerOperation.AFTER_DELETE && !tr.BPG_After_Delete__c ||
                    operationType == System.TriggerOperation.AFTER_UNDELETE && !tr.BPG_After_Undelete__c)
                    continue;
                
                if (tr.BPG_Debug__c)
                {
                    log('Calling Class: ' +tr.BPG_Class_Name__c);
                    log(getLimitDebugString());
                }   
                
                t = Type.forName(tr.BPG_Class_Name__c);            
                if(t == null || !(t.newInstance() instanceof BPG_Trigger_Handler_Interface))
                {
                    log('INVALID CLASS ' +tr.BPG_Class_Name__c);  
                    continue;
                }
                
                //If the registered class does NOT wish to be called multiple times....
                if (!tr.BPG_Allow_Recursive_Calls__c && recursionCheckSet.contains(operationType))
                {
                    if (tr.BPG_Debug__c)
                        log('Skipping recursive call for operation: ' +operationType);
                    continue;
                }
                    
                
                //if the class has a record type filter applied, then rather than passing in the old and new trigger
                //context variables we loop through the context variables and pull out only those records which have
                //the correct record type.  We then pass the filtered old/new lists into the relevant classes.  Note:
                //if zero records meet the filter then the class will not get called.
                if (tr.BPG_Record_Type_Filter__c == null)
                {
                    found = true;
                    oFiltered = o;
                    nFiltered = n;
                }
                else
                {
                    found = false;
                    oFiltered = new List<sObject>();  
                    nFiltered = new List<sObject>();      
                    
                    for (Integer i=0; i<size; i++)
                    {
                        //The old/oldMap context variables are only applicable for delete/update triggers
                        if (operationType == TriggerOperation.BEFORE_DELETE || operationType == TriggerOperation.AFTER_DELETE || operationType == TriggerOperation.BEFORE_UPDATE || operationType == TriggerOperation.AFTER_UPDATE)
                        {
                            rtid = (Id) o.get(i).get('RecordTypeId');   
                            rtName = rtiMap.get(rtid).getDeveloperName();
                            if (rtName.startsWith(tr.BPG_Record_Type_Filter__c))
                            {
                                found = true;
                                oFiltered.add(o.get(i));
                            }
                        }
                        //The new/newMap context variables are only applicable for insert/update/undelete triggers
                        if (operationType == TriggerOperation.BEFORE_INSERT|| operationType == TriggerOperation.AFTER_INSERT || operationType == TriggerOperation.BEFORE_UPDATE || operationType == TriggerOperation.AFTER_UPDATE || operationType == TriggerOperation.AFTER_UNDELETE)
                        {
                            rtid = (Id) n.get(i).get('RecordTypeId');   
                            rtName = rtiMap.get(rtid).getDeveloperName();
                            if (rtName.startsWith(tr.BPG_Record_Type_Filter__c))
                            {
                                found = true;
                                nFiltered.add(n.get(i));
                            }    
                        }                    
                    }
                }
                
                //If no records meet the filter criteria, then don't call the class
                if (!found)
                {
                    if (tr.BPG_Debug__c)
                        log('Skipping call as no records met filter criteria');
                    continue;
                }
                    
                      
                BPG_Trigger_Handler_Interface thi = (BPG_Trigger_Handler_Interface) t.newInstance();        
                switch on operationType
                {
                    when BEFORE_INSERT { thi.beforeInsert(oFiltered, oMap, nFiltered, nMap, sot, tr.BPG_Parameters__c, tr.BPG_Debug__c); }
                    when BEFORE_UPDATE { thi.beforeUpdate(oFiltered, oMap, nFiltered, nMap, sot, tr.BPG_Parameters__c, tr.BPG_Debug__c); }
                    when BEFORE_DELETE { thi.beforeDelete(oFiltered, oMap, nFiltered, nMap, sot, tr.BPG_Parameters__c, tr.BPG_Debug__c); }
                    when AFTER_INSERT { thi.afterInsert(oFiltered, oMap, nFiltered, nMap, sot, tr.BPG_Parameters__c, tr.BPG_Debug__c); }
                    when AFTER_UPDATE { thi.afterUpdate(oFiltered, oMap, nFiltered, nMap, sot, tr.BPG_Parameters__c, tr.BPG_Debug__c); }
                    when AFTER_DELETE { thi.afterDelete(oFiltered, oMap, nFiltered, nMap, sot, tr.BPG_Parameters__c, tr.BPG_Debug__c); }
                    when AFTER_UNDELETE { thi.afterUndelete(oFiltered, oMap, nFiltered, nMap, sot, tr.BPG_Parameters__c, tr.BPG_Debug__c); }
                } 
                thi.finish();
                
                if (tr.BPG_Debug__c)
                {
                    log('Class Execution Completed: ' +tr.BPG_Class_Name__c);
                    log(getLimitDebugString());
                }   
    
            }
            
            //Add the operation type to the recursionCheckSet so that we can check if this operation type gets called recursively
            recursionCheckSet.add(operationType);
        }
    }
    
    //Constructs a formatted string displaying usage of a number of key transactional governor limits
    public static String getLimitDebugString()
    {
        String debugString = ''; 
        
        debugString += 'Aggregate Queries: ' +Limits.getAggregateQueries() +'/' +Limits.getLimitAggregateQueries();   
        debugString += '\nCallouts: ' +Limits.getCallouts() +'/' +Limits.getLimitCallouts();     
        debugString += '\nCPU Time: ' +Limits.getCpuTime() +'/' +Limits.getLimitCpuTime();
        debugString += '\nDatabase Time: ' +Limits.getDatabaseTime() +'/' +Limits.getLimitDatabaseTime();       
        debugString += '\nDML Rows: ' +Limits.getDmlRows() +'/' +Limits.getLimitDmlRows();    
        debugString += '\nDML Statements: ' +Limits.getDmlStatements() +'/' +Limits.getLimitDmlStatements();    
        debugString += '\nQueries: ' +Limits.getQueries() +'/' +Limits.getLimitQueries();

        return debugString;
    }
    
    //Log method - eventually this will be rewritten to log out to the custom event monitoring solution.
    private static void log (String message)
    {
        System.debug('BPG_Trigger_Handler_Utility - ' +message);
    }
    
    /*********************************************************************************************************************************************************
     * Mock implementations of the methods defined within BPG_Trigger_Handler_Interface.  
     * 
     * A class may choose to extend BPG_Trigger_Utilities and overload just the methods it needs rather than implementing BPG_Trigger_Handler_Interface 
     * directly and having to implement all of the methods even if only 1 or 2 ever get called.  As a safety net, these mock implementations throw an
     * exception if they get called and the extending class has not overloaded them.
     * *******************************************************************************************************************************************************/
    public virtual void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        throw new TriggerHandlerException('A class has subscribed to the beforeInsert event without providing an implementation of the beforeInsert method');
    }
    public virtual void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        throw new TriggerHandlerException('A class has subscribed to the beforeUpdate event without providing an implementation of the beforeUpdate method');
    }
    public virtual void beforeDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        throw new TriggerHandlerException('A class has subscribed to the beforeDelete event without providing an implementation of the beforeDelete method');
    }
    public virtual void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        throw new TriggerHandlerException('A class has subscribed to the afterInsert event without providing an implementation of the afterInsert method');
    } 
    public virtual void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        throw new TriggerHandlerException('A class has subscribed to the afterUpdate event without providing an implementation of the afterUpdate method');
    } 
    public virtual void afterDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        throw new TriggerHandlerException('A class has subscribed to the afterDelete event without providing an implementation of the afterDelete method');
    }
    public virtual void afterUndelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        throw new TriggerHandlerException('A class has subscribed to the afterUndelete event without providing an implementation of the afterUndelete method');
    }  
    public virtual void finish() {}
    
    //Custom exception
    public class TriggerHandlerException extends Exception {}
}