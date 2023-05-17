## Code Review

Algumas orientações para facilitar o processo de code reviewing.

### Pull Request Checklist

- [x] Code Style
- [x] Aplicação da Regra do Escoteiro, conforme alguns pontos abaixo:
    * Refatoração de nomes de variáveis
    * Refatoração de nomes de método
    * Remoção de códigos comentados e System.debug's em produção
    * Refatoração de operações DMLs para classes Repository
    * Utilização de Fixture Factories para classes de Teste

#### A  regra do escoteiro

> [...] *Deixe a área do acampamento mais limpa do que como você a encontrou*.
>
> Robert C. Martin, "Clean Code", p. 14

Uncle Bob traz esta frase como uma referência adaptada que, trazendo a regra para o mundo da programação, ela significa deixar o código mais limpo do que estava antes de mexer nele.