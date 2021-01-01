/*****************************************************************************************
*       Date:        4NOV2019
*       Author:      Naglis Kazlauskas - IBM
*       Description: Test class for BPI_SharepointAPIService
*****************************************************************************************/
@isTest	
public class BPI_SharePointAPIServiceTests {
    /**
    * @description 	creates data which is used it the other tests
    * @param
    * @return
    */
    @TestSetup
    static void makeData(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(newUser);
        insert newCounterpartyContactList;
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(newDocumentRequestList,
                                                                                               newCounterpartyContactList, 2);
        insert newDocumentStoreList;
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(2);
        for (ContentVersion cV : newContentVersionList) {
            cV.DUP_Status__c = 'Approved';
        }
        insert newContentVersionList;
        
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 2];
        List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
        for (Integer i = 0; i < newDocumentStoreList.size(); i++) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId      = newDocumentStoreList[i].Id;
            cdl.ContentDocumentId   = cdList[i].Id;
            cdl.shareType           = 'V';
            cdl.Visibility          = 'AllUsers'; 
            insertCDLList.add(cdl);
        }
        insert insertCDLList;      
    }
    /**
    * @description 	tests the API callout and asserts the desired response. 
    * 				Uses in storeIds which have documents attacthed to them
    * @param
    * @return
    */
    @isTest static void pushFilesToSharepointTest(){
        List<DUP_Document_Request__c> newRequestTestList = [SELECT Id 
                                                            FROM DUP_Document_Request__c 
                                                            WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                            LIMIT 1];
        
        List<DUP_Document_Store__c> newDocumentStoreList = [SELECT Id
                                                            FROM DUP_Document_Store__c 
                                                            WHERE DUP_Document_Request__c =: newRequestTestList[0].Id];  
        Set<Id> linkedEntityIds = new Set<Id>();
        for(DUP_Document_Store__c dS : newDocumentStoreList){
            linkedEntityIds.add(dS.Id);
        }     
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BPI_SharePointAPIServiceHttpCalloutMock()); 
        BPI_SharepointAPIService newCall = BPI_SharepointAPIService.init('baseFolderListValue', 'subFolderValue');
        Map<Id,List<BPI_SharepointAPIService.ResponseWrapper>> apiResponsesResults = newCall.pushFilesToSharepoint(linkedEntityIds);
        Test.stopTest(); 
        List<Id> myIdList = new List<Id>();
        myIdList.addAll(apiResponsesResults.keySet());
        List<BPI_SharepointAPIService.ResponseWrapper> myWrap = apiResponsesResults.get(myIdList[0]);
        HttpResponse trueResponse = myWrap[0].response;
        System.assertEquals('multipart/form-data;boundary=----------------------------153501500631101', trueResponse.getHeader('Content-Type'));
        System.assertEquals('baseFolder', trueResponse.getHeader('BaseFolderName'));
        System.assertEquals('subFolder', trueResponse.getHeader('CounterpartyId'));
        System.assertEquals(200, trueResponse.getStatusCode());
        System.assertEquals(2, apiResponsesResults.size());
    }
    /**
    * @description 	tests buildBodyBlob method -- by passing in blobs with different 
    * 				value in the end (the desired values '=' & '==')
    * @param
    * @return
    */
    @isTest static void buildBodyBlobTest(){
        Blob blobOfString0 = Blob.valueof('====');
        Blob blobOfString1 = Blob.valueof('/someParent/single.endswithdots=');
        Test.startTest();
        Blob returnBlob0 = BPI_SharepointAPIService.buildBodyBlob(blobOfString0, 'baseFolder', 'subFolder');
        Blob returnBlob1 = BPI_SharepointAPIService.buildBodyBlob(blobOfString1, 'baseFolder', 'subFolder');
        Test.stopTest();
        System.assertEquals(true, returnBlob0.toString().contains('===='));
        System.assertEquals(true, returnBlob1.toString().contains('/someParent/single.endswithdots='));
    }
}