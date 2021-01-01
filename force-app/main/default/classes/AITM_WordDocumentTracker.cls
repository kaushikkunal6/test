/************************************************************************************************
 * @author           Shweta
 * @date             08/September/2020
 * @group            AirBP
 * @description      Class for the track of the word documents
 *                   
 * history
 * 08/September/2020   Shweta          Created
 ****************************************************************************************************************/

public class AITM_WordDocumentTracker {

  /**
     * @description gets the word/zip details
     * @param StartDate of String,EndDate of String
     * @return List of the DocumentWrapper class
     */

     @AuraEnabled
      public static list<DocumentWrapper> fetchDoc(String StartDate,String EndDate){      
          Date sDate = date.valueOf(StartDate);
          Time sTime = Time.newInstance(0,0,0,0);
          Datetime newStartDate = Datetime.newInstance(sDate,sTime);        
          Date eDate = date.valueOf(EndDate);
          Time eTime = Time.newInstance(0,0,0,0);
          Datetime newEndDate = Datetime.newInstance(eDate,eTime);
          Set<Id> tendersIds = new Set<Id>();      
      
          List<ContentDocumentLink> contentDocumentLinkTest;
          contentDocumentLinkTest = [SELECT Id,ContentDocument.Id, ContentDocument.Title, ContentDocument.FileType,LinkedEntityId,LinkedEntity.Name,ContentDocument.CreatedDate FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM AITM_Tender__c) AND ContentDocument.FileType IN ('WORD_X', 'WORD','ZIP') AND ContentDocument.CreatedDate >= :newStartDate AND ContentDocument.CreatedDate <= :newEndDate];
          List<DocumentWrapper> result = new List<DocumentWrapper>();
              for (ContentDocumentLink c :contentDocumentLinkTest) {
                       tendersIds.add(c.LinkedEntityId);            
            
              }
           Map<String,String> accGRNMap = new Map<String,String>();
           List<AITM_Tender__c> tenders = [Select Id,Owner.Name,AITM_Tender_Sector__c from AITM_Tender__c where Id IN:tendersIds];
           List<AITM_Tender_Account__c> tenderAccounts = [Select AITM_GRN__c,AITM_Customer_Name__c from AITM_Tender_Account__c where AITM_Tender__c IN:tendersIds];
              for(AITM_Tender_Account__c acc:tenderAccounts){
                    if(!accGRNMap.containsKey(acc.AITM_GRN__c)){
                        accGRNMap.put(acc.AITM_GRN__c,acc.AITM_Customer_Name__c);
                    }
              }
                for (ContentDocumentLink c :contentDocumentLinkTest) {           
                       result.add(new DocumentWrapper(c,tenders,accGRNMap));            
                }        
              
         return result;
       }


   /**
     * @description DocumentWrapper wrapper inner class
     */
      public class DocumentWrapper {
        public @AuraEnabled String TenderName;
        public @AuraEnabled String TenderSector;
        public @AuraEnabled String CustomerName;
        public @AuraEnabled String DocumentTitle;
        public @AuraEnabled String GRN;
        public @AuraEnabled String Owner;
        public @AuraEnabled Date CreatedDate;
        public @AuraEnabled String CreatedTime;       
         
         
       
       public  DocumentWrapper(ContentDocumentLink c,List<AITM_Tender__c> tenders,Map<String,String> accGRNMap){

         this.DocumentTitle = c.ContentDocument.Title;
         this.CreatedDate = (c.ContentDocument.CreatedDate).date();
         this.CreatedTime =  String.valueOf((c.ContentDocument.CreatedDate).time());
         this.TenderName = c.LinkedEntity.Name;
            for(AITM_Tender__c t : tenders){
                if (t.Id == c.LinkedEntityId){
                     this.TenderSector = t.AITM_Tender_Sector__c;
                     this.Owner = t.Owner.Name;
                     break;
                }
            }
           String s1 = c.ContentDocument.Title;
           String s2;
           String s3 ;   
  
             if(s1.contains('_')) {   
               s2 = s1.substringAfterLast('_');
               String numericString = '';    
                   if(s2.contains('Agreement') || s2.contains('FFSA')){
                         s2 = s2.substringBeforeLast('-');
                         s3 =  s2.right(7);        
                   } else{
                         if(s2.split('-').size()>1) {
                             s3 = s2.split('-')[0];        
                         } else{
                                for(integer i=0;i<s2.length();i++){
                                   String s = s2.mid(i,1);
                                       if(s.isNumeric()){
                                       numericString +=s;
                                       }
                                         if(numericString.length()>7){
                                             numericString = numericString.right(6) ;
                                         }            
                                }
                                 s3 = numericString;
                           }            
                   }        
             } else{
                    if(s1.contains('-')){
                       s2 = s1.substringBeforeLast('-');        
                       s3 = s2.left(6);        
                    }        
             }
                this.GRN = s3;
                this.CustomerName = accGRNMap.get(s3);  
      
       }
      }
}