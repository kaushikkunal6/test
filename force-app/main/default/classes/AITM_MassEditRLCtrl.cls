/***********************************************************************************************
 * @author           Neeti
 * @date             23/August/2019
 * @group            AirBP
 * @description      Used for Tender LocationTaxesAndFees edit veiw in TenderLocationLineItem Related List
 
 * History

**********************************************************************************************/
public with sharing class AITM_MassEditRLCtrl {    

    /**
     * @description gets layout
     * @param recordId set collection of type string   
     * @param sObjectName sobject name
     * @param sessionID of type string
     * @return MassEditLayout
     */   
    @AuraEnabled
    public static MassEditLayout getLayout(string recordId, string sObjectName, string sessionID) {
        // Check if the object has record types enabled
        sessionID = getSessionIdFromVFPage();
        List<RecordType> rts = [SELECT Id FROM RecordType WHERE SObjectType = :sObjectName ];
        Id recordTypeId = null;
        if (rts.size() > 0) {
            //Get record type id from the record that started the lightning component. 
            string soql = 'SELECT RecordtypeId FROM ' + sObjectName + ' WHERE id = \'' + recordId + '\'';
            List<sobject> records = Database.query(soql);
            recordTypeId = (Id)records[0].get('RecordtypeId');
        }
       
        //SELECT DEFAULT MASTER RECORD TYPE IF NO RECORDTYPE FOUND
        // now, let's get the layout for this record type id by quering the metadata api
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        String url =  salesforceHost + Label.AITM_MassEdit_URL2 + sObjectName +'/describe/layouts/' + recordTypeId;
        
        HttpRequest req = new HttpRequest();
            
        req.setMethod('GET');
        req.setEndpoint(url);
        req.setHeader('Content-type', 'application/json');
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId()); // Not working when apex called from a lightning component
        req.setHeader('Authorization', 'Bearer ' + sessionID); //sessionID is loaded in a VF and passed as a parameter to this aura method. 
        //previous line needs to be commented if using oAuth.
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        
        try {
            res = http.send(req);
        } catch (Exception e) {
            //"Convert" the exception into an AuraHandledException
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }
        
        String jsonString = res.getBody();// Now we have all the record metadata as a string. 
        // We need to convert it into APEX object. But before that we want to get rid of apex reserved words
        
        jsonString = jsonString.replace('"sobject":', '"objectname":');//required because sobject is reserved in apex
        jsonString = jsonString.replace('"sort":', '"sortBy":');//required because sort is reserved in apex
        
        
        MassEditLayout mel = new MassEditLayout(sObjectName);
        
        //The following JSON parser does the job of converting the metadata api result into one RList Object
        //for each related list. These RList Object are stored into MassEditLayout Object and returned to the lightning
        //component. 
        JSONParser parser = JSON.createParser(jsonString);
        Boolean isActivitiesAdded = false;
        while (parser.nextToken() != null) {
        
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'relatedLists')) {
                    parser.nextToken();
                    
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            RList rl = (RList)parser.readValueAs(RList.class);
                            if (rl.objectname=='CombinedAttachment' || rl.objectname=='AttachedContentDocument' 
                                || rl.objectname=='CollaborationGroupRecord' || rl.objectname=='ProcessInstanceHistory'
                                || rl.objectname=='EmailStatus' || rl.objectname==null || rl.objectname=='OpportunitySplit'
                                || (rl.objectname.contains('History') && rl.objectname!='ActivityHistory' && !rl.objectname.endsWith('__c'))
                                || rl.objectname=='AttachedContentNote'  
                               )
                                continue; //skip some not queryable standard objects
                            
                            //Remove all related list with no lookupid to the parent record. 
                            if (rl.field == null) {
                                if (rl.objectname=='Opportunity' && sObjectName=='Contact') {} 
                                else continue;
                            }
                            
                            //ActivityHistory and OpenActivities object are special objects that need to be handled differently
                            if (rl.objectname=='ActivityHistory' || rl.objectname=='OpenActivity' ) {
                                if (!isActivitiesAdded) addTaskAndEventRL(mel);
                                isActivitiesAdded=true;
                                continue;
                            }
                            mel.relatedLists.add(rl);
                            String s = JSON.serialize(rl);
                            //If we find account or opp teams, we'll add a related list with an extraction of users
                            if (rl.objectname=='OpportunityTeamMember' || rl.objectname=='AccountTeamMember' )
                                mel.relatedLists.add(extractRelatedList(rl,'User',new SortProperties('FirstName',true)));
                                //addExtractedUsers(mel);
                            //If we find campaign influence, we'll add a related list with an extraction of campaigns
                            if ((rl.objectname=='CampaignInfluence' && sObjectName=='Opportunity')
                                || (rl.objectname=='CampaignMember' && sObjectName=='Contact')) {
                                    RList RCampaign = extractRelatedList(rl,'Campaign',new SortProperties('Name',true));
                                    if (RCampaign!=null) mel.relatedLists.add(RCampaign);
                            }
                            
                            if (rl.objectname=='OpportunityContactRole')
                                mel.relatedLists.add(extractRelatedList(rl,'Contact',new SortProperties('FirstName',true)));
                            
                            if (rl.objectname=='OpportunityLineItem'){
                                Rlist RPBE = extractRelatedList(rl,'PriceBookEntry',new SortProperties('Product2.Name',true));
                                if (RPBE!=null) {
                                    mel.relatedLists.add(RPBE);
                                    Rlist RProducts = extractRelatedList(RPBE,'Product2',new SortProperties('Name',true));
                                    if (RProducts!=null) mel.relatedLists.add(RProducts);
                                    }
                            }   
                    }
                }
            }
        }
        
        }
      
      mel.layoutId=jsonString.substringAfter('"id":"').substringBefore('"');
      mel.objectId=getObjectIdFromToolingApi(sObjectName,sessionID);
      //addChatterPosts(mel);  
      // Standard objects sometimes have some strange behavours that we need to correct
      fixStandardObjects(mel); 
      fixLookupFields(mel);  
      for (RList rl : mel.relatedLists){
        rl.objectId=getObjectIdFromToolingApi(rl.objectname,sessionID);
        rl.parentRecordLayoutId=mel.layoutId;
        rl.parentObjectId=mel.objectId;
        rl.parentObjectName=mel.objectName;
      }    
      // We need also to figure wich fields are mandatory to create new records but are not included in the layout. 
      // These fields will be used to clone or to create blank records. 
      getExtraFields(mel);   
      // Finally, we also need some metadata for each field. Is the field editable ? What's its type ?
      getRLMetaData(mel);
      getFieldsMetaData(mel);

      return mel;
    }

    /**
     * @description gets currecny list from taxes
     * @param sObjectName sobject name
     * @return listOfCurrency of type List
     */  
    @AuraEnabled(cacheable=true)
    public static List<String> getListOfCurrency(){
        List<String> listOfCurrency = new List<String>();
        List<AggregateResult> records = [SELECT AITM_Currency__c FROM AITM_Taxes_Fees__c GROUP BY AITM_Currency__c];
        for (AggregateResult ar : records)  {
            listOfCurrency.add(String.valueOf(ar.get('AITM_Currency__c')));
        }
        return listOfCurrency;
    }   
    
    /**
     * @description gets object id from tooling api
     * @param sObjectName sobject name
     * @param sessionID of type string
     * @return string
     */  
    public static String getObjectIdFromToolingApi(string sObjectName, string sessionID){
        String objectName = sObjectName;
        if (objectName.endsWith('__c')) {
            objectName= objectName.removeEnd('__c');
        } else {
            return objectName;
        }    

        String query = 'SELECT Id From CustomObject Where DeveloperName = \'' + objectName + '\'';
        String endpoint = Url.getSalesforceBaseUrl().toExternalForm();
        endpoint += Label.AITM_MassEdit_URL1;
        endpoint += EncodingUtil.urlEncode(query, 'UTF-8');
        
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + sessionID);
        request.setEndpoint(endpoint);
        
        
        String customObjectId='';        
        try {
            HttpResponse response = new Http().send(request);
            customObjectId = response.getBody().substringAfter('"Id":"').substringBefore('"');
        } catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }    
        
        customObjectId=customObjectId.left(15);
        return customObjectId;
    }
    
   
   /**
     * @description Following method is to extract a relatedlist from another related list and allow to edit fields in source related list
     * @param sObjectName sobject name
     * @param sessionID of type string
     * @return string
     */
    public static RList extractRelatedList(RList sourceRL, String objectToExtract, SortProperties sortBy) {
       Schema.SObjectType oExtract = Schema.getGlobalDescribe().get(objectToExtract);  
       RList rl = new RList();
       rl.objectname = objectToExtract;
       rl.label = oExtract.getDescribe().getLabelPlural()+' (extracted from '+sourceRL.objectName+')';
       rl.field = null;
       rl.extractedFrom = sourceRL.objectName;
       rl.sortBy = new list<SortProperties>();
       rl.sortBy.add(sortBy);
       rl.columns = new list<Column>();
       //If the extracted object is user, let's override the related list columns
       if (rl.objectname =='User') {
         rl.columns.add(new Column('FirstName'));
         rl.columns.add(new Column('LastName'));
         rl.columns.add(new Column('Title'));  
         return rl;  
       }
       //If we extract another object, let's extract the columns for the new object from the columns in the source object
       for (column col:sourceRL.columns){
         if (col.fieldApiName.startsWithIgnoreCase(objectToExtract+'.'))
             rl.columns.add(new Column(col.fieldApiName.removeStartIgnoreCase(objectToExtract+'.')));
       }
       if (rl.columns.size()>0) return rl;
       else return null;
   }      
  
    
    /**
     * @description Task and events are weird objets for which the metadata api provide weird information. 
     * @param mel MassEditLayout
     * @return null
     */
    static void addTaskAndEventRL(MassEditLayout mel) {
        RList rlTask = new RList();
        rlTask.objectname='Task';rlTask.label='Tasks';
        rlTask.field=(mel.objectName!='Lead') ? 'WhatId' : 'WhoId';
        rlTask.sortBy=new list<SortProperties>();
        rlTask.sortBy.add(new SortProperties('ActivityDate',false));
        rlTask.columns = new list<Column>();
        rlTask.columns.add(new Column('Subject'));
        rlTask.columns.add(new Column('ActivityDate'));
        rlTask.columns.add(new Column('Status'));
        Column cTaskSubtype = new Column('TaskSubtype');
        cTaskSubtype.UpdateableOnlyOnCreate=true;
        rlTask.columns.add(cTaskSubtype);
        if (mel.objectName!='Lead') rlTask.columns.add(new Column('WhoId'));
        rlTask.columns.add(new Column('OwnerId'));
        mel.relatedLists.add(rlTask);
        
        RList rlEvent = new RList();
        rlEvent.objectname='Event';rlEvent.label='Events';
        rlEvent.field=(mel.objectName!='Lead') ? 'WhatId' : 'WhoId';
        rlEvent.sortBy=new list<SortProperties>();
        rlEvent.sortBy.add(new SortProperties('ActivityDate',false));
        rlEvent.columns = new list<Column>();
        rlEvent.columns.add(new Column('Subject'));
        rlEvent.columns.add(new Column('StartDateTime'));
        rlEvent.columns.add(new Column('DurationInMinutes'));
        if (mel.objectName!='Lead') rlEvent.columns.add(new Column('WhoId'));
        rlEvent.columns.add(new Column('OwnerId'));
        mel.relatedLists.add(rlEvent); 
        
    }
 
    /**
     * @description When a lookup field is found in a related list, the metadata api replace it with a name field on the target object.
     * @param mel MassEditLayout
     * @return null
     */
    static void fixLookupFields(MassEditLayout mel) { 
        for (RList rl : mel.relatedLists){
            list<Column> columnsClean = new list<Column>(); 
            for (Column col : rl.columns){
                if (col.fieldApiName.endsWith('__r.Name') && col.lookupId!=null)
                 columnsClean.add(new Column(col.lookupId));    
                else if (col.fieldApiName=='User.Name' && (rl.objectname=='OpportunityTeamMember' || rl.objectname=='AccountTeamMember')){
                    Column colUserId = new Column('UserId');
                    colUserId.UpdateableOnlyOnCreate=true; 
                    columnsClean.add(colUserId);
                } 
                else if (col.fieldApiName=='Contact.Name')
                  columnsClean.add(new Column('ContactId'));
                else if (col.fieldApiName=='Account.Name')
                columnsClean.add(new Column('AccountId'));
                else if (col.fieldApiName=='Campaign.Name')
                columnsClean.add(new Column('CampaignId'));                
                else columnsClean.add(col); 
            }    
            rl.columns=columnsClean; 
        }
    }
    
    /**
     * @description When a lookup field is found in a related list, the metadata api replace it with a name field on the target object.
     * @param mel MassEditLayout
     * @return null
     */
    static void fixStandardObjects(MassEditLayout mel) { 
       
         for (RList rl : mel.relatedLists){
             rl.initialObjectName=rl.objectname;
             // Let's convert "account contact roles" into contacts. This will allow us to edit them. 
            if (rl.objectname=='AccountContactRelation' && mel.objectName=='Account') {
                rl.objectname='Contact';
                rl.extractedFrom='AccountContactRelation';rl.field='AccountId';
                list<Column> columnsClean = new list<Column>(); 
                for (Column col : rl.columns){
                if (col.fieldApiName.contains('Contact.')) columnsClean.add(col); 
                }    
                rl.columns=columnsClean;     
                String rlString = JSON.serialize(rl);
                rlString = rlString.replaceAll('Contact[.]', '');
                RList rlCleaned = (RList)JSON.deserialize(rlString, Rlist.class);
                rl.columns = rlCleaned.columns;
                rl.sortBy= rlCleaned.sortBy;
            
            }
            if (rl.objectname=='Opportunity' && mel.objectName=='Contact') {
                rl.extractedFrom='OpportunityContactRole';rl.field=null;  
            }
            
            if (rl.objectname=='OpportunityLineItem' && mel.objectName=='Opportunity') {
                rl.label='Opportunity Line Items';  
            }  
            
            //"Name" field on contact object is non updateable, let's convert it into firstname and lastname
            if (rl.objectname=='Contact'){
                list<Column> columnsClean = new list<Column>(); 
                for (Column col : rl.columns){
                    if (col.fieldApiName!='Name') {
                        columnsClean.add(col); 
                    } else {
                        Column colFirstName = new Column();
                        colFirstName.fieldapiname='FirstName';
                        columnsClean.add(colFirstName);
                        Column colLastName = new Column();
                        colLastName.fieldapiname='LastName';
                        columnsClean.add(colLastName);
                    }
                }
                rl.columns=columnsClean;  
            }
            if (rl.objectname.contains('ContactRole')){
               List<String> allowedCols = new list<String> {'Contact.Name', 'Role', 'IsPrimary', 'Contact.Title'}; 
               list<Column> columnsClean = new list<Column>(); 
               for (Column col : rl.columns){
                    if (allowedCols.contains(col.fieldApiName)) columnsClean.add(col);
                }
               rl.columns=columnsClean;  
            }
            if (rl.objectname=='CampaignInfluence'){ 
               list<Column> columnsClean = new list<Column>();
               for (Column col : rl.columns){
                   if (!col.fieldApiName.contains('OpportunityContactRole')) {columnsClean.add(col);}
                }
               rl.columns=columnsClean;  
            }      
           
         }
    }
    
    /**
     * @description This method is called when a user click save on a related list. Goal is to send back to client side all save results record per record. 
     * @param sObjectName of type String
     * @param toInsert of type List
     * @param toUpdate of type List
     * @param toDelete of type StListring
     * @return SaveTableResult
     */
    @AuraEnabled    
    public static SaveTableResult saveRecords (string sObjectName,list<SObject> toInsert,list<SObject> toUpdate,list<SObject> toDelete, List<AITM_Tender_Location_Taxes_and_Fees__c> taxListToInsert){
            
        SaveTableResult saveResult = new SaveTableResult();
        Set<Id> setOfLineItemIds = new Set<Id>();
        List<AITM_Tender_Location_Line_Item__c> lineitemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
     
        try {
        
                // UPDATE RECORDS 
                Database.SaveResult[] updateResult = Database.update(toUpdate,false);
                Integer i=0;    
                for (Database.SaveResult sr : updateResult) {
                  saveResult.updateResults.add(new DMLResult(toUpdate[i].Id,sr.isSuccess(),sr.getErrors()));
                  i++;  
                }
               
                // INSERT RECORDS    
                Database.SaveResult[] insertResult = Database.insert(taxListToInsert,false);
                for(AITM_Tender_Location_Taxes_and_Fees__c tax : taxListToInsert){
                    setOfLineItemIds.add(tax.Tender_Location_Line_Item_Id__c);
                }
                for(AITM_Tender_Location_Line_Item__c lineitem : [SELECT AITM_Is_Eligible_Line_for_All_Tax_Fee__c FROM AITM_Tender_Location_Line_Item__c WHERE ID IN :setOfLineItemIds]){
                    lineitem.AITM_Is_Eligible_Line_for_All_Tax_Fee__c = true;
                    lineitemsToUpdate.add(lineitem);
                }
                if(lineitemsToUpdate != null && lineitemsToUpdate.size() >0){
                    Database.update(lineitemsToUpdate,false);
                }
                /*i=0;    
                for (Database.SaveResult sr : insertResult) {
                  saveResult.insertResults.add(new DMLResult(toInsert[i].Id,sr.isSuccess(),sr.getErrors()));
                  i++;  
                }*/
                    
                // DELETE RECORDS
                Database.DeleteResult[] deleteResult = Database.delete(toDelete,false);
                i=0;    
                for (Database.DeleteResult sr : deleteResult) {
                  saveResult.deleteResults.add(new DMLResult(toDelete[i].Id,sr.isSuccess(),sr.getErrors()));
                  i++;  
                }   
             }
          catch (Exception e) {
            //"Convert" the exception into an AuraHandledException
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());    
        }
        return saveResult;
    }    
    
    /**
     * @description This method will insert custom tax record
     * @param taxList of type List
     * @return List
     */
    @AuraEnabled
    public static void saveTaxRecords(List<AITM_Tender_Location_Taxes_and_Fees__c> taxList){
        Insert taxList;
    }
 
    /**
     * @description This method gets mandatory fields
     * @param sObjectName of type String
     * @return List
     */
    public static list<String> getObjectMandatoryFields (String sObjectName) {
            List<String> reqFields = new List<String>();
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType targetObj = schemaMap.get(sObjectName);
            if (targetObj==null) return reqFields;
            Map <String, Schema.SObjectField> fieldMap = targetObj.getDescribe().fields.getMap();
            for(String fieldName : fieldMap.keySet())
            { 
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult F = field.getDescribe();
               //A nillable field can have a null value, hence it is not mandatory.
                if( F.isCreateable() && !F.isNillable() && !F.isDefaultedOnCreate() && F.isUpdateable()) {
                    reqFields.add(F.getName()); //getName() recovers the APEX field name (=with correct letter uppercase)
                }
              
           }
        if (!reqFields.contains('Name') && fieldMap.get('name')!=null && !fieldMap.get('name').getDescribe().isAutoNumber() && fieldMap.get('name').getDescribe().isUpdateable()) {
            reqFields.add('Name'); 
        }
        return reqFields;
    } 
    
    /**
     * @description gets records
     * @param recordId of type String
     * @param sObjectName of type String
     * @param rl of type String
     * @param queryLimit of type String
     * @return List
     */
    @AuraEnabled    
    public static list<sobject> getRecords (string recordId, string sObjectName, string rl, String queryLimit){
        //LET'S BUILD A DYNAMIC QUERY
        Rlist oRlist = (RList)JSON.deserialize(rl, Rlist.class);
      
        //FIELDS OF THE QUERY 
        string soqlFields='Tender_Location_Line_Item_Id__r.AITM_Record_Type_Name__c,';
        for (String s : oRlist.allFields) {
            soqlFields += s + ', ';
        }
        if (soqlFields.endsWith(', ')) {
            soqlFields= soqlFields.removeEnd(', ')+' ';
        }
      
        
        //ORDER BY OF THE QUERY
        string orderBy='';
        if (oRlist.sortBy!=null && oRlist.sortBy.size() > 0) {
           if (oRlist.objectname =='Task' && oRlist.sortBy[0].column=='ActivityDate') oRlist.sortBy[0].ascending = false; // force tasks to be ordered descending as in lightning 
           orderBy=' ORDER BY '+oRlist.sortBy[0].column+' '+(oRlist.sortBy[0].ascending?'ASC':'DESC');
           if (oRlist.sortBy.size()==2) 
           orderBy+=', '+oRlist.sortBy[1].column+' '+(oRlist.sortBy[1].ascending?'ASC':'DESC');
        }
        
        //WHERE PART OF THE QUERY
        string wherePart='';
        wherePart=' where '+oRlist.field+' = \'' + recordId + '\' ';
        
        // craft the 'where' clause for task and events
        if (oRlist.objectname=='Event' || oRlist.objectname=='Task') {
            wherePart+=' OR AccountId = \'' + recordId + '\' ';
            if (oRlist.parentObjectName=='Account' || oRlist.parentObjectName=='Contact'){
               MAP<ID,Contact> mapContact = new MAP<Id,Contact>([Select ID from Contact where AccountId = :recordId OR Id = :recordId]);
               SET<ID> setContactIDs = mapContact.keyset();
                if (oRlist.objectname=='Task') {
                    if (Schema.getGlobalDescribe().get('TaskRelation')!=null){
                        String mapQuery='select id, TaskId from TaskRelation where RelationId in :SetContactIDs';
                        //we use a dynamic query when querying TaskRelation, otherwise, the package will require 'shared activities' as an org feature
                        MAP<ID,sObject> mapTR = new MAP<Id,sObject> (database.query(mapQuery));
                        SET<ID> setTaskIDs = new Set<ID>();
                        for (ID tr_ID : mapTR.keyset()) {
                          setTaskIDs.add((ID)mapTR.get(tr_ID).get('TaskId'));  
                        }
                        wherePart+=' OR Id in :setTaskIDs '; 
                    } else 
                        wherePart+=' OR WhoId in :setContactIDs ';     
                }
                if (oRlist.objectname=='Event') {
                    if (Schema.getGlobalDescribe().get('TaskRelation')!=null){
                        String mapQuery='select id, EventId from EventRelation where RelationId in :setContactIDs';
                        //we use a dynamic query when querying EventRelation, otherwise, the package will require 'shared activities' as an org feature
                        MAP<ID,sObject> mapER = new MAP<Id,sObject> (database.query(mapQuery));
                        SET<ID> setEventIDs = new Set<ID>();
                        for (ID er_ID : mapER.keyset()) {
                          setEventIDs.add((ID)mapER.get(er_ID).get('EventId'));  
                        }
                        wherePart+=' OR Id in :setEventIDs ';
                    } else 
                        wherePart+=' OR WhoId in :setContactIDs ';      
                }
            }
        }
        if (oRlist.objectname=='CampaignInfluence')
              wherePart+=' AND Model.IsDefaultModel = true ';

        // CRAFT THE WHERE CLAUSE FOR ALL THE RLEATED LISTS THAT WERE EXTRACTED FROM OTHER LISTS
        if (oRlist.objectname=='Product2' && oRlist.parentObjectName=='Opportunity') {
            String mapQuery='select id, Product2Id from OpportunityLineItem where OpportunityId = \''+recordId+'\'';
            MAP<ID,sObject> mapOLI = new MAP<ID,sObject> (database.query(mapQuery));
            SET<ID> setProductIDs = new Set<ID>();
            for (ID oli_ID : mapOLI.keyset()) {
               setProductIDs.add((ID)mapOLI.get(oli_ID).get('Product2Id')); 
            }    
            wherePart=' WHERE Id IN :SETProductIDs ';    
        } 
        else if ((oRlist.extractedFrom!=null && oRlist.field==null)
                || oRlist.extractedFrom=='AccountContactRelation' ) {
            String mapQuery='SELECT ID, '+oRlist.objectname+'Id FROM '+oRlist.extractedFrom+' WHERE '+oRlist.parentObjectName+'Id = \''+recordId+'\'';
            if (oRlist.extractedFrom=='CampaignInfluence') mapQuery+=' and Model.IsDefaultModel = true';
            MAP<ID,sObject> mapSourceObject = new MAP<ID,sObject> (database.query(mapQuery));
            SET<ID> setTargetObject = new Set<ID>();
            for (ID sr_ID : mapSourceObject.keyset()) {
                 setTargetObject.add((ID)mapSourceObject.get(sr_ID).get(oRlist.objectname+'Id'));
            }
            wherePart=' where Id IN :setTargetObject ';
        }        
       
       //CONCATENATE THE QUERY 
       string soql = 'SELECT '+soqlFields+' FROM ' + oRlist.objectname + wherePart +orderBy;
       soql += ' LIMIT '+queryLimit; 
       list<sobject> records = Database.query(soql);
        
       return records;
        
    }

    /**
     * @description This method is called when a user click save on a related list. Goal is to send back to client side all save results record per record. 
     * @param mel of type MassEditLayout
     * @return null
     */
    public static void getRLMetaData (MassEditLayout mel) {
      for (RList rl : mel.relatedLists){
      if (rl.objectname=='User'){
        rl.isRowCreateable = false;
        rl.isRowDeleteable = false;  
      } 
      else if (rl.objectname=='CampaignInfluence'){
        rl.isRowCreateable = false;
        rl.isRowDeleteable = true;     
      }    
      else {
        rl.isRowCreateable = true;
        rl.isRowDeleteable = true;    
      }      
      }    
    }    
    
    /**
     * @description gets fields meta data
     * @param mel of type MassEditLayout
     * @return null
     */
    public static void getFieldsMetaData (MassEditLayout mel) {
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        for (RList rl : mel.relatedLists){
            Schema.SObjectType targetObj = schemaMap.get(rl.objectname);
            if (targetObj==null) continue;
            Map <String, Schema.SObjectField> fieldMap = targetObj.getDescribe().fields.getMap();
            //let's get full metadata for layout fields. 
            for (Column col : rl.columns){
                col.isVisible=true; 
                Schema.SObjectField field = fieldMap.get(col.fieldApiName);
                if (field != null) {
                    col.fieldType = field.getDescribe().getType().name();
                    col.isCalculated = field.getDescribe().isCalculated();
                    col.isUpdateable = field.getDescribe().isUpdateable();
                    if (col.isCalculated){
                        col.fieldType = 'CALCULATED';
                    }
                    col.htmlInputType = new HtmlInputType(col.fieldType);
                    
                     if (col.fieldType=='PICKLIST') {
                       PicklistOption[] options = new list<PicklistOption>();  
                       Schema.PicklistEntry[] picklistValues = field.getDescribe().getPicklistValues();
                        for (Schema.PicklistEntry entry : picklistValues){
                            PicklistOption newOption = new PicklistOption(entry.getValue(),entry.getLabel());
                            options.add(newOption);
                        }
                      col.picklistOptions=options;  
                     }
                   if (col.fieldType=='REFERENCE') {
                      Relationship relationship = new Relationship(field.getDescribe().getRelationshipName()); 
                      for(Schema.SObjectType reference : field.getDescribe().getReferenceTo()) {
                        relationship.objects.add(reference.getDescribe().getName());
                      }
                      col.relationship=relationship; 
                   } 
                   
                } else {
                    col.isUpdateable = false;
                }
            }
          
         //let's get basic metadata for all fields.
         Column[] allFieldsWithFieldType = new list<Column>();
         for (string s : rl.allFields){    
            Column c = new Column();
            c.fieldApiName=s;
            Schema.SObjectField field = fieldMap.get(s);
            if (field != null) {
                c.fieldType = field.getDescribe().getType().name();
                c.htmlInputType = new HtmlInputType(c.fieldType);
            }
           allFieldsWithFieldType.add(c);    
         }
        rl.allFieldsWithFieldType=allFieldsWithFieldType;    
        }
        

        return;
    }

