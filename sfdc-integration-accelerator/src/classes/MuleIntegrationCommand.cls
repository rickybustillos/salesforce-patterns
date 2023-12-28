/**
 * @description: Abstract command class that contains common methods for Mule Integration commands
 * @author: Henrique Bustillos - Everymind
 */
public abstract class MuleIntegrationCommand {

    protected MuleIntegration__mdt integration;

    protected MuleEventQueueRepository muleEventQueueRepository;

    protected MuleIntegrationRepository muleIntegrationRepository;

    protected MuleIntegrationValidator validate;

    public MuleIntegrationCommand ( MuleIntegrationType integrationType ) {
        this();
        this.setIntegration( integrationType );
    }

    protected MuleIntegrationCommand () {
        this.muleEventQueueRepository = new MuleEventQueueRepository();
        this.muleIntegrationRepository = new MuleIntegrationRepository();
        this.validate = new MuleIntegrationValidator();
    }

    @TestVisible
    private void setIntegration ( MuleIntegrationType integrationType ) {

        this.integration = this.muleIntegrationRepository.findByIntegrationName( integrationType );

        this.validate.existantMetadata( this.integration );
        this.validate.objectsNotEmpty( this.integration );
        this.validate.objectsFieldsNotEmpty( this.integration.MuleIntegrationObjects__r );
    }

    public virtual List<Database.SaveResult> execute () {
        return this.execute( this.muleEventQueueRepository.findPendingByIntegrationName( this.integration.DeveloperName ) );
    }

    public abstract List<Database.SaveResult> execute (List<MuleEventQueue__c> eventQueues);

    protected void updateEventQueuesWithError(List<MuleEventQueue__c> eventQueues, String message) {

        for ( MuleEventQueue__c eventQueue : eventQueues ) {
            this.enrichEventQueueWithError( eventQueue, message );
        }

        this.muleEventQueueRepository.save(eventQueues);
    }

    protected Map<String, String> getFieldsByObjectName () {

        Map<String, String> fieldsByObjectName = new Map<String, String>();

        for ( MuleIntegrationObject__mdt integrationObject : this.integration.MuleIntegrationObjects__r ) {

            fieldsByObjectName.put(
                integrationObject.SObjectType__c,
                integrationObject.Fields__c
            );
        }

        return fieldsByObjectName;
    }

    protected MuleEventQueue__c enrichEventQueueWithError ( MuleEventQueue__c eventQueue, String message ) {

        String errorPayload = JSON.serializePretty( message );

        eventQueue.Status__c = MuleEventQueueStatus.ERROR.name();
        eventQueue.InternalError__c = errorPayload;

        return eventQueue;
    }

    protected List<MuleEventQueue__c> withPayloadOrError ( List<MuleEventQueue__c> eventQueues, Map<String, Object> payloadByObjectId ) {

        for ( MuleEventQueue__c eventQueue : eventQueues ) {

            if ( !payloadByObjectId.containsKey( eventQueue.RecordId__c ) ) {
                eventQueue = this.enrichEventQueueWithError( eventQueue, 'Record in RecordId__c field not found.');
                continue;
            }

            eventQueue.Payload__c = JSON.serialize( payloadByObjectId.get( eventQueue.RecordId__c ) );
        }

        return eventQueues;
    }

    protected MuleIntegrationEvent__e buildEvent ( MuleEventQueue__c eventQueue ) {

        return new MuleIntegrationEvent__e (
            MuleIntegrationName__c = eventQueue.MuleIntegrationName__c
            , MuleEventQueueId__c = eventQueue.Id
            , Payload__c = eventQueue.Payload__c
        );
    }

    protected List<Database.SaveResult> publishEvents ( List<MuleEventQueue__c> eventQueues ) {

        List<MuleIntegrationEvent__e> eventsToPublish = new List<MuleIntegrationEvent__e>();

        for ( MuleEventQueue__c eventQueue : eventQueues ) {

            if ( eventQueue.Status__c == MuleEventQueueStatus.ERROR.name() ) continue;

            eventsToPublish.add( this.buildEvent( eventQueue ) );
        }

        this.muleEventQueueRepository.save( eventQueues );

        if ( eventsToPublish.isEmpty() ) return null;

        return EventBus.publish( eventsToPublish );
    }

    @TestVisible
    private void setMuleEventQueueRepository ( MuleEventQueueRepository muleEventQueueRepository ) {
        this.muleEventQueueRepository = muleEventQueueRepository;
    }

    @TestVisible
    private void setMuleIntegrationRepository ( MuleIntegrationRepository muleIntegrationRepository ) {
        this.muleIntegrationRepository = muleIntegrationRepository;
    }
}