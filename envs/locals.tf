# /************************************************************
# Common
# ************************************************************/
locals {
  common_defined_tags = {
    format("%s.%s", oci_identity_tag_namespace.common.name, oci_identity_tag_default.key_env.tag_definition_name)                = "prd"
    format("%s.%s", oci_identity_tag_namespace.common.name, oci_identity_tag_default.key_managedbyterraform.tag_definition_name) = "true"
  }
}

# /************************************************************
# Log Group / Capture Filter / VCN Flow Logs
# ************************************************************/
locals {
  flowlog_sets = {
    ### For Bastion
    bastion = {
      ### Log Group
      log_group_name = "lg-vcn-flow-logs-bastion"
      log_group_desc = "For Bastion VCN Flow Logs"
      ### Capture Filter
      capture_name = "cf-vcn-flow-logs-bastion"
      capture_rules = [
        {
          priority         = 0
          sampling_rate    = 1
          is_enabled       = true
          flow_log_type    = "ALL"
          rule_action      = "INCLUDE"
          source_cidr      = "0.0.0.0/0"
          destination_cidr = "0.0.0.0/0"
          protocol         = "6"
        }
      ]
      ### Logs
      log_name  = "logs-vcn-flow-logs-bastion"
      subnet_id = oci_core_subnet.private_bastion.id
    }
    ### For Oracle
    oracle = {
      ### Log Group
      log_group_name = "lg-vcn-flow-logs-oracle"
      log_group_desc = "For Oracle VCN Flow Logs"
      ### Capture Filter
      capture_name = "cf-vcn-flow-logs-oracle"
      capture_rules = [
        {
          priority         = 0
          sampling_rate    = 1
          is_enabled       = true
          flow_log_type    = "ALL"
          rule_action      = "INCLUDE"
          source_cidr      = "0.0.0.0/0"
          destination_cidr = "0.0.0.0/0"
          protocol         = "6"
        }
      ]
      ### Logs
      log_name  = "logs-vcn-flow-logs-oracle"
      subnet_id = oci_core_subnet.private_oracle.id
    }
    ### For Windows
    windows = {
      ### Log Group
      log_group_name = "lg-vcn-flow-logs-windows"
      log_group_desc = "For Windows VCN Flow Logs"
      ### Capture Filter
      capture_name = "cf-vcn-flow-logs-windows"
      capture_rules = [
        {
          priority         = 0
          sampling_rate    = 1
          is_enabled       = true
          flow_log_type    = "ALL"
          rule_action      = "INCLUDE"
          source_cidr      = "0.0.0.0/0"
          destination_cidr = "0.0.0.0/0"
          protocol         = "6"
        }
      ]
      ### Logs
      log_name  = "logs-vcn-flow-logs-windows"
      subnet_id = oci_core_subnet.private_windows.id
    }
  }
}
