locals {
  env_slo_target_map = {
    "dev"        = 0.80
    "qa"         = 0.90
    "staging"    = 0.95
    "production" = 0.99
    "govcloud-moderate" = 0.99
    "govcloud-staging" = 0.99
    "govcloud-high" = 0.99
  }
}

resource "elasticstack_kibana_slo" "test" {
  name        = "my-kewl-svc SLO"
  description = "my-kewl-svc SLO"
  tags        = var.common_tags

  kql_custom_indicator {
    index           = "logs-*"
    good            = "agent.id : supdawg"
    total           = "agent.id : supdawg"
    filter          = "agent.id : supdawg"
    timestamp_field = "@timestamp"
  }

  time_window {
    duration = "30d"
    type     = "rolling"
  }

  budgeting_method = "occurrences"

  objective {
    target = local.env_slo_target_map[var.environment] #this is a demonstration how you can change values based on the environment (or any other variable)
  }

  settings {
    sync_delay = "1m"
    frequency  = "1m"
  }

  group_by = ["*"]
}
