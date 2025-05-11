variable "location" {
  description = "Azure region"
  default     = "northeurope"
}

variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "acr_username" {
  description = "Username for logging into the acr"
  type        = string
}

variable "acr_password" {
  description = "Password for acr"
  type        = string
  sensitive   = true
}
