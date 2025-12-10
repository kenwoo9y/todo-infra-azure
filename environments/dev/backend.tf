# Terraform Cloud backend (partial configuration)
# Backend configuration is provided via environment variables:
# - TF_ORG_NAME: Organization name (automatically used by deploy.sh)
# - TF_WORKSPACE_NAME_PREFIX: Workspace name prefix (automatically used by deploy.sh)
# - TF_CLI_ARGS_init: Can be set directly to pass -backend-config options
# The deploy.sh script automatically constructs TF_CLI_ARGS_init from TF_ORG_NAME and TF_WORKSPACE_NAME_PREFIX
terraform {
  backend "remote" {
    # Organization and workspace are configured via TF_CLI_ARGS_init environment variable
    # which is automatically set by deploy.sh or GitHub Actions
  }
}