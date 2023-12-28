/**
 * @description: This is an exclusive class to process triggered MuleEventQueue__c records.
 * @author: Henrique Bustillos - Everymind
 */
public with sharing class MuleEventQueueHandler extends TriggerHandler {

    static final Map<String, MuleIntegration__mdt> MULE_INTEGRATIONS = MuleIntegration__mdt.getAll();

    private List<MuleEventQueue__c> newEventQueues;
    private Map<Id, MuleEventQueue__c> oldEventQueuesById;

    private MuleEventQueueRepository repository;

    private MuleEventQueueValidator validate;

    private MuleEventQueueEnricher enricher;

    private MuleEventQueueFilter filter;

    public MuleEventQueueHandler() {
        this.newEventQueues = (List<MuleEventQueue__c>) Trigger.new;
        this.oldEventQueuesById = (Map<Id, MuleEventQueue__c>) Trigger.oldMap;
        this.repository = new MuleEventQueueRepository();
        this.validate = new MuleEventQueueValidator();
        this.enricher = new MuleEventQueueEnricher();
        this.filter = new MuleEventQueueFilter();
    }

    public override void beforeInsert () {
        this.setPendingStatus();
        this.validateDuplicatedPending();
        this.cancelInactiveIntegrations();
    }

    public override void beforeUpdate () {
        this.setPendingStatus();
        this.validateDuplicatedPending();
        this.incrementRetryCount();
    }

    public override void afterUpdate () {
        this.blockOldRelated();
    }

    public override void afterInsert () {
        this.blockOldRelated();
    }

    private void setPendingStatus() {

        List<MuleEventQueue__c> newPendingEventQueues = this.filter.byEmptyStatus( this.newEventQueues );

        this.enricher.withPendingStatus( newPendingEventQueues );
    }

    private void validateDuplicatedPending() {

        List<String> ignoredIds = Lists.byField(this.newEventQueues, 'Id');

        List<MuleEventQueue__c> duplicityValidableEventQueues = this.filter.byDuplicityValidables( this.newEventQueues, this.oldEventQueuesById );

        if (duplicityValidableEventQueues.isEmpty()) return;

        List<MuleEventQueue__c> existentPendingEventQueues = this.repository.findPendingByRecordsIds(
            Lists.byField( this.newEventQueues, 'RecordId__c' ),
            ignoredIds
        );

        List<String> existentPendingObjectsIds = Lists.byField( existentPendingEventQueues, 'RecordId__c');

        this.validate.withNotDuplicatedObjectId( duplicityValidableEventQueues, existentPendingObjectsIds );
    }

    private void cancelInactiveIntegrations() {

        List<MuleEventQueue__c> queuesToCancel = this.filter.byInactiveIntegrations( this.newEventQueues, MULE_INTEGRATIONS );

        this.enricher.cancel( queuesToCancel );
    }

    private void incrementRetryCount() {

        List<MuleEventQueue__c> retryedEventQueues = this.filter.byRetryedEventQueues( this.newEventQueues, this.oldEventQueuesById );

        this.enricher.incrementRetryCount( retryedEventQueues );
    }

    private void blockOldRelated() {

        List<MuleEventQueue__c> newPendingEventQueues = this.filter.byPendingEventQueues( this.newEventQueues );

        List<MuleEventQueue__c> oldRelatedEventQueues = this.repository.findOldRelated(
            Lists.byField( newPendingEventQueues, 'RecordId__c' ),
            Lists.byField( newPendingEventQueues, 'Id' )
        );

        this.enricher.blockRetries(oldRelatedEventQueues);
    }
}