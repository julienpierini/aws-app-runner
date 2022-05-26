locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment

  # Automatically load vpc variables
  app_runner_vars                  = read_terragrunt_config(find_in_parent_folders("vars/app-runner.hcl"))
  httpbin_cpu                      = local.app_runner_vars.locals.httpbin_cpu
  httpbin_enabled_auto_deployments = local.app_runner_vars.locals.httpbin_enabled_auto_deployments
  httpbin_image_version            = local.app_runner_vars.locals.httpbin_image_version
  httpbin_max_concurrency          = local.app_runner_vars.locals.httpbin_max_concurrency
  httpbin_max_size                 = local.app_runner_vars.locals.httpbin_max_size
  httpbin_memory                   = local.app_runner_vars.locals.httpbin_memory
  httpbin_min_size                 = local.app_runner_vars.locals.httpbin_min_size
  httpbin_port                     = local.app_runner_vars.locals.httpbin_port

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
  stack       = "app-runner"
  name_suffix = "${local.project}-${local.env}"

  # Terraform source
  module_version = "v0.1.0"

  # Tags
  tags = {
    Environment = local.env
    Project     = local.project
    stack       = local.stack
    Deployer    = "terraform"
  }
}

terraform {
  source = "git@github.com:julienpierini/terraform-aws-app-runner.git?ref=${local.module_version}"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "ecr" {
  config_path = "../ecr"
}

dependency "kms" {
  config_path = "../kms"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependencies {
  paths = ["../ecr", "../kms", "../vpc"]
}

inputs = {

  name_suffix = "${local.stack}-${local.name_suffix}"

  app_runner = {
    "httpbin" = {
      enable_vpc_egress_configuration = true
      enabled_auto_deployments        = local.httpbin_enabled_auto_deployments
      kms_key_arn                     = dependency.kms.outputs.key_arn

      image_repository_type = "ECR"
      image_identifier      = "${dependency.ecr.outputs.repository_url}:${local.httpbin_image_version}"

      vpc_id       = dependency.vpc.outputs.vpc_id
      subnets      = dependency.vpc.outputs.private_subnets

      auto_scaling_configuration = {
        max_concurrency = local.httpbin_max_concurrency
        max_size        = local.httpbin_max_size
        min_size        = local.httpbin_min_size
        tags            = local.tags
      }
      image_configuration = {
        port = local.httpbin_port
      }
      instance_configuration = {
        cpu    = local.httpbin_cpu
        memory = local.httpbin_memory
      }

      tags = local.tags
    }
  }

}
