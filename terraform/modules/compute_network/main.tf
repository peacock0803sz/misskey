# forwarding rule
resource "google_compute_global_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "${var.name}-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = var.compute_global_address
}

# HTTP target proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "${var.name}-target-http-proxy"
  url_map = google_compute_url_map.default.id
}

# URL map
resource "google_compute_url_map" "default" {
  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.default.id

}

# backend service
resource "google_compute_backend_service" "default" {
  name                  = "${var.name}-backend-subnet"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.default.id]
  backend {
    group           = var.compute_mig_url
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# health check
resource "google_compute_health_check" "default" {
  name               = "${var.name}-hc"
  check_interval_sec = 60
  http_health_check {
    port_specification = "USE_SERVING_PORT"
    request_path       = "/_genki" // TODO: Replace
  }
}


# allow all access from IAP and health check ranges
resource "google_compute_firewall" "fw_iap" {
  name          = "${var.name}-fw-allow-iap-hc"
  direction     = "INGRESS"
  network       = var.network_id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
}

# allow http from proxy subnet to backends
resource "google_compute_firewall" "fw_to_backends" {
  name          = "${var.name}-fw-allow-ilb-to-backends"
  direction     = "INGRESS"
  network       = var.network_id
  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["http-server"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
}

