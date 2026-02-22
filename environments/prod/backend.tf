terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-ptesk-infra-static-website"
    key          = "prod/terraform.tfstate" # Explicit environment prefix — no workspace injection needed
    region       = "us-east-2"             # Prod lives in us-east-2; backend bucket stays in ap-south-1
    encrypt      = true
    use_lockfile = true
  }
}
