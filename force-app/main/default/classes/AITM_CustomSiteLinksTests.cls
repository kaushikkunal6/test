/*************************************************************************
 * @author         srnandan
 * @date           19/December/2019
 * @group          AirBP
 * @description    test class for controller AITM_CustomSiteLinks

 * history
 * 19/December/2019  srnandan       Created  
 *************************************************************************/
@isTest 
private inherited sharing class AITM_CustomSiteLinksTests {

    /**
     * @description tests to viewing custom links
     * @param  null
     * @return void
     */
    @isTest 
    static void testCustomLinksDisplayCategorywise() {
        AITM_CustomLinksControllerTestSetup testSetup = new AITM_CustomLinksControllerTestSetup();
        Test.startTest();
            Map<String, List<AITM_Site_Links__c>> mapSiteLinks = AITM_CustomSiteLinks.getCustomLinks();
        Test.stopTest();
        System.assertEquals(2 , mapSiteLinks.size());
    }
	
    /**
     * @description class to hold custom links controller test
     */
    private inherited sharing class AITM_CustomLinksControllerTestSetup {
        public List<AITM_Site_Links__c> sitelinks = new List<AITM_Site_Links__c>();
        public final Integer ITEM_SIZE = 10;
        public AITM_CustomLinksControllerTestSetup() {
            
            for(integer i = 0 ; i < ITEM_SIZE; i++) {
                AITM_Site_Links__c sitelink = new AITM_Site_Links__c();
                sitelink.Name = 'Name' + i;
                sitelink.AITM_Site_URL__c = 'https://xyz.com/'+ i;
                sitelink.AITM_Target__c = '_blank';
                sitelink.AITM_Description__c = 'desc' + i;
                sitelink.AITM_Active__c = true;
                if(i < 5) {
                    sitelink.AITM_Category__c = 'System';
                } else {
                    sitelink.AITM_Category__c = 'Data';
                }
                sitelinks.add(sitelink);
            }

            insert sitelinks;
        }
    }
}