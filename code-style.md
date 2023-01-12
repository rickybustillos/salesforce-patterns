
# Code Style guide

The intention of this guide is to provide a set of conventions that **encourage good code**.
It is the distillation of many combined man-years of software engineering and Java development experience.
While some suggestions are more strict than others, **you should always practice good judgment**.

If following the guide causes unnecessary hoop-jumping or otherwise less-readable code, *readability trumps the guide*.
However, if the more 'readable' variant comes with perils or pitfalls, readability may be sacrificed.

## Table of contents
---

- [Concerns about Custom Objects and Custom Fields naming](#concerns-about-custom-objects-and-custom-fields-naming)
- [Apex Coding Style](#apex-coding-style)
- [Source Type Basic](#source-type-basic)
- [Declaration Types](#declaration-types)
- [Formatting](#formatting)
- [Field, class, and method declarations](#field-class-and-method-declarations)
- [Variable naming](#variable-naming)
- [Exceptions](#exceptions)
- [Writing testable code](#writing-testable-code)
- [Documentation](#documentation)


## Concerns about Custom Objects and Custom Fields naming

Avoid prepositions in APIName

Avoid use the automatic platform label to api name conversion for labels with special characters. Examples:


	// Wrong
	Label:   Tipo de Serviço
	ApiName: Tipo_de_Servi_o__c

	Label:   Configuração Dinamica
	ApiName: Configura__o_Dinamica__c

	// Right
	Label:   Tipo Serviço
	ApiName: TipoServico__c

	Label:   Configuração Dinamica
	ApiName: ConfiguracaoDinamica__c

Avoid use the own type for describe the custom field api name. Example:

	Standard object:          "Order"
	or for a Custom object:   "Pedido__c"

	// Wrong
	CustomField:              TipoPedido__c

	// Right
	CustomField:              Tipo__c


## Apex Coding Style
------------------

The structure of this document is based on the [ Google Java Style ](https://google.github.io/styleguide/javaguide.html) reference and is work in progress.

## Source Type Basic
------------------

### File Encoding: UTF-8
Source files must be encoded using *UTF-8*.

### Indentation

- Indentation uses spaces (not tabs)
- Unix (LF), not DOS (CRLF) line endings
- Eliminate all trailing whitespace
	- On Linux, Mac, etc.: ``` find . -type f -name "*.cls" -exec perl -p -i -e "s/[ \t]$//g" {} \;```

### Apex source file organization

The following governs how the elements of a source file are organized:

- static fields
- normal fields
- constructors
- (private) methods called from constructors
- static factory methods
- JavaBean properties (i.e., getters and setters)
- method implementations coming from interfaces
- private or protected templates that get called from method implementations coming from interfaces
- other methods
- equals, hashCode, and toString

Note that private or protected methods called from method implementations should be placed immediately below the methods where they're used. In other words if there 3 interface method implementations with 3 private methods (one used from each), then the order of methods should include 1 interface and 1 private method in sequence, not 3 interface and then 3 private methods at the bottom.

Above all, the organization of the code should feel natural.

## Declaration Types
------------------
### Pascal Case

Example: **B**ack**C**olor

``` java

class BackColor {

}

```

### camel Case

> Example: **b**ack**C**olor

#### UPPER_CASE

> Example: BACK_COLOR

## Declaration
----------------

### Classes e Interfaces

> **PascalCase**
>
> Example: **S**ales**O**rder

``` java

public class SalesOrder  {

    Supplier supplier;
    Customer customer;
    Billto billto;
    Shipto shito;

    public SalesOrder() {
    }

}

```

### Methods


> **camelCase**
>
> Exemple: public void  **sendToApproval** () {}.

``` java

public class SalesOrder  {

    public void sendToApproval () {
        // some code ...
    }

}

```

### Instance attributes

>camelCase
>
>Exemplo: attributeName

### Constants and Enum Values

>UPPER_Case
>
>Exemple: READ_ONLY


``` java

public class SalesOrder  {

    public static final String APPROVED_STATUS = 'Approved';

}

public enum SalesOrderStatusType  {

    NEW,
    WAITING_FOR_APPROVAL,
    APPROVED,
    SHIPPED,
    BILLED,
    CLOSED

}

```

## Formatting

### Braces

#### Braces are used where optional

Braces are used with ``` if, for, do and while statements ``` , even when the body is empty or contains only a single statement.

#### Nonempty blocks: K & R style
Braces follow the Kernighan and Ritchie style [ ("Egyptian brackets") ](http://www.codinghorror.com/blog/2012/07/new-programming-jargon.html) for nonempty blocks and block-like constructs:

- No line break before the opening brace.
- Line break after the opening brace.
- Line break before the closing brace.
- Line break after the closing brace, only if that brace terminates a statement or terminates the body of a method, constructor, or named class. For example, there is no line break after the brace if it is followed by else or a comma.

Examples:

``` java

	// acceptable
    if ( condition() ) {
        try {
            something();
      	} catch (ProblemException e) {
        	recover();
      	}
    } else if (otherCondition()) {
      	somethingElse();
    } else {
      	lastThing();
    }

	// acceptable
	for ( String value : values ) {
		// some code;
	}

	// acceptable
	for ( String value : values ) someOperation();

	// acceptable
    if (condition()) return;

	// not acceptable
	if (condition()) something();
	else if (otherCondition()) somethingElse();
	else lastThing();

	// not acceptable
	try {  something(); } catch (ProblemException e) { recover(); }
	try {  something(); } catch (ProblemException e) {}


```

#### Block indentation: +4 spaces

Each time a new block or block-like construct is opened, the indent increases by four spaces. When the block ends, the indent returns to the previous indent level. The indent level applies to both code and comments throughout the block.

Continuation indent is 4 columns. Nested continuations may add 4 columns or 2 at each level.

``` java

// Bad.
//   - Line breaks are arbitrary.
//   - Scanning the code makes it difficult to piece the message together.
throw new IllegalStateException("Failed to process request" + request.getId()
	+ " for user " + user.getId() + " query: '" + query.getText()
	+ "'");

// Good.
//   - Each component of the message is separate and self-contained.
//   - Adding or removing a component of the message requires minimal reformatting.
throw new IllegalStateException("Failed to process"
	+ " request " + request.getId()
	+ " for user " + user.getId()
	+ " query: '" + query.getText() + "'");

```

Method declaration continuations.

``` java
    // Sub-optimal since line breaks are arbitrary and only filling lines.
    String downloadAnInternet(Internet internet, Tubes tubes,
        Blogosphere blogs, Amount<Long, Data> bandwidth) {
      tubes.download(internet);
      ...
    }

    // Acceptable.
    String downloadAnInternet(Internet internet, Tubes tubes, Blogosphere blogs,
        Amount<Long, Data> bandwidth) {
      tubes.download(internet);
      ...
    }

    // Nicer, as the extra newline gives visual separation to the method body.
    String downloadAnInternet(Internet internet, Tubes tubes, Blogosphere blogs,
        Amount<Long, Data> bandwidth) {

      tubes.download(internet);
      ...
    }

    // Also acceptable, but may be awkward depending on the column depth of the opening parenthesis.
    public String downloadAnInternet(Internet internet,
                                     Tubes tubes,
                                     Blogosphere blogs,
                                     Amount<Long, Data> bandwidth) {
      tubes.download(internet);
      ...
    }

    // Preferred for easy scanning and extra column space.
    public String downloadAnInternet(
        Internet internet,
        Tubes tubes,
        Blogosphere blogs,
        Amount<Long, Data> bandwidth) {

      tubes.download(internet);
      ...
    }
```

Don't break up a statement unnecessarily.

``` java
    // Bad.
    final String value =
        otherValue;

    // Good.
    final String value = otherValue;
```

##### Chained method calls

``` java
    // Bad.
    //   - Line breaks are based on line length, not logic.
    Iterable<Module> modules = ImmutableList.<Module>builder().add(new LifecycleModule())
        .add(new AppLauncherModule()).addAll(application.getModules()).build();

    // Good.
    //   - Calls are logically separated.
    //   - However, the trailing period logically splits a statement across two lines.
    Iterable<Module> modules = ImmutableList.<Module>builder().
        add(new LifecycleModule()).
        add(new AppLauncherModule()).
        addAll(application.getModules()).
        build();

    // Better.
    //   - Method calls are isolated to a line.
    //   - The proper location for a new method call is unambiguous.
    Iterable<Module> modules = ImmutableList.<Module>builder()
        .add(new LifecycleModule())
        .add(new AppLauncherModule())
        .addAll(application.getModules())
        .build();
```
#### No tabs
An oldie, but goodie.  We've found tab characters to cause more harm than good.


#### Class declaration

Try as much as possible to put the ```implements, extends``` section of a class declaration on the same line as the class itself.

Order the classes so that the most important comes first.

### Whitespace

####  Vertical Whitespace

A single blank line always appears:

- Between consecutive members or initializers of a class: fields, constructors, methods, nested classes, static initializers, and instance initializers.

A single blank line may also appear anywhere it improves readability, for example between statements to organize the code into logical subsections. A blank line before the first member or initializer, or after the last member or initializer of the class, is neither encouraged nor discouraged.

Multiple consecutive blank lines are permitted, but never required (or encouraged).

####  Horizontal whitespace

Beyond where required by the language or other style rules, and apart from literals, comments and Javadoc, a single ASCII space also appears in the following places only.

- Separating any reserved word, such as ``` if, for or catch ``` , from an open parenthesis ```(()``` that follows it on that line
- Separating any reserved word, such as else or catch, from a closing curly brace (}) that precedes it on that line
- On both sides of any binary or ternary operator. This also applies to the following "operator-like" symbols:
	- the colon (:) in an enhanced for ("foreach") statement
- After ,:; or the closing parenthesis ()) of a cast
- On both sides of the double slash (//) that begins an end-of-line comment. Here, multiple spaces are allowed, but not required.
- Between the type and variable of a declaration: List<String> list
- Optional just inside both braces of an array initializer
	- new int[] {5, 6} and new int[] { 5, 6 } are both valid
- Between a type annotation and [] or ....

This rule is never interpreted as requiring or forbidding additional space at the start or end of a line; it addresses only interior space.

#### Horizontal alignment: never required

**Terminology Note:** Horizontal alignment is the practice of adding a variable number of additional spaces in your code with the goal of making certain tokens appear directly below certain other tokens on previous lines.

``` java
private int x; // this is fine
private Color color; // this too

private int   x;      // not acceptable
private Color color;  // may leave it unaligned

```

## Field, class, and method declarations
--------------------------------

##### Modifier order

We follow the [Java Language Specification](http://docs.oracle.com/javase/specs/) for modifier
ordering (sections
[8.1.1](http://docs.oracle.com/javase/specs/jls/se7/html/jls-8.html#jls-8.1.1),
[8.3.1](http://docs.oracle.com/javase/specs/jls/se7/html/jls-8.html#jls-8.3.1) and
[8.4.3](http://docs.oracle.com/javase/specs/jls/se7/html/jls-8.html#jls-8.4.3)).

``` java
    // Bad.
    final volatile private String value;

    // Good.
    private final volatile String value;
```

## Variable naming

#### Extremely short variable names should be reserved for instances like loop indices.

``` java
    // Bad.
    //   - Field names give little insight into what fields are used for.
    class User {
 		private final int a;
      	private final String m;
      	...
    }

    // Good.
    class User {
    	private final int ageInYears;
      	private final String maidenName;
        ...
    }
```

#### Use Intention-Revealing Names

It is easy to say that names should reveal intent. What we want to impress upon you is that
we are serious about this. Choosing good names takes time but saves more than it takes.
So take care with your names and change them when you find better ones. Everyone who
reads your code (including you) will be happier if you do

``` java
// Bad
public List<int[]> getThem() {
    List<int[]> list1 = new ArrayList<int[]>();
    for (int[] x : theList)
        if (x[0] == 4)
            list1.add(x);
    return list1;
}

// Good
public List<int[]> getFlaggedCells() {
    List<int[]> flaggedCells = new ArrayList<int[]>();
    for (int[] cell : gameBoard)
        if (cell[STATUS_VALUE] == FLAGGED)
            flaggedCells.add(cell);
    return flaggedCells;
}

```

#### Don't embed metadata in variable names

A variable name should describe the variable's purpose. Adding extra information like scope and type is generally a sign of a bad variable name.

Avoid embedding the field type in the field name.

``` java

    // Bad.
	List<Account> accountList;
	Set<Account> accountSet;
	Map<Integer, User> idToUserMap;
    String valueString;

    // Good.
	// for all collections use plural !!!!!
	List<Account> accounts;
	Set<Account> accounts;

	// Map structure index something or group something
	Map<Integer, User> usersById;

	Map<String, List<User>> usersByState;

    String value;

```

Also avoid embedding scope information in a variable.  Hierarchy-based naming suggests that a class
is too complex and should be broken apart.


``` java
    // Bad.
    String _value;
    String mValue;

    // Good.
    String value;
```

#### Avoid Disinformation

``` java
// Bad
public List<int[]> getThem() {
    List<int[]> list1 = new ArrayList<int[]>();
    for (int[] x : theList)
        if (x[0] == 4)
            list1.add(x);
    return list1;
}

// Good
public List<int[]> getFlaggedCells() {
    List<int[]> flaggedCells = new ArrayList<int[]>();
    for (int[] cell : gameBoard)
        if (cell[STATUS_VALUE] == FLAGGED)
            flaggedCells.add(cell);
    return flaggedCells;
}

```

### Space pad operators and equals.

``` java
    // Bad.
    //   - This offers poor visual separation of operations.
    int foo=a+b+1;

    // Good.
    int foo = a + b + 1;
```
### Be explicit about operator precedence
Don't make your reader open the
[spec](http://docs.oracle.com/javase/tutorial/java/nutsandbolts/operators.html) to confirm,
if you expect a specific operation ordering, make it obvious with parenthesis.


``` java
    // Bad.
    return a << 8 * n + 1 | 0xFF;

    // Good.
    return (a << (8 * n) + 1) | 0xFF;
```

It's even good to be *really* obvious.


``` java
    if ((values != null) && (10 > values.size())) {
      ...
    }
```

## Exceptions

### Catch narrow exceptions
Sometimes when using try/catch blocks, it may be tempting to just `catch Exception`, `Error`,
or `Throwable` so you don't have to worry about what type was thrown.  This is usually a bad idea, as you can end up catching more than you really wanted to deal with.  For example, `catch Exception` would capture `System.QueryException`, and `catch System.DmlException`


``` java
    // Bad.
    //   - If a RuntimeException happens, the program continues rather than aborting.
    try {
      storage.insertUser(user);
    } catch (Exception e) {
      LOG.error("Failed to insert user.");
    }

    try {
      storage.insertUser(user);
    } catch (StorageException e) {
      LOG.error("Failed to insert user.");
    }
```

https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_exception_methods.htm

##### Don't swallow exceptions

An empty `catch` block is usually a bad idea, as you have no signal of a problem.  Coupled with [narrow exception](#catch-narrow-exceptions) violations, it's a recipe for disaster.

**Create custom exception classes 'extends Exception' to handle business errors**

**Don't hide system exceptions inside the Map and "log" classes to debug it - let it throw or handle in a specific application behavior**

##### Throw appropriate exception types
Let your API users obey [catch narrow exceptions](#catch-narrow-exceptions), don't throw Exception.
Even if you are calling another naughty API that throws Exception, at least hide that so it doesn't bubble up even further.  You should also make an effort to hide implementation details from your callers when it comes to exceptions.


``` java
    // Bad.
    //   - Caller is forced to catch Exception, trapping many unnecessary types of issues.
    interface DataStore {
      String fetchValue(String key) throws Exception;
    }

    // Better.
    //   - The interface leaks details about one specific implementation.
    interface DataStore {
      String fetchValue(String key) throws SQLException, UnknownHostException;
    }

    // Good.
    //   - A custom exception type insulates the user from the implementation.
    //   - Different implementations aren't forced to abuse irrelevant exception types.
    interface DataStore {
      String fetchValue(String key) throws StorageException;

      static class StorageException extends Exception {
        ...
      }
    }
```

## Writing testable code
-------------------------

Writing unit tests doesn't have to be hard. You can make it easy for yourself if you keep testability in mind while designing your classes and interfaces.

### Clean Tests (clean code)

What makes a clean test? Three things. Readability, readability, and readability. Read-
ability is perhaps even more important in unit tests than it is in production code. What
makes tests readable? The same thing that makes all code readable: clarity, simplicity,
and density of expression. In a test you want to say a lot with as few expressions as
possible.

The [BUILD-OPERATE-CHECK](http://fitnesse.org/FitNesse.AcceptanceTestPatterns) pattern is made obvious by the structure of these tests.
Each of the tests is clearly split into three parts. The first part builds up the test data, the second part operates on that test data, and the third part checks that the operation yielded the expected results.
Notice that the vast majority of annoying detail has been eliminated. The tests get
right to the point and use only the data types and functions that they truly need. Anyone
who reads these tests should be able to work out what they do very quickly, without being
misled or overwhelmed by details.

### Avoid mutable static state
Mutable static state is rarely necessary, and causes loads of problems when present.  A very simple case that mutable static state complicates is unit testing.  Since unit tests runs are typically in a single VM, static state will persist through all test cases.  In general, mutable static state is a sign of poor class design.

### Fakes and mocks

When testing a class, you often need to provide some kind of canned functionality as a replacement for real-world behavior. For example, rather than fetching a row from a real database, you have a test row that you want to return. This is most commonly performed with a fake object or a mock object. While the difference sounds subtle, mocks have major benefits over fakes.

```java

public virtual class HttpProxy {

    virtual
    public String get (String queryString) {
        // send http request;
    }
}

public class ZipCodeService {

    private HttpProxy proxy;
    private AddressTransformer transformer;

    // some proxy configuration omitted
    public Address getAddressDetails (String zipCode) {

        String responsePayload = proxy.get ('?zipCode=' + zipCode);

        return transformer.toAddress ( esponsePayload );
    }

    // 4 injection
    public void setHttpProxy ( HttpProxy proxy ) {
        this.proxy = proxy;
    }

}

/**
 * Mock HttpProxy behavior
 */
@isTest
public class HttpProxyMock extends HttpProxy {

    String payload;

    public HttpProxyMock() {
        super();
    }

    public HttpProxyMock(String payload) {
        this();
        this.payload = payload;
    }

    //Mock get method implementation
    override
    public String get (String queryString) {
        return payload;
    }

}

@isTest
private class ZipCodeServiceTest {

    // fixture factory for ZipCodeService
    public static ZipCodeService newZipCodeService ( String addressResponse ) {

        ZipCodeService service = new ZipCodeService();
        service.setHttpProxy ( new HttpProxyMock (addressResponse) );
        return service;
    }

    @isTest
    public static void givenValidZipCodeWhenServiceCalledThenReturnValidAddress () {

        String expectedAddressPayload = '{"street":"XXXX", "city":"New York", "countryCode":"US" ,"zipCode":"023782383"}';

        // Test setup - only valid for this scenario
        ZipCodeService service = newZipCodeService(expectedAddressPayload);

        // call service with HttpProxy Mocked
        Address address = service.getAddressDetails ('023782383');

        System.assert ( address.street == 'XXXX' );
        System.assert ( address.city == 'New York' );
        System.assert ( address.countryCode == 'US' );
        System.assert ( address.zipCode == '023782383' );
    }

}

```

### F.I.R.S.T.

Clean tests follow five other rules that form the above acronym:

- **Fast** Tests should be fast. They should run quickly. When tests run slow, you won’t want
to run them frequently. If you don’t run them frequently, you won’t find problems early
enough to fix them easily. You won’t feel as free to clean up the code. Eventually the code
will begin to rot.

- **Independent** Tests should not depend on each other. One test should not set up the condi-
tions for the next test. You should be able to run each test independently and run the tests in
any order you like. When tests depend on each other, then the first one to fail causes a cas-
cade of downstream failures, making diagnosis difficult and hiding downstream defects.

- **Repeatable** Tests should be repeatable in any environment. You should be able to run the
tests in the production environment, in the QA environment, and on your laptop while
riding home on the train without a network. If your tests aren’t repeatable in any environ-
ment, then you’ll always have an excuse for why they fail. You’ll also find yourself unable
to run the tests when the environment isn’t available.

- **Self-Validating** The tests should have a boolean output. Either they pass or fail. You
should not have to read through a log file to tell whether the tests pass. You should not have
to manually compare two different text files to see whether the tests pass. If the tests aren’t
self-validating, then failure can become subjective and running the tests can require a long
manual evaluation.

- **Timely** The tests need to be written in a timely fashion. Unit tests should be written just
before the production code that makes them pass. If you write tests after the production
code, then you may find the production code to be hard to test. You may decide that some
production code is too hard to test. You may not design the production code to be testable.

### Testing anti patterns

##### Time-dependence
Code that captures real wall time can be difficult to test repeatably, especially when time deltas
are meaningful. Therefore, try to avoid  'System.now()', 'System.today()'

##### Use test factory and @testSetup instead of seeAllData=true

https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_utility_classes.htm

https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_testsetup_using.htm


## Documentation

### Class header

``` java
/**
 * Class Description (optional)
 *
 * @author <Name> - <Company>
 */
```