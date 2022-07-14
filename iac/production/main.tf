variable "gcp_project_id" {
}
variable "cred_file" {
}
variable "github_account" {
}
variable "github_repo_name" {
}
variable "db_user_name" {
}
variable "db_user_password" {
}

provider "google" {
  credentials = file("${var.cred_file}")
  project = var.gcp_project_id
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}
provider "google-beta" {
  credentials = file("${var.cred_file}")
  project = var.gcp_project_id
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}


# CI 実行アカウント
resource "google_service_account" "ci_service_account" {
  account_id   = "ci-${var.github_account}"
  display_name = "CI Service Account for ${var.github_account}"
}
# CI 実行アカウントに Cloud SQL 管理者権限をつける(staging db 作成や削除のため)
resource "google_project_iam_member" "ci_role_cloudsql_admin" {
  project = var.gcp_project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:ci-${var.github_account}@${var.gcp_project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_service_account.ci_service_account
  ]
}
# CI 実行アカウントにバケット管理権限をつける(Docker image アップロードや staging bucket 作成等のため)
resource "google_project_iam_member" "ci_role_storage_admin" {
  project = var.gcp_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:ci-${var.github_account}@${var.gcp_project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_service_account.ci_service_account
  ]
}
# CI 実行アカウントに run.admin 権限をつける(Cloud Run デプロイのため)
resource "google_project_iam_member" "ci_role_run_admin" {
  project = var.gcp_project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:ci-${var.github_account}@${var.gcp_project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_service_account.ci_service_account
  ]
}
# CI 実行アカウントに iam.serviceAccountUser 権限をつける(Cloud Run デプロイのため)
resource "google_project_iam_member" "ci_role_iam_service_account_user" {
  project = var.gcp_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:ci-${var.github_account}@${var.gcp_project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_service_account.ci_service_account
  ]
}

# CI 実行アカウントに resourcemanager.projectIamAdmin 権限をつける(main ブランチへのマージ時に Terraform を実行するため)
resource "google_project_iam_member" "ci_role_resourcemanager_project_iam_admin" {
  project = var.gcp_project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:ci-${var.github_account}@${var.gcp_project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_service_account.ci_service_account
  ]
}
# CI 実行アカウントに iam.serviceAccountViewer 権限をつける(main ブランチへのマージ時に Terraform を実行するため)
resource "google_project_iam_member" "ci_role_iam_service_account_viewer" {
  project = var.gcp_project_id
  role    = "roles/iam.serviceAccountViewer"
  member  = "serviceAccount:ci-${var.github_account}@${var.gcp_project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_service_account.ci_service_account
  ]
}
# CI 実行アカウントに iam.workloadIdentityPoolViewer 権限をつける(main ブランチへのマージ時に Terraform を実行するため)
resource "google_project_iam_member" "ci_role_iam_workload_identity_pool_viewer" {
  project = var.gcp_project_id
  role    = "roles/iam.workloadIdentityPoolViewer"
  member  = "serviceAccount:ci-${var.github_account}@${var.gcp_project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_service_account.ci_service_account
  ]
}



# DB 接続サービスアカウント
resource "google_service_account" "db_client_service_account" {
  account_id   = "db-client-${var.github_account}"
  display_name = "DB client service account for ${var.github_account}"
}
# DB 接続サービスアカウントに Cloud SQL 接続権限をつける(migrationなどのため)
resource "google_project_iam_member" "db_client_role_cloudsql_client" {
  project = var.gcp_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:db-client-${var.github_account}@${var.gcp_project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_service_account.db_client_service_account
  ]
}


# Cloud Run 実行アカウント
resource "google_service_account" "cloud_run_service_account" {
  account_id   = "cloud-run-${var.github_account}"
  display_name = "Cloud Run Service Account for ${var.github_account}"
}
# Cloud Run 実行アカウントに GCS 接続権限をつける
resource "google_project_iam_member" "cloud_run_role_storage_object_admin" {
  project = var.gcp_project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:cloud-run-${var.github_account}@${var.gcp_project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_service_account.cloud_run_service_account
  ]
}
# Cloud Run 実行アカウントに Cloud SQL 接続権限をつける
resource "google_project_iam_member" "cloud_run_role_cloudsql_client" {
  project = var.gcp_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:cloud-run-${var.github_account}@${var.gcp_project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_service_account.cloud_run_service_account
  ]
}


# Workload Identity Pool for GitHub Actions
# display_name は github アカウント名含め 32 文字以内となるよう適宜短縮
resource "google_iam_workload_identity_pool" "github_actions_pool" {
  provider                  = google-beta
  workload_identity_pool_id = "pool-${var.github_account}"
  display_name              = "Pool for ${var.github_account}"
  description               = "Pool for ${var.github_account}"
}

# Workload Identity Pool Provider for GitHub Actions
resource "google_iam_workload_identity_pool_provider" "github_actions_pool_provider" {
  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "provider-${var.github_account}"
  display_name                       = "Provider for ${var.github_account}"
  attribute_mapping                  = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  depends_on = [
    google_iam_workload_identity_pool.github_actions_pool
  ]
}

# CI 実行アカウントに Workload Identity User 権限をつける
resource "google_service_account_iam_member" "ci_role_iam_workload_identity_user" {
  service_account_id = google_service_account.ci_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions_pool.name}/attribute.repository/${var.github_repo_name}"
  depends_on = [
    google_service_account.ci_service_account,
    google_iam_workload_identity_pool.github_actions_pool
  ]
}

# PostgreSQL インスタンス
resource "google_sql_database_instance" "db_instance" {
  # 試行錯誤段階では消せるようにする
  deletion_protection = false

  name             = "db-instance-${var.github_account}"
  # database_version = "POSTGRES_13"
  database_version = "POSTGRES_14"
  region           = "asia-northeast1"
  settings {
    activation_policy = "ALWAYS"
    availability_type = "ZONAL"
    backup_configuration {
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
      start_time                     = "15:00"
      transaction_log_retention_days = 7
    }
    disk_autoresize       = true
    disk_autoresize_limit = 0
    disk_size             = 10
    disk_type             = "PD_SSD"
    ip_configuration {
      ipv4_enabled = true
    }
    location_preference {
      zone = "asia-northeast1-b"
    }
    pricing_plan = "PER_USE"
    tier         = "db-f1-micro"
  }
}

# PostgreSQL DB 接続ユーザ (サービスアカウントではなく DB のユーザ)
resource "google_sql_user" "sql_user" {
  instance = google_sql_database_instance.db_instance.name
  name     = var.db_user_name
  password = var.db_user_password
  depends_on = [
    google_sql_database_instance.db_instance
  ]
}


# 本番DB
resource "google_sql_database" "database_production" {
  name      = "db-production-${var.github_account}"
  instance  = google_sql_database_instance.db_instance.name
  charset   = "UTF8"
  collation = "en_US.UTF8"
  depends_on = [
    google_sql_database_instance.db_instance
  ]
}

# 本番環境用 GCS bucket
resource "google_storage_bucket" "bucket_production" {
  force_destroy            = false
  location                 = "ASIA-NORTHEAST1"
  name                     = "bucket-${var.gcp_project_id}-${var.github_account}"
  # public_access_prevention = "inherited"
  storage_class            = "STANDARD"
}
# 本番環境用 GCS bucket アクセス設定
resource "google_storage_bucket_access_control" "bucket_production_public_rule" {
  bucket = google_storage_bucket.bucket_production.name
  role   = "READER"
  entity = "allUsers"
  depends_on = [
    google_storage_bucket.bucket_production
  ]
}
