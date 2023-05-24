/**
 * @description: Class to provide MuleIntegration__c custom metadatas
 * @author: Henrique Bustillos - Everymind
 */
public virtual without sharing class MuleIntegrationRepository {

    /*
     * @description: key is MuleIntegration__c.Name
     */
    public virtual Map<String, MuleIntegration__c> findActiveRetryable () {

        List<MuleIntegration__c> integrations = [
            SELECT
                ClassName__c
                , Name
                , IsActive__c
                , IsRetryable__c
            FROM MuleIntegration__c
            WHERE IsRetryable__c = true
            AND IsActive__c = true
        ];

        Map<String, MuleIntegration__c> integrationsByName = (Map<String, MuleIntegration__c>) Maps.indexBy('Name', integrations);

        return integrationsByName;
    }
}