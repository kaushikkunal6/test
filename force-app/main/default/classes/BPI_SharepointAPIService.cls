/*****************************************************************************************
*       Date:        31OCT2019
*       Author:      Stuart Pullen - IBM
*       Description: BPI Service class to wrap the Mulesoft Sharepoint integration
*       Currently this class is just used by the DUP project but in future may be extended to include extra functionality. Please consider existing usage of this class before modifying
*       The API this service class calls will currenlty map to one sharepoint instance (configured at the API level). 
*       The API expects 2 parameters in additon to a binary image of the file
*       The baseFolderList is a comma separated list of folders to search within, directly from the root of the sharepoint instance
*       The subFolder is a single folder which may be contained within one of the base folders. The API will recursviely search each base folder until it finds the sub folder
*       If the subFolder is found the file will be placed in that folder and a response with the path to the file will be returned
*       If the subfolder is not found an error response will be returned
*****************************************************************************************/
public with sharing class BPI_SharepointAPIService {

    private static final String SHAREPOINT_BODYNAME = 'FileForUpload';

    private String baseFolderList;
    private String subFolder;  
    private String sharepointVersion;
    private String bearerToken;
	private static String boundary = '----------------------------153501500631101';
    private static BPI_SharepointAPIService instance;

    //private constructor
    private BPI_SharepointAPIService(){}

    //wrapper for the response
    public class ResponseWrapper {
        public Id contentVersionId;
        public HttpResponse response;
    }    
    
  
    
    //Init method to specify a list of base folders and a sub folder to search for in sharepoint
    //If the Mulesoft API locates a matching folder the file will be written to that folder
    public static BPI_SharepointAPIService init(String baseFolderListValue, String subFolderValue) {
        instance = new BPI_SharepointAPIService();
        instance.baseFolderList = baseFolderListValue; //baseFolderList;
        instance.subFolder = subFolderValue; //subFolder;
        instance.bearerToken = getBearerToken();
        instance.sharepointVersion = '2013';
        return instance;
    }
    
    //Init method to specify a list of base folders and a sub folder to search for in sharepoint
    //If the Mulesoft API locates a matching folder the file will be written to that folder
    public static BPI_SharepointAPIService init(String baseFolderListValue, String subFolderValue, string sharepointVersion) {
        instance = init(baseFolderListValue, subFolderValue) ;
        instance.sharepointVersion = sharepointVersion;
        return instance;
    }
    

    /**
	* @description:	accepts a list of Record Ids that are linked to files. The method will extract the binary for each record
    *   from the latest ContentVersion via the ContentDocumentLink and send this to sharepoint, and place them using the folders 
    *   specified in the contructor
	* @param: Set<Id> linkedEntityIdList
	* @return: Map<id,List<ResponseWrapper>> - returns the response from sharepoint for each record we push the files from
	*/    
    public Map<Id,List<ResponseWrapper>> pushFilesToSharepoint(Set<Id> linkedEntityIdList){         

        //Use the linked entityid to find the files we want to send to sharepoint
        List<ContentDocumentLink> contentDocumentLinkList = [
            SELECT ContentDocument.LatestPublishedVersion.VersionData,
                ContentDocument.LatestPublishedVersion.Title,
                LinkedEntityId,
            	ContentDocument.LatestPublishedVersion.FileExtension,
            	ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :linkedEntityIdList
                AND ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Approved'
        ];

        return pushSingleFileToSharepoint(contentDocumentLinkList);
    }

    /**
	* @description:	accepts a list of ContentDocumentLink  that are linked to files. The method will extract the binary for
    *    each record from the latest ContentVersion via the ContentDocumentLink and send this to sharepoint, and place them
    *    using the folders specified in the contructor
	* @param: Set<Id> linkedEntityIdList
	* @return: Map<id,List<ResponseWrapper>> - returns the response from sharepoint for each record we push the files from
	*/    
    public Map<Id,List<ResponseWrapper>> pushSingleFileToSharepoint(List<ContentDocumentLink> contentDocumentLinkList){   
        Map<Id,List<ResponseWrapper>> apiResponses = new Map<Id,List<ResponseWrapper>>();
        
        for(ContentDocumentLink cdl : contentDocumentLinkList){
            
            HttpResponse res = pushFileToSharepoint(cdl.ContentDocument.LatestPublishedVersion.VersionData, 
                    SHAREPOINT_BODYNAME,
                    cdl.ContentDocument.LatestPublishedVersion.Title + '.' +cdl.ContentDocument.LatestPublishedVersion.FileExtension, 
                    instance.baseFolderList, 
                    instance.subFolder,
                    instance.bearerToken) ;
            System.Debug(res.getBody());
            
            List<ResponseWrapper> httpResponseWrapperList = apiResponses.get(cdl.LinkedEntityId);
            if(httpResponseWrapperList == null){
                httpResponseWrapperList = new List<ResponseWrapper>();
            }
            ResponseWrapper rw = new ResponseWrapper();
            rw.contentVersionId = cdl.ContentDocument.LatestPublishedVersionId;
            rw.response = res;
            httpResponseWrapperList.add(rw);

            apiResponses.put(cdl.LinkedEntityId, httpResponseWrapperList);
        }
        
        return apiResponses;
    }

     /**
	* @description:	accepts a list of ContentDocuemntIds  The method will extract the binary for each record from the latest ContentVersion and send this to sharepoint, and place them using the folders specified in the contructor
	* @param: List<Id> contentDocumentIdList
	* @return: Map<id,HttpResponse> - returns the response from sharepoint for each content Document we push the files from
	*/   
    /*
    public Map<id,HttpResponse> pushFilesToSharepoint(List<Id> contentDocumentIdList){
        
        Map<id,HttpResponse> apiResponses = new Map<id,HttpResponse> () ;

        //Use the linked entityid to find the files we want to send to sharepoint
        List<ContentDocument> contentDocumentList = [
            SELECT LatestPublishedVersion.VersionData,
                LatestPublishedVersion.Title,
            	Id
            FROM ContentDocument
            WHERE Id = :contentDocumentIdList
        ];
        
        for(ContentDocument cd : contentDocumentList){
            
            HttpResponse res = pushFileToSharepoint(cd.LatestPublishedVersion.VersionData, 
                    SHAREPOINT_BODYNAME,
                    cd.LatestPublishedVersion.Title, 
                    this.baseFolderList, 
                    this.subFolder) ;
            System.Debug(res.getBody());
            apiResponses.put( cd.Id ,res );
        }
        
        return apiResponses;
    }
    */
    /**
	* @description: Call the API using the blob 
	* @params:  Blob file_body - the file,
                String bodyName - the name of the body to send in the request, 
                String file_name - the name of the file to store in sharepoint, 
                String baseFolder - base folders to search within, 
                String subFolder - sub folder to find in the base folder
	* @return: HttpResponse - returns the repsonse from sharepoint for the call
	*/
    private static HttpResponse pushFileToSharepoint(Blob file_body, String bodyName, String file_name, String baseFolder, String subFolder, string bearerToken){
       
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','multipart/form-data; boundary='+ boundary);
        req.setHeader('BaseFolderName', baseFolder);
        req.setHeader('CounterpartyId', subFolder);
        req.setHeader('Authorization', 'Bearer ' + bearerToken);
        req.setMethod('POST');
        req.setEndpoint('callout:BPI_Sharepoint');
        req.setBodyAsBlob(buildBodyBlob(file_body, file_name, bodyName));
        req.setTimeout(60000);

        Http http = new Http();
        return http.send(req);
    }

    // code to build up the binary correctly for the api
    @TestVisible private static Blob buildBodyBlob (Blob file_body, string file_name, string bodyName) {
        
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="'+bodyName+'"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
        // GW: Do not prepend footer with \r\n, you'll see why in a moment
        // String footer = '\r\n--'+boundary+'--'; 
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('=')){
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);

        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        System.debug('Inside last 4 bytes: ' + last4Bytes);
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            // We have appended the \r\n to the Blob, so leave footer as it is.
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
            // Prepend the CR LF to the footer
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }

        return bodyBlob;

    }

     private static string getBearerToken() {
        String newBearerToken = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        try{
            request.setEndpoint('callout:BPI_Sharepoint_Azure');
            request.setMethod('POST');
            request.setHeader('Content-Type','application/x-www-form-urlencoded');
            request.setBody('{!$Credential.Password}');
            response = http.send(request);
        } catch(Exception e){
            return newBearerToken;
        }
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        newBearerToken = results.get('access_token').toString();
        return newBearerToken ;
    }

}