# Implementação

Implemente a tarefa ou especificação solicitada.

## Antes de alterar código

Leia:

1. `docs/base/architecture.md`;
2. `docs/base/quality.md`;
3. o código relacionado à funcionalidade.

---

## Fonte da verdade

A spec é a fonte da verdade para:

- requisitos;
- comportamento;
- critérios de aceite.

Não implemente funcionalidades fora do escopo solicitado.

Não crie novos requisitos durante a implementação.

---

## Regras de implementação

Preserve:

- arquitetura existente;
- contratos existentes;
- convenções do projeto;
- compatibilidade com funcionalidades anteriores.

Evite:

- refactoring não relacionado;
- novas abstrações sem necessidade;
- novas dependências sem justificativa;
- alterações em arquivos não relacionados;
- implementação antecipada de requisitos futuros.

Antes de criar um novo componente, serviço, repository, helper, abstração ou
biblioteca, verifique se já existe algo equivalente no projeto.

---

## Implementação

Implemente a menor solução capaz de atender completamente aos requisitos.

Adicione ou atualize testes correspondentes ao comportamento alterado.

Não altere testes válidos apenas para fazer a implementação passar.

Quando uma mudança exigir alteração arquitetural relevante, sinalize a
divergência antes de introduzir um novo padrão.

---

## Validação

Ao terminar execute:

```bash
./scripts/validate.sh
```

Caso a validação falhe:

1. investigue a causa;
2. corrija;
3. execute novamente;
4. repita até que a validação passe.

Somente considere a implementação concluída quando a validação passar.

---

## Resposta final

Informe de forma objetiva:

- o que foi implementado;
- principais arquivos alterados;
- testes criados ou alterados;
- testes executados;
- resultado de `scripts/validate.sh`;
- riscos ou pendências encontradas.
