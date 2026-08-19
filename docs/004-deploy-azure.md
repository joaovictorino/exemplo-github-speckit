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
   │ inicializa o Nginx com o endereço interno da API e encaminha /api
   ▼
Backend — Azure Container Apps (ingresso interno)
Migration — Azure Container Apps Job (sem ingresso)
   │ identidade gerenciada atribuída pelo usuário: lê o segredo no Key Vault
   ├──────────────► Azure Key Vault
   │
   │ conexão privada por Private Endpoint
   ▼
Azure Database for MySQL Flexible Server (sem acesso público)

Terraform 
  ├── Backend remoto 
│ |   └── Azure Blob Storage 
│ |       └── terraform.tfstate   
  └── Subscrição Azure existente
         └── Resource Group
               ├── Azure Container Registry
               ├── Log Analytics Workspace
               ├── VNet e subnets
               ├── Azure Container Apps Environment
               ├── Container App do frontend
               ├── Container App do backend
               ├── Container Apps Job de migration
               ├── Azure Database for MySQL Flexible Server
               ├── Private Endpoint e Private DNS Zone do MySQL
               ├── Azure Key Vault
               └── Identidade gerenciada atribuída pelo usuário
```

O frontend será o único componente exposto à internet. O backend será acessível somente pelo ambiente de Container Apps. O servidor MySQL não terá acesso público: API e migration o alcançarão exclusivamente pelo Private Endpoint e pela zona DNS privada `privatelink.mysql.database.azure.com`.

O estado do Terraform deverá ser armazenado remotamente em Azure Blob Storage, utilizando o backend azurerm.

O Storage Account e o container utilizados pelo backend remoto são considerados recursos de bootstrap da infraestrutura e devem existir antes da execução de terraform init. Eles não fazem parte do ciclo de vida dos recursos provisionados por esta SPEC.

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
* MySQL privado, Private Endpoint e DNS privado;
* Key Vault;
* identidade gerenciada atribuída pelo usuário.

Os módulos devem declarar explicitamente suas próprias variáveis, recursos e outputs. Dependências entre módulos devem ocorrer por inputs e outputs declarados, sem referências diretas a arquivos internos de outro módulo.

### RF03 — Limite de gerenciamento

O Terraform deve criar o Resource Group e todos os recursos necessários dentro dele.

O Terraform não deve criar, excluir ou alterar recursos externos ao Resource Group da aplicação. O acesso ao Azure Blob Storage utilizado como backend remoto limita-se à leitura e gravação do estado Terraform e não implica gerenciamento do ciclo de vida desse Storage Account.

### RF04 — Registro de imagens

Deve ser provisionado um Azure Container Registry para armazenar as imagens de container do frontend e do backend.

As Container Apps devem obter imagens a partir desse registro sem usar credenciais expostas no código-fonte ou nas configurações públicas das aplicações.

### RF05 — Ambiente de containers

Deve ser provisionado um único Azure Container Apps Environment integrado a uma Virtual Network.

Devem ser provisionadas duas Container Apps independentes:

* frontend, executando a imagem gerada para a aplicação React;
* backend, executando a imagem gerada para a API ASP.NET Core.

As aplicações devem receber configurações necessárias por variáveis de ambiente e segredos gerenciados pela plataforma, sem incorporar dados sensíveis nas imagens.

A API e o Job de migration devem compartilhar uma identidade gerenciada atribuída pelo usuário. Essa identidade deve possuir apenas as permissões necessárias para baixar imagens do registro e ler os segredos usados pelas duas cargas.

### RF06 — Exposição do frontend

O frontend deve aceitar tráfego HTTPS externo e disponibilizar uma URL pública fornecida pelo Azure.

O acesso público deve existir somente para o frontend. Domínio próprio, certificado personalizado, CDN e WAF não fazem parte desta SPEC.

### RF07 — Isolamento do backend

O backend deve possuir apenas ingresso interno, sem URL pública acessível pela internet.

O frontend deve encaminhar chamadas destinadas a `/api` para o endereço interno do backend, preservando os contratos HTTP já definidos nas SPECs 001 a 003.

A imagem do frontend deve conter um script de inicialização que receba o endereço interno da API por variável de ambiente, valide-o e substitua somente um marcador previamente definido na configuração do Nginx antes de iniciar o servidor. A configuração local deve fornecer o endereço do serviço `backend`; o ambiente Azure deve fornecer o FQDN interno da API. O frontend não deve depender de endereço público da API.

### RF08 — MySQL privado

Deve ser provisionado um Azure Database for MySQL Flexible Server com acesso privado por Azure Private Endpoint.

O Private Endpoint deve ficar em subnet da VNet da aplicação e ser resolvido por uma Private DNS Zone `privatelink.mysql.database.azure.com` vinculada à VNet. O acesso público ao servidor deve permanecer desabilitado e não devem existir regras de firewall público.

Somente a API e o Job de migration, por meio da rede privada e do DNS privado configurados, devem conseguir se conectar ao banco. O frontend não deve possuir credenciais nem rota de rede para o MySQL.

### RF09 — Persistência e migrações

O banco de produção deve usar armazenamento persistente e preservar dados durante uma atualização das Container Apps.

As migrations existentes no backend devem ser executadas de forma controlada antes de a nova versão da API atender tráfego, sem exigir acesso público ao MySQL.

### RF10 — Configuração da aplicação

O backend e o Job de migration devem usar uma string de conexão compatível com o MySQL privado, fornecida pelo Azure Key Vault. A referência ao segredo deve usar a identidade gerenciada atribuída pelo usuário; a string de conexão não deve ser enviada como valor para as Container Apps nem para o Terraform.

O frontend deve ser configurado para consumir a API pelo caminho `/api`, sem depender de endereço público do backend.

### RF11 — Observabilidade mínima

Deve ser provisionado Log Analytics Workspace e integrado ao ambiente de Container Apps.

Logs do frontend e do backend devem ficar disponíveis para consulta centralizada. A API deve manter um endpoint de saúde compatível com a SPEC 001 para permitir verificação de disponibilidade.

### RF12 — Operação do Terraform

Deve haver instruções para autenticar no Azure, selecionar a subscrição existente, definir as variáveis obrigatórias, executar `terraform init`, `terraform plan` e `terraform apply`, além de obter a URL pública do frontend após o deploy.

O planejamento do Terraform deve permitir identificar previamente recursos a criar, alterar ou excluir.

### RF13 — Backend remoto do Terraform

O Terraform deve utilizar backend remoto azurerm para armazenamento do arquivo de estado em Azure Blob Storage.

A configuração deve permitir informar, durante a inicialização do Terraform, os seguintes dados do backend:

Resource Group que contém o Storage Account de estado;
nome do Storage Account;
nome do Blob Container;
chave utilizada para identificar o arquivo de estado da aplicação.

O arquivo terraform.tfstate não deve ser armazenado localmente como mecanismo principal de persistência e não deve ser versionado no repositório.

O backend remoto deve ser inicializado por meio de terraform init, utilizando parâmetros externos ao código versionado quando necessário.

Credenciais, access keys, SAS tokens ou outros segredos de acesso ao Storage Account não devem ser gravados no repositório.

Sempre que possível, a autenticação no backend deverá utilizar a identidade autenticada no Azure, evitando credenciais estáticas.

### Complemento ao RF12 — Operação do Terraform

As instruções operacionais devem incluir:

autenticação no Azure;
seleção da subscrição existente;
configuração das variáveis obrigatórias;
configuração dos parâmetros do backend remoto Azure Blob Storage;
execução de terraform init;
execução de terraform plan;
execução de terraform apply;
obtenção da URL pública do frontend após o deploy.

A inicialização deverá usar o backend remoto configurado para a aplicação, garantindo que execuções posteriores utilizem o mesmo estado compartilhado.

Exemplo conceitual:

terraform init \
  -backend-config="resource_group_name=<rg-do-state>" \
  -backend-config="storage_account_name=<storage-do-state>" \
  -backend-config="container_name=<container-do-state>" \
  -backend-config="key=<nome-do-state>.tfstate"

Valores específicos de ambiente não devem ser codificados diretamente nos arquivos Terraform quando puderem ser fornecidos durante a inicialização.

### RF14 — Automação one shot de deploy

Deve existir um único script de automação para provisionar e publicar a aplicação. Ele deve validar os pré-requisitos, inicializar o Terraform com o backend remoto, criar a infraestrutura base necessária para o registro de imagens, compilar e publicar as imagens de frontend e backend no Azure Container Registry, gravar ou atualizar a string de conexão no Azure Key Vault, concluir o provisionamento das cargas e executar as migrations antes de validar a saúde da API e do frontend.

O script deve aceitar uma tag de imagem informada pelo operador e, quando ela não for informada, usar uma tag derivada do commit atual. Ele deve falhar sem expor segredos e retornar erro quando qualquer etapa ou verificação de saúde não for bem-sucedida. Reexecuções devem reconciliar a infraestrutura e atualizar as imagens e o segredo sem exigir passos manuais no portal.

---

## 5. Requisitos de segurança

### RS01 — Superfície pública mínima

Nenhuma rota pública deve expor diretamente o backend ou o MySQL.

### RS02 — Segredos

Senhas do MySQL, strings de conexão e outros valores sensíveis devem ser fornecidos fora do controle de versão. A string de conexão deve ser gravada no Azure Key Vault pelo fluxo de automação e consumida pela API e pelo Job de migration por referência de segredo e identidade gerenciada; seu valor não pode ser exposto em logs, outputs ou configurações de Container Apps.

### RS03 — Rede privada

A comunicação API/migration–MySQL deve ocorrer pela VNet e pelo Private Endpoint. A resolução do nome do MySQL deve usar a zona DNS privada `privatelink.mysql.database.azure.com` e não depender de exceções temporárias de firewall público.

---

## 6. Critérios de aceite

### AC01 — Provisionamento reprodutível

Dado uma subscrição existente e variáveis válidas

Quando o responsável executar o fluxo Terraform documentado

Então o Resource Group e todos os recursos descritos nesta SPEC deverão ser criados sem etapas manuais no portal Azure.

### Complemento ao AC01 — Provisionamento reprodutível

Dado uma subscrição existente, um backend Azure Blob Storage previamente disponível e variáveis válidas

Quando o responsável inicializar o Terraform utilizando o backend remoto documentado e executar o fluxo de provisionamento

Então o Terraform deverá utilizar o estado armazenado no Azure Blob Storage

E o Resource Group da aplicação e todos os recursos descritos nesta SPEC deverão ser criados sem etapas manuais no portal Azure.

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

Quando a API ou o Job de migration se conectar usando sua configuração privada

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
* CI/CD, pipelines remotos de build ou GitHub Actions; o script one shot local descrito nesta SPEC faz parte do escopo;
* múltiplos ambientes (desenvolvimento, homologação e produção);
* domínio próprio, certificados personalizados, CDN, Azure Front Door, Application Gateway ou WAF;
* autenticação de usuários finais além do mecanismo de demonstração já estabelecido;
* alta disponibilidade multi-região, recuperação de desastre ou escalabilidade além das configurações básicas do Container Apps;
* acesso administrativo público ao MySQL.
* provisionamento inicial do Storage Account e do Blob Container utilizados como backend remoto do Terraform;
* implementação de mecanismos avançados de governança do state, como replicação entre regiões ou políticas corporativas de retenção;
* criação ou administração da subscrição Azure.

---

## 8. Premissas

* A identidade que executará o Terraform possui permissões suficientes na subscrição existente para criar o Resource Group e os recursos listados.
* A região escolhida oferece Azure Container Apps Environment com integração de VNet, Azure Database for MySQL Flexible Server com Private Endpoint e Azure Key Vault.
* A identidade que executará o script possui permissões para provisionar os recursos, publicar imagens no ACR, criar ou atualizar o segredo no Key Vault e consultar a saúde das cargas.
* A máquina que executará o script possui Azure CLI autenticada, Terraform e Docker disponíveis.
* As imagens de frontend e backend serão construídas a partir dos Dockerfiles definidos na SPEC 001 e disponibilizadas no Azure Container Registry pelo script one shot.
* O ambiente inicial é único e destinado à demonstração ou produção de pequeno porte.
* Existe previamente um Azure Storage Account e um Blob Container acessíveis pela identidade que executará o Terraform para armazenamento remoto do state.
* A identidade utilizada na execução possui permissões suficientes para ler e gravar o state no Blob Storage.
* O backend remoto utilizará o provider/backend azurerm e será configurado antes do provisionamento dos recursos da aplicação.
* O estado remoto é considerado infraestrutura de bootstrap e possui ciclo de vida independente do Resource Group da aplicação.
