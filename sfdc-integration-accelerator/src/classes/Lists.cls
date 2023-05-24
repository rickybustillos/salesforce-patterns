/**
 * @description: Utility class to handle and working with Lists
 * @author: Henrique Bustillos - Everymind
 */
public with sharing class Lists {

    public static List<String> byFields ( List<SObject> records, List<String> fields ) {

        if ( isEmpty(records) || isEmpty(fields) ) return new List<String>();

        List<String> fieldsValues = new List<String>();

        for ( SObject record : records ) {

            for ( String field : fields ) {

                if ( record.get(field) == null ) continue;

                fieldsValues.add( '' + record.get(field) );
            }
        }

        return fieldsValues;
    }

    public static List<String> byField( List<SObject> records, String field ) {
        return byFields( records, new List<String>{ field } );
    }

    public static Boolean isEmpty( List<Object> records ) {
        return records == null || records.isEmpty();
    }
}