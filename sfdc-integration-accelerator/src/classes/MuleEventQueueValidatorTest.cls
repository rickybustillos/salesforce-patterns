/**
 * @description: Test class for MuleEventQueueValidator
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleEventQueueValidatorTest {

    @isTest
    static void scenarioWithExistentPendingObjectId() {

        List<MuleEventQueue__c> eventQueues = new List<MuleEventQueue__c>{ MuleEventQueueFactory.newMuleEventQueue() };

        List<String> exitentObjectsIds = new List<String>{ eventQueues.get(0).ObjectId__c };

        Test.startTest();

        MuleEventQueueValidator validator = new MuleEventQueueValidator();

        validator.withNotDuplicatedObjectId( eventQueues , exitentObjectsIds );

        Test.stopTest();

        System.assert( eventQueues.get(0).hasErrors(), 'MuleEventQueue should have error' );
    }

    @isTest
    static void scenarioWithDuplicatedInSameContext() {

        List<MuleEventQueue__c> eventQueues = new List<MuleEventQueue__c>{
            MuleEventQueueFactory.newMuleEventQueue(),
            MuleEventQueueFactory.newMuleEventQueue()
        };

        Test.startTest();

        MuleEventQueueValidator validator = new MuleEventQueueValidator();

        validator.withNotDuplicatedObjectId( eventQueues , new List<String>() );

        Test.stopTest();

        System.assert( eventQueues.get(1).hasErrors(), 'MuleEventQueue should have error' );
    }
}