/**
 * @description gets extra fields meta data
 * @param mel of type MassEditLayout
 * @return null
 */ 
public static void getExtraFields (MassEditLayout mel) {
    for (RList rl : mel.relatedLists){
        List<String> extraFields = new List<String>();
        List<String> allFields = new List<String>();
        List<String> layoutFields = new List<String>();  
        for (Column col : rl.columns){
            layoutFields.add(col.fieldApiName);
            allFields.add(col.fieldApiName);
        }
        List<String> reqFields = getObjectMandatoryFields(rl.objectname);
        for (String s : reqFields){
            if (!layoutFields.contains(s)) {extraFields.add(s);allFields.add(s);}
        }
        if (!layoutFields.contains('Id') && !extraFields.contains('Id')) 
            {extraFields.add('Id');allFields.add('Id');}
        if (!layoutFields.contains(rl.field) && !extraFields.contains(rl.field)) 
            {extraFields.add(rl.field);allFields.add(rl.field);}
        rl.layoutFields=layoutFields;
        rl.extraFields=extraFields;
        rl.allFields=allFields;
    }
    return;
}

/**
 * @description gets extra fields meta data
 * @param null
 * @return null
 */     
@AuraEnabled    
public static void cleanChatterPosts () {
    Feeditem[] posts = [select id,type,body from FeedItem where type='CreateRecordEvent' or type='SocialPost'];
    delete posts;    
}   

