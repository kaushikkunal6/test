@isTest
private class BPI_MG1_TriggerHandlerTest {

    private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';

    private static String lastMethodCalled;

    private static BPI_MG1_TriggerHandlerTest.BPI_MG1_TestHandler handler;

    static {
        handler = new BPI_MG1_TriggerHandlerTest.BPI_MG1_TestHandler();
        // override its internal trigger detection
        handler.isTriggerExecuting = true;
    }

    /***************************************
    * unit tests
    ***************************************/

    // contexts tests

    @isTest
    static void testBeforeInsert() {
        beforeInsertMode();
        handler.run();
        System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
    }

    @isTest
    static void testBeforeUpdate() {
        beforeUpdateMode();
        handler.run();
        System.assertEquals('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
    }

    @isTest
    static void testBeforeDelete() {
        beforeDeleteMode();
        handler.run();
        System.assertEquals('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
    }

    @isTest
    static void testAfterInsert() {
        afterInsertMode();
        handler.run();
        System.assertEquals('afterInsert', lastMethodCalled, 'last method should be afterInsert');
    }

    @isTest
    static void testAfterUpdate() {
        afterUpdateMode();
        handler.run();
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
    }

    @isTest
    static void testAfterDelete() {
        afterDeleteMode();
        handler.run();
        System.assertEquals('afterDelete', lastMethodCalled, 'last method should be afterDelete');
    }

    @isTest
    static void testAfterUndelete() {
        afterUndeleteMode();
        handler.run();
        System.assertEquals('afterUndelete', lastMethodCalled, 'last method should be afterUndelete');
    }

    @isTest
    static void testNonTriggerContext() {
        try {
            handler.run();
            System.assert(false, 'the handler ran but should have thrown');
        } catch(BPI_MG1_TriggerHandler.TriggerHandlerException te) {
            System.assertEquals(TRIGGER_CONTEXT_ERROR, te.getMessage(), 'the exception message should match');
        } catch(Exception e) {
            System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }
    }

    // instance method tests

    @isTest
    static void testLoopCount() {
        beforeInsertMode();

        // set the max loops to 2
        handler.setMaxLoopCount(2);

        // run the handler twice
        handler.run();
        handler.run();

        // clear the tests
        resetTest();

        try {
            // try running it. This should exceed the limit.
            handler.run();
            System.assert(false, 'the handler should throw on the 3rd run when maxloopcount is 3');
        } catch(BPI_MG1_TriggerHandler.TriggerHandlerException te) {
            // we're expecting to get here
            System.assertEquals(null, lastMethodCalled, 'last method should be null');
        } catch(Exception e) {
            System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }

        // clear the tests
        resetTest();

        // now clear the loop count
        handler.clearMaxLoopCount();

        try {
            // re-run the handler. We shouldn't throw now.
            handler.run();
            System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
        } catch(BPI_MG1_TriggerHandler.TriggerHandlerException te) {
            System.assert(false, 'running the handler after clearing the loop count should not throw');
        } catch(Exception e) {
            System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }
    }

    @isTest
    static void testLoopCountClass() {
        BPI_MG1_TriggerHandler.LoopCount lc = new BPI_MG1_TriggerHandler.LoopCount();
        System.assertEquals(5, lc.getMax(), 'max should be five on init');
        System.assertEquals(0, lc.getCount(), 'count should be zero on init');

        lc.increment();
        System.assertEquals(1, lc.getCount(), 'count should be 1');
        System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 1');

        lc.increment();
        lc.increment();
        lc.increment();
        lc.increment();
        System.assertEquals(5, lc.getCount(), 'count should be 5');
        System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 5');

        lc.increment();
        System.assertEquals(6, lc.getCount(), 'count should be 6');
        System.assertEquals(true, lc.exceeded(), 'should not be exceeded with count of 6');
    }

    // private method tests

    @isTest
    static void testGetHandlerName() {
        System.assertEquals('BPI_MG1_TestHandler', handler.getHandlerName(), 'handler name should match class name');
    }

    // test virtual methods

    @isTest
    static void testVirtualMethods() {
        BPI_MG1_TriggerHandler h = new BPI_MG1_TriggerHandler();
        boolean isError = false;
        try{
            h.beforeInsert();
            h.beforeUpdate();
            h.beforeDelete();
            h.afterInsert();
            h.afterUpdate();
            h.afterDelete();
            h.afterUndelete();
        }
        catch (Exception e) {
            isError = true;

        }
        system.assertEquals(false, isError, 'exception occurred during virtual class execution');

    }

    /***************************************
    * testing utilities
    ***************************************/

    private static void resetTest() {
        lastMethodCalled = null;
    }

    // modes for testing

    private static void beforeInsertMode() {
        handler.setTriggerContext('before insert', true);
    }

    private static void beforeUpdateMode() {
        handler.setTriggerContext('before update', true);
    }

    private static void beforeDeleteMode() {
        handler.setTriggerContext('before delete', true);
    }

    private static void afterInsertMode() {
        handler.setTriggerContext('after insert', true);
    }

    private static void afterUpdateMode() {
        handler.setTriggerContext('after update', true);
    }

    private static void afterDeleteMode() {
        handler.setTriggerContext('after delete', true);
    }

    private static void afterUndeleteMode() {
        handler.setTriggerContext('after undelete', true);
    }

    // test implementation of the BPI_MG1_TriggerHandler

    private class BPI_MG1_TestHandler extends BPI_MG1_TriggerHandler {

        public override void beforeInsert() {
            BPI_MG1_TriggerHandlerTest.lastMethodCalled = 'beforeInsert';
        }

        public override void beforeUpdate() {
            BPI_MG1_TriggerHandlerTest.lastMethodCalled = 'beforeUpdate';
        }

        public override void beforeDelete() {
            BPI_MG1_TriggerHandlerTest.lastMethodCalled = 'beforeDelete';
        }

        public override void afterInsert() {
            BPI_MG1_TriggerHandlerTest.lastMethodCalled = 'afterInsert';
        }

        public override void afterUpdate() {
            BPI_MG1_TriggerHandlerTest.lastMethodCalled = 'afterUpdate';
        }

        public override void afterDelete() {
            BPI_MG1_TriggerHandlerTest.lastMethodCalled = 'afterDelete';
        }

        public override void afterUndelete() {
            BPI_MG1_TriggerHandlerTest.lastMethodCalled = 'afterUndelete';
        }

    }

}