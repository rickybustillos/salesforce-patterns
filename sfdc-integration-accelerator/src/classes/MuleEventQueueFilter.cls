/**
 * @description: Filter class for MuleEventQueue collections
 * @author: Henrique Bustillos - Everymind
 */
public without sharing class MuleEventQueueFilter {

    public List<MuleEventQueue__c> byInactiveIntegrations ( List<MuleEventQueue__c> muleEventQueues, Map<String, MuleIntegration__mdt> integrations ) {

        List<MuleEventQueue__c> inactiveEventQueues = new List<MuleEventQueue__c>();

        for ( MuleEventQueue__c muleEventQueue : muleEventQueues ) {

            if ( !integrations.containsKey( muleEventQueue.MuleIntegrationName__c ) ) continue;

            if ( integrations.get( muleEventQueue.MuleIntegrationName__c ).IsActive__c ) continue;

            inactiveEventQueues.add( muleEventQueue );
        }

        return inactiveEventQueues;
    }

    public List<MuleEventQueue__c> byDuplicityValidables ( List<MuleEventQueue__c> newEventQueues, Map<Id, MuleEventQueue__c> oldEventQueuesById ) {

        if ( oldEventQueuesById == null || oldEventQueuesById.isEmpty() ) return newEventQueues;

        List<MuleEventQueue__c> validableEventQueues = new List<MuleEventQueue__c>();

        for ( MuleEventQueue__c newEventQueue : newEventqueues ) {

            if ( this.isDuplicityValidable( newEventQueue, oldEventQueuesById.get( newEventQueue.Id ) ) ) {

                validableEventQueues.add( newEventQueue );
            }
        }

        return validableEventQueues;
    }

    private Boolean isDuplicityValidable ( MuleEventQueue__c muleEventQueue, MuleEventQueue__c oldEventQueue ) {

        Boolean newIsNotPending = muleEventQueue.Status__c != MuleEventQueueStatus.PENDING.name();

        Boolean oldIsNotPending = oldEventQueue.Status__c != MuleEventQueueStatus.PENDING.name();

        if ( newIsNotPending && oldIsNotPending ) return false;

        return true;
    }

    public List<MuleEventQueue__c> byPendingEventQueues ( List<MuleEventQueue__c> newEventQueues ) {

        List<MuleEventQueue__c> pendingEventQueues = new List<MuleEventQueue__c>();

        for ( MuleEventQueue__c newEventQueue : newEventqueues ) {

            if ( newEventQueue.Status__c != MuleEventQueueStatus.PENDING.name() ) continue;

            pendingEventQueues.add( newEventQueue );
        }

        return pendingEventQueues;
    }

    public List<MuleEventQueue__c> byRetryedEventQueues ( List<MuleEventQueue__c> newEventQueues, Map<Id, MuleEventQueue__c> oldEventQueuesById ) {

        List<MuleEventQueue__c> retryedEventQueues = new List<MuleEventQueue__c>();

        for( MuleEventQueue__c muleEventQueue : newEventQueues ) {

            MuleEventQueue__c oldEventQueue = oldEventQueuesById.get( muleEventQueue.Id );

            if ( !MuleEventQueueStatus.TECHNICAL_ERROR.name().contains( oldEventQueue.Status__c )  ) continue;

            if ( MuleEventQueueStatus.TECHNICAL_ERROR.name().contains( muleEventQueue.Status__c ) ) continue;

            retryedEventQueues.add( muleEventQueue );
        }

        return retryedEventQueues;
    }

    public List<MuleEventQueue__c> byEmptyStatus ( List<MuleEventQueue__c> muleEventQueues ) {

        List<MuleEventQueue__c> newMuleEventQueues = new List<MuleEventQueue__c>();

        for ( MuleEventQueue__c muleEventQueue : muleEventQueues ) {

            if ( muleEventQueue.Status__c != null ) continue;

            newMuleEventQueues.add( muleEventQueue );
        }

        return newMuleEventQueues;
    }
}