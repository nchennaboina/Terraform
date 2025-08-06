# modules/logic_app_network_access/main.tf
resource "azurerm_resource_group" "logicapp_rg" {
  name     = var.resource_group_name
  location = var.location
  tags = var.tags
}

resource "azurerm_storage_account" "logicapp_storage" {
  name                         = "logicappstorage${random_integer.suffix.result}"
  resource_group_name          = azurerm_resource_group.logicapp_rg.name
  location                     = azurerm_resource_group.logicapp_rg.location
  account_tier                 = "Standard"
  account_replication_type     = "LRS"
  min_tls_version              = "TLS1_2"
  #public_network_access_enabled = false
  tags = var.tags
 allow_nested_items_to_be_public = false
}

resource "azurerm_service_plan" "logicapp_plan" {
  name                = "logicapp-plan"
  location            = azurerm_resource_group.logicapp_rg.location
  resource_group_name = azurerm_resource_group.logicapp_rg.name
  os_type  = "Windows"
  sku_name = "WS1"
  tags = var.tags
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_logic_app_standard" "this" {
  name                       = "${var.name}-${random_integer.suffix.result}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_service_plan.logicapp_plan.id
  storage_account_name       = azurerm_storage_account.logicapp_storage.name
  storage_account_access_key = azurerm_storage_account.logicapp_storage.primary_access_key
  version                    = var.logicapp_version
  https_only                 = var.https_only
  client_affinity_enabled    = var.client_affinity_enabled
  enabled                    = var.enabled
  public_network_access      = var.public_network_access_enabled

  dynamic "site_config" {
    for_each = [var.site_config]
    content {
      always_on                 = site_config.value.always_on
      ftps_state                = site_config.value.ftps_state
      http2_enabled             = site_config.value.http2_enabled
      min_tls_version           = site_config.value.min_tls_version
      pre_warmed_instance_count = site_config.value.pre_warmed_instance_count
      scm_type                  = site_config.value.scm_type
      vnet_route_all_enabled    = site_config.value.vnet_route_all_enabled
      dynamic "ip_restriction" {
        for_each = var.public_network_access_enabled == "Enabled" ? var.main_site_ip_restrictions : []
        content {
          ip_address     = ip_restriction.value.ip_address
          service_tag    = ip_restriction.value.service_tag
          name           = ip_restriction.value.name
          priority       = ip_restriction.value.priority
          action         = ip_restriction.value.action
        }
      }

      # SCM site IP restrictions (multiple rules supported)
      dynamic "scm_ip_restriction" {
        for_each = var.public_network_access_enabled == "Enabled" ? var.scm_site_ip_restrictions : []
        content {
          ip_address     = scm_ip_restriction.value.ip_address
          service_tag    = scm_ip_restriction.value.service_tag
          name           = scm_ip_restriction.value.name
          priority       = scm_ip_restriction.value.priority
          action         = scm_ip_restriction.value.action
        }
      }
    }
  }
  app_settings = var.app_settings
  tags         = var.tags
}
