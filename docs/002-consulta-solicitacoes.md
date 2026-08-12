# SPEC 002 — Consulta de Solicitações

**Status:** Hands-on
**Dependência:** SPEC 001 concluída
**Objetivo:** Permitir que o cidadão autenticado visualize suas solicitações e consulte os detalhes de uma solicitação específica.

---

## 1. História do usuário

Como cidadão autenticado
Quero visualizar minhas solicitações
Para acompanhar o andamento dos processos que iniciei.

---

## 2. Requisitos funcionais

### RF01 — Listar solicitações

O cidadão deve conseguir visualizar todas as solicitações associadas ao seu identificador.

Cada item deve apresentar:

* número;
* situação atual;
* data de criação;
* data da última atualização.

### RF02 — Consultar uma solicitação

O cidadão deve conseguir abrir uma solicitação e visualizar seus detalhes.

### RF03 — Isolamento entre cidadãos

Um cidadão não deve conseguir consultar solicitações pertencentes a outro cidadão.

### RF04 — Solicitação inexistente

A aplicação deve tratar adequadamente consultas a identificadores inexistentes.

---

## 3. API esperada

### Listar solicitações

```http
GET /api/solicitacoes
```

Resposta:

```json
[
  {
    "id": 1,
    "numero": "2026-000001",
    "status": "EmAnalise",
    "dataCriacao": "2026-08-01T10:00:00",
    "dataUltimaAtualizacao": "2026-08-10T15:30:00"
  }
]
```

Somente solicitações pertencentes ao usuário corrente devem ser retornadas.

---

### Consultar solicitação

```http
GET /api/solicitacoes/{id}
```

Resposta de sucesso:

```json
{
  "id": 1,
  "numero": "2026-000001",
  "status": "EmAnalise",
  "dataCriacao": "2026-08-01T10:00:00",
  "dataUltimaAtualizacao": "2026-08-10T15:30:00"
}
```

---

## 4. Regras de acesso

O identificador do cidadão deve ser obtido por meio da abstração de usuário corrente criada na SPEC 001.

A API não deve aceitar `cidadaoId` enviado pelo frontend para determinar a propriedade da solicitação.

Não utilizar:

```http
GET /api/solicitacoes?cidadaoId=cidadao-001
```

A identidade deve ser derivada do contexto do usuário corrente.

---

## 5. Comportamentos esperados

### Solicitação existente e pertencente ao usuário

Retornar:

```http
200 OK
```

### Solicitação inexistente

Retornar:

```http
404 Not Found
```

### Solicitação existente pertencente a outro cidadão

O sistema não deve expor dados da solicitação.

Para evitar exposição desnecessária sobre a existência de recursos pertencentes a outros usuários, utilizar:

```http
404 Not Found
```

como comportamento padrão.

---

## 6. Frontend

Criar uma página:

```text
Minhas Solicitações
```

Exemplo conceitual:

```text
Minhas Solicitações

2026-000001
Em análise
Atualizado em 10/08/2026
[Ver detalhes]

2026-000002
Aprovada
Atualizado em 08/08/2026
[Ver detalhes]
```

Ao selecionar uma solicitação, apresentar seus detalhes.

Exemplo:

```text
Solicitação 2026-000001

Status
Em análise

Criada em
01/08/2026

Última atualização
10/08/2026
```

---

## 7. Estados da interface

A aplicação deve tratar:

### Loading

Enquanto os dados estiverem sendo carregados.

### Lista vazia

Quando o cidadão não possuir solicitações.

Exemplo:

```text
Você ainda não possui solicitações.
```

### Erro

Quando houver falha ao consultar a API.

### Não encontrado

Quando a solicitação informada não puder ser encontrada.

---

## 8. Critérios de aceite

### AC01 — Listagem

Dado que `cidadao-001` esteja autenticado
E possua duas solicitações

Quando acessar a página de solicitações

Então deverá visualizar somente suas duas solicitações.

---

### AC02 — Isolamento

Dado que `cidadao-001` esteja autenticado
E exista uma solicitação pertencente a `cidadao-002`

Quando listar suas solicitações

Então a solicitação de `cidadao-002` não deverá ser retornada.

---

### AC03 — Detalhes

Dado que `cidadao-001` possua a solicitação `2026-000001`

Quando consultar seus detalhes

Então deverá visualizar:

* número;
* status;
* data de criação;
* data da última atualização.

---

### AC04 — Outro cidadão

Dado que `cidadao-001` esteja autenticado
E uma solicitação pertença a `cidadao-002`

Quando `cidadao-001` tentar consultar essa solicitação diretamente

Então a API deverá retornar:

```http
404 Not Found
```

E nenhum dado da solicitação deverá ser retornado.

---

### AC05 — Inexistente

Dado um identificador de solicitação inexistente

Quando o cidadão realizar a consulta

Então a API deverá retornar:

```http
404 Not Found
```

---

### AC06 — Lista vazia

Dado um cidadão que não possui solicitações

Quando acessar a página

Então deverá visualizar:

```text
Você ainda não possui solicitações.
```

---

## 9. Testes esperados

### Backend

Criar testes que validem:

* listagem do cidadão;
* isolamento entre cidadãos;
* consulta válida;
* solicitação inexistente;
* tentativa de acessar solicitação de outro cidadão;
* contrato HTTP.

Os testes de integração devem utilizar o MySQL real preparado pela SPEC 001.

### Frontend

Criar testes para:

* carregamento da lista;
* lista com dados;
* lista vazia;
* erro da API;
* abertura dos detalhes;
* solicitação não encontrada.

---

## 10. Restrições

A implementação deve:

* utilizar a arquitetura definida na SPEC 001;
* não alterar o modelo de autenticação;
* não expor o identificador interno do cidadão como parâmetro de autorização;
* não alterar contratos da SPEC 001 sem justificativa;
* não implementar histórico;
* não implementar criação ou edição de solicitações.

---

## 11. Resultado esperado

Ao término desta spec o usuário deverá conseguir realizar:

```text
Cidadão
   ↓
Frontend
   ↓
GET /api/solicitacoes
   ↓
Application
   ↓
MySQL
```

e:

```text
Cidadão
   ↓
Seleciona solicitação
   ↓
GET /api/solicitacoes/{id}
   ↓
Detalhes
```

com isolamento adequado entre cidadãos e cobertura automatizada dos principais comportamentos.
