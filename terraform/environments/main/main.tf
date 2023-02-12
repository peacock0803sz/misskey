locals {
  name = "misskey"
}

module "networking" {
  source = "../../modules/networking"

  name = local.name
}

module "compute_instance" {
  source = "../../modules/compute_instance"

  gcp_project       = "misskey-peacock0803sz"
  compute_engine_sa = var.compute_engine_sa
  service_account_iam_roles = [
    "roles/iap.tunnelResourceAccessor",
  ]
  network_id  = module.networking.compute_network_id
  subnet_id   = module.networking.compute_subnet_id
  name        = local.name
  vm_user     = "peacock"
  ssh_pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCecvu/n6E3qw1W3Ih0AEXPA1mNGGrZ70lDuaQ1S0vze/thx6hA79InczhDN1fEBV8XZH3X06RXJiKkllcPNfRe3NEX8fJFBYXE+dpNODReN8cP4jGHQS4X/4decS8Z3IdwA2yqKFeC/VQ5ik4UlnZHhgjRjEcNd6HxGbAKegz4DO053JxLjHqytb5/QhPt/IelqU/p6s5RUMqG9uV37qGZeVGzefg88QnGMk31yqbhAmiRaQZX/wRWcukRm3Tqbq48UkxVOTfLYy0gh6gTzxuZtyohdcwYYFnam5lpgRtDIJc13qriO9oB5sILCC+lpSZgzd95cytBYicbVNdb0OB4ZhtXoPLo4aP7dHNVyPt8evpr0uSw7kbH7WxAEYQbUNNjHUbnjulDVPM5ZrVmQu++WBbT5P05sfyidtfNj8N0A7p1l2XCUV4NQ3qALjGjjai34GrJQ+hEgRpqxytEC1J20xGIPTpGS+U0z3QIfiT3WX5fQMK+BBEeC/ryhTbl7oeAwJPaQJ0U5hr9XrVqo+ZKHx3vmlDVuAPoBbxgll5d/suVrCW3KW5OVxEtkMifWsGZrZ7Vh329vZqP3p3Vg1pyLB0JjvYMbUdCTlkn3loNFcU1UDrK2rhfoeoh9AqEzDq24L/XSWIxAUxlz5XqKB7DWXHSs6Yuigw22h5t7K0bgQ== contact@peacock0803sz.com"

  depends_on = [
    module.networking
  ]
}

module "compute_network" {
  source = "../../modules/compute_network"

  name                   = local.name
  compute_global_address = module.networking.compute_global_address
  compute_mig_url        = module.compute_instance.compute_mig_url
  network_id             = module.networking.compute_network_id

  depends_on = [
    module.networking,
    module.compute_instance
  ]
}

module "cloud_sql" {
  source = "../../modules/cloud_sql"

  instance_name     = local.name
  machine_tier      = "db-f1-micro"
  availability_type = "REGIONAL"
  disk_size         = 100
  network_id        = module.networking.compute_network_id
  db_username       = "misskey"

  depends_on = [
    module.networking,
    module.compute_instance
  ]
}


