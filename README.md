# Exemplo utilizando GitHub SpecKit SDD com Copilot CLI

Este repositório tem como objetivo exemplificar o uso de Spec-Driven Development (SDD) utilizando o GitHub SpecKit e o Copilot CLI para o desenvolvimento de software.

Esta é a aplicação base para gestão de solicitações (Foundation Architecture), estruturada para oferecer uma separação clara de conceitos, testabilidade e facilidade de execução utilizando Docker Compose.

## 🚀 Arquitetura e Tecnologias

A aplicação é dividida em duas partes principais (Backend e Frontend) e utiliza as seguintes tecnologias:

### Backend

- **Linguagem / Framework:** C# / .NET 7 ou 8 (ASP.NET Core Web API)
- **Arquitetura:** Clean Architecture / Layered Architecture
  - `Api/`: Controladores, Middlewares, Program.cs
  - `Application/`: Serviços, DTOs, Interfaces de aplicação
  - `Domain/`: Entidades de domínio (ex: *Solicitacao*), Value Objects, Interfaces de domínio
  - `Infrastructure/`: Persistência de dados e Autenticação
- **Banco de Dados:** MySQL 8.x
- **ORM:** Entity Framework Core
- **Testes:** xUnit / NUnit / MSTest
  - Testes unitários focados nas regras de negócio e serviços
  - Testes de integração utilizando instâncias reais isoladas do MySQL (via Testcontainers ou orquestração Docker)

### Frontend

- **Linguagem / Framework:** React + TypeScript
- **Testes:** React Testing Library + Jest
- **Estrutura de Pastas:** Componentes, Páginas, Serviços, Tipos

---

## 🛠️ Como Executar o Projeto

Todo o ambiente de desenvolvimento foi pensado para ser executado com o mínimo de dependências na máquina host, utilizando contêineres Docker.

### Pré-requisitos

- [Docker](https://www.docker.com/) e [Docker Compose](https://docs.docker.com/compose/) instalados na máquina host.

### Subindo a Aplicação

Na raiz do repositório, execute o seguinte comando para inicializar todo o stack (Frontend, Backend, Banco de Dados e Migrations):

```bash
docker compose up --build
```

> **Nota:** As migrações do banco de dados e a carga de dados iniciais (Seed) são aplicadas automaticamente durante a inicialização do Docker Compose (via um contêiner específico de migração).

### Verificação dos Serviços

1. **Backend (API de Healthcheck):**
   Execute o comando abaixo ou acesse via navegador para garantir que a API está rodando corretamente:

   ```bash
   curl -fsS http://localhost/api/health
   ```

   *Retorno esperado:* `{"status":"ok"}`

2. **Frontend:**
   Abra o endereço [http://localhost](http://localhost) em seu navegador para visualizar a interface inicial.

---

## 🧪 Testes

### Executando Testes Unitários

Os testes unitários podem ser executados dentro do contêiner do backend ou localmente (caso você tenha o SDK do .NET instalado):

```bash
dotnet test --project backend/tests/UnitTests
```

### Executando Testes de Integração

Os testes de integração provisionam instâncias isoladas do MySQL, garantindo a fidelidade dos testes de persistência.

```bash
dotnet test --project backend/tests/IntegrationTests
```

---

## ⚙️ Migrações e Banco de Dados

Caso seja necessário rodar as migrações manualmente (a partir de dentro do contêiner do backend ou caso tenha ambiente local configurado):

```bash
dotnet ef database update --project backend/src/Infrastructure/Persistence
```

- Variáveis de ambiente são carregadas a partir de um arquivo `.env` (disponível na raiz do repositório).
- A documentação da API baseia-se em **OpenAPI (Swagger)**.

---
Para mais detalhes arquiteturais, veja os documentos contidos no diretório `specs/`.
