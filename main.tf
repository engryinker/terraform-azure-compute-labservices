resource "azurerm_lab_service_plan" "this" {
  for_each = var.lab_plans

  name                      = each.value.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  allowed_regions           = each.value.allowed_regions
  shared_gallery_id         = each.value.shared_gallery_id
  default_network_subnet_id = each.value.default_network_subnet_id

  dynamic "support_info" {
    for_each = each.value.support_info == null ? [] : [each.value.support_info]
    content {
      email        = try(support_info.value.email, null)
      instructions = try(support_info.value.instructions, null)
      phone        = try(support_info.value.phone, null)
      url          = try(support_info.value.url, null)
    }
  }

  dynamic "default_auto_shutdown" {
    for_each = each.value.default_auto_shutdown == null ? [] : [each.value.default_auto_shutdown]
    content {
      disconnect_delay_minutes = try(default_auto_shutdown.value.disconnect_delay_minutes, null)
      idle_delay_minutes       = try(default_auto_shutdown.value.idle_delay_minutes, null)
      no_connect_delay_minutes = try(default_auto_shutdown.value.no_connect_delay_minutes, null)
      shutdown_on_idle         = try(default_auto_shutdown.value.shutdown_on_idle, null)
    }
  }

  dynamic "default_connection" {
    for_each = each.value.default_connection == null ? [] : [each.value.default_connection]
    content {
      client_rdp_access = try(default_connection.value.client_rdp_access, null)
      client_ssh_access = try(default_connection.value.client_ssh_access, null)
      web_rdp_access    = try(default_connection.value.web_rdp_access, null)
      web_ssh_access    = try(default_connection.value.web_ssh_access, null)
    }
  }

  tags = coalesce(each.value.tags, var.tags)
}

resource "azurerm_lab_service_lab" "this" {
  for_each = var.labs

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  lab_plan_id         = azurerm_lab_service_plan.this[each.value.lab_plan_key].id
  title               = each.value.title
  description         = each.value.description

  virtual_machine {
    admin_user                                  = each.value.virtual_machine.admin_user
    image_reference                             = each.value.virtual_machine.image_reference
    sku                                         = each.value.virtual_machine.sku
    usage_quota                                 = each.value.virtual_machine.usage_quota
    additional_capability_gpu_drivers_installed = try(each.value.virtual_machine.additional_capability_gpu_drivers_installed, null)
    create_option                               = try(each.value.virtual_machine.create_option, null)
    non_admin_user                              = try(each.value.virtual_machine.non_admin_user, null)
    shutdown_on_disconnect_enabled              = try(each.value.virtual_machine.shutdown_on_disconnect_enabled, null)
  }

  dynamic "security" {
    for_each = each.value.security == null ? [] : [each.value.security]
    content {
      open_access_enabled = security.value.open_access_enabled
    }
  }

  dynamic "connection_setting" {
    for_each = each.value.connection_setting == null ? [] : [each.value.connection_setting]
    content {
      client_rdp_access = try(connection_setting.value.client_rdp_access, null)
      client_ssh_access = try(connection_setting.value.client_ssh_access, null)
    }
  }

  dynamic "network" {
    for_each = each.value.network == null ? [] : [each.value.network]
    content {
      subnet_id = try(network.value.subnet_id, null)
    }
  }

  dynamic "auto_shutdown" {
    for_each = each.value.auto_shutdown == null ? [] : [each.value.auto_shutdown]
    content {
      disconnect_delay_minutes = try(auto_shutdown.value.disconnect_delay_minutes, null)
      idle_delay_minutes       = try(auto_shutdown.value.idle_delay_minutes, null)
      no_connect_delay_minutes = try(auto_shutdown.value.no_connect_delay_minutes, null)
      shutdown_on_idle         = try(auto_shutdown.value.shutdown_on_idle, null)
    }
  }

  dynamic "roster" {
    for_each = each.value.roster == null ? [] : [each.value.roster]
    content {
      active_directory_group_id = try(roster.value.active_directory_group_id, null)
      lms_instance              = try(roster.value.lms_instance, null)
      lti_client_id             = try(roster.value.lti_client_id, null)
      lti_context_id            = try(roster.value.lti_context_id, null)
      lti_roster_endpoint       = try(roster.value.lti_roster_endpoint, null)
    }
  }

  tags = coalesce(each.value.tags, var.tags)
}
