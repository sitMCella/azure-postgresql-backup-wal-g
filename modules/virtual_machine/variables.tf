variable "resource_group_name" {
  description = "(Required) The name of the Resource Group."
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

variable "subnet_id" {
  description = "(Required) The ID of the subnet."
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

variable "storage_account_id" {
  description = "(Required) The ID of the Storage Account."
  type        = string
}

variable "allowed_public_ip_addresses" {
  description = "(Optional) The external IP addresses allowed to access the Azure resources."
  type        = list(string)
  default     = []
}

variable "virtual_machine_address_prefixes" {
  description = "(Required) The address prefixes of the Azure Virtual Machine subnet."
  type        = list(string)
}

variable "tags" {
  description = "(Optional) The Tags for the Azure resources."
  type        = map(string)
  default     = {}
}
