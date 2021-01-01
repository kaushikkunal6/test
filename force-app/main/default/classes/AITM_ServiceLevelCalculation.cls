/***********************************************************************************************
 * @author           shweta
 * @date             20/December/2020
 * @group            AirBP
 * @description      This class is used to calculate the service level on tender location level

 * history
 * 20/December/2020 shweta      Created 
 ************************************************************************************************/


public class AITM_ServiceLevelCalculation { 
    public static Integer locationLevel ;    
    /**
    * @description updates the service level of the tender Location
    * @param tenderLocationLineItems of type List,tenderId of type Id,t of type AITM_Tender__c  
    * @return Null
    */    
    public static void calculationOfServiceLevels(List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems,Id tenderId,AITM_Tender__c t){
        Set<Id> tenderLocationsIds = new Set<Id>();                
          for(AITM_Tender_Location_Line_Item__c lineItem :tenderLocationLineItems){
            tenderLocationsIds.add(lineItem.AITM_Tender_Location__c);
          }
           Map<Id, AITM_Tender_Location__c> tenderLocations = new Map<Id, AITM_Tender_Location__c>([Select Id,AITM_Location_Default_Service_Level__c,AITM_Location__c,AITM_Customer_Service_Level__c,AITM_LocationDefaultValue__c,AITM_CustomerDefaultValue__c,AITM_Status__c,AITM_Service_Level__c
                                                                                                 FROM AITM_Tender_Location__c 
                                                                                                 WHERE Id IN : tenderLocationsIds 
                                                                                                 And AITM_Tender__c = :tenderId
                                                                                                 AND AITM_Is_Current_Round__c = true AND AITM_Status__c ='Awaiting price']);
       
        List<AITM_Tender_Location_Line_Item__c> lineItems = [Select Id,AITM_Tender_Location__c,AITM_Ad_hoc_Volume__c,AITM_Location_Delivery_Point__r.AITM_Service_Level_Provided__c,AITM_Account__c,AITM_Account__r.AITM_Preferred_Service_Level__c,AITM_Account__r.AITM_Aircraft_Fleet__c,AITM_Requested_Volume_USG__c from  AITM_Tender_Location_Line_Item__c where AITM_Tender_Location__c IN:tenderLocationsIds];
        Map<Id,List<AITM_Tender_Location_Line_Item__c>> mapOfTenderLocationWithLineItems = new Map<Id,List<AITM_Tender_Location_Line_Item__c>>();
                for(AITM_Tender_Location_Line_Item__c lineItem :lineItems){
                  if(mapOfTenderLocationWithLineItems.containsKey(lineItem.AITM_Tender_Location__c)){
                     List<AITM_Tender_Location_Line_Item__c> ls = mapOfTenderLocationWithLineItems.get(lineItem.AITM_Tender_Location__c);
                     ls.add(lineItem);
                  }else{
                     List<AITM_Tender_Location_Line_Item__c> ls = new List<AITM_Tender_Location_Line_Item__c>();
                     ls.add(lineItem);
                     mapOfTenderLocationWithLineItems.put(lineItem.AITM_Tender_Location__c,ls);
                  }
                }        
               locationLevelServiceCalculation(mapOfTenderLocationWithLineItems,tenderLocations,locationLevel);
               customerLevelServiceCalculation(mapOfTenderLocationWithLineItems,tenderLocations,t);
               update(tenderLocations.values());        
    } 
    
