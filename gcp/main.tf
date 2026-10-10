terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc" {
  name                    = "stock-dashboard-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "stock-dashboard-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc.id
  region        = var.region
}

resource "google_compute_firewall" "web" {
  name    = "stock-dashboard-web"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["stock-dashboard"]
}

resource "google_compute_instance" "vm" {
  name         = "stock-dashboard-vm"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["stock-dashboard"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      // Public IP
    }
  }

  metadata = {
    ssh-keys = "${var.admin_username}:${file(var.ssh_public_key_path)}"
  }
}
