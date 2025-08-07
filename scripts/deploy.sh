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