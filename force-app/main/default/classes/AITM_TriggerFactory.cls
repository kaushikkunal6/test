public with sharing class AITM_TriggerFactory {

    private SObjectHandler handler;

    public AITM_TriggerFactory(Schema.sObjectType soType) {
        handler = this.getHandler(soType);  
        if (handler == null) {
            throw new TriggerException('No Trigger Handler registered for Object Type: ' + soType);
        }
    }

    public void execute() {
        if (Trigger.isBefore) {
            this.handleBefore();
        }
        else {
            this.handleAfter();
        }

        handler.andFinally();
    }

    private void handleBefore() {
        handler.bulkBefore();
            
        if (Trigger.isDelete) {
            for (SObject so : Trigger.old) {
                handler.beforeDelete(so);
            }
        } else if (Trigger.isInsert) {
            for (SObject so : Trigger.new) {
                handler.beforeInsert(so);
            }
        } else if (Trigger.isUpdate) {
            for (SObject so : Trigger.old) {
                handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
            }
        }
    }

    private void handleAfter() {
        handler.bulkAfter();
            
        if (Trigger.isDelete) {
            for (SObject so : Trigger.old) {
                handler.afterDelete(so);
            }
        } else if (Trigger.isInsert) {
            for (SObject so : Trigger.new) {
                handler.afterInsert(so);
            }
        } else if (Trigger.isUpdate) {
            for (SObject so : Trigger.old) {
                handler.afterUpdate(so, Trigger.newMap.get(so.Id));
            }
        }
    }
    
    private SObjectHandler getHandler(Schema.sObjectType soType) {
        
        if (soType == AITM_Tender_Location__c.sObjectType) {
            return new AITM_TenderLocationHandler();
        }
        else if (soType == AITM_Tender_Location_Staging__c.sObjectType) {
            return new AITM_TenderLocationStagingHandler();
        }
        /*else if (soType == AITM_Tender_Location_Line_Item__c.sObjectType) {
            return new AITM_TenderLocationLineItemHandler();
        }*/
        /*else if (soType == AITM_Tender__c.sObjectType) {
            return new AITM_TenderHandler();
        }*/
        else if (soType == AITM_Delivery_Point__c.sObjectType) {
            return new AITM_DeliveryPointHandler();
        }
        else if (soType == AITM_Location__c.sObjectType) {
            return new AITM_LocationHandler();
        } 
        else if (soType == AITM_Location_Manager__c.sObjectType) {
            return new AITM_LocationManagerHandler();
        }
        return null;
    }

    public interface SObjectHandler {
        void bulkBefore();
        void bulkAfter();
        void beforeInsert(SObject so);
        void beforeUpdate(SObject oldSo, SObject so);
        void beforeDelete(SObject so);
        void afterInsert(SObject so);
        void afterUpdate(SObject oldSo, SObject so);
        void afterDelete(SObject so);
        void andFinally();
    }

    public interface HandlerRepository {
        void register(SObjectHandler handler);
        List<SObjectHandler> handlers();
    }

    public with sharing class TriggerException extends Exception {}

}