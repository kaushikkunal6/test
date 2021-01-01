global with sharing class AttachmentController {

    public AttachmentController( Object o ) { } 
    
    @RemoteAction
    global static Boolean uploadAttachment(String strBase64,String contentType,String name,String parentId) {
        Attachment attachment = new Attachment();
        attachment.ContentType=contentType;
        attachment.ParentId = parentId;
        attachment.Name = name;
        attachment.Body = EncodingUtil.base64Decode(strBase64);
        try {
            insert attachment;
        } catch (Exception e) {
            //place here the code to log in table
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'AttachmentController', 'uploadAttachment', (List<Id>)null, 'GCM_Application_Administrator'); 
            return false;
        } 
        return true;
    }

    @RemoteAction
    global static Boolean traceAction(String interactionId,String parentId,String fileName,String message) {
        System.debug('called traceAction, interactionId : [' + interactionId + '] parentId : [' + parentId + +' fileName : [' + fileName + '] message : [' + message + ']');
        String msg = 'interactionId : [' + interactionId + '] parentId : [' + parentId + +' fileName : [' + fileName + '] message : [' + message + ']';
        //place here the code to log in table
        BPG_Error_Logger errorLogger = new BPG_Error_Logger(new AttachmentException(msg), 'Class', 'AttachmentController', 'traceAction', (List<Id>)null, 'GCM_Application_Administrator'); 
        return true;
    }
    
    //Custom Exception class
    public class AttachmentException extends Exception {}

}