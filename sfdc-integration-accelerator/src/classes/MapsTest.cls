/**
 * @description: Test class for Maps utility class
 * @author: Henrique Bustillos - Everymind
*/
@isTest
public class MapsTest {

    public static List<Account> setup() {
        return ListsTest.setup();
    }

    @isTest
    static void itShouldReturnAccountsIndexedByField () {

        List<Account> accounts = MapsTest.setup();

        Test.startTest();

        Map<String, Account> accountsByBillingState = (Map<String,Account>) Maps.indexBy( 'BillingState', accounts );

        Test.stopTest();

        System.assertEquals( 2, accountsByBillingState.size(), 'Indexed Accounts size should be 2' );
    }

    @isTest
    static void itShouldReturnEmptyIndexedMap () {

        List<SObject> records = new List<SObject>();

        Test.startTest();

        Map<String, SObject> recordsByBillingState = Maps.indexBy( 'BillingState', records );

        Test.stopTest();

        System.assert( recordsByBillingState.isEmpty(), 'Indexed Accounts should be empty' );
    }

    @isTest
    static void itShouldReturnIndexedFieldByAnotherFieldMap() {

        List<Account> accounts = MapsTest.setup();

        Test.startTest();

        Map<String, Decimal> accountsByBillingState = (Map<String, Decimal>) Maps.indexFieldBy( 'BillingState', 'NumberOfEmployees', accounts );

        Test.stopTest();

        System.assertEquals( 2, accountsByBillingState.size() );
        System.assertEquals( 3, accountsByBillingState.get('Rio de Janeiro') );
    }

    @isTest
    static void itShouldReturnGroupedMap () {

        List<Account> accounts = MapsTest.setup();

        Test.startTest();

        Map<String, List<Account>> accountsGroupedByBillingState = (Map<String, List<Account>>) Maps.groupBy( 'BillingState', accounts );

        Test.stopTest();

        System.assertEquals( 2, accountsGroupedByBillingState.size(), 'Grouped Accounts size should be 2' );
        System.assertEquals( 2, accountsGroupedByBillingState.get('São Paulo').size(), 'Grouped Accounts size should be 2' );
    }

    @isTest
    static void itShouldReturnEmptyGroupedMap () {

        List<Account> accounts = new List<Account>();

        Test.startTest();

        Map<String, List<Account>> accountsGroupedByBillingState = (Map<String, List<Account>>) Maps.groupBy( 'BillingState', accounts );

        Test.stopTest();

        System.assert( accountsGroupedByBillingState.isEmpty(), 'Grouped Accounts should be empty' );
    }

    @isTest
    static void itShouldReturnUntypedGroupedMap () {

        List<Account> accounts = MapsTest.setup();

        Test.startTest();

        Map<String, List<Account>> accountsGroupedByBillingState = (Map<String, List<Account>>) Maps.groupBy( 'BillingState', accounts, Account.class );

        Test.stopTest();

        System.assertEquals( 2, accountsGroupedByBillingState.size(), 'Grouped Accounts size should be 2' );
        System.assertEquals( 2, accountsGroupedByBillingState.get('São Paulo').size(), 'Grouped Accounts size should be 2' );
    }

    @isTest
    static void itShouldReturnEmptyUntypedGroupedMap () {

        List<Account> accounts = new List<Account>();

        Test.startTest();

        Map<String, List<Account>> accountsGroupedByBillingState = (Map<String, List<Account>>) Maps.groupBy( 'BillingState', accounts, Account.class );

        Test.stopTest();

        System.assert( accountsGroupedByBillingState.isEmpty(), 'Grouped Accounts should be empty' );
    }

    @isTest
    static void itShouldReturnMetadataIndexedMapByField () {

        List<MuleIntegration__mdt> integrations = new List<MuleIntegration__mdt>{
            MuleIntegrationFactory.newMuleIntegration()
        };

        Test.startTest();

        Map<String, Object> eventIntegrationsByClassName = Maps.indexByFieldAndValue(
            integrations
            , 'ApexClassName__c'
            , 'IsRetryable__c'
            , true
        );

        Test.stopTest();

        System.assert( eventIntegrationsByClassName.containsKey('MuleIntegrationCommandTest.MuleIntegrationCommandMock'), 'Indexed map should contains a key' );
    }

    @isTest
    static void itShouldReturnSObjectIndexedMapByField () {

        List<Account> accounts = MapsTest.setup();

        Test.startTest();

        Map<String, Object> accountsByName = Maps.indexByFieldAndValue(
            accounts
            , 'Name'
            , 'BillingState'
            , 'São Paulo'
        );

        Test.stopTest();

        System.assert( accountsByName.containsKey('Account 1'), 'Indexed map should contains the key' );
        System.assert( accountsByName.containsKey('Account 2'), 'Indexed map should contains the key' );
    }

    @isTest
    static void returnGroupedMapByLookup () {

        List<Account> accounts = MapsTest.setup();

        Test.startTest();

        Map<String, List<Account>> accountsByParentName = (Map<String, List<Account>>) Maps.groupByLookupField( 'Parent', 'Name', accounts );

        Test.stopTest();

        System.assertEquals( 2, accountsByParentName.size(), 'Grouped Accounts size should be 2' );
        System.assertEquals( 1, accountsByParentName.get('ParentAccount 1').size(), 'Grouped Accounts size should be 1' );
    }

    @isTest
    static void returnEmptyWhenGroupByLookup () {

        List<Account> accounts = new List<Account>();

        Test.startTest();

        Map<String, List<Account>> accountsByParentName = (Map<String, List<Account>>) Maps.groupByLookupField( 'Parent', 'Name', accounts );

        Test.stopTest();

        Assert.isTrue( accountsByParentName.isEmpty(), 'Grouped Accounts size should be empty' );
    }

    @isTest
    static void returnEmptyWhenGroupMapByLookupFieldNotFound () {

        List<Account> accounts = MapsTest.setup();

        Test.startTest();

        Map<String, List<Account>> accountsByParentName = (Map<String, List<Account>>) Maps.groupByLookupField( 'Parent', 'NumberOfEmployees', accounts );

        Test.stopTest();

        Assert.isTrue( accountsByParentName.isEmpty(), 'Grouped Accounts size should be empty' );
    }
}