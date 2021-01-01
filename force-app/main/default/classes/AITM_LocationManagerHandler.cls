/**
 * @author George Arshakian
 * @description AITM_LocationManagerHandler - Trigger Handler for Location Manager object. Contains two processes - population of owner and check for one LM per one sector
 **/ 
public with sharing class AITM_LocationManagerHandler implements AITM_TriggerFactory.SObjectHandler {
    private final String DUPLICATE_SECTOR_LOCATION_MANAGER = Label.AITM_LocationManagerDuplicateMessage;
    private List<AITM_Location_Manager__c> locationManagersToCheck;

    public AITM_LocationManagerHandler() {
        locationManagersToCheck = new List<AITM_Location_Manager__c>();
    }

    public void bulkBefore() {}
    public void bulkAfter() {}
    public void beforeInsert(SObject so) {
        AITM_Location_Manager__c manager = (AITM_Location_Manager__c) so;
        if (manager.AITM_Location_Manager__c != null) {
            manager.OwnerId = manager.AITM_Location_Manager__c;
        }
        locationManagersToCheck.add(manager);
    }
    public void beforeUpdate(SObject oldSo, SObject so){
        AITM_Location_Manager__c oldManager = (AITM_Location_Manager__c) oldSo;
        AITM_Location_Manager__c manager = (AITM_Location_Manager__c) so;
        if (manager.AITM_Location_Manager__c != null
            && manager.AITM_Location_Manager__c != oldManager.AITM_Location_Manager__c) {
            manager.OwnerId = manager.AITM_Location_Manager__c;
        }
    }
    public void beforeDelete(SObject so) {}
    public void afterInsert(SObject so) {}
    public void afterUpdate(SObject oldSo, SObject so) {}
    public void afterDelete(SObject so) {}
    public void andFinally() {
        if (locationManagersToCheck.size() > 0) {
            addErrorsForExistingSectors();
        }
    }

    /**
     * @author George Arshakian
     * @description addErrorsForExistingSectors - method, which is adding errors to all new location managers which are having the same sector as an existing LM
     **/
    private void addErrorsForExistingSectors() {
        Set<Id> locationsIds = new Set<Id>();
        for (AITM_Location_Manager__c manager : this.locationManagersToCheck) {
            locationsIds.add(manager.AITM_Location__c);
        }

        Map<Id, Set<String>> existingSectors = new Map<Id, Set<String>>();
        for (AITM_Location_Manager__c existingManager : AITM_LocationManagerDao.getInstance().getLocationManagersForLocation(locationsIds)) {
            if (!existingSectors.containsKey(existingManager.AITM_Location__c)) {
                existingSectors.put(existingManager.AITM_Location__c, new Set<String>());
            }
            existingSectors.get(existingManager.AITM_Location__c).add(existingManager.AITM_Sector__c);
        }

        for (AITM_Location_Manager__c manager : this.locationManagersToCheck) {
            if (existingSectors.containsKey(manager.AITM_Location__c)) {
                if (existingSectors.get(manager.AITM_Location__c).contains(manager.AITM_Sector__c)) {
                    manager.addError(DUPLICATE_SECTOR_LOCATION_MANAGER);
                }
            }
        }
    }
}