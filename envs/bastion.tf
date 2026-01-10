# /************************************************************
# Private Key
# ************************************************************/
resource "tls_private_key" "ssh_keygen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  filename        = "./.key/private.pem"
  content         = tls_private_key.ssh_keygen.private_key_pem
  file_permission = "0600"
}

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
  defined_tags                 = local.common_defined_tags
}

# /************************************************************
# Session
# ************************************************************/
##### Managed SSH 
##### SSH port forwarding
##### Dynamic Port Forwarding (SOCKS5)