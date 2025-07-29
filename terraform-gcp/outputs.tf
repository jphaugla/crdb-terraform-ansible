// terraform-gcp/outputs.tf
output "join_string" {
  description = "The comma‑separated list of CockroachDB node addresses for --join"
  value       = local.join_string
}

output "subnet_id" {
  value = google_compute_subnetwork.main_subnet.id
}

output "network_self_link" {
  description = "Self‑link of the VPC"
  value       = google_compute_network.main.self_link
}

output "network_name" {
  description = "Name of the VPC"
  value       = google_compute_network.main.name
}

output "subnet_self_link" {
  description = "Self‑link of the Subnetwork"
  value       = google_compute_subnetwork.main_subnet.self_link
}

output "subnet_name" {
  description = "Name of the Subnetwork"
  value       = google_compute_subnetwork.main_subnet.name
}

