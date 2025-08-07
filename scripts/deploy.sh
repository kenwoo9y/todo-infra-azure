#!/bin/bash

# Stop script on error
set -e

# Show usage
show_usage() {
    echo "Usage: $0 <environment>"
    echo ""
    echo "Arguments:"
    echo "  environment    Environment name to deploy (e.g., dev, staging, production)"
    echo ""
    echo "Examples:"
    echo "  $0 dev"
    echo "  $0 staging"
    echo "  $0 production"
    exit 1
}

# Check arguments
if [ $# -eq 0 ]; then
    echo "❌ Error: Environment name not specified."
    show_usage
fi

ENVIRONMENT=$1

# Validate environment name
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    echo "❌ Error: Invalid environment name."
    echo "   Valid environment names: dev, staging, production"
    exit 1
fi

# Setup Terraform backend if not exists
setup_backend() {
    echo "🔧 Checking Terraform backend setup..."
    
    RESOURCE_GROUP_NAME="terraform-state-rg"
    STORAGE_ACCOUNT_NAME="tfstatetodoapp"
    CONTAINER_NAME="tfstate"
    LOCATION="japaneast"
    
    # Check if resource group exists
    if ! az group show --name $RESOURCE_GROUP_NAME >/dev/null 2>&1; then
        echo "📦 Creating resource group..."
        az group create \
          --name $RESOURCE_GROUP_NAME \
          --location $LOCATION \
          --tags Environment=infrastructure Project=todo-app ManagedBy=terraform
    fi
    
    # Check if storage account exists
    if ! az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME >/dev/null 2>&1; then
        echo "💾 Creating storage account..."
        az storage account create \
          --resource-group $RESOURCE_GROUP_NAME \
          --name $STORAGE_ACCOUNT_NAME \
          --sku Standard_LRS \
          --encryption-services blob \
          --location $LOCATION \
          --tags Environment=infrastructure Project=todo-app ManagedBy=terraform
    fi
    
    # Check if container exists
    if ! az storage container show --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME >/dev/null 2>&1; then
        echo "📁 Creating blob container..."
        az storage container create \
          --name $CONTAINER_NAME \
          --account-name $STORAGE_ACCOUNT_NAME
    fi
    
    # Get access key
    ACCOUNT_KEY=$(az storage account keys list \
      --resource-group $RESOURCE_GROUP_NAME \
      --account-name $STORAGE_ACCOUNT_NAME \
      --query '[0].value' \
      --output tsv)
    
    # Set environment variable
    export ARM_ACCESS_KEY=$ACCOUNT_KEY
    
    echo "✅ Terraform backend setup completed!"
    echo "🔑 Access key has been set as ARM_ACCESS_KEY environment variable"
}

# Check and setup backend
setup_backend

echo "🚀 Deploying infrastructure for $ENVIRONMENT environment..."

# Environment directory path
ENV_DIR="environments/$ENVIRONMENT"

# Check if environment directory exists
if [[ ! -d "$ENV_DIR" ]] || [[ ! -f "$ENV_DIR/main.tf" ]] || [[ ! -f "$ENV_DIR/variables.tf" ]]; then
    echo "❌ Error: $ENVIRONMENT environment directory or required files not found."
    echo "   Please check the $ENV_DIR directory."
    exit 1
fi

# Change to environment directory
cd "$ENV_DIR"

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Plan deployment
echo "📋 Checking deployment plan..."
terraform plan

# Confirm with user
read -p "Continue deployment to $ENVIRONMENT environment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 1
fi

# Execute deployment
echo "🏗️ Deploying infrastructure..."
terraform apply -auto-approve

# Deployment completed
echo "✅ Deployment to $ENVIRONMENT environment completed!"
echo ""
echo "📊 Deployment results:"
terraform output

echo ""
echo "🔗 Access URLs:"
echo "Front Door URL: https://$(terraform output -raw front_door_url)"
echo "Container App URL: https://$(terraform output -raw container_app_url)"
echo "Storage Account Web Endpoint: $(terraform output -raw storage_account_primary_web_endpoint)"

echo ""
echo "📝 Next steps:"
echo "1. Push application Docker image to Container Registry"
echo "2. Upload frontend application to Blob Storage"
echo "3. Update Container App to deploy new image" 