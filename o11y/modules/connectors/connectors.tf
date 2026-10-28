//Slack
resource "elasticstack_kibana_action_connector" "o11y-alertbot" { //create the connector in dev, please do not create `o11y-alertbot` in other envs since it is shared
  count             = var.environment == "dev" ? 1 : 0
  name              = "o11y-alertbot"
  connector_type_id = ".slack_api"
  secrets = jsonencode({
    token = "dummy-token" //your team might want to have a live token in dev, feel free to add something to vault if you want
  })
}

data "elasticstack_kibana_action_connector" "o11y-alertbot" { //use shared connector in non-dev envs
  count = var.environment == "dev" ? 0 : 1
  name  = "o11y-alertbot"
}

locals {
  o11y_alertbot_connector_id = var.environment == "dev" ? elasticstack_kibana_action_connector.o11y-alertbot[0].id : data.elasticstack_kibana_action_connector.o11y-alertbot[0].id
}

output "slack_connector_id" {
  value     = split("/", local.o11y_alertbot_connector_id)[1] #hack off `$space/` to get the connector ID
  sensitive = true
}


//PagerDuty
resource "elasticstack_kibana_action_connector" "pd_my_svc" {
  count             = var.environment == "dev" ? 1 : 0
  name              = "pd-my-svc"
  connector_type_id = ".pagerduty"
  secrets = jsonencode({
    routingKey = "dummy-key"
  })
}

data "elasticstack_kibana_action_connector" "pd_my_svc" {
  count = var.environment == "dev" ? 0 : 1
  name  = "pd-my-svc"
}

locals {
  pd_connector_id = var.environment == "dev" ? elasticstack_kibana_action_connector.pd_my_svc[0].id : data.elasticstack_kibana_action_connector.pd_my_svc[0].id
}

output "pd_connector_id" {
  value     = split("/", local.pd_connector_id)[1] #hack off `$space/` to get the connector ID
  sensitive = true
}
