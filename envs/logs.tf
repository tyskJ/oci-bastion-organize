# /************************************************************
# Log Group
# ************************************************************/
##### For VCN Flow Logs
resource "oci_logging_log_group" "log_group" {
  for_each = local.flowlog_sets

  compartment_id = oci_identity_compartment.workload.id
  display_name   = each.value.log_group_name
  description    = each.value.log_group_desc
  defined_tags   = local.common_defined_tags
}

# /************************************************************
# Capture Filter - Flow log
# ************************************************************/
resource "oci_core_capture_filter" "capture_filter" {
  for_each = local.flowlog_sets

  compartment_id = oci_identity_compartment.workload.id
  display_name   = each.value.capture_name
  filter_type    = "FLOWLOG"
  dynamic "flow_log_capture_filter_rules" {
    for_each = each.value.capture_rules
    content {
      priority         = flow_log_capture_filter_rules.value.priority
      sampling_rate    = flow_log_capture_filter_rules.value.sampling_rate
      is_enabled       = flow_log_capture_filter_rules.value.is_enabled
      flow_log_type    = flow_log_capture_filter_rules.value.flow_log_type
      rule_action      = flow_log_capture_filter_rules.value.rule_action
      source_cidr      = flow_log_capture_filter_rules.value.source_cidr
      destination_cidr = flow_log_capture_filter_rules.value.destination_cidr
      protocol         = flow_log_capture_filter_rules.value.protocol
    }
  }
  defined_tags = local.common_defined_tags
}

# /************************************************************
# Logs - VCN Flow Logs
# ************************************************************/
resource "oci_logging_log" "flow" {
  for_each = local.flowlog_sets

  display_name = each.value.log_name
  is_enabled   = true
  log_type     = "SERVICE"
  configuration {
    # 対象リソース及びキャプチャフィルタのコンパートメントが一致していること
    compartment_id = oci_identity_compartment.workload.id
    source {
      source_type = "OCISERVICE"
      service     = "flowlogs"
      category    = "subnet"
      resource    = each.value.subnet_id
      parameters = {
        capture_filter = oci_core_capture_filter.capture_filter[each.key].id
      }
    }
  }
  log_group_id       = oci_logging_log_group.log_group[each.key].id
  retention_duration = 30
  defined_tags       = local.common_defined_tags
}