terraform {
  required_version = "~> 1.17.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.73"
    }
  }

  # Remote state: create the S3 bucket first, then uncomment and run
  # `terraform init -migrate-state`. (S3 native locking; no DynamoDB table needed.)
  # backend "s3" {
  #   bucket       = "<state-bucket-name>"
  #   key          = "agent-stack/terraform.tfstate"
  #   region       = "<region>"
  #   use_lockfile = true
  # }
}
