/**
 * @description: Class to provide mocks for MuleIntegrationRepository class
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleIntegrationRepositoryTest {

    @isTest
    static void findActiveRetryable() {

        Test.startTest();

        MuleIntegrationRepository repository = new MuleIntegrationRepository();

        try {
            Map<String, MuleIntegration__mdt> actual = repository.findActiveRetryable();

            Assert.isTrue( true, 'Should not throw exception, success' );

        } catch (Exception e) {
            Assert.fail('Should not throw exception, it throws: ' + e.getMessage());
        }

        Test.stopTest();
    }

    @isTest
    static void findByIntegrationName() {

        Test.startTest();

        MuleIntegrationRepository repository = new MuleIntegrationRepository();

        MuleIntegration__mdt actual = repository.findByIntegrationName( MuleIntegrationType.TEST_INTEGRATION );

        Test.stopTest();

        Assert.isNull( actual, 'Should return null, success' );
    }

    public class MuleIntegrationRepositoryMock extends MuleIntegrationRepository {

        String payload;

        public MuleIntegrationRepositoryMock (String payload) {
            this.payload = payload;
        }

        public override Map<String, MuleIntegration__mdt> findActiveRetryable() {
            return (Map<String, MuleIntegration__mdt>) JSON.deserialize(payload, Map<String, MuleIntegration__mdt>.class);
        }

        public override MuleIntegration__mdt findByIntegrationName( MuleIntegrationType integrationType ) {
            return (MuleIntegration__mdt) JSON.deserialize(payload, MuleIntegration__mdt.class);
        }

    }
}