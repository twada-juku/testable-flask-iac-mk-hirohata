#!/bin/sh

if [ $# -ne 2 ] ; then
    echo "missing arguments. usage: $0 GitHubアカウント名（例: twada） GitHubリポジトリ名（例: twada-juku/testable-flask-iac-twada）"
    exit
fi

GITHUB_ACCOUNT=$1
GITHUB_REPOSITORY=$2
GCP_PROJECT_ID=$(gcloud config get-value project)
GCP_PROJECT_NUMBER=$(gcloud projects list --filter="${GCP_PROJECT_ID}" --format="value(PROJECT_NUMBER)")

echo "# CI/CD 用環境変数ファイルを生成"
cat << EOF > $(realpath "$(dirname $0)/../.ci_env")
DOCKER_BUILDKIT=1
COMPOSE_DOCKER_CLI_BUILD=1
GCP_REGION=asia-northeast1
GCP_PROJECT_ID=${GCP_PROJECT_ID}
GCP_CLOUD_RUN_SERVICE_NAME=testable-flask-iac-${GITHUB_ACCOUNT}
GCP_PROD_IMAGE_TAG_NAME=gcr.io/${GCP_PROJECT_ID}/testable-flask-iac-${GITHUB_ACCOUNT}
LOCAL_PROD_IMAGE_TAG_NAME=testable-flask-iac_stage-prod
GCP_DEV_IMAGE_TAG_NAME=gcr.io/${GCP_PROJECT_ID}/testable-flask-iac-dev-${GITHUB_ACCOUNT}
LOCAL_DEV_IMAGE_TAG_NAME=testable-flask-iac_stage-dev
GCP_DB_INSTANCE_NAME=db-instance-${GITHUB_ACCOUNT}
GCP_INSTANCE_CONNECTION_NAME=${GCP_PROJECT_ID}:asia-northeast1:db-instance-${GITHUB_ACCOUNT}
GCP_DB_NAME=db-production-${GITHUB_ACCOUNT}
PROD_DB_USER=juku-db-user
GCP_CLOUD_STORAGE_BUCKET_NAME=bucket-${GCP_PROJECT_ID}-${GITHUB_ACCOUNT}
GCP_CI_SA_EMAIL=ci-${GITHUB_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com
GCP_CLOUD_RUN_SA_EMAIL=cloud-run-${GITHUB_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com
GCP_WORKLOAD_IDENTITY_PROVIDER=projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/pool-${GITHUB_ACCOUNT}/providers/provider-${GITHUB_ACCOUNT}
EOF

echo "# 検証環境用 Terraform 設定ファイルを生成"
cat << EOF > $(realpath "$(dirname $0)/staging/terraform.tf")
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    bucket  = "tf-state-${GCP_PROJECT_ID}-staging-${GITHUB_ACCOUNT}"
    prefix  = "terraform/state"
  }
}
EOF

echo "# 本番環境用 Terraform 設定ファイルを生成"
cat << EOF > $(realpath "$(dirname $0)/production/terraform.tf")
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    bucket  = "tf-state-${GCP_PROJECT_ID}-production-${GITHUB_ACCOUNT}"
    prefix  = "terraform/state"
  }
}
EOF

echo "# GCP サービス初期設定用 Makefile を生成"
cat << EOF > $(realpath "$(dirname $0)/services/Makefile")
.PHONY: init plan apply

init:
	@GOOGLE_APPLICATION_CREDENTIALS=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json) terraform init

plan:
	@GOOGLE_APPLICATION_CREDENTIALS=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json) terraform plan \\
		-var='gcp_project_id=${GCP_PROJECT_ID}' \\
		-var='cred_file=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json)'

apply:
	@GOOGLE_APPLICATION_CREDENTIALS=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json) terraform apply \\
		-var='gcp_project_id=${GCP_PROJECT_ID}' \\
		-var='cred_file=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json)'
EOF

echo "# 本番環境用 Makefile を生成"
cat << EOF > $(realpath "$(dirname $0)/production/Makefile")
.PHONY: init plan apply

init:
	@GOOGLE_APPLICATION_CREDENTIALS=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json) terraform init

plan:
	@GOOGLE_APPLICATION_CREDENTIALS=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json) terraform plan \\
		-var='gcp_project_id=${GCP_PROJECT_ID}' \\
		-var='github_account=${GITHUB_ACCOUNT}' \\
		-var='github_repo_name=${GITHUB_REPOSITORY}' \\
		-var='db_user_name=juku-db-user' \\
		-var='cred_file=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json)'

apply:
	@GOOGLE_APPLICATION_CREDENTIALS=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json) terraform apply \\
		-var='gcp_project_id=${GCP_PROJECT_ID}' \\
		-var='github_account=${GITHUB_ACCOUNT}' \\
		-var='github_repo_name=${GITHUB_REPOSITORY}' \\
		-var='db_user_name=juku-db-user' \\
		-var='cred_file=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json)'

destroy:
	@GOOGLE_APPLICATION_CREDENTIALS=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json) terraform destroy \\
		-var='gcp_project_id=${GCP_PROJECT_ID}' \\
		-var='github_account=${GITHUB_ACCOUNT}' \\
		-var='github_repo_name=${GITHUB_REPOSITORY}' \\
		-var='db_user_name=juku-db-user' \\
		-var='cred_file=\$(realpath \$(CURDIR)/../../.terraform-account-credential.json)'
EOF
