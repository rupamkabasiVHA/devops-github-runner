terraform {
  backend "s3" {
    bucket       = "rupam-terraform-state-bucket"
    key          = "github-runner/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}