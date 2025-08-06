terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "db005cb5-c9a9-4176-9bc3-d5078ef91c7b"
  features {}
}
module "azurerm_logic_app_standard" {
  source = "./modules/logic_app_network_access"

  name                       = "logicapp-demo"
  resource_group_name         = "rg-demo"
  location                   = "eastus"
  https_only                 = true
  client_affinity_enabled    = false
  enabled                    = true

  site_config = {
    always_on                 = true
    ftps_state                = "Disabled"
    http2_enabled             = true
    min_tls_version           = "1.2"
    pre_warmed_instance_count = 1
    scm_type                  = "None"
    vnet_route_all_enabled    = false
  }

  main_site_ip_restrictions = [
    {
      ip_address    = "203.0.113.0/24"
      priority      = 100
      name          = "Corporate Network"
      action        = "Allow"
      service_tag   = null
      vnet_subnet_id = null
    },
    {
      ip_address    = null
      service_tag   = "AzureCloud.westus2"
      priority      = 110
      name          = "Azure DevOps West US2"
      action        = "Allow"
      vnet_subnet_id = null
    }
  ]

  scm_site_ip_restrictions = []

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"     = "node"
    "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
  }

  tags = {
    environment = "demo"
    Owner       = "narendra.chennaboina@neudesic.com"
  }
}