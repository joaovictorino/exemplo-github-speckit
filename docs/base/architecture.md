# Arquitetura da Solução

## 1. Objetivo

Este documento registra as decisões arquiteturais permanentes do projeto.

Requisitos funcionais, histórias de usuário e critérios de aceite pertencem às
especificações localizadas em `specs/`.

Em caso de conflito entre este documento e uma especificação funcional ativa,
a divergência deve ser identificada antes da implementação.

---

## 2. Visão geral

A aplicação permite que cidadãos acompanhem solicitações realizadas junto à
organização.

A arquitetura base é:

```text
Usuário
   │
   ▼
React Web Application
   │
   │ REST / JSON
   ▼
ASP.NET Core Web API
   │
   ▼
Application
   │
   ▼
Repository
   │
   ▼
Entity Framework Core
   │
   ▼
MySQL
```

A solução deve permanecer simples, testável e preparada para evolução
incremental por meio de novas especificações.

---

## 3. Stack tecnológica

### Backend

- C#
- ASP.NET Core Web API
- REST / JSON
- OpenAPI / Swagger
- Entity Framework Core
- MySQL

### Frontend

- React
- TypeScript
- componentes funcionais
- comunicação HTTP com a API

### Execução local

- Docker
- Docker Compose
- containers independentes para:
  - backend;
  - frontend;
  - migrations;
  - MySQL.

### Infraestrutura Azure

Quando aplicável às especificações de infraestrutura:

- Terraform;
- Azure Container Registry;
- Azure Container Apps;
- Azure Database for MySQL Flexible Server;
- Azure Virtual Network;
- Private DNS;
- Log Analytics.

---

## 4. Organização do backend

Estrutura conceitual:

```text
backend/src/

Api/
Application/
Domain/
Infrastructure/
```

### Api

Responsável por:

- endpoints HTTP;
- controllers;
- middleware;
- configuração da aplicação;
- OpenAPI;
- tradução entre HTTP e casos de uso.

Não deve conter regras de negócio.

### Application

Responsável por:

- casos de uso;
- serviços de aplicação;
- DTOs;
- contratos necessários à execução dos casos de uso;
- orquestração das regras de negócio.

Não deve depender diretamente de Entity Framework Core.

### Domain

Responsável por:

- entidades;
- regras e conceitos de domínio;
- value objects, quando necessários.

Não deve depender de infraestrutura.

### Infrastructure

Responsável por:

- Entity Framework Core;
- MySQL;
- implementações concretas de repositories;
- integrações técnicas;
- mecanismos concretos de autenticação quando introduzidos.

---

## 5. Direção das dependências

A direção esperada é:

```text
Api
 │
 ▼
Application
 │
 ▼
Domain

Infrastructure
      │
      └── implementa contratos consumidos por Application/Domain
```

Detalhes de infraestrutura não devem contaminar regras de negócio.

---

## 6. Persistência

O banco relacional da aplicação é MySQL.

Entity Framework Core é utilizado como detalhe de persistência.

Regras:

- migrations fazem parte do repositório;
- Application não depende diretamente de EF Core;
- entidades de persistência não devem ser retornadas diretamente pela API;
- mudanças de schema devem possuir migration correspondente;
- testes de persistência devem utilizar MySQL real;
- banco in-memory não substitui testes que validam comportamento específico do MySQL.

---

## 7. API

A API utiliza:

- REST;
- JSON;
- códigos HTTP adequados;
- OpenAPI;
- tratamento centralizado de erros.

Controllers devem ser finos e delegar comportamento aos casos de uso.

Erros internos e stack traces não devem ser expostos ao cliente.

Endpoint mínimo de saúde:

```http
GET /api/health
```

---

## 8. Usuário corrente

Casos de uso dependentes do usuário autenticado devem utilizar uma abstração
equivalente a:

```text
ICurrentUser
    Id
```

Regras de negócio não devem depender diretamente de:

- JWT;
- cookies;
- Microsoft Entra ID;
- Keycloak;
- OAuth;
- OpenID Connect.

O mecanismo concreto de autenticação é detalhe de infraestrutura.

---

## 9. Frontend

Organização conceitual:

```text
frontend/src/

components/
pages/
services/
types/
```

Responsabilidades:

- `components`: componentes reutilizáveis;
- `pages`: composição das telas;
- `services`: comunicação com APIs;
- `types`: contratos e tipos usados no frontend.

Regras:

- componentes não devem conhecer detalhes internos do backend;
- acesso HTTP deve ficar centralizado em serviços apropriados;
- estados de loading e erro devem ser tratados explicitamente;
- mudanças visuais não devem alterar contratos de API implicitamente.

---

## 10. Execução local

O ambiente local deve ser reproduzível por Docker Compose.

Fluxo canônico:

```bash
docker compose up --build
```

Devem ser orquestrados:

```text
frontend
backend
migration
mysql
```

sem preparação manual prévia do banco.

---

## 11. Testabilidade

### Testes unitários

Devem testar regras de negócio sem:

- servidor HTTP;
- banco de dados;
- infraestrutura externa.

### Testes de integração

Devem utilizar MySQL real, isolado e descartável.

### Testes da API

Quando pertinente, devem percorrer o caminho completo:

```text
HTTP
 ↓
API
 ↓
Application
 ↓
Repository
 ↓
MySQL
```

### Testes do frontend

Devem validar quando aplicável:

- renderização;
- interação;
- loading;
- erros;
- comportamento após respostas da API.

---

## 12. Arquitetura Azure

Quando executada a especificação de deploy Azure:

```text
Internet
   │
   ▼
Frontend — Azure Container Apps
   │
   │ /api
   ▼
Backend — Azure Container Apps
   │
   ▼
Azure Database for MySQL Flexible Server
```

Regras:

- somente o frontend possui ingresso público;
- backend possui ingresso interno;
- MySQL não possui acesso público;
- comunicação backend–MySQL ocorre por rede privada;
- infraestrutura é provisionada por Terraform;
- Terraform administra recursos a partir do Resource Group;
- a subscrição Azure existente está fora do escopo de gerenciamento.

---

## 13. Princípios arquiteturais

Ao tomar decisões:

1. preferir soluções simples;
2. evitar abstrações antecipadas;
3. não adicionar camadas sem necessidade concreta;
4. preservar separação entre negócio e infraestrutura;
5. preservar testabilidade;
6. reutilizar padrões existentes;
7. evitar dependências desnecessárias;
8. evoluir a arquitetura conforme necessidades reais das specs;
9. não implementar antecipadamente requisitos futuros;
10. evitar reorganizações estruturais extensas sem necessidade.

Mudanças arquiteturais relevantes devem ser deliberadas e documentadas,
não introduzidas silenciosamente durante uma implementação funcional.
