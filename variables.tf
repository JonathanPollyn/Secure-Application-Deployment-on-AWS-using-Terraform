variable "domain_zone_name" {
  type = string
}

variable "app_record_name" {
  type = string
}


variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  sensitive   = true
}
