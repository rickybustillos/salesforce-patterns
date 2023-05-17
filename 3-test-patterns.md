
## Test Patterns

Não tem como falar de testes unitários sem falar de TDD (Test Driven Development) que é uma das práticas do Extreme Programming (XP). Essas práticas foram formuladas por _Kent Beck_ e _Ron Jeffries_.

A maneira que o TDD trabalha é através de requisitos, ou users story que são decompostas em um conjunto de comportamentos que são premissas para atender o requisito.

Para cada comportamento do sistema, a primeira coisa a se fazer é escrever um teste unitário que irá testar este comportamento. Um dos benefícios de se escrever o teste primeiro é que ele proporciona uma visão mais empática com relação a como aquela funcionalidade será consumida.

### Testes Unitários

No teste de unidade cada parte do código tem que garantir que está funcionando, independente de suas dependências. Isso significa que todo teste unitário deve ser mocado, não dependendo de dado de banco para ser executado.

### Testes Integrados

O teste integrado parte do pressuposto que será executado um teste de ponta a ponta, ou seja, se estamos tentando executar uma classe de repositório ou de acesso ao banco de dados este teste irá de fato acessar o serviço e executar operações reais.

### Testes Unitários VS Testes Integrados

Todo teste integrado deve executar uma operação real, ou seja, todas as dependências devem estar ligadas para que o teste execute e garanta que o mesmo cenário executado retorne sempre o mesmo resultado.

Dado isso o custo de execução de um teste integrado é muito mais caro (tempo de execução e manutenção) em relação ao teste unitário que basicamente utiliza de Mocks e Stubs para simular o comportamento de um classe ou de um método.

### Mock de dados em testes

#### Teste de classes de serviço ou operações de negócio

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

        return service.findAccountByName( name );
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
            new AccountRepositoryTest.AccountRepositoryMock(payload) );

        Test.startTest();

        List<Account> accounts = AccountController.findByName();

        Test.stopTest();

        System.assert( accounts.size() > 0 );
        System.assertEquals( 'Test', accounts.get(0).Name );
    }
}
```
