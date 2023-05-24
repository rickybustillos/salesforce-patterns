/**
 * @description: This class is a factory for Contact objects to use exclusively in test contexts.
 * @author: Henrique Bustillos - Everymind
 */
@isTest
public class ContactFactory {

    public static Contact newContact ( String name ) {
        return new Contact (
            LastName = name
        );
    }

    public static Contact newContact ( Account account ) {
        Contact contact = newContact ( account.Name + 'Test' );
        contact.AccountId = account.Id;
        return contact;
    }

    public static Contact createContact ( String name ) {
        return createContact ( newContact(name) );
    }

    public static Contact createContact ( Account account ) {
        return createContact ( newContact(account) );
    }

    public static Contact createContact ( Contact contact ) {
        insert contact;
        return contact;
    }

    public static Contact fromJson (String payload) {
        return (Contact) JSON.deserialize(payload, Contact.class);
    }

    public static List<Contact> fromJsonArray (String payload) {
        return (List<Contact>) JSON.deserialize(payload, List<Contact>.class);
    }
}