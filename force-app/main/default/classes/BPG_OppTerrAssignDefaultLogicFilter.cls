/*** Apex version of the default logic.
* If opportunity's assigned owner is assigned to
*  Case 1: 0 territories in active model
*            then set territory2Id = null
*  Case 2: 1 territory in active model
*            then set territory2Id = owner's territory2Id
*  Case 3: 2 or more territories in active model
*            then set territory2Id = owner's territory2Id that is of highest priority.
*            But if multiple territories have same highest priority, then set territory2Id = null 
*/
global inherited sharing class BPG_OppTerrAssignDefaultLogicFilter implements TerritoryMgmt.OpportunityTerritory2AssignmentFilter {
    
    // Set of Opp Record Type Ids In Scope
    // If you want to add your types, or modify the logic, please contact SFO TEAM
    private static final Set<Id> OPP_RTID_IN_SCOPE = new Set<Id>(SFO_Constant.VALID_RECORD_TYPES);
        
    // Set of Opp Record Type Ids In Scope  
    private static final Set<Id> SET_OPP_RTID_IN_SCOPE = new Set<Id>(BPG_Constant.VALID_RECORD_TYPES);   
    
    global BPG_OppTerrAssignDefaultLogicFilter() {}
    
    global Map<Id,Id> getOpportunityTerritory2Assignments(List<Id> opportunityIds) {
        Map<Id, Id> OppIdTerritoryIdResult = new Map<Id, Id>();

        // Get the active territory model Id
        Id activeModelId = getActiveModelId();
        if(activeModelId != null){
            List<Opportunity> opportunities = 
                [SELECT Id, AccountId, OwnerId, Territory2Id 
                 FROM Opportunity 
                 WHERE Id IN :opportunityIds
                  AND (RecordTypeId IN :OPP_RTID_IN_SCOPE OR  RecordTypeId IN :SET_OPP_RTID_IN_SCOPE)];
            
            Set<Id> ownerIds = new Set<Id>();
            // Create set of parent ownerIds
            for(Opportunity opp : opportunities){
                ownerIds.add(opp.OwnerId);
            }
            Map<Id,Territory2Priority> accountMaxPriorityTerritory = getUserMaxPriorityTerritory(activeModelId, ownerIds);
            // For each opportunity, assign the highest priority territory if there is no conflict, else assign null.
            for(Opportunity opp: opportunities){
                Territory2Priority tp = accountMaxPriorityTerritory.get(opp.OwnerId);
                // Assign highest priority territory if there is only 1.
                if(tp != null && !tp.moreTerritoriesAtPriority){
                    OppIdTerritoryIdResult.put(opp.Id, tp.territory2Id);
                }else{
                    OppIdTerritoryIdResult.put(opp.Id, null);
                }
            }
        }
        return OppIdTerritoryIdResult;
    }
    /**
      * Query assigned territoryIds in active model for given ownerIds.
      * Create a map of OwnerId to max priority territory.
      */
     private Map<Id,Territory2Priority> getUserMaxPriorityTerritory(Id activeModelId, Set<Id> ownerIds){
        Map<Id,Territory2Priority> userMaxPriorityTerritory = new Map<Id,Territory2Priority>();
        for(UserTerritory2Association uta : 
            [SELECT UserId, Territory2Id, Territory2.Territory2Type.Priority 
             FROM UserTerritory2Association 
             WHERE UserId IN :ownerIds 
              AND Territory2.Territory2ModelId = :activeModelId
             ORDER BY Territory2.Territory2Type.Priority ASC])
        {

            // If this is the first territory examined for owner 
            // or it has greater priority than current highest priority territory, 
            // then set this as new highest priority territory.
            userMaxPriorityTerritory.put(
                uta.UserId, 
                new Territory2Priority(
                    uta.Territory2Id,
                    uta.Territory2.Territory2Type.priority,
                    // The priority of current highest territory is same as this, 
                    // so set moreTerritoriesAtPriority to indicate multiple highest priority territories seen so far.
                    (userMaxPriorityTerritory.containsKey(uta.UserId) && 
                     uta.Territory2.Territory2Type.priority == userMaxPriorityTerritory.get(uta.UserId).priority)));
        }
        return userMaxPriorityTerritory;
    }
    /**
     * Get the Id of the Active Territory Model.
     * If none exists, return null.
     */
    private Id getActiveModelId() {
        List<Territory2Model> models = [Select Id from Territory2Model where State = 'Active'];
        Id activeModelId = null;
        if(models.size() == 1){
            activeModelId = models.get(0).Id;
        }

        return activeModelId;
    }
    /**
    * Helper class to help capture territory2Id, its priority, and whether there are more territories with same priority assigned to the account.
    */
    @testVisible
    private class Territory2Priority {
        
        public Id territory2Id { get; set; }
        public Integer priority { get; set; }
        public Boolean moreTerritoriesAtPriority { get; set; }
		@testVisible
        Territory2Priority(Id territory2Id, Integer priority, Boolean moreTerritoriesAtPriority){
            this.territory2Id = territory2Id;
            this.priority = priority;
            this.moreTerritoriesAtPriority = moreTerritoriesAtPriority;
        }
    }
}