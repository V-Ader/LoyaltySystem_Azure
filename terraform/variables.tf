variable "location" {
  description = "Azure region"
  default     = "northeurope"
}

variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "k8s_host" {
  description = "The Kubernetes API server endpoint"
  type        = string
}

variable "k8s_token" {
  description = "Bearer token for authentication to the Kubernetes API"
  type        = string
  sensitive   = true
}

variable "k8s_ca" {
  description = "Base64-encoded certificate authority data for the Kubernetes cluster"
  type        = string
  sensitive   = true
}

variable "argocd_server_addr" {
  description = "The ArgoCD API server address (e.g., https://argocd.example.com)"
  type        = string
}

variable "argocd_username" {
  description = "Username for logging into the ArgoCD API"
  type        = string
}

variable "argocd_password" {
  description = "Password for ArgoCD API user"
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
