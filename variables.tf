variable "project_name" {
  description = "Project name, used as prefix for resources"
  type        = string
  default     = "paypulse"
}

variable "environment" {
  description = "Environment name (demo, staging, prod)"
  type        = string
  default     = "demo"
}

variable "location" {
  description = "Cloud region (Azure: westeurope)"
  type        = string
  default     = "westeurope"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "node_size" {
  description = "VM size for cluster nodes"
  type        = string
  # Azure: Standard_B2s (2 vCPU, 4 GB RAM) - cheapest viable
  # GCP:   e2-small (2 vCPU, 2 GB RAM)
  default     = "Standard_B2s"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.35"
}