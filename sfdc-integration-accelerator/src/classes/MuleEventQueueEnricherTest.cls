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

        System.assertEquals( MuleEventQueueStatus.CANCELED.name(), canceledQueues.get(0).Status__c, 'Event Queue status should be CANCELED' );
    }

    @isTest
    static void itShouldBlockMuleEventQueue () {

        String eventQueuePayload = '{ "IsRetryBlocked__c": false }';

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.fromJson( eventQueuePayload );

        Test.startTest();

        MuleEventQueueEnricher enricher = new MuleEventQueueEnricher();

        MuleEventQueue__c enrichedQueue = enricher.blockRetry( eventQueue );

        Test.stopTest();

        System.assert( enrichedQueue.IsRetryBlocked__c, 'IsRetryBlocked__c should be true' );
    }

    @isTest
    static void itShouldBlockMuleEventQueues () {

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
        System.assertEquals( 3, enrichedQueues.get(0).RetryCount__c, 'RetryCount__c should be 3' );

        System.assert( !enrichedQueues.get(1).IsRetryBlocked__c, 'IsRetryBlocked__c should be false' );
        System.assertEquals( 1, enrichedQueues.get(1).RetryCount__c, 'RetryCount__c should be 1' );
    }
}