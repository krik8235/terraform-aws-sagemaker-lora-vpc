output "lambda_proxy_url" {
  description = "The public URL of your LoRA Proxy. Use this in your frontend/client."
  value       = aws_lambda_function_url.proxy_url.function_url
}

output "s3_bucket_name" {
  description = "The name of your LoRA adapter bucket on S3."
  value       = aws_s3_bucket.lora_bucket.id
}

output "s3_bucket_arn" {
  description = "The ARN of your LoRA adapter bucket on S3."
  value       = aws_s3_bucket.lora_bucket.arn
}

output "vpc_id" {
  description = "The ID of the AWS VPC created."
  value       = aws_vpc.main.id
}
