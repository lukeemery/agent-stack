variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}
