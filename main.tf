resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ${path.module}/package
      cp ${path.module}/lambda/lambda_function.py ${path.module}/package/
      uv pip install --target ${path.module}/package boto3 botocore
    EOT
  }
  triggers = {
    code_hash = filemd5("${path.module}/lambda/lambda_function.py")
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/package"
  output_path = "${path.module}/function.zip"
  depends_on  = [null_resource.install_dependencies]
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = var.vpc_name }
}

resource "aws_subnet" "sub1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.vpc_name}-lambda-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow Lambda to talk to SageMaker API"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "lora_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_iam_role" "iam_role" {
  name = "${var.vpc_name}-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = ["lambda.amazonaws.com", "sagemaker.amazonaws.com"] }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sagemaker_invoke" {
  name = "lambda-sagemaker-invoke-policy"
  role = aws_iam_role.iam_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sagemaker:InvokeEndpoint"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "proxy" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = var.lambda_function_name
  role             = aws_iam_role.iam_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 900
}


resource "aws_lambda_function_url" "proxy_url" {
  function_name      = aws_lambda_function.proxy.function_name
  authorization_type = "NONE"
  cors {
    allow_origins  = var.allowed_origins
    allow_methods  = ["*"]
    allow_headers  = ["*"]
    expose_headers = ["keep-alive", "date"]
    max_age        = 86400
  }
}

resource "aws_lambda_permission" "allow_public_access" {
  statement_id           = "AllowPublicInvocation"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.proxy.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

resource "aws_lambda_permission" "allow_invoke_function" {
  statement_id  = "AllowPublicInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.proxy.function_name
  principal     = "*"
}
