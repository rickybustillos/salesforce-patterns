/**
 * @description: Utility class to handle and working with Maps
 * @author: Henrique Bustillos - Everymind
 */
public without sharing class Maps {

    public static Map<String, SObject> indexBy ( String fieldName, List<SObject> records ) {

        if ( Lists.isEmpty(records) ) return new Map<String, SObject>();

        Map<String, SObject> values = newEmptyMap(records);

        for ( SObject record : records ) {

            String value = (String) record.get( fieldName );

            if ( value == null ) continue;

            values.put( value, record );
        }

        return values;
    }

    public static Map<String, Decimal> indexFieldBy ( String fieldName, String fieldName2, List<SObject> records) {

        if ( Lists.isEmpty(records) ) return new Map<String, Decimal>();

        Map<String, Decimal> values = new Map<String, Decimal>();

        for ( SObject record : records ) {

            String value = (String) record.get( fieldName );

            if ( value == null ) continue;

            values.put( value, (Decimal) record.get( fieldName2 ) );
        }

        return values;
    }

    /*
     * @description: Works with SObjects and Custom Metadatas objects
    */
    public static Map<String, Object> indexByFieldAndValue ( List<Object> records, String indexedField, String field, Object value ) {

        if ( Lists.isEmpty(records) ) return null;

        Map<String, Object> recordsByField = new Map<String, Object>();

        for ( Object record : records ) {

            CObject coreRecord = new CObject(record);

            if ( !coreRecord.containsKey(field) ) continue;

            if ( coreRecord.get(field) != value ) continue;

            recordsByField.put( (String) coreRecord.get(indexedField), record);
        }

        return recordsByField;
    }

    public static Map<String, List<SObject>> groupBy ( String fieldName, List<SObject> records ) {

        if ( Lists.isEmpty(records) ) return new Map<String, List<SObject>>();

        Map<String, List<SObject>> values = newEmptyGroupedMap(records);

        for ( SObject record : records ) {

            String value = (String) record.get( fieldName );

            if ( value == null ) continue;

            if ( !values.containsKey( value ) ) {
                values.put( value, new List<SObject>() );
            }

            values.get( value ).add( record );
        }

        return values;
    }

    private static Map<String, List<SObject>> newEmptyGroupedMap ( List<SObject> records ) {

        if ( Lists.isEmpty(records) ) return null;

        Schema.DescribeSObjectResult describer = records.get(0).getSObjectType().getDescribe();

        String sobjectName = describer.getName();

        Type sobjectType = Type.forName( 'Map<String, List<' + sobjectName + '>>' );

        return (Map<String, List<SObject>>) sobjectType.newInstance();
    }

    private static Map<String, SObject> newEmptyMap (List<SObject> records) {

        if ( Lists.isEmpty(records) ) return null;

        Schema.DescribeSObjectResult describer = records.get(0).getSObjectType().getDescribe();

        String sobjectName = describer.getName();

        Type sobjectType = Type.forName( 'Map<String, ' + sobjectName + '>' );

        return (Map<String, SObject>) sobjectType.newInstance();
    }
}