/**
 * @description gets record object name
 * @param recordId of type String
 * @return Rec
 */     
@AuraEnabled
public static Rec getRecObjectAndName (string recordId) {
        if(recordId==null || (recordId.length() != 15 && recordId.length() != 18)) return new Rec(null,null);
        String objectName=((ID)recordId).getSObjectType().getDescribe().getName();
        String query = 'SELECT Name FROM '+objectName+' WHERE Id=\''+recordId+'\''; 
        String recName=null;
       try {
           list<sobject> records = Database.query(query);
           recName = (String)records[0].get('Name');
        }
       catch (Exception e) {
         recName=null;   
        } 
       
        return new Rec(objectName,recName);
}    
    
       
 public with sharing class RList {
     @AuraEnabled 
     public String field;
     @AuraEnabled 
     public String name;
     @AuraEnabled 
     public String label;
     @AuraEnabled 
     public String objectname;
     @AuraEnabled 
     public String extractedFrom;
     @AuraEnabled
     public String initialObjectname;
     @AuraEnabled 
     public list<Column> columns;
     @AuraEnabled 
     public list<SortProperties> sortBy; 
     @AuraEnabled 
     public list<String> layoutFields;
     @AuraEnabled 
     public list<String> extraFields;
     @AuraEnabled 
     public list<String> allFields;
     @AuraEnabled 
     public list<Column> allFieldsWithFieldType;
     @AuraEnabled 
     public String objectId;
     @AuraEnabled 
     public String parentRecordLayoutId;
     @AuraEnabled 
     public String parentObjectId;
     @AuraEnabled 
     public String parentObjectName;
     @AuraEnabled 
     public Boolean isRowCreateable;
     @AuraEnabled 
     public Boolean isRowDeleteable;
} 

