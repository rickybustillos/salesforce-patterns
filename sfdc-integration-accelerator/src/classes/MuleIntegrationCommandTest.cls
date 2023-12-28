/**
 * @description: Test class for MuleIntegrationCommand architecture
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class MuleIntegrationCommandTest {

    @isTest
    static void successIntegratedScenario () {

        String integrationPayload = MuleIntegrationFactory.getIntegrationWithObjectsAndFieldsPayload('Name');

        List<MuleEventQueue__c> eventQueues = new List<MuleEventQueue__c>{ MuleEventQueueFactory.createMuleEventQueue() };

        Test.startTest();

        MuleIntegrationCommandMock command = new MuleIntegrationCommandMock();
        command.setMuleIntegrationRepository( new MuleIntegrationRepositoryTest.MuleIntegrationRepositoryMock( integrationPayload ) );
        command.setIntegration( MuleIntegrationType.TEST_INTEGRATION );

        List<Database.SaveResult> result = command.execute();

        Test.stopTest();

        System.assertEquals( 1, result.size(), 'Should have one result' );
        System.assert( result[0].isSuccess(), 'Should be success' );
    }

    @isTest
    static void errorIntegratedScenarioWithoutRecords () {

        String integrationPayload = MuleIntegrationFactory.getIntegrationWithObjectsAndFieldsPayload('Name', 'User');

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.createMuleEventQueue();

        System.assertEquals( MuleEventQueueStatus.PENDING.name(), eventQueue.Status__c, 'Should be PENDING' );

        Test.startTest();

        MuleIntegrationCommandMock command = new MuleIntegrationCommandMock();
        command.setMuleIntegrationRepository( new MuleIntegrationRepositoryTest.MuleIntegrationRepositoryMock( integrationPayload ) );
        command.setIntegration( MuleIntegrationType.TEST_INTEGRATION );

        List<Database.SaveResult> result = command.execute();

        Test.stopTest();

        System.assertEquals( null, result, 'Should be null' );

        eventQueue = [ SELECT Status__c FROM MuleEventQueue__c WHERE Id = :eventQueue.Id ];

        System.assertEquals( MuleEventQueueStatus.ERROR.name(), eventQueue.Status__c, 'Should be ERROR' );
    }

    @isTest
    static void errorIntegratedScenarioWithoutObjectId () {

        String integrationPayload = MuleIntegrationFactory.getIntegrationWithObjectsAndFieldsPayload('Name');

        MuleEventQueue__c eventQueue = MuleEventQueueFactory.newMuleEventQueue();
        eventQueue.RecordId__c = 'unknownId';

        System.assertEquals( MuleEventQueueStatus.PENDING.name(), eventQueue.Status__c, 'Should be PENDING' );

        Test.startTest();

        MuleIntegrationCommandMock command = new MuleIntegrationCommandMock();
        command.setMuleIntegrationRepository( new MuleIntegrationRepositoryTest.MuleIntegrationRepositoryMock( integrationPayload ) );
        command.setMuleEventQueueRepository( new MuleEventQueueRepositoryTest.MuleEventQueueRepositoryMock() );
        command.setIntegration( MuleIntegrationType.TEST_INTEGRATION );

        List<Database.SaveResult> result = command.execute( new List<MuleEventQueue__c>{ eventQueue } );

        Test.stopTest();

        System.assertEquals( null, result, 'Should be null' );

        System.assertEquals( MuleEventQueueStatus.ERROR.name(), eventQueue.Status__c, 'Should be ERROR' );
    }

    @isTest
    static void integratedScenarioWithoutMetadata() {

        Test.startTest();

        try {

            MuleIntegrationCommandMock command = new MuleIntegrationCommandMock( MuleIntegrationType.TEST_INTEGRATION );

            System.assert( false, 'Should throw an error, does not have an integration metadata for TEST_INTEGRATION' );

        } catch ( Exception e ) {

            System.assert( true, 'Should throw an error, does not have an integration metadata for TEST_INTEGRATION' );
        }

        Test.stopTest();
    }

    @isTest
    static void errorScenarioWithoutExistantMetadata() {

        String integrationPayload = '{}';

        Test.startTest();

        try {

            MuleIntegrationCommandMock command = new MuleIntegrationCommandMock();
            command.setMuleIntegrationRepository( new MuleIntegrationRepositoryTest.MuleIntegrationRepositoryMock( integrationPayload ) );
            command.setIntegration( MuleIntegrationType.TEST_INTEGRATION );

            System.assert( false, 'Should thrown an MuleIntegrationException, not thrown' );

        } catch ( MuleIntegrationException e ) {

            System.assert( true, 'Should thrown an MuleIntegrationException, thrown' );
        }

        Test.stopTest();
    }

    @isTest
    static void errorScenarioWithoutObjects() {

        String integrationPayload = MuleIntegrationFactory.getIntegrationPayload();

        Test.startTest();

        try {

            MuleIntegrationCommandMock command = new MuleIntegrationCommandMock();
            command.setMuleIntegrationRepository( new MuleIntegrationRepositoryTest.MuleIntegrationRepositoryMock( integrationPayload ) );
            command.setIntegration( MuleIntegrationType.TEST_INTEGRATION );

            System.assert( false, 'Should thrown an MuleIntegrationException, not thrown' );

        } catch ( MuleIntegrationException e ) {

            System.assert( true, 'Should thrown an MuleIntegrationException, thrown' );
        }

        Test.stopTest();
    }

    @isTest
    static void errorScenarioWithoutObjectsFields() {

        String integrationPayload = MuleIntegrationFactory.getIntegrationWithObjectsAndFieldsPayload('');

        Test.startTest();

        try {

            MuleIntegrationCommandMock command = new MuleIntegrationCommandMock();
            command.setMuleIntegrationRepository( new MuleIntegrationRepositoryTest.MuleIntegrationRepositoryMock( integrationPayload ) );
            command.setIntegration( MuleIntegrationType.TEST_INTEGRATION );

            System.assert( false, 'Should thrown an MuleIntegrationException, not thrown' );

        } catch ( MuleIntegrationException e ) {

            System.assert( true, 'Should thrown an MuleIntegrationException, thrown' );
        }

        Test.stopTest();
    }

    /**
     * @description: Mock class for MuleIntegrationCommand (also, how to use it)
     */
    public class MuleIntegrationCommandMock extends MuleIntegrationCommand {

        /**
         * @description: constructor to use in your test class
         */
        public MuleIntegrationCommandMock() {
            super();
        }

        /**
         * @description: constructor to use in your class in real world
         * make sure that the <integration> variable is a static final constant in your class
         * and not a parameter in the constructor like this example bellow
         */
        public MuleIntegrationCommandMock( MuleIntegrationType integration ) {
            super(integration);
        }

        /**
         * @description: implement your own method to execute the integration following this pattern
         */
        public override List<Database.SaveResult> execute ( List<MuleEventQueue__c> eventQueues ) {

            List<Database.SaveResult> publishedEvents = null;

            try {

                // gather your data to be integrated
                List<Account> gatheredData = this.getAccounts();

                // validate if the gathered data is empty
                this.validate.emptyRecords( gatheredData );

                // build your payload indexed by each MuleEventQueue.RecordId__c
                // usually implement a private method "buildPayload" to this
                // also you can create a DTO to represent your payload and the method will return Map<String, YourDTOPayload>
                Map<String, Object> payloadsByRecordId = new Map<String, Object>{ 'fakeId' => gatheredData };

                // publish or update with error your events after enriching the events with payload or error
                publishedEvents = this.publishEvents( this.withPayloadOrError( eventQueues, payloadsByRecordId ) );

            } catch ( Exception e ) {

                this.updateEventQueuesWithError( eventQueues, e.getMessage() + e.getStackTraceString() );
            }

            return publishedEvents;
        }

        /**
         * @description: implement your own method to get the data to be integrated,
         * also you can use the super class method getFieldsByObjectName() to get the fields to be integrated
         */
        private List<Account> getAccounts () {

            String fieldsToIntegrate = this.getFieldsByObjectName().get('Account');

            if ( this.getFieldsByObjectName().containsKey('Account') ) {

                // here in real world you should make a SOQL query (prefer to use a Repository segregated class)
                // ex: return this.accountRepository.findAllByFields( fieldsToIntegrate );
                return new List<Account>{ AccountFactory.newAccount('TestAccount') };
            }

            return new List<Account>();
        }
    }
}