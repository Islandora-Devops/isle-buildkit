terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  backend "s3" {
    endpoints = {
      s3 = "https://tor1.digitaloceanspaces.com"
    }

    bucket = "isle-terraform-state"
    key    = "terraform.tfstate"

    # Deactivate a few AWS-specific checks
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    region                      = "us-east-1"
  }
}

provider "digitalocean" {
  token = var.do_token
}

locals {
  buckets = {
    gradle_cache   = "isle-cache-gradle"
    buildkit_cache = "isle-cache-buildkit"
    sccache_cache  = "isle-cache-sccache"
  }
}

# Create all buckets
resource "digitalocean_spaces_bucket" "buckets" {
  for_each = local.buckets
  name          = each.value
  region        = "tor1"
  force_destroy = false
}

# Create public read policies for each bucket
resource "digitalocean_spaces_bucket_policy" "bucket_policies" {
  for_each = local.buckets
  bucket = digitalocean_spaces_bucket.buckets[each.key].name
  region = "tor1"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["arn:aws:s3:::${each.value}/*"]
      }
    ]
  })
} 