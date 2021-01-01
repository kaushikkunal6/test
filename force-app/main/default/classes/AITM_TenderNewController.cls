/*
*Created By : Neeti Thapliyal Bourai
*Create Date": 06/11/2020
* Class is created as a resuable componnent for tender new page.
*
*/

public class AITM_TenderNewController {

    @AuraEnabled
    public static Date getEndDate(Date startDate) {
        
        Date EndDate =(startDate.addYears(1))-1;
        return EndDate;
    }

   @AuraEnabled
   public static user fetchUser(){
       
     // query current user information  
      User oUser = new User();
      oUser=[select id,Name,IsActive,IsPortalEnabled,Profile.Name  FROM User Where id =: userInfo.getUserId() ];
       if(oUser.Profile.Name.Contains('%labp%')){
           return oUser;
       }
       else
           return null;
       
}
}