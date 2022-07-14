#!/bin/sh

if [ $# -ne 1 ] ; then
    echo "missing arguments. usage: $0 GitHubアカウント名"
    exit
fi

GITHUB_ACCOUNT=$1
GCP_PROJECT_ID=$(gcloud config get-value project)

echo "# Service Usage API を有効化 (Terraform に必要)"
gcloud services enable serviceusage.googleapis.com

echo "# Terraform 用のサービスアカウントを作成"
gcloud iam service-accounts create terraform-${GITHUB_ACCOUNT} --display-name "Terraform Service Account for ${GITHUB_ACCOUNT}"

echo "# Terraform 用のサービスアカウントに権限をつける"
echo "## roles/editor をつける"
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} --member="serviceAccount:terraform-${GITHUB_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" --role="roles/editor"

echo "## roles/resourcemanager.projectIamAdmin をつける"
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} --member="serviceAccount:terraform-${GITHUB_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" --role="roles/resourcemanager.projectIamAdmin"

echo "## roles/iam.serviceAccountAdmin をつける"
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} --member="serviceAccount:terraform-${GITHUB_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" --role="roles/iam.serviceAccountAdmin"

echo "## roles/run.admin をつける"
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} --member="serviceAccount:terraform-${GITHUB_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" --role="roles/run.admin"

echo "## roles/iam.workloadIdentityPoolAdmin をつける"
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} --member="serviceAccount:terraform-${GITHUB_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" --role="roles/iam.workloadIdentityPoolAdmin"

echo "# Terraform 用のサービスアカウントの認証情報をダウンロード"
gcloud iam service-accounts keys create ./.terraform-account-credential.json --iam-account="terraform-${GITHUB_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" --key-file-type=json

echo "# 本番環境 Terraform state 用のバケット作成"
gsutil mb "gs://tf-state-${GCP_PROJECT_ID}-production-${GITHUB_ACCOUNT}"

echo "# ステージング環境 Terraform state 用のバケット作成"
gsutil mb "gs://tf-state-${GCP_PROJECT_ID}-staging-${GITHUB_ACCOUNT}"
