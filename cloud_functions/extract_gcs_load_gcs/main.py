# %%
import os
from infer_date_from_filename import infer_date_from_filename
from unzip_file import unzip_file
from load_loop_habit import load_loop_habit

def extract_gcs_load_gcs(event, context):
#def extract_gcs_load_gcs(source_path:str, unizp_destination_path:str, processed_destination_path: str):
    source_path = os.path.join('gs://', event['bucket'], event['name'])
    unizp_destination_path = 'tmp/dump'
    processed_destination_path = 'tmp/clean'
    inferred_date = infer_date_from_filename(source_path)
    unzip_file(source_path, unizp_destination_path)
    load_loop_habit(unizp_destination_path, processed_destination_path, inferred_date)


