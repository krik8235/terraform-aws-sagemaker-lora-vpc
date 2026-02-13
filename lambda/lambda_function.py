import boto3, json, os
from botocore.config import Config

def lambda_handler(event, context):
    config = Config(read_timeout=1200, connect_timeout=10, retries={'max_attempts': 0})
    region_name = os.environ.get('AWS_REGION', "us-east-1")
    runtime = boto3.client('sagemaker-runtime', region_name=region_name, config=config)

    h = event.get('headers', {})
    target_model = h.get('x-amzn-sagemaker-target-model') or h.get('X-Amzn-SageMaker-Target-Model') or 'uk-r8-a8-all.tar.gz'
    
    input_body = event.get('body')
    if isinstance(input_body, str): input_body = input_body.encode('utf-8')

    try:
        response = runtime.invoke_endpoint(
            EndpointName="lora-multi-adapter-mme-endpoint",
            ContentType='application/json',
            TargetModel=target_model,
            Body=input_body
        )
        
        result_str = response['Body'].read().decode('utf-8')
        return { 
            'statusCode': 200, 
            'body': result_str
        }
    
    except Exception as e:
        return { 'statusCode': 500, 'body': json.dumps({"error": str(e)}) }    

