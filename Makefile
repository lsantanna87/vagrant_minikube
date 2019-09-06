THIS_FILE := $(lastword $(MAKEFILE_LIST))
.ONESHELL:

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build_local
build_local: ## Build local env using vagrant and playing local playbook
	@$(MAKE) -f $(THIS_FILE) prepare
	@$(MAKE) -f $(THIS_FILE) lint playbook=local_deploy.yml
	@vagrant up
	@ansible-playbook -i inventories/local -e env_name=local local_deploy.yml


.PHONY: deploy
deploy: ## deploy to a real env
ifneq ($(strip $(env)),)
				@$(MAKE) -f $(THIS_FILE) prepare
				@ansible-playbook -i inventories/$(env) -e env_name=$(env) deploy.yml
else
	@echo "env is required!"
endif

.PHONY: prepare
prepare: ## install all the dependencies
	@python3 -m venv env && \
					source env/bin/activate && \
					pip3 install -r requirements.txt

.PHONY: destroy_local
destroy_local: ## Destroy the local env
	@vagrant destroy

.PHONY: lint
lint: ## Ansible lint
ifneq ($(strip $(playbook)),)
				@ansible-lint ./$(playbook)
else
	@echo "Error when invoking make lint"
	@echo "Expected: make lint playbook=<PLAYBOOKNAME.YML>"
endif
