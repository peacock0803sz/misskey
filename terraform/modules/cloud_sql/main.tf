resource "random_password" "db_password" {
  length           = 32
  override_special = "()-_=+[]{}<>!@$%&"
}

resource "google_sql_database_instance" "cloud_sql_instance" {
  name                = var.instance_name
  database_version    = "POSTGRES_14"
  deletion_protection = false

  settings {
    tier              = var.machine_tier
    availability_type = var.availability_type
    disk_size         = var.disk_size

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }
}

resource "google_sql_user" "db_user" {
	name     = var.db_username
	instance = google_sql_database_instance.cloud_sql_instance.name
	password = random_password.db_password.result
}
