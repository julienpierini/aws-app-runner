locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment

  # Automatically load vpc variables
  vpc_vars           = read_terragrunt_config(find_in_parent_folders("vars/vpc.hcl"))
  cidr               = local.vpc_vars.locals.cidr
  azs                = local.vpc_vars.locals.azs
  private_subnets    = local.vpc_vars.locals.private_subnets
  public_subnets     = local.vpc_vars.locals.public_subnets
  enable_nat_gateway = local.vpc_vars.locals.enable_nat_gateway

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
  stack       = "vpc"
  name_suffix = "${local.project}-${local.env}"

  # Terraform source
  module_version = "v3.14.0"

  # Tags
  tags = {
    Environment = local.env
    Project     = local.project
    stack       = local.stack
    Deployer    = "terraform"
  }
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git?ref=${local.module_version}"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {

  name = "${local.stack}-${local.name_suffix}"
  cidr = local.cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = local.enable_nat_gateway

  tags = local.tags

}
