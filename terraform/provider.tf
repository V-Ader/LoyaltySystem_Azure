terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.5.2"
    }
  }
}

provider "kubernetes" {
  host                   = var.k8s_host
  token                  = var.k8s_token
  cluster_ca_certificate = base64decode(var.k8s_ca)
}

provider "argocd" {
  server_addr = var.argocd_server_addr
  username    = var.argocd_username
  password    = var.argocd_password
}
