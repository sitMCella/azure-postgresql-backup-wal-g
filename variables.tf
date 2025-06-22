variable "subscription_id" {
  description = "(Required) The Subscription ID."
  type        = string
}

variable "location" {
  description = "(Required) The location of the Azure resources (e.g. westeurope)."
  type        = string
}

variable "location_abbreviation" {
  description = "(Required) The location abbreviation (e.g. weu)."
  type        = string
}

variable "environment" {
  description = "(Required) The environment name (e.g. test)."
  type        = string
}

variable "workload_name" {
  description = "(Required) The name of the workload."
  type        = string
}

variable "postgresql_administrator_login" {
  description = "(Required) The administrator name for the PostgreSQL Flexible Server."
  type        = string
}

variable "postgresql_administrator_password" {
  description = "(Required) The administrator password for the PostgreSQL Flexible Server."
  type        = string
}

variable "vm_admin_username" {
  description = "(Required) The administrator username for the Azure Virtual Machine."
  type        = string
}

variable "vm_admin_password" {
  description = "(Required) The administrator password for the Azure Virtual Machine."
  type        = string
}

variable "allowed_public_ip_address_ranges" {
  description = "(Optional) The external IP address ranges allowed to access the Azure resources."
  type        = list(string)
  default     = []
}

variable "allowed_public_ip_addresses" {
  description = "(Optional) The external IP addresses allowed to access the Azure resources."
  type        = list(string)
  default     = []
}
