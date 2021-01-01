/***********************************************************************************************
 * @author           George
 * @date             25/Jan/2018
 * @group            AirBP
 * @description      Trigger Handler for Location

 * history
 * 01/December/2017  George         Created
 * 20/March/2018     Ravi           Removed Create Default Delivery Point when Location is created AR-2972
 *************************************************************************************/
public class AITM_LocationHandler implements AITM_TriggerFactory.SObjectHandler {
    private HandlerRepository handlersStorage;

    /**
     * @description constructor to initialize and register handlerrepository
     */
    public AITM_LocationHandler() {
        handlersStorage = new HandlerRepository();
    }

    /**
     * @description bulk before factory method operation SObject handler
     * @param null
     * @return void
     */   

    public void bulkBefore() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkBefore();
        }
    }

    /**
     * @description bulk after factory method operation SObject handler
     * @param null
     * @return void
     */

    public void bulkAfter() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkAfter();
        }
    }

    /**
     * @description bulk before Insert factory method operation SObject handler
     * @param null
     * @return void
     */

    public void beforeInsert(SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeInsert(so);
        }
    }

    /**
     * @description bulk before update factory method operation SObject handler
     * @param null
     * @return void
     */

    public void beforeUpdate(SObject oldSo, SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeUpdate(oldSo, so);
        }
    }

    /**
     * @description bulk before delete factory method operation SObject handler
     * @param null
     * @return void
     */

    public void beforeDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeDelete(so);
        }
    }

    /**
     * @description bulk after insert factory method operation SObject handler
     * @param null
     * @return void
     */

    public void afterInsert(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterInsert(so);
        }
    }

    /**
     * @description bulk after update factory method operation SObject handler
     * @param null
     * @return void
     */

    public void afterUpdate(SObject oldSo, SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterUpdate(oldSo, so);
        }
    }

    /**
     * @description bulk after delete factory method operation SObject handler
     * @param null
     * @return void
     */

    public void afterDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterDelete(so);
        }
    }

    /**
     * @description finally block method called for trigger event
     * @param null
     * @return void
     */

    public void andFinally() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.andFinally();
        }
    }

    /**
     * @description class implementing HandlerRepository interface
     */

    private class HandlerRepository implements AITM_TriggerFactory.HandlerRepository {
        private List<AITM_TriggerFactory.SObjectHandler> handlers;

        /**
         * @description default constructor of handlerrepository class
         */

        public HandlerRepository() {
            handlers = new List<AITM_TriggerFactory.SObjectHandler>();
        }

        /**
         * @description registers/adds SObject handler to collection
         * @param handler of type AITM_TriggerFactory.SObjectHandler
         * @return void
         */

        public void register(AITM_TriggerFactory.SObjectHandler handler) {
            handlers.add(handler);
        }
        
        /**
         * @description returns list collection of SObjectHandler
         * @param null
         * @return List collection of type AITM_TriggerFactory.SObjectHandler
         */
        
        public List<AITM_TriggerFactory.SObjectHandler> handlers() {
            return handlers;
        }
    }

    /**
     * @description class which invokes create default delivery point
     */

    private class CreateDefaultDeliveryPoint implements AITM_TriggerFactory.SObjectHandler {

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return void
         */

        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return void
         */

        public void bulkAfter(){}

        /**
         * @description bulk before insert factory method operation SObject handler
         * @param null
         * @return void
         */

        public void beforeInsert(SObject so){}

        /**
         * @description bulk before update factory method operation SObject handler
         * @param null
         * @return void
         */

        public void beforeUpdate(SObject oldSo, SObject so){}


        /**
         * @description bulk before delete factory method operation SObject handler
         * @param null
         * @return void
         */
        public void beforeDelete(SObject so){}

        /**
         * @description bulk after Insert factory method operation SObject handler
         * @param null
         * @return void
         */


        public void afterInsert(SObject so){}

        /**
         * @description bulk after update factory method operation SObject handler
         * @param null
         * @return void
         */

        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description bulk after delete factory method operation SObject handler
         * @param null
         * @return void
         */


        public void afterDelete(SObject so){}

        /**
         * @description finally block called for trigger handler 
         * @param null
         * @return void
         */
        

        public void andFinally() {}

    }

}