/**
 * @description: Class to enrich Mule Event Queues with information. Usually used in a trigger transaction.
 * @author: Henrique Bustillos - Everymind
 */
public without sharing class MuleEventQueueEnricher {

    MuleEventQueueRepository repository;

    public MuleEventQueueEnricher() {
        this.repository = new MuleEventQueueRepository();
    }

    public List<MuleEventQueue__c> cancel ( List<MuleEventQueue__c> muleEventQueues ) {

        for ( MuleEventQueue__c muleEventQueue : muleEventQueues ) {
            this.cancel( muleEventQueue );
        }

        return muleEventQueues;
    }

    public MuleEventQueue__c cancel ( MuleEventQueue__c muleEventQueue ) {

        muleEventQueue.Status__c = MuleEventQueueStatus.CANCELED.name();

        return muleEventQueue;
    }

    public MuleEventQueue__c blockRetry ( MuleEventQueue__c muleEventQueue ) {

        muleEventQueue.IsRetryBlocked__c = true;

        return muleEventQueue;
    }

    public List<MuleEventQueue__c> blockRetries ( List<MuleEventQueue__c> oldRelatedEventQueues ) {

        for ( MuleEventQueue__c oldRelatedEventQueue : oldRelatedEventQueues ) {
            this.blockRetry( oldRelatedEventQueue );
        }

        return this.repository.save( oldRelatedEventQueues );
    }

    public List<MuleEventQueue__c> incrementRetryCount ( List<MuleEventQueue__c> newMuleEventQueues ) {

        for( MuleEventQueue__c muleEventQueue : newMuleEventQueues ) {

            muleEventQueue.RetryCount__c += 1;

            if (muleEventQueue.RetryCount__c >= 3) {
                this.blockRetry( muleEventQueue );
            }
        }

        return newMuleEventQueues;
    }

    public List<MuleEventQueue__c> updatePublishedEvents ( List<MuleIntegrationEvent__e> events ) {

        List<MuleEventQueue__c> muleEventQueues = this.repository.findByIds( Lists.byField( events, 'MuleEventQueueId__c' ) );

        for ( MuleEventQueue__c muleEventQueue : muleEventQueues ) {
            muleEventQueue.Status__c = MuleEventQueueStatus.SENT.name();
            muleEventQueue.ReturnedPayload__c = '';
            muleEventQueue.InternalError__c = '';
        }

        return (List<MuleEventQueue__c>) this.repository.save( muleEventQueues );
    }

    public List<MuleEventQueue__c> withPendingStatus ( List<MuleEventQueue__c> muleEventQueues ) {

        for ( MuleEventQueue__c muleEventQueue : muleEventQueues ) {
            this.withPendingStatus( muleEventQueue );
            this.resetPayloadsAndErrors( muleEventQueue );
        }

        return muleEventQueues;
    }

    public MuleEventQueue__c withPendingStatus ( MuleEventQueue__c muleEventQueue ) {

        muleEventQueue.Status__c = MuleEventQueueStatus.PENDING.name();

        return muleEventQueue;
    }

    public MuleEventQueue__c resetPayloadsAndErrors ( MuleEventQueue__c muleEventQueue ) {

        muleEventQueue.ReturnedPayload__c = '';
        muleEventQueue.Payload__c = '';
        muleEventQueue.InternalError__c = '';

        return muleEventQueue;
    }

    @TestVisible
    private void setRepository ( MuleEventQueueRepository repository ) {
        this.repository = repository;
    }
}