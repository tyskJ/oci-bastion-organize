# /************************************************************
# Bastion
# ************************************************************/
resource "oci_bastion_bastion" "this" {
  name                         = "bastion"
  compartment_id               = oci_identity_compartment.workload.id
  bastion_type                 = "STANDARD"
  target_subnet_id             = oci_core_subnet.private_bastion.id
  dns_proxy_status             = "ENABLED" # Flag to enable FQDN and SOCKS5 Proxy Support.
  client_cidr_block_allow_list = [var.source_ip]
  max_session_ttl_in_seconds   = 10800 # Max minutes (3 hours)
  defined_tags = {
    format("%s.%s", oci_identity_tag_namespace.common.name, oci_identity_tag_default.key_env.tag_definition_name)                = "prd"
    format("%s.%s", oci_identity_tag_namespace.common.name, oci_identity_tag_default.key_managedbyterraform.tag_definition_name) = "true"
  }
}

# /************************************************************
# Session
# ************************************************************/
##### Managed SSH 
##### SSH port forwarding
##### Dynamic Port Forwarding (SOCKS5)