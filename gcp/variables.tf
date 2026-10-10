variable "project_id" {
  description = "The GCP project ID where the VM will be created."
  type        = string
}

variable "region" {
  description = "GCP region for the VPC and subnet."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for the VM."
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "Machine type for the Linux VM."
  type        = string
  default     = "e2-micro"
}

variable "admin_username" {
  description = "Username used for SSH access to the VM."
  type        = string
  default     = "gcpuser"
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key used to access the VM."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
