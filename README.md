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
- [Azure Storage Account](https://azure.microsoft.com/services/storage/) - Blob Storage with Static Website for frontend static files

### Backend Services
- [Azure Container Apps](https://azure.microsoft.com/services/container-apps/) - Serverless container platform for backend services
- [Azure Container Registry](https://azure.microsoft.com/services/container-registry/) - Container image registry for backend

### Database
- [Azure Database for MySQL](https://azure.microsoft.com/services/mysql/) - Managed MySQL database
- [Azure Database for PostgreSQL](https://azure.microsoft.com/services/postgresql/) - Managed PostgreSQL database

### Security & Identity
- [Azure Key Vault](https://azure.microsoft.com/services/key-vault/) - Secure storage and management of database connection strings and secrets
- [Microsoft Entra ID](https://www.microsoft.com/security/business/identity-access/microsoft-entra-id) - Identity and Access Management for service principals and permissions
- [Workload Identity Federation](https://learn.microsoft.com/azure/active-directory/develop/workload-identity-federation) - OIDC-based authentication for GitHub Actions and Terraform Cloud

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
5. Enable required resource providers in your Azure subscription
6. Create a [Terraform Cloud account](https://app.terraform.io/session) and organization
7. Authenticate with Terraform Cloud:
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

**Note:** When using OIDC authentication, `ARM_CLIENT_SECRET` is not required.

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
    - `TF_WORKSPACE_NAME_PREFIX`: Workspace name prefix (e.g., `todo-infra`)
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

### Environment Configuration
The project supports multiple environments (dev, staging, production) with separate configurations:

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
   - **Why**: Terraform's native format, supports complex types, better IDE support

2. **`.env`** (Tool-specific environment variables):
   - `TF_TOKEN_app_terraform_io`: Terraform Cloud authentication token
     - **Note**: Automatically used by Terraform Cloud, no `.tf` file configuration needed
   - `TF_ORG_NAME`: Terraform Cloud organization name
     - **Note**: Automatically used by `deploy.sh` to configure backend (no manual `-backend-config` needed)
   - `TF_WORKSPACE_NAME_PREFIX`: Workspace name prefix
     - **Note**: Automatically used by `deploy.sh` to configure backend (no manual `-backend-config` needed)
   - **Why**: Shared across multiple tools, not Terraform-specific. All values are automatically used without `.tf` file configuration.

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

### Output Information
After deployment, the following information is available:
- **Container App URL**: URL where the backend application is accessible
- **Storage Account Web Endpoint**: Static website endpoint for frontend application
- **Container Registry Login Server**: Container image registry information
- **MySQL Server FQDN**: MySQL database connection information
- **PostgreSQL Server FQDN**: PostgreSQL database connection information
- **Key Vault Name**: Key Vault name for database connection strings

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
     - Workspace name: `{TF_WORKSPACE_NAME_PREFIX}-{env}` (e.g., `todo-infra-dev`, `todo-infra-staging`, `todo-infra-production`)
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
     - `TF_WORKSPACE_NAME_PREFIX`: Workspace name prefix (e.g., `todo-infra`). The full workspace name will be `{prefix}-{environment}` (e.g., `todo-infra-dev`)
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

4. Create environments in GitHub repository Settings → Environments (dev, staging, production)

5. **Migrate existing state** to Terraform Cloud (if migrating from local state):
   - Ensure `.env` file is configured with Terraform Cloud settings (see Initial Setup step 4)
   - The `deploy.sh` script will automatically use these settings
   - For dev environment:
     ```bash
     ./scripts/deploy.sh dev
     # The script will prompt to migrate state on first run if local state exists
     ```
   - Or manually migrate:
     ```bash
     # Load .env file (if not already loaded)
     export $(cat .env | grep -v '^#' | xargs)
     
     cd environments/dev
     terraform init \
       -backend-config=organization="${TF_ORG_NAME}" \
       -backend-config=workspaces.name="${TF_WORKSPACE_NAME_PREFIX}-dev" \
       -migrate-state
     # When prompted, type "yes" to migrate the state
     ```
   - **Note**: If starting fresh, Terraform Cloud will create a new state file automatically

6. **Deployment Methods**:
   - **Automatic Deployment**: 
     - Pushing to `main` branch → runs plan automatically
     - For actual deployment, use workflow_dispatch manually
   - **Manual Deployment**: 
     - Open the "Actions" tab in your GitHub repository
     - Select "Terraform Deploy Workflow"
     - Click "Run workflow"
     - Choose the environment to deploy (dev/staging/production) and action (plan/apply/destroy)
     - Click "Run workflow"

7. **Verify Deployment**:
   - After the GitHub Actions workflow execution, deployment information will be displayed
   - Alternatively, you can check resource information using the `terraform output` command