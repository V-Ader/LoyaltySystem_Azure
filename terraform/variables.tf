variable "location" {
  description = "Azure region"
  default     = "northeurope"
}

variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "github token"
  type        = string
  sensitive   = true
}