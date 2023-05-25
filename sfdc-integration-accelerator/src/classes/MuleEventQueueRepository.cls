/**
 * @description: This class provides collections of stored Event Queues
 * @author: Henrique Bustillos - Everymind
 */
public virtual without sharing class MuleEventQueueRepository extends AbstractRepository {

    public virtual List<MuleEventQueue__c> findPendingByObjectIds (Set<String> objectIds, List<String> ignoredIds) {
        return findPendingByObjectIds( new List<String>(objectIds), ignoredIds );
    }

    public virtual List<MuleEventQueue__c> findPendingByObjectIds (List<String> objectIds, List<String> ignoredIds) {
        return [
            SELECT Id, ObjectId__c, Status__c, CreatedDate, LastModifiedDate
            FROM MuleEventQueue__c
            WHERE ObjectId__c IN :objectIds
            AND Status__c = :MuleEventQueueStatus.PENDING.name()
            AND Id NOT IN :ignoredIds
            ORDER BY CreatedDate ASC
        ];
    }

    public virtual List<MuleEventQueue__c> findPendingByIntegrationName ( String integrationName ) {
        return [
            SELECT Id, ObjectId__c, Status__c, CreatedDate, LastModifiedDate
            FROM MuleEventQueue__c
            WHERE Status__c = :MuleEventQueueStatus.PENDING.name()
            AND MuleIntegration__r.Name = :integrationName
            ORDER BY CreatedDate ASC
        ];
    }

    public virtual List<MuleEventQueue__c> findRetryable ( Set<String> retryableIntegrationsNames ) {
        return [
            SELECT Id, ObjectId__c, Status__c, CreatedDate, LastModifiedDate, RetryCount__c, IsRetryBlocked__c, MuleIntegration__c, MuleIntegration__r.Name
            FROM MuleEventQueue__c
            WHERE Status__c = :MuleEventQueueStatus.TECHNICAL_ERROR.name()
            AND MuleIntegration__r.Name IN :retryableIntegrationsNames
            AND RetryCount__c < 3
            AND IsRetryBlocked__c = false
        ];
    }

    public virtual List<MuleEventQueue__c> findOldRelated ( List<String> objectsIds, List<String> ignoredEventsQueuesIds ) {
        return [
            SELECT Id, ObjectId__c, Status__c, CreatedDate, LastModifiedDate, RetryCount__c, IsRetryBlocked__c, MuleIntegration__c, MuleIntegration__r.Name
            FROM MuleEventQueue__c
            WHERE Status__c != :MuleEventQueueStatus.PENDING.name()
            AND ObjectId__c IN :objectsIds
            AND Id NOT IN :ignoredEventsQueuesIds
            AND IsRetryBlocked__c = false
            AND LastModifiedDate > :Date.today().addDays(-15)
        ];
    }

}