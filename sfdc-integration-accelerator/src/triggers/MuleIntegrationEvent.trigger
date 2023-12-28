/**
 * @description: Trigger for MuleIntegrationEvent Platform Event
 * @author: Henrique Bustillos - Everymind
 */
trigger MuleIntegrationEvent on MuleIntegrationEvent__e (after insert) {
    new MuleEventQueueEnricher().updatePublishedEvents( (List<MuleIntegrationEvent__e>) Trigger.new );
}