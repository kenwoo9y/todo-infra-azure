# todo-infra-azure

This is a Terraform infrastructure project for deploying ToDo applications on Microsoft Azure, designed for simplicity and extensibility.

## Tech Stack

![Terraform](https://img.shields.io/badge/Terraform-7C42FA?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)
![MySQL](https://img.shields.io/badge/mysql-4479A1.svg?style=for-the-badge&logo=mysql&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

### Infrastructure as Code
- [Terraform](https://www.terraform.io/) v1.0+ - Infrastructure as Code tool
- [Terraform Cloud](https://www.terraform.io/cloud) - Remote state management and backend

### Cloud Platform
- [Microsoft Azure](https://azure.microsoft.com/) - Cloud platform for hosting and database services

### Frontend Services
- [Azure Storage Account](https://azure.microsoft.com/products/storage/blobs/) - Blob Storage with Static Website for frontend static files

### Backend Services
- [Azure Container Apps](https://azure.microsoft.com/products/container-apps/) - Serverless container platform for backend services
- [Azure Container Registry](https://azure.microsoft.com/products/container-registry/) - Container image registry for backend

### Database
- [Azure Database for MySQL](https://azure.microsoft.com/products/mysql/) - Managed MySQL database
- [Azure Database for PostgreSQL](https://azure.microsoft.com/products/postgresql/) - Managed PostgreSQL database

### Security & Identity
- [Azure Key Vault](https://azure.microsoft.com/products/key-vault/) - Secure storage and management of database connection strings and secrets
- [Microsoft Entra ID](https://www.microsoft.com/security/business/identity-access/microsoft-entra-id) - Identity and Access Management for service principals and permissions
- [Workload Identity Federation](https://learn.microsoft.com/entra/workload-id/workload-identity-federation) - OIDC-based authentication for GitHub Actions and Terraform Cloud

### Logging
- [Azure Monitor - Log Analytics](https://learn.microsoft.com/azure/azure-monitor/logs/log-analytics-overview?tabs=simple) - Log management and aggregation service

### Code Quality Assurance
- [TFLint](https://github.com/terraform-linters/tflint) - Terraform linting and validation
- [terraform fmt](https://www.terraform.io/docs/cli/commands/fmt) - Terraform code formatting

### CI/CD
- GitHub Actions - Continuous Integration and Deployment

## Setup
### Prerequisites
1. Install [Terraform](https://www.terraform.io/downloads.html) v1.0+
2. Install [TFLint](https://github.com/terraform-linters/tflint#installation)
3. Install [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
4. Create an [Azure Subscription](https://portal.azure.com/) and get your subscription ID
5. Create a [Terraform Cloud account](https://app.terraform.io/session) and organization
6. Authenticate with Terraform Cloud:
   ```bash
   terraform login
   ```

### Terraform Cloud Setup
This project uses Terraform Cloud for state management.

#### 1. Create Terraform Cloud Organization and Workspaces
1. Log in to [Terraform Cloud](https://app.terraform.io/)
2. Create an Organization (if you don't have one)

#### 2. OIDC Authentication Setup (Recommended)
Setup instructions for using OIDC authentication to deploy to Azure from Terraform Cloud:

**Azure-side Configuration:**
1. Create a Federated Credential in Microsoft Entra ID:
   ```bash
   # Create Federated Credential for Terraform Cloud
   az ad app create --display-name "terraform-cloud-oidc"
   
   # Get the application ID
   APP_ID=$(az ad app list --display-name "terraform-cloud-oidc" --query "[0].appId" -o tsv)
   
   # Create Service Principal
   az ad sp create --id $APP_ID
   
   # Assign Contributor role to Subscription
   az role assignment create \
     --assignee $APP_ID \
     --role Contributor \
     --scope /subscriptions/YOUR_SUBSCRIPTION_ID
   
   # Create Federated Credential
   # Note: You need to create a separate Federated Credential for each Workspace
   # Create JSON file
   cat > /tmp/federated-credential.json <<EOF
   {
     "name": "terraform-cloud-oidc-workspace-dev",
     "issuer": "https://app.terraform.io",
     "subject": "organization:YOUR_ORG_NAME:workspace:YOUR_WORKSPACE_PREFIX-dev:run_phase:*",
     "audiences": ["terraform.io"]
   }
   EOF
   
   az ad app federated-credential create \
     --id $APP_ID \
     --parameters /tmp/federated-credential.json
   
   # Create similar credentials for staging and production environments
   ```

**Terraform Cloud-side Configuration:**
1. Navigate to your Terraform Cloud Organization
2. Go to Settings → Variable sets
3. Create a new Variable set or edit an existing one
4. Add the following environment variables:
   - `ARM_USE_OIDC`: `true` (not sensitive)
   - `ARM_CLIENT_ID`: Microsoft Entra ID application Client ID (the `$APP_ID` above) - **Mark as Sensitive**
   - `ARM_SUBSCRIPTION_ID`: Azure Subscription ID - **Mark as Sensitive**
   - `ARM_TENANT_ID`: Azure Tenant ID - **Mark as Sensitive**

### Initial Setup
1. Clone this repository:
    ```
    $ git clone https://github.com/kenwoo9y/todo-infra-azure.git
    $ cd todo-infra-azure
    ```

2. Configure Terraform variables:
    ```
    $ cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
    ```
    Edit `environments/dev/terraform.tfvars` and set Terraform-specific variables:
    - `subscription_id`: Azure Subscription ID (required)
    - `location`: Azure region (optional, default: "japaneast")
    - `environment`: Environment name (optional, default: "dev")
    - `name_prefix`: Name prefix for resources (optional, default: "todo")
    - `mysql_password`: MySQL database password (required)
    - `postgresql_password`: PostgreSQL database password (required)
    - `default_database_type`: Database type (optional, "mysql" or "postgresql", default: "mysql")
    - `mysql_database_name`: MySQL database name (optional)
    - `postgresql_database_name`: PostgreSQL database name (optional)
    - `mysql_user`: MySQL database username (optional)
    - `postgresql_user`: PostgreSQL database username (optional)
    - `terraform_service_principal_object_id`: Service principal Object ID for Key Vault access (optional, recommended for consistency between local and CI/CD)
    - Other Terraform variables as needed

3. Authenticate with Azure:
    ```bash
    az login
    ```
    **Note**: Authentication via `az login` is sufficient for local development.

4. Configure environment variables for Terraform Cloud:
    ```
    $ cp .env.example .env
    ```
    Edit `.env` file and set the following (required for Terraform Cloud backend):
    - `TF_ORG_NAME`: Terraform Cloud organization name (required)
    - `TF_WORKSPACE_NAME_PREFIX`: Workspace name prefix (e.g., `todo-infra-azure`)
      - Workspace names will be: `{prefix}-dev`, `{prefix}-staging`, `{prefix}-production`
    - `TF_TOKEN_app_terraform_io`: Terraform Cloud token (optional if using `terraform login`)

    **Note**: 
    - The `deploy.sh` script automatically uses these environment variables to configure the Terraform Cloud backend
    - If you've already run `terraform login`, you don't need to set `TF_TOKEN_app_terraform_io`
    - Terraform Cloud workspaces should be created with **Execution Mode: Local** (not Remote)

5. **Set Terraform Service Principal Object ID** (Required for Key Vault access):
   
   To ensure consistent Key Vault access policy across local and CI/CD environments, you need to set the `terraform_service_principal_object_id` variable. This should be the same service principal used in GitHub Actions.
   
   **Get the service principal object ID:**
   ```bash
   # If you know the Azure Client ID used in GitHub Actions
   az ad sp show --id <AZURE_CLIENT_ID> --query id -o tsv
   
   # Or list all service principals and find the one used for GitHub Actions
   az ad sp list --display-name "github-actions-oidc" --query "[0].id" -o tsv
   ```
   
   **Add to terraform.tfvars:**
   ```hcl
   terraform_service_principal_object_id = "your-service-principal-object-id"
   ```
   
   **Note:** If this variable is not set, Terraform will use the current authenticated user's object_id, which may cause inconsistencies between local and CI/CD environments.

6. Deploy the infrastructure:
    ```
    $ ./scripts/deploy.sh dev
    ```
   
   **Note**: The `container_image` variable in `terraform.tfvars` is optional. If left empty, the infrastructure (Container Registry, databases, etc.) will be created, but the Container App service will be skipped. After pushing your Docker image to Container Registry, set the `container_image` value and run the deploy script again to create the Container App service.
   
   **Two-stage deployment workflow**:
   
   1. **First deployment** (Infrastructure only):
      - Leave `container_image` empty in `terraform.tfvars` (or omit it)
      - Run `./scripts/deploy.sh dev`
      - This creates Container Registry, databases, and other infrastructure resources
      - Container App service is not created at this stage
   
   2. **Build and push Docker image**:
      - Build and push your Docker image to the Container Registry created in step 1
      - The deploy script will display the next steps if Container App service was not created
   
   3. **Second deployment** (Create Container App service):
      - Update `terraform.tfvars` with the `container_image` URL
      - Run `./scripts/deploy.sh dev` again
      - This creates the Container App service with your container image

## Usage
### Infrastructure Management
- Deploy infrastructure:
    ```
    $ ./scripts/deploy.sh [dev|staging|production]
    ```
    - State is automatically stored in Terraform Cloud (configured via `.env` file)
    - First deployment will prompt to migrate state if migrating from local to remote
- Destroy infrastructure:
    ```
    $ ./scripts/destroy.sh [dev|staging|production]
    ```
    - State operations are coordinated through Terraform Cloud to prevent conflicts

### Database Management
- Database information and switching instructions are documented in the Database Switching section below.

## Development
### Code Quality Checks
- Lint check:
    ```
    $ make lint-check
    ```
- Fix linting issues:
    ```
    $ make lint-fix
    ```
- Check code formatting:
    ```
    $ make format-check
    ```
- Apply code formatting:
    ```
    $ make format-fix
    ```

## Infrastructure

### Architecture Overview

The infrastructure consists of the following components:

- **Backend**: Container Apps service with containerized application
- **Frontend**: Storage Account bucket with Static Website hosting
- **Database**: Azure Database instances (MySQL and PostgreSQL) with connection strings stored in Key Vault
- **Container Registry**: Azure Container Registry for Docker images
- **Security**: Workload Identity Federation for GitHub Actions, Service Principals for Azure authentication
- **State Management**: Terraform Cloud for remote state storage and coordination

For detailed architecture diagrams, see [Architecture Diagram](./docs/architecture-diagram.md).

#### Development Environment
- **Location**: `environments/dev/`
- **Default Database**: MySQL
- **Database Plans**:
  - MySQL: `B_Standard_B1ms` (Burstable tier - cheapest option)
  - PostgreSQL: `B_Standard_B1ms` (Burstable tier - cheapest option)

#### Configuration Variables

Terraform variables are managed in two places:

1. **`terraform.tfvars`** (Terraform-specific variables):
   - `subscription_id`: Azure Subscription ID (required)
   - `location`: Azure region (optional, default: "japaneast")
   - `environment`: Environment name (optional, default: "dev")
   - `name_prefix`: Name prefix for resources (optional, default: "todo")
   - `mysql_password`: MySQL database password (required)
   - `postgresql_password`: PostgreSQL database password (required)
   - `default_database_type`: Default database type (optional, "mysql" or "postgresql", default: "mysql")
   - `mysql_database_name`: MySQL database name (optional, default: "todo_mysql_db")
   - `postgresql_database_name`: PostgreSQL database name (optional, default: "todo_postgresql_db")
   - `mysql_user`: MySQL database username (optional, default: "todo_mysql_user")
   - `postgresql_user`: PostgreSQL database username (optional, default: "todo_postgresql_user")
   - `container_image`: Container image URL for Container Apps (optional, leave empty to skip Container App service creation on first deployment)
   - `log_analytics_workspace_sku`: Log Analytics Workspace SKU (optional, default: "PerGB2018")
   - `container_app_cpu`: CPU limit for Container App container (optional, default: 0.25)
   - `container_app_memory`: Memory limit for Container App container (optional, default: "0.5Gi")
   - `container_app_target_port`: Target port for Container App container (optional, default: 8000)
   - `terraform_service_principal_object_id`: Service principal Object ID for Key Vault access (optional, recommended for consistency between local and CI/CD)

2. **`.env`** (Tool-specific environment variables):
   - `TF_TOKEN_app_terraform_io`: Terraform Cloud authentication token
   - `TF_ORG_NAME`: Terraform Cloud organization name
   - `TF_WORKSPACE_NAME_PREFIX`: Workspace name prefix

### Database Switching
The infrastructure supports both PostgreSQL and MySQL databases. You can switch between them using the Container Apps Console or Azure CLI:

**Manual switching via Azure Portal**:
- Go to Azure Portal → Container Apps → Your App → Revision Management
- Edit the latest revision
- Change `DB_TYPE` to "mysql" or "postgresql"
- Change `MYSQL_DATABASE_URL` or `POSTGRESQL_DATABASE_URL` as needed
- Deploy the new revision

**Manual switching via Azure CLI**:
```bash
# Switch to MySQL
az containerapp update \
  --name dev-todoapp-dev-backend \
  --resource-group todo-app-dev-rg \
  --set-env-vars DB_TYPE=mysql

# Switch to PostgreSQL
az containerapp update \
  --name dev-todoapp-dev-backend \
  --resource-group todo-app-dev-rg \
  --set-env-vars DB_TYPE=postgresql
```

## Deployment Workflow

### Manual Deployment

The deployment follows a two-stage process to allow infrastructure setup before pushing Docker images:

1. **Infrastructure Setup** (First deployment):
    ```
    $ ./scripts/deploy.sh dev
    ```
    - Creates Container Registry, databases, and other infrastructure resources
    - Container App service is not created if `container_image` is empty
    - The deploy script will display next steps if Container App service was skipped

2. **Application Image Deployment**:
    - Build your application container image
    - Push to Azure Container Registry (created in step 1)
    - Update the `container_image` variable in `terraform.tfvars` with the image URL

3. **Container App Service Creation** (Second deployment):
    ```
    $ ./scripts/deploy.sh dev
    ```
    - Creates the Container App service with your container image
    - Service is automatically configured with database connection strings from Key Vault

4. **Post-Deployment**:
    - Verify the deployed resources in Azure Portal
    - Configure application environment variables if needed
    - Run database migrations

5. **Database Configuration**:
    - Follow the manual switching instructions in the Database Switching section below

### Automated Deployment with GitHub Actions

To set up automated deployment with GitHub Actions, follow these steps:

1. **Set up Terraform Cloud Backend** (Required for state management):
   - Create a Terraform Cloud account at https://app.terraform.io/
   - Create an organization (note your organization name)
   - For each environment (dev, staging, production), create a workspace:
     - Workspace name: `{TF_WORKSPACE_NAME_PREFIX}-{env}` (e.g., `todo-infra-azure-dev`, `todo-infra-azure-staging`, `todo-infra-azure-production`)
     - **Execution mode: Local** (CRITICAL: Must be set to "Local" for local/CI execution)
       - Go to Workspace → Settings → General Settings
       - Set Execution Mode to **Local**
       - If set to "Remote", you'll get "Insufficient rights to generate a plan" error
       - Local mode allows Terraform to run on your machine or in CI/CD while storing state remotely
   - **Authenticate with Terraform Cloud** (Required for local deployment):
     ```bash
     terraform login
     ```
     This creates `~/.terraform.d/credentials.tfrc.json` for authentication.
     Alternatively, you can set `TF_TOKEN_app_terraform_io` environment variable.
   - Generate a User API Token (for GitHub Actions):
     - Go to User Settings → Tokens
     - Create a new token and copy it
     - This token is used by GitHub Actions to authenticate with Terraform Cloud

2. **Azure OIDC Authentication Setup**:
   
   Setup instructions for using OIDC authentication to deploy to Azure from GitHub Actions:
   
   **Azure-side Configuration:**
   
   a. Create a Federated Credential in Microsoft Entra ID:
      ```bash
      # Create Federated Credential for GitHub Actions
      az ad app create --display-name "github-actions-oidc"
      
      # Get the application ID
      APP_ID=$(az ad app list --display-name "github-actions-oidc" --query "[0].appId" -o tsv)
      
      # Create Service Principal
      az ad sp create --id $APP_ID
      
      # Assign Contributor role to Subscription
      az role assignment create \
        --assignee $APP_ID \
        --role Contributor \
        --scope /subscriptions/YOUR_SUBSCRIPTION_ID
      
      # Create Federated Credential (for GitHub repository)
      # Branch-based authentication
      cat > /tmp/github-oidc-branch.json <<EOF
      {
        "name": "github-actions-oidc-main",
        "issuer": "https://token.actions.githubusercontent.com",
        "subject": "repo:YOUR_GITHUB_ORG/YOUR_REPO_NAME:ref:refs/heads/main",
        "audiences": ["api://AzureADTokenExchange"]
      }
      EOF
      
      az ad app federated-credential create \
        --id $APP_ID \
        --parameters /tmp/github-oidc-branch.json
      
      # Also create environment-specific Federated Credentials (recommended)
      # For dev environment
      cat > /tmp/github-oidc-dev.json <<EOF
      {
        "name": "github-actions-oidc-dev",
        "issuer": "https://token.actions.githubusercontent.com",
        "subject": "repo:YOUR_GITHUB_ORG/YOUR_REPO_NAME:environment:dev",
        "audiences": ["api://AzureADTokenExchange"]
      }
      EOF
      
      az ad app federated-credential create \
        --id $APP_ID \
        --parameters /tmp/github-oidc-dev.json
      
      # Create similar credentials for staging and production environments
      ```
   
   b. **Grant Key Vault Access Permissions** (Required):
      
      The service principal needs access to Key Vault to read and manage secrets. This is especially important if Key Vault already exists or when Terraform needs to read existing secrets during `terraform plan` or `terraform apply`.
      
      **Option A: Using Azure Portal:**
      1. Navigate to Azure Portal → Key Vaults → Your Key Vault
      2. Go to "Access policies" → "Add Access Policy"
      3. Search for your service principal (using the Client ID from step a)
      4. Grant the following Secret permissions:
         - `Get`, `List`, `Set`, `Delete`, `Recover`, `Backup`, `Restore`
      5. Click "Add" and "Save"
      
      **Option B: Using Azure CLI:**
      ```bash
      # Get the service principal Object ID
      SP_OBJECT_ID=$(az ad sp show --id $APP_ID --query id -o tsv)
      
      # Grant Key Vault access permissions
      az keyvault set-policy \
        --name <YOUR_KEY_VAULT_NAME> \
        --object-id $SP_OBJECT_ID \
        --secret-permissions get list set delete recover backup restore
      ```
      
      **Option C: Using RBAC (Role-Based Access Control):**
      ```bash
      # Get the service principal Object ID
      SP_OBJECT_ID=$(az ad sp show --id $APP_ID --query id -o tsv)
      
      # Assign Key Vault Secrets Officer role
      az role assignment create \
        --role "Key Vault Secrets Officer" \
        --assignee $SP_OBJECT_ID \
        --scope /subscriptions/<YOUR_SUBSCRIPTION_ID>/resourceGroups/<YOUR_RESOURCE_GROUP>/providers/Microsoft.KeyVault/vaults/<YOUR_KEY_VAULT_NAME>
      ```
      
      **Note:** If Key Vault doesn't exist yet, you can skip this step for the initial deployment. However, you'll need to grant permissions before subsequent deployments if Terraform needs to read existing secrets.
   
   c. **Grant Storage Blob Data Contributor Role** (Required for Frontend Deployment):
      
      GitHub Actions needs permission to upload build artifacts to Blob Storage. This requires the "Storage Blob Data Contributor" role.
      
      **Option A: Grant User Access Administrator Role to Service Principal** (Recommended):
      
      To allow Terraform to automatically create role assignments, grant the service principal the "User Access Administrator" role at the resource group level:
      
      ```bash
      # Get the service principal Object ID
      SP_OBJECT_ID=$(az ad sp show --id $APP_ID --query id -o tsv)
      
      # Get your subscription ID and resource group name
      SUBSCRIPTION_ID="your-subscription-id"
      RESOURCE_GROUP="todo-dev-rg"
      
      # Assign User Access Administrator role at resource group level
      az role assignment create \
        --assignee $SP_OBJECT_ID \
        --role "User Access Administrator" \
        --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}
      ```
      
      **Option B: Manually Create Role Assignment** (If Option A is not possible):
      
      If you cannot grant "User Access Administrator" role, you can manually create the role assignment after the storage account is created:
      
      ```bash
      # Get the service principal Object ID
      SP_OBJECT_ID=$(az ad sp show --id $APP_ID --query id -o tsv)
      
      # Get storage account ID (after Terraform creates it)
      STORAGE_ACCOUNT_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Storage/storageAccounts/<STORAGE_ACCOUNT_NAME>"
      
      # Manually create the role assignment
      az role assignment create \
        --assignee $SP_OBJECT_ID \
        --role "Storage Blob Data Contributor" \
        --scope $STORAGE_ACCOUNT_ID
      
      # Then import it into Terraform state
      cd environments/dev
      terraform import \
        module.frontend.azurerm_role_assignment.storage_blob_data_contributor \
        "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Storage/storageAccounts/<STORAGE_ACCOUNT_NAME>/providers/Microsoft.Authorization/roleAssignments/<ROLE_ASSIGNMENT_ID>"
      ```
      
      To get the role assignment ID:
      ```bash
      az role assignment list \
        --assignee $SP_OBJECT_ID \
        --scope $STORAGE_ACCOUNT_ID \
        --query "[?roleDefinitionName=='Storage Blob Data Contributor'].id" -o tsv
      ```

3. **Configure GitHub Secrets**:
   - Navigate to GitHub repository Settings → Secrets and variables → Actions
   - Add the following Secrets:
     - `AZURE_CLIENT_ID`: Microsoft Entra ID application Client ID (the `$APP_ID` from step 2a)
     - `AZURE_TENANT_ID`: Azure Tenant ID
     - `AZURE_SUBSCRIPTION_ID`: Azure Subscription ID
     - `TF_API_TOKEN`: Your Terraform Cloud User API Token
     - `TF_ORG_NAME`: Your Terraform Cloud organization name
     - `TF_WORKSPACE_NAME_PREFIX`: Workspace name prefix (e.g., `todo-infra-azure`). The full workspace name will be `{prefix}-{environment}` (e.g., `todo-infra-azure-dev`)
     - **Terraform Variables** (optional, defaults from `variables.tf` will be used if not set):
       - `TF_VAR_SUBSCRIPTION_ID`: Azure Subscription ID
       - `TF_VAR_LOCATION`: Azure region (default: "japaneast")
       - `TF_VAR_MYSQL_PASSWORD`: MySQL database password
       - `TF_VAR_POSTGRESQL_PASSWORD`: PostgreSQL database password
       - `TF_VAR_ENVIRONMENT`: Environment name (default: "dev")
       - `TF_VAR_NAME_PREFIX`: Name prefix for resources (default: "todo")
       - `TF_VAR_CONTAINER_IMAGE`: Container image URL for Container Apps
       - `TF_VAR_DEFAULT_DATABASE_TYPE`: Default database type ("mysql" or "postgresql", default: "mysql")
       - `TF_VAR_MYSQL_DATABASE_NAME`: MySQL database name
       - `TF_VAR_POSTGRESQL_DATABASE_NAME`: PostgreSQL database name
       - `TF_VAR_MYSQL_USER`: MySQL database username
       - `TF_VAR_POSTGRESQL_USER`: PostgreSQL database username
       - `TF_VAR_LOG_ANALYTICS_WORKSPACE_SKU`: Log Analytics Workspace SKU (default: "PerGB2018")
       - `TF_VAR_CONTAINER_APP_CPU`: CPU limit for Container App container (default: 0.25)
       - `TF_VAR_CONTAINER_APP_MEMORY`: Memory limit for Container App container (default: "0.5Gi")
       - `TF_VAR_CONTAINER_APP_TARGET_PORT`: Target port for Container App container (default: 8000)
       - **Note**: 
         - If these secrets are not set, the default values defined in `variables.tf` will be used
         - `terraform_service_principal_object_id` is automatically set from the service principal used for authentication, so it does not need to be configured as a secret

4. **Deployment Methods**:
   - **Automatic Deployment**: 
     - Pushing to `main` branch → runs plan automatically
     - For actual deployment, use workflow_dispatch manually
   - **Manual Deployment**: 
     - Open the "Actions" tab in your GitHub repository
     - Select "Terraform Deploy Workflow"
     - Click "Run workflow"
     - Choose the environment to deploy (dev/staging/production) and action (plan/apply/destroy)
     - Click "Run workflow"

5. **Verify Deployment**:
   - After the GitHub Actions workflow execution, deployment information will be displayed
   - Alternatively, you can check resource information using the `terraform output` command

---
## セットアップ
### 前提条件
1. [Terraform](https://www.terraform.io/downloads.html) v1.0+をインストール
2. [TFLint](https://github.com/terraform-linters/tflint#installation)をインストール
3. [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)をインストール
4. [Azure Subscription](https://portal.azure.com/)を作成し、サブスクリプションIDを取得
5. [Terraform Cloudアカウント](https://app.terraform.io/session)と組織を作成
6. Terraform Cloudで認証:
   ```bash
   terraform login
   ```

### Terraform Cloudセットアップ
このプロジェクトはステート管理にTerraform Cloudを使用する。

#### 1. Terraform Cloud組織とワークスペースの作成
1. [Terraform Cloud](https://app.terraform.io/)にログイン
2. 組織を作成（まだ持っていない場合）

#### 2. OIDC認証セットアップ（推奨）
Terraform CloudからAzureにデプロイするためのOIDC認証を使用するセットアップ手順:

**Azure側の設定:**
1. Microsoft Entra IDでフェデレーテッド資格情報を作成:
   ```bash
   # Terraform Cloud用のフェデレーテッド資格情報を作成
   az ad app create --display-name "terraform-cloud-oidc"
   
   # アプリケーションIDを取得
   APP_ID=$(az ad app list --display-name "terraform-cloud-oidc" --query "[0].appId" -o tsv)
   
   # サービスプリンシパルを作成
   az ad sp create --id $APP_ID
   
   # サブスクリプションにContributorロールを割り当て
   az role assignment create \
     --assignee $APP_ID \
     --role Contributor \
     --scope /subscriptions/YOUR_SUBSCRIPTION_ID
   
   # フェデレーテッド資格情報を作成
   # 注意: 各ワークスペースごとに別々のフェデレーテッド資格情報を作成する必要がある
   # JSONファイルを作成
   cat > /tmp/federated-credential.json <<EOF
   {
     "name": "terraform-cloud-oidc-workspace-dev",
     "issuer": "https://app.terraform.io",
     "subject": "organization:YOUR_ORG_NAME:workspace:YOUR_WORKSPACE_PREFIX-dev:run_phase:*",
     "audiences": ["terraform.io"]
   }
   EOF
   
   az ad app federated-credential create \
     --id $APP_ID \
     --parameters /tmp/federated-credential.json
   
   # stagingとproduction環境用にも同様の資格情報を作成
   ```

**Terraform Cloud側の設定:**
1. Terraform Cloud組織に移動
2. Settings → Variable setsに移動
3. 新しいVariable setを作成するか、既存のものを編集
4. 以下の環境変数を追加:
   - `ARM_USE_OIDC`: `true` (機密情報ではない)
   - `ARM_CLIENT_ID`: Microsoft Entra IDアプリケーションのクライアントID（上記の`$APP_ID`）- **機密情報としてマーク**
   - `ARM_SUBSCRIPTION_ID`: AzureサブスクリプションID - **機密情報としてマーク**
   - `ARM_TENANT_ID`: AzureテナントID - **機密情報としてマーク**

### 初期セットアップ
1. リポジトリをクローン:
    ```
    $ git clone https://github.com/kenwoo9y/todo-infra-azure.git
    $ cd todo-infra-azure
    ```

2. Terraform変数を設定:
    ```
    $ cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
    ```
    `environments/dev/terraform.tfvars`を編集し、Terraform固有の変数を設定:
    - `subscription_id`: AzureサブスクリプションID（必須）
    - `location`: Azureリージョン（オプション、デフォルト: "japaneast"）
    - `environment`: 環境名（オプション、デフォルト: "dev"）
    - `name_prefix`: リソースの名前プレフィックス（オプション、デフォルト: "todo"）
    - `mysql_password`: MySQLデータベースパスワード（必須）
    - `postgresql_password`: PostgreSQLデータベースパスワード（必須）
    - `default_database_type`: データベースタイプ（オプション、"mysql"または"postgresql"、デフォルト: "mysql"）
    - `mysql_database_name`: MySQLデータベース名（オプション）
    - `postgresql_database_name`: PostgreSQLデータベース名（オプション）
    - `mysql_user`: MySQLデータベースユーザー名（オプション）
    - `postgresql_user`: PostgreSQLデータベースユーザー名（オプション）
    - `terraform_service_principal_object_id`: Key Vaultアクセス用のサービスプリンシパルObject ID（オプション、ローカルとCI/CD間の一貫性のために推奨）
    - その他のTerraform変数（必要に応じて）

3. Azureで認証:
    ```bash
    az login
    ```
    **注意**: ローカル開発では`az login`による認証で十分。

4. Terraform Cloud用の環境変数を設定:
    ```
    $ cp .env.example .env
    ```
    `.env`ファイルを編集し、以下を設定（Terraform Cloudバックエンドに必須）:
    - `TF_ORG_NAME`: Terraform Cloud組織名（必須）
    - `TF_WORKSPACE_NAME_PREFIX`: ワークスペース名プレフィックス（例: `todo-infra-azure`）
      - ワークスペース名は次のようになる: `{prefix}-dev`, `{prefix}-staging`, `{prefix}-production`
    - `TF_TOKEN_app_terraform_io`: Terraform Cloudトークン（`terraform login`を使用している場合はオプション）

    **注意**: 
    - `deploy.sh`スクリプトはこれらの環境変数を自動的に使用してTerraform Cloudバックエンドを設定する
    - 既に`terraform login`を実行している場合、`TF_TOKEN_app_terraform_io`を設定する必要はない
    - Terraform Cloudワークスペースは**Execution Mode: Local**（Remoteではない）で作成する必要がある

5. **TerraformサービスプリンシパルObject IDを設定**（Key Vaultアクセスに必須）:
   
   ローカルとCI/CD環境間でKey Vaultアクセスポリシーを一貫させるために、`terraform_service_principal_object_id`変数を設定する必要がある。これはGitHub Actionsで使用されるのと同じサービスプリンシパルである必要がある。
   
   **サービスプリンシパルObject IDを取得:**
   ```bash
   # GitHub Actionsで使用されるAzureクライアントIDが分かっている場合
   az ad sp show --id <AZURE_CLIENT_ID> --query id -o tsv
   
   # または、すべてのサービスプリンシパルをリストしてGitHub Actionsで使用されているものを探す
   az ad sp list --display-name "github-actions-oidc" --query "[0].id" -o tsv
   ```
   
   **terraform.tfvarsに追加:**
   ```hcl
   terraform_service_principal_object_id = "your-service-principal-object-id"
   ```
   
   **注意:** この変数が設定されていない場合、Terraformは現在認証されているユーザーのobject_idを使用するが、ローカルとCI/CD環境間で不整合が発生する可能性がある。

6. インフラストラクチャをデプロイ:
    ```
    $ ./scripts/deploy.sh dev
    ```
   
   **注意**: `terraform.tfvars`の`container_image`変数はオプション。空のままにすると、インフラストラクチャ（Container Registry、データベースなど）は作成されますが、Container Appサービスはスキップされる。DockerイメージをContainer Registryにプッシュした後、`container_image`の値を設定し、デプロイスクリプトを再度実行してContainer Appサービスを作成すること。
   
   **2段階デプロイメントワークフロー**:
   
   1. **初回デプロイ**（インフラストラクチャのみ）:
      - `terraform.tfvars`で`container_image`を空のままにする（または省略）
      - `./scripts/deploy.sh dev`を実行
      - これにより、Container Registry、データベース、その他のインフラストラクチャリソースが作成されます
      - この段階ではContainer Appサービスは作成されない
   
   2. **Dockerイメージのビルドとプッシュ**:
      - Dockerイメージをビルドし、ステップ1で作成されたContainer Registryにプッシュ
      - Container Appサービスが作成されなかった場合、デプロイスクリプトが次のステップを表示します
   
   3. **2回目のデプロイ**（Container Appサービスを作成）:
      - `container_image`のURLで`terraform.tfvars`を更新
      - `./scripts/deploy.sh dev`を再度実行
      - これにより、コンテナイメージを使用してContainer Appサービスが作成される

## 使用方法
### インフラ管理
- デプロイ:
    ```
    $ ./scripts/deploy.sh [dev|staging|production]
    ```
    - ステートは自動的にTerraform Cloudに保存される（`.env`ファイルで設定）
- 削除:
    ```
    $ ./scripts/destroy.sh [dev|staging|production]
    ```
    - ステート操作はTerraform Cloudを通じて調整され、競合を防ぐ

### データベース管理
- データベース情報と切り替え手順は、以下の「データベース切り替え」セクションに記載。

## 開発
### コード品質チェック
- リントチェック:
    ```
    $ make lint-check
    ```
- リントの問題を修正:
    ```
    $ make lint-fix
    ```
- コードフォーマットをチェック:
    ```
    $ make format-check
    ```
- コードフォーマットを適用:
    ```
    $ make format-fix
    ```

## インフラストラクチャ

### アーキテクチャ概要

インフラストラクチャは以下のコンポーネントで構成されている:

- **バックエンド**: コンテナ化されたアプリケーションを持つContainer Appsサービス
- **フロントエンド**: Static Websiteホスティング機能付きStorage Accountバケット
- **データベース**: Key Vaultに接続文字列が保存されたAzure Databaseインスタンス（MySQLとPostgreSQL）
- **Container Registry**: Dockerイメージ用のAzure Container Registry
- **セキュリティ**: GitHub Actions用のWorkload Identity Federation、Azure認証用のサービスプリンシパル
- **ステート管理**: リモートステート保存と調整のためのTerraform Cloud

詳細なアーキテクチャ図については、[アーキテクチャ図](./docs/architecture-diagram.md)を参照。

#### 開発環境
- **場所**: `environments/dev/`
- **デフォルトデータベース**: MySQL
- **データベースプラン**:
  - MySQL: `B_Standard_B1ms`（最も安価なオプション）
  - PostgreSQL: `B_Standard_B1ms`（最も安価なオプション）

#### 設定変数

Terraform変数は2つの場所で管理される:

1. **`terraform.tfvars`**（Terraform固有の変数）:
   - `subscription_id`: AzureサブスクリプションID（必須）
   - `location`: Azureリージョン（オプション、デフォルト: "japaneast"）
   - `environment`: 環境名（オプション、デフォルト: "dev"）
   - `name_prefix`: リソースの名前プレフィックス（オプション、デフォルト: "todo"）
   - `mysql_password`: MySQLデータベースパスワード（必須）
   - `postgresql_password`: PostgreSQLデータベースパスワード（必須）
   - `default_database_type`: デフォルトデータベースタイプ（オプション、"mysql"または"postgresql"、デフォルト: "mysql"）
   - `mysql_database_name`: MySQLデータベース名（オプション、デフォルト: "todo_mysql_db"）
   - `postgresql_database_name`: PostgreSQLデータベース名（オプション、デフォルト: "todo_postgresql_db"）
   - `mysql_user`: MySQLデータベースユーザー名（オプション、デフォルト: "todo_mysql_user"）
   - `postgresql_user`: PostgreSQLデータベースユーザー名（オプション、デフォルト: "todo_postgresql_user"）
   - `container_image`: Container Apps用のコンテナイメージURL（オプション、最初のデプロイメントでContainer Appサービス作成をスキップする場合は空のまま）
   - `log_analytics_workspace_sku`: Log Analytics Workspace SKU（オプション、デフォルト: "PerGB2018"）
   - `container_app_cpu`: Container AppコンテナのCPU制限（オプション、デフォルト: 0.25）
   - `container_app_memory`: Container Appコンテナのメモリ制限（オプション、デフォルト: "0.5Gi"）
   - `container_app_target_port`: Container Appコンテナのターゲットポート（オプション、デフォルト: 8000）
   - `terraform_service_principal_object_id`: Key Vaultアクセス用のサービスプリンシパルObject ID（オプション、ローカルとCI/CD間の一貫性のために推奨）

2. **`.env`**（ツール固有の環境変数）:
   - `TF_TOKEN_app_terraform_io`: Terraform Cloud認証トークン
   - `TF_ORG_NAME`: Terraform Cloud組織名
   - `TF_WORKSPACE_NAME_PREFIX`: ワークスペース名プレフィックス

### データベース切り替え
PostgreSQLとMySQLの両方のデータベースをサポートしており、Container AppsコンソールまたはAzure CLIを使用して切り替えることができる:

**Azure Portal経由の手動切り替え**:
- Azure Portal → Container Apps → アプリ → Revision Managementに移動
- 最新のリビジョンを編集
- `DB_TYPE`を"mysql"または"postgresql"に変更
- 必要に応じて`MYSQL_DATABASE_URL`または`POSTGRESQL_DATABASE_URL`を変更
- 新しいリビジョンをデプロイ

**Azure CLI経由の手動切り替え**:
```bash
# MySQLに切り替え
az containerapp update \
  --name dev-todoapp-dev-backend \
  --resource-group todo-app-dev-rg \
  --set-env-vars DB_TYPE=mysql

# PostgreSQLに切り替え
az containerapp update \
  --name dev-todoapp-dev-backend \
  --resource-group todo-app-dev-rg \
  --set-env-vars DB_TYPE=postgresql
```

## デプロイメントワークフロー

### 手動デプロイメント

デプロイメントは、Dockerイメージをプッシュする前にインフラストラクチャをセットアップできるように、2段階のプロセスで行う:

1. **インフラストラクチャセットアップ**（初回デプロイ）:
    ```
    $ ./scripts/deploy.sh dev
    ```
    - Container Registry、データベース、その他のインフラストラクチャリソースを作成
    - `container_image`が空の場合、Container Appサービスは作成されない
    - Container Appサービスがスキップされた場合、デプロイスクリプトが次のステップを表示する

2. **アプリケーションイメージのデプロイ**:
    - アプリケーションコンテナイメージをビルド
    - Azure Container Registry（ステップ1で作成）にプッシュ
    - `terraform.tfvars`の`container_image`変数をイメージURLで更新

3. **Container Appサービス作成**（2回目のデプロイ）:
    ```
    $ ./scripts/deploy.sh dev
    ```
    - コンテナイメージを使用してContainer Appサービスを作成
    - サービスはKey Vaultからのデータベース接続文字列で自動的に設定される

4. **デプロイ後**:
    - Azure Portalでデプロイされたリソースを確認
    - 必要に応じてアプリケーション環境変数を設定
    - データベースマイグレーションを実行

5. **データベース設定**:
    - 以下の「データベース切り替え」セクションの手動切り替え手順を参照

### GitHub Actionsによる自動デプロイメント

1. **Terraform Cloudバックエンドをセットアップ**（ステート管理に必須）:
   - https://app.terraform.io/ でTerraform Cloudアカウントを作成
   - 組織を作成（組織名をメモ）
   - 各環境（dev、staging、production）ごとにワークスペースを作成:
     - ワークスペース名: `{TF_WORKSPACE_NAME_PREFIX}-{env}`（例: `todo-infra-azure-dev`、`todo-infra-azure-staging`、`todo-infra-azure-production`）
     - **実行モード: Local**（重要: ローカル/CI実行には"Local"に設定する必要がある）
       - Workspace → Settings → General Settingsに移動
       - Execution Modeを**Local**に設定
       - "Remote"に設定すると、"Insufficient rights to generate a plan"エラーが発生する
       - Localモードでは、ステートをリモートに保存しながら、マシン上またはCI/CDでTerraformを実行できる
   - **Terraform Cloudで認証**（ローカルデプロイメントに必須）:
     ```bash
     terraform login
     ```
     これにより、認証用の`~/.terraform.d/credentials.tfrc.json`が作成される。
     または、`TF_TOKEN_app_terraform_io`環境変数を設定することもできる。
   - User API Tokenを生成（GitHub Actions用）:
     - User Settings → Tokensに移動
     - 新しいトークンを作成してコピー
     - このトークンはGitHub ActionsがTerraform Cloudで認証するために使用される

2. **Azure OIDC認証セットアップ**:
   
   GitHub ActionsからAzureにデプロイするためのOIDC認証を使用するセットアップ手順:
   
   **Azure側の設定:**
   
   a. Microsoft Entra IDでフェデレーテッド資格情報を作成:
      ```bash
      # GitHub Actions用のフェデレーテッド資格情報を作成
      az ad app create --display-name "github-actions-oidc"
      
      # アプリケーションIDを取得
      APP_ID=$(az ad app list --display-name "github-actions-oidc" --query "[0].appId" -o tsv)
      
      # サービスプリンシパルを作成
      az ad sp create --id $APP_ID
      
      # サブスクリプションにContributorロールを割り当て
      az role assignment create \
        --assignee $APP_ID \
        --role Contributor \
        --scope /subscriptions/YOUR_SUBSCRIPTION_ID
      
      # フェデレーテッド資格情報を作成（GitHubリポジトリ用）
      # ブランチベースの認証
      cat > /tmp/github-oidc-branch.json <<EOF
      {
        "name": "github-actions-oidc-main",
        "issuer": "https://token.actions.githubusercontent.com",
        "subject": "repo:YOUR_GITHUB_ORG/YOUR_REPO_NAME:ref:refs/heads/main",
        "audiences": ["api://AzureADTokenExchange"]
      }
      EOF
      
      az ad app federated-credential create \
        --id $APP_ID \
        --parameters /tmp/github-oidc-branch.json
      
      # 環境固有のフェデレーテッド資格情報も作成（推奨）
      # dev環境用
      cat > /tmp/github-oidc-dev.json <<EOF
      {
        "name": "github-actions-oidc-dev",
        "issuer": "https://token.actions.githubusercontent.com",
        "subject": "repo:YOUR_GITHUB_ORG/YOUR_REPO_NAME:environment:dev",
        "audiences": ["api://AzureADTokenExchange"]
      }
      EOF
      
      az ad app federated-credential create \
        --id $APP_ID \
        --parameters /tmp/github-oidc-dev.json
      
      # stagingとproduction環境用にも同様の資格情報を作成
      ```
   
   b. **Key Vaultアクセス権限を付与**（必須）:
      
      サービスプリンシパルは、Key Vaultにアクセスしてシークレットを読み取り、管理する必要がある。これは、Key Vaultが既に存在する場合や、Terraformが`terraform plan`または`terraform apply`中に既存のシークレットを読み取る必要がある場合に特に重要。
      
      **オプションA: Azure Portalを使用:**
      1. Azure Portal → Key Vaults → Key Vaultに移動
      2. "Access policies" → "Add Access Policy"に移動
      3. サービスプリンシパルを検索（ステップaのクライアントIDを使用）
      4. 以下のSecret権限を付与:
         - `Get`、`List`、`Set`、`Delete`、`Recover`、`Backup`、`Restore`
      5. "Add"と"Save"をクリック
      
      **オプションB: Azure CLIを使用:**
      ```bash
      # サービスプリンシパルObject IDを取得
      SP_OBJECT_ID=$(az ad sp show --id $APP_ID --query id -o tsv)
      
      # Key Vaultアクセス権限を付与
      az keyvault set-policy \
        --name <YOUR_KEY_VAULT_NAME> \
        --object-id $SP_OBJECT_ID \
        --secret-permissions get list set delete recover backup restore
      ```
      
      **オプションC: RBAC（ロールベースアクセス制御）を使用:**
      ```bash
      # サービスプリンシパルObject IDを取得
      SP_OBJECT_ID=$(az ad sp show --id $APP_ID --query id -o tsv)
      
      # Key Vault Secrets Officerロールを割り当て
      az role assignment create \
        --role "Key Vault Secrets Officer" \
        --assignee $SP_OBJECT_ID \
        --scope /subscriptions/<YOUR_SUBSCRIPTION_ID>/resourceGroups/<YOUR_RESOURCE_GROUP>/providers/Microsoft.KeyVault/vaults/<YOUR_KEY_VAULT_NAME>
      ```
      
      **注意:** Key Vaultがまだ存在しない場合、初期デプロイメントではこのステップをスキップできる。ただし、Terraformが既存のシークレットを読み取る必要がある場合、後続のデプロイメントの前に権限を付与する必要がある。
   
   c. **Storage Blob Data Contributorロールを付与**（フロントエンドデプロイメントに必須）:
      
      GitHub Actionsは、Blob Storageにビルド成果物をアップロードする権限が必要。これには"Storage Blob Data Contributor"ロールが必要。
      
      **オプションA: サービスプリンシパルにUser Access Administratorロールを付与**（推奨）:
      
      Terraformが自動的にロール割り当てを作成できるようにするには、リソースグループレベルでサービスプリンシパルに"User Access Administrator"ロールを付与する:
      
      ```bash
      # サービスプリンシパルObject IDを取得
      SP_OBJECT_ID=$(az ad sp show --id $APP_ID --query id -o tsv)
      
      # サブスクリプションIDとリソースグループ名を取得
      SUBSCRIPTION_ID="your-subscription-id"
      RESOURCE_GROUP="todo-dev-rg"
      
      # リソースグループレベルでUser Access Administratorロールを割り当て
      az role assignment create \
        --assignee $SP_OBJECT_ID \
        --role "User Access Administrator" \
        --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}
      ```
      
      **オプションB: 手動でロール割り当てを作成**（オプションAが不可能な場合）:
      
      "User Access Administrator"ロールを付与できない場合、ストレージアカウントが作成された後、手動でロール割り当てを作成できる:
      
      ```bash
      # サービスプリンシパルObject IDを取得
      SP_OBJECT_ID=$(az ad sp show --id $APP_ID --query id -o tsv)
      
      # ストレージアカウントIDを取得（Terraformが作成した後）
      STORAGE_ACCOUNT_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Storage/storageAccounts/<STORAGE_ACCOUNT_NAME>"
      
      # 手動でロール割り当てを作成
      az role assignment create \
        --assignee $SP_OBJECT_ID \
        --role "Storage Blob Data Contributor" \
        --scope $STORAGE_ACCOUNT_ID
      
      # その後、Terraformステートにインポート
      cd environments/dev
      terraform import \
        module.frontend.azurerm_role_assignment.storage_blob_data_contributor \
        "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Storage/storageAccounts/<STORAGE_ACCOUNT_NAME>/providers/Microsoft.Authorization/roleAssignments/<ROLE_ASSIGNMENT_ID>"
      ```
      
      ロール割り当てIDを取得するには:
      ```bash
      az role assignment list \
        --assignee $SP_OBJECT_ID \
        --scope $STORAGE_ACCOUNT_ID \
        --query "[?roleDefinitionName=='Storage Blob Data Contributor'].id" -o tsv
      ```

3. **GitHub Secretsを設定**（各リポジトリについて）:
   - GitHubリポジトリのSettings → Secrets and variables → Actionsに移動
   - 以下のSecretsを追加:
     - `AZURE_CLIENT_ID`: Microsoft Entra IDアプリケーションのクライアントID（ステップ2aの`$APP_ID`）
     - `AZURE_TENANT_ID`: AzureテナントID
     - `AZURE_SUBSCRIPTION_ID`: AzureサブスクリプションID
     - `TF_API_TOKEN`: Terraform Cloud User API Token
     - `TF_ORG_NAME`: Terraform Cloud組織名
     - `TF_WORKSPACE_NAME_PREFIX`: ワークスペース名プレフィックス（例: `todo-infra-azure`）。完全なワークスペース名は`{prefix}-{environment}`（例: `todo-infra-azure-dev`）になります
     - **Terraform変数**（オプション、設定されていない場合は`variables.tf`のデフォルト値が使用される）:
       - `TF_VAR_SUBSCRIPTION_ID`: AzureサブスクリプションID
       - `TF_VAR_LOCATION`: Azureリージョン（デフォルト: "japaneast"）
       - `TF_VAR_MYSQL_PASSWORD`: MySQLデータベースパスワード
       - `TF_VAR_POSTGRESQL_PASSWORD`: PostgreSQLデータベースパスワード
       - `TF_VAR_ENVIRONMENT`: 環境名（デフォルト: "dev"）
       - `TF_VAR_NAME_PREFIX`: リソースの名前プレフィックス（デフォルト: "todo"）
       - `TF_VAR_CONTAINER_IMAGE`: Container Apps用のコンテナイメージURL
       - `TF_VAR_DEFAULT_DATABASE_TYPE`: デフォルトデータベースタイプ（"mysql"または"postgresql"、デフォルト: "mysql"）
       - `TF_VAR_MYSQL_DATABASE_NAME`: MySQLデータベース名
       - `TF_VAR_POSTGRESQL_DATABASE_NAME`: PostgreSQLデータベース名
       - `TF_VAR_MYSQL_USER`: MySQLデータベースユーザー名
       - `TF_VAR_POSTGRESQL_USER`: PostgreSQLデータベースユーザー名
       - `TF_VAR_LOG_ANALYTICS_WORKSPACE_SKU`: Log Analytics Workspace SKU（デフォルト: "PerGB2018"）
       - `TF_VAR_CONTAINER_APP_CPU`: Container AppコンテナのCPU制限（デフォルト: 0.25）
       - `TF_VAR_CONTAINER_APP_MEMORY`: Container Appコンテナのメモリ制限（デフォルト: "0.5Gi"）
       - `TF_VAR_CONTAINER_APP_TARGET_PORT`: Container Appコンテナのターゲットポート（デフォルト: 8000）
       - **注意**: 
         - これらのシークレットが設定されていない場合、`variables.tf`で定義されたデフォルト値が使用される
         - `terraform_service_principal_object_id`は認証に使用されるサービスプリンシパルから自動的に設定されるため、シークレットとして設定する必要はない

4. **デプロイメント方法**:
   - **自動デプロイメント**: 
     - `main`ブランチにプッシュ → 自動的にplanを実行
     - 実際のデプロイメントには、手動でworkflow_dispatchを使用
   - **手動デプロイメント**: 
     - GitHubリポジトリの"Actions"タブを開く
     - "Terraform Deploy Workflow"を選択
     - "Run workflow"をクリック
     - デプロイする環境（dev/staging/production）とアクション（plan/apply/destroy）を選択
     - "Run workflow"をクリック

5. **デプロイメントを確認**:
   - GitHub Actionsワークフロー実行後、デプロイメント情報が表示される
   - または、`terraform output`コマンドを使用してリソース情報を確認できる
