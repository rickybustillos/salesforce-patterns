/**
 * @description: Test class for MuleEventQueueEnricher
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleEventQueueEnricherTest {

    @isTest
    static void returnCanceledEvent () {

        String eventQueuePayload = '[{ "Status__c": "PENDING" }]';

        List<MuleEventQueue__c> queuesToCancel = MuleEventQueueFactory.fromJsonArray( eventQueuePayload );

        Test.startTest();

        MuleEventQueueEnricher enricher = new MuleEventQueueEnricher();

        List<MuleEventQueue__c> canceledQueues = enricher.cancel( queuesToCancel );

        Test.stopTest();

        Assert.areEqual( MuleEventQueueStatus.CANCELED.name(), canceledQueues.get(0).Status__c, 'Mule Event Queue status should be CANCELED' );
    }

    @isTest
    static void itShouldBlockEventQueue () {

        String eventQueuePayload = '{ "IsRetryBlocked__c": false }';

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.fromJson( eventQueuePayload );

        Test.startTest();

        MuleEventQueueEnricher enricher = new MuleEventQueueEnricher();

        MuleEventQueue__c enrichedQueue = enricher.blockRetry( eventQueue );

        Test.stopTest();

        System.assert( enrichedQueue.IsRetryBlocked__c, 'IsRetryBlocked__c should be true' );
    }

    @isTest
    static void itShouldBlockEventQueues () {

        String eventQueuesPayload = '[{ "IsRetryBlocked__c": false }]';

        List<MuleEventQueue__c> eventQueues = MuleEventQueueFactory.fromJsonArray( eventQueuesPayload );

        Test.startTest();

        MuleEventQueueEnricher enricher = new MuleEventQueueEnricher();
        enricher.setRepository( new MuleEventQueueRepositoryTest.MuleEventQueueRepositoryMock() );

        List<MuleEventQueue__c> enrichedQueues = enricher.blockRetries( eventQueues );

        Test.stopTest();

        System.assert( enrichedQueues.get(0).IsRetryBlocked__c, 'IsRetryBlocked__c should be true' );
    }

    @isTest
    static void itShouldincrementRetryCount () {

        String eventQueuesPayload = '[{ "RetryCount__c": 2, "IsRetryBlocked__c": false }, { "RetryCount__c": 0, "IsRetryBlocked__c": false }]';

        List<MuleEventQueue__c> eventQueues = MuleEventQueueFactory.fromJsonArray( eventQueuesPayload );

        Test.startTest();

        MuleEventQueueEnricher enricher = new MuleEventQueueEnricher();
        enricher.setRepository( new MuleEventQueueRepositoryTest.MuleEventQueueRepositoryMock() );

        List<MuleEventQueue__c> enrichedQueues = enricher.incrementRetryCount( eventQueues );

        Test.stopTest();

        System.assert( enrichedQueues.get(0).IsRetryBlocked__c, 'IsRetryBlocked__c should be true' );
        Assert.areEqual( 3, enrichedQueues.get(0).RetryCount__c, 'RetryCount__c should be 3' );

        System.assert( !enrichedQueues.get(1).IsRetryBlocked__c, 'IsRetryBlocked__c should be false' );
        Assert.areEqual( 1, enrichedQueues.get(1).RetryCount__c, 'RetryCount__c should be 1' );
    }

    @isTest
    static void updatePublishedEvents() {

        TriggerHandler.bypass('MuleEventQueueHandler');

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.createMuleEventQueue();

        TriggerHandler.clearBypass('MuleEventQueueHandler');

        MuleIntegrationEvent__e event = new MuleIntegrationEvent__e();
        event.MuleEventQueueId__c = eventQueue.Id;
        event.MuleIntegrationName__c = eventQueue.MuleIntegrationName__c;

        Test.startTest();

        MuleEventQueueEnricher enricher = new MuleEventQueueEnricher();
        enricher.setRepository( new MuleEventQueueRepositoryTest.MuleEventQueueRepositoryMock() );

        List<MuleEventQueue__c> savedQueues = enricher.updatePublishedEvents( new List<MuleIntegrationEvent__e>{ event } );

        Test.stopTest();

        Assert.isFalse( savedQueues.isEmpty(), 'Should not be empty' );
        Assert.areEqual( 1, savedQueues.size(), 'Size should be 1' );
    }

    @isTest
    static void setPendingStatusAndResetFields() {

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.newMuleEventQueue();
        eventQueue.Status__c = null;
        eventQueue.ReturnedPayload__c = 'payload';
        eventQueue.Payload__c = 'payload';
        eventQueue.InternalError__c = 'error';

        List<MuleEventQueue__c> eventQueues = new List<MuleEventQueue__c>{ eventQueue };

        Test.startTest();

        MuleEventQueueEnricher enricher = new MuleEventQueueEnricher();

        List<MuleEventQueue__c> enrichedQueues = enricher.withPendingStatus( eventQueues );

        Test.stopTest();

        Assert.isFalse( enrichedQueues.isEmpty(), 'Should not be empty' );
        Assert.areEqual( enrichedQueues.size(), 1, 'Should be 1' );

        Assert.areEqual( MuleEventQueueStatus.PENDING.name(), enrichedQueues[0].Status__c, 'Should be PENDING' );
        Assert.areEqual( '', enrichedQueues[0].ReturnedPayload__c, 'Should be reseted' );
        Assert.areEqual( '', enrichedQueues[0].Payload__c, 'Should be reseted' );
        Assert.areEqual( '', enrichedQueues[0].InternalError__c, 'Should be reseted' );
    }
}