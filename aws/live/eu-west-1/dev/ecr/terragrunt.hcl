locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment

  ecr_vars          = read_terragrunt_config(find_in_parent_folders("vars/ecr.hcl"))
  roles_arn         = local.ecr_vars.locals.read_write_access_roles_arn
  count_number      = local.ecr_vars.locals.max_count_number
  registry_scanning = local.ecr_vars.locals.enable_registry_scanning

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
  stack       = "ecr"
  name_suffix = "${local.project}-${local.env}"

  # Terraform source
  module_version = "v1.1.1"

  # Tags
  tags = {
    Environment = local.env
    Project     = local.project
    Stack       = local.stack
    Deployer    = "terraform"
  }
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-ecr.git?ref=${local.module_version}"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  repository_name = "httpbin-${local.name_suffix}"

  repository_read_access_arns = [
    "arn:aws:iam::${local.account_id}:root",
    "arn:aws:iam::${local.account_id}:role/service-role/AppRunnerECRAccessRole"
  ]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last ${local.count_number} images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = local.count_number
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
  # Registry Scanning Configuration
  manage_registry_scanning_configuration = local.registry_scanning
  registry_scan_type                     = "ENHANCED"
  registry_scan_rules = [
    {
      scan_frequency = "SCAN_ON_PUSH"
      filter         = "*"
      filter_type    = "WILDCARD"
      }, {
      scan_frequency = "CONTINUOUS_SCAN"
      filter         = "example"
      filter_type    = "WILDCARD"
    }
  ]
  tags = local.tags
}
