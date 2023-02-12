# service account
data "google_service_account" "compute" {
  account_id = var.compute_engine_sa
}
resource "google_project_iam_binding" "iam_binding" {
  count = length(var.service_account_iam_roles)

  project = var.gcp_project
  role    = var.service_account_iam_roles[count.index]
  members = ["serviceAccount:${data.google_service_account.compute.email}"]
}

# instance template
resource "google_compute_instance_template" "instance_template" {
  name         = "${var.name}-ilb-mig-template"
  machine_type = "e2-micro"
  tags         = ["http-server"]

  network_interface {
    network    = var.network_id
    subnetwork = var.subnet_id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-11"
    auto_delete  = true
    boot         = true
  }

  metadata_startup_script = <<EOS
sudo su -
echo "export EDITOR=vi" >> /root/.bashrc
useradd -mD ${var.vm_user}
useradd -m misskey
echo '${var.ssh_pub_key}' >> /home/${var.vm_user}/.ssh/authorized_keys
	EOS

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    email  = data.google_service_account.compute.email
    scopes = ["cloud-platform"]
  }
}

# MIG
resource "google_compute_instance_group_manager" "mig" {
  name = "${var.name}-ilb-mig"
  zone = "asia-northeast1-b"

  version {
    instance_template = google_compute_instance_template.instance_template.id
    name              = "primary"
  }
  base_instance_name = var.name
  target_size        = 1

  named_port {
    name = "http"
    port = 80
  }
}
