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

### Cloud Platform
- [Microsoft Azure](https://azure.microsoft.com/) - Cloud platform for hosting and database services

### Frontend Services
- [Azure Storage Account](https://azure.microsoft.com/services/storage/) - Blob Storage with Static Website for frontend static files
- [Azure Front Door](https://azure.microsoft.com/services/frontdoor/) - Content delivery network and load balancer for frontend

### Backend Services
- [Azure Container Apps](https://azure.microsoft.com/services/container-apps/) - Serverless container platform for backend services
- [Azure Container Registry](https://azure.microsoft.com/services/container-registry/) - Container image registry for backend

### Database
- [Azure Database for MySQL](https://azure.microsoft.com/services/mysql/) - Managed MySQL database
- [Azure Database for PostgreSQL](https://azure.microsoft.com/services/postgresql/) - Managed PostgreSQL database

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
6. Authenticate with Terraform Cloud:
   ```bash
   terraform login
   ```

### Terraform Cloud Setup
This project uses Terraform Cloud for state management.

#### 1. Create Terraform Cloud Organization and Workspaces
1. Log in to [Terraform Cloud](https://app.terraform.io/)
2. Create an Organization (if you don't have one)
3. Create Workspaces for each environment:
   - `{workspace-prefix}-dev`
   - `{workspace-prefix}-staging`
   - `{workspace-prefix}-production`

#### 2. OIDC Authentication Setup (Recommended)
Setup instructions for using OIDC authentication to deploy to Azure from Terraform Cloud:

**Azure-side Configuration:**
1. Create a Federated Credential in Azure AD:
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
1. Navigate to your Terraform Cloud Workspace
2. Go to Settings → Variables
3. Add the following environment variables:
   - `ARM_USE_OIDC`: `true`
   - `ARM_CLIENT_ID`: Azure AD application Client ID (the `$APP_ID` above)
   - `ARM_SUBSCRIPTION_ID`: Azure Subscription ID
   - `ARM_TENANT_ID`: Azure Tenant ID

**Note:** When using OIDC authentication, `ARM_CLIENT_SECRET` is not required.

### GitHub Actions Setup
Setup instructions for deploying from GitHub Actions:

#### 1. Azure OIDC Authentication Setup
Setup instructions for using OIDC authentication to deploy to Azure from GitHub Actions:

**Azure-side Configuration:**
1. Create a Federated Credential in Azure AD:
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

2. **Grant Key Vault Access Permissions** (Required):
   
   The service principal needs access to Key Vault to read and manage secrets. This is especially important if Key Vault already exists or when Terraform needs to read existing secrets during `terraform plan` or `terraform apply`.
   
   **Option A: Using Azure Portal:**
   1. Navigate to Azure Portal → Key Vaults → Your Key Vault
   2. Go to "Access policies" → "Add Access Policy"
   3. Search for your service principal (using the Client ID from step 1)
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

**GitHub-side Configuration:**
1. Navigate to GitHub repository Settings → Secrets and variables → Actions
2. Add the following Secrets:
   - `AZURE_CLIENT_ID`: Azure AD application Client ID (the `$APP_ID` above)
   - `AZURE_TENANT_ID`: Azure Tenant ID
   - `AZURE_SUBSCRIPTION_ID`: Azure Subscription ID
   - `TF_ORG_NAME`: Terraform Cloud Organization name
   - `TF_WORKSPACE_NAME_PREFIX`: Terraform Cloud Workspace name prefix (e.g., `todo-infra`)

3. Create environments in GitHub repository Settings → Environments (dev, staging, production)

4. Terraform Cloud Authentication:
   - When using Terraform Cloud from GitHub Actions, Terraform Cloud authentication is required
   - Method 1: Add `TF_TOKEN_app_terraform_io` to GitHub Secrets (recommended)
   - Method 2: Create an API Token in Terraform Cloud Workspace and add it to GitHub Secrets
   - Note: `terraform login` is only valid for local environments and cannot be used in GitHub Actions

#### 2. Deploying with GitHub Actions
How to deploy from GitHub Actions:

**Manual Deployment (workflow_dispatch):**
1. Navigate to the GitHub repository Actions tab
2. Select "Terraform Deploy Workflow"
3. Click "Run workflow"
4. Select environment (dev/staging/production) and action (plan/apply/destroy)
5. Click "Run workflow"

**Automatic Deployment (push):**
- Pushing to the `main` branch automatically runs plan
- For actual deployment, use workflow_dispatch manually

### Initial Setup
1. Clone this repository:
    ```
    $ git clone https://github.com/kenwoo9y/todo-infra-azure.git
    $ cd todo-infra-azure
    ```

2. Authenticate with Azure:
    ```
    $ az login
    ```

3. Configure environment variables:
    ```
    $ cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
    ```
    Edit `environments/dev/terraform.tfvars` to match your requirements.

4. Deploy the infrastructure:
    ```
    $ ./scripts/deploy.sh dev
    ```

## Usage
### Infrastructure Management
- Deploy infrastructure:
    ```
    $ ./scripts/deploy.sh [dev|staging|production]
    ```
- Destroy infrastructure:
    ```
    $ ./scripts/destroy.sh [dev|staging|production]
    ```

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
### Environment Configuration
The project supports multiple environments (dev, staging, production) with separate configurations:

#### Development Environment
- **Location**: `environments/dev/`
- **Default Database**: MySQL
- **Database Plans**:
  - MySQL: `B_Standard_B1ms` (Burstable tier - cheapest option)
  - PostgreSQL: `B_Standard_B1ms` (Burstable tier - cheapest option)

#### Configuration Variables
- `resource_group_name`: Azure Resource Group name (required)
- `location`: Azure region (default: "japaneast")
- `project_name`: Project name prefix for resources (default: "todoapp-dev")
- `storage_account_name`: Storage account name (required)
- `acr_name`: Azure Container Registry name (required)
- `default_database_type`: Default database type ("mysql" or "postgresql")
- `database_name`: Database name (default: "todoapp_dev")
- `mysql_user`: MySQL database username (required)
- `mysql_password`: MySQL database password (required)
- `postgresql_user`: PostgreSQL database username (required)
- `postgresql_password`: PostgreSQL database password (required)

### Database Switching
The infrastructure supports both PostgreSQL and MySQL databases with two switching methods:

#### Method 1: Environment Variable Switching (Recommended)
Both database URLs are available as environment variables in Container Apps, allowing instant switching without redeployment:

1. **Get database information from Terraform outputs**:
    ```bash
    cd environments/dev
    terraform output
    ```

2. **Manual switching via Azure Portal**:
    - Go to Azure Portal → Container Apps → Your App → Revision Management
    - Edit the latest revision
    - Change `DB_TYPE` to "mysql" or "postgresql"
    - Change `MYSQL_DATABASE_URL` or `POSTGRESQL_DATABASE_URL` as needed
    - Deploy the new revision

3. **Manual switching via Azure CLI**:
    ```bash
    # Switch to MySQL
    az containerapp revision set-mode \
      --name dev-todoapp-dev-backend \
      --resource-group todo-app-dev-rg \
      --mode single \
      --revision dev-todoapp-dev-backend--latest
    
    # Update environment variables
    az containerapp update \
      --name dev-todoapp-dev-backend \
      --resource-group todo-app-dev-rg \
      --set-env-vars DB_TYPE=mysql
    ```

#### Method 2: Infrastructure Redeployment
Change the default database type in `terraform.tfvars` and redeploy:

1. **Edit terraform.tfvars**:
    ```bash
    # environments/dev/terraform.tfvars
    default_database_type = "mysql"  # or "postgresql"
    ```

2. **Redeploy infrastructure**:
    ```bash
    ./scripts/deploy.sh dev
    ```

### Output Information
After deployment, the following information is available:
- **Container App URL**: URL where the backend application is accessible
- **Front Door URL**: URL where the frontend application is accessible
- **Storage Account Web Endpoint**: Static website endpoint
- **Container Registry Login Server**: Container image registry information
- **MySQL Server FQDN**: MySQL database connection information
- **PostgreSQL Server FQDN**: PostgreSQL database connection information

## Deployment Workflow
1. **Infrastructure Setup**:
    ```
    $ ./scripts/deploy.sh dev
    ```

2. **Container Image Deployment**:
    - Build your application container image
    - Push to Azure Container Registry using the login server information from outputs
    - Update the `container_image` and `container_app_image_tag` variables in `terraform.tfvars`

3. **Application Deployment**:
    - Deploy your application to Container Apps
    - Set environment variables in your application
    - Run database migrations

4. **Database Configuration**:
    - Follow the manual switching instructions in the Database Switching section below

## Security & Best Practices
- Database passwords are stored as sensitive variables in Terraform
- Azure Database instances are configured with SSL enforcement
- Container Apps are configured with appropriate network security
- Infrastructure changes are version controlled
- Code quality is enforced through linting and formatting
