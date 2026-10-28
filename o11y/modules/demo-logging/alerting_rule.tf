locals {
  runbook_url = "https://cloud.elastic.dev/sre/runbooks/my-kewl-svc"
}

resource "elasticstack_kibana_alerting_rule" "my-svc-alerting-rule" {
  name         = "my-kewl-svc"
  notify_when  = "onActionGroupChange"
  rule_type_id = "xpack.uptime.alerts.monitorStatus"
  consumer     = "alerts"
  enabled      = true
  interval     = "1m"
  tags         = var.common_tags
  params = jsonencode({
    search                  = "",
    numTimes                = 8,
    timerangeUnit           = "m",
    timerangeCount          = 10,
    shouldCheckStatus       = true,
    shouldCheckAvailability = false,
    availability = {
      range     = 30,
      rangeUnit = "d",
      threshold = "99"
    },
    filters = {
      tags = ["o11y"]
    }
  })
  actions {
    group = "xpack.uptime.alerts.actionGroups.monitorStatus"
    id    = var.slack_connector_id
    params = jsonencode({
      subAction = "postMessage",
      subActionParams = {
        channels = var.slack_channel_id
        text     = ":alert1: *[${var.environment}] {{rule.name}}* | :kibana:<{{context.viewInAppUrl}}|Monitor> | :notebook:<${local.runbook_url}|Runbook> | <{{kibanaBaseUrl}}/app/observability/alerts?rangeFrom={{context.timestamp}}%7C%7C-5m&rangeTo=now|Alert Details>\n{{context.monitorName}} from {{context.observerLocation}}\nmy-kewl-svc is unhealthy\nReason: {{context.reason}}\nAlertID: `{{rule.name}} | {{context.monitorName}}`"
      }
    })
  }
  actions {
    group = "recovered"
    id    = var.slack_connector_id
    params = jsonencode({
      subAction = "postMessage",
      subActionParams = {
        channels = var.slack_channel_id
        text     = ":white_check_mark:  [${var.environment}] Alert recovered for {{context.monitorName}} from {{context.observerLocation}}.\nAlertID: `{{rule.name}} | {{context.monitorName}}`"
      }
    })
  }

  dynamic "actions" {
    for_each = var.environment == "production" ? [1] : [] #ping pagerduty in prod only
    content {
      group = "recovered"
      id    = var.pd_connector_id
      params = jsonencode({
        dedupKey    = "{{rule.id}}:{{context.monitorName}}",
        eventAction = "resolve"
      })
    }
  }

  dynamic "actions" {
    for_each = var.environment == "production" ? [1] : []
    content {
      group = "xpack.uptime.alerts.actionGroups.monitorStatus"
      id    = var.pd_connector_id
      params = jsonencode({
        dedupKey    = "{{rule.id}}:{{context.monitorName}}",
        eventAction = "trigger",
        summary     = "{{rule.name}} Kibana: my-kewl-svc status is unhealthy. {{context.reason}} | runbook: ${local.runbook_url}",
        severity    = "critical",
        timestamp   = "{{context.date}}",
        component   = ""
      })
    }
  }
}
