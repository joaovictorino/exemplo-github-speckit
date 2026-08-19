# Correção de Bug

Corrija o problema informado.

---

## Antes de alterar código

Leia:

- descrição do problema;
- spec relacionada;
- `docs/architecture.md`;
- `docs/quality.md`;
- código relacionado;
- testes relacionados.

Não comece alterando código imediatamente.

---

## Investigação

Primeiro:

1. reproduza o problema quando possível;
2. identifique o fluxo responsável;
3. determine a causa raiz;
4. identifique o menor conjunto de arquivos necessário para a correção.

Não corrija apenas o sintoma se a causa raiz puder ser identificada.

Diferencie fatos confirmados de hipóteses.

---

## Implementação

Faça a menor alteração capaz de corrigir o problema.

Preserve:

- comportamento não relacionado;
- contratos existentes;
- arquitetura atual;
- compatibilidade com requisitos anteriores.

Evite:

- refactoring não relacionado;
- mudança arquitetural não necessária;
- alteração de contratos sem necessidade;
- novas dependências;
- alterações em arquivos não envolvidos.

Não altere testes válidos apenas para fazê-los passar.

Adicione teste de regressão quando aplicável.

---

## Validação

Execute:

```bash
./scripts/validate.sh
```

Se falhar:

1. investigue;
2. corrija;
3. execute novamente.

Não considere a correção concluída enquanto a validação estiver falhando.

---

## Resultado

Informe:

- causa raiz;
- correção realizada;
- arquivos alterados;
- teste de regressão criado ou atualizado;
- resultado da validação;
- eventuais riscos restantes.
