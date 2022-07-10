# %%
import os
from gcloud import storage
from infer_date_from_filename import infer_date_from_filename
from unzip_file import unzip_file
from load_loop_habit import load_loop_habit

def extract_gcs_load_gcs(event, context):
#def extract_gcs_load_gcs(source_path:str, unizp_destination_path:str, processed_destination_path: str):
    source_uri = os.path.join('gs://', event['bucket'], event['name'])
    print(source_uri)
    source_path = f"tmp/zip/{event['name']}"
    print(source_path)
    unizp_destination_path = 'tmp/dump'
    processed_destination_path = 'tmp/clean'

    client = storage.Client()
    bucket = client.bucket('qs-dev-352513-raw')
    blob = bucket.blob(event['name'])
    blob.download_to_filename(source_path)

    
    inferred_date = infer_date_from_filename(source_path)
    unzip_file(source_path, unizp_destination_path)
    load_loop_habit(unizp_destination_path, processed_destination_path, inferred_date)
