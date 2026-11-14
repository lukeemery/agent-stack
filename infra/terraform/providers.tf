provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "agent-stack"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
