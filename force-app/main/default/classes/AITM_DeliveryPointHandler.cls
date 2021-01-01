/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    handler class for delivery point object

 * history
 * 01/December/2017  George       Created
 * 24/May/2019       srnandan     Modified - AR-5029 added functionality populating product default and density
 *                                 based on productdensity mapping, added comments both at class and method level
 *************************************************************************/
public with sharing class AITM_DeliveryPointHandler implements AITM_TriggerFactory.SObjectHandler {
    //variable holds handler class registration
    private HandlerRepository handlersStorage;
    /**
     * @description constructor method
     */
    public AITM_DeliveryPointHandler() {
        handlersStorage = new HandlerRepository();
        handlersStorage.register(new DeliveryPointChangeDefault());
        handlersStorage.register(new RemovedDormantDeliveryPoints());
    }   

    /**
     * @description bulk before trigger operation
     * @param null
     * @return null
     */
    public void bulkBefore() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkBefore();
        }
    }

    /**
     * @description bulk after trigger operation method
     * @param null
     * @return null
     */
    public void bulkAfter() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkAfter();
        }
    }

    /**
     * @description before insert trigger operation method
     * @param so of type SObject
     * @return null
     */
    public void beforeInsert(SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeInsert(so);
        }
    }

    /**
     * @description before update trigger operation method
     * @param oldSo of type SObject
     * @param so of type SObject
     * @return null
     */
    public void beforeUpdate(SObject oldSo, SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeUpdate(oldSo, so);
        }
    }

    /**
     * @description before delete trigger operation method
     * @param so of type SObject
     * @return null
     */
    public void beforeDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeDelete(so);
        }
    }

    /**
     * @description after insert trigger operation method
     * @param so of type SObject
     * @return null
     */
    public void afterInsert(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterInsert(so);
        }
    }

    /**
     * @description after update trigger operation method
     * @param oldSo of type SObject
     * @param so of type SObject
     * @return null
     */
    public void afterUpdate(SObject oldSo, SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterUpdate(oldSo, so);
        }
    }

    /**
     * @description after delete trigger operation
     * @param so of type SObject
     * @return null
     */
    public void afterDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterDelete(so);
        }
    }

    /**
     * @description finally method
     * @return null
     */
    public void andFinally() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.andFinally();
        }
    }

    private class HandlerRepository implements AITM_TriggerFactory.HandlerRepository {
        private List<AITM_TriggerFactory.SObjectHandler> handlers;

        public HandlerRepository() {
            handlers = new List<AITM_TriggerFactory.SObjectHandler>();
        }

        public void register(AITM_TriggerFactory.SObjectHandler handler) {
            handlers.add(handler);
        }
        
        public List<AITM_TriggerFactory.SObjectHandler> handlers() {
            return handlers;
        }
    }

    private class DeliveryPointChangeDefault implements AITM_TriggerFactory.SObjectHandler {
    	//private List<Id> locationIds;
    	//private Set<Id> currentDeliveryPointIds;
    	//private List<AITM_Delivery_Point__c> deliveryPointsToUpdate;

        public DeliveryPointChangeDefault() {
        	//locationIds = new List<Id>();
        	//currentDeliveryPointIds = new Set<Id>();
        	//deliveryPointsToUpdate = new List<AITM_Delivery_Point__c>();
        }

        public void bulkBefore(){}
        public void bulkAfter(){}
        public void beforeInsert(SObject so){
            //AITM_Delivery_Point__c deliveryPoint = (AITM_Delivery_Point__c) so;
            //collectLocationIdsOnSetDefaultValue(deliveryPoint, null);
            //currentDeliveryPointIds.add(deliveryPoint.Id);
        }
        public void beforeUpdate(SObject oldSo, SObject so){
        	//AITM_Delivery_Point__c deliveryPoint = (AITM_Delivery_Point__c) so;
        	//AITM_Delivery_Point__c deliveryPointOld = (AITM_Delivery_Point__c) oldSo;
            //collectLocationIdsOnSetDefaultValue(deliveryPoint, deliveryPointOld);
        	//currentDeliveryPointIds.add(deliveryPoint.Id);
        }
        public void beforeDelete(SObject so){}

        public void afterInsert(SObject so){}

        public void afterUpdate(SObject oldSo, SObject so){}

        public void afterDelete(SObject so){}

        public void andFinally() {
        	/*if(locationIds.size() > 0){
        		for(AITM_Delivery_Point__c deliveryPoint : [SELECT Id, AITM_Default__c FROM AITM_Delivery_Point__c WHERE AITM_Location__c IN :locationIds AND Id NOT IN :currentDeliveryPointIds]){
        			if(deliveryPoint.AITM_Default__c == true){
        				deliveryPoint.AITM_Default__c = false;
        				deliveryPointsToUpdate.add(deliveryPoint);
        			}
        		}
        	}
        	if(deliveryPointsToUpdate.size() > 0) {
        		update deliveryPointsToUpdate;
        	}*/
            if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
                updateDeliveryProductDetails(Trigger.new, trigger.oldmap);
            }
        }

        public void collectLocationIdsOnSetDefaultValue(AITM_Delivery_Point__c deliveryPoint, AITM_Delivery_Point__c deliveryPointOld) {
            /*if((deliveryPoint.AITM_Default__c && deliveryPointOld == null) || (deliveryPoint.AITM_Default__c && !deliveryPointOld.AITM_Default__c)) {
                locationIds.add(deliveryPoint.AITM_Location__c);
            }*/
        }

        /**
         * @description updates product default and density fields based on product density mapping
         * @param deliveryPoint of type list of AITM_Delivery_Point__c
         * @param oldDeliveryPoint of type map<id,sObject>
         * @return void
         */
        public void updateDeliveryProductDetails(List<AITM_Delivery_Point__c> deliveryPoint, Map<id,sObject> oldDeliveryPoint ) {
            Set<Id> tenderDeliveryPointSet = new Set<Id>();
            Set<String> productDensitySet = new Set<String>();
            Map<Id,AITM_Delivery_Point__c> oldDeliveryPointMap = (oldDeliveryPoint != null) ? (Map<Id,AITM_Delivery_Point__c>)oldDeliveryPoint : new Map<Id,AITM_Delivery_Point__c>();
            for(AITM_Delivery_Point__c delivery : deliveryPoint) {
				productDensitySet.add(delivery.AITM_Product__c);                    
            }
            if(!productDensitySet.isEmpty()) {
                Map<String, AITM_Product_Density_Mapping__mdt> mapProductDensity = AITM_BaseUtils.getProductDensityMap(productDensitySet);
                if(!mapProductDensity.isEmpty()) {
                	for(AITM_Delivery_Point__c singleLocation : deliveryPoint) {   
                   	  singleLocation.AITM_Density__c = mapProductDensity.get(singleLocation.AITM_Product__c).AITM_Density__c;
                      singleLocation.AITM_Product_Default__c = mapProductDensity.get(singleLocation.AITM_Product__c).AITM_Product__c;
                      singleLocation.AITM_Product_Pricing_Report__c = mapProductDensity.get(singleLocation.AITM_Product__c).AITM_Description__c;
               		}    
                }
            }
        }
    }
    
    private class RemovedDormantDeliveryPoints implements AITM_TriggerFactory.SObjectHandler {
        private List<AITM_Delivery_Point__c> listofDPToUpdate;
        private Set<Id> setofIds;

        public RemovedDormantDeliveryPoints() {
            listofDPToUpdate = new List<AITM_Delivery_Point__c>();
            setofIds = new Set<Id>();
        }

        public void bulkBefore(){}
        public void bulkAfter(){}
        public void beforeInsert(SObject so){}
        
        public void beforeUpdate(SObject oldSo, SObject so){}
        
        public void beforeDelete(SObject so){}

        public void afterInsert(SObject so){
            AITM_Delivery_Point__c deliveryPoint = (AITM_Delivery_Point__c) so;
            setofIds.add(deliveryPoint.Id);
        }

        public void afterUpdate(SObject oldSo, SObject so){}

        public void afterDelete(SObject so){}

        public void andFinally() {
            if(setofIds != null && setofIds.size() > 0){
                List<AITM_Delivery_Point__c> deliveryPoints = [Select id, Name, AITM_Is_Active__c, AITM_Location__c FROM AITM_Delivery_Point__c where Id IN :setofIds];
                for(AITM_Delivery_Point__c delPoint : deliveryPoints){
                    if(delPoint.AITM_Is_Active__c == true){
                        delPoint.AITM_Location__c = null;
                        listofDPToUpdate.add(delPoint);
                    }
                }
            }
        	if(listofDPToUpdate.size() > 0){
        		Database.update(listofDPToUpdate, false);
        	}
        }
    }
}