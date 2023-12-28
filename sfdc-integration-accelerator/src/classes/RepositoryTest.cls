/**
 * @description: Class to test the Repository abstract class
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class RepositoryTest {

    @isTest
    static void creationAndUpdateScenario () {

        Account account = AccountFactory.newAccount('AccountName');

        TestRepository repository = new TestRepository();

        repository.save( account );

        System.assert( account.Id != null, 'Account Id should not be null' );

        Test.startTest();

        account.Name = 'Updated AccountName';

        repository.save( account );

        Test.stopTest();

        System.assert( account.Id != null, 'Account Id should not be null' );
        System.assertEquals( 'Updated AccountName', account.Name, 'Account Name should be Updated AccountName' );
    }

    @isTest
    static void invalidRemovalErrorScenario () {

        TestRepository repository = new TestRepository();

        Test.startTest();

        Account account = null;

        SObject savedRecord = repository.save( account );
        List<SObject> savedRecords = repository.save( new List<Account>() );

        repository.remove( account );
        repository.remove( new List<Account>() );

        Test.stopTest();

        System.assertEquals( null, savedRecord, 'Saved record should be null' );
        System.assertEquals( null, savedRecords, 'Saved records should be null' );
    }

    @isTest
    static void removalScenario () {

        Account account = AccountFactory.createAccount('AccountName');

        System.assert( account.Id != null, 'Account Id should not be null' );

        Test.startTest();

        TestRepository repository = new TestRepository();

        repository.remove( account );

        Test.stopTest();

        List<Account> accounts = [ SELECT Id FROM Account WHERE Id = :account.Id ];

        System.assert( accounts.isEmpty(), 'Accounts should be empty' );
    }

    public class TestRepository extends Repository {}
}