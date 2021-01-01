/***********************************************************************************************
 * @author           srnandan
 * @date             12/August/2018
 * @group            AirBP
 * @description      Used for listing Content Document Link files for related record
 
 * history
 * 12/August/2018    srnandan        Created
 *************************************************************************************/
public with sharing class AITM_RelatedTenderFileListController {

    /**
        * @description gets if the tender owner has been logged
        * @param Id as arecordId
        * @return boolean
        */
        @AuraEnabled
        public static Boolean getProfileInfo(Id arecordId){
        Boolean b = false;
        AITM_Tender__c t = [Select OwnerId from AITM_Tender__c where Id = :arecordId];
        Id loggedUserid = UserInfo.getUserId();
            if(t.OwnerId == loggedUserid)  {
                b = true;
          }
        return b;
        
    }

    /**
        * @description gets the relevant documents for the non owner of the tender
        * @param Id as arecordId        
        * @return list of Content Document
        */

    
    @AuraEnabled
    public static List<ContentDocument> getContentDocs(Id arecordId)
    {   
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocument.Title, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId AND (ContentDocument.Title LIKE 'LABP DEBRIEF%' OR ContentDocument.Title LIKE 'LABP FEEDBACK%')];
        if (contentDocumentLinks.size() < 1) return new List<ContentDocument>(); 
        
        // Make a List of ContentDocument IDs
        List <Id> documentIds = new List <Id> ();
        for (ContentDocumentLink nextCDL : contentDocumentLinks) {
            documentIds.add(nextCDL.ContentDocumentId); 
        }        
        
        List<ContentDocument> entries = [SELECT Title, FileType, ContentSize, LastModifiedDate, LatestPublishedVersionId FROM ContentDocument WHERE Id IN :documentIds ORDER BY LatestPublishedVersionId DESC LIMIT 50];
        return entries;
    }
}