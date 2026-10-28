locals {
  slack_channel_ids = {
    "cloud-alerts-critical"            = "CGM2U8Q84" #feel free to change these for your own channels and requirements
    "cloud-observability"              = "CBMNS0WNP"
    "cloud-observability-alert-dev"    = "C011G4TLWJX"
    "sre-observability-prod-alerts"    = "C07N8N6QUQ5"
    "sre-observability-nonprod-alerts" = "C07P0CJTXFA"
  }

  env_to_channel = {
    "govcloud-high" = "sre-observability-prod-alerts" #allows you to dynamically change channel based on environment
    "govcloud-moderate" = "sre-observability-prod-alerts" #allows you to dynamically change channel based on environment
    "govcloud-staging" = "sre-observability-nonprod-alerts" #allows you to dynamically change channel based on environment
    "production"        = "sre-observability-prod-alerts"
    "staging"           = "sre-observability-nonprod-alerts"
    "qa"                = "sre-observability-nonprod-alerts"
    "dev"               = "cloud-observability-alert-dev"
  }
}

output "slack_channel_id" {
  value = local.slack_channel_ids[local.env_to_channel[var.environment]]
}
