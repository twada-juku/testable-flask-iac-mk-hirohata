.PHONY: init plan apply

init:
	@GOOGLE_APPLICATION_CREDENTIALS=$(realpath $(CURDIR)/../../.terraform-account-credential.json) terraform init

plan:
	@GOOGLE_APPLICATION_CREDENTIALS=$(realpath $(CURDIR)/../../.terraform-account-credential.json) terraform plan \
		-var='gcp_project_id=sys0098096-2-84291304' \
		-var='github_account=mk-hirohata' \
		-var='github_repo_name=testable-flask-iac-mk-hirohata' \
		-var='db_user_name=juku-db-user' \
		-var='cred_file=$(realpath $(CURDIR)/../../.terraform-account-credential.json)'

apply:
	@GOOGLE_APPLICATION_CREDENTIALS=$(realpath $(CURDIR)/../../.terraform-account-credential.json) terraform apply \
		-var='gcp_project_id=sys0098096-2-84291304' \
		-var='github_account=mk-hirohata' \
		-var='github_repo_name=testable-flask-iac-mk-hirohata' \
		-var='db_user_name=juku-db-user' \
		-var='cred_file=$(realpath $(CURDIR)/../../.terraform-account-credential.json)'

destroy:
	@GOOGLE_APPLICATION_CREDENTIALS=$(realpath $(CURDIR)/../../.terraform-account-credential.json) terraform destroy \
		-var='gcp_project_id=sys0098096-2-84291304' \
		-var='github_account=mk-hirohata' \
		-var='github_repo_name=testable-flask-iac-mk-hirohata' \
		-var='db_user_name=juku-db-user' \
		-var='cred_file=$(realpath $(CURDIR)/../../.terraform-account-credential.json)'
