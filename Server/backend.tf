terraform {
  backend "s3" {
    bucket = "terraform-statefile-forservers2"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}