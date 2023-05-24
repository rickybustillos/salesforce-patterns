/**
 * @description: Class to enrich Mule Event Queues with information. Generally used in a trigger transaction.
 * @author: Henrique Bustillos - Everymind
 */
public without sharing class EventQueueEnricher {

    MuleEventQueueRepository repository;

    public EventQueueEnricher() {
        this.repository = new MuleEventQueueRepository();
    }

    public List<EventQueue__c> cancel ( List<EventQueue__c> eventQueues ) {

        for ( EventQueue__c eventQueue : eventQueues ) {
            this.cancel( eventQueue );
        }

        return eventQueues;
    }

    public EventQueue__c cancel ( EventQueue__c eventQueue ) {

        eventQueue.Status__c = EventQueueStatus.CANCELED.name();

        return eventQueue;
    }

    public EventQueue__c blockRetry ( EventQueue__c eventQueue ) {

        eventQueue.IsRetryBlocked__c = true;

        return eventQueue;
    }

    public List<EventQueue__c> blockRetries ( List<EventQueue__c> oldRelatedEventQueues ) {

        for ( EventQueue__c oldRelatedEventQueue : oldRelatedEventQueues ) {
            this.blockRetry( oldRelatedEventQueue );
        }

        return this.repository.save( oldRelatedEventQueues );
    }

    public List<EventQueue__c> incrementRetryCount ( List<EventQueue__c> newEventQueues ) {

        for( EventQueue__c eventQueue : newEventQueues ) {

            eventQueue.RetryCount__c += 1;

            if (eventQueue.RetryCount__c >= 3) {
                this.blockRetry( eventQueue );
            }
        }

        return newEventQueues;
    }

    @TestVisible
    private void setRepository ( MuleEventQueueRepository repository ) {
        this.repository = repository;
    }
}