public with sharing class SortProperties {
  @AuraEnabled
  public Boolean ascending;
  @AuraEnabled  
  public String column;
  SortProperties(){}
  public SortProperties(string fieldName, Boolean isAscending){
    this.column=fieldName;
    this.ascending=isAscending;  
  } 
}    
    
public with sharing class Column {
    @AuraEnabled 
    public String field;
    @AuraEnabled 
    public String fieldApiName;
    @AuraEnabled 
    public String format;
    @AuraEnabled 
    public String label;
    @AuraEnabled 
    public String lookupId;
    @AuraEnabled 
    public String name;
    @AuraEnabled 
    public Boolean sortable;
    @AuraEnabled 
    public String fieldType;
    @AuraEnabled
    public Boolean isCalculated;
    @AuraEnabled
    public Boolean isUpdateable;
    @AuraEnabled
    public Boolean isVisible;
    @AuraEnabled
    public Boolean UpdateableOnlyOnCreate;
    @AuraEnabled 
    public HtmlInputType htmlInputType;
    @AuraEnabled 
    public list<PicklistOption> picklistOptions;
    @AuraEnabled 
    public Relationship relationship;
    public Column(){
        this.UpdateableOnlyOnCreate=false;
        this.isVisible=true;
    }
    public Column(String fieldApiName){
     this.fieldApiName=fieldApiName;
     this.UpdateableOnlyOnCreate=false;
     this.isVisible=true;
    }
}
    
