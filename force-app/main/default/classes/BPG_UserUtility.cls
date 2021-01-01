/*****************************************************************************************
*   Date:           20AUG19
*   Author:         Nilang Pandey – TCS (Tata Consultancy Services Ltd.)
*   Description:    Updates the ManagerId based on populated field BPG_Manager_NTID__c on User record before insert and before update
*   Modifications:  
****************************************************************************************/
public with sharing class BPG_UserUtility {
    
    //This method is used to fill the Map used for getting Id of user with respective NTID
    public static Map<String, Id> fillNtidMap() {
        Map<String, Id> ntIdMapTemp = new Map<String, Id>();
        List<User> usersNow = [
                                SELECT
                                    Id,
                                    NTID__c,
                                    Name,
                                    ManagerId,
                                    BPG_Manager_NTID__c
                                FROM 
                                    User
                                WHERE
                                    IsActive = true
                                AND
                                    UserType = 'Standard'
                                AND 
                                    NTID__c != NULL
                            ];
        for (User userTemp : usersNow) {
            if (userTemp.NTID__c != null) {
                ntIdMapTemp.put(userTemp.NTID__c, userTemp.Id);
            }
        }
        return ntIdMapTemp;
    }
    
    //After Insert method called when a new user with Manager NTID is inserted, ManagerId is set here
    public static void updateManagerWithNTID(List<User> lstNewUsers) {
        List<User> lstUserUpdate = new List<User>();
        Map<String, Id> mapUserNtid = new Map<String, Id>();
        if (lstNewUsers.size() > 0) {
            mapUserNtid = fillNtidMap();
            for (User newUser : lstNewUsers) {
                if (newUser.BPG_Manager_NTID__c != null) {
                    User userOne = new User(Id = newUser.Id, ManagerId = mapUserNtid.get(newUser.BPG_Manager_NTID__c));
                    lstUserUpdate.add(userOne);
                }
            }
            if (lstUserUpdate.size() > 0) {
                update lstUserUpdate;
            }
        }
    }
    
    //After Update method called when a new user with Manager NTID is inserted, ManagerId is set here
    public static void updateManagerWithNTID(List<User> lstNewUsers, Map<Id, User> mapOldUsers) {
        List<User> lstUserUpdate = new List<User>();
        Map<String, Id> mapUserNtid = new Map<String, Id>();
        if (lstNewUsers.size() > 0) {
            mapUserNtid = fillNtidMap();
            for (User newUser : lstNewUsers) {
                if (mapOldUsers.get(newUser.Id).BPG_Manager_NTID__c != newUser.BPG_Manager_NTID__c) {
                    User userOne = new User(Id=newUser.Id, ManagerId = mapUserNtid.get(newUser.BPG_Manager_NTID__c));
                    lstUserUpdate.add(userOne);
                }
            }
            if (lstUserUpdate.size() > 0) {
                update lstUserUpdate;
            }
        }
    }
}