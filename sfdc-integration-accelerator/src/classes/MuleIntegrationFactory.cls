/**
 * @description: This class is a factory for Mule Integrations to use exclusively in test contexts.
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleIntegrationFactory {

    public static final String TEST_INTEGRATION = 'TEST_INTEGRATION';

    public static MuleIntegration__c newMuleIntegration () {
        return new MuleIntegration__c (
            Name = TEST_INTEGRATION
            , IsActive__c = true
            , IsSchedulable__c = true
            , IsRetryable__c = true
            , ClassName__c = 'MuleIntegrationCommandTest.MuleIntegrationCommandMock'
        );
    }

    public static MuleIntegration__c createMuleIntegration () {
        return createMuleIntegration( newMuleIntegration() );
    }

    public static MuleIntegration__c createMuleIntegration (MuleIntegration__c integration) {
        insert integration;
        return integration;
    }

    public static MuleIntegration__c fromJson ( String payload ) {
        return (MuleIntegration__c) JSON.deserialize( payload, MuleIntegration__c.class );
    }

    public static List<MuleIntegration__c> fromJsonArray ( String payload ) {
        return (List<MuleIntegration__c>) JSON.deserialize( payload, List<MuleIntegration__c>.class );
    }
}