public with sharing class Relationship{
   @AuraEnabled 
   public String relationshipName; 
   @AuraEnabled
   public list<String> objects;
   Relationship (String relationshipName){
    this.relationshipName=relationshipName;   
    this.objects = new list<String>();     
   } 
}    
    
public with sharing class PicklistOption{
    @AuraEnabled 
    public String value; 
    @AuraEnabled 
    public String label;
    public PicklistOption(String value, String label){
        this.value=value; this.label=label;
    }
 }
    
public with sharing class SaveTableResult{
@AuraEnabled     
public DMLResult[] insertResults;
@AuraEnabled 
public DMLResult[] updateResults;
@AuraEnabled 
public DMLResult[] deleteResults;
SaveTableResult(){
    this.insertResults = new list<DMLResult>();
    this.updateResults = new list<DMLResult>();
    this.deleteResults = new list<DMLResult>();    
 }    
}    
    

public with sharing class DMLResult {
    @AuraEnabled 
    public String id;
    @AuraEnabled     
    public Boolean isSuccess;
    @AuraEnabled     
    public String error;
    public DMLResult(String id, Boolean isSuccess,Database.Error[] Errors){
        this.id=id; this.isSuccess=isSuccess;
        this.error='';
        for(Database.Error err : Errors) {               
            this.error+=err.getStatusCode() + ': ' + err.getMessage()+'<br/>';
            this.error+='Fields that affected this error: ' + err.getFields()+'<br/>';
        }
    }
}    

