/**
 * @author George Arshakian
 * @description AITM_LocationManagerDao - DAO (Data Access) class for a Location Manager object. Contains SOQL/DML operations to wrap them and not use directly
 **/ 
public with sharing class AITM_LocationManagerDao  {
    private static AITM_LocationManagerDao instance;
    private static Set<String> MANAGER_SECTORS;
     
    public static AITM_LocationManagerDao getInstance() {
        if (instance == null) {
            instance = new AITM_LocationManagerDao();
        }
        return instance;
    }

    public static Set<String> getSectors() {
        if (MANAGER_SECTORS == null) {
            MANAGER_SECTORS = new Set<String>();
            for (Schema.PicklistEntry sectorValue : AITM_Location_Manager__c.AITM_Sector__c.getDescribe().getPicklistValues()) {
                MANAGER_SECTORS.add(sectorValue.getValue());
            }
        }
        return MANAGER_SECTORS;
    }

    public List<AITM_Location_Manager__c> getLocationManagersForLocation(Set<Id> locationsIds) {
        return [SELECT Id, AITM_Sector__c, AITM_Location__c FROM AITM_Location_Manager__c WHERE AITM_Location__c IN :locationsIds];
    }

    public List<AITM_Location_Manager__c> createLocationManagers(Id locationId, Id userId) {
        List<AITM_Location_Manager__c> result = new List<AITM_Location_Manager__c>(); 
        for (String sector : AITM_LocationManagerDao.getSectors()) {
            result.add(new AITM_Location_Manager__c(
                AITM_Sector__c = sector,
                AITM_Location_Manager__c = userId,
                AITM_Location__c = locationId
            ));
        }
        return result;
    }

    public void saveLocationManagers(List<AITM_Location_Manager__c> locationManagers) {
        Database.insert(locationManagers, false);
    }
}