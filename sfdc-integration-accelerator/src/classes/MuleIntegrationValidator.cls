/**
 * @description: Responsible to Validate mule integration metadatas
 * @author: Henrique Bustillos - Everymind
 */
public without sharing class MuleIntegrationValidator {

    public void emptyRecords ( List<SObject> records ) {

        if ( records.isEmpty() ) {

            throw new MuleIntegrationException('No target records to process');
        }
    }

    public void emptyRecords ( Map<String, Object> records ) {

        if ( records.isEmpty() ) {

            throw new MuleIntegrationException('No target records to process');
        }
    }

    public void existantMetadata ( MuleIntegration__mdt integration ) {

        if ( integration == null ) {

            throw new MuleIntegrationException('Integration metadata does not exist');
        }
    }

    public void objectsNotEmpty ( MuleIntegration__mdt integration ) {

        if ( integration.MuleIntegrationObjects__r.isEmpty() ) {

            throw new MuleIntegrationException('Integration metadata does not have objects associated');
        }
    }

    public void objectsFieldsNotEmpty ( List<MuleIntegrationObject__mdt> integrationObjects ) {

        for ( MuleIntegrationObject__mdt integrationObject : integrationObjects ) {

            if ( integrationObject.Fields__c == null || integrationObject.Fields__c == '' ) {

                throw new MuleIntegrationException('Integration metadata object does not have fields filled');
            }
        }
    }
}