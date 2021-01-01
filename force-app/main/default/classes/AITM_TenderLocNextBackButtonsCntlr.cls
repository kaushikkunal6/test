/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      controller class used in aura component Tender Locations Next and Back buttons

 * history
 * 01/December/2017  George      Created 
 * 08/May/2018       srnandan    added with sharing and comments at method and class level as per coding standards
 *                               added auraenabledmethod "getTenderIdByTenderLocationId" to get tenderid
 ************************************************************************************************/
public class AITM_TenderLocNextBackButtonsCntlr {

    /**
     * @description gets tender locations
     * @param tenderLocationId of type String
     * @param filteredTenderLocationIds of type String
     * @return List<AITM_Tender_Location__c> collection of AITM_Tender_Location__c 
     */

      @AuraEnabled 
      public static List<AITM_Tender_Location__c> getTenderLocations(String tenderLocationId, String filteredTenderLocationIds) {
          System.debug('tenderLocationId='+tenderLocationId);
    	AITM_LocationsDao locationsDao = new AITM_LocationsDao();
    	List<String> criterias = new List<String>();
    	Id tenderId = locationsDao.getTenderIdByTenderLocationId(tenderLocationId);
		System.debug('tenderId='+tenderId);
    	if(filteredTenderLocationIds != null && filteredTenderLocationIds != 'null' && filteredTenderLocationIds != ''){
			criterias.add('Id IN (' + filteredTenderLocationIds + ')');
    	}else {
    		criterias.add('AITM_Is_Current_Round__c = true');
    	}
    	
		return locationsDao.getTenderLocationsWithLineItems(tenderId, criterias);
    }
	
    /**
     * @description gets tenderid for a given tender location
     * @param tenderLocationId of type String
     * @return Id 
     */

      @AuraEnabled 
      public static Id getTenderIdByTenderLocationId(String tenderLocationId) {
        AITM_LocationsDao locationsDao = new AITM_LocationsDao();
        Id tenderId = locationsDao.getTenderIdByTenderLocationId(tenderLocationId);
        return tenderId;
    }

}