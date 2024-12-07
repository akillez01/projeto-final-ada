import boto3
import os

# Configurações AWS
BUCKET_NAME = "ada-contabilidade-file-storage"  # Nome do bucket criado no Terraform
FILE_NAME = "output.json"

def upload_to_s3(file_path, bucket_name, object_name=None):
    if object_name is None:
        object_name = os.path.basename(file_path)

    # Criar cliente S3
    s3_client = boto3.client("s3")
    try:
        s3_client.upload_file(file_path, bucket_name, object_name)
        print(f"File {file_path} uploaded to bucket {bucket_name} as {object_name}")
    except Exception as e:
        print(f"Error uploading file: {e}")

if __name__ == "__main__":
    # Verifica se o arquivo foi gerado antes de tentar fazer o upload
    if os.path.exists(FILE_NAME):
        upload_to_s3(FILE_NAME, BUCKET_NAME)
    else:
        print(f"File {FILE_NAME} does not exist. Please generate the data first.")
