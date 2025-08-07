#!/bin/bash

# Stop script on error
set -e

# Show usage
show_usage() {
    echo "Usage: $0 <environment>"
    echo ""
    echo "Arguments:"
    echo "  environment    Environment name to destroy (e.g., dev, staging, production)"
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

echo "🗑️ Destroying infrastructure for $ENVIRONMENT environment..."

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

# Plan destruction
echo "📋 Checking destruction plan..."
terraform plan -destroy

# Confirm with user
echo ""
echo "⚠️  Warning: This operation will delete all resources in the $ENVIRONMENT environment."
echo "   Resources to be deleted:"
echo "   - Resource Group"
echo "   - Storage Account"
echo "   - Container Registry"
echo "   - Container Apps"
echo "   - Database"
echo "   - Front Door"
echo "   - Virtual Network"
echo ""

# Special confirmation for production environment
if [[ "$ENVIRONMENT" == "production" ]]; then
    echo "🚨 Production environment destruction. Please be extra careful!"
    read -p "Are you sure you want to destroy the production environment? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "❌ Destruction cancelled."
        exit 1
    fi
else
    read -p "Are you sure you want to destroy the $ENVIRONMENT environment? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "❌ Destruction cancelled."
        exit 1
    fi
fi

# Execute destruction
echo "🗑️ Destroying infrastructure..."
terraform destroy -auto-approve

echo "✅ Destruction of $ENVIRONMENT environment completed!" 