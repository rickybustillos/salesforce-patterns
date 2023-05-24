/**
 * @description: Abstract command class that contains common methods for Mule Integration commands
 * @author: Henrique Bustillos - Everymind
 */
public abstract class MuleIntegrationCommand {

    protected MuleEventQueueRepository muleEventQueueRepository;

    public MuleIntegrationCommand() {
        this.muleEventQueueRepository = new MuleEventQueueRepository();
    }

    public abstract void execute (List<MuleEventQueue__c> eventQueues);

    protected void updateEventQueuesWithError(List<MuleEventQueue__c> eventQueues, String message) {

        for ( MuleEventQueue__c eventQueue : eventQueues ) {
            this.enrichEventQueueWithError( eventQueue, message );
        }

        this.muleEventQueueRepository.save(eventQueues);
    }

    protected MuleEventQueue__c enrichEventQueueWithError ( MuleEventQueue__c eventQueue, String message ) {

        String errorPayload = JSON.serializePretty( message );

        eventQueue.Status__c = EventQueueStatus.ERROR.name();
        eventQueue.InternalError__c = errorPayload;

        return eventQueue;
    }

    protected MuleIntegrationEvent__e buildEvent ( MuleEventQueue__c eventQueue, String integrationName, String payload ) {

        return new MuleIntegrationEvent__e (
            IntegrationName__c = integrationName
            , EventQueueId__c = eventQueue.Id
            , Payload__c = payload
        );
    }

    public void setMuleEventQueueRepository ( MuleEventQueueRepository muleEventQueueRepository ) {
        this.muleEventQueueRepository = muleEventQueueRepository;
    }
}