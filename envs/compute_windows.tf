/************************************************************
PW
************************************************************/
resource "random_string" "instance_password" {
  length  = 16
  special = true
}

/************************************************************
Cloud-Init
************************************************************/
data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = true
  part {
    filename     = "windows_init.ps1"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/userdata/windows_init.ps1", {
      instance_user     = "opc"
      instance_password = random_string.instance_password.result
    })
  }
}

/************************************************************
Compute (Windows Server)
************************************************************/
##### Instance
resource "oci_core_instance" "windows_instance" {
  display_name        = "windows-instance"
  compartment_id      = oci_identity_compartment.workload.id
  availability_domain = data.oci_identity_availability_domain.ads.name
  fault_domain        = data.oci_identity_fault_domains.fds.fault_domains[0].name
  shape               = "VM.Standard.E5.Flex"
  shape_config {
    ocpus         = 8
    memory_in_gbs = 12
  }
  instance_options {
    are_legacy_imds_endpoints_disabled = false
  }
  availability_config {
    is_live_migration_preferred = false
    recovery_action             = "RESTORE_INSTANCE"
  }
  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
    plugins_config {
      desired_state = "ENABLED"
      name          = "Custom Logs Monitoring"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Run Command"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Cloud Guard Workload Protection"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Block Volume Management"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "OS Management Hub Agent"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Fleet Application Management Service"
    }
  }
  create_vnic_details {
    display_name = "windows-instance-vnic"
    subnet_id    = oci_core_subnet.private_windows.id
    nsg_ids = [
      oci_core_network_security_group.sg_windows.id
    ]
    assign_public_ip = false
    # 最大63文字 (Windowsは15文字)
    # 英数字、ハイフンは使用可
    # ピリオドは使用不可
    # 先頭 or 末尾にハイフンは使用不可
    # 数字のみになることは不可
    # RFC952 及び RFC1123 に準拠する必要有
    # 後から変更可
    hostname_label = "windows-instance"
  }
  is_pv_encryption_in_transit_enabled = true
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.windows_supported_image.images[0].id
    # boot_volume_size_in_gbs         = "100"
    boot_volume_vpus_per_gb         = "10"
    is_preserve_boot_volume_enabled = false
    # kms_key_id                      = null
  }
  metadata = {
    user_data = data.cloudinit_config.this.rendered
  }
  defined_tags = local.common_defined_tags
}