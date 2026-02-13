variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name for LoRA adapters"
  type        = string
  default     = "tf-demo-lora-multi-adapter"
}

variable "vpc_name" {
  description = "Name of the SageMaker VPC"
  type        = string
  default     = "tf-demo-lora-vpc"
}

variable "lambda_function_name" {
  description = "Name of Lambda Proxy Function"
  type        = string
  default     = "tf-demo-lora-proxy"
}

variable "allowed_origins" {
  description = "Allowed CORS origins for Lambda Proxy"
  type        = list(string)
  default     = ["http://localhost:3000"]
}
