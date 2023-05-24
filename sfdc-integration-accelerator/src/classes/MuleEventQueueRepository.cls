/**
 * @description: This class provides collections of stored Event Queues
 * @author: Henrique Bustillos - Everymind
 */
public virtual inherited sharing class MuleEventQueueRepository extends Repository {

    public virtual List<EventQueue__c> findPendingByObjectIds (Set<String> objectIds, List<String> ignoredIds) {
        return findPendingByObjectIds( new List<String>(objectIds), ignoredIds );
    }

    public virtual List<EventQueue__c> findPendingByObjectIds (List<String> objectIds, List<String> ignoredIds) {
        return [
            SELECT Id, ObjectId__c, Status__c, CreatedDate, LastModifiedDate
            FROM EventQueue__c
            WHERE ObjectId__c IN :objectIds
            AND Status__c = :EventQueueStatus.PENDING.name()
            AND Id NOT IN :ignoredIds
            ORDER BY CreatedDate ASC
        ];
    }

    public virtual List<EventQueue__c> findPendingByIntegrationName ( String integrationName ) {
        return [
            SELECT Id, ObjectId__c, Status__c, CreatedDate, LastModifiedDate
            FROM EventQueue__c
            WHERE Status__c = :EventQueueStatus.PENDING.name()
            AND EventIntegrationName__c = :integrationName
            ORDER BY CreatedDate ASC
        ];
    }

    public virtual List<EventQueue__c> findRetryable ( Set<String> retryableIntegrationsNames ) {
        return [
            SELECT Id, ObjectId__c, Status__c, CreatedDate, LastModifiedDate, RetryCount__c, IsRetryBlocked__c, EventIntegrationName__c
            FROM EventQueue__c
            WHERE Status__c = :EventQueueStatus.TECHNICAL_ERROR.name()
            AND EventIntegrationName__c IN :retryableIntegrationsNames
            AND RetryCount__c < 3
            AND IsRetryBlocked__c = false
        ];
    }

    public virtual List<EventQueue__c> findOldRelated ( List<String> objectsIds, List<String> ignoredEventsQueuesIds ) {
        return [
            SELECT Id, ObjectId__c, Status__c, CreatedDate, LastModifiedDate, RetryCount__c, IsRetryBlocked__c, EventIntegrationName__c
            FROM EventQueue__c
            WHERE Status__c != :EventQueueStatus.PENDING.name()
            AND ObjectId__c IN :objectsIds
            AND Id NOT IN :ignoredEventsQueuesIds
            AND IsRetryBlocked__c = false
            AND LastModifiedDate > :Date.today().addDays(-15)
        ];
    }

}