    /**
    * @description calculates the location default service level
    * @param locationAndPrefrredServiceMap of type Map,tenderLocations of type Map,locationLevel of type Integer
    * @return Null
    */  
    public static void locationLevelServiceCalculation(Map<Id,List<AITM_Tender_Location_Line_Item__c>> locationAndPrefrredServiceMap,Map<Id,AITM_Tender_Location__c> tenderLocations,Integer locationLevel){
          for(Id tenderLocationId :locationAndPrefrredServiceMap.keySet()){
              Set<String> locationDefaultServiceLevel  = new Set<String>();
              List<AITM_Tender_Location_Line_Item__c> lineItems =  locationAndPrefrredServiceMap.get(tenderLocationId);
                 for(AITM_Tender_Location_Line_Item__c t:lineItems){
                     if(t.AITM_Location_Delivery_Point__r.AITM_Service_Level_Provided__c!=null){
                       locationDefaultServiceLevel.add(t.AITM_Location_Delivery_Point__r.AITM_Service_Level_Provided__c);
                     }else{
                          locationDefaultServiceLevel.add('level-1');                     
                       }
                 }
                  AITM_Tender_Location__c locationToUpdate = tenderLocations.get(tenderLocationId);
                    if(locationDefaultServiceLevel.contains('level-1') && locationToUpdate!=null){
                       locationToUpdate.AITM_Location_Default_Service_Level__c = 'level-1';
                       locationToUpdate.AITM_LocationDefaultValue__c = 1;
                    }else{
                         if(locationDefaultServiceLevel.contains('level-1&2') && locationToUpdate!=null){
                            locationToUpdate.AITM_Location_Default_Service_Level__c = 'level-1&2';
                            locationToUpdate.AITM_LocationDefaultValue__c = 2;                     
                         } else{
                             if(locationDefaultServiceLevel.contains('level-1,2&3') && locationToUpdate!=null){
                                locationToUpdate.AITM_Location_Default_Service_Level__c = 'level-1,2&3';                          
                                locationToUpdate.AITM_LocationDefaultValue__c = 3;                      
                             }
                           }
                     }               
          } 
    }    
    /**
    * @description calculates the customer default service level
    * @param locationAndPrefrredServiceMap of type Map,tenderLocations of type Map,tender of type AITM_Tender__c
    * @return Null
    */        
    public static void customerLevelServiceCalculation(Map<Id,List<AITM_Tender_Location_Line_Item__c>> locationAndPrefrredServiceMap,Map<Id,AITM_Tender_Location__c> tenderLocations,AITM_Tender__c tender){
        for(Id tenderLocationId :locationAndPrefrredServiceMap.keySet()){          
              Set<Boolean> adhocvol = new Set<Boolean>();
              AITM_Tender_Location__c locationToUpdate = tenderLocations.get(tenderLocationId);
              List<AITM_Tender_Location_Line_Item__c> lineItems =  locationAndPrefrredServiceMap.get(tenderLocationId);
              for(AITM_Tender_Location_Line_Item__c t:lineItems){
                  adhocvol.add(t.AITM_Ad_hoc_Volume__c);     
              }
                 if(locationToUpdate!=null){
                     if(adhocvol.contains(false)){       
          		      locationToUpdate.AITM_Customer_Service_Level__c = tender.AITM_Customer_Service_Level__c;
			          locationToUpdate.AITM_Aircraft_Type__c = tender.AITM_Aircraft_Type__c;
			          locationToUpdate.AITM_Service_Level__c = tender.AITM_Customer_Service_Level__c;
                      locationToUpdate.AITM_Aircraft_Type_Serrvice__c =  tender.AITM_Aircraft_Type__c;   
			          String serviceLevel = tender.AITM_Customer_Service_Level__c;                
			           if(serviceLevel =='Level I') {
			             locationToUpdate.AITM_CustomerDefaultValue__c = 1;
			           }else{if(serviceLevel =='Level II'){
			                locationToUpdate.AITM_CustomerDefaultValue__c = 2;
			             }else{ if(serviceLevel =='Level III')
			                     locationToUpdate.AITM_CustomerDefaultValue__c = 3;
			                  }
			                }              
                     }else{
                          locationToUpdate.AITM_Customer_Service_Level__c =  'Level I';
                          locationToUpdate.AITM_Service_Level__c = 'Level I';
                          locationToUpdate.AITM_CustomerDefaultValue__c = 1;
                        }
                 }
        }

    } 
}

    
    
      
        /*public static void customerLevelServiceCalculation(Map<Id,List<AITM_Tender_Location_Line_Item__c>> locationAndPrefrredServiceMap,Map<Id,AITM_Tender_Location__c> tenderLocations,AITM_Tender__c tender){
         //need to write the logic for the customer service calculation
         for(Id tenderLocationId :locationAndPrefrredServiceMap.keySet()){
              Set<String> customerDefaultServiceLevel  = new Set<String>();
              Set<Id> setOfAccountIds = new Set<Id>();
              
              Map<String,List<String>> mapOfAirCraftType = new Map<String,List<String>>();
              
              Set<Boolean> adhocvol = new Set<Boolean>();
              AITM_Tender_Location__c locationToUpdate = tenderLocations.get(tenderLocationId);

              List<AITM_Tender_Location_Line_Item__c> lineItems =  locationAndPrefrredServiceMap.get(tenderLocationId);
              for(AITM_Tender_Location_Line_Item__c t:lineItems){
               adhocvol.add(t.AITM_Ad_hoc_Volume__c);
              

              }

             if(adhocvol.contains(false)){
              
              for(AITM_Tender_Location_Line_Item__c t:lineItems){
                     

                   customerDefaultServiceLevel.add(t.AITM_Account__r.AITM_Preferred_Service_Level__c);
                   setOfAccountIds.add(t.AITM_Account__c);
                  
                   if(mapOfAirCraftType.containsKey(t.AITM_Account__r.AITM_Preferred_Service_Level__c)){
                       List<String> aircraftType = mapOfAirCraftType.get(t.AITM_Account__r.AITM_Preferred_Service_Level__c);
                       aircraftType.add(t.AITM_Account__r.AITM_Aircraft_Fleet__c);
                   }else{
                       List<String> cs = new List<String>();
                      cs.add(t.AITM_Account__r.AITM_Aircraft_Fleet__c);
                      mapOfAirCraftType.put(t.AITM_Account__r.AITM_Preferred_Service_Level__c,cs);  

                   }

              }
              if(setOfAccountIds.size() == customerDefaultServiceLevel.size() || customerDefaultServiceLevel.size()>1){
               calculateCustomerServiceLevel(mapOfAirCraftType,locationToUpdate,customerDefaultServiceLevel);
              
               
            }else{
                List<String> tenderCustomerAccount = new List<String>();
                for(AITM_Tender_Account__c a:tender.AITM_Tender_Accounts__r){
                    if(a.AITM_Affiliates_Account__c!=Null && setOfAccountIds.contains(a.AITM_Account__c)){
                    tenderCustomerAccount.add(a.AITM_Affiliates_Account__r.AITM_Aircraft_Fleet__c);
                    }
                }
                calculateCustomerServiceLevelForSameLevels(customerDefaultServiceLevel,locationToUpdate,tenderCustomerAccount,lineItems);

                 

            }
         }else{
             locationToUpdate.AITM_Customer_Service_Level__c =  'Level I';
             locationToUpdate.AITM_Service_Level__c = 'Level I';
             locationToUpdate.AITM_CustomerDefaultValue__c = 1;

         }
         }

        } 
        public static void calculateCustomerServiceLevel(Map<String,List<String>> mapOfAirCraftType,AITM_Tender_Location__c locationToUpdate, Set<String> customerDefaultServiceLevel){
        if(customerDefaultServiceLevel.contains('Level III') && locationToUpdate!=null){
                  
                      locationToUpdate.AITM_Customer_Service_Level__c =  'Level III';  
                      List<String> ls =   mapOfAirCraftType.get('Level III') ;             
                      locationToUpdate.AITM_Aircraft_Type_Serrvice__c = ls.get(ls.size()-1);
                      locationToUpdate.AITM_Service_Level__c = 'Level III';  
                      locationToUpdate.AITM_Aircraft_Type__c = ls.get(ls.size()-1);
                      locationToUpdate.AITM_CustomerDefaultValue__c = 3;

              
              }
              else{
                  if(customerDefaultServiceLevel.contains('Level II') && locationToUpdate!=null){
                      locationToUpdate.AITM_Customer_Service_Level__c = 'Level II';
                      List<String> ls =   mapOfAirCraftType.get('Level II') ; 
                      locationToUpdate.AITM_Aircraft_Type_Serrvice__c = ls.get(ls.size()-1);
                      locationToUpdate.AITM_Service_Level__c = 'Level II';  
                      locationToUpdate.AITM_Aircraft_Type__c = ls.get(ls.size()-1);
                      locationToUpdate.AITM_CustomerDefaultValue__c = 2;
                  }
                  else{
                      if(customerDefaultServiceLevel.contains('Level I') && locationToUpdate!=null){
                      locationToUpdate.AITM_Customer_Service_Level__c = 'Level I';
                      List<String> ls =   mapOfAirCraftType.get('Level I') ; 
                      locationToUpdate.AITM_Aircraft_Type_Serrvice__c = ls.get(ls.size()-1);
                      locationToUpdate.AITM_Service_Level__c = 'Level I';  
                      locationToUpdate.AITM_Aircraft_Type__c = ls.get(ls.size()-1);
                      locationToUpdate.AITM_CustomerDefaultValue__c = 1;
                  }

                  }

              }
        
        
        
        
        }

        public static void calculateCustomerServiceLevelForSameLevels(Set<String> customerDefaultServiceLevel,AITM_Tender_Location__c locationToUpdate, List<String> tenderCustomerAccount,List<AITM_Tender_Location_Line_Item__c> lineItems){
        Decimal maxValue = 0;
        String aircraft ;
       
        if(customerDefaultServiceLevel.contains('Level III') && locationToUpdate!=null){                  
                      locationToUpdate.AITM_Customer_Service_Level__c = 'Level III'; 
                     
                      locationToUpdate.AITM_Service_Level__c = 'Level III';                      
                      locationToUpdate.AITM_CustomerDefaultValue__c = 3;
                      if(tenderCustomerAccount.size()>0 && tenderCustomerAccount!=null) {
                        locationToUpdate.AITM_Aircraft_Type_Serrvice__c = tenderCustomerAccount.get(0);
                         locationToUpdate.AITM_Aircraft_Type__c = tenderCustomerAccount.get(0);
                      } else{
                          for(AITM_Tender_Location_Line_Item__c t :lineItems){
                              if(maxValue <= t.AITM_Requested_Volume_USG__c){
                                  maxValue = t.AITM_Requested_Volume_USG__c;
                                  aircraft = t.AITM_Account__r.AITM_Aircraft_Fleet__c;
                              }
                              
                              
                              }
                              locationToUpdate.AITM_Aircraft_Type_Serrvice__c = aircraft;
                         locationToUpdate.AITM_Aircraft_Type__c = aircraft;
                                           
          

                            
        }            
                      
        } else{
                  if(customerDefaultServiceLevel.contains('Level II') && locationToUpdate!=null){
                      locationToUpdate.AITM_Customer_Service_Level__c =  'Level II';                            
                      locationToUpdate.AITM_Service_Level__c = 'Level II';            
                      locationToUpdate.AITM_CustomerDefaultValue__c = 2;
                      if(tenderCustomerAccount.size()>0 && tenderCustomerAccount!=null) {
                        locationToUpdate.AITM_Aircraft_Type_Serrvice__c = tenderCustomerAccount.get(0);
                         locationToUpdate.AITM_Aircraft_Type__c = tenderCustomerAccount.get(0);
                      } else{

                          for(AITM_Tender_Location_Line_Item__c t :lineItems){
                              if(maxValue < t.AITM_Requested_Volume_USG__c){
                                  maxValue = t.AITM_Requested_Volume_USG__c;
                                  aircraft = t.AITM_Account__r.AITM_Aircraft_Fleet__c;
                              }
                              
                              
                              }
                              locationToUpdate.AITM_Aircraft_Type_Serrvice__c = aircraft;
                         locationToUpdate.AITM_Aircraft_Type__c = aircraft;
                      }

                  }else{
                      if(customerDefaultServiceLevel.contains('Level I') && locationToUpdate!=null){
                      locationToUpdate.AITM_Customer_Service_Level__c =  'Level I';                   
                      locationToUpdate.AITM_Service_Level__c = 'Level I'; 
                      locationToUpdate.AITM_CustomerDefaultValue__c = 1;            
                      if(tenderCustomerAccount.size()>0 && tenderCustomerAccount!=null) {
                         locationToUpdate.AITM_Aircraft_Type_Serrvice__c = tenderCustomerAccount.get(0);
                         locationToUpdate.AITM_Aircraft_Type__c = tenderCustomerAccount.get(0);
                      } else{

                          for(AITM_Tender_Location_Line_Item__c t :lineItems){
                              if(maxValue < t.AITM_Requested_Volume_USG__c){
                                  maxValue = t.AITM_Requested_Volume_USG__c;
                                  aircraft = t.AITM_Account__r.AITM_Aircraft_Fleet__c;
                              }
                              
                              
                              }
                              locationToUpdate.AITM_Aircraft_Type_Serrvice__c = aircraft;
                              locationToUpdate.AITM_Aircraft_Type__c = aircraft;
                      }
                      
                      }   

                  }

              }
        
        
        
        
        }*/