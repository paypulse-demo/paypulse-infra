output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = try(azurerm_kubernetes_cluster.paypulse.name)
}

output "cluster_location" {
  description = "Location of the cluster"
  value       = var.location
}

output "namespace" {
  description = "Application namespace"
  value       = kubernetes_namespace.paypulse_prod.metadata[0].name
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = can(azurerm_kubernetes_cluster.paypulse) ? format("az aks get-credentials --resource-group %s --name %s", azurerm_resource_group.paypulse.name, azurerm_kubernetes_cluster.paypulse.name) : ""
}