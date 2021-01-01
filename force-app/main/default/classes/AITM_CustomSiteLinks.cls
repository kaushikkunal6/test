/*************************************************************************
 * @author         srnandan
 * @date           19/December/2019
 * @group          AirBP
 * @description    controller class being called from lwc component to display custom site links

 * history
 * 19/December/2019  srnandan       Created  
 *************************************************************************/
public with sharing class AITM_CustomSiteLinks {
    /**
     * @description gets custom site link object details group by category
     * @param null
     * @return Map collection containing site link details
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AITM_Site_Links__c>> getCustomLinks() {
        Map<String, List<AITM_Site_Links__c>> mapSiteLinkByCategory = new Map<String, List<AITM_Site_Links__c>>();

        for(AITM_Site_Links__c sitelink : [
            SELECT Name, AITM_Site_URL__c, AITM_Target__c, AITM_Category__c, AITM_Description__c
            FROM AITM_Site_Links__c
            WHERE AITM_Active__c = true order by AITM_Order__c
        ]) {
            if(mapSiteLinkByCategory.containsKey(sitelink.AITM_Category__c)) {               
                mapSiteLinkByCategory.get(sitelink.AITM_Category__c).add(sitelink);
            } else {
                mapSiteLinkByCategory.put(sitelink.AITM_Category__c, new List<AITM_Site_Links__c>{ sitelink });
            }
        }

        return mapSiteLinkByCategory;
    }
}