/**
 * @description: Test class for MuleEventQueueValidator
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleEventQueueValidatorTest {

    @isTest
    static void scenarioWithExistentPendingObjectId() {

        List<MuleEventQueue__c> muleEventQueues = new List<MuleEventQueue__c>{ MuleEventQueueFactory.newMuleEventQueue() };

        List<String> exitentObjectsIds = new List<String>{ muleEventQueues.get(0).RecordId__c };

        Test.startTest();

        MuleEventQueueValidator validator = new MuleEventQueueValidator();

        validator.withNotDuplicatedObjectId( muleEventQueues , exitentObjectsIds );

        Test.stopTest();

        System.assert( muleEventQueues.get(0).hasErrors(), 'EventQueue should have error' );
    }

    @isTest
    static void scenarioWithDuplicatedInSameContext() {

        List<MuleEventQueue__c> muleEventQueues = new List<MuleEventQueue__c>{
            MuleEventQueueFactory.newMuleEventQueue(),
            MuleEventQueueFactory.newMuleEventQueue()
        };

        Test.startTest();

        MuleEventQueueValidator validator = new MuleEventQueueValidator();

        validator.withNotDuplicatedObjectId( muleEventQueues , new List<String>() );

        Test.stopTest();

        System.assert( muleEventQueues.get(1).hasErrors(), 'EventQueue should have error' );
    }
}