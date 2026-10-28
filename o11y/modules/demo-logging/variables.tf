#All of these variables come from the cluster metadata, they are automatically set by cluster-mgmt, eg https://github.com/elastic/cluster-mgmt-resources/blob/main/baseconfig/qa.conf.d/qa-clusters.yaml#L11-L15
variable "csp" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "purpose" {
  type = string
}

variable "deployment_id" {
  type = string
}

#These variables are custom, you can make however many you want. Check out the `inputs` in targets.yaml
variable "common_tags" {
  type = list(string)
}

variable "slack_channel_id" {
  type = string
}

variable "slack_connector_id" {
  type = string
}

variable "pd_connector_id" {
  type = string
}
