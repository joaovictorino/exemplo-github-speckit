# SPEC 004 — Deploy Privado no Azure

**Status:** Hands-on
**Dependências:** SPEC 001, SPEC 002 e SPEC 003 concluídas
**Objetivo:** Disponibilizar a aplicação em uma subscrição Azure já existente, com frontend e backend executados em Azure Container Apps e banco MySQL sem acesso público, usando Terraform para provisionar a infraestrutura até o nível do Resource Group.

---

## 1. Contexto

As funcionalidades das especificações anteriores são executadas localmente por Docker Compose. É necessário disponibilizá-las em um ambiente Azure único, reprodutível e isolado de acesso direto ao banco de dados e à API.

A subscrição Azure já existe e está fora do escopo de criação e administração desta especificação. O Terraform deverá iniciar o provisionamento pela criação do Resource Group e administrar somente os recursos definidos nesta SPEC.

---

## 2. História do usuário

Como responsável pela aplicação
Quero provisionar e publicar frontend, backend e banco de dados no Azure
Para que cidadãos acessem a aplicação pela internet, enquanto a API e os dados permaneçam protegidos em rede privada.

---

## 3. Arquitetura alvo

```text
Internet
   │ HTTPS
   ▼
Frontend — Azure Container Apps (ingresso externo)
   │ chamadas /api por endereço interno
   ▼
Backend — Azure Container Apps (ingresso interno)
   │ conexão privada
   ▼
Azure Database for MySQL Flexible Server (sem acesso público)

Terraform
   └── Subscrição Azure existente
         └── Resource Group
               ├── Azure Container Registry
               ├── Log Analytics Workspace
               ├── VNet e subnets
               ├── Azure Container Apps Environment
               ├── Container App do frontend
               ├── Container App do backend
               ├── Azure Database for MySQL Flexible Server
               └── Private DNS Zone do MySQL
```

O frontend será o único componente exposto à internet. O backend será acessível somente pelo ambiente de Container Apps. O servidor MySQL não terá endpoint ou regra de acesso público.

---

## 4. Requisitos funcionais

### RF01 — Código de infraestrutura

O repositório deve conter código Terraform versionado para provisionar a infraestrutura desta SPEC.

O código deve receber como entrada a identificação da subscrição existente, região, nomes ou prefixos dos recursos, credenciais administrativas iniciais do MySQL e referências das imagens de frontend e backend.

Segredos não devem ser gravados em arquivos versionados, variáveis padrão ou outputs de Terraform.

### RF02 — Modularização do Terraform

Os arquivos Terraform devem ser organizados em módulos reutilizáveis, com um módulo raiz responsável apenas pela composição dos recursos e pela passagem de variáveis e outputs entre módulos.

Cada módulo deve ter uma responsabilidade clara e coesa. No mínimo, a estrutura deve separar os recursos de:

* Resource Group;
* rede privada, subnets e DNS privado;
* registro de imagens;
* observabilidade;
* ambiente Azure Container Apps;
* aplicação de frontend;
* aplicação de backend;
* MySQL privado.

Os módulos devem declarar explicitamente suas próprias variáveis, recursos e outputs. Dependências entre módulos devem ocorrer por inputs e outputs declarados, sem referências diretas a arquivos internos de outro módulo.

### RF03 — Limite de gerenciamento

O Terraform deve criar o Resource Group e todos os recursos necessários dentro dele.

O Terraform não deve criar, excluir ou alterar a subscrição Azure existente, nem recursos externos ao Resource Group definido para esta aplicação.

### RF04 — Registro de imagens

Deve ser provisionado um Azure Container Registry para armazenar as imagens de container do frontend e do backend.

As Container Apps devem obter imagens a partir desse registro sem usar credenciais expostas no código-fonte ou nas configurações públicas das aplicações.

### RF05 — Ambiente de containers

Deve ser provisionado um único Azure Container Apps Environment integrado a uma Virtual Network.

Devem ser provisionadas duas Container Apps independentes:

* frontend, executando a imagem gerada para a aplicação React;
* backend, executando a imagem gerada para a API ASP.NET Core.

As aplicações devem receber configurações necessárias por variáveis de ambiente e segredos gerenciados pela plataforma, sem incorporar dados sensíveis nas imagens.

### RF06 — Exposição do frontend

O frontend deve aceitar tráfego HTTPS externo e disponibilizar uma URL pública fornecida pelo Azure.

O acesso público deve existir somente para o frontend. Domínio próprio, certificado personalizado, CDN e WAF não fazem parte desta SPEC.

### RF07 — Isolamento do backend

O backend deve possuir apenas ingresso interno, sem URL pública acessível pela internet.

O frontend deve encaminhar chamadas destinadas a `/api` para o endereço interno do backend, preservando os contratos HTTP já definidos nas SPECs 001 a 003.

### RF08 — MySQL privado

