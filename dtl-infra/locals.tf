# Derived values and naming conventions shared across the root module.
locals {
  # Canonical name prefix, e.g. "dtl-phase2". Azure resource naming rules vary
  # (some disallow hyphens / have length caps); per-module locals adjust as needed.
  name_prefix = "${var.project}-${var.environment}"

  # Resource group that holds the whole stack for this environment.
  resource_group_name = "rg-${local.name_prefix}"

  # Merge common tags with an environment tag.
  tags = merge(var.tags, {
    environment = var.environment
  })
}
