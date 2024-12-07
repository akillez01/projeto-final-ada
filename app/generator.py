import zipfile
import os

def zip_files(zip_filename, source_files):
    try:
        # Cria o arquivo zip
        with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for file in source_files:
                # Adiciona arquivos ao zip
                zipf.write(file, os.path.basename(file))  # Usando basename para manter os nomes de arquivos no ZIP
        print(f"Arquivo {zip_filename} criado com sucesso!")
    except Exception as e:
        print(f"Erro ao criar o arquivo ZIP: {e}")

if __name__ == "__main__":
    # Arquivos que você deseja adicionar ao ZIP
    files_to_zip = ['generator.py', 'uploader.py']  # Adicione outros arquivos conforme necessário
    
    # Nome do arquivo ZIP de saída
    zip_filename = 'fileProcessor.zip'
    
    zip_files(zip_filename, files_to_zip)
