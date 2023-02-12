output "sql_user_password" {
	value = random_password.db_password.result
}
