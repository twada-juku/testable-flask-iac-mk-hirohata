terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    bucket  = "tf-state-sys0098096-2-84291304-staging-mk-hirohata"
    prefix  = "terraform/state"
  }
}
