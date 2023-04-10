## Design Patterns

### Repository
O Design Pattern Repository foi criado por Erik Evans no livro Domain Driven Design (2003) que é também mencionado em [ Prof EAA ( Patterns of Enterprise Application Architecture ) ](https://www.martinfowler.com/eaaCatalog/repository.html) de Martin Fowler.

Segue abaixo um trecho do livro [Implementing Domain-Driven Design - Vaughn Vernon](https://books.google.com.br/books/about/Implementing_Domain_Driven_Design.html?id=X7DpD5g3VP8C&source=kp_cover&redir_esc=y).

Segue também uma [documentação da Microsoft sobre o pattern Repository](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design).

> A repository commonly refers to a **storage location**, usually considered a place of safety or **preservation  of the items stored in it**. When you store something in a repository and later return to retrieve it, you expect that it will be in the same state as it was in when you put it there. At some point you may choose to remove the stored item from the repository.
>
> This basic set of principles applies to a DDD **Repository**. Placing an Aggregate (10) instance in its corresponding Repository, and later using that Repository to retrieve the same instance, yields the expected whole object. If you alter a preexisting Aggregate instance that you retrieve from the Repository, its changes will be persisted. If you remove the instance from the Repository, you will be unable to retrieve it from that point forward. \
For each type of object that needs global access, create an object that can provide the illusion of an in-memory collection of all objects of that type. Set up access through a well-known global interface.
>
> Provide methods to add and remove objects. \
Provide methods that select objects based on some criteria and return fully instantiated objects or collections of objects whose attribute values meet the criteria.
>
> Provide repositories only for aggregates [...]
>
>  Evans, p. 151

#### Classe **Repository**

Seguindo paradigmas da Orientação a Objetos, temos a classe abstrata Repository na qual contém métodos genéricos que podem ser reutilizados numa Repository de qualquer objeto apenas extendendo-a.
Esta implementação permite que as operações DML e queries SOQL sejam de responsabilidade da classe Repository e além disso, permite que no cenário de testes possa ser feito Mocks em métodos que não exigem a Inserção do objeto para garantir a funcionalidade (Vide Test Patterns).

``` java

public abstract Repository {

  public virtual SObject save ( SObject aggregate ) {
    // [...]
  }

  public virtual List<SObject> save ( List<SObject> aggregates ) {
    // [...]
  }

  public virtual void remove ( SObject record ) {
    // [...]
  }

  public virtual void remove ( List<SObject> records ) {
    // [...]
  }
}
```

#### Implementação do Repository
Exemplo de uso:

``` java
public virtual class AccountRepository extends Repository {

    public virtual List<Account> findByName ( String name ) {
        return [
            SELECT Id, Name, Type, BillingCity
              , BillingState , BillingPostalCode
              , BillingCountry, CreatedDate
            FROM Account
            WHERE Name LIKE :name
        ];
    }

    public virtual List<Account> findByExternalIds ( List<String> externalIds ) {
        return [
            SELECT BillingStreet, BillingCity
               , BillingState, BillingPostalCode
               , BillingCountry  , BillingLatitude
               , BillingLongitude , BillingGeocodeAccuracy
               , BillingAddress, Name
               , Id, ExternalId__c
            FROM Account
            WHERE ExternalId__c IN :externalIds
        ];
    }

    public virtual List<Account> findWithContactsByName ( String name ) {
        return [
            SELECT Id, Name, Type, BillingCity, BillingState
                , BillingPostalCode, BillingCountry, CreatedDate
                , ( SELECT Id, FirstName, LastName FROM Contacts )
            FROM Account
            WHERE Name LIKE :name
        ];
    }
}
```

Perceba que o Repository também fica responsável por executar os inserts, updates e deletes, operações comuns que são herdadas da classe abstrata Repository.

### Mais informações sobre o pattern Repository:

#### Repository pattern
Edward Hieatt and Rob Mee. Repository pattern.
https://martinfowler.com/eaaCatalog/repository.html

#### The Repository pattern
https://learn.microsoft.com/previous-versions/msp-n-p/ff649690(v=pandp.10)

#### Eric Evans. Domain-Driven Design: Tackling Complexity in the Heart of Software. (Book; includes a discussion of the Repository pattern)
https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215/

#### Unit of Work pattern
Martin Fowler. Unit of Work pattern.
https://martinfowler.com/eaaCatalog/unitOfWork.html

### Trigger Handler

O Pattern Trigger Handler foi criado com intuito de evitar criar lógicas em trigger. As triggers não devem possuir lógica e sim delegar a operação para uma classe especializada (segregação de responsabilidade). **Colocar lógica em triggers cria um código não testável e difícil de manter.**

A classe que extende TriggerHandler **tem o papel de ser uma delegadora de operações**, dessa forma ela mantém uma estrutura enxuta e *limpa*.

Esta implementação com licença MIT do usuário [kevinohara80](https://github.com/kevinohara80/sfdc-trigger-framework) no GitHub traz um conjunto de funcionalidades como:

*   Desligar a Trigger em tempo de execução
*   Eventos de Trigger implementados com a Orientação a Objetos
*   Torna a Classe especializada **mais testável**, pois é possível criar Mock dos dados
*   Capacidade de detectar e limitar recursividade, ou seja, modificações subsequentes no mesmo objeto

A Classe TriggerHandler fornece uma implementação padrão para todos os eventos suportados pelas Triggers.


```java
// Métodos opcionais (virtual) que a classe TriggerHandler implementa
// que capturam todos os eventos da Trigger

    void beforeInsert() {}
    void beforeUpdate() {}
    void beforeDelete() {}
    void afterInsert() {}
    void afterUpdate() {}
    void afterDelete() {}
    void afterUndelete() {}
```

Segue abaixo um exemplo de utilização do padrão Trigger Handler para o objeto Account:

#### Implementação da TriggerHandler

```java
public class AccountTriggerHandler extends TriggerHandler {

    private List<Account> newAccounts;
    private Map<Id, Account> oldAccounts;

    public AccountTH() {
        this.newAccounts = (List<Account>) Trigger.new;
        this.oldAccounts = (Map<Id, Account>) Trigger.oldMap;
    }

    public override void beforeInsert() {
      // [...]
    }

    public override void afterUpdate() {
      // [...]
    }
}
```

[Documentação oficial do Trigger Handler Framework no GitHub](https://github.com/kevinohara80/sfdc-trigger-framework)



### Filter

Para determinadas operações necessitamos filtrar, indexar e agrupar objetos. É frequente que esse tipo de implementação seja implementado diretamente na classe, o que acaba poluindo a mesma com este tipo de regra. O Design Pattern Filter encapsula toda lógica de filtro, indexação e agrupamento em uma única classe para aquele objeto de domínio.


#### Classe Filter
Aqui um pequeno exemplo de implementação "genérica" de uma Filter, onde existe a entrada de dados para serem filtrados e o retorno da lista filtrada.

```java
public class Filter {

    public List<SObject> byChangedFieldValue ( List<SObject> newRecords
        , Map<Id, SObject> oldRecords
        , String changedField
        , String changedValue ) {
        // [...]
    }

    public List<SObject> byChangedFields ( List<SObject> newRecords
        , Map<Id, SObject> oldRecords
        , List<String> changedFields ) {
        // [...]
    }
}
```
> Não é recomendado que a classe Filter tenha acesso ao **Repository**, ela deve somente receber a lista para ser filtrada, indexada ou agrupada, pois desta forma ela cumpre sua responsabilidade e mantém o desacoplamento e segregação das classes.

Um ótimo cenário para essa implementação é criar uma AccountFilter extendendo de Filter, onde a classe herdada terá os métodos "genéricos" para serem implementados ou reutilizados.

#### Implementação da Filter

```java
public class AccountFilter extends Filter {

    public List<Account> byChangedAppointmentDate ( List<Account> newAccounts, Map<Id, Account> oldAccounts ) {

        List<String> changedFields = new List<String>{ 'AppointmentDate__c' };

        return this.byChangedFields( oldAccounts, changedFields );
    }
}
```