/************************************************************************************************************
* Date:        02AUGUST18
* Author:      Lalit Singh
* Comments:    Test class for Managing Non-Salesforce Licenses.
* 
* 
*    *************************************** Change History ************************************************
Version       Date         Comments
V0.1     30 Aug 2018   Fixed assertion and updated query to fetch one permission sets

* *******************************************************************************************************/
@isTest(SeeallData=False)
private class BPG_ManageNonSalesforceLicencesTest {
    
    private static testMethod void testuserPackageLicenceHelper() {
        //Decalaration
        List<Id> userIdListToInsert = new List<Id>();
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> psaListToDelete = new List<PermissionSetAssignment>();
        String qualifiedApiName;
        
        //getting the customMetadata and qualifiedApiName
        //V0.1 change added condition to check BPG_User_Field_Name__c is null
        List<BPG_Permission_Set_to_Entitlement_Map__mdt> mdtList = [SELECT QualifiedApiName, Package_Namespace__c, BPG_User_Field_Name__c, BPG_User_Field_Value__c FROM BPG_Permission_Set_to_Entitlement_Map__mdt where BPG_User_Field_Value__c = null and BPG_User_Field_Name__c = null];
        
        if(!mdtList.isEmpty()){
            for(BPG_Permission_Set_to_Entitlement_Map__mdt mdt : mdtList){
                qualifiedApiName = mdt.QualifiedApiName;
            }
            
            //Creating users
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'BP Base (Salesforce)' LIMIT 1];
            User u1 = BPG_Test_Util.createsTestUser(profile.Id, 'Test', 'user1');
            userIdListToInsert.add(u1.Id);
            
            User u2 = BPG_Test_Util.createsTestUser(profile.Id, 'Test', 'user2');
            userIdListToInsert.add(u2.Id);
            
            
            //getting Permission set
            PermissionSet pset = [SELECT Id, Name FROM PermissionSet WHERE Name =: qualifiedApiName];
            
            Test.startTest();
            //Creating PermissionSetAssignment
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId=u1.Id, PermissionSetId = pset.id);
            psaList.add(psa1);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId=u2.Id, PermissionSetId = pset.id);
            psaList.add(psa2);
            
            
            insert psaList;
            
            //BPG_ManageNonSalesforceLicences.doAssignment();
            BPG_ManageNonSalesforceLicensesInvocable.doassingment();
            BPG_ManageNonSalesforceLicences.doAssignment(userIdListToInsert);
            
            // start processing for deletion
            
            For(UserPackageLicense upl :([SELECT Id, UserId FROM UserPackageLicense Where UserId = :psa1.AssigneeId])){
                system.assertEquals(upl.UserId,psa1.AssigneeId);
            }
            For(PermissionSetAssignment psa: psaList){
                psaListToDelete.add(psa);
            }
            delete psaListToDelete;
            
            //BPG_ManageNonSalesforceLicences.doAssignment();
            BPG_ManageNonSalesforceLicensesInvocable.doassingment();
            BPG_ManageNonSalesforceLicences.doAssignment(userIdListToInsert);
            
            // Assert
            For(UserPackageLicense uplic :([SELECT Id, UserId FROM UserPackageLicense Where UserId IN :userIdListToInsert])){
                system.assertNotEquals(uplic.userId, u1.id);
                system.assertNotEquals(uplic.userId, u2.id);
            }
            
            Test.stopTest();    
        }
    }
    
    private static testMethod void testuserFieldHelper(){
        //Decalaration
        List<Id> userIdListToInsert = new List<Id>();
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> psaListToDelete = new List<PermissionSetAssignment>();
        String qualifiedApiName;
        String userFieldValue;
        
        //getting the customMetadata and qualifiedApiName
        ////V0.1 change added condition to fetch one record from CustomMetadata
        for(BPG_Permission_Set_to_Entitlement_Map__mdt mdt : [SELECT QualifiedApiName, Package_Namespace__c, BPG_User_Field_Name__c, BPG_User_Field_Value__c FROM BPG_Permission_Set_to_Entitlement_Map__mdt where BPG_User_Field_Value__c != null and QualifiedApiName='GCM_Saviynt_Service_User']){
            qualifiedApiName = mdt.QualifiedApiName;
            userFieldValue = mdt.BPG_User_Field_Value__c;
        }
        
        //Creating users
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'BP Base (Salesforce)' LIMIT 1];
        User u1 = BPG_Test_Util.createsTestUser(profile.Id, 'Test', 'user1');
        userIdListToInsert.add(u1.Id);
        User u2 = BPG_Test_Util.createsTestUser(profile.Id, 'Test', 'user2');
        userIdListToInsert.add(u2.Id);
        
        //getting Permission set
        PermissionSet pset = [SELECT Id, Name FROM PermissionSet WHERE Name =: qualifiedApiName];
        Test.startTest();
        //Creating PermissionSetAssignment
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId=u1.Id, PermissionSetId = pset.id);
        psaList.add(psa1);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId=u2.Id, PermissionSetId = pset.id);
        psaList.add(psa2);
        
        insert psaList;
        
        //BPG_ManageNonSalesforceLicences.doAssignment();
        BPG_ManageNonSalesforceLicensesInvocable.doassingment();
        BPG_ManageNonSalesforceLicences.doAssignment(userIdListToInsert);
        
        //V0.1 to get updated value for assertion
        User userAfterupdate1 = [select id,BPG_Assigned_Permission_Set__c,UserPermissionsSupportUser from User where id = :u1.Id];
        User userAfterupdate2 = [select id,BPG_Assigned_Permission_Set__c,UserPermissionsSupportUser from User where id = :u2.Id];
        
        //Asserts for User Package License Assignment.
        For(UserPackageLicense upl :([SELECT Id, UserId FROM UserPackageLicense Where UserId = :psa1.AssigneeId])){
            system.assertEquals(upl.UserId,psa1.AssigneeId);
        }
        
        //Asserts for User field updates
        system.assertEquals(userFieldValue, String.valueof(userAfterupdate1.UserPermissionsSupportUser));
        system.assertEquals(userFieldValue, String.valueof(userAfterupdate2.UserPermissionsSupportUser));
        
        // start processing for deletion
        For(PermissionSetAssignment psa: psaList){
            psaListToDelete.add(psa);
        }
        delete psaListToDelete;
        
        //BPG_ManageNonSalesforceLicences.doAssignment();
        BPG_ManageNonSalesforceLicensesInvocable.doassingment();
        BPG_ManageNonSalesforceLicences.doAssignment(userIdListToInsert);
        
        //V0.1 change added condition to get updated value for assertion
        User userAfterupdate3 = [select id,BPG_Assigned_Permission_Set__c,UserPermissionsSupportUser from User where id = :u1.Id];
        User userAfterupdate4 = [select id,BPG_Assigned_Permission_Set__c,UserPermissionsSupportUser from User where id = :u2.Id];
        
        //Asserts for User field updates
        system.assertEquals(false, userAfterupdate3.UserPermissionsSupportUser);
        system.assertEquals(false, userAfterupdate4.UserPermissionsSupportUser);
        
        //Asserts for User package License assignment Removal.
        For(UserPackageLicense uplic :([SELECT Id, UserId FROM UserPackageLicense Where UserId IN :userIdListToInsert])){
            system.assertNotEquals(uplic.userId, u1.id);
            system.assertNotEquals(uplic.userId, u2.id);
        }
        Test.stopTest();   
    }
}