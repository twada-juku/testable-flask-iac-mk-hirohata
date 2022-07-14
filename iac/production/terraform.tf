terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    bucket  = "tf-state-sys0098096-2-84291304-production-mk-hirohata"
    prefix  = "terraform/state"
  }
}
