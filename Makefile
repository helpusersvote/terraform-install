TERRAFORM_VERSION = 0.11.8
KUBECTL_VERSION = v1.11.2

# Default to downloaded dependencies (if available)
export PATH := ./bin:$(PATH)

deploy:
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve -var 'do_destroy=true'

check:
	terraform init
	terraform plan

setup-env: bin/kubectl bin/terraform .git/hooks/pre-commit

bin/kubectl: bin
	curl -L https://storage.googleapis.com/kubernetes-release/release/$(KUBECTL_VERSION)/bin/linux/amd64/kubectl >$@
	chmod +x $@

bin/terraform: bin
	curl -L https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip | funzip >$@
	chmod +x $@

bin:
	mkdir -p $@

.git/hooks/pre-commit:
	./hack/setup-githooks.sh

.PHONY: deploy destroy check setup-env
