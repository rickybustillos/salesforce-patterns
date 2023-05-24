/**
 * @description: Test class for MuleEventQueueHandler
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleEventQueueHandlerTest {

    @isTest
    static void itShouldCreateAnEventQueue() {

        Test.startTest();

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.createEventQueue();

        Test.stopTest();

        List<MuleEventQueue__c> storedEventQueues = [SELECT Id FROM MuleEventQueue__c WHERE Id = :eventQueue.Id];

        System.assertEquals( 1, storedEventQueues.size(), 'There should be one event queue created');
    }

    @isTest
    static void itShoulReturnAnErrorWhenCreatingDuplicatedEventQueue() {

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.createEventQueue();

        Test.startTest();

        try {

            MuleEventQueue__c newEventQueue = MuleEventQueueFactory.createEventQueue();

            System.assert( false, 'There should be an error' );

        } catch ( DmlException e ) {

            System.assert( true, 'There should be an error' );
        }

        Test.stopTest();
    }

    @isTest
    static void itShouldCreateAnSchedulableEventQueue() {

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.createEventQueue();

        MuleEventQueue__c newEventQueue = MuleEventQueueFactory.newEventQueue();
        newEventQueue.ObjectId__c = 'anotherObjectId';

        Test.startTest();

        MuleEventQueueFactory.createEventQueue( newEventQueue );

        Test.stopTest();

        List<MuleEventQueue__c> storedEventQueues = [SELECT Id FROM MuleEventQueue__c WHERE Id = :newEventQueue.Id];

        System.assertEquals( 1, storedEventQueues.size(), 'There should return the event queue created');
    }
}