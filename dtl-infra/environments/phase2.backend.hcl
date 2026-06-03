# Backend config for the phase2 state.
# Use with:  terraform init -backend-config=environments/phase2.backend.hcl
#
# Fill in after bootstrapping the state storage account (see backend.tf).
resource_group_name  = "rg-dtl-tfstate"
storage_account_name = "REPLACE_WITH_UNIQUE_NAME"
container_name       = "tfstate"
key                  = "phase2.terraform.tfstate"
