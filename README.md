# Salesforce Patterns and Best Practices
Melhores práticas e convenções no desenvolvimento Salesforce.

Neste documento veremos os melhores Design Patterns, Test Patterns, Convenções de código seguindo literaturas de referência mundial em Desenvolvimento de Software como o Clean Code e Princípios do SOLID de Robert C. Martin, dentre outras pessoas que fizeram parte da construção desses padrões.

Um dos objetivos deste documento é garantir que a orientação a objetos cumpra seu papel de tornar o design mais entendível, flexível e sustentável e também prospectar ao desenvolvedor o início de sua desenvoltura em seu olhar crítico e começar a pensar no código como seu legado.

Tudo isso traz riqueza e valor em qualquer projeto em que for aplicado, seguindo um padrão e refletindo paradigmas pensados e estudados durante todos esses anos em relação às práticas de desenvolvimento.


## Design Patterns

### Repository
O Design Pattern Repository foi criado por Erik Evans no livro Domain Driven Design (2003) que é também mencionado em [ Prof EAA ( Patterns of Enterprise Application Architecture ) ](https://www.martinfowler.com/eaaCatalog/repository.html)do Martin Fowler.

Segue abaixo um trecho do livro [Implementing Domain-Driven Design - Vaughn Vernon](https://books.google.com.br/books/about/Implementing_Domain_Driven_Design.html?id=X7DpD5g3VP8C&source=kp_cover&redir_esc=y).

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

  public SObject save (SObject aggregate) {
    // [...]
  }

  public List<SObject> save (List<SObject> aggregates) {
    // [...]
  }

  public List<Database.SaveResult> updateAll ( List<SObject> aggregates ) {
    // [...]
  }

  public List<Database.SaveResult> insertAll ( List<SObject> aggregates ) {
    // [...]
  }
}
```

Exemplo de uso:

``` java
public virtual class AccountRepository extends Repository {

    public virtual List<Account> findByName ( String name ) {
        return [
            SELECT Id, Name, Type, BillingCity
              , BillingState , BillingPostalCode
              , BillingCountry, CreatedDate
            FROM Account
            WHERE Name like :name
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
            WHERE ExternalId__c in : externalIds
        ];
    }

    public virtual List<Account> findWithContactsByName ( String name ) {
        return [
            SELECT Id, Name, Type, BillingCity, BillingState
                , BillingPostalCode, BillingCountry, CreatedDate, CreatedBy.Name
                , ( SELECT Id, FirstName, LastName FROM Contacts )
            FROM Account
            WHERE Name LIKE :name
        ];
    }
}
```

Perceba que o Repository também fica responsável por executar os inserts, updates, delete e essas operações são herdadas da classe abstrata Repository.

### Trigger Handler

O Pattern Trigger Handler foi criado com intuito de evitar criar lógicas em trigger. As triggers não devem possuir lógica e sim delegar a operação para uma classe especializada (segregação de responsabilidade). **Colocar lógica em triggers cria um código não testável e difícil de manter.**

A classe que extende TriggerHandler **tem o papel de ser uma delegadora de operações**, dessa forma ela mantém uma estrutura enxuta e *limpa*.

Esta implementação com licença MIT do usuário [kevinohara80](https://github.com/kevinohara80/sfdc-trigger-framework) no GitHub traz um conjunto de funcionalidades como:

*   Desligar a Trigger em tempo de execução
*   Eventos de Trigger implementandos com a Orientação a Objetos
*   Torna a Classe especializada mais testável, pois é possível criar Mock dos dados
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

Segue abaixo um exemplo de utilização do padrão Trigger Handler para o Objeto Account:

#### Implementação da TriggerHandler

```java
public class AccountTriggerHandler extends TriggerHandler {

    private List<Account> newAccounts;
    private Map<Id, Account> oldAccounts;

    public AccountTH() {
        this((List<Account>) Trigger.new, (Map<Id, Account>) Trigger.oldMap);
    }

    public AccountTH( List<Account> newAccounts , Map<Id, Account> oldAccounts ) {
        this.newAccounts = newAccounts;
        this.oldAccounts = oldAccounts;
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
> Não é recomendado que a classe Filter tenha acesso ao **Repository**, ela deve somente receber a lista para ser filtrada, indexada ou agrupada, pois assim ela tem somente esta responsabilidade.

Um ótimo cenário para essa implementação é criar uma AccountFilter extendendo de Filter, onde a classe herdada terá os métodos "genéricos" para serem im

#### Implementação da Filter

```java
public class AccountFilter extends Filter {

    public List<Account> byChangedAppointmentDate ( List<Account> newAccounts, Map<Id, Account> oldAccounts ) {

        List<String> changedFields = new List<String>{ 'AppointmentDate__c' };

        return this.byChangedFields( oldAccounts, changedFields );
    }
}
```

### Transformer

Uma característica natural em integrações sistêmicas é a necessidade de "mapear" os dados do sistema de origem para o sistema de destino. Para realizar esse papel existe o pattern Transformer.

Ele é muito semelhante ao pattern Builder do GOF, tendo o papel de segregar a responsabilidade de criação de objetos complexos.

No exemplo abaixo temos o cenário de uma integração sistêmica com a ViaCep, logo temos uma estrutura de dados respectiva do sistema da ViaCep que precisamos mapeá-lo para o cenário destino, que no caso é o endereço de entrega de uma Account registrada do lado Salesforce, logo é delegado à classe Transformer executar essa transformação de dados com o response origem.


###### **AccountAddressTransformer**

```java
public class AccountAddressTransformer {

    public AccountAddressTransformer() {
    }

    public Account toAccountBillingAddress (ViaCepCodeAddressResponse response) {

        Account account = new Account();

        account.BillingCity = response.localidade;
        account.BillingStreet = response.logradouro + ' ' + response.complemento;
        account.BillingState = response.uf;
        account.BillingPostalCode = response.cep;
        account.BillingCountry = 'Brasil';

        return account;
    }

    public Account toAccountShippingAddress (ViaCepCodeAddressResponse response) {

        Account account = new Account();

        account.ShippingCity = response.localidade;
        account.ShippingStreet = response.logradouro + ' ' + response.complemento;
        account.ShippingState = response.uf;
        account.ShippingPostalCode = response.cep;
        account.ShippingCountry = 'Brasil';

        return account;
    }
}
```

### FixtureFactory (Testes)

 Fixture nada mais é do que um template de dados que utilizamos em Cenários de Teste. Por exemplo, uma instância do objeto Account com os dados de BillingAddress, ShippingAddress, etc.

Segue abaixo a anatomia de uma classe Fixture Factory, lembrando de sempre manter a segregação de responsabilidade única do SOLID. Tendo isso em mente, devemos criar uma FixtureFactory especializada para cada objeto de domínio.


#### **AccountFixtureFactory**


``` java
@isTest
public class AccountFixtureFactory {

    public static Map<String, Schema.RecordTypeInfo> recordTypes =
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();

    public static Account newAccount(String name) {
        Account account = new Account();
        account.Name = name;
        account.LastName = 'Teste' + Date.today();
        account.RecordTypeId = recordTypes.get( 'SpecificRecordType' ).getRecordTypeId()
    }

    public static Account createAccount(String name) {
        return createAccount ( newAccount (name));
    }

    public static Account createAccount (Account account) {
        insert account;
        return account;
    }
}
```


##### O propósito de cada nomenclatura dos métodos

*   **newAccount** : Utilizado para prover a instância de determinado SObject, no caso Account.

*   **createAccount** : Métodos "create" são utilizados para criar o SObject de fato. Neste exemplo temos dois métodos sobrecarregados, pois um é utilizado para criar com base nas mesmas entradas do newAccount e outro com base no SObject.

Note que no cenário de teste, não faz sentido utilizarmos repositories para queries SOQL e nem temos restrições para operações DML, pois não se trata de uma classe produtiva, e sim uma classe especializada para testes.


#### Testando Classes de Repositório utilizando Fixture Factory

> A principal característica de um Repositório (Repository) é interação com banco de dados, dado isso ela este tipo de classe necessita de **Testes Integrados** para validar vários elementos como Campos, Objetos e fluxo transacional.


##### **AccountRepositoryTest**

``` java
@isTest
public class AccountRepositoryTest {

    @isTest
    public static void itShouldReturnAStoredAccount() {

        // Given
        Account expectedAccount = AccountFixtureFactory.createAccount('Test Account');

        System.assert( expectedAccount.Id != null );

        // When
        Test.startTest();

        AccountRepository repository = new AccountRepository();

        Account storedAccount = repository.findById( expectedAccount.Id );

        Test.stopTest();

        // Then

        System.assert( expectedAccount.Id == storedAccount.Id);
    }

    public class AccountRepositoryMock {
        // [...]
    }
}
```

> Given-When-Then is a style of representing tests - or as its advocates would say - specifying a system's behavior using SpecificationByExample. It's an approach developed by Daniel Terhorst-North and Chris Matts as part of [Behavior-Driven Development (BDD)](https://dannorth.net/introducing-bdd/). It appears as a structuring approach for many testing frameworks such as Cucumber. You can also look at it as a reformulation of the [Four-Phase Test pattern](http://xunitpatterns.com/Four%20Phase%20Test.html).
>
> Martin Fowler

---

## Test Patterns

Não tem como falar de testes unitários sem falar de TDD (Test Driven Development) que é uma das práticas do Extreme Programming (XP). Essas práticas foram formuladas por _Kent Beck_ e _Ron Jeffries_ à partir de suas experiências no desenvolvimento de um sistema de pagamento para a Chrysler.

A maneira que TDD trabalha é através de requisitos, ou users story que são decompostas em um conjunto de comportamentos que são premissas para atender o requisito.

Para cada comportamento do sistema, a primeira coisa a se fazer é escrever um teste unitário que irá testar este comportamento. Um dos benefícios de se escrever o teste primeiro é que ele proporciona uma visão mais empática com relação a como aquela funcionalidade será consumida.

### Testes Unitários

No teste de unidade cada parte do código tem que garantir que está funcionando, independente de suas dependências. Isso significa que todo teste unitário deve ser mocado, não dependendo de dado de banco para ser executado.

### Testes Integrados

O teste integrado parte do pressuposto que será executado um teste de ponta a ponta, ou seja, se estamos tentando executar uma classe de repositório ou de acesso ao banco de dados este teste irá de fato acessar o serviço e executar operações reais.

### Testes Unitários VS Testes Integrados

Todo teste integrado deve executar uma operação real, ou seja, todos as dependências devem estar ligadas para que o teste execute e garanta que o mesmo cenário executado retorne sempre o mesmo resultado.
Dado isso o custo de execução de um teste integrado é muito mais caro (tempo de execução e manutenção) em relação ao teste unitário que basicamente utiliza de Mocks e Stubs para simular o comportamento de um classe ou de um método.

### Mock de dados em testes

#### Teste de classes de serviço (ref. a BO)

Classes de Serviço geralmente acessam um repositório ou outro serviço, então neste caso podemos e devemos utilizar testes com mock de dados em payloads.

**Para efeitos didáticos** suponha que temos uma classe chamada de AccountService que utiliza a AccountRepository conforme o exemplo abaixo.

Um ponto de atenção é que todos os métodos no Repository devem ser virtual para que estes possam ser sobrescritos.


```java

public class AccountService {

    private AccountRepository repository;

    public AccountService() {
        this.repository = new AccountRepository();
    }

    public List<Account> findAccountByName (String name) {
        return repository.findByName (name);
    }

    // test injection
    public void setRepository (AccountRepository repository) {
        this.repository = repository;
    }
}

```

Perceba que o método de findAccountByName utiliza o repository e espera que ele retorne uma lista de Accounts, então é exatamente isso que temos que simular o método findByName retornar uma lista de Accounts.

```java
@isTest
public class AccountServiceTest {

    public static void itShouldReturnFetchedAccountByName() {

        String payload = '[{"Id":"001f000001ONeLzAAL","Name":"Test"}]';

        Test.startTest();

        AccountService service = new AccountService ();
        service.setRepository ( new AccountRepositoryTest.AccountRepositoryMock(payload) );

        List<Account> accounts = service.findAccountByName('Test');

        Test.stopTest();

        System.assert( accounts.size() > 0 );
        System.assertEquals( 'Test', accounts.get(0).Name );
    }


    public static void itShouldReturnEmptyAccountList() {
        String payload = '[]';

        Test.startTest();

        AccountService service = new AccountService ();
        service.setRepository ( new AccountRepositoryMock (payload) );

        List<Account> accounts = service.findAccountByName ('Test');

        Test.stopTest();

        System.assert (accounts.size() == 0);
    }
}
```

```java
public class AccountRepositoryTest {

    // [...]

    public class AccountRepositoryMock extends AccountRepository {

        public String payload;

        public AccountRepositoryMock (String payload) {
            super();
            this.payload = payload;
        }

        override
        public List<Account> findByName (String name) {
            return (List<Account>) JSON.deserialize (payload, List<Account>.class);
        }

        override
        public SObject save (SObject account) {
            return JSON.deserialize (payload, Account.class);
        }
    }
}
```

Para este exemplo, note que o objetivo deste teste é garantir que o método da AccountService está executando e retornando o que ela é responsável por fazer, descartando qualquer outra operação integrada da AccountRepository. Logo, é um exemplo de um teste unitário.

Com esse teste, está coberto 100% da classe AccountService e com um dos menores tempo de execução possível.



#### Teste de classes Rest Resource

Como ficaria essas práticas de teste em um RestResource ou método expostos como AuraEnabled ou qualquer outro método estático?


```java
@RestResource (urlMapping='api/account')
global with sharing class AccountController {

    public static AccountService service;

    static {
        service = new AccountService();
    }

    @HttpGet
    global static List<Account> findByName () {
        String name = RestContext.request.params.get('name');
        return service.findAccountByName();
    }

}

```

A classe acima possui um atributo estático inicializado dentro de um bloco static {}. Como vou criar um mock disso? Simples:

```java
@isTest
public class AccountControllerTest {

    @isTest
    public static void itShouldReturnFetchedAccountByName() {

        RestRequest request = new RestRequest();
        RestResponse respose = new RestResponse();

        request.httpMethod = 'GET';
        request.params.put('name', 'Test');

        RestContext.request = request;
        RestContext.response = respose;

        String payload = '[ {"Id":"001f000001ONeLzAAL","Name":"Test"} ]';

        AccountController.service.setRepository (
            new AccountRepositoryTest.AccountRepositoryMock (payload) );

        Test.startTest();

        List<Account> accounts = AccountController.findByName ();

        Test.stopTest();

        System.assert( accounts.size() > 0 );
        System.assertEquals( 'Test', accounts.get(0).Name );
    }
}
```

---

## Code Review

Algumas orientações para facilitar o processo de code reviewing.

### Pull Request Checklist

* Code Style
* Aplicação da Regra do Escoteiro, conforme alguns pontos abaixo:

    * Refatoração de nomes de variáveis
    * Refatoração de nomes de método
    * Remoção de códigos comentados
    * Refatoração de DMLs para classes Repository
    * Utilização de FixtureFactories para classes de Teste

#### A  regra do escoteiro

> [...] *Deixe a área do acampamento mais limpa do que como você a encontrou*.
>
> Robert C. Martin, "Clean Code", p. 14

Uncle Bob traz esta frase como uma referência adaptada que, trazendo a regra para o mundo da programação, ela significa deixar o código mais limpo do que estava antes de mexer nele.