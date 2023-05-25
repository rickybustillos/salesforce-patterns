/**
 * @description: Class to enrich Mule Event Queues with information. Generally used in a trigger transaction.
 * @author: Henrique Bustillos - Everymind
 */
public without sharing class MuleEventQueueEnricher {

    MuleEventQueueRepository repository;

    public MuleEventQueueEnricher() {
        this.repository = new MuleEventQueueRepository();
    }

    public List<MuleEventQueue__c> cancel ( List<MuleEventQueue__c> eventQueues ) {

        for ( MuleEventQueue__c eventQueue : eventQueues ) {
            this.cancel( eventQueue );
        }

        return eventQueues;
    }

    public MuleEventQueue__c cancel ( MuleEventQueue__c eventQueue ) {

        eventQueue.Status__c = MuleEventQueueStatus.CANCELED.name();

        return eventQueue;
    }

    public MuleEventQueue__c blockRetry ( MuleEventQueue__c eventQueue ) {

        eventQueue.IsRetryBlocked__c = true;

        return eventQueue;
    }

    public List<MuleEventQueue__c> blockRetries ( List<MuleEventQueue__c> oldRelatedEventQueues ) {

        for ( MuleEventQueue__c oldRelatedEventQueue : oldRelatedEventQueues ) {
            this.blockRetry( oldRelatedEventQueue );
        }

        return this.repository.save( oldRelatedEventQueues );
    }

    public List<MuleEventQueue__c> incrementRetryCount ( List<MuleEventQueue__c> newEventQueues ) {

        for( MuleEventQueue__c eventQueue : newEventQueues ) {

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