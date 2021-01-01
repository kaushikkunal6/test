/************************************************************************************************************
* Date:        31JULY18
* Author:      Jon Marson
* Comments:    This class is to manage assignment of licences for 3rd party / AppExchange products installed
*              within Salesforce, such as Conga Composer and Youreka Forms.  In order to use these products
*              the user requires a licence in addition to their normal Salesforce licence.  The two main
*              mechanisms used by 3rd Party Apps for managing licencing are:
*                  (1) UserPackageLicence object
*                  (2) Custom field on User object
*              Both these mechanisms usually require an administrator to navigate to a screen within 
*              Salesforce to assign a licence to the user, however at BP all user provisioning and 
*              entitlement management is handled via Saviynt.  Saviynt's out of the box functionality
*              does not support the above mechanisms. 
* 
*              To work around this, Saviynt will assign the user a 'Dummy' permission set; this logic 
*              will then map that permission set to one of the above mechanisms.  This is controlled via
*              a custom metadata type 'BPG_Permission_Set_to_Entitlement_Map'
*************************************** Change History ************************************************
Version       Date          Author              Comments
V0.1        20 Aug 2018     Revan               Added Constructor to execute doAssignment() method
V0.2        30 Aug 2018     Lalit Singh         Handled scenario where more than one permission sets present for user field update 
V0.3        16 Oct 2018     Lalit Singh         Applying Partial Insert or updates
V0.4        17 Jan 2019     Revan Chavan        Changes made in UserFieldHelper method to update Boolean fields on User
V0.5        28 Jan 2019     Revan Chavan        Fix performance issues
V0.6        01 Mar 2019     Richa Pal           Fixed prod CPU time out issue - made the class Batchable
V0.7        05 Aug 2019     Sunny               Added user type filter.
V0.8		18 Sep 2019     Lalit Singh			Adding filter of Saviynt Integration user so that the query picks up only those users which were created by Saviynt.
* *******************************************************************************************************/
public with sharing class BPG_ManageNonSalesforceLicences implements Database.Batchable<sObject> {
    
    private static List<UserPackageLicense> uplList;
    private static List<User> userList;

    private static List<PermissionSetAssignment> psaForPackagesList;
    private static List<PermissionSetAssignment> psaForUserFieldList;
    private static Map<String, String> permissionSetToPackageMap = new Map<String, String>();
    private static Map<String, String> permissionSetToUserFieldMap = new Map<String, String>();
    private static Map<String, String> permissionSetToUserValueMap = new Map<String, String>();
    private static Set<String> uniqueFieldNameSet = new Set<String>(); // V0.2 change
    private static Map<String, String> userFieldToTypeMap = new Map<String, String>(); //V0.4 changes start
    
    private string query= 'SELECT Id FROM User where UserType = \'Standard\' AND CreatedBy.Name = \'Saviynt Integration\'';
 
    public Database.QueryLocator start(Database.BatchableContext BC) {
        if (test.isRunningTest()){
            query += ' and firstname = \'Test\'';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute (Database.BatchableContext bc, List<user> scope)
    {
        List<id> lstUserId = new List<id> ();    
        for (user objU : scope) {
            lstUserId.add(objU.id);
        }
        if (!lstUserId.isEmpty())
            doAssignment(lstUserId);
    }
    
    public void finish(Database.BatchableContext bc) {}
    
    public static void doAssignment(List<Id> userIdList)
    {
        populatePermissionSetMaps();
        
        uplList = [SELECT Id, PackageLicenseId, UserId, PackageLicense.NamespacePrefix FROM UserPackageLicense WHERE UserId IN :userIdList];
        psaForPackagesList = [SELECT PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name IN :permissionSetToPackageMap.keySet() AND AssigneeId IN :userIdList];
        userPackageLicenceHelper();
        // start of V0.2 change
        String strfieldnames = ' ';
        for (string fieldAPI : uniqueFieldNameSet) {
            strfieldnames= strfieldnames +','+ fieldAPI;
        }
        String userquery = 'SELECT Id ' +strfieldnames+' FROM User where id IN :userIdList';
        userList = Database.query(userquery);
        // end of V0.2 change
        psaForUserFieldList = [SELECT PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name IN :permissionSetToUserFieldMap.keySet() AND AssigneeId IN :userIdList];   
        userFieldHelper();
    }
    
    private static void populatePermissionSetMaps()
    { 
        for(BPG_Permission_Set_to_Entitlement_Map__mdt psem : [SELECT QualifiedApiName, Package_Namespace__c, BPG_User_Field_Name__c, BPG_User_Field_Value__c, BPG_Field_Data_Type__c FROM BPG_Permission_Set_to_Entitlement_Map__mdt])    
        {
            if (psem.Package_Namespace__c != null)
            {
                permissionSetToPackageMap.put(psem.QualifiedApiName, psem.Package_Namespace__c);   
            }
            if (psem.BPG_User_Field_Name__c != null)
            {
                permissionSetToUserFieldMap.put(psem.QualifiedApiName, psem.BPG_User_Field_Name__c);
                permissionSetToUserValueMap.put(psem.QualifiedApiName, psem.BPG_User_Field_Value__c);
                // V0.2 change to add field API names in Set
                uniqueFieldNameSet.add(psem.BPG_User_Field_Name__c);
                userFieldToTypeMap.put(psem.BPG_User_Field_Name__c,psem.BPG_Field_Data_Type__c); //V0.5 changes end
                //V0.4 changes end
            }
        }
        
    }   
    
    private static void userFieldHelper()
    {
        Map<String, String> userFieldValueMap = new Map<String, String>();
        for (PermissionSetAssignment psa : psaForUserFieldList)
            userFieldValueMap.put(psa.AssigneeId +';' +permissionSetToUserFieldMap.get(psa.PermissionSet.Name), permissionSetToUserValueMap.get(psa.PermissionSet.Name));
        
        List<User> userListToUpdate = new List<User>();
        Boolean updated;
        String key;
        String targetValue;
        
        for (User u : userList)
        { 
            updated = false;
            
            for (String fieldName : permissionSetToUserFieldMap.values())
            {
                key = u.Id +';' +fieldName;
                targetValue = userFieldValueMap.containsKey(key) ? userFieldValueMap.get(key) : null;
                //V0.4 changes start
                String fieldType = userFieldToTypeMap.containsKey(fieldName) ? userFieldToTypeMap.get(fieldName) : null;
                if (u.get(fieldName) != targetValue)
                    
                {
                    if (fieldType == 'BOOLEAN') {
                        Boolean booleanfield = targetValue != NULL ? boolean.valueof(targetValue) : False; 
                        u.put(fieldName, booleanfield);
                        updated = true;
                    }
                    else {
                        u.put(fieldName, targetValue);
                        updated = true;
                    }
                } //V0.4 Changes end
            }
            
            //Don't add the user record to the list inside the inner for loop, as we may be updating multiple fields against the same user.
            if (updated)
                userListToUpdate.add(u);
        }
        
        //v0.3 changes start
        if (!userListToUpdate.isEmpty())
            database.update(userListToUpdate, false);
        //v0.3 changes END
    }
    
    private static void userPackageLicenceHelper()
    {
        //Populate map containing EXISTING user package licence assignments.  Use a concatenation of Package Namespace and UserId as the key.
        Map<String, UserPackageLicense> userPackageLicenceMap_Existing = new Map<String, UserPackageLicense>();
        for (UserPackageLicense upl : uplList)
            userPackageLicenceMap_Existing.put(upl.PackageLicense.NamespacePrefix +';' +upl.UserId, upl);
        
        //Populate map containing TARGET user package licence assignments.  Use a concatenation of Package Namespace and UserId as the key.
        Set<String> userPackageLicenceSet_Target = new Set<String>();
        for (PermissionSetAssignment psa : psaForPackagesList)
            userPackageLicenceSet_Target.add(permissionSetToPackageMap.get(psa.PermissionSet.Name) +';' +psa.AssigneeId);
        
        //Populate a map to convert from Package Namespace to Package Id
        Map<String,Id> packagelicenseMap = new Map<String,Id>();
        for(PackageLicense pkg : [SELECT Id, NamespacePrefix FROM PackageLicense])
            packagelicenseMap.put(pkg.NamespacePrefix, pkg.Id);
        
        //Find assignments to add (i.e. those in target but not in existing)
        List<UserPackageLicense> uplListToInsert = new List<UserPackageLicense>();
        for (String target : userPackageLicenceSet_Target)
        {
            String[] pkgSplit;
            if (!userPackageLicenceMap_Existing.containsKey(target))
            {
                pkgSplit = target.split(';');
                uplListToInsert.add(new UserPackageLicense(UserId=pkgSplit[1], PackageLicenseId = packagelicenseMap.get(pkgSplit[0])));
            }
        }
        
        //v0.3 changes start
        //Insert Assignment
        if (!uplListToInsert.isEmpty())
            database.insert(uplListToInsert, false);
        //v0.3 changes End  
        
        //Find assignments to remove (i.e. those in existing but not in target)
        List<UserPackageLicense> uplListToDelete = new List<UserPackageLicense>();
        for (String existing : userPackageLicenceMap_Existing.keySet())
        {
            if (!userPackageLicenceSet_Target.contains(existing))
                uplListToDelete.add(userPackageLicenceMap_Existing.get(existing));
        }
        //Remove Assignment
        if (!uplListToDelete.isEmpty())
            delete uplListToDelete;
    }
    
    //V0.6 -- cannot call an Invocable method in a batch class. A separate class - BPG_ManageNonSalesforceLicensesInvocable, 
    //is written to innoke this method from process builder
    //@InvocableMethod(label='Insert PackageLicenses' description='Inserts the PackageLicense to the User based upon the Permission Set Assignment.')
    /*public static void doAssignment()
    {
        populatePermissionSetMaps();
        
        uplList = [SELECT Id, PackageLicenseId, UserId, PackageLicense.NamespacePrefix FROM UserPackageLicense];
        psaForPackagesList = [SELECT PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name IN :permissionSetToPackageMap.keySet()];
        userPackageLicenceHelper();
        // start of V0.2 change
        String strfieldnames = ' ';
        for (string fieldAPI : uniqueFieldNameSet) {
            strfieldnames= strfieldnames +','+ fieldAPI;
        }
        string query = 'SELECT Id' +strfieldnames +' FROM User';
        if (test.isRunningTest()){
            query += ' where firstname = \'Test\'';
        }
        userList = Database.query(query);        
        // end of V0.2 change
        psaForUserFieldList = [SELECT PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name IN :permissionSetToUserFieldMap.keySet()];   
        userFieldHelper();
    }
    */
}