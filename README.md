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
  - MySQL: `B_Gen5_1` (Basic tier)
  - PostgreSQL: `B_Gen5_1` (Basic tier)

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

## Troubleshooting
### Common Issues
1. **Azure Authentication**:
    ```
    $ az login
    ```

2. **Subscription ID Not Set**:
    - Verify your Azure subscription is active
    - Ensure you have the necessary permissions

3. **Resource Provider Not Registered**:
    - Register required resource providers in your Azure subscription:
      - Microsoft.Storage
      - Microsoft.ContainerRegistry
      - Microsoft.App
      - Microsoft.DBforMySQL
      - Microsoft.DBforPostgreSQL
      - Microsoft.Network
      - Microsoft.Resources

4. **Database Connection Issues**:
    - Verify database connection strings in Terraform outputs
    - Check Azure Database instance status in portal
    - Ensure proper network configuration

### Getting Help
- Run `make help` for available commands
- Check script help: `./scripts/deploy.sh --help`
- Review Terraform outputs: `terraform output`
