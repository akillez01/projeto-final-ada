import boto3
import os
import zipfile
import subprocess

# Configurações AWS
BUCKET_NAME = "ada-contabilidade-storage"  # Nome do bucket criado no Terraform
ZIP_FILENAME = "arquivolambda.zip"
FILES_TO_ZIP = ['index.py', 'upload_zip.py', 'requirements.txt']  # Adicione outros arquivos conforme necessário

def zip_files(zip_filename, source_files):
    try:
        # Instalar dependências no diretório atual
        subprocess.check_call([os.sys.executable, '-m', 'pip', 'install', '-r', 'requirements.txt', '-t', '.'])
        
        # Cria o arquivo zip
        with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for file in source_files:
                # Adiciona arquivos ao zip
                zipf.write(file, os.path.basename(file))  # Usando basename para manter os nomes de arquivos no ZIP
            
            # Adiciona dependências ao zip
            for root, dirs, files in os.walk('.'):
                for file in files:
                    if file.endswith('.py') and file not in source_files:
                        zipf.write(os.path.join(root, file))
        print(f"Arquivo {zip_filename} criado com sucesso!")
    except Exception as e:
        print(f"Erro ao criar o arquivo ZIP: {e}")

def upload_to_s3(file_path, bucket_name, object_name=None):
    if object_name is None:
        object_name = os.path.basename(file_path)

    # Criar cliente S3
    s3_client = boto3.client("s3")
    try:
        s3_client.upload_file(file_path, bucket_name, object_name)
        print(f"Arquivo {file_path} enviado para o bucket {bucket_name} como {object_name}")
    except Exception as e:
        print(f"Erro ao enviar o arquivo: {e}")

if __name__ == "__main__":
    # Cria o arquivo ZIP
    zip_files(ZIP_FILENAME, FILES_TO_ZIP)

    # Verifica se o arquivo ZIP foi gerado antes de tentar fazer o upload
    if os.path.exists(ZIP_FILENAME):
        upload_to_s3(ZIP_FILENAME, BUCKET_NAME)
    else:
        print(f"Arquivo {ZIP_FILENAME} não existe. Por favor, gere o arquivo primeiro.")