/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    class to holds user data access object

 * history
 * 06/December/2017  George       Created 
 * 04/April/2018     srnandan     Modified - added code comments class and methods
 * 20/April/2018     srnandan     Modified - removed id in soql as apex always returns id
 *************************************************************************/
public without sharing class AITM_UsersDao {

    /**
     * @description gets list of location manager users
     * @return List collection of User
     */
    public List<User> getLocationManagers() {
        return [SELECT Name FROM User WHERE ProfileId = :this.getProfileId('Air_TMLocation Manager')];
    }

    /**
     * @description gets list of users related to pricing responsibility and delegates
     * @param delegates Set<String>
     * @return Map collection of User
     */
    public List<user> getPricingUsersAndDelegatesAll(Set<String> delegates) {
         return ([SELECT Id FROM User WHERE (Email IN :delegates) AND IsActive = true]);//AND ProfileId = :this.getProfileId('Air_TMLocation Manager')
       
    }

    /**
     * @description gets profile id for a given profile name
     * @param profileName of type string
     * @return Id
     */
    public Id getProfileId(String profileName) {
        return [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1][0].Id;
    }

    /**
     * @description get profilename for a user
     * @param userId of type Id
     * @return string
     */
    public String getProfileName(Id userId) {
        return [SELECT ProfileId, Profile.Name FROM User WHERE Id = :userId LIMIT 1][0].Profile.Name;
    }
    /**
     * @description gets list of users related to pricing responsibility and delegates
     * @return List collection of User
     */
    public Map<Id,User> getPricingUsersAndDelegates(Set<Id> pricingUsers, Set<String> delegates) {
        return new Map<Id, User>([SELECT Id, Email FROM User WHERE (Email in :delegates OR Id in :pricingUsers) AND IsActive = true]);// AND ProfileId = :this.getProfileId('Air_TMLocation Manager')]);
    }
    /**
     * @description gets list of users related to pricing responsibility and delegates
     * @param delegates Set<String>
     * @return Map collection of User
     */
    public Map<Id, String> getPricingUsersAndDelegates(Set<String> delegates) {
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE (Email IN :delegates) AND IsActive = true]);//AND ProfileId = :this.getProfileId('Air_TMLocation Manager')
        Map<Id, String> userEmailMap = new Map<Id, String>();
        for(Id userId : userMap.keySet()) {
            userEmailMap.put(userId, userMap.get(userId).Email);
        }
        return userEmailMap;
    }

}