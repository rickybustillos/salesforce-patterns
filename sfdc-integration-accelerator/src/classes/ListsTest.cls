/**
 * @description: Test class for Lists utility class
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class ListsTest {

    public static List<Account> setup() {
        return new List<Account> {
            AccountFactory.fromJson('{ "Id": "'+((Id) FixtureFactory.generateFakeId( Account.getSObjectType() ))+'", "Name":"Account 1", "BillingState":"São Paulo", "NumberOfEmployees": 5}'),
            AccountFactory.fromJson('{ "Id": "'+((Id) FixtureFactory.generateFakeId( Account.getSObjectType() ))+'", "Name":"Account 2", "BillingState":"São Paulo", "NumberOfEmployees": 14, "Parent": {"Name": "ParentAccount 1"} }'),
            AccountFactory.fromJson('{ "Id": "'+((Id) FixtureFactory.generateFakeId( Account.getSObjectType() ))+'", "Name":"Account 3", "BillingState":"Rio de Janeiro", "NumberOfEmployees": 3, "Parent": {"Name": "ParentAccount 2"} }')
        };
    }

    @isTest
    private static void itShouldReturnAListWithFieldValues () {

        List<Account> accounts = setup();

        Test.startTest();

        List<String> names = Lists.byfield( accounts, 'Name' );

        Test.stopTest();

        System.assertEquals( 3, names.size(), 'Names list should have 3 elements' );
    }

    @isTest
    private static void itShouldReturnEmptyList () {

        List<SObject> records = new List<SObject>();

        Test.startTest();

        List<String> values = Lists.byfield( records, 'BillingState' );

        Test.stopTest();

        System.assertEquals( 0, values.size(), 'Values list should be empty' );
    }
}