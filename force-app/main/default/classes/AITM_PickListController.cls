/*
*Created By : Neeti Thapliyal Bourai
*Create Date": 06/11/2020
* Class is created as a resuable componnent for picklist field.
*
*/
public class AITM_PickListController {
	@AuraEnabled        
    public static List<String> getPickListValuesIntoList(String objectType, String selectedField){
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        for( Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){ 
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
}