variable "resource_group_name" {
  description = "Name of the existing resource group to deploy every resource in this module call into. This module does not create the resource group itself."
  type        = string
}

variable "location" {
  description = "Azure region for every resource created by this module call."
  type        = string
}

variable "tags" {
  description = "Default tags applied to every resource created by this module call (e.g. the output of terraform-azure-tags). Overridden per-resource by that resource's own `tags` attribute, if set."
  type        = map(string)
  default     = {}
}

variable "lab_plans" {
  description = <<-EOT
    Map of Azure Lab Services lab plans to create, keyed by an arbitrary caller-chosen map key.

    NOTE: there is no published AVM module for Azure Lab Services (Microsoft.LabServices). The GitHub
    `Azure/terraform-azurerm-avm-res-devtestlab-lab` repository wraps the older, distinct "DevTest Labs"
    product and is not published to the Terraform Registry as of this writing, so it isn't usable here either.
    This wraps the native `azurerm_lab_service_plan` / `azurerm_lab_service_lab` resources directly and is
    deliberately conservative in scope -- validate against your provider version before relying on it, and
    swap in an AVM module if/when Microsoft publishes one.
    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lab_service_plan
  EOT
  type = map(object({
    name                      = string
    allowed_regions           = optional(list(string), null)
    shared_gallery_id         = optional(string, null)
    support_info              = optional(any, null)
    default_auto_shutdown     = optional(any, null)
    default_connection        = optional(any, null)
    default_network_subnet_id = optional(string, null)
    tags                      = optional(map(string))
  }))
  default = {}
}

variable "labs" {
  description = <<-EOT
    Map of Azure Lab Services labs to create, keyed by an arbitrary caller-chosen map key.
    `lab_plan_key` must reference a key in var.lab_plans.
  EOT
  type = map(object({
    name               = string
    lab_plan_key       = string
    title              = optional(string, null)
    description        = optional(string, null)
    virtual_machine    = any
    security           = optional(any, { open_access_enabled = false })
    connection_setting = optional(any, null)
    network            = optional(any, null)
    auto_shutdown      = optional(any, null)
    roster             = optional(any, null)
    tags               = optional(map(string))
  }))
  default = {}
}
