/**
 * @description: This is an exclusive class to process and delegate operations to triggered MuleEventQueue__c records.
 * @author: Henrique Bustillos - Everymind
 */
public with sharing class MuleEventQueueHandler extends TriggerHandler {

    List<MuleEventQueue__c> newQueues;
    Map<Id, MuleEventQueue__c> oldQueuesById;

    MuleEventQueueRepository repository;
    MuleEventQueueValidator validate;
    MuleEventQueueEnricher enricher;
    MuleEventQueueFilter filter;

    public MuleEventQueueHandler() {
        this.newQueues = (List<MuleEventQueue__c>) Trigger.new;
        this.oldQueuesById = (Map<Id, MuleEventQueue__c>) Trigger.oldMap;
        this.repository = new MuleEventQueueRepository();
        this.validate = new MuleEventQueueValidator();
        this.enricher = new MuleEventQueueEnricher();
        this.filter = new MuleEventQueueFilter();
    }

    public override void beforeInsert () {
        this.validateDuplicatedPending();
        this.cancelInactiveIntegrations();
    }

    public override void beforeUpdate () {
        this.validateDuplicatedPending();
        this.incrementRetryCount();
    }

    public override void afterUpdate () {
        this.blockOldRelated();
    }

    public override void afterInsert () {
        this.blockOldRelated();
    }

    private void validateDuplicatedPending () {

        List<MuleEventQueue__c> duplicityValidableMuleEventQueues = this.filter.byDuplicityValidables( this.newQueues, this.oldQueuesById );

        if ( duplicityValidableMuleEventQueues.isEmpty() ) return;

        List<String> ignoredIds = Lists.byField(this.newQueues, 'Id');

        List<MuleEventQueue__c> duplicatedPendingMuleEventQueues = this.repository.findPendingByObjectIds(
            Lists.byField( this.newQueues, 'ObjectId__c' ),
            ignoredIds
        );

        List<String> existentPendingObjectsIds = Lists.byField( duplicatedPendingMuleEventQueues, 'ObjectId__c');

        this.validate.withNotDuplicatedObjectId( duplicityValidableMuleEventQueues, existentPendingObjectsIds );
    }

    private void cancelInactiveIntegrations () {

        List<MuleEventQueue__c> queuesToCancel = this.filter.byInactiveIntegrations( this.newQueues );

        this.enricher.cancel( queuesToCancel );
    }

    private void incrementRetryCount () {

        List<MuleEventQueue__c> retryedMuleEventQueues = this.filter.byRetryedMuleEventQueues( this.newQueues, this.oldQueuesById );

        this.enricher.incrementRetryCount( retryedMuleEventQueues );
    }

    private void blockOldRelated () {

        List<MuleEventQueue__c> newPendingMuleEventQueues = this.filter.byPendingMuleEventQueues( this.newQueues );

        List<MuleEventQueue__c> oldRelatedMuleEventQueues = this.repository.findOldRelated(
            Lists.byField( newPendingMuleEventQueues, 'ObjectId__c' ),
            Lists.byField( newPendingMuleEventQueues, 'Id' )
        );

        this.enricher.blockRetries(oldRelatedMuleEventQueues);
    }
}