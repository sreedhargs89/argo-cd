# Remote state in Azure Blob Storage.
#
# The storage account / container that holds this state must exist BEFORE the
# first `terraform init` (chicken-and-egg: state can't store its own backend).
# Bootstrap it once, manually or with a tiny separate root, e.g.:
#
#   az group create -n rg-dtl-tfstate -l japaneast
#   az storage account create -n stdtltfstate<unique> -g rg-dtl-tfstate \
#       -l japaneast --sku Standard_LRS --min-tls-version TLS1_2
#   az storage container create -n tfstate --account-name stdtltfstate<unique>
#
# Values are intentionally left blank and supplied at init time via a backend
# config file so the same code serves multiple environments:
#
#   terraform init -backend-config=environments/phase2.backend.hcl
terraform {
  backend "azurerm" {
    # resource_group_name  = "rg-dtl-tfstate"
    # storage_account_name = "stdtltfstate<unique>"
    # container_name       = "tfstate"
    # key                  = "phase2.terraform.tfstate"
  }
}
