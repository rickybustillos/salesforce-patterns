/**
 * @description: Factory class to provide MuleIntegration__mdt for tests
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleIntegrationFactory {

    public static String getIntegrationPayload() {
        return getIntegrationPayload('');
    }

    public static String getIntegrationPayload( String integrationObjects ) {
        return '{ "ApexClassName__c":"MuleIntegrationCommandTest.MuleIntegrationCommandMock", "IsActive__c": false, "Label": "'+ MuleEventQueueFactory.TEST_INTEGRATION +'", '
            + '"IsRetryable__c":true, "MasterLabel":"'+ MuleEventQueueFactory.TEST_INTEGRATION +'", '
            + '"SystemModstamp":"2023-01-01T00:00:00.000+0000", "Language":"pt_BR", "IsSchedulable__c":true, '
            + '"Description__c":"Test integration metadata.", "QualifiedApiName":"'+ MuleEventQueueFactory.TEST_INTEGRATION +'", '
            + '"DeveloperName":"'+ MuleEventQueueFactory.TEST_INTEGRATION +'"'+ integrationObjects +' }';
    }

    public static String getIntegrationWithObjectsAndFieldsPayload( String fields ) {

        String integrationObjects = ', "MuleIntegrationObjects__r": {"totalSize":1, "done":true,'
        + '"records": [{"attributes": {"type": "MuleIntegrationObject__mdt"}, "Fields__c": "'+fields+'",'
        + '"SObjectType__c": "Account", "DeveloperName": "TestIntegrationAccount"}]}';

        return getIntegrationPayload( integrationObjects );
    }

    public static String getIntegrationWithObjectsAndFieldsPayload( String fields, String sObjectType ) {

        String integrationObjects = ', "MuleIntegrationObjects__r": {"totalSize":1, "done":true,'
        + '"records": [{"attributes": {"type":"MuleIntegrationObject__mdt"}, "Fields__c":"'+fields+'",'
        + '"SObjectType__c": "'+sObjectType+'", "DeveloperName": "TestIntegrationAccount"}]}';

        return getIntegrationPayload( integrationObjects );
    }

    public static MuleIntegration__mdt newMuleIntegration() {
        return fromJson( getIntegrationPayload('') );
    }

    public static MuleIntegration__mdt newMuleIntegrationWithObjects() {

        return fromJson( getIntegrationWithObjectsAndFieldsPayload('') );
    }

    public static MuleIntegration__mdt newMuleIntegrationWithObjectsAndFields() {

        return fromJson( getIntegrationWithObjectsAndFieldsPayload('Name') );
    }

    public static Map<String, MuleIntegration__mdt> newIntegrations() {

        Map<String, MuleIntegration__mdt> integrations = new Map<String, MuleIntegration__mdt>();

        integrations.put(MuleEventQueueFactory.TEST_INTEGRATION, newMuleIntegration());

        return integrations;
    }

    public static MuleIntegration__mdt fromJson( String payload ) {
        return (MuleIntegration__mdt) JSON.deserialize( payload, MuleIntegration__mdt.class);
    }
}