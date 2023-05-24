/**
 * @description: Class to provide MuleIntegrationObject__c custom metadatas
 * @author: Henrique Bustillos - Everymind
 */
public virtual without sharing class MuleIntegrationObjectRepository extends Repository {

    public virtual Map<String, MuleIntegrationObject__c> findByDeveloperNames ( List<String> developerNames ) {

        List<MuleIntegrationObject__c> eventObjectsFields = [
            SELECT Fields__c, DeveloperName
            FROM MuleIntegrationObject__c
            WHERE DeveloperName = :developerNames
        ];

        Map<String, MuleIntegrationObject__c> eventObjectsFieldsByDeveloperName = new Map<String, MuleIntegrationObject__c>();

        for ( MuleIntegrationObject__c eventObjectFields : eventObjectsFields ) {
            eventObjectsFieldsByDeveloperName.put(eventObjectFields.DeveloperName, eventObjectFields);
        }

        return eventObjectsFieldsByDeveloperName;
    }
}