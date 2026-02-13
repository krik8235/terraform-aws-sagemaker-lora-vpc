# AWS SageMaker Multi-Model LoRA Infrastructure

This Terraform module deploys a production-ready (Free Tier) infrastructure for orchestrating LoRA (Low-Rank Adaptation) adapters with SageMaker Multi-Model Endpoints (MME).

## Features

- **Lambda Proxy**: A Python 3.12 entry point that handles dynamic adapter switching.
- **Automated Packaging**: Uses `uv` to automatically bundle `boto3` and `botocore` dependencies into the Lambda ZIP.
- **VPC Isolated**: Dedicated networking layer (VPC, Subnet, Security Groups) for secure model invocation.
- **S3 Storage**: Dedicated bucket for hosting your LoRA `.tar.gz` adapters.

## Prerequisites

1.  **AWS CLI**: Configured with credentials and a default region.
2.  **Terraform**: Version 1.6 or higher.
3.  **uv**: (Recommended) or `pip` installed for dependency bundling during the build process.


## Quick Start

- Follow these steps to deploy the stack:

```bash
# initialize terraform
terraform init

# create a deployment plan
terraform plan -out=tfplan

# apply the plan
terraform apply "tfplan"
```

- Once the deployment is complete, Terraform will display the lambda_url in the output section.


## Testing the Proxy

You can verify the connection to your SageMaker endpoint using curl.

First fetch the endpoint Lambda URL:

```bash
terraform output lambda_proxy_url
```

Then, replace the placeholder with the URL and run:

```bash
curl -X POST https://<YOUR_LAMBDA_PROXY_URL_HERE>/ \
     -H "Content-Type: application/json" \
     -d '{
           "userQuery": "Give me a discount because the delivery was late."
         }'
```

* The default LoRA adapter will transform `userQuery` into British tone.


## Cleanup

To avoid unnecessary AWS costs, destroy the infrastructure when finished:

```bash
# create a destruction plan
terraform plan -destroy -out=killplan

# execute the destruction
terraform apply "killplan"
```


## Pro Tier Features

For enterprise-grade performance and security, the Pro Tier includes:

- **Custom Training Data Set**: Transforms your data or creates structured training data sets in JSONL from the ground up to train LoRA adapters.
- **Custom Models and Adapters**: Choose the base model aligned with task goals and tune LoRA adapters with your training data.
- **VPC PrivateLink**: Build and connect to `SageMaker Runtime` directly via interface endpoints, ensuring traffic never leaves the `AWS` network.
- **Auto-Scaling Inference**: Automatic scaling of endpoint instances based on real-time request volume.
- **Secret Management**: Integrated handling of API keys and sensitive configuration via `AWS Secrets Manager`.


## Project Structure

```text
.
├── main.tf          # core infrastructure logic
├── variables.tf     # customizable input variables
├── outputs.tf       # deployment receipt (urls and ids)
├── README.md        # documentation
└── lambda/
    └── lambda_function.py  # python proxy logic
```


### Reference for Project Structure

To ensure your repository follows industry standards, you can refer to this guide on professional Terraform file organization:

[Terraform Best Practices for Project Structure](https://www.youtube.com/watch?v=PVLbr72G8pc)


## License

MIT
