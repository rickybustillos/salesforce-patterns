/**
 * @description: Test class for MuleEventQueueHandler
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleEventQueueHandlerTest {

    @isTest
    static void itShouldCreateAnEventQueue() {

        Test.startTest();

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.createMuleEventQueue();

        Test.stopTest();

        List<MuleEventQueue__c> storedEventQueues = [SELECT Id FROM MuleEventQueue__c WHERE Id = :eventQueue.Id];

        System.assertEquals( 1, storedEventQueues.size(), 'There should be one event queue created');
    }

    @isTest
    static void itShoulReturnAnErrorWhenCreatingDuplicatedEventQueue() {

        MuleIntegration__c integration = MuleIntegrationFactory.createMuleIntegration();

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.createMuleEventQueue( integration );

        Test.startTest();

        try {

            MuleEventQueue__c newEventQueue = MuleEventQueueFactory.createMuleEventQueue( integration );

            System.assert( false, 'There should be an error' );

        } catch ( DmlException e ) {

            System.assert( true, 'There should be an error' );
        }

        Test.stopTest();
    }

    @isTest
    static void itShouldCreateAnSchedulableEventQueue() {

        MuleIntegration__c integration = MuleIntegrationFactory.createMuleIntegration();

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.createMuleEventQueue( integration );

        MuleEventQueue__c newEventQueue = MuleEventQueueFactory.newMuleEventQueue( integration );
        newEventQueue.ObjectId__c = 'anotherObjectId';

        Test.startTest();

        MuleEventQueueFactory.createMuleEventQueue( newEventQueue );

        Test.stopTest();

        List<MuleEventQueue__c> storedEventQueues = [SELECT Id FROM MuleEventQueue__c WHERE Id = :newEventQueue.Id];

        System.assertEquals( 1, storedEventQueues.size(), 'There should return the event queue created');
    }
}