provider "google" {
  project = "misskey-peacock0803sz"
  region  = "asia-northeast1"
}
provider "google-beta" {
  project = "misskey-peacock0803sz"
  region  = "asia-northeast1"
}

terraform {
  required_providers {
    google = {
      version = ">=4.47.0"
    }
  }
}
