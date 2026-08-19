# Padrões de Qualidade

## 1. Objetivo

Este documento define os critérios mínimos de qualidade utilizados durante
implementação, correção e revisão.

As especificações em `specs/` definem o comportamento esperado.

Este documento define como avaliar se a implementação atende esse comportamento
com qualidade.

---

## 2. Definition of Done

Uma tarefa somente pode ser considerada concluída quando:

- os requisitos aplicáveis da spec foram implementados;
- o projeto compila;
- testes existentes continuam passando;
- testes necessários ao novo comportamento foram adicionados ou atualizados;
- não existem regressões conhecidas;
- contratos existentes foram preservados quando não houver mudança explícita;
- nenhuma informação sensível foi adicionada ao repositório;
- `scripts/validate.sh` termina com sucesso.

---

## 3. Regras gerais

Durante uma implementação:

- fazer a menor alteração capaz de atender ao requisito;
- preservar padrões existentes;
- evitar refactoring não relacionado;
- não adicionar frameworks ou bibliotecas sem necessidade concreta;
- não adicionar abstrações para requisitos hipotéticos;
- não duplicar lógica existente;
- não alterar requisitos para adaptar a implementação;
- não alterar testes válidos apenas para fazer a implementação passar;
- não implementar requisitos futuros antecipadamente.

---

## 4. Backend

Controllers devem:

- receber requisições HTTP;
- validar aspectos relacionados ao protocolo;
- delegar comportamento à Application;
- converter resultados em respostas HTTP.

Controllers não devem conter regras de negócio.

Application deve concentrar casos de uso.

Domain deve permanecer independente de:

- Entity Framework Core;
- ASP.NET Core;
- banco de dados;
- mecanismos concretos de autenticação.

Infrastructure deve conter detalhes técnicos como:

- EF Core;
- MySQL;
- repositories concretos;
- integrações externas.

---

## 5. API

Endpoints devem:

- utilizar contratos explícitos;
- retornar códigos HTTP adequados;
- não expor exceções internas;
- utilizar o tratamento padronizado de erros.

Entidades de persistência não devem ser retornadas diretamente.

Mudanças incompatíveis em contratos existentes precisam estar explicitamente
previstas pela spec.

---

## 6. Persistência

Alterações no modelo persistido devem:

- possuir migration quando necessário;
- preservar dados existentes quando aplicável;
- ser testadas contra MySQL real.

Não utilizar banco in-memory para validar comportamento específico do MySQL.

---

## 7. Testes do backend

### Unitários

Devem testar regras de negócio isoladamente.

Não devem exigir:

- banco;
- rede;
- servidor HTTP.

### Integração

Devem utilizar uma instância real e isolada de MySQL.

Devem validar quando pertinente:

- migrations;
- mapeamentos;
- persistência;
- consultas;
- isolamento de dados.

### HTTP / API

Quando o requisito envolver endpoints, os testes devem exercitar o fluxo
apropriado da aplicação.

Sempre que a intenção for validar integração real, evitar mocks de componentes
internos que façam parte do comportamento sob teste.

---

## 8. Frontend

Alterações relevantes de comportamento devem possuir testes quando aplicável.

Priorizar testes observáveis pelo usuário.

Testar:

- conteúdo renderizado;
- interação;
- loading;
- erros;
- comportamento após resposta da API.

Evitar testes excessivamente acoplados à implementação interna dos componentes.

---

## 9. Segurança

Nunca versionar:

- senhas;
- tokens;
- connection strings contendo credenciais;
- secrets;
- arquivos `.env` contendo valores reais.

Logs não devem expor dados sensíveis.

Backend e banco Azure não devem ser tornados públicos sem requisito explícito.

---

## 10. Terraform

Alterações Terraform devem passar por:

```bash
terraform fmt -check
terraform validate
```

Quando o ambiente e as credenciais estiverem disponíveis, executar também:

```bash
terraform plan
```

Módulos devem:

- possuir responsabilidade clara;
- declarar inputs e outputs explicitamente;
- não acessar detalhes internos de outros módulos.

Terraform não deve modificar recursos fora do escopo definido pela spec.

Segredos não devem ser gravados em:

- arquivos versionados;
- valores padrão de variáveis;
- outputs.

---

## 11. Validação obrigatória

Antes de concluir uma implementação executar:

```bash
./scripts/validate.sh
```

Se falhar:

1. identificar a causa;
2. corrigir;
3. executar novamente;
4. repetir até que a validação passe.

Nunca declarar uma tarefa concluída sabendo que a validação falha.

---

## 12. Critérios de revisão

Durante code review verificar pelo menos:

### Requisitos

- requisito ausente;
- comportamento divergente da spec;
- critérios de aceite não atendidos;
- comportamento adicional não solicitado.

### Bugs

- fluxo incorreto;
- edge cases;
- tratamento incorreto de erros;
- regressões.

### Arquitetura

- regra de negócio no controller;
- dependência de infraestrutura no domínio;
- duplicação;
- abstrações desnecessárias;
- novo padrão introduzido sem necessidade.

### Testes

- requisito sem teste relevante;
- teste que não cobre o comportamento;
- teste excessivamente mockado;
- persistência testada sem MySQL real;
- teste alterado apenas para mascarar defeito.

### Segurança

- secrets;
- exposição indevida;
- informações sensíveis em logs.

Achados devem ser classificados por severidade e ter impacto concreto.
Preferências puramente estilísticas não devem ser tratadas como defeitos.
