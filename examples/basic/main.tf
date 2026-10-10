terraform {
  required_version = ">= 1.7.0"
}

module "labservices" {
  source = "../.."

  resource_group_name = "rg-example"
  location            = "eastus"
  tags = {
    environment = "dev"
  }

  lab_plans = {} # see README Inputs table for the per-entry schema
  labs      = {}
}
