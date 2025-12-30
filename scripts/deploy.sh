#!/bin/bash

# Script to deploy environment
# Usage: ./scripts/deploy.sh [dev|staging|production]

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
    echo "  $0           # Deploy dev environment"
    echo "  $0 dev       # Deploy dev environment"
    echo "  $0 staging   # Deploy staging environment"
    echo "  $0 production # Deploy production environment"
    echo ""
    echo "Notes:"
    echo "  - Create .env file from .env.example and configure it"
    echo "  - Set Terraform Cloud environment variables: TF_ORG_NAME, TF_WORKSPACE_NAME_PREFIX"
    echo "  - Or set environment variables manually: TF_VAR_* etc."
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

# Azure credentials check (optional, but helpful)
if ! az account show >/dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Azure CLI authentication not found${NC}"
    echo -e "${YELLOW}Make sure you have authenticated with 'az login'${NC}"
    echo ""
fi

# Environment directory existence check
ENV_DIR="environments/$ENVIRONMENT"
if [ ! -d "$ENV_DIR" ]; then
    echo -e "${RED}Error: Environment directory '$ENV_DIR' does not exist${NC}"
    echo "Available environments:"
    ls -1 environments/ 2>/dev/null || echo "  (No environments found)"
    exit 1
fi

# Check for terraform.tfvars existence
if [ ! -f "$ENV_DIR/terraform.tfvars" ]; then
    echo -e "${YELLOW}Warning: terraform.tfvars file not found in $ENV_DIR${NC}"
    if [ -f "$ENV_DIR/terraform.tfvars.example" ]; then
        echo -e "${YELLOW}Please copy terraform.tfvars.example to terraform.tfvars and configure it.${NC}"
    else
        echo -e "${YELLOW}Please create $ENV_DIR/terraform.tfvars${NC}"
    fi
    exit 1
fi

echo -e "${BLUE}Environment: $ENVIRONMENT${NC}"
echo -e "${YELLOW}Starting deployment...${NC}"

# Change to environment directory
cd "$ENV_DIR"

# Setup backend configuration for Terraform Cloud (required)
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
  
  # Check Terraform Cloud authentication
  if [ -z "$TF_TOKEN_app_terraform_io" ] && [ ! -f "$HOME/.terraform.d/credentials.tfrc.json" ]; then
    echo -e "${YELLOW}Warning: Terraform Cloud authentication not found.${NC}"
    echo -e "${YELLOW}Please either:${NC}"
    echo -e "${YELLOW}  1. Run 'terraform login' to authenticate${NC}"
    echo -e "${YELLOW}  2. Or set TF_TOKEN_app_terraform_io environment variable${NC}"
    echo -e "${YELLOW}State upload may fail without authentication.${NC}"
    echo ""
  fi
else
  echo -e "${RED}Error: Terraform Cloud configuration is required.${NC}"
  echo -e "${RED}Please set the following environment variables:${NC}"
  echo -e "${RED}  - TF_ORG_NAME: Terraform Cloud organization name${NC}"
  echo -e "${RED}  - TF_WORKSPACE_NAME_PREFIX: Workspace name prefix${NC}"
  echo ""
  echo -e "${BLUE}Example:${NC}"
  echo -e "${BLUE}  export TF_ORG_NAME=\"your-org\"${NC}"
  echo -e "${BLUE}  export TF_WORKSPACE_NAME_PREFIX=\"todo-infra\"${NC}"
  exit 1
fi

# Terraform init
echo -e "${YELLOW}Running Terraform init...${NC}"
terraform init -input=false

# Terraform plan
echo -e "${YELLOW}Running Terraform plan...${NC}"
set +e
PLAN_OUTPUT=$(terraform plan 2>&1)
PLAN_EXIT_CODE=$?
set -e

# Terraform apply
echo -e "${YELLOW}Running Terraform apply...${NC}"
if [ $PLAN_EXIT_CODE -ne 0 ]; then
  # Plan failed (likely empty workspace on first deploy)
  echo "$PLAN_OUTPUT"
  if echo "$PLAN_OUTPUT" | grep -q "Error acquiring the state lock\|resource not found"; then
    echo -e "${YELLOW}Workspace is empty (first deploy). Running apply with -lock=false...${NC}"
    terraform apply -auto-approve -lock=false
  else
    echo -e "${RED}Plan failed. Please check the error above.${NC}"
    exit $PLAN_EXIT_CODE
  fi
else
  echo "$PLAN_OUTPUT"
  terraform apply -auto-approve
fi

# Cleanup temporary backend config file
if [ -f "backend-config.tfbackend" ]; then
  rm -f "backend-config.tfbackend"
fi

echo -e "${GREEN}Deployment completed!${NC}"
echo ""

# Display output values
echo -e "${BLUE}=== Output Values ===${NC}"
terraform output

echo ""
echo -e "${GREEN}Created resources:${NC}"
if terraform output -raw front_door_url >/dev/null 2>&1; then
  echo -e "  Front Door URL: https://$(terraform output -raw front_door_url)"
fi
if terraform output -raw container_app_url >/dev/null 2>&1; then
  echo -e "  Container App URL: https://$(terraform output -raw container_app_url)"
fi
if terraform output -raw storage_account_primary_web_endpoint >/dev/null 2>&1; then
  echo -e "  Storage Account Web Endpoint: $(terraform output -raw storage_account_primary_web_endpoint)"
fi

echo ""
echo -e "${BLUE}Next steps:${NC}"

# Check if Container App was created
if terraform output -raw container_app_url >/dev/null 2>&1; then
  echo "  1. Verify the deployed resources in Azure Portal"
  echo "  2. Configure application environment variables if needed"
  echo "  3. Run database migrations if required"
else
  # Container App was not created (container_image is empty)
  echo -e "${YELLOW}Container App was not created (container_image is empty).${NC}"
  echo ""
  echo -e "${BLUE}Next steps:${NC}"
  echo "  1. Build and push your Docker image to Container Registry"
  echo "  2. Update terraform.tfvars with the container_image URL"
  echo "  3. Run this script again to create Container App:"
  echo ""
  echo -e "     ${GREEN}./scripts/deploy.sh $ENVIRONMENT${NC}"
  echo ""
  echo "  4. Upload frontend application to Blob Storage"
  echo "  5. Verify the deployed resources in Azure Portal"
  echo "  6. Configure application environment variables if needed"
  echo "  7. Run database migrations if required"
fi 