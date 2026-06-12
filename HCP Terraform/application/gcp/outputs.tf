output "instance_public_ip" {
  description = "The public IP address of the compute instance"
  value       = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}
