terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-ptesk-infra-static-website"
    key          = "dev/terraform.tfstate" # Explicit environment prefix — no workspace injection needed
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
