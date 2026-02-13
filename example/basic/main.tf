provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "lora_infra_demo" {
  source = "../../" # root
  region      = var.region
  vpc_name    = var.vpc_name
  bucket_name = lower("${var.bucket_name}-${random_id.suffix.hex}")
}

output "sagemaker_vpc_id" {
  value = module.lora_infra_demo.vpc_id
}

output "lambda_endpoint_url" {
  value = module.lora_infra_demo.lambda_proxy_url
}
