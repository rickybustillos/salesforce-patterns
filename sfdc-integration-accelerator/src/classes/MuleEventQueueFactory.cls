/**
 * @description: This class is a factory for Event Queue objects to use exclusively in test contexts.
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleEventQueueFactory {

    public static final String TEST_INTEGRATION = 'TEST_INTEGRATION';

    public static MuleEventQueue__c newMuleEventQueue( String recordId ) {
        return new MuleEventQueue__c (
            Status__c = MuleEventQueueStatus.PENDING.name()
            , MuleIntegrationName__c = TEST_INTEGRATION
            , RecordId__c = recordId
            , RetryCount__c = 0
            , IsRetryBlocked__c = false
        );
    }

    public static MuleEventQueue__c newMuleEventQueue() {
        return newMuleEventQueue( 'fakeId' );
    }

    public static MuleEventQueue__c createMuleEventQueue( String recordId ) {
        return createMuleEventQueue( newMuleEventQueue( recordId ) );
    }

    public static MuleEventQueue__c createMuleEventQueue() {
        return createMuleEventQueue( newMuleEventQueue() );
    }

    public static MuleEventQueue__c createMuleEventQueue( MuleEventQueue__c muleEventQueue ) {
        insert muleEventQueue;
        return muleEventQueue;
    }

    public static MuleEventQueue__c fromJson ( String payload ) {
        return (MuleEventQueue__c) JSON.deserialize( payload, MuleEventQueue__c.class );
    }

    public static List<MuleEventQueue__c> fromJsonArray ( String payload ) {
        return (List<MuleEventQueue__c>) JSON.deserialize( payload, List<MuleEventQueue__c>.class );
    }
}