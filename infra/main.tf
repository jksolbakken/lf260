terraform {
  backend "gcs" {
    bucket = "jksolbakken-lf260-tfstate"
    prefix = "tofu/state"
  }
}

resource "google_compute_network" "lfclass_network" {
  name = "lfclass"
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
}

resource "google_compute_subnetwork" "vpc_sub" {
  name = "lfclass-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region = var.gcp_region
  network = google_compute_network.lfclass_network.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "rules" {
  project     = var.gcp_project
  name        = "open4all"
  network     = google_compute_network.lfclass_network.id
  description = "allow from all ips"
  allow {
    protocol = "tcp"
    ports = [ "22", "443" ]
  }
  source_ranges = [ "0.0.0.0/0" ]
}

resource "google_compute_address" "worker-external-ip" {
  name = "worker-ipv4-address"
}

resource "google_compute_instance" "master" {
  provider     = google
  name         = "master"
  machine_type = "e2-standard-2"

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_sub.name
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-noble-arm64-v20240615"
    }
  }

  allow_stopping_for_update = true
}

resource "google_compute_instance" "worker" {
  provider     = google
  name         = "worker"
  machine_type = "e2-standard-2"

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_sub.name
    access_config {
      nat_ip = google_compute_address.worker-external-ip.address
    }
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-noble-arm64-v20240615"
    }
  }

  allow_stopping_for_update = true
}
