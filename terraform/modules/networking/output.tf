output "compute_network_id" {
	value = google_compute_network.network.id
}
output "compute_subnet_id" {
	value = google_compute_subnetwork.subnet.id
}
output "compute_global_address" {
	value = google_compute_global_address.default.address
}
