/**
 * @description: Test class for MuleEventQueueFilter
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleEventQueueFilterTest {

    @isTest
    static void returnEventsWhenFilterByInactiveIntegrations() {

        List<MuleEventQueue__c> muleEventQueues = new MuleEventQueue__c[]{ MuleEventQueueFactory.newMuleEventQueue() };

        Map<String, MuleIntegration__mdt> integrations = MuleIntegrationFactory.newIntegrations();

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredEventQueues = filter.byInactiveIntegrations( muleEventQueues, integrations );

        Test.stopTest();

        Assert.areEqual( 1, filteredEventQueues.size(), 'Filtered event queues should have 1 element' );
    }

    @isTest
    static void returnEventWhenFilterNewPendingByDuplicityValidables () {

        String eventQueuesPayload = '[{ "Status__c": "PENDING" }]';

        List<MuleEventQueue__c> muleEventQueues = MuleEventQueueFactory.fromJsonArray(eventQueuesPayload);

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredEventQueues = filter.byDuplicityValidables( muleEventQueues, new Map<Id, MuleEventQueue__c>() );

        Test.stopTest();

        Assert.areEqual( 1, filteredEventQueues.size(), 'Filtered event queues should have 1 element' );
    }

    @isTest
    static void returnEventWhenFilterUpdatedByDuplicityValidables () {

        String eventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "PENDING", "IsRetryBlocked__c": false }]';

        String oldEventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "PENDING", "IsRetryBlocked__c": true }]';

        List<MuleEventQueue__c> muleEventQueues = MuleEventQueueFactory.fromJsonArray(eventQueuesPayload);

        Map<Id, MuleEventQueue__c> oldEventQueuesById = new Map<Id, MuleEventQueue__c>(
            MuleEventQueueFactory.fromJsonArray(oldEventQueuesPayload)
        );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredEventQueues = filter.byDuplicityValidables( muleEventQueues, oldEventQueuesById );

        Test.stopTest();

        Assert.areEqual( 1, filteredEventQueues.size(), 'There should not have duplicity validables event queues' );
    }

    @isTest
    static void returnEventWhenFilterCanceledToPendingByDuplicityValidables () {

        String eventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "PENDING" }]';

        String oldEventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "CANCELED" }]';

        List<MuleEventQueue__c> muleEventQueues = MuleEventQueueFactory.fromJsonArray(eventQueuesPayload);

        Map<Id, MuleEventQueue__c> oldEventQueuesById = new Map<Id, MuleEventQueue__c>(
            MuleEventQueueFactory.fromJsonArray(oldEventQueuesPayload)
        );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredEventQueues = filter.byDuplicityValidables( muleEventQueues, oldEventQueuesById );

        Test.stopTest();

        Assert.areEqual( 1, filteredEventQueues.size(), 'Filtered event queues should have 1 element' );
    }

    @isTest
    static void returnEventWhenFilterPendingToSentByDuplicityValidables () {

        String eventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "SENT" }]';

        String oldEventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "PENDING" }]';

        List<MuleEventQueue__c> muleEventQueues = MuleEventQueueFactory.fromJsonArray(eventQueuesPayload);

        Map<Id, MuleEventQueue__c> oldEventQueuesById = new Map<Id, MuleEventQueue__c>(
            MuleEventQueueFactory.fromJsonArray(oldEventQueuesPayload)
        );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredEventQueues = filter.byDuplicityValidables( muleEventQueues, oldEventQueuesById );

        Test.stopTest();

        Assert.areEqual( 1, filteredEventQueues.size(), 'Duplicity validables event queues should have 1 element' );
    }

    @isTest
    static void returnEmptyWhenFilterSentToTechnicalErrorByDuplicityValidables () {

        String eventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "TECHNICAL_ERROR" }]';

        String oldEventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "SENT" }]';

        List<MuleEventQueue__c> muleEventQueues = MuleEventQueueFactory.fromJsonArray(eventQueuesPayload);

        Map<Id, MuleEventQueue__c> oldEventQueuesById = new Map<Id, MuleEventQueue__c>(
            MuleEventQueueFactory.fromJsonArray(oldEventQueuesPayload)
        );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredEventQueues = filter.byDuplicityValidables( muleEventQueues, oldEventQueuesById );

        Test.stopTest();

        System.assert( filteredEventQueues.isEmpty(), 'There should not have any duplicity validables queues.' );
    }

    @isTest
    static void itShouldReturnPendingEventQueues() {

        String payload = '[{ "Status__c": "PENDING" }, { "Status__c": "CANCELED" }]';

        List<MuleEventQueue__c> muleEventQueues = MuleEventQueueFactory.fromJsonArray( payload );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredEventQueues = filter.byPendingEventQueues( muleEventQueues );

        Test.stopTest();

        Assert.areEqual( 1, filteredEventQueues.size(), 'Filtered event queues should have 1 element' );
    }

    @isTest
    static void itShouldReturnRetryedEventQueues() {

        String payload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "SUCCESS" }, { "Id": "a1K890000003A1FEAU", "Status__c": "PENDING" }]';

        String oldEventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "TECHNICAL_ERROR" }, { "Id": "a1K890000003A1FEAU", "Status__c": "CANCELED" }]';

        List<MuleEventQueue__c> newEventQueues = MuleEventQueueFactory.fromJsonArray( payload );

        Map<Id, MuleEventQueue__c> oldEventQueues = new Map<Id, MuleEventQueue__c>( MuleEventQueueFactory.fromJsonArray( oldEventQueuesPayload ) );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredEventQueues = filter.byRetryedEventQueues( newEventQueues, oldEventQueues );

        Test.stopTest();

        Assert.areEqual( 1, filteredEventQueues.size(), 'Filtered event queues should have 1 element' );
    }

    @isTest
    static void returnEventsWithEmptyStatus() {

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.newMuleEventQueue();
        eventQueue.Status__c = null;

        List<MuleEventQueue__c> muleEventQueues = new List<MuleEventQueue__c>{ eventQueue };

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredQueues = filter.byEmptyStatus( muleEventQueues );

        Test.stopTest();

        Assert.areEqual( 1, filteredQueues.size(), 'Filtered event queues should have 1 element' );
    }
}