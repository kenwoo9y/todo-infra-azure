.PHONY: help lint-check lint-fix format-check format-fix chmod-scripts
.DEFAULT_GOAL := help

lint-check: ## Check terraform code with tflint
	tflint --recursive

lint-fix: ## Fix terraform code with tflint
	tflint --recursive --fix

format-check: ## Check the terraform code format
	terraform fmt -check -recursive

format-fix: ## Format the terraform code
	terraform fmt -recursive

chmod-scripts: ## Make scripts executable
	chmod +x scripts/*.sh

help: ## Show options
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'