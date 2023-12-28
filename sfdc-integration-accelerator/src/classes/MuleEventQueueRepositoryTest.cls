/**
 * @description: Test class for MuleEventQueueRepository
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleEventQueueRepositoryTest {

    @TestSetup
    static void setup(){
        TriggerHandler.bypass('MuleEventQueueHandler');

        MuleEventQueue__c muleEventQueue = MuleEventQueueFactory.createMuleEventQueue();

        TriggerHandler.clearAllBypasses();
    }

    @isTest
    static void findByIdsTest() {

        Id muleEventQueueId = [ SELECT Id FROM MuleEventQueue__c LIMIT 1 ].Id;

        Test.startTest();

        MuleEventQueueRepository repository = new MuleEventQueueRepository();

        List<MuleEventQueue__c> muleEventQueues = repository.findByIds( new List<String>{ muleEventQueueId } );

        Test.stopTest();

        Assert.isFalse( muleEventQueues.isEmpty(), 'There should not be empty' );
    }

    @isTest
    static void itShouldFindAnEvent() {

        MuleEventQueue__c muleEventQueue = [ SELECT Id, RecordId__c FROM MuleEventQueue__c LIMIT 1 ];

        Set<String> objectsIds = new Set<String>{ muleEventQueue.RecordId__c };

        Test.startTest();

        MuleEventQueueRepository repository = new MuleEventQueueRepository();

        List<MuleEventQueue__c> storedEventQueues = repository.findPendingByRecordsIds( objectsIds, new List<String>() );

        Test.stopTest();

        System.assertEquals( 1, storedEventQueues.size(), 'There should be one event queue' );
    }

    @isTest
    static void itShouldReturnAnAccountPendingIntegration () {

        Test.startTest();

        MuleEventQueueRepository repository = new MuleEventQueueRepository();

        List<MuleEventQueue__c> storedEventQueues = repository.findPendingByIntegrationName( MuleEventQueueFactory.TEST_INTEGRATION );

        Test.stopTest();

        System.assertEquals( 1, storedEventQueues.size(), 'There should be one event queue' );
    }

    @isTest
    static void itShouldFindRetryableEvent() {

        TriggerHandler.bypass('EventQueueTH');

        MuleEventQueue__c retryableEventQueue = MuleEventQueueFactory.newMuleEventQueue();
        retryableEventQueue.Status__c = MuleEventQueueStatus.TECHNICAL_ERROR.name();
        retryableEventQueue.RecordId__c = 'fakeIdRetryable';

        MuleEventQueueFactory.createMuleEventQueue(retryableEventQueue);

        TriggerHandler.clearAllBypasses();

        Set<String> integrationNames = new Set<String>{ retryableEventQueue.MuleIntegrationName__c };

        Test.startTest();

        MuleEventQueueRepository repository = new MuleEventQueueRepository();

        List<MuleEventQueue__c> storedEventQueues = repository.findRetryable( integrationNames );

        Test.stopTest();

        System.assertEquals( 1, storedEventQueues.size(), 'There should be one event queue' );
    }

    @isTest
    static void itShouldFindOldRelatedEvent() {

        TriggerHandler.bypass('EventQueueTH');

        MuleEventQueue__c oldRelatedEventQueue = MuleEventQueueFactory.newMuleEventQueue();
        oldRelatedEventQueue.RecordId__c = 'fakeIdOldRelated';
        MuleEventQueueFactory.createMuleEventQueue(oldRelatedEventQueue);

        oldRelatedEventQueue.Status__c = MuleEventQueueStatus.TECHNICAL_ERROR.name();
        update oldRelatedEventQueue;

        TriggerHandler.clearAllBypasses();

        List<String> objectsIds = new List<String>{ oldRelatedEventQueue.RecordId__c };

        Test.startTest();

        MuleEventQueueRepository repository = new MuleEventQueueRepository();

        List<MuleEventQueue__c> storedEventQueues = repository.findOldRelated( objectsIds, new List<String>() );

        Test.stopTest();

        System.assertEquals( 1, storedEventQueues.size(), 'There should be one event queue' );
    }

    public class MuleEventQueueRepositoryMock extends MuleEventQueueRepository {

        String payload;

        public MuleEventQueueRepositoryMock () {}

        public MuleEventQueueRepositoryMock( String payload ) {
            this.payload = payload;
        }

        public override List<MuleEventQueue__c> findRetryable( Set<String> retryableIntegrationsNames ) {
            return (List<MuleEventQueue__c>) JSON.deserialize( this.payload, List<MuleEventQueue__c>.class );
        }

        public override List<MuleEventQueue__c> findPendingByIntegrationName ( String integrationName ) {
            return (List<MuleEventQueue__c>) JSON.deserialize( this.payload, List<MuleEventQueue__c>.class );
        }

        public override List<SObject> save ( List<SObject> eventQueues ) {
            return eventQueues;
        }
    }

}