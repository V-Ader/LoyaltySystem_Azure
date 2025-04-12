# Provider for azurerm and helm
provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-k8s-argo"
  location = "northeurope"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-argo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksargo"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  kubernetes_version = "1.29.2"

  oidc_issuer_enabled = true

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  create_namespace = true

  values = [<<EOF
server:
  service:
    type: LoadBalancer
EOF
  ]
}

resource "kubernetes_manifest" "argocd_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "my-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL = "https://github.com/V-Ader/Loyalty---Azure.git"
        targetRevision = "HEAD"
        path = "deploy/cards_api"  # or path to your Kubernetes manifests
      }
      destination = {
        server = "https://kubernetes.default.svc"
        namespace = "default"  # or wherever you want your app to be deployed
      }
      syncPolicy = {
        automated = {
          prune = true
          selfHeal = true
        }
      }
    }
  }
}

resource "kubernetes_secret" "acr-credentials" {
  metadata {
    name      = "acr-credentials"
    namespace = var.argocd_namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = base64encode(jsonencode({
      auths = {
        "imageregistryaderkz.azurecr.io" = {
          username = var.acr_username
          password = var.acr_password
          email    = "you@example.com"
          auth     = base64encode("${var.acr_username}:${var.acr_password}")
        }
      }
    }))
  }
}
