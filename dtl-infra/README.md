# DTL Platform — Azure Infrastructure (Terraform)

Infrastructure-as-Code for the **AGH DTL System** (Data Transformation Layer),
Phase 2, on Microsoft Azure. This repository provisions **infrastructure only** —
application code (Web / Validation / Normalization / Transform / Reporting /
Notification) is delivered separately by the development teams and deployed onto
the infrastructure defined here.

## Status: Skeleton + one reference module

This is a deliberate starting point, not the complete stack:

- ✅ **Root module wiring** — resource group, shared variables, naming, tags, outputs
- ✅ **Remote state backend** (Azure Blob) — config in `backend.tf`
- ✅ **`modules/networking`** — fully built (VNet, subnets, NSGs, no-public-IP posture)
- 🚧 **All other modules** — wired as commented stubs in `main.tf`, to be built
  by copying the networking module's structure

## Layout

```
dtl-infra/
├── versions.tf              # Terraform & provider version pins
├── providers.tf             # azurerm / random providers (auth via env)
├── backend.tf               # Azure Blob remote state (bootstrap notes inside)
├── variables.tf             # Shared input variables
├── locals.tf                # Naming conventions & merged tags
├── main.tf                  # RG + module wiring (networking active; rest stubbed)
├── outputs.tf               # Root outputs
├── terraform.tfvars.example # Sample variable values
├── environments/
│   ├── phase2.tfvars        # Phase-2 variable values
│   └── phase2.backend.hcl   # Phase-2 backend config
└── modules/
    └── networking/          # FULLY BUILT reference module
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## Mapping to the requirements (deep-dive §11)

| Requirement | Module | State |
|-------------|--------|-------|
| VNet + private/public/data subnets, NSGs | `networking` | ✅ built |
| Azure VM (no public IP) | `compute` | 🚧 stub |
| Application Gateway (HTTPS term, KV cert) | `app_gateway` | 🚧 stub |
| Blob Storage (~12 GB, 7-yr lifecycle) | `storage` | 🚧 stub |
| PostgreSQL Flexible Server | `postgresql` | 🚧 stub |
| Key Vault | `key_vault` | 🚧 stub |
| Communication Services (email) | `communication` | 🚧 stub |
| Monitor + Log Analytics | `monitoring` | 🚧 stub |
| Data Factory | `data_factory` | 🚧 stub |
| Repos + Pipelines (CI/CD) | n/a (pipeline yaml) | 🚧 future |

## Prerequisites

- Terraform `>= 1.6`
- Azure CLI authenticated to the AGH subscription (`az login`), or a service
  principal exported as `ARM_CLIENT_ID` / `ARM_CLIENT_SECRET` /
  `ARM_TENANT_ID` / `ARM_SUBSCRIPTION_ID` for CI.
- A bootstrapped state storage account (see `backend.tf`).

## Usage

```bash
cd dtl-infra

# 1. One-time: bootstrap the state storage account (see backend.tf), then
#    fill in environments/phase2.backend.hcl.

# 2. Initialise with the backend config
terraform init -backend-config=environments/phase2.backend.hcl

# 3. Review the plan
terraform plan -var-file=environments/phase2.tfvars

# 4. Apply
terraform apply -var-file=environments/phase2.tfvars
```

> ⚠️ Set `allowed_vpn_source_cidrs` to the real IBM VPN / AGH ranges before
> applying. While empty, the Application Gateway NSG **denies all inbound**
> (fail-closed) — intentional so nothing is exposed by accident.

## Extending: build the next module

1. `cp -r modules/networking modules/<name>` and replace the body.
2. Expose what other modules need via `outputs.tf`.
3. Uncomment and complete the matching `module "<name>"` block in `main.tf`.
4. `terraform plan` to verify wiring, then apply.

## Notes

- This code is self-contained and not tied to the surrounding repository; it can
  be moved into a dedicated DTL infra repo (or Azure Repos) without changes.
- No credentials or secrets are committed. Certificates live in Key Vault;
  the App Gateway references them by secret ID.
```
