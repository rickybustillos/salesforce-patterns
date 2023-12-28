/**
 * @description: Class to provide MuleIntegration__mdt custom metadatas
 * @author: Henrique Bustillos - Everymind
 */
public virtual without sharing class MuleIntegrationRepository {

    /**
     * @description: find all active retryable integrations indexed by DeveloperName
     */
    public virtual Map<String, MuleIntegration__mdt> findActiveRetryable () {

        List<MuleIntegration__mdt> integrations = [
            SELECT
                ApexClassName__c
                , DeveloperName
                , IsActive__c
                , IsRetryable__c
            FROM MuleIntegration__mdt
            WHERE IsRetryable__c = true
            AND IsActive__c = true
        ];

        if ( !integrations.isEmpty() ) return (Map<String, MuleIntegration__mdt>) Maps.indexBy('DeveloperName', integrations);

        return new Map<String, MuleIntegration__mdt>();
    }

    public virtual MuleIntegration__mdt findByIntegrationName ( MuleIntegrationType integrationType ) {

        List<MuleIntegration__mdt> integrations = [
            SELECT
                ApexClassName__c
                , DeveloperName
                , IsActive__c
                , IsRetryable__c
                , (SELECT Id, Fields__c, SObjectType__c, DeveloperName FROM MuleIntegrationObjects__r)
            FROM MuleIntegration__mdt
            WHERE DeveloperName = :integrationType.name()
        ];

        return integrations.isEmpty() ? null : integrations[0];
    }
}