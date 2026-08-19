# CLAUDE.md

## Projeto

Aplicação de acompanhamento de solicitações desenvolvida utilizando
Spec-Driven Development.

As funcionalidades são definidas por especificações em `specs/`.

---

## Ordem de leitura

Antes de implementar alterações relevantes, leia:

1. a spec ativa em `specs/`;
2. `docs/base/architecture.md`;
3. `docs/base/quality.md`;
4. o código relacionado.

Leia `plan.md` e `tasks.md` da spec quando existirem.

---

## Fontes de verdade

Cada conjunto de arquivos possui uma responsabilidade distinta:

```text
specs/
    requisitos, comportamento e critérios de aceite

docs/base/architecture.md
    decisões arquiteturais permanentes

docs/base/quality.md
    critérios de qualidade e Definition of Done

prompts/
    workflows operacionais reutilizáveis

scripts/
    build e validação determinísticos
```

Não replique requisitos funcionais em outros documentos.

---

## Princípios

- implementar somente o escopo solicitado;
- preferir soluções simples;
- preservar padrões existentes;
- evitar abstrações antecipadas;
- evitar refactoring não relacionado;
- não adicionar dependências sem necessidade concreta;
- não alterar contratos sem requisito explícito;
- investigar antes de corrigir problemas não triviais;
- preservar alterações existentes do usuário.

---

## Workflows

Para implementação:

`prompts/implement.md`

Para revisão:

`prompts/review.md`

Para correção:

`prompts/fix.md`

Para investigação:

`prompts/investigate.md`

---

## Validação

Antes de declarar uma implementação concluída execute:

```bash
./scripts/validate.sh
```

Uma tarefa não está concluída enquanto essa validação estiver falhando.

Não esconda falhas de validação.

Não altere testes válidos somente para fazer a validação passar.

---

## Git

Não realizar sem solicitação explícita:

- commit;
- push;
- merge;
- rebase;
- reset;
- operações destrutivas.

Não descartar alterações existentes que não tenham sido criadas durante a
tarefa atual.

Antes de modificar arquivos já alterados pelo usuário, preserve as mudanças
existentes.
