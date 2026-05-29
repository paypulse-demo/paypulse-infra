# For the demo, we use local state.
# In production you would use remote state in Azure Storage or GCS,
# with state locking via blob lease or GCS object versioning.
#
# Example for Azure (commented out):
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "tfstate-rg"
#     storage_account_name = "tfstateXXXXX"
#     container_name       = "tfstate"
#     key                  = "paypulse.tfstate"
#   }
# }