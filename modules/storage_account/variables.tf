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

variable "allowed_public_ip_addresses" {
  description = "(Required) List of public IP or IP ranges in CIDR Format."
  type        = list(string)
}

variable "allowed_virtual_network_subnet_ids" {
  description = "(Required) List of allowed subnet IDs."
  type        = list(string)
}

variable "tags" {
  description = "(Optional) The Tags for the Azure resources."
  type        = map(string)
  default     = {}
}
