resource "google_secret_manager_secret" "db_password" {
  name = "db_password"
}

resource "google_secret_manager_secret_version" "db_password" {
  secret = google_secret_manager_secret.db_password.name

  secret_data = var.sql_user_password
}
