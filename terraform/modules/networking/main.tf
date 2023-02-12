# VPC network
resource "google_compute_network" "network" {
  name                    = "${var.name}-network"
  auto_create_subnetworks = false
}

# backend subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name}-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.network.id
}

# reserved IP (global)
resource "google_compute_global_address" "default" {
  name = "${var.name}-static-ip"
}

# reserved IP (internal)
resource "google_compute_global_address" "private_ip" {
  name          = "${var.name}-internal-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.network.id
}

# VPC Connector
resource "google_service_networking_connection" "networking_connection" {
  network                 = google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}
