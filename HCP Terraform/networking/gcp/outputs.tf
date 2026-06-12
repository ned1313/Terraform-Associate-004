output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.main.id
}

output "subnet_id" {
  description = "The self link of the public subnet"
  value       = google_compute_subnetwork.public.self_link
}
