Autor: **Henrique Souza Silva Bustillos**

# Detalhamento técnico da integração

## User Story (Card) relacionada

Desenvolvido na Sprint X em Outubro de 2022
(link para o Card da US)

## Regras do Serviço

Esta integração deve ser executada por fluxo de trigger.

### Critério de aceite 1

#### QUANDO
For realizado a assinatura do Contrato (Contract)

#### E
O campo "Autorização de contato" (**Autorizacao_Contato__c**) do Contrato for igual a "Sim"

#### ENTÃO
A integração deverá ser executada assíncronamente assim que o Contrato for Assinado.

#### E
Neste cenário em espefício, o campo "options" da Request deverá ser preenchidas com os valores na tabela abaixo.
Obs.: vide **Payloads da Integração** no final do documento para mais detalhes.

```json
"options": [
    "SMS",
    "EMAIL"
]
```

### Critério de aceite 2

#### QUANDO
For realizado a assinatura do Contrato (Contract)

#### E
O campo Contract.**Autorizacao_Contato__c** for igual a "Não"

#### ENTÃO
A integração deverá ser executada assíncronamente assim que o Contrato for Assinado.

#### E
Neste cenário em espefício, o campo "options" da Request deverão ser vazias conforme exemplo abaixo.

```json
"options": []
```

### Critério de aceite 3

#### QUANDO
A integração for executada

#### ENTÃO
Após retornar uma Response de sucesso deverá salvar no campo Integration__c do Contrato (Contract) o valor 'true'.

## Mapeamento do Serviço Outbound

| | |
|---|---|
| Origem | Salesforce |
| Destino | Sistema externo (identificar) |
| Endpoint QA | (preencher) |
| Endpoint PROD | (preencher) |
| Método HTTP | POST |
| Tipo de Autenticação | Bearer Token |
| Barramento | (algum sistema intermediador?) |

## Mapeamento de campos

| Salesforce | Sistema externo | Obrigatório? | Tipo |
|-|-|-|-|
|  Contract.**CPF__c** OU <br> Contract.**CNPJ__c** | document| Sim | String |
| -- | email | Sim | String |
| -- | firstName | Sim | String |
| -- | lastName | Sim | String |
| Valor fixo (vide Payloads) | requestInformation | Sim | String |
| Valor fixo (vide Payloads) | purposes | Sim | List<Purpose>

Nesta integração, alinhado com o time do Sistema externo, os campos *firstName*, *lastName* e *email* devem ser enviados um . (ponto), devido o processo Salesforce hoje apenas exigir o nome completo da Conta (Account) em um campo único e o campo de email ser opcional.

## Payloads da integração

### Request

Payload de request no formato JSON que o Salesforce enviará ao Sistema externo.

A request **deve** ser enviada em um **objeto JSON único**.

O campo "document" pode ser enviado com ou sem formatação de CPF ou CNPJ.

```json
{
    "document": "204.401.990-69",
    "email": "teste@teste.com.br",
    "firstName": ".",
    "lastName": ".",
    "requestInformation": "aquiSeriaUmTokenFixoIssoÉUmTeste",
    "purposes": [
        {
            "id": "ad1wqd1qw89d1q0w9d9d4",
            "preferences": [
                {
                    "id": "qw4d16q5w1d6q5wd0q65w1d3",
                    "options": [
                        "SMS",
                        "EMAIL"
                    ]
                }
            ]
        }
    ]
}

```

### Response de sucesso

A única resposta de sucesso da integração será o Status Code 204 (No Content) com um body vazio.

```json

```

### Responses de erro

#### Erro de documento inválido

Payload de response de erro no formato JSON que o Sistema externo retornará quando o campo "document" for inválido.

```json
{
    "error": true,
    "message": "O documento informado é inválido"
}
```

#### Erro de canais (options) inválidos

Payload de response de erro no formato JSON que o Sistema externo retornará quando pelo menos uma das "options" for inválida.
Neste exemplo a option "PHONE_kCALL" é inválida.

```json
{
    "error": true,
    "message": "O canal SMSS não existe ou é inválido. Os canais disponíveis são: SMS, EMAIL"
}
```

---

# Diagrama de classes (Salesforce)

## Publicação do evento de integração

O evento é criado através do fluxo de trigger, conforme classes na imagem a seguir:

(imagem do diagrama de classes p/ o fluxo de trigger até a publicação do evento assíncrono)


## Execução do evento publicado (assíncrono / queueable OU single future call)

A Classe ExternalIntegrationOutboundCommand será executada na instância do framework de integrações e na imagem abaixo mostra suas dependências e classes para respectivas tratativas das operações.

(imagem do diagrama de classes p/ o fluxo de execução a partir do evento assíncrono)