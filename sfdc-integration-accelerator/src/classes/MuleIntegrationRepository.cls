/**
 * @description: Class to provide MuleIntegration__c custom metadatas
 * @author: Henrique Bustillos - Everymind
 */
public virtual without sharing class MuleIntegrationRepository {

    public virtual Map<String, MuleIntegration__c> findActives () {

            List<MuleIntegration__c> integrations = [
                SELECT
                    Id
                    , Name
                    , ClassName__c
                    , IsActive__c
                    , IsRetryable__c
                FROM MuleIntegration__c
                WHERE IsActive__c = true
            ];

            return new Map<String, MuleIntegration__c>( integrations );
    }

    /*
     * @description: key is MuleIntegration__c.Name
     */
    public virtual Map<String, MuleIntegration__c> findActiveRetryable () {

        List<MuleIntegration__c> integrations = [
            SELECT
                Name
                , ClassName__c
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