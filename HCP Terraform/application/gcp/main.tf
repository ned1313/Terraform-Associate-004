data "google_compute_subnetwork" "selected" {
  self_link = var.subnet_id
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = data.google_compute_subnetwork.selected.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_instance" "web" {
  name         = "taco-wagon-web"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.selected.self_link

    access_config {
      # Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>Welcome to the Taco Wagon App</h1>" > /var/www/html/index.html
              EOF

  labels = var.common_labels
}
