terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

variable "gcp_project_id" {
}
variable "cred_file" {
}

provider "google" {
  credentials = file("${var.cred_file}")
  project = var.gcp_project_id
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

# Cloud Resource Manager API
# Creates, reads, and updates metadata for Google Cloud Platform resource containers.
resource "google_project_service" "cloudresourcemanager_googleapis_com" {
  service = "cloudresourcemanager.googleapis.com"
}
# Identity and Access Management (IAM) API
# Manages identity and access control for Google Cloud Platform resources, including the creation of service accounts, which you can use to authenticate to Google and make API calls.
resource "google_project_service" "iam_googleapis_com" {
  service = "iam.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_googleapis_com
  ]
}
# IAM Service Account Credentials API
resource "google_project_service" "iamcredentials_googleapis_com" {
  service = "iamcredentials.googleapis.com"
  depends_on = [
    google_project_service.iam_googleapis_com,
  ]
}
# Google Cloud Storage JSON API
# Lets you store and retrieve potentially-large, immutable data objects.
resource "google_project_service" "storage_api_googleapis_com" {
  service = "storage-api.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_googleapis_com
  ]
}
# Google Container Registry API
# Google Container Registry provides secure, private Docker image storage on Google Cloud Platform
resource "google_project_service" "containerregistry_googleapis_com" {
  service = "containerregistry.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_googleapis_com,
    google_project_service.storage_api_googleapis_com
  ]
}
# Cloud Build API
# Cloud Build, Google Cloud’s continuous integration (CI) and continuous delivery (CD) platform, lets you build software quickly across all languages.
resource "google_project_service" "cloudbuild_googleapis_com" {
  service = "cloudbuild.googleapis.com"
  depends_on = [
    google_project_service.containerregistry_googleapis_com
  ]
}
# Cloud Storage
# Google Cloud Storage is a RESTful service for storing and accessing your data on Google's infrastructure.
resource "google_project_service" "storage_component_googleapis_com" {
  service = "storage-component.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_googleapis_com
  ]
}
# Cloud SQL
# Google Cloud SQL is a hosted and fully managed relational database service on Google's infrastructure.
resource "google_project_service" "sql_component_googleapis_com" {
  service = "sql-component.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_googleapis_com
  ]
}
# Cloud SQL Admin API
# API for Cloud SQL database instance management
resource "google_project_service" "sqladmin_googleapis_com" {
  service = "sqladmin.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_googleapis_com
  ]
}
# Cloud Run API
# Serverless agility for containerized apps
resource "google_project_service" "run_googleapis_com" {
  service = "run.googleapis.com"
  depends_on = [
    google_project_service.containerregistry_googleapis_com,
    google_project_service.storage_component_googleapis_com
  ]
}
# Security Token Service API
# The Security Token Service exchanges Google or third-party credentials for a short-lived access token to Google Cloud resources.
resource "google_project_service" "sts_googleapis_com" {
  service = "sts.googleapis.com"
  depends_on = [
    google_project_service.iam_googleapis_com,
  ]
}
