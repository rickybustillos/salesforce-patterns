/**
 * @description: Filter class for MuleEventQueue collections
 * @author: Henrique Bustillos - Everymind
 */
public without sharing class MuleEventQueueFilter {

    public List<MuleEventQueue__c> byInactiveIntegrations ( List<MuleEventQueue__c> eventQueues, Map<String, MuleIntegration__c> activeIntegrationsById ) {

        List<MuleEventQueue__c> eventQueuesToCancel = new List<MuleEventQueue__c>();

        for ( MuleEventQueue__c eventQueue : eventQueues ) {

            if ( activeIntegrationsById.containsKey( eventQueue.MuleIntegration__c ) ) continue;

            eventQueuesToCancel.add( eventQueue );
        }

        return eventQueuesToCancel;
    }

    public List<MuleEventQueue__c> byDuplicityValidables ( List<MuleEventQueue__c> newMuleEventQueues, Map<Id, MuleEventQueue__c> oldMuleEventQueuesById ) {

        if ( oldMuleEventQueuesById == null || oldMuleEventQueuesById.isEmpty() ) return newMuleEventQueues;

        List<MuleEventQueue__c> validableMuleEventQueues = new List<MuleEventQueue__c>();

        for ( MuleEventQueue__c newMuleEventQueue : newMuleEventQueues ) {

            if ( this.isDuplicityValidable( newMuleEventQueue, oldMuleEventQueuesById.get( newMuleEventQueue.Id ) ) ) {

                validableMuleEventQueues.add( newMuleEventQueue );
            }
        }

        return validableMuleEventQueues;
    }

    private Boolean isDuplicityValidable ( MuleEventQueue__c eventQueue, MuleEventQueue__c oldMuleEventQueue ) {

        Boolean newIsNotPending = eventQueue.Status__c != MuleEventQueueStatus.PENDING.name();

        Boolean oldIsNotPending = oldMuleEventQueue.Status__c != MuleEventQueueStatus.PENDING.name();

        if ( newIsNotPending && oldIsNotPending ) return false;

        return true;
    }

    public List<MuleEventQueue__c> byPendingMuleEventQueues ( List<MuleEventQueue__c> newMuleEventQueues ) {

        List<MuleEventQueue__c> pendingMuleEventQueues = new List<MuleEventQueue__c>();

        for ( MuleEventQueue__c newMuleEventQueue : newMuleEventQueues ) {

            if ( newMuleEventQueue.Status__c != MuleEventQueueStatus.PENDING.name() ) continue;

            pendingMuleEventQueues.add( newMuleEventQueue );
        }

        return pendingMuleEventQueues;
    }

    public List<MuleEventQueue__c> byRetryedMuleEventQueues ( List<MuleEventQueue__c> newMuleEventQueues, Map<Id, MuleEventQueue__c> oldMuleEventQueuesById ) {

        List<MuleEventQueue__c> retryedMuleEventQueues = new List<MuleEventQueue__c>();

        for( MuleEventQueue__c eventQueue : newMuleEventQueues ) {

            MuleEventQueue__c oldMuleEventQueue = oldMuleEventQueuesById.get( eventQueue.Id );

            if ( MuleEventQueueStatus.TECHNICAL_ERROR.name() != oldMuleEventQueue.Status__c ) continue;

            if ( MuleEventQueueStatus.TECHNICAL_ERROR.name() == eventQueue.Status__c ) continue;

            retryedMuleEventQueues.add( eventQueue );
        }

        return retryedMuleEventQueues;
    }
}