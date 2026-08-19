# Converge

Realize uma revisão da implementação atual.

Não altere nenhum arquivo.

---

## Contexto

Leia:

1. a spec relacionada;
2. `docs/base/architecture.md`;
3. `docs/base/quality.md`;
4. os arquivos alterados;
5. os testes relacionados.

Analise preferencialmente o diff atual:

```bash
git diff
git diff --stat
```

Quando aplicável, compare também com a branch base.

---

## Requisitos

Verifique:

- requisitos não implementados;
- implementação divergente da spec;
- critérios de aceite não atendidos;
- comportamento adicional não solicitado;
- mudança de contrato não prevista.

---

## Bugs

Procure:

- erros lógicos;
- edge cases;
- regressões;
- tratamento incorreto de erros;
- comportamento inconsistente;
- problemas de concorrência quando aplicável;
- tratamento incorreto de valores nulos ou vazios.

---

## Arquitetura

Verifique:

- regras de negócio em controllers;
- dependências na direção incorreta;
- domínio dependendo de infraestrutura;
- acoplamento desnecessário;
- duplicação;
- abstrações desnecessárias;
- novos padrões introduzidos sem necessidade.

---

## Persistência

Verifique:

- migrations ausentes;
- problemas de mapeamento;
- risco de perda de dados;
- consultas incorretas;
- ausência de isolamento entre usuários;
- comportamento específico de MySQL sendo testado com banco in-memory.

---

## API

Verifique:

- códigos HTTP;
- contratos;
- tratamento de erro;
- exposição de detalhes internos;
- compatibilidade com contratos anteriores.

---

## Frontend

Verifique:

- estados de loading;
- estados de erro;
- interação;
- comportamento após resposta da API;
- inconsistências com o contrato da API;
- componentes excessivamente acoplados.

---

## Testes

Verifique:

- requisito sem cobertura;
- teste que não representa comportamento real;
- mocks excessivos;
- ausência de teste de regressão;
- testes que validam implementação interna em vez de comportamento.

---

## Segurança

Verifique:

- secrets;
- credenciais;
- exposição indevida de serviços;
- dados sensíveis em logs;
- configuração insegura.

---

## Resultado

Classifique somente problemas concretos como:

- CRITICAL
- HIGH
- MEDIUM
- LOW

Para cada achado informe:

- severidade;
- arquivo;
- localização aproximada;
- problema;
- impacto;
- correção recomendada.

Não liste preferências puramente estilísticas como defeitos.

Não sugira refactoring sem benefício concreto relacionado ao problema
encontrado.

Se não encontrar problemas relevantes, informe explicitamente.
