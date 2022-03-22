# Specify the provider and access details
provider "aws" {
  region = var.aws_region
  access_key = env.AWS_ACCESS_KEY_ID
  secret_key = env.AWS_SECRET_ACCESS_KEY
}
