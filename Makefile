SHELL := /usr/bin/env bash

# Check variable is provided
ifndef env
	$(error "env" flag is not set)
endif

# HOW TO EXECUTE

# Executing Terraform PLAN
#	$ make tf-plan env=<env>
#    e.g.,
#       make tf-plan env=dev

# Executing Terraform APPLY
#   $ make tf-apply env=<env>

# Executing Terraform DESTROY
#	$ make tf-destroy env=<env>

all-test: clean tf-plan

.PHONY: clean
clean:
	rm -rf .terraform

.PHONY: tf-plan
tf-plan:
	terraform fmt && terraform init -backend-config accounts/${env}/backend.conf -reconfigure && terraform validate && terraform plan -var-file accounts/${env}/terraform.tfvars

.PHONY: tf-apply
tf-apply:
	terraform fmt && terraform init -backend-config accounts/${env}/backend.conf -reconfigure && terraform validate && terraform apply -var-file accounts/${env}/terraform.tfvars -auto-approve

.PHONY: tf-destroy
tf-destroy:
	terraform init -backend-config accounts/${env}/backend.conf -reconfigure && terraform destroy -var-file accounts/${env}/terraform.tfvars
