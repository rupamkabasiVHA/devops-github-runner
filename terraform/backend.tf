
terraform {
  backend "s3" {
    bucket         = "rupam-devops-terraform-state-bucket"
    key            = "github-runner/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}