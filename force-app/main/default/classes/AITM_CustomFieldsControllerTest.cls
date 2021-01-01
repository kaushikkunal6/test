@isTest
public class AITM_CustomFieldsControllerTest {
    
    @isTest
    static void fetchRecordsTest1() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Phone = '123456789';
        acc.Type = 'Prospect';
        insert acc;
        
        List<AITM_ReusableCustomLookupCntrl.RecordsData> result = AITM_ReusableCustomLookupCntrl.fetchRecords('Account', 'Name', 'Test', '');
        List<String> result1 = AITM_PickListController.getPickListValuesIntoList('Account','Type');
        
        System.assertEquals(result != null, true);
    }
    
    @isTest
    static void fetchRecordsTest2() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Phone = '123456789';
        acc.Type = 'Prospect';
        insert acc;
        
        List<AITM_ReusableCustomLookupCntrl.RecordsData> result = AITM_ReusableCustomLookupCntrl.fetchRecords('Account', 'Name', 'Test', acc.Id);
        System.assertEquals(result.size(), 1);
    }
    
    @isTest
    static void fetchRecordsNegativeTest() {
        try {
            List<AITM_ReusableCustomLookupCntrl.RecordsData> result = AITM_ReusableCustomLookupCntrl.fetchRecords('', 'Name', 'Test', '');
        } catch(Exception ex) {
            System.assertNotEquals(ex.getMessage(), NULL);
        }
    }
}