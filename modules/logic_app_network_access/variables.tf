# modules/private_logic_app/variables.tf

variable "name" {
  description = "The name of the private Logic App Standard"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
variable "logicapp_version" {
  description = "Logic App runtime version"
  type        = string
  default     = "4.0"
}
variable "location" {
  description = "The Azure region for deployment"
  type        = string
}
variable "public_network_access_enabled" {
  description = "Enable or disable public network access for the Logic App."
  type        = string
  default     = "Enabled"
}

variable "scm_site_ip_restrictions" {
  description = "List of SCM site IP restriction rules"
  type        = list(object({
    ip_address     = optional(string)
    service_tag    = optional(string)
    vnet_subnet_id = optional(string)
    name           = optional(string)
    priority       = optional(number)
    action         = optional(string)
  }))
  default     = []
}

variable "main_site_ip_restrictions" {
  description = "List of main site IP restriction rules"
  type        = list(object({
    ip_address     = optional(string)
    service_tag    = optional(string)
    vnet_subnet_id = optional(string)
    name           = optional(string)
    priority       = optional(number)
    action         = optional(string)
  }))
  default     = []
}

variable "https_only" {
  description = "Enable HTTPS only"
  type        = bool
  default     = true
}

variable "client_affinity_enabled" {
  description = "Enable client affinity"
  type        = bool
  default     = false
}

variable "enabled" {
  description = "Enable the Logic App"
  type        = bool
  default     = true
}

variable "site_config" {
  description = "Site configuration"
  type = object({
    always_on                 = optional(bool, true)
    ftps_state                = optional(string)
    http2_enabled             = optional(bool)
    min_tls_version           = optional(string)
    pre_warmed_instance_count = optional(number)
    scm_type                  = optional(string)
    vnet_route_all_enabled    = optional(bool)
  })
  default = {}
}

variable "app_settings" {
  description = "Additional app settings"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}