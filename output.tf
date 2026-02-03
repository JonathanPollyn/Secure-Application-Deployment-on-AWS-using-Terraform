output "alb_dns" {
  value = aws_alb.alb.dns_name
}

output "app_url" {
  value = "https://${var.app_record_name}.${var.domain_zone_name}"
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}