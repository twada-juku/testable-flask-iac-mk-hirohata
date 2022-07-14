variable "gcp_project_id" {
}
variable "cred_file" {
}
variable "db_name" {
}
variable "db_instance_name" {
}
variable "bucket_name" {
}

provider "google" {
  credentials = file("${var.cred_file}")
  project = var.gcp_project_id
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}


# PR テスト環境用 DB
resource "google_sql_database" "database_for_pr" {
  name      = var.db_name
  instance  = var.db_instance_name
  charset   = "UTF8"
  collation = "en_US.UTF8"
}


# PR テスト環境用 GCS bucket
resource "google_storage_bucket" "bucket_for_pr" {
  # テスト環境にデータが入っていても消せるようにする
  force_destroy            = true
  location                 = "ASIA-NORTHEAST1"
  name                     = var.bucket_name
  # public_access_prevention = "inherited"
  storage_class            = "STANDARD"
}

# PR テスト環境用 GCS bucket アクセス設定
resource "google_storage_bucket_access_control" "bucket_for_pr_public_rule" {
  bucket = google_storage_bucket.bucket_for_pr.name
  role   = "READER"
  entity = "allUsers"
  depends_on = [
    google_storage_bucket.bucket_for_pr
  ]
}
