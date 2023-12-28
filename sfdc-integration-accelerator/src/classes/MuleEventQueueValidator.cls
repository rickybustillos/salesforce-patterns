/**
 * @description: Validator class for EventQueues records
 * @author: Henrique Bustillos - Everymind
 */
public without sharing class MuleEventQueueValidator {

    public void withNotDuplicatedObjectId ( List<MuleEventQueue__c> muleEventQueues, List<String> existentPendingIds  ) {

        Map<String, MuleEventQueue__c> eventQueuesByObjectId = new Map<String, MuleEventQueue__c>();

        for ( MuleEventQueue__c muleEventQueue : muleEventQueues ) {

            if ( this.isDuplicated( muleEventQueue, existentPendingIds ) ) {
                muleEventQueue.addError( 'There is already a pending event queued for this object.' );
            }

            if ( eventQueuesByObjectId.containsKey( muleEventQueue.RecordId__c ) ) {
                muleEventQueue.addError( 'There is already a pending event queued for this object.' );
                continue;
            }

            eventQueuesByObjectId.put( muleEventQueue.RecordId__c, muleEventQueue );
        }
    }

    private Boolean isDuplicated ( MuleEventQueue__c muleEventQueue, List<String> existentPendingIds ) {
        return existentPendingIds.contains( muleEventQueue.RecordId__c );
    }
}