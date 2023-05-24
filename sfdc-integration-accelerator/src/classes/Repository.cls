/**
 * @description: Abstract class that represents a generic SObject Repository. Provides standard methods for all repositories.
 * @author: Henrique Bustillos - Everymind
 */
public abstract inherited sharing class Repository {

    public virtual SObject save ( SObject aggregate ) {

        if ( aggregate == null ) return null;

        return this.save( new List<SObject>{ aggregate } ).get( 0 );
    }

    public virtual List<SObject> save ( List<SObject> aggregates ) {

        if ( aggregates == null || aggregates.isEmpty() ) return null;

        upsert aggregates;
        return aggregates;
    }

    public virtual void remove ( SObject record ) {

        if( record == null ) return;

        this.remove( new List<SObject>{ record } );
    }

    public virtual void remove ( List<SObject> records ) {

        if( records == null || records.isEmpty() ) return;

        delete records;
    }
}
