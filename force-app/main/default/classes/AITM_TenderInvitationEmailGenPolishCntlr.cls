public with sharing class AITM_TenderInvitationEmailGenPolishCntlr {
    public static @AuraEnabled AITM_EmailGeneratorController.EmailDTO generate(Id tenderId, String locationType) {
        AITM_InvitationEmailGenerator.Generator emailCreator = new AITM_InvitationEmailGenerator.Generator(tenderId, locationType);
        emailCreator.locationType = locationType;
        return emailCreator.generate();
    }

    public static @AuraEnabled List<String> postToChatter(Id tenderId, String locationType) {
        AITM_InvitationEmailGenerator.Generator emailCreator = new AITM_InvitationEmailGenerator.Generator(tenderId, locationType);
        emailCreator.locationType = locationType;
        return emailCreator.postToChatter();
    }

    private @testVisible class EmailDTOTenderId {
        public Id tenderId;
        public AITM_EmailGeneratorController.EmailDTO emailDTO;
    }
}