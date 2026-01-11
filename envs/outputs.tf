# /************************************************************
# Windows PW
# ************************************************************/
output "pw_windows" {
  description = "Windows Servers RDP PW"
  value       = random_string.instance_password.result
}