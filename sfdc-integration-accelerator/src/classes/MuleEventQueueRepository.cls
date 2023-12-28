/**
 * @description: This class provides collections of stored Mule Event Queues
 * @author: Henrique Bustillos - Everymind
 */
public virtual inherited sharing class MuleEventQueueRepository extends Repository {

    public virtual List<MuleEventQueue__c> findPendingByRecordsIds (Set<String> recordsIds, List<String> ignoredIds) {
        return this.findPendingByRecordsIds( new List<String>(recordsIds), ignoredIds );
    }

    public virtual List<MuleEventQueue__c> findPendingByRecordsIds (List<String> recordsIds, List<String> ignoredIds) {
        return [
            SELECT Id, RecordId__c, Status__c, CreatedDate, LastModifiedDate
            FROM MuleEventQueue__c
            WHERE RecordId__c IN :recordsIds
            AND Status__c = :MuleEventQueueStatus.PENDING.name()
            AND Id NOT IN :ignoredIds
            ORDER BY CreatedDate ASC
        ];
    }

    public virtual List<MuleEventQueue__c> findPendingByIntegrationName ( String integrationName ) {
        return [
            SELECT Id, RecordId__c, Status__c, CreatedDate, LastModifiedDate, MuleIntegrationName__c
            FROM MuleEventQueue__c
            WHERE Status__c = :MuleEventQueueStatus.PENDING.name()
            AND MuleIntegrationName__c = :integrationName
            ORDER BY CreatedDate ASC
        ];
    }

    public virtual List<MuleEventQueue__c> findRetryable ( Set<String> retryableIntegrationsNames ) {
        return [
            SELECT Id, RecordId__c, Status__c, CreatedDate, LastModifiedDate, RetryCount__c, IsRetryBlocked__c, MuleIntegrationName__c
            FROM MuleEventQueue__c
            WHERE Status__c = :MuleEventQueueStatus.TECHNICAL_ERROR.name()
            AND MuleIntegrationName__c IN :retryableIntegrationsNames
            AND RetryCount__c < 3
            AND IsRetryBlocked__c = false
        ];
    }

    public virtual List<MuleEventQueue__c> findOldRelated ( List<String> objectsIds, List<String> ignoredEventsQueuesIds ) {
        return [
            SELECT Id, RecordId__c, Status__c, CreatedDate, LastModifiedDate, RetryCount__c, IsRetryBlocked__c, MuleIntegrationName__c
            FROM MuleEventQueue__c
            WHERE Status__c != :MuleEventQueueStatus.PENDING.name()
            AND RecordId__c IN :objectsIds
            AND Id NOT IN :ignoredEventsQueuesIds
            AND IsRetryBlocked__c = false
            AND LastModifiedDate > :Date.today().addDays(-15)
        ];
    }

    public virtual List<MuleEventQueue__c> findByIds ( List<String> ids ) {
        return [
            SELECT Id, Status__c
            FROM MuleEventQueue__c
            WHERE Id IN :ids
        ];
    }

}