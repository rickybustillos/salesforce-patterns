/**
 * @description: Test class for MuleEventQueueHandler
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleEventQueueHandlerTest {

    @isTest
    static void itShouldCreateAnEventQueue() {

        Test.startTest();

        MuleEventQueue__c muleEventQueue = MuleEventQueueFactory.createMuleEventQueue();

        Test.stopTest();

        List<MuleEventQueue__c> storedEventQueues = [SELECT Id FROM MuleEventQueue__c WHERE Id = :muleEventQueue.Id];

        System.assertEquals( 1, storedEventQueues.size(), 'There should be one event queue created');
    }

    @isTest
    static void itShoulReturnAnErrorWhenCreatingDuplicatedEventQueue() {

        MuleEventQueue__c muleEventQueue = MuleEventQueueFactory.createMuleEventQueue();

        Test.startTest();

        try {

            MuleEventQueue__c newEventQueue = MuleEventQueueFactory.createMuleEventQueue();

            System.assert( false, 'There should be an error' );

        } catch ( DmlException e ) {

            System.assert( true, 'There should be an error' );
        }

        Test.stopTest();
    }

    @isTest
    static void itShouldCreateAnSchedulableEventQueue() {

        MuleEventQueue__c muleEventQueue = MuleEventQueueFactory.createMuleEventQueue();

        MuleEventQueue__c newEventQueue = MuleEventQueueFactory.newMuleEventQueue();
        newEventQueue.RecordId__c = 'anotherObjectId';

        Test.startTest();

        MuleEventQueueFactory.createMuleEventQueue( newEventQueue );

        Test.stopTest();

        List<MuleEventQueue__c> storedEventQueues = [SELECT Id FROM MuleEventQueue__c WHERE Id = :newEventQueue.Id];

        System.assertEquals( 1, storedEventQueues.size(), 'There should return the event queue created');
    }

    @isTest
    static void itShouldResetAnEventQueue() {

        MuleEventQueue__c muleEventQueue = MuleEventQueueFactory.newMuleEventQueue();
        muleEventQueue.Status__c = MuleEventQueueStatus.SENT.name();
        muleEventQueue.ReturnedPayload__c = 'payload';
        muleEventQueue.Payload__c = 'payload';
        muleEventQueue.InternalError__c = 'null';
        insert muleEventQueue;

        Test.startTest();

        muleEventQueue.Status__c = '';
        update muleEventQueue;

        Test.stopTest();

        List<MuleEventQueue__c> storedEventQueues = [SELECT Id, Status__c, ReturnedPayload__c, Payload__c, InternalError__c FROM MuleEventQueue__c WHERE Id = :muleEventQueue.Id];

        Assert.areEqual( 1, storedEventQueues.size(), 'There should be one event queue created and updated');

        Assert.areEqual( MuleEventQueueStatus.PENDING.name(), storedEventQueues[0].Status__c, 'Should be PENDING' );
        Assert.areEqual( null, storedEventQueues[0].ReturnedPayload__c, 'ReturnedPayload__c Should be reseted' );
        Assert.areEqual( null, storedEventQueues[0].Payload__c, 'Payload__c Should be reseted' );
        Assert.areEqual( null, storedEventQueues[0].InternalError__c, 'InternalError__c Should be reseted' );
    }
}