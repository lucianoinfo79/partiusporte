output "ecr_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "ECR repository for the Partiusporte homologation image."
}

output "certificate_validation_records" {
  value = [
    for option in aws_acm_certificate.app.domain_validation_options : {
      name  = option.resource_record_name
      type  = option.resource_record_type
      value = option.resource_record_value
    }
  ]
  description = "Add these DNS CNAME records to validate the TLS certificate."
}

output "certificate_arn" {
  value       = aws_acm_certificate.app.arn
  description = "ACM certificate ARN; wait until its status is ISSUED before enabling the application."
}

output "application_cname_target" {
  value       = aws_lb.app.dns_name
  description = "Create a CNAME from app_host to this ALB DNS name after ACM validation."
}

output "application_url" {
  value       = "https://${var.app_host}"
  description = "Homologation URL."
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.app.name
}

output "web_service_name" {
  value = "${local.name}-web"
}

output "worker_service_name" {
  value = "${local.name}-worker"
}

output "web_task_definition" {
  value = var.enable_application ? aws_ecs_task_definition.web[0].family : null
}

output "database_endpoint" {
  value = aws_db_instance.partiusporte.address
}

output "application_security_group_id" {
  value = aws_security_group.application.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "database_secret_arn" {
  value       = aws_db_instance.partiusporte.master_user_secret[0].secret_arn
  description = "RDS-managed master secret ARN; value is never output."
}
