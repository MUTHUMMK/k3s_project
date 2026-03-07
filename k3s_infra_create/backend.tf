terraform {
  backend "s3" {
    bucket         = "tf-backend-test1"
    key            = "k3s-cluster/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "for-tf"
    encrypt        = true
  }
}