/**
 * @description: This class is a factory for Event Queue objects to use exclusively in test contexts.
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleEventQueueFactory {

    public static MuleEventQueue__c newMuleEventQueue () {
        return new MuleEventQueue__c (
            IsRetryBlocked__c = false
            , RetryCount__c = 0
            , Status__c = MuleEventQueueStatus.PENDING.name()
            , ObjectId__c = 'fakeId'
        );
    }

    public static MuleEventQueue__c newMuleEventQueue ( MuleIntegration__c integration ) {

        MuleEventQueue__c eventQueue = newMuleEventQueue();
        eventQueue.MuleIntegration__c = integration.Id;

        return eventQueue;
    }

    public static MuleEventQueue__c createMuleEventQueue ( MuleIntegration__c integration ) {
        return createMuleEventQueue( newMuleEventQueue( integration ) );
    }

    public static MuleEventQueue__c createMuleEventQueue () {
        return createMuleEventQueue( newMuleEventQueue( MuleIntegrationFactory.createMuleIntegration() ) );
    }

    public static MuleEventQueue__c createMuleEventQueue (MuleEventQueue__c eventQueue) {
        insert eventQueue;
        return eventQueue;
    }

    public static MuleEventQueue__c fromJson ( String payload ) {
        return (MuleEventQueue__c) JSON.deserialize( payload, MuleEventQueue__c.class );
    }

    public static List<MuleEventQueue__c> fromJsonArray ( String payload ) {
        return (List<MuleEventQueue__c>) JSON.deserialize( payload, List<MuleEventQueue__c>.class );
    }
}