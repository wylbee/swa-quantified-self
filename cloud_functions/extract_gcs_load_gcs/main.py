# %%
import os
import tempfile
from gcloud import storage
from infer_date_from_filename import infer_date_from_filename
from unzip_file import unzip_file
from load_loop_habit import load_loop_habit

def extract_gcs_load_gcs(event, context):
#def extract_gcs_load_gcs(source_path:str, unizp_destination_path:str, processed_destination_path: str):
    tmpdir = tempfile.gettempdir()
    source_uri = os.path.join('gs://', event['bucket'], event['name'])
    print(source_uri)
    source_path = f"{tmpdir}/new_file.zip"
    print(source_path)
    unizp_destination_path = f'{tmpdir}/dump'
    processed_destination_path = f'{tmpdir}/clean'

    os.makedirs(os.path.dirname(f"{tmpdir}/zip/"), exist_ok=True)
    client = storage.Client()
    bucket = client.bucket('qs-dev-352513-raw')
    blob = bucket.blob(event['name'])
    print(blob)
    blob.download_to_filename(source_path)
    #with open(source_path, 'wb') as file_obj:
    #    client.download_blob_to_file(source_uri, file_obj)

    
    inferred_date = infer_date_from_filename(source_uri)
    unzip_file(source_path, unizp_destination_path)
    load_loop_habit(unizp_destination_path, processed_destination_path, inferred_date)
