/************************************************************
Compartment - workload
************************************************************/
resource "oci_identity_compartment" "workload" {
  compartment_id = var.tenancy_ocid
  name           = "oci-bastion-organize"
  description    = "For OCI Bastion Organize"
  enable_delete  = true
}