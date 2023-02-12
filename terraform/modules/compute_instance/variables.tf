variable "gcp_project" { type = string }
variable "compute_engine_sa" { type = string }
variable "service_account_iam_roles" { type = list(string) }
variable "network_id" { type = string }
variable "subnet_id" { type = string }
variable "name" { type = string }
variable "vm_user" { type = string }
variable "ssh_pub_key" { type = string }