Deve ser provisionado um Azure Database for MySQL Flexible Server com acesso por rede privada.

O servidor deve ser associado a subnet delegada e Private DNS Zone adequadas. O acesso público deve permanecer desabilitado.

Somente o backend, por meio da rede privada e do DNS privado configurados, deve conseguir se conectar ao banco. O frontend não deve possuir credenciais nem rota de rede para o MySQL.

### RF09 — Persistência e migrações

O banco de produção deve usar armazenamento persistente e preservar dados durante uma atualização das Container Apps.

As migrations existentes no backend devem ser executadas de forma controlada antes de a nova versão da API atender tráfego, sem exigir acesso público ao MySQL.

### RF10 — Configuração da aplicação

O backend deve usar uma string de conexão compatível com o MySQL privado, fornecida como segredo.

O frontend deve ser configurado para consumir a API pelo caminho `/api`, sem depender de endereço público do backend.

### RF11 — Observabilidade mínima

Deve ser provisionado Log Analytics Workspace e integrado ao ambiente de Container Apps.

Logs do frontend e do backend devem ficar disponíveis para consulta centralizada. A API deve manter um endpoint de saúde compatível com a SPEC 001 para permitir verificação de disponibilidade.

### RF12 — Operação do Terraform

Deve haver instruções para autenticar no Azure, selecionar a subscrição existente, definir as variáveis obrigatórias, executar `terraform init`, `terraform plan` e `terraform apply`, além de obter a URL pública do frontend após o deploy.

O planejamento do Terraform deve permitir identificar previamente recursos a criar, alterar ou excluir.

---

## 5. Requisitos de segurança

### RS01 — Superfície pública mínima

Nenhuma rota pública deve expor diretamente o backend ou o MySQL.

### RS02 — Segredos

Senhas do MySQL, strings de conexão e outros valores sensíveis devem ser fornecidos fora do controle de versão e armazenados como segredos da plataforma quando consumidos pelas aplicações.

### RS03 — Rede privada

A comunicação backend–MySQL deve ocorrer pela VNet. A resolução do nome do MySQL deve usar DNS privado e não depender de exceções temporárias de firewall público.

---

## 6. Critérios de aceite

### AC01 — Provisionamento reprodutível

Dado uma subscrição existente e variáveis válidas

Quando o responsável executar o fluxo Terraform documentado

Então o Resource Group e todos os recursos descritos nesta SPEC deverão ser criados sem etapas manuais no portal Azure.

### AC02 — Acesso público controlado

Dado o ambiente provisionado

Quando um usuário acessar a URL pública do frontend por HTTPS

Então deverá conseguir carregar a aplicação.

E não deverá existir endpoint público para o backend ou o MySQL.

### AC03 — Comunicação interna com a API

Dado o frontend publicado

Quando a aplicação realizar uma chamada para `/api/solicitacoes`

Então a solicitação deverá alcançar o backend pelo ingresso interno.

E o contrato HTTP das funcionalidades das SPECs 002 e 003 deverá permanecer compatível.

### AC04 — Banco inacessível publicamente

Dado o servidor MySQL provisionado

Quando for tentada uma conexão pela internet pública

Então a conexão deverá ser recusada.

Quando o backend se conectar usando sua configuração privada

Então deverá conseguir acessar o banco.

### AC05 — Atualização sem perda de dados

Dado um banco com dados de solicitações

Quando uma nova imagem do backend for implantada e suas migrations forem executadas

Então os dados existentes deverão permanecer disponíveis após a atualização.

### AC06 — Diagnóstico operacional

Dado o ambiente em funcionamento

Quando uma requisição ao backend gerar um log ou ocorrer uma falha de inicialização

Então a informação deverá poder ser localizada no Log Analytics Workspace.

---

## 7. Fora do escopo

Esta SPEC não inclui:

* criação, gerenciamento ou cobrança da subscrição Azure;
* CI/CD, pipelines de build, publicação automática de imagens ou GitHub Actions;
* múltiplos ambientes (desenvolvimento, homologação e produção);
* domínio próprio, certificados personalizados, CDN, Azure Front Door, Application Gateway ou WAF;
* autenticação de usuários finais além do mecanismo de demonstração já estabelecido;
* alta disponibilidade multi-região, recuperação de desastre ou escalabilidade além das configurações básicas do Container Apps;
* acesso administrativo público ao MySQL.

---

## 8. Premissas

* A identidade que executará o Terraform possui permissões suficientes na subscrição existente para criar o Resource Group e os recursos listados.
* A região escolhida oferece Azure Container Apps Environment com integração de VNet e Azure Database for MySQL Flexible Server com acesso privado.
* As imagens de frontend e backend serão construídas a partir dos Dockerfiles definidos na SPEC 001 e disponibilizadas no Azure Container Registry.
* O ambiente inicial é único e destinado à demonstração ou produção de pequeno porte.
