terraform {
  backend "gcs" {
    bucket = "jksolbakken-lf260-tfstate"
    prefix = "tofu/state"
  }
}

resource "google_compute_instance" "default" {
  provider     = google
  name         = "default"
  machine_type = "e2-micro"

  network_interface {
    network = "default"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-focal-v20220712"
    }
  }

  allow_stopping_for_update = true
}
