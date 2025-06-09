terraform {
  required_providers {
    sakuracloud = {
      source = "sacloud/sakuracloud"

      # We recommend pinning to the specific version of the SakuraCloud Provider you're using
      # since new versions are released frequently
      version = "2.26.0"
      #version = "~> 2"
    }
  }
}

provider "sakuracloud" {
  token        = var.sakuracloud_access_token
  secret = var.sakuracloud_access_token_secret
  zone                = var.sakuracloud_zone
}