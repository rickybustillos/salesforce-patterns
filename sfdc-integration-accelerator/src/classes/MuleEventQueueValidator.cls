/**
 * @description: Validator class for MuleEventQueues records
 * @author: Henrique Bustillos - Everymind
 */
public without sharing class MuleEventQueueValidator {

    public void withNotDuplicatedObjectId ( List<MuleEventQueue__c> eventQueues, List<String> existentPendingIds  ) {

        Map<String, MuleEventQueue__c> eventQueuesByObjectId = new Map<String, MuleEventQueue__c>();

        for ( MuleEventQueue__c eventQueue : eventQueues ) {

            if ( this.isDuplicated( eventQueue, existentPendingIds ) ) {
                eventQueue.addError( 'There is already a pending event queued for this object.' );
            }

            if ( eventQueuesByObjectId.containsKey( eventQueue.ObjectId__c ) ) {
                eventQueue.addError( 'There is already a pending event queued for this object.' );
                continue;
            }

            eventQueuesByObjectId.put( eventQueue.ObjectId__c, eventQueue );
        }
    }

    private Boolean isDuplicated ( MuleEventQueue__c eventQueue, List<String> existentPendingIds ) {
        return existentPendingIds.contains( eventQueue.ObjectId__c );
    }
}