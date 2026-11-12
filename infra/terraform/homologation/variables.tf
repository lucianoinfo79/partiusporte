variable "aws_region" {
  description = "AWS region for the Partiusporte homologation stack."
  type        = string
  default     = "sa-east-1"
}

variable "expected_account_id" {
  description = "Account guard for the MGL Atlas AWS account."
  type        = string
  default     = "414762935567"
}

variable "app_host" {
  description = "Public hostname used for Partiusporte homologation."
  type        = string
  default     = "hml.partiusporte.com.br"
}

variable "atlas_public_api_base_url" {
  description = "Atlas public API base URL used by the Partiusporte catalog."
  type        = string
  default     = "https://atlas-hml.mglsports.com.br/api/public/v1"
}

variable "atlas_public_origin" {
  description = "Browser-facing Atlas origin used for registration handoff."
  type        = string
  default     = "https://atlas-hml.mglsports.com.br"
}

variable "vpc_cidr" {
  description = "Dedicated CIDR for the Partiusporte VPC; adjust if it overlaps an existing network."
  type        = string
  default     = "10.44.0.0/16"
}

variable "image_tag" {
  description = "Immutable image tag to deploy after it has been pushed to ECR."
  type        = string
  default     = "homologation-initial"
}

variable "enable_application" {
  description = "Creates the HTTPS listeners, task definitions, and ECS services after the image and ACM certificate are ready."
  type        = bool
  default     = false
}

variable "initial_web_tasks" {
  description = "Initial web task count. Keep at zero until db:prepare completes."
  type        = number
  default     = 0
}

variable "initial_worker_tasks" {
  description = "Initial Solid Queue worker count. Keep at zero until db:prepare completes."
  type        = number
  default     = 0
}

variable "db_instance_class" {
  description = "RDS PostgreSQL instance size for homologation."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage_gb" {
  description = "Initial encrypted RDS storage size."
  type        = number
  default     = 20
}

variable "db_deletion_protection" {
  description = "Protects the homologation database from accidental deletion."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch retention for application logs."
  type        = number
  default     = 30
}
