/**
 * @description: Test class for MuleEventQueueFilter
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleEventQueueFilterTest {

    @isTest
    static void returnEventsWhenFilterByInactiveIntegrations() {

        List<MuleEventQueue__c> eventQueues = new MuleEventQueue__c[]{ MuleEventQueueFactory.newMuleEventQueue() };

        Map<String, EventIntegration__mdt> integrations = EventIntegrationFactory.newIntegrations();

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredMuleEventQueues = filter.byInactiveIntegrations( eventQueues, integrations );

        Test.stopTest();

        System.assertEquals( 1, filteredMuleEventQueues.size(), 'Filtered event queues should have 1 element' );
    }

    @isTest
    static void returnEventWhenFilterNewPendingByDuplicityValidables () {

        String eventQueuesPayload = '[{ "Status__c": "PENDING" }]';

        List<MuleEventQueue__c> eventQueues = MuleEventQueueFactory.fromJsonArray(eventQueuesPayload);

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredMuleEventQueues = filter.byDuplicityValidables( eventQueues, new Map<Id, MuleEventQueue__c>() );

        Test.stopTest();

        System.assertEquals( 1, filteredMuleEventQueues.size(), 'Filtered event queues should have 1 element' );
    }

    @isTest
    static void returnEventWhenFilterUpdatedByDuplicityValidables () {

        String eventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "PENDING", "IsRetryBlocked__c": false }]';

        String oldMuleEventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "PENDING", "IsRetryBlocked__c": true }]';

        List<MuleEventQueue__c> eventQueues = MuleEventQueueFactory.fromJsonArray(eventQueuesPayload);

        Map<Id, MuleEventQueue__c> oldMuleEventQueuesById = new Map<Id, MuleEventQueue__c>(
            MuleEventQueueFactory.fromJsonArray(oldMuleEventQueuesPayload)
        );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredMuleEventQueues = filter.byDuplicityValidables( eventQueues, oldMuleEventQueuesById );

        Test.stopTest();

        System.assertEquals( 1, filteredMuleEventQueues.size(), 'There should not have duplicity validables event queues' );
    }

    @isTest
    static void returnEventWhenFilterCanceledToPendingByDuplicityValidables () {

        String eventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "PENDING" }]';

        String oldMuleEventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "CANCELED" }]';

        List<MuleEventQueue__c> eventQueues = MuleEventQueueFactory.fromJsonArray(eventQueuesPayload);

        Map<Id, MuleEventQueue__c> oldMuleEventQueuesById = new Map<Id, MuleEventQueue__c>(
            MuleEventQueueFactory.fromJsonArray(oldMuleEventQueuesPayload)
        );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredMuleEventQueues = filter.byDuplicityValidables( eventQueues, oldMuleEventQueuesById );

        Test.stopTest();

        System.assertEquals( 1, filteredMuleEventQueues.size(), 'Filtered event queues should have 1 element' );
    }

    @isTest
    static void returnEventWhenFilterPendingToSentByDuplicityValidables () {

        String eventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "SENT" }]';

        String oldMuleEventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "PENDING" }]';

        List<MuleEventQueue__c> eventQueues = MuleEventQueueFactory.fromJsonArray(eventQueuesPayload);

        Map<Id, MuleEventQueue__c> oldMuleEventQueuesById = new Map<Id, MuleEventQueue__c>(
            MuleEventQueueFactory.fromJsonArray(oldMuleEventQueuesPayload)
        );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredMuleEventQueues = filter.byDuplicityValidables( eventQueues, oldMuleEventQueuesById );

        Test.stopTest();

        System.assertEquals( 1, filteredMuleEventQueues.size(), 'Duplicity validables event queues should have 1 element' );
    }

    @isTest
    static void returnEmptyWhenFilterSentToTechnicalErrorByDuplicityValidables () {

        String eventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "TECHNICAL_ERROR" }]';

        String oldMuleEventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "SENT" }]';

        List<MuleEventQueue__c> eventQueues = MuleEventQueueFactory.fromJsonArray(eventQueuesPayload);

        Map<Id, MuleEventQueue__c> oldMuleEventQueuesById = new Map<Id, MuleEventQueue__c>(
            MuleEventQueueFactory.fromJsonArray(oldMuleEventQueuesPayload)
        );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredMuleEventQueues = filter.byDuplicityValidables( eventQueues, oldMuleEventQueuesById );

        Test.stopTest();

        System.assert( filteredMuleEventQueues.isEmpty(), 'There should not have any duplicity validables queues.' );
    }

    @isTest
    static void itShouldReturnPendingMuleEventQueues() {

        String payload = '[{ "Status__c": "PENDING" }, { "Status__c": "CANCELED" }]';

        List<MuleEventQueue__c> eventQueues = MuleEventQueueFactory.fromJsonArray( payload );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredMuleEventQueues = filter.byPendingMuleEventQueues( eventQueues );

        Test.stopTest();

        System.assertEquals( 1, filteredMuleEventQueues.size(), 'Filtered event queues should have 1 element' );
    }

    @isTest
    static void itShouldReturnRetryedMuleEventQueues() {

        String payload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "SUCCESS" }, { "Id": "a1K890000003A1FEAU", "Status__c": "PENDING" }]';

        String oldMuleEventQueuesPayload = '[{ "Id": "a1K8900000039y1EAA", "Status__c": "TECHNICAL_ERROR" }, { "Id": "a1K890000003A1FEAU", "Status__c": "CANCELED" }]';

        List<MuleEventQueue__c> newMuleEventQueues = MuleEventQueueFactory.fromJsonArray( payload );

        Map<Id, MuleEventQueue__c> oldMuleEventQueues = new Map<Id, MuleEventQueue__c>( MuleEventQueueFactory.fromJsonArray( oldMuleEventQueuesPayload ) );

        Test.startTest();

        MuleEventQueueFilter filter = new MuleEventQueueFilter();

        List<MuleEventQueue__c> filteredMuleEventQueues = filter.byRetryedMuleEventQueues( newMuleEventQueues, oldMuleEventQueues );

        Test.stopTest();

        System.assertEquals( 1, filteredMuleEventQueues.size(), 'Filtered event queues should have 1 element' );
    }
}