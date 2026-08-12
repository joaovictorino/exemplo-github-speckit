# SPEC 001 — Foundation e Baseline Arquitetural

**Status:** Executada antes do hands-on
**Objetivo:** Criar a fundação técnica da aplicação de acompanhamento de solicitações, estabelecendo arquitetura, padrões de desenvolvimento, persistência, testes automatizados e contratos básicos que serão utilizados pelas próximas funcionalidades.

---

## 1. Contexto

Será construída uma aplicação web para que cidadãos possam acompanhar solicitações realizadas junto à organização.

A aplicação deverá servir como base para evolução incremental por meio de novas especificações.

Esta especificação não implementa casos de uso completos de negócio. Seu objetivo é estabelecer uma fundação técnica simples, testável e evolutiva.

A fundação deve ser executável integralmente por meio de Docker e Docker Compose, permitindo subir backend, frontend, migration e banco de dados com um único comando, sem exigir instalação manual de dependências na máquina do desenvolvedor.

---

## 2. Stack tecnológica

### Backend

* ASP.NET Core Web API
* C#
* API REST
* OpenAPI
* acesso a dados com Entity Framework Core
* MySQL

### Frontend

* React
* TypeScript
* consumo da API via HTTP
* componentes funcionais
* organização simples por páginas, componentes e serviços

### DevOps

* Container Docker no backend
* Container Migration no backend
* Container Docker no nginx frontend
* Docker compose com backend, frontend, migration e mysql

### Testes

Backend:

* testes unitários para regras de negócio;
* testes de integração utilizando MySQL real dedicado aos testes;
* testes HTTP da API.

Frontend:

* testes de componentes;
* testes das principais interações do usuário;
* mocks somente para dependências externas quando necessário.

---

## 3. Princípios arquiteturais

A solução deve:

1. separar regras de negócio de detalhes de infraestrutura;
2. evitar regras de negócio diretamente nos controllers;
3. permitir testes das regras sem necessidade de iniciar toda a aplicação;
4. permitir testes de persistência contra MySQL real;
5. manter o frontend desacoplado da implementação interna do backend;
6. expor contratos HTTP explícitos (Swagger);
7. possuir tratamento padronizado de erros;
8. permitir evolução incremental sem reorganizações estruturais extensas;
9. evitar abstrações sem necessidade concreta;
10. privilegiar simplicidade em relação a frameworks ou padrões excessivos;
11. permitir os testes locais emulando todo o ambiente com Docker e Docker Compose.

---

## 4. Visão de arquitetura

### Contexto

```text
┌──────────────┐
│   Cidadão    │
└──────┬───────┘
       │
       │ HTTPS
       ▼
┌──────────────┐
│ React Web App│
└──────┬───────┘
       │
       │ REST / JSON
       ▼
┌──────────────┐
│ ASP.NET Core │
│     API      │
└──────┬───────┘
       │
       │ EF Core
       ▼
┌──────────────┐
│    MySQL     │
└──────────────┘
```

### Visão interna do backend

```text
HTTP Request
     │
     ▼
┌─────────────┐
│ Controller  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Application │
│   Service   │
└──────┬──────┘
       │
       ├───────────────┐
       ▼               ▼
┌─────────────┐   ┌─────────────┐
│ Repository  │   │Current User │
│ Interface   │   │ Abstraction │
└──────┬──────┘   └─────────────┘
       │
       ▼
┌─────────────┐
│ EF Core /   │
│    MySQL    │
└─────────────┘
```

---

## 5. Estrutura esperada

Uma estrutura possível:

```text
/
├── backend/
│   ├── src/
│   │   ├── Api/
│   │   ├── Application/
│   │   ├── Domain/
│   │   └── Infrastructure/
│   │
│   ├── tests/
│   │   ├── UnitTests/
│   │   └── IntegrationTests/
│   │
│   └── Dockerfile
│
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   └── types/
│   │
│   ├── tests/
│   │
│   └── Dockerfile
│
├── docker-compose.yml
│
└── specs/
```

A estrutura final pode ser ajustada durante o planejamento técnico, desde que os princípios desta especificação sejam mantidos.

O `docker-compose.yml` deve orquestrar backend, frontend, migration e MySQL. Cada componente executável (backend e frontend) deve possuir seu próprio `Dockerfile`.

Não criar camadas ou projetos adicionais sem necessidade concreta.

---

## 6. Persistência

O sistema deve utilizar MySQL como banco de dados relacional.

A camada de aplicação não deve depender diretamente de Entity Framework Core.

A persistência deve ser acessada por contratos apropriados definidos pela aplicação ou domínio.

As migrations devem fazer parte do repositório.

---

## 7. Modelo inicial

Criar inicialmente a entidade `Solicitacao`, suficiente para suportar as próximas specs.

A entidade deve possuir pelo menos:

```text
Solicitacao

Id
Numero
CidadaoId
Status
DataCriacao
DataUltimaAtualizacao
```

Dados adicionais não devem ser criados antecipadamente sem necessidade funcional.

### Status iniciais

Utilizar inicialmente:

```text
Recebida
EmAnalise
Aprovada
Rejeitada
```

---

## 8. Usuário autenticado

A aplicação deve considerar que os casos de uso poderão depender do usuário autenticado.

Criar uma abstração equivalente a:

```text
ICurrentUser
    Id
```

Nenhuma regra de negócio deve depender diretamente de mecanismos específicos como:

* JWT;
* cookies;
* Microsoft Entra ID;
* Keycloak;
* OAuth;
* OpenID Connect.

Para o ambiente de demonstração deverá existir uma implementação de desenvolvimento capaz de representar um usuário previamente conhecido.

Exemplo conceitual:

```text
CurrentUser.Id = "cidadao-001"
```

A implementação real de autenticação poderá ser adicionada posteriormente sem alterar os casos de uso.

---

## 9. API

A API deverá:

* utilizar JSON;
* possuir documentação OpenAPI;
* utilizar códigos HTTP adequados;
* possuir respostas de erro padronizadas;
* não expor exceções internas;
* não retornar entidades de persistência diretamente.

Criar endpoint básico:

```http
GET /api/health
```

Resultado esperado:

```http
200 OK
```

Esse endpoint será utilizado somente para verificar que a aplicação está funcionando.

---

## 10. Tratamento de erros

A API deve possuir tratamento centralizado de erros.

Erros funcionais conhecidos devem ser convertidos para respostas HTTP apropriadas.

Erros inesperados devem retornar resposta genérica, sem detalhes internos da aplicação.

Formato conceitual:

```json
{
  "type": "validation_error",
  "title": "Dados inválidos",
  "status": 400
}
```

---

## 11. Dados iniciais

O ambiente de desenvolvimento deverá possuir dados suficientes para as specs seguintes.

Criar pelo menos:

```text
cidadao-001

Solicitação 2026-000001
Status: EmAnalise

Solicitação 2026-000002
Status: Aprovada
```

E:

```text
cidadao-002

Solicitação 2026-000003
Status: Recebida
```

Isso permitirá testar posteriormente isolamento de dados entre usuários.

---

## 12. Estratégia de testes do backend

### Testes unitários

Devem testar regras de negócio sem banco real ou servidor HTTP.

### Testes de integração com MySQL

Os testes devem executar contra uma instância MySQL real dedicada à execução automatizada.

O banco deve ser:

* criado automaticamente durante os testes;
* isolado do banco de desenvolvimento;
* descartável;
* inicializado com migrations da aplicação.

Os testes devem validar pelo menos:

* conexão;
* migrations;
* persistência;
* consultas;
* mapeamentos.

Não utilizar banco in-memory como substituto para os testes que pretendem validar comportamento específico do MySQL.

### Testes da API

A aplicação deverá possuir testes HTTP capazes de iniciar a API em ambiente de teste e executar chamadas reais contra os endpoints.

Fluxo esperado:

```text
Teste
  ↓
HTTP Request
  ↓
ASP.NET Core
  ↓
Application
  ↓
Repository
  ↓
MySQL de teste
```

Assim, os testes exercitam o caminho completo da aplicação.

---

## 13. Estratégia de testes do frontend

O frontend deve possuir infraestrutura para testar:

* renderização de páginas;
* estados de loading;
* estados de erro;
* interação com elementos;
* dados retornados pela API.

Não é necessário criar uma suíte extensa nesta especificação.

O objetivo é preparar a infraestrutura para que cada nova spec adicione seus respectivos testes.

---

## 14. Critérios de aceite

### AC01 — Backend executável

Dado o projeto configurado
Quando o backend for iniciado
Então a API deverá iniciar sem erros.

### AC02 — Banco

Dado o backend configurado
Quando a aplicação acessar o banco
Então deverá conectar ao MySQL utilizando a configuração do ambiente.

### AC03 — Migration

Dado um banco vazio
Quando as migrations forem executadas
Então a estrutura necessária deverá ser criada.

### AC04 — Health

Dado o backend em execução
Quando for realizado:

```http
GET /api/health
```

Então deverá retornar:

```http
200 OK
```

### AC05 — Testes MySQL

Dado o conjunto de testes de integração
Quando os testes forem executados
Então uma instância MySQL isolada deverá ser utilizada e os testes deverão executar sem dependência de banco previamente instalado ou preparado manualmente.

### AC06 — Testes HTTP

Dada a suíte de integração
Quando um teste da API for executado
Então deverá ser possível enviar uma requisição HTTP à aplicação e validar a resposta.

### AC07 — Frontend

Dado o frontend configurado
Quando a aplicação for iniciada
Então deverá ser apresentada uma página inicial funcional.

### AC08 — Usuário corrente

Dado o ambiente de desenvolvimento
Quando um caso de uso solicitar o usuário atual
Então deverá receber o identificador configurado para o usuário de demonstração.

### AC09 — Ambiente via Docker Compose

Dado o repositório clonado, sem nenhuma dependência previamente instalada na máquina
Quando for executado `docker compose up`
Então backend, frontend, migration e MySQL deverão subir corretamente e a aplicação deverá ficar acessível de ponta a ponta.

---

## 15. Fora do escopo

Não implementar nesta especificação:

* autenticação OAuth/OIDC real;
* autorização por papéis;
* histórico de solicitações;
* tela de consulta de solicitações;
* cadastro de solicitações;
* edição de solicitações;
* notificações;
* upload de arquivos;
* filas;
* cache;
* infraestrutura cloud.

Esses requisitos deverão surgir de especificações próprias.

---

## 16. Resultado esperado

Após a execução da SPEC 001 deverá existir uma aplicação executável contendo:

```text
React
   ↓
ASP.NET Core API
   ↓
Application
   ↓
Repository
   ↓
MySQL
```

com:

* estrutura inicial;
* modelo de solicitação;
* migrations;
* usuário de demonstração;
* OpenAPI;
* tratamento de erros;
* testes unitários;
* testes de integração com MySQL;
* testes HTTP da API;
* infraestrutura inicial de testes do frontend;
* Dockerfiles do backend e do frontend;
* `docker-compose.yml` capaz de subir toda a aplicação (backend, frontend, migration e MySQL) com um único comando.

Esta versão constitui o baseline sobre o qual novas especificações serão implementadas.
