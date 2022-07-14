.PHONY: init plan apply

init:
	@GOOGLE_APPLICATION_CREDENTIALS=$(realpath $(CURDIR)/../../.terraform-account-credential.json) terraform init

plan:
	@GOOGLE_APPLICATION_CREDENTIALS=$(realpath $(CURDIR)/../../.terraform-account-credential.json) terraform plan \
		-var='gcp_project_id=sys0098096-2-84291304' \
		-var='cred_file=$(realpath $(CURDIR)/../../.terraform-account-credential.json)'

apply:
	@GOOGLE_APPLICATION_CREDENTIALS=$(realpath $(CURDIR)/../../.terraform-account-credential.json) terraform apply \
		-var='gcp_project_id=sys0098096-2-84291304' \
		-var='cred_file=$(realpath $(CURDIR)/../../.terraform-account-credential.json)'
