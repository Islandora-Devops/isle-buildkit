# Isle Terraform Configuration

This Terraform configuration manages Digital Ocean Spaces buckets for Isle's
build and cache infrastructure.

> This requires that the bucket `isle-terraform-state` has been manually created.

## Buckets Created

- `isle-cache-gradle`: Gradle cache bucket
- `isle-cache-buildkit`: BuildKit cache bucket
- `isle-cache-sccache`: Shared Compilation cache bucket

All cache buckets are configured with public read access.

## Prerequisites

1. Terraform >= 1.0.0
2. Digital Ocean account and API token
3. AWS CLI configured with Digital Ocean Spaces credentials (for state management)

## Setup

Copy `terraform.tfvars.example` to `terraform.tfvars`:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and add your Digital Ocean API token:

```hcl
do_token = "your-digital-ocean-token-here"
```

An access key and secret key is required to store state in a DigitalOcean Space. You will find this in BitWarden.

```bash
export AWS_ACCESS_KEY_ID="<your_access_key>"
export AWS_SECRET_ACCESS_KEY="<your_secret_key>"
export SPACES_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export SPACES_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
```

Initialize Terraform:

```bash
terraform init
```

Review the planned changes:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

## State Management

The Terraform state is stored in the `isle-terraform-state` bucket in Digital Ocean Spaces. The state is automatically configured to use this bucket.

## Bucket Access

All cache buckets (`isle-cache-gradle`, `isle-cache-buildkit`, `isle-cache-sccache`) are configured with public read access. This means anyone can read objects from these buckets, but only authorized users can write to them.

## Lifecycle Policy

Since DigitalOcean Spaces allow up to 250GiB in the base tier, it is unlikely that we will ever hit that restriction. Therefore, there is no lifecycle policy on the buckets. This can always be revisited in the future.
