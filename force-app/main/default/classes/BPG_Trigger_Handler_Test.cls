/******************************************************************************************
 *  Date:           17JAN19
 *  Author:         Jon Marson
 *  Description:    Test class for BP Trigger Handler Utilities
 * ***************************************************************************************/
@isTest
public class BPG_Trigger_Handler_Test extends BPG_Trigger_Handler_Utilities
{
    static boolean beforeInsertHasRun;
    
    @isTest
    static void testTriggerHandler()
    { 
        //First test is to simulate the Account before insert event, and check the implementation of beforeInsert inside this class (BPG_Trigger_Handler_Test) gets called.
        //Note: cannot create custom metadata type in test class, therefore we have to mock it and populate mdtMap manually   
        BPG_Trigger_Handler_Utilities.mdtList = new BPG_Trigger_Registration__mdt[] {new BPG_Trigger_Registration__mdt(BPG_Object_API_Name__c='Account', BPG_Class_Name__c='BPG_Trigger_Handler_Test', BPG_Before_Insert__c=true, BPG_Active__c=true, BPG_Debug__c=true)};
        BPG_Trigger_Handler_Utilities.objName = 'Account';
        beforeInsertHasRun = false;
        BPG_Trigger_Handler_Utilities.handleEvent('Account', System.TriggerOperation.BEFORE_INSERT, 1, null, null, null, null);  
        System.assert(beforeInsertHasRun);
        
        //Second test is to simulate the Case before insert event.  We provide a dummy non-existent class name for this so it won't actually do anything
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet(); //Reset recursion check set - otherwise trigger handler utility will think 'BEFORE_INSERT' has already run
        BPG_Trigger_Handler_Utilities.mdtList = new BPG_Trigger_Registration__mdt[] {new BPG_Trigger_Registration__mdt(BPG_Object_API_Name__c='Case', BPG_Class_Name__c='DummyNonExistentClass', BPG_Before_Insert__c=true, BPG_Active__c=true, BPG_Debug__c=true)};
        BPG_Trigger_Handler_Utilities.objName = 'Case';
        BPG_Trigger_Handler_Utilities.handleEvent('Case', System.TriggerOperation.BEFORE_INSERT, 1, null, null, null, null);        
        
        //Third test is to simulate the Case before insert event again but using the implementation of beforeInsert inside this class (BPG_Trigger_Handler_Test).
        //We do NOT expect before insert to run, as it should be skipped as a recursive call
        beforeInsertHasRun = false;
        BPG_Trigger_Handler_Utilities.mdtList = new BPG_Trigger_Registration__mdt[] {new BPG_Trigger_Registration__mdt(BPG_Object_API_Name__c='Case', BPG_Class_Name__c='BPG_Trigger_Handler_Test', BPG_Before_Insert__c=true, BPG_Active__c=true, BPG_Debug__c=true)};
        BPG_Trigger_Handler_Utilities.objName = 'Case';
        BPG_Trigger_Handler_Utilities.handleEvent('Case', System.TriggerOperation.BEFORE_INSERT, 1, null, null, null, null);       
        System.assert(!beforeInsertHasRun);
        
        //Final test is to simulate all the events on Opportunity.  These should all fail, as we subscribe the 'BPG_Trigger_Handler_Utilities' class without overloading the method implementations. 
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet(); //Reset recursion check set - otherwise trigger handler utility will think 'BEFORE_INSERT' has already run
        BPG_Trigger_Handler_Utilities.mdtList = new BPG_Trigger_Registration__mdt[] {new BPG_Trigger_Registration__mdt(BPG_Object_API_Name__c='Opportunity', BPG_Class_Name__c='BPG_Trigger_Handler_Utilities', BPG_Before_Insert__c=true, BPG_After_Insert__c=true, BPG_Before_Update__c=true, BPG_After_Update__c=true, BPG_Before_Delete__c=true, BPG_After_Delete__c=true, BPG_After_Undelete__c=true, BPG_Active__c=true)};   
        BPG_Trigger_Handler_Utilities.objName = 'Opportunity';
            
        Integer exceptionCount = 0; 
        try 
        {
            BPG_Trigger_Handler_Utilities.handleEvent('Opportunity', System.TriggerOperation.BEFORE_INSERT, 1, null, null, null, null);  //no
        }
        catch(Exception e) 
        {
            exceptionCount ++;
        }
        try
        {
            BPG_Trigger_Handler_Utilities.handleEvent('Opportunity', System.TriggerOperation.AFTER_INSERT, 1, null, null, null, null);
        }
        catch(Exception e) 
        {
            exceptionCount ++;
        }
        try 
        {
            BPG_Trigger_Handler_Utilities.handleEvent('Opportunity', System.TriggerOperation.BEFORE_UPDATE, 1, null, null, null, null); 
        }
        catch(Exception e) 
        {
            exceptionCount ++;
        }
        try
        {
            BPG_Trigger_Handler_Utilities.handleEvent('Opportunity', System.TriggerOperation.AFTER_UPDATE, 1, null, null, null, null);
        }
        catch(Exception e) 
        {
            exceptionCount ++;
        }
        try 
        {
            BPG_Trigger_Handler_Utilities.handleEvent('Opportunity', System.TriggerOperation.BEFORE_DELETE, 1, null, null, null, null); 
        }
        catch(Exception e) 
        {
            exceptionCount ++;
        }
        try
        {
            BPG_Trigger_Handler_Utilities.handleEvent('Opportunity', System.TriggerOperation.AFTER_DELETE, 1, null, null, null, null);
        }
        catch(Exception e) 
        {
            exceptionCount ++;
        }
        try
        {
            BPG_Trigger_Handler_Utilities.handleEvent('Opportunity', System.TriggerOperation.AFTER_UNDELETE, 1, null, null, null, null);
        }
        catch(Exception e) 
        {
            exceptionCount ++;
        }   
        System.assertEquals(7, exceptionCount);


        
        
    }
    
    //If the Trigger Registration for the 'BPG_Trigger_Handler_Test' (before insert) is successful, then set the variable to true
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        beforeInsertHasRun = true;    
    }

}