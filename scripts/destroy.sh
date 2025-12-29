#!/bin/bash

# Script to destroy environment
# Usage: ./scripts/destroy.sh [dev|staging|production]

set -e

# Colored output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables from .env file if it exists
if [ -f ".env" ]; then
  echo -e "${BLUE}Loading environment variables from .env file...${NC}"
  set -a
  source .env
  set +a
elif [ -f ".env.example" ]; then
  echo -e "${YELLOW}Warning: .env file not found. Please copy .env.example to .env and configure it.${NC}"
fi

# Default environment
DEFAULT_ENV="dev"

# Help display
show_help() {
    echo "Usage: $0 [dev|staging|production]"
    echo ""
    echo "Arguments:"
    echo "  Environment: dev, staging, production (default: dev)"
    echo ""
    echo "Examples:"
    echo "  $0           # Destroy dev environment"
    echo "  $0 dev       # Destroy dev environment"
    echo "  $0 staging   # Destroy staging environment"
    echo "  $0 production # Destroy production environment"
    echo ""
    echo "Notes:"
    echo "  - This operation cannot be undone"
    echo "  - All data will be lost"
    echo "  - Create .env file from .env.example and configure it"
    echo "  - Or set environment variables manually: ARM_ACCESS_KEY, TF_VAR_* etc."
}

# Argument check
if [ $# -gt 1 ]; then
    echo -e "${RED}Error: Too many arguments${NC}"
    show_help
    exit 1
fi

ENVIRONMENT=${1:-$DEFAULT_ENV}

# Environment validation
if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "production" ]; then
    echo -e "${RED}Error: Environment must be 'dev', 'staging', or 'production'${NC}"
    show_help
    exit 1
fi

# Environment directory existence check
ENV_DIR="environments/$ENVIRONMENT"
if [ ! -d "$ENV_DIR" ]; then
    echo -e "${RED}Error: Environment directory '$ENV_DIR' does not exist${NC}"
    echo "Available environments:"
    ls -1 environments/ 2>/dev/null || echo "  (No environments found)"
    exit 1
fi

# Azure credentials check (optional, but helpful)
if ! az account show >/dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Azure CLI authentication not found${NC}"
    echo -e "${YELLOW}Make sure you have authenticated with 'az login'${NC}"
    echo ""
fi

echo -e "${BLUE}Environment: $ENVIRONMENT${NC}"
echo -e "${RED}Warning: This operation cannot be undone. All data will be lost.${NC}"

# Confirmation prompt
read -p "Are you sure you want to destroy the $ENVIRONMENT environment? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${YELLOW}Destruction cancelled${NC}"
    exit 0
fi

echo -e "${YELLOW}Starting environment destruction...${NC}"

# Change to environment directory
cd "$ENV_DIR"

# Setup backend configuration for Terraform Cloud if environment variables are set
if [ -n "$TF_ORG_NAME" ] && [ -n "$TF_WORKSPACE_NAME_PREFIX" ]; then
  WORKSPACE_NAME="${TF_WORKSPACE_NAME_PREFIX}-${ENVIRONMENT}"
  BACKEND_CONFIG_FILE="backend-config.tfbackend"
  cat > "$BACKEND_CONFIG_FILE" <<EOF
organization = "${TF_ORG_NAME}"
workspaces {
  name = "${WORKSPACE_NAME}"
}
EOF
  export TF_CLI_ARGS_init="-backend-config=$BACKEND_CONFIG_FILE"
  echo -e "${BLUE}Using Terraform Cloud backend: ${TF_ORG_NAME}/${WORKSPACE_NAME}${NC}"
fi

# Terraform init
echo -e "${YELLOW}Running Terraform init...${NC}"
terraform init -input=false

# Terraform destroy
echo -e "${YELLOW}Running Terraform destroy...${NC}"
terraform destroy -auto-approve

# Cleanup temporary backend config file
if [ -f "backend-config.tfbackend" ]; then
  rm -f "backend-config.tfbackend"
fi

echo -e "${GREEN}Environment destruction completed!${NC}"
echo ""
echo "Destroyed resources:"
echo "  - Resource Group"
echo "  - Storage Account"
echo "  - Container Registry"
echo "  - Container Apps"
echo "  - Database (MySQL/PostgreSQL)"
echo "  - Front Door"
echo "  - Key Vault"
echo "  - Log Analytics Workspace"
echo "  - Other Azure resources"
echo ""
echo -e "${BLUE}Note: It is recommended to also remove environment variable files in your application repository${NC}" 