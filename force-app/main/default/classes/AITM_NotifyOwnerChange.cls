/***********************************************************************************************
 * @author           Chetna
 * @date             26/November/2020
 * @group            AirBP
 * @description      Send Email with the details from Process Builder

 * history
 ************************************************************************************************/
public with sharing class AITM_NotifyOwnerChange {
    /**
     * @description get details from process builder
     */
    public class EmailRequest{
        @InvocableVariable(/*label='Account Name',*/ required=true)
        public String accountName;
        @InvocableVariable(/*label='Account GRN',*/ required=true)
        public String accountGRN;
        @InvocableVariable(/*label='Account Owner Name',*/ required=true)
        public String accountOwner;
        @InvocableVariable(/*label='Account Owner Email',*/ required=true)
        public String accountOwnerEmail;
    }
    
    /**
     * @description to send email to MDM team and cc new account owner of the changes
     * @param  List<EmailRequest>
     * @return null
     */
    @InvocableMethod(label='Send Email to MDM Team' description='US 717669: Send email notification to MDM Team and cc account owner.')
    public static void sendEmailFromProcessBuilder(List<EmailRequest> emailRequests) {
        List<Messaging.SendEmailResult> sendResults = new List<Messaging.SendEmailResult>();
        Messaging.SingleEmailMessage mailToSend = new Messaging.SingleEmailMessage();
        for(EmailRequest er : emailRequests){
            mailToSend.setToAddresses(new List<String>{System.Label.AITM_OwnerChangeEmailID});
            mailToSend.setCcAddresses(new List<String>{er.accountOwnerEmail});
            mailToSend.setSubject(er.accountName + ' ' + System.Label.AITM_OwnerChangeSubject);
            mailToSend.setHtmlBody(System.Label.AITM_BeforeAccountName + ' ' + er.accountName + ' ' 
                                   + System.Label.AITM_BetweenAccountNameAndGRN + ' ' + er.accountGRN + ' ' 
                                   + System.Label.AITM_BetweenGRNandOwner + ' ' + er.accountOwner + ' ' 
                                   + System.Label.AITM_AfterAccountOwner + UserInfo.getName());
        }
        try{
            sendResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mailToSend});
        } catch(Exception ex){
            System.debug('Mail not sent: ' + sendResults);
        }
   }
}