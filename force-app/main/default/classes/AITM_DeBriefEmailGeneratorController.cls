/*************************************************************************
* @author         George
* @date           01/December/2017
* @group          AirBP
* @description    controller class when Generate Offer button was clicked. It attaches Tender Offer GT&C 
*                 and MSDS PDF files(email attachments).

* history
* 01/December/2017  George       Created
* 23/April/2018     srnandan     added with sharing to outer class as per coding standard and also code comments
* 12/August/2018    srnandan     Modified AR-3316 - modified method generate and notifyAirports 
*                                adding extra param locationType
* 20/Februrary/2019  Shweta      Modified AR-5010  Modified method notifyAirports to return the non null values
* 16/September/2019  srnandan    WK-701437 added new method updateDebriefEmailSent to track debrief email sent update on tender
*************************************************************************/
public with sharing class AITM_DeBriefEmailGeneratorController {
    
    /**
     * @description generates email DTO
     * @param  tenderId of type Id
     * @param  locationType of type String
     * @return AITM_EmailGeneratorController.EmailDTO
     */
    public static @AuraEnabled AITM_EmailGeneratorController.EmailDTO generate(Id tenderId, String locationType) {
        AITM_DeBriefEmailGenerator.Generator emailCreator = new AITM_DeBriefEmailGenerator.Generator(tenderId, locationType);
        return emailCreator.generate();
    }

    /**
     * @description notify airports with emails
     * @param  tenderId of type Id
     * @param  locationType of type String
     * @return void
     */
    public static @AuraEnabled void notifyAirports(Id tenderId, String locationType) {
        AITM_DeBriefEmailGenerator.AirportEmailGenerator emailCreator = new AITM_DeBriefEmailGenerator.AirportEmailGenerator(tenderId,locationType);
        List<AITM_EmailGeneratorController.EmailDTO> generatedEmails = emailCreator.getAirportEmails();
        if(generatedEmails !=null){
            new AITM_EmailGeneratorController().sendEmail(generatedEmails);
        }
    }

    /**
     * @description update debrief email sent
     * @param  tenderId of type Id
     * @return void
     */
    public static @AuraEnabled void updateDebriefEmailSent(Id tenderId) {
        new AITM_TenderDao().updateDebriefEmailSentDate(tenderId);
    }

    /**
     * @description attaches email
     * @param  emailDTOWithTenderId of type string
     * @return void
     */
    public static @AuraEnabled void attachEmail(String emailDTOWithTenderId, String locationType) {
        EmailDTOTenderId dataObject = (EmailDTOTenderId) JSON.deserialize(emailDTOWithTenderId, EmailDTOTenderId.class);
        AITM_DeBriefEmailGenerator.AttachmentGenerator emailAsAttachmentGenerator = 
		    new AITM_DeBriefEmailGenerator.AttachmentGenerator(dataObject.tenderId, dataObject.emailDTO, locationType);
        emailAsAttachmentGenerator.attach();
    }

    /**
     * @description wrapper class EmailDTOTenderId
     */
    private @testVisible class EmailDTOTenderId {
        public Id tenderId;
        public AITM_EmailGeneratorController.EmailDTO emailDTO;
    }
    
    public static @AuraEnabled Boolean getTenderData(String tenderId) {
        AITM_Tender__c tender = new AITM_TenderDao().getTender(tenderId);
        if(tender.AITM_Select_to_Apply_Old_Taxes_and_Fees__c) {
            return true;
        }else {
            return false;
        }
    }
    
    /**
     * @description Get refresh and new taxes and fees record from master data
     * @param  tenderId of type Id
     * @param  locationType of type string
     * @return void
     */
    @AuraEnabled
    public static void upsertNewTaxAndFee(Id tenderId, String locationType) {
        Map<Id, Boolean> mapOfLineItemWithBooleanProductDefault = new Map<Id, Boolean>();
        Map<String, Boolean> mapOfUpdatedFeeWithSelectToApplyBoolean = new Map<String, Boolean>();
        List<AITM_Tender_Location_Line_Item__c> listOfLineItems = new List<AITM_Tender_Location_Line_Item__c>();
        List<AITM_Tender_Location_Taxes_and_Fees__c> listOfExistingTaxesFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
        
        if (locationType != null && tenderId != null) {
            listOfLineItems = [SELECT AITM_Delivery_Method__c,AITM_Location_Delivery_Point__c,AITM_Product_Default__c, AITM_Tender_Id__c,AITM_Tender__c,AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Account__c,AITM_Account__r.AITM_Account_Classification__c,recordType.Name 
                               FROM AITM_Tender_Location_Line_Item__c 
                               WHERE AITM_Is_Current_Round__c = true 
                               AND RecordTypeId = :AITM_LocationsDao.TLLI_ID_RECORD_TYPE_DEBRIEF
                               AND AITM_Tender__c = :tenderId AND AITM_Tender_Location__r.AITM_Locations_Filter__c = :locationType];
            for(AITM_Tender_Location_Line_Item__c lineitem : listOfLineItems) {
                mapOfLineItemWithBooleanProductDefault.put(lineItem.Id, false);
            }
            for(AITM_Tender_Location_Taxes_and_Fees__c fee : new AITM_LocationsDao().getTaxesAndFeesBySetOfItemIds(mapOfLineItemWithBooleanProductDefault.keySet())){
                if(!mapOfUpdatedFeeWithSelectToApplyBoolean.containsKey(fee.Name +'-' + fee.AITM_Fuel_type__c + '-' + fee.Tender_Location_Line_Item_Id__c)) {
                    mapOfUpdatedFeeWithSelectToApplyBoolean.put(fee.Name +'-'+ fee.AITM_Fuel_type__c + '-' + fee.Tender_Location_Line_Item_Id__c, fee.AITM_Select_to_Apply_in_Contract__c);    
                }
                listOfExistingTaxesFees.add(fee);
            }
            if(!listOfExistingTaxesFees.isEmpty()){
                AITM_TenderApplyNewTaxesAndfees.deleteExistingTaxesAndFees(listOfExistingTaxesFees);
            }
            AITM_TenderApplyNewTaxesAndfees.attachTaxAndFeeRecordsOnLineItem(listOfLineItems, null);
        }
    }
}