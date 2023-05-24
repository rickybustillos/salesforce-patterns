/**
 * @description: Class to provide mocks for EventIntegrationRepository class
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class EventIntegrationRepositoryTest {

    public class EventIntegrationRepositoryMock extends EventIntegrationRepository {

        String payload;

        public EventIntegrationRepositoryMock (String payload) {
            this.payload = payload;
        }

        public override Map<String, EventIntegration__mdt> findActiveRetryable () {
            return (Map<String, EventIntegration__mdt>) JSON.deserialize(payload, Map<String, EventIntegration__mdt>.class);
        }

    }
}