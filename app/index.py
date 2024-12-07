import json
import boto3

def handler(event, context):
    # Seu código aqui
    return {
        'statusCode': 200,
        'body': json.dumps('Hello Lambda!')
    }