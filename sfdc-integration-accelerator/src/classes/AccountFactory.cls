/**
 * @description: This class is a factory for Account objects to use exclusively in test contexts.
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class AccountFactory {

    public static final Map<String, Schema.RecordTypeInfo> RECORD_TYPES =
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();

    public static Account newAccount ( String name ) {
        return new Account (
            Name = name,
            Description = 'Account instance in test context'
        );
    }

    public static Map<String, SObject> integratedScenarioWithContacts () {

        Map<String, SObject> records = new Map<String, SObject>();

        Account account = createAccount( 'Account with Contacts' );
        records.put( 'account', account );

        Contact contact = ContactFactory.createContact( account );
        records.put( 'contact', contact );

        AccountContactRelation relation = [ SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE AccountId = :account.Id AND ContactId = :contact.Id  ];
        records.put( 'relation', relation );

        return records;
    }

    public static Account createAccount ( String name ) {
        return createAccount( newAccount (name) );
    }

    public static Account createAccount ( Account account ) {
        insert account;
        return account;
    }

    public static Account fromJson ( String payload ) {
        return (Account) JSON.deserialize(payload, Account.class);
    }

    public static List<Account> fromJsonArray ( String payload ) {
        return (List<Account>) JSON.deserialize(payload, List<Account>.class);
    }
}