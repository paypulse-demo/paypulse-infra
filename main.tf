provider "azurerm" {
  features {}
}

# Resource group for everything
resource "azurerm_resource_group" "paypulse" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

# The AKS cluster
resource "azurerm_kubernetes_cluster" "paypulse" {
  name                = "${var.project_name}-${var.environment}-aks"
  location            = azurerm_resource_group.paypulse.location
  resource_group_name = azurerm_resource_group.paypulse.name
  dns_prefix          = "${var.project_name}-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.node_size

    # Auto-scaling (the HPA in File 4 needs this)
    auto_scaling_enabled = true
    min_count            = 2
    max_count            = 5

    # Smaller OS disk to save cost
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  # Use Azure CNI for better network policy support
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Configure Kubernetes provider using cluster credentials
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.paypulse.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.paypulse.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.paypulse.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.paypulse.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.paypulse.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.paypulse.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.paypulse.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.paypulse.kube_config[0].cluster_ca_certificate)
  }
}

# The helm provider will use the same kubeconfig as the kubernetes provider
# No explicit provider block required when using default kubeconfig

# Namespace for the application
resource "kubernetes_namespace" "paypulse_prod" {
  metadata {
    name = "paypulse-prod"
    labels = {
      project     = var.project_name
      environment = "prod"
    }
  }

  depends_on = [azurerm_kubernetes_cluster.paypulse]
}

# Install nginx-ingress controller via Helm
resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.11.1"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }

  depends_on = [azurerm_kubernetes_cluster.paypulse]
}