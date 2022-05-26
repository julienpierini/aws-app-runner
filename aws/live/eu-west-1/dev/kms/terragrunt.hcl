locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.aws_account_id

  # Automatically load project-level variables
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  project      = local.project_vars.locals.project

  # Variables
  stack       = "kms"
  name_suffix = "${local.project}-${local.env}"

  # Terraform source
  module_version = "0.12.1"

  # Tags
  tags = {
    Environment = local.env
    Project     = local.project
    Deployer    = "terraform"
    Stack       = local.stack
    Name        = "ksm-app-runner-${local.name_suffix}"
  }
}

terraform {
  source = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=${local.module_version}"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  name                = "ksm-app-runner-${local.name_suffix}"
  description         = "KMS key for app-runner ${local.env}"
  enable_key_rotation = true
  alias               = "alias/kms-app-runner-${local.name_suffix}"
  tags                = local.tags
}