public with sharing class MassEditLayout {
    @AuraEnabled 
    public String objectName;
    @AuraEnabled 
    public String objectId;
    @AuraEnabled 
    public String layoutId;
    @AuraEnabled 
    public list<RList> relatedLists; 
    MassEditLayout () {
        relatedLists = new list<RList>();
    }
    MassEditLayout (String objectName) {
        relatedLists = new list<RList>();
        this.objectName = objectName;
    }
}
    
public with sharing class Rec {
  @AuraEnabled
  public String sObjectName;
  @AuraEnabled
  public String recordName;
  public Rec(String sObjectName, String recordName){
   this.sObjectName=sObjectName;
   this.recordName=recordName;   
  }
} 
         

public with sharing class HtmlInputType {
       @AuraEnabled 
       public String mainType; 
       @AuraEnabled 
       public String subType;
       public HtmlInputType(String fieldType){
           this.mainType='invalid';
           this.subType='invalid';    
           if (fieldType=='TEXTAREA' || fieldType=='STRING' || fieldType=='ID' || fieldType=='COMBOBOX' ) {
                this.mainType='standard';
                this.subType='text';    
           } 
           if (fieldType=='CURRENCY' || fieldType=='DOUBLE' || fieldType=='INTEGER' || fieldType=='PERCENT' ) {
                this.mainType='standard';
                this.subType='number';    
           } 
           if (fieldType=='DATE' || fieldType=='DATETIME') {
                this.mainType='standard';
                this.subType='date';    
           } 
           if (fieldType=='DATETIME') {
                this.mainType='standard';
                this.subType='datetime-local';    
           }            
           if (fieldType=='BOOLEAN') {
                this.mainType='checkbox';
                this.subType='';    
           }
           if (fieldType=='CALCULATED') {
                this.mainType='calculated';
                this.subType='';    
           } 
           if (fieldType=='PICKLIST' ||  fieldType=='MULTIPICKLIST') {
                //this.mainType='standard'; //this is a hack until a v2 of the component with picklist management
                this.mainType='picklist';
                this.subType='';    
           }
           if (fieldType=='EMAIL') {
                this.mainType='standard';
                this.subType='email';    
           }
           if (fieldType=='PHONE') {
                this.mainType='standard';
                this.subType='tel';    
           }
           if (fieldType=='URL') {
                this.mainType='standard';
                this.subType='url';    
           }
           if (fieldType=='REFERENCE') {
                this.mainType='lookup';
                this.subType='';    
           } 
        }
    }
    
     public static String getSessionIdFromVFPage() {
        if(Test.isRunningTest()) {
            return 'SESSION_ID';
        } else {
            String SESSION_ID_START = 'SESSION_ID_START';
            String SESSION_ID_END = 'SESSION_ID_END';
            String pageContent = Page.AITM_Session_Id.getContent().toString();
            Integer startIndex = pageContent.indexOf(SESSION_ID_START) + SESSION_ID_START.length();
            Integer endIndex = pageContent.indexOf(SESSION_ID_END);
            return pageContent.substring(startIndex, endIndex);
        }
    }   
}