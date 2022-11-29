terraform {
  backend "s3" {
    bucket = "terraform-statefile-bucket22444"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}