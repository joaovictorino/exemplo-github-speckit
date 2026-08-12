# SPEC 003 — Histórico da Solicitação

**Status:** Hands-on
**Dependências:** SPEC 001 e SPEC 002 concluídas
**Objetivo:** Permitir que o cidadão visualize o histórico de mudanças de uma solicitação sem alterar o comportamento existente da consulta de solicitações.

---

## 1. Nova necessidade

Após disponibilizar a consulta de solicitações, identificou-se que visualizar apenas o status atual não é suficiente.

O cidadão precisa entender como sua solicitação evoluiu ao longo do tempo.

---

## 2. História do usuário

Como cidadão
Quero visualizar o histórico da minha solicitação
Para entender quais etapas ela percorreu e quando cada mudança ocorreu.

---

## 3. Requisitos funcionais

### RF01 — Histórico

Cada solicitação poderá possuir zero ou mais eventos de histórico.

### RF02 — Dados do evento

Cada evento deve possuir:

* data e hora;
* situação correspondente;
* descrição pública.

### RF03 — Ordenação

Os eventos devem ser apresentados do mais recente para o mais antigo.

### RF04 — Segurança

Um cidadão somente poderá consultar o histórico de solicitações que lhe pertencem.

### RF05 — Compatibilidade

Os endpoints implementados na SPEC 002 devem continuar funcionando com o mesmo comportamento.

---

## 4. Modelo de domínio

Adicionar conceito equivalente a:

```text
HistoricoSolicitacao

Id
SolicitacaoId
Status
Descricao
DataHora
```

Uma solicitação poderá possuir:

```text
Solicitacao
     │
     │ 1:N
     ▼
HistoricoSolicitacao
```

---

## 5. API

Adicionar novo endpoint:

```http
GET /api/solicitacoes/{id}/historico
```

Exemplo:

```json
[
  {
    "status": "EmAnalise",
    "descricao": "Solicitação encaminhada para análise.",
    "dataHora": "2026-08-10T15:30:00"
  },
  {
    "status": "Recebida",
    "descricao": "Solicitação recebida pelo sistema.",
    "dataHora": "2026-08-01T10:00:00"
  }
]
```

---

## 6. Compatibilidade

Não alterar os contratos existentes:

```http
GET /api/solicitacoes
```

e:

```http
GET /api/solicitacoes/{id}
```

A implementação do histórico deve ser incremental.

Consumidores existentes da SPEC 002 não devem precisar ser modificados para continuar utilizando as funcionalidades anteriores.

---

## 7. Segurança

O acesso ao histórico deve utilizar exatamente o mesmo conceito de propriedade da solicitação utilizado na SPEC 002.

### Solicitação do usuário

```http
200 OK
```

### Solicitação inexistente

```http
404 Not Found
```

### Solicitação de outro cidadão

```http
404 Not Found
```

Nenhum evento de histórico deve ser retornado.

---

## 8. Frontend

Na tela de detalhes criada na SPEC 002, adicionar uma seção:

```text
Solicitação 2026-000001

Status atual
Em análise

Histórico

10/08/2026 15:30
Em análise
Solicitação encaminhada para análise.

01/08/2026 10:00
Recebida
Solicitação recebida pelo sistema.
```

A implementação pode utilizar:

* lista;
* timeline;
* outro componente simples equivalente.

Priorizar clareza em relação a complexidade visual.

---

## 9. Estados da interface

### Loading

Mostrar indicação de carregamento enquanto o histórico é consultado.

### Histórico vazio

Caso não existam eventos:

```text
Nenhum histórico disponível.
```

### Erro

Falha ao carregar o histórico não deve impedir necessariamente a visualização dos dados principais da solicitação.

A interface deve deixar claro que ocorreu um problema somente na obtenção do histórico.

---

## 10. Dados iniciais

Adicionar dados para a solicitação:

```text
2026-000001
```

Histórico:

```text
01/08/2026 10:00
Recebida
Solicitação recebida pelo sistema.

05/08/2026 09:15
EmAnalise
Solicitação encaminhada para análise.

10/08/2026 15:30
EmAnalise
Análise da documentação iniciada.
```

---

## 11. Critérios de aceite

### AC01 — Histórico

Dado que o cidadão possua uma solicitação com eventos de histórico

Quando acessar os detalhes da solicitação

Então deverá visualizar os eventos associados.

---

### AC02 — Ordenação

Dado que existam múltiplos eventos

Quando o histórico for apresentado

Então o evento mais recente deverá aparecer primeiro.

---

### AC03 — Isolamento

Dado que `cidadao-001` esteja autenticado
E a solicitação pertença a `cidadao-002`

Quando tentar consultar:

```http
GET /api/solicitacoes/{id}/historico
```

Então deverá receber:

```http
404 Not Found
```

E nenhum dado deverá ser exposto.

---

### AC04 — Histórico vazio

Dado que uma solicitação pertença ao cidadão
E não possua eventos de histórico

Quando acessar seus detalhes

Então a interface deverá exibir:

```text
Nenhum histórico disponível.
```

---

### AC05 — Compatibilidade

Dada a implementação da SPEC 003

Quando a suíte automatizada criada na SPEC 002 for executada

Então todos os testes anteriores deverão continuar passando.

---

### AC06 — API anterior

Dada a nova funcionalidade de histórico

Quando o consumidor chamar:

```http
GET /api/solicitacoes/{id}
```

Então a estrutura de resposta definida na SPEC 002 deverá permanecer compatível.

---

## 12. Testes esperados

### Backend

Adicionar testes para:

* histórico com múltiplos eventos;
* ordenação;
* histórico vazio;
* solicitação inexistente;
* acesso de outro cidadão;
* persistência dos eventos no MySQL;
* endpoint HTTP.

### Regressão

Executar toda a suíte da SPEC 002.

Nenhum teste existente deverá ser removido apenas para permitir a nova implementação.

Caso algum teste precise ser alterado, a razão deverá ser explicitamente justificada.

### Frontend

Adicionar testes para:

* renderização do histórico;
* ordenação;
* loading;
* histórico vazio;
* erro da consulta;
* preservação da tela de detalhes existente.

---

## 13. Análise de impacto esperada antes da implementação

Antes de modificar o código, analisar:

1. quais entidades existentes serão afetadas;
2. se uma nova migration é necessária;
3. quais repositories precisam ser alterados;
4. quais services serão impactados;
5. quais endpoints existentes devem permanecer inalterados;
6. quais componentes React serão modificados;
7. quais testes existentes cobrem os comportamentos afetados;
8. quais novos testes serão necessários.

A implementação não deve começar antes da geração desse plano.

---

## 14. Restrições

Não:

* alterar o mecanismo de usuário corrente;
* substituir tecnologias da SPEC 001;
* alterar contratos da SPEC 002 sem necessidade;
* incluir edição manual do histórico;
* incluir criação de solicitações;
* introduzir novos frameworks sem justificativa.

---

## 15. Resultado esperado

Antes:

```text
Solicitação
    ↓
Status atual
```

Depois:

```text
Solicitação
    │
    ├── Status atual
    │
    └── Histórico
          │
          ├── Evento N
          ├── Evento N-1
          └── Evento N-2
```

O principal objetivo técnico desta spec não é apenas adicionar uma tela.

Ela deve demonstrar que uma nova especificação pode evoluir software existente preservando:

* contratos;
* regras;
* testes;
* estrutura arquitetural;
* comportamento já